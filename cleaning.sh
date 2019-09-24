#! /bin/bash

if [ "${1:0:2}" = "--" ]; then
    shift

    # Check that the right number of arguments was passed
    if [ "${#}" -ne 3 ]; then
        echo "You must provide the mandatory arguments such as -- [manifest filename] [storage name] [replica secret name]"
        exit 1
    fi

    manifestFilename="${1}.yml"
    storageName="${2}"
    replicaSecret="${3}"

    echo "Deleting kubectl manifest file ${manifestFilename}"
    kubectl delete -f "${manifestFilename}"

    echo "Deleting pvc object"
    read name status volume capacity access modes storageClass age <<< $(kubectl get pvc | grep pvc)
    kubectl delete pvc "${name}"
    unset name status volume capacity access modes storageClass age
    
    echo "Deleting storage class object"
    kubectl delete storageClass "${storageName}"

    echo "Deleting secret keyfile"
    kubectl delete secret "${replicaSecret}"

else
    echo "You must provide the mandatory arguments such as -- [manifest filename] [storage name] [replica secret name]"
    exit 1
fi