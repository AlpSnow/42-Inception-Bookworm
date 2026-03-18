FROM debian:bookworm

RUN apt-get update && apt-get install -y \
    nginx \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

COPY website /var/www/html

# donne :
# aux dossiers : droit de traversée pour tout le monde
# aux fichiers : lecture/exécution selon le mode appliqué
# Sans quoi NGINX refuse de lire les fichiers avec des droits root

# Donne des permissions suffisantes pour que NGINX puisse lire
# les fichiers et traverser les dossiers.
# Sans le bit "x" sur les répertoires, le serveur web ne peut pas
# accéder aux sous-dossiers comme /Slider ou /JavaScript-Game.
RUN chmod -R 755 /var/www/html

CMD ["nginx", "-g", "daemon off;"]