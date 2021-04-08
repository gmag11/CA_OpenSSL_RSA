#!/bin/bash
source .env

mkdir private certs crl
touch index.txt
touch index.txt.attr
echo 1000 > serial

# copy openssl_root.cnf

# Create the Root CA's Private Key
openssl genrsa -aes256 -passout pass:${CA_KEY_PASS} -out private/${CA_FILE_PREFIX}.key.pem 4096
chmod 400 private/${CA_FILE_PREFIX}.key.pem

# Create the Root CA's Certificate
openssl req -config openssl_root.cnf -new -x509 -sha256 -extensions v3_ca -key private/${CA_FILE_PREFIX}.key.pem -days 3650 -out certs/${CA_FILE_PREFIX}.crt.pem -passin pass:${CA_KEY_PASS}

# Check CA certificate
openssl x509 -noout -text -in certs/${CA_FILE_PREFIX}.crt.pem
