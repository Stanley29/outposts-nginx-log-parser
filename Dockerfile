FROM debian:stable-slim

RUN apt-get update && apt-get install -y \
    bash \
    git \
    coreutils \
    grep \
    sed \
    gawk \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY parser.sh .

RUN chmod +x parser.sh

ENTRYPOINT ["./parser.sh"]

