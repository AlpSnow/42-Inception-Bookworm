FROM debian:bookworm

RUN apt-get update && apt-get install -y \
    curl \
    ca-certificates \
    bash \
    && rm -rf /var/lib/apt/lists/*

RUN curl -L -Ss https://my-netdata.io/kickstart.sh -o /tmp/netdata.sh \
    && bash /tmp/netdata.sh --dont-wait

EXPOSE 19999

CMD ["netdata", "-D"]