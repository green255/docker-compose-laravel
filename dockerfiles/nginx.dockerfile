FROM nginx:stable-alpine AS base

ARG UID
ARG GID

ENV UID=${UID}
ENV GID=${GID}

# MacOS staff group's gid is 20, so is the dialout group in alpine linux. We're not using it, let's just remove it.
RUN delgroup dialout

RUN addgroup -g ${GID} --system laravel
RUN adduser -G laravel --system -D -s /bin/sh -u ${UID} laravel
RUN sed -i "s/user  nginx/user laravel/g" /etc/nginx/nginx.conf

RUN mkdir -p /var/www/src

ADD ./nginx/acme_challenge.conf /etc/nginx/snippets/acme_challenge.conf

FROM base as dev

ADD ./nginx/port_80_listen.conf /etc/nginx/conf.d/default.conf


FROM base as prod

ADD ./nginx/port_80_redirect.conf /etc/nginx/conf.d/default.conf
