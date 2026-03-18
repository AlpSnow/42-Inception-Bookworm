#!/bin/bash
set -e

echo "Starting FTP server..."

# Lecture du mot de passe FTP depuis Docker secrets
FTP_PASSWORD="$(tr -d '\n' < /run/secrets/ftp_password.txt 2>/dev/null || true)"

# Vérifie que les variables nécessaires existent
if [ -z "$FTP_USER" ] || [ -z "$FTP_PASSWORD" ]; then
    echo "ERROR: FTP_USER or FTP_PASSWORD is missing"
    exit 1
fi

# Crée l'utilisateur FTP s'il n'existe pas encore
if ! id "$FTP_USER" >/dev/null 2>&1; then
    useradd -m "$FTP_USER"
    echo "$FTP_USER:$FTP_PASSWORD" | chpasswd
fi

# Dossier FTP
mkdir -p /var/www/html/ftp_upload
chown -R "$FTP_USER:$FTP_USER" /var/www/html/ftp_upload

# Dossier obligatoire pour vsftpd
mkdir -p /var/run/vsftpd/empty

# Configuration vsftpd
cat << EOF > /etc/vsftpd.conf
listen=YES
anonymous_enable=NO
local_enable=YES
write_enable=YES
local_umask=022
dirmessage_enable=YES
use_localtime=YES
xferlog_enable=YES
connect_from_port_20=YES
chroot_local_user=YES
allow_writeable_chroot=YES
secure_chroot_dir=/var/run/vsftpd/empty
pasv_enable=YES
pasv_min_port=21000
pasv_max_port=21010
local_root=/var/www/html/ftp_upload
EOF

exec vsftpd /etc/vsftpd.conf