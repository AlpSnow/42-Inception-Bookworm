#!/bin/bash
set -e

# Le shebang -> #!/bin/bash
# Ça veut dire :
# exécuter ce script avec bash
# Sans ça, Linux ne saurait pas quel interpréteur utiliser.

# set -e -> si une commande échoue, le script s'arrête immédiatement
# C’est très important pour éviter :
# - une base partiellement créée
# - un user SQL mal configuré
# - un container qui continue malgré une erreur



# Ici, le script lit les fichiers xxx
# puis met leur contenu dans des variables bash : DB_ROOT_PASSWORD et DB_PASSWORD
# tr -d '\n' enlève le retour à la ligne.
# 2>/dev/null masque les erreurs
# || true évite que set -e stoppe le script si le fichier n’existe pas
# Donc le script ne plante pas immédiatement ici.
# Il fera les vérifications juste après.
DB_ROOT_PASSWORD="$(tr -d '\n' < /run/secrets/db_root_password.txt 2>/dev/null || true)"
DB_PASSWORD="$(tr -d '\n' < /run/secrets/db_password.txt 2>/dev/null || true)"


# on vérifie que dans notre .env les variables suivantes existent :
# DB_NAME existe
# DB_USER existe
# -z signifie : la variable est vide
# if = début de condition
# then = début du bloc à exécuter si la condition est vraie
# fi = fin du bloc if
if [ -z "$DB_NAME" ] || [ -z "$DB_USER" ]; then
  echo "ERROR: DB_NAME ou DB_USER manquant (.env)"
  exit 1
fi

# Même logique, mais pour les mots de passe (dans secret pour la securite)
if [ -z "$DB_ROOT_PASSWORD" ] || [ -z "$DB_PASSWORD" ]; then
  echo "ERROR: secrets manquants (db_root_password.txt / db_password.txt)"
  exit 1
fi

# MariaDB a besoin de ce dossier pour créer le socket :
# /run/mysqld/mysqld.sock
# Donc on le creer
# mkdir -p = crée le dossier s’il n’existe pas
# chown -R mysql:mysql = donne le dossier à l’utilisateur mysql
mkdir -p /run/mysqld
chown -R mysql:mysql /run/mysqld


# Vérifier si la DB a déjà été initialisée ou non :
# -f = teste si un fichier existe et est un fichier normal (C’est beaucoup plus fiable qu’un test sur un dossier)
if [ ! -f "/var/lib/mysql/.inception_db_initialized" ]; then
  echo "Initializing MariaDB data directory..."

  # Initialiser les tables système MariaDB
  # Cette commande crée la structure de base de MariaDB dans : /var/lib/mysql
  # --user=mysql = initialise pour l’utilisateur mysql
  # --basedir=/usr = base d’installation
  # --datadir=/var/lib/mysql = là où seront stockées les données
  # >/dev/null = masque la sortie standard pour avoir des logs plus propres.
  mariadb-install-db --user=mysql --basedir=/usr --datadir=/var/lib/mysql >/dev/null

  # Ici, on lance MariaDB temporairement pour pouvoir faire les commandes SQL de configuration
  # --skip-networking = MariaDB démarre sans réseau
  # Le & met le processus en arrière-plan. Sinon le script restait bloqué ici.
  # pid="$!" -> $! = PID du dernier processus lancé en arrière-plan
  # Donc on stocke le PID de ce MariaDB temporaire pour pouvoir l’arrêter ensuite.
  echo "Starting MariaDB temporarily for setup..."
  mysqld --user=mysql --datadir=/var/lib/mysql --skip-networking --socket=/run/mysqld/mysqld.sock &
  pid="$!"

  # MariaDB met un peu de temps à démarrer.
  # Donc on attend qu’il réponde vraiment.
  # mariadb ... -e "SELECT 1;" -> essaie simplement de se connecter et d’exécuter une requête SQL minimale.
  until mariadb --protocol=socket -uroot --socket=/run/mysqld/mysqld.sock -e "SELECT 1;" >/dev/null 2>&1; do
    sleep 1
  done


  # Créer la base et l’utilisateur (commandes sql)
  # '%' = cet utilisateur peut se connecter depuis n'importe quel host
  # FLUSH PRIVILEGES = Force MariaDB à recharger immédiatement les permissions.
  echo "Configuring database and users..."
  mariadb --protocol=socket -uroot --socket=/run/mysqld/mysqld.sock <<-SQL
    CREATE DATABASE IF NOT EXISTS \`${DB_NAME}\`;
    CREATE USER IF NOT EXISTS '${DB_USER}'@'%' IDENTIFIED BY '${DB_PASSWORD}';
    GRANT ALL PRIVILEGES ON \`${DB_NAME}\`.* TO '${DB_USER}'@'%';
    ALTER USER 'root'@'localhost' IDENTIFIED BY '${DB_ROOT_PASSWORD}';
    FLUSH PRIVILEGES;
SQL

  # Maintenant que la DB est configurée, on arrête le MariaDB temporaire.
  # kill "$pid" = Envoie un signal d’arrêt au process.
  # wait "$pid" = Attend qu’il se termine proprement.
  # || true = Empêche un crash si le process est déjà terminé
  echo "Stopping temporary MariaDB..."
  kill "$pid" || true
  wait "$pid" || true

  # marker file
  # Crée un fichier vide qui sert de drapeau (on s'en sert a la maniere d'un booleen)
  # histoire de savoir si la base a déjà été initialisée
  touch /var/lib/mysql/.inception_db_initialized
fi

# Démarrage final

# exec remplace le shell courant par mysqld.
# Donc :
# PID 1 du container = mysqld
# C’est très important pour Docker, car le process principal doit être proprement géré.
# Sans exec, on aurait :
# PID 1 = bash
# PID 2 = mysqld
# et Docker gérerait moins bien :
# les signaux
# l’arrêt du container
# certains comportements système
echo "Starting MariaDB..."
exec mysqld --user=mysql --datadir=/var/lib/mysql

