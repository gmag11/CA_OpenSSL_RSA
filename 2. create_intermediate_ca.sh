#!/bin/bash

source .env

# Create directory structure
# mkdir intermediate

# Create your intermediary CA database to keep track of signed certificates
mkdir intermediate/certs intermediate/crl intermediate/csr intermediate/private
touch intermediate/index.txt
touch intermediate/index.txt.attr
echo 1000 > intermediate/serial

# Create a crlnumber file for the intermediary CA to use
echo 1000 > intermediate/crlnumber

# copy openssl_intermediate.cnf
# Create the intermediate key
openssl genrsa -aes256 -passout pass:${INT_CA_KEY_PASS} -out intermediate/private/${INT_CA_FILE_PREFIX}.key.pem 4096
chmod 400 intermediate/private/${INT_CA_FILE_PREFIX}.key.pem

# Create the certificate Signing Request
openssl req -config intermediate/openssl_intermediate.cnf -new -newkey -sha256 -key intermediate/private/${INT_CA_FILE_PREFIX}.key.pem -out intermediate/csr/${INT_CA_FILE_PREFIX}.csr -passin pass:${INT_CA_KEY_PASS}

# Create the intermediate certificate
openssl ca -config openssl_root.cnf -extensions v3_intermediate_ca -days 3650 -notext -md sha256 -in intermediate/csr/${INT_CA_FILE_PREFIX}.csr -out intermediate/certs/${INT_CA_FILE_PREFIX}.crt.pem -passin pass:${CA_KEY_PASS} -batch

#Validate the Certificate Contents with OpenSSL
openssl x509 -noout -text -in intermediate/certs/${INT_CA_FILE_PREFIX}.crt.pem
