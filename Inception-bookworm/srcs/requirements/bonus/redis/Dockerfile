FROM debian:bookworm

RUN apt-get update && apt-get install -y \
    redis-server \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

COPY tools/entrypoint.sh /usr/local/bin/entrypoint.sh

RUN chmod +x /usr/local/bin/entrypoint.sh

CMD ["/usr/local/bin/entrypoint.sh"]