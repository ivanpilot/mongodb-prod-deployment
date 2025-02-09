#! /bin/bash

filenameLength="${#0}"
filename="${0:2:(( filenameLength - 2 - 3 ))}"

# Create a random password and store it in a temp file
openssl rand -base64 756 > ./secret.txt

# Create a kubernetes secret from the generated password
kubectl create secret generic "${filename}" --from-file=internal-auth-mongodb-keyfile=./secret.txt &>/dev/null

rm -rf ./secret.txt
echo "Waiting for secret to be created."
timer=1
while [ "${timer}" -le 5 ]; do
    sleep 1
    if [ "${timer}" -lt 5 ]; then
        printf '.'
    else
        echo '.'
    fi
    (( timer++ ))
done

echo "Checking if secret was created."

counter=0
max=15
# Name of the secret is the same as the script file name
while [[ "${secret}" != "${filename}" && "${counter}" -le "${max}" ]]; do
    read secret kind data age <<< $(kubectl get secrets ${filename} | grep ${filename})
    sleep 2
    (( counter++ ))
done

if [ -z "${secret}" ]; then
    echo "No secret was created. Abort."
    exit 1
fi

echo "Confirmed - secret was created."