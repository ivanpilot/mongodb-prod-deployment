#! /bin/bash

filenameLength="${#0}"
filename="${0:2:(( $filenameLength - 2 - 3 ))}"

echo "Generating a secret to be used with our mongodb replica set within kubectl"

openssl rand -base64 756 > ./secret.txt

kubectl create secret generic ${filename} --from-file=internal-auth-mongodb-keyfile=./secret.txt

rm -rf ./secret.txt

echo "The kubectl secret has been generated and is called ${filename}."