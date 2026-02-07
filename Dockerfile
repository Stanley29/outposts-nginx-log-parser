FROM alpine:3.20

RUN apk add --no-cache bash git coreutils grep sed awk

WORKDIR /app

COPY parser.sh .

RUN chmod +x parser.sh

ENTRYPOINT ["./parser.sh"]
