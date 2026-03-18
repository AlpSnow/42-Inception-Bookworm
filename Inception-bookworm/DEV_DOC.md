# Developer Documentation

This document describes how the infrastructure is implemented and how a developer can work with the project.

---------------------------------------------------

# Project Setup

To run the project from scratch, the following tools must be installed:

Docker  
Docker Compose  
Make  

The project must be executed inside a virtual machine as required by the subject.

Clone the repository and navigate to the project directory:

git clone <repository_url>
cd Inception

---------------------------------------------------

# Build and Launch

The entire infrastructure can be built and launched using:

make

or

make up

Docker Compose will:

- build the images from the Dockerfiles
- create the network
- create volumes
- start all containers

---------------------------------------------------

# Containers

Each service runs inside its own Docker container.

Mandatory services:

nginx  
wordpress  
mariadb  

Bonus services:

redis  
ftp  
adminer  
static_website  
netdata  

Each container is built using its own Dockerfile.

---------------------------------------------------

# Docker Compose

The infrastructure is orchestrated using docker-compose.yml.

Docker Compose defines:

- services
- volumes
- networks
- dependencies between containers

Each service communicates through the Docker network using its service name.

---------------------------------------------------

# Networking

All containers communicate through a custom Docker network called:

inception

Docker provides an internal DNS system that allows containers to communicate using service names.

Example:

wordpress -> mariadb  
wordpress -> redis  
nginx -> wordpress  

---------------------------------------------------

# Volumes and Data Storage

Persistent storage is implemented using bind mounts.

MariaDB database files:

/home/mwallis/data/mariadb

WordPress website files:

/home/mwallis/data/wordpress

These directories store persistent data even if containers are removed or rebuilt.

---------------------------------------------------

# Container Management

Useful Docker commands for development and debugging:

List running containers:

docker ps

Stop all services:

make down

Restart the infrastructure:

make re

View logs:

docker compose logs

View logs for a specific service:

docker compose logs nginx
docker compose logs wordpress
docker compose logs mariadb

---------------------------------------------------

# TLS Configuration

Nginx handles HTTPS connections using a self-signed certificate generated with OpenSSL.

Example configuration in nginx.conf:

ssl_protocols TLSv1.2 TLSv1.3;

Only HTTPS (port 443) is exposed as required by the project subject.

---------------------------------------------------

# WordPress

WordPress runs using PHP-FPM.

Nginx communicates with the WordPress container using FastCGI.

Example configuration:

fastcgi_pass wordpress:9000;

---------------------------------------------------

# Redis Cache

Redis is used as an object cache for WordPress to improve performance.

WordPress connects to Redis using the container hostname:

WP_REDIS_HOST=redis

---------------------------------------------------

# Monitoring

Netdata provides a monitoring dashboard available at:

http://localhost:19999

It displays:

- CPU usage
- memory usage
- network traffic
- container metrics