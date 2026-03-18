#!/bin/bash
set -e


# Le shebang -> #!/bin/bash
# Ça veut dire :
# exécuter ce script avec bash
# Sans ça, Linux ne saurait pas quel interpréteur utiliser.

# set -e -> si une commande échoue, le script s'arrête immédiatement
# C’est très important pour éviter :
# - une installation WordPress partielle
# - un fichier de configuration incomplet
# - un container qui continue malgré une erreur




# Ici, le script lit les fichiers xxx
# puis met leur contenu dans des variables bash : DB_PASSWORD, WP_ADMIN_PASSWORD et WP_USER_PASSWORD
# tr -d '\n' enlève le retour à la ligne.
# 2>/dev/null masque les erreurs
# || true évite que set -e stoppe le script si le fichier n’existe pas
# Donc le script ne plante pas immédiatement ici.
# Il fera les vérifications juste après.
DB_PASSWORD="$(tr -d '\n' < /run/secrets/db_password.txt 2>/dev/null || true)"
WP_ADMIN_PASSWORD="$(tr -d '\n' < /run/secrets/wp_admin_password.txt 2>/dev/null || true)"
WP_USER_PASSWORD="$(tr -d '\n' < /run/secrets/wp_user_password.txt 2>/dev/null || true)"



# Vérifie que les variables d'environnement nécessaires sont bien définies
# dans le container. Si l'une d'elles est vide, le script s'arrête.
# -z signifie : chaîne vide.
if [ -z "$DB_NAME" ] || [ -z "$DB_USER" ] || [ -z "$DOMAIN_NAME" ] || [ -z "$WP_TITLE" ] || [ -z "$WP_ADMIN_USER" ] || [ -z "$WP_ADMIN_EMAIL" ] || [ -z "$WP_USER" ] || [ -z "$WP_USER_EMAIL" ]; then
    echo "ERROR: variables manquantes dans .env"
    exit 1
fi

# Vérifie que les secrets ont bien été lus.
# Si un mot de passe est vide, on arrête le script.
if [ -z "$DB_PASSWORD" ] || [ -z "$WP_ADMIN_PASSWORD" ] || [ -z "$WP_USER_PASSWORD" ]; then
    echo "ERROR: secrets manquants"
    exit 1
fi


# Crée le dossier du site WordPress s'il n'existe pas encore.
# -p évite une erreur si le dossier existe déjà.
mkdir -p /var/www/html



# Attend que MariaDB soit réellement prête à accepter des connexions.
# La commande tente une connexion au serveur MariaDB et exécute "SELECT 1;".
# Tant que cette commande échoue, on attend 2 secondes puis on réessaie.
# Cela compense le fait que depends_on ne garantit pas qu'un service est déjà prêt.
echo "Waiting for MariaDB..."
until mariadb -h mariadb -u"$DB_USER" -p"$DB_PASSWORD" -e "SELECT 1;" >/dev/null 2>&1; do
    sleep 2
done
echo "MariaDB is ready."




echo "Waiting for Redis..."
until php -r "exit((new Redis())->connect('redis', 6379) ? 0 : 1);" 2>/dev/null; do
    sleep 2
done
echo "Redis is ready."


# Installe wp-cli seulement s'il n'est pas déjà présent.
# wp-cli est l'outil en ligne de commande utilisé pour télécharger,
# configurer et installer WordPress automatiquement.
# [ ! -f ... ] : vrai si le fichier n'existe pas.
# curl télécharge le binaire wp-cli.
# chmod +x rend ce binaire exécutable.
if [ ! -f /usr/local/bin/wp ]; then
    echo "Installing wp-cli..."
    curl -o /usr/local/bin/wp https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
    chmod +x /usr/local/bin/wp
fi

# Si wp-config.php n'existe pas encore, cela signifie que WordPress
# n'a pas encore été configuré. On effectue donc l'installation initiale.
# Sinon, on ne touche à rien pour préserver les données persistantes.
if [ ! -f /var/www/html/wp-config.php ]; then
    echo "Downloading WordPress..."
    # Télécharge les fichiers du coeur de WordPress dans /var/www/html.
    # --allow-root est nécessaire car le script est exécuté en root dans le container.
    wp core download --allow-root

    echo "Creating wp-config.php..."
    # Génère le fichier wp-config.php avec les paramètres de connexion à la base de données.
    # "mariadb" est le nom du service sur le réseau Docker, donc WordPress
    # peut joindre MariaDB via mariadb:3306.
    wp config create \
        --dbname="$DB_NAME" \
        --dbuser="$DB_USER" \
        --dbpass="$DB_PASSWORD" \
        --dbhost="mariadb:3306" \
        --allow-root


    echo "Configuring Redis..."
    wp config set WP_REDIS_HOST "'redis'" --raw --type=constant --allow-root
    wp config set WP_REDIS_PORT 6379 --raw --type=constant --allow-root
    wp config set WP_CACHE true --raw --type=constant --allow-root

    echo "Installing WordPress..."
    # Finalise l'installation de WordPress :
    # - définit l'URL du site
    # - définit le titre
    # - crée le compte administrateur
    # --skip-email évite l'envoi d'un mail lors de l'installation.
    wp core install \
        --url="https://$DOMAIN_NAME" \
        --title="$WP_TITLE" \
        --admin_user="$WP_ADMIN_USER" \
        --admin_password="$WP_ADMIN_PASSWORD" \
        --admin_email="$WP_ADMIN_EMAIL" \
        --skip-email \
        --allow-root

    echo "Creating WordPress user..."
    # Crée un second utilisateur WordPress non-admin.
    # Cet utilisateur appartient à l'application WordPress, pas à MariaDB.
    # Ici, on lui donne le rôle "author".
    wp user create \
        "$WP_USER" \
        "$WP_USER_EMAIL" \
        --user_pass="$WP_USER_PASSWORD" \
        --role=author \
        --allow-root


    echo "Installing Redis cache plugin..."
    wp plugin install redis-cache --activate --allow-root

    echo "Enabling Redis cache..."
    wp redis enable --allow-root || true

    # Donne la propriété des fichiers WordPress à www-data,
    # l'utilisateur utilisé par le serveur web / PHP-FPM.
    # Cela évite les problèmes de permissions sur les fichiers du site.
    chown -R www-data:www-data /var/www/html
fi


# Lance PHP-FPM au premier plan.
# -F signifie "foreground" : le processus ne part pas en arrière-plan.
# exec remplace le shell par php-fpm, ce qui permet à php-fpm
# de devenir le processus principal du container (PID 1).
# C'est une bonne pratique Docker.
echo "Starting PHP-FPM..."

exec php-fpm8.2 -F






################################################################################
#                               COMMANDES UTILISÉES
################################################################################

# curl
# ----
# curl signifie "Client URL".
# C'est un outil qui permet de télécharger ou envoyer des données via une URL
# (HTTP, HTTPS, FTP, etc.).
#
# Dans ce script :
#
# curl -o /usr/local/bin/wp https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
#
# Cette commande télécharge le binaire wp-cli depuis Internet
# et l'enregistre dans le fichier /usr/local/bin/wp.
#
# -o : permet de définir le nom du fichier de sortie.
#
# Le dossier /usr/local/bin fait partie du PATH Linux, ce qui permet ensuite
# d'exécuter la commande simplement avec :
#
# wp
#
# au lieu de devoir taper :
#
# /usr/local/bin/wp


# wp
# --
# "wp" est la commande de WP-CLI (WordPress Command Line Interface).
#
# WP-CLI permet de contrôler WordPress directement depuis le terminal
# sans passer par l'interface web du navigateur.
#
# Dans ce script, WP-CLI est utilisé pour :
#
# - télécharger WordPress
# - générer le fichier de configuration
# - installer le site
# - créer des utilisateurs
#
# Exemples utilisés dans ce script :
#
# wp core download
# → télécharge les fichiers du cœur de WordPress
#
# wp config create
# → génère le fichier wp-config.php contenant les paramètres de la base de données
#
# wp core install
# → installe WordPress et crée le compte administrateur
#
# wp user create
# → crée un utilisateur WordPress supplémentaire
#
# L'option :
#
# --allow-root
#
# est nécessaire car le script s'exécute en root dans le container Docker.
# WP-CLI refuse normalement l'exécution en root pour des raisons de sécurité.


# chown
# -----
# chown signifie "change owner".
# Cette commande permet de modifier le propriétaire d'un fichier ou d'un dossier.
#
# Dans ce script :
#
# chown -R www-data:www-data /var/www/html
#
# -R : applique le changement récursivement à tous les fichiers et sous-dossiers
#
# www-data : utilisateur Linux utilisé par le serveur web / PHP-FPM
#
# Cette commande donne la propriété des fichiers WordPress à l'utilisateur
# www-data afin que le serveur web puisse lire et modifier les fichiers du site
# sans rencontrer d'erreurs de permission.
################################################################################