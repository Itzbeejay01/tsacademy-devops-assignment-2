FROM alpine:3.20

RUN apk add --no-cache \
    bash \
    bind-tools \
    coreutils \
    iputils \
    procps

WORKDIR /app

COPY app/ /app/

RUN chmod +x /app/diagnostic.sh /app/health-check.sh

ENTRYPOINT ["/app/diagnostic.sh"]
CMD ["help"]
