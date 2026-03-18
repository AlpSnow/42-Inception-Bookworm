# Base de image comme pour mariadb,
# Docker télécharge l'image Debian bookworm depuis le registre Docker si elle n'existe pas déjà localement
FROM debian:bookworm

# Installation des paquets nécessaires
# nginx   -> serveur web
# openssl -> génération du certificat TLS
RUN apt-get update && apt-get install -y \
    nginx \
    openssl \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Créer le dossier pour les certificats TLS
# Le dossier WordPress est deja installé et le volume est partagé avec nginx.
RUN mkdir -p /etc/nginx/ssl

# Copier la configuration nginx
COPY conf/nginx.conf /etc/nginx/nginx.conf

# Copier le script d'entrypoint
COPY tools/entrypoint.sh /usr/local/bin/entrypoint.sh

# Rendre le script exécutable
RUN chmod +x /usr/local/bin/entrypoint.sh

# Port HTTPS
EXPOSE 443

# Définit le programme lancé au démarrage du container.
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]