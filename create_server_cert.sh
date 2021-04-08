#!/bin/bash

source .env

echo "Enter subdomain without $DOMAIN ending"
read SUBDOMAIN
echo "Enter private key password. Can be empty to generate unencrypted key only"
read -s KEY_PASS

if [[ "$KEY_PASS" != "" ]]
then
  echo "Repeat key password"
  read -s KEY_PASS_1
fi

if [[ "$KEY_PASS" == "" ]]
then
  KEY_PASS="123456"
else
  if [[ "$KEY_PASS" != "$KEY_PASS_1" ]]
  then
    # echo "Passwords do not match $KEY_PASS - $KEY_PASS_1"
    exit 1
  fi
fi
#echo Password is ${KEY_PASS}

cp intermediate/openssl_server.cnf intermediate/openssl_server.${SUBDOMAIN}.cnf
sed -i "s/#SAN_DOMAIN#/${SUBDOMAIN}.${DOMAIN}/" intermediate/openssl_server.${SUBDOMAIN}.cnf

# Create the private key
openssl genrsa -aes256 -out intermediate/private/${SUBDOMAIN}.${DOMAIN}.key.pem -passout pass:${KEY_PASS} 2048
chmod 600 intermediate/private/${SUBDOMAIN}.${DOMAIN}.key.pem

# Create the CSR
openssl req -config intermediate/openssl_server.${SUBDOMAIN}.cnf -new -key intermediate/private/${SUBDOMAIN}.${DOMAIN}.key.pem -out intermediate/csr/${SUBDOMAIN}.${DOMAIN}.csr -passin pass:${KEY_PASS}

# Decrypt key
openssl rsa -in intermediate/private/${SUBDOMAIN}.${DOMAIN}.key.pem -out intermediate/private/${SUBDOMAIN}.${DOMAIN}.key -passin pass:${KEY_PASS}
chmod 600 intermediate/private/${SUBDOMAIN}.${DOMAIN}.key

# Create the Certificate
openssl ca -config intermediate/openssl_server.${SUBDOMAIN}.cnf -extensions server_cert -days 360 -in intermediate/csr/${SUBDOMAIN}.${DOMAIN}.csr -out intermediate/certs/${SUBDOMAIN}.${DOMAIN}.crt.pem -passin pass:${INT_CA_KEY_PASS} -batch

# Validate the certificate
openssl x509 -noout -text -in intermediate/certs/${SUBDOMAIN}.${DOMAIN}.crt.pem

# Create certificate chain
cat intermediate/certs/${SUBDOMAIN}.${DOMAIN}.crt.pem intermediate/certs/${INT_CA_FILE_PREFIX}.crt.pem > intermediate/certs/${SUBDOMAIN}.${DOMAIN}.fullchain.pem

if [[ "$KEY_PASS" == "123456" ]]
then
  rm intermediate/private/${SUBDOMAIN}.${DOMAIN}.key.pem
fi

rm intermediate/openssl_server.${SUBDOMAIN}.cnf
