# Base de image comme pour mariadb,
# Docker télécharge l'image Debian bookworm depuis le registre Docker si elle n'existe pas déjà localement
FROM debian:bookworm

# Installation des packages nécessaires
# php-fpm	  -> exécuter PHP
# PHP-FPM signifie : PHP FastCGI Process Manager
# C’est un service qui attend les requêtes venant du serveur web.
# php-cli -> l’interpréteur PHP en ligne de commande.
# php-mysql -> connecter WordPress à MariaDB
# php-redis    -> permettre à PHP / WordPress de communiquer avec Redis
# curl      -> télécharger WordPress
# mariadb-client -> tester la DB (chaque container est isoler donc meme si deja dl dans maria db, il faut le refaire)

RUN apt-get update && apt-get install -y \
    php-fpm \
    php-cli \
    php-mysql \
    php-redis \
    curl \
    mariadb-client \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Créer le dossier WordPress
# C'est là que WordPress sera installé.
# Et ce dossier sera le volume partagé avec nginx.
RUN mkdir -p /var/www/html
RUN mkdir -p /run/php

# Copier la config PHP-FPM
# Ce fichier servira à corriger un gros problème du projet :
# php-fpm écoute normalement sur :
# - unix socket
# mais nginx va utiliser :
# - TCP port 9000
# Donc on doit modifier ça.
COPY conf/www.conf /etc/php/8.2/fpm/pool.d/www.conf

# Copier le script d'entrypoint
COPY tools/entrypoint.sh /usr/local/bin/entrypoint.sh

# Rendre le script exécutable
RUN chmod +x /usr/local/bin/entrypoint.sh


# Définir le dossier de travail par défaut dans le container.
# Autrement dit :
# Toutes les commandes suivantes seront exécutées
# depuis ce dossier.
# C’est l’équivalent de faire dans un terminal :
# cd /var/www/html
# sauf qu'on reste sur ce dossier.
# Dans le docker-compose.yml :
# volumes:
#   - wordpress_data:/var/www/html
# et ce volume pointe vers :
# /home/mwallis/data/wordpress
WORKDIR /var/www/html

# Port utilisé par php-fpm
EXPOSE 9000

# Script lancé au démarrage
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]