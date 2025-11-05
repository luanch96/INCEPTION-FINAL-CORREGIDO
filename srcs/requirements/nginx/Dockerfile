FROM debian:bookworm

RUN apt-get update && apt-get install -y \
    nginx \
    openssl \
    gettext-base \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /etc/nginx/ssl

COPY conf/nginx.conf /etc/nginx/nginx.conf.template

RUN mkdir -p /var/log/nginx

EXPOSE 443

CMD ["/bin/bash", "-c", "envsubst '$$DOMAIN_NAME' < /etc/nginx/nginx.conf.template > /etc/nginx/nginx.conf && nginx -g 'daemon off;'"]