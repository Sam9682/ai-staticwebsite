#!/bin/bash

# Generate SSL certificates for AI-StaticWebsite

echo "🔐 Generating SSL certificates..."

mkdir -p ssl

# Generate private key
openssl genrsa -out ssl/key.pem 2048

# Generate certificate
openssl req -new -x509 -key ssl/key.pem -out ssl/cert.pem -days 365 -subj "/C=US/ST=State/L=City/O=Organization/CN=localhost"

chmod 600 ssl/key.pem
chmod 644 ssl/cert.pem

echo "✅ SSL certificates generated successfully!"
echo "   Private key: ssl/key.pem"
echo "   Certificate: ssl/cert.pem"