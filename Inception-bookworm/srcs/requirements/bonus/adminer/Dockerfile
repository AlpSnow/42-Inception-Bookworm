FROM debian:bookworm

RUN apt-get update && apt-get install -y \
    php \
    php-mysqli \
    php-cli \
    curl \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /var/www/html

RUN curl -L https://github.com/vrana/adminer/releases/download/v4.8.1/adminer-4.8.1.php \
    -o /var/www/html/index.php

WORKDIR /var/www/html

CMD ["php", "-S", "0.0.0.0:8080", "-t", "/var/www/html"]