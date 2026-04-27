#!/bin/bash -e

CERT_DIR="/etc/lighttpd/ssl"
DOMAIN="garden.connect"

# Skip if certificates already exist
if [ -f "$CERT_DIR/$DOMAIN.pem" ]; then
    echo "SSL certificates already exist, skipping generation"
    exit 0
fi

mkdir -p "$CERT_DIR"

# Check if openssl is available
if ! command -v openssl &> /dev/null; then
    echo "ERROR: openssl not found!"
    exit 1
fi

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
