#! /bin/bash

if [ "${1:0:2}" = "--" ]; then
    shift

    # Check that the right number of arguments was passed
    if [ "${#}" -ne 4 ]; then
        echo "You must provide the mandatory arguments such as -- [replicas] [manifest filename] [storage name] [replica secret name]"
        exit 1
    fi

    if [ -n "${1}" ] && [ "${1}" -eq "${1}" ] && [ "${1}" -gt 0 ] && [ "${1}" -le 10 ]; then


        replicas="${1}"
        manifestFilename="${2}.yml"
        storageName="${3}"
        replicaSecret="${4}"

        echo "Deleting kubectl manifest file ${manifestFilename}"
        kubectl delete -f "${manifestFilename}"

        echo "Deleting pvc object"
        for (( i = 0; i < "${replicas}"; i++ )); do
            read name status volume capacity access modes storageClass age <<< $(kubectl get pvc | grep pvc)
            kubectl delete pvc "${name}"
            unset name status volume capacity access modes storageClass age
        done
        
        echo "Deleting storage class object"
        kubectl delete storageClass "${storageName}"

        echo "Deleting secret keyfile"
        kubectl delete secret "${replicaSecret}"
    
    else
        echo "The number of replicas must be between 1 and 10" 
        exit 1
    fi
else
    echo "You must provide the mandatory arguments such as -- [replicas] [manifest filename] [storage name] [replica secret name]"
    exit 1
fi