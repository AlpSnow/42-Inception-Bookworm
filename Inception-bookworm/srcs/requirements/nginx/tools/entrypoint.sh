#!/bin/bash
set -e

# Créer le certificat TLS auto-signé
openssl req -x509 -nodes -days 365 \
    -newkey rsa:2048 \
    -keyout /etc/nginx/ssl/nginx.key \
    -out /etc/nginx/ssl/nginx.crt \
    -subj "/C=FR/ST=France/L=Paris/O=42/OU=Inception/CN=$DOMAIN_NAME"

# Lancer nginx au premier plan
exec nginx -g "daemon off;"







# crée un certificat :
# openssl req

# certificat auto-signé :
# -x509

# pas de mot de passe :
# -nodes


# valide pendant 1 an :
# -days 365

# clé RSA 2048 bits :
# -newkey rsa:2048

# fichiers générés :
# /etc/nginx/ssl/nginx.key = clé privée
# /etc/nginx/ssl/nginx.crt = certificat public

# sujet du certificat
# -subj "/C=FR/.../CN=$DOMAIN_NAME"
# CN = nom du domaine
# Dans .env : DOMAIN_NAME=mwallis.42.fr


# lancement nginx :
# nginx -g "daemon off;"

# Important :
# daemon off sinon nginx passerait en background et le container s'arrêterait immédiatement.