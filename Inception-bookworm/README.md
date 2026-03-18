*This project has been created as part of the 42 curriculum by mwallis.*

# Inception


# Description

Inception is a system administration project focused on containerization using Docker.

The objective is to build a small infrastructure composed of multiple services running in isolated containers and orchestrated with Docker Compose.

The infrastructure hosts a WordPress website served through Nginx using HTTPS (TLS). Each service runs in its own container and communicates through a dedicated Docker network.

Persistent storage is implemented using Docker volumes so that data is preserved even if containers are recreated.

Several additional services are included as part of the bonus section.


# Architecture

- Mandatory services

Nginx  
Acts as the entry point of the infrastructure.  
Handles HTTPS connections and serves the WordPress website using TLS encryption.

WordPress  
Runs as a PHP-FPM application container.  
Processes PHP requests and communicates with the MariaDB database.

MariaDB  
Database server used by WordPress.  
Stores website data using persistent storage.


- Bonus services

Redis  
Provides caching for WordPress to improve performance.

FTP (vsftpd)  
Allows file transfer access to the WordPress files.

Adminer  
Web interface used to manage the MariaDB database.

Static Website  
Independent Nginx container serving a simple static website.

Netdata  
Monitoring tool providing real-time system and container metrics.


# Project Structure

Inception/
├── Makefile
├── README.md
├── USER_DOC.md
├── DEV_DOC.md
└── srcs/
    ├── docker-compose.yml
    ├── .env
    └── requirements/
        ├── mariadb/
        ├── nginx/
        ├── wordpress/
        └── bonus/
            ├── adminer/
            ├── redis/
            ├── ftp/
            ├── static_website/
            └── netdata/


# Volumes

Persistent data is stored on the host machine in the following directories:

/home/mwallis/data/mariadb  
/home/mwallis/data/wordpress

This ensures that database data and WordPress files remain available even if containers are removed or recreated.


# Network

All containers are connected through a dedicated Docker network called "inception".

Containers communicate with each other using their service names as hostnames.

Example:

wordpress -> mariadb  
wordpress -> redis  
nginx -> wordpress


# Instructions

Start the infrastructure

make  
or  
make up

Stop the infrastructure

make down

Restart everything

make re


# Resources

Documentation used during this project:

Docker documentation  
Docker Compose documentation  
Nginx documentation  
WordPress documentation  
MariaDB documentation  
Redis documentation

AI tools were used to explore configuration ideas, assist with troubleshooting, and deepen understanding of containerized infrastructure.
All generated information was manually verified and tested before integration.
Each part of the project was checked step by step, including the virtual machine, the Git repository, the .gitignore behavior, the Docker Compose setup, each container individually, the Makefile, and finally the complete infrastructure.


# Design Choices

Virtual Machines vs Docker

Virtual machines emulate an entire operating system and require more resources.
Docker containers share the host kernel and isolate applications more efficiently.

Secrets vs Environment Variables

Environment variables are useful for configuration but are not ideal for sensitive information.
Docker secrets allow secure handling of confidential data by injecting them at runtime.

Docker Network vs Host Network

Docker networks isolate containers and allow them to communicate securely using service names.
Host networking removes this isolation and exposes containers directly to the host network.

Docker Volumes vs Bind Mounts

Docker volumes are managed by Docker and provide persistent storage for container data.
Bind mounts map a host directory directly to the container filesystem.