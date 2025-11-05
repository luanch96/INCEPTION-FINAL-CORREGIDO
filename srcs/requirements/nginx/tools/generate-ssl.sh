#!/bin/bash

DOMAIN="${DOMAIN_NAME:-luisanch.42.fr}"
SSL_DIR="/home/luisanch/data/ssl"

mkdir -p $SSL_DIR

openssl genrsa -out $SSL_DIR/nginx.key 2048

openssl req -new -x509 -key $SSL_DIR/nginx.key -out $SSL_DIR/nginx.crt -days 365 -subj "/C=ES/ST=Madrid/L=Madrid/O=42/OU=IT/CN=$DOMAIN"

chmod 600 $SSL_DIR/nginx.key
chmod 644 $SSL_DIR/nginx.crt

echo "Certificados SSL generados en $SSL_DIR"
echo "Dominio: $DOMAIN"
echo "Certificado: $SSL_DIR/nginx.crt"
echo "Clave privada: $SSL_DIR/nginx.key"