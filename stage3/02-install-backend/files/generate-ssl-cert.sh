#!/bin/bash

CERT_DIR="/etc/lighttpd/ssl"
DOMAIN="garden.connect"

mkdir -p "$CERT_DIR"

openssl req -x509 -nodes -days 3650 -newkey rsa:2048 \
    -keyout "$CERT_DIR/$DOMAIN.key" \
    -out "$CERT_DIR/$DOMAIN.crt" \
    -subj "/C=US/ST=State/L=City/O=Garden/CN=$DOMAIN" \
    -addext "subjectAltName=DNS:$DOMAIN,DNS:*.$DOMAIN"

cat "$CERT_DIR/$DOMAIN.crt" "$CERT_DIR/$DOMAIN.key" > "$CERT_DIR/$DOMAIN.pem"

chmod 600 "$CERT_DIR/$DOMAIN.key"
chmod 644 "$CERT_DIR/$DOMAIN.crt"
chmod 600 "$CERT_DIR/$DOMAIN.pem"

echo "SSL certificate generated for $DOMAIN at $CERT_DIR"
