#! /bin/bash

# launch program as <program_name> -- [args]
# args are
# 1. number of replicas > 3
# 2. name of the statefulSet object from manifest > mongod
# 3. name of kubernetes manifest file

if [ "${1:0:2}" = "--" ]; then
    shift

    if [ "${#}" -ne 5 ]; then
        echo "You must provide the mandatory arguments such as -- [replicas] [statefulset object] [mongodb manifest filename] [storage manifest filename] [storage name]"
        exit 1
    fi

    if [ -n "${1}" ] && [ "${1}" -eq "${1}" ] && [ "${1}" -gt 0 ] && [ "${1}" -le 10 ]; then

        replicas="${1}"
        statefulSetName="${2}"
        mongod_manifest_file="${3}.yml"
        storage_manifest_file="${4}.yml"
        storageName="${5}"

    # Deploy storage class
        echo "Waiting for storageClass to be provisioned."
        kubectl apply -f "${storage_manifest_file}"
        timer=1
        while [ "${timer}" -le 10 ]; do
            sleep 1
            if [ "${timer}" -lt 10 ]; then
                printf '.'
            else
                echo '.'
            fi
            (( timer++ ))
        done

        echo "Checking if storageClass has been provisioned."
        counterStorage=0
        maxStorage=15
        while [[ "${name}" != "${storageName}" && "${counterStorage}" -le "${maxStorage}" ]]; do
            read name provisioner age <<< $(kubectl get storageClass ${storageName} | grep ${storageName})
            (( counterStorage++ ))
        done

        if [ -z "${name}" ]; then
            echo "No storage class was created. Abort."
            exit 1
        fi
        echo "Confirmed - storageClass provisioned."

    # Deploy mongodb
        echo "Waiting for all replicas to start."
        kubectl apply -f "${mongod_manifest_file}"
        timer=1
        while [ "${timer}" -le 15 ]; do
            sleep 1
            if [ "${timer}" -lt 15 ]; then
                printf '.'
            else
                echo '.'
            fi
            (( timer++ ))
        done

        echo "Checking if all replicas started up."
        counter=0
        max=15
        while [[ "${numPodsRunning}" -ne "${replicas}" ]]; do
            numPodsRunning=0
            
            if [ "${counter}" -eq "${max}" ]; then
                echo "The replica set did not manage to start properly. Abort."
                exit 1
            fi

            for (( i = 0; i < "${replicas}"; i++ )); do
                read pods[$i] ready[$i] status[$i] age[$i] <<< $(kubectl get pods ${pods[$i]} | grep ${statefulSetName})

                if [ ${status[$i]} == 'Running' ]; then
                    (( numPodsRunning++ ))
                fi
            done

            sleep 5
            (( counter++ ))
        done
        echo "Confirmed - all replicas set started up."
    else
        echo "The number of replicas must be between 1 and 10."
        exit 1
    fi
else
    echo "You must provide the mandatory arguments such as -- [replicas] [statefulset object] [mongodb manifest filename] [storage manifest filename] [storage name]"
    exit 1
fi