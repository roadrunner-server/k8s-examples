# syntax=docker/dockerfile:1.7

FROM composer:2 AS vendor
WORKDIR /app
COPY composer.json composer.lock ./
RUN composer install --no-dev --prefer-dist --classmap-authoritative --no-interaction --no-progress --ignore-platform-req=ext-sockets

FROM ghcr.io/roadrunner-server/roadrunner:2025.1 AS rr

FROM php:8.5-cli-alpine
WORKDIR /app

RUN apk add --no-cache ca-certificates \
    && apk add --no-cache --virtual .build-deps $PHPIZE_DEPS linux-headers \
    && docker-php-ext-install sockets \
    && apk del .build-deps \
    && addgroup -S rr -g 10001 \
    && adduser -S rr -G rr -u 10001

COPY --from=rr /usr/bin/rr /usr/local/bin/rr
COPY --from=vendor /app/vendor /app/vendor
COPY worker.php /app/worker.php
COPY .rr.yaml /etc/rr/.rr.yaml

RUN chown -R rr:rr /app /etc/rr

USER rr

EXPOSE 8080 2112 2114

CMD ["rr", "serve", "-c", "/etc/rr/.rr.yaml", "-w", "/app"]
