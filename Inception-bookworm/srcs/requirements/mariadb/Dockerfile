# Base de l’image.
# On construit notre container à partir d’un système Debian minimal.
FROM debian:bookworm

# Pendant la construction de l’image :
# Docker lance un container temporaire et exécute cette commande.
# Ça installe :
# mariadb-server


# apt-get clean
# Supprime le cache apt pour alléger l’image.

# rm -rf /var/lib/apt/lists/*
# Nettoie les fichiers apt restants.
# C’est une bonne pratique Docker.

RUN apt-get update && apt-get install -y \
    mariadb-server \
    mariadb-client \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*


# MariaDB a besoin du dossier /run/mysqld pour créer son socket
RUN mkdir -p /run/mysqld && chown -R mysql:mysql /run/mysqld



# Copie un fichier depuis ton projet vers l'image Docker.
# source : srcs/requirements/mariadb/tools/entrypoint.sh
# destination : /usr/local/bin/entrypoint.sh
# Cela signifie que le script sera présent dans le filesystem du container.
COPY conf/my.cnf /etc/mysql/mariadb.conf.d/50-server.cnf
COPY tools/entrypoint.sh /usr/local/bin/entrypoint.sh

# Rend le script exécutable.
# chmod + x = autoriser l'exécution du fichier
# sans cela : permission denied
RUN chmod +x /usr/local/bin/entrypoint.sh

# Définit le programme lancé
# au démarrage du container.
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]




# Déclare que MariaDB écoute sur le port :
# 3306
# Ça n’ouvre pas le port vers l’extérieur.
# Ça documente juste le port interne.
EXPOSE 3306

# C’est le processus principal du container.
# Quand le container démarre :
# mysqld
# sera lancé.

# Ceci est devenu inutile car deja dans le script d'entrypoint
# CMD ["mysqld"]
