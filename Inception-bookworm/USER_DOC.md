# User Documentation

This document explains how an end user or administrator can run and interact with the infrastructure.

---------------------------------------------------

# Services Overview

The infrastructure provides the following services:

Nginx  
Handles HTTPS connections and serves the WordPress website.

WordPress  
PHP application used to manage the website content.

MariaDB  
Database used by WordPress to store all website data.

Redis  
Caching system used to improve WordPress performance.

FTP  
Allows file transfer access to WordPress files.

Adminer  
Web interface to manage the MariaDB database.

Static Website  
Independent container serving a static website.

Netdata  
Monitoring dashboard showing real-time metrics.

---------------------------------------------------

# Start the project

Launch the entire infrastructure:

make

or

make up

Docker will build the images if necessary and start all containers.

---------------------------------------------------

# Stop the project

make down

This will stop and remove all containers.

---------------------------------------------------

# Restart the infrastructure

make re

This command will:

- stop containers
- remove containers
- rebuild images
- restart the full infrastructure

---------------------------------------------------

# Access services

Main WordPress website

https://mwallis.42.fr

WordPress administration panel

https://mwallis.42.fr/wp-login.php

Adminer database interface

http://localhost:8080

Static website

http://localhost:8081

Netdata monitoring dashboard

http://localhost:19999

---------------------------------------------------

# FTP access

Connect using an FTP client:

ftp localhost

Login using the credentials defined in the environment configuration.

Files uploaded through FTP are stored inside the WordPress volume.

---------------------------------------------------

# Credentials location

Sensitive credentials such as database passwords and FTP credentials are stored outside of the repository.

They are defined using:

- environment variables in `.env`
- Docker secrets stored in the `secrets/` directory

These files are ignored by Git for security reasons.

---------------------------------------------------

# Check that services are running

To verify that the infrastructure is running correctly, use:

docker ps

This command should display all running containers.

You can also inspect logs using:

docker compose logs

or

docker compose logs <service_name>

Example:

docker compose logs nginx
docker compose logs wordpress
docker compose logs mariadb

---------------------------------------------------

# Data persistence

Data is stored on the host machine:

/home/mwallis/data/mariadb  
/home/mwallis/data/wordpress  

This ensures that database data and WordPress files remain available even if containers are recreated.