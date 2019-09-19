#! /bin/bash

filenameLength="${#0}"
filename="${0:2:(( $filenameLength - 2 - 3 ))}"

# Create a randomn password and store it in temp file called secret.txt
openssl rand -base64 756 > ./secret.txt

# Create a kubernetes secret from the generated password
kubectl create secret generic ${filename} --from-file=internal-auth-mongodb-keyfile=./secret.txt

rm -rf ./secret.txt
sleep 10

# Confirm if secret was created
counter=0
max=15
# Name of the secret is the same as the script file name
while [[ ${secret} != ${filename} && ${counter} -lt ${max} ]]; do
    read secret kind data age <<< $(kubectl get secrets ${filename} | grep ${filename})
    sleep 2
    (( counter++ ))
done

if [ -z ${secret} ]; then
    echo No secret was created. Abort.
    exit 1
fi

echo "The kubectl secret has been generated and is called ${filename}."