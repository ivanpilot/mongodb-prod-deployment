#! /bin/bash
set -e

if [ "${1:0:2}" = "--" ]; then
    shift

    # Check that the right number of arguments was passed
    if [ -z "${1}" ] || [ -z "${2}" ] || [ -z "${3}" ] || [ "${#@}" -ne 3 ]; then
        echo "You must provide the mandatory arguments such as -- [statefulset object] [stateful container name] [database name]"
        exit 1
    fi

    statefulSetObject="${1}"
    containerName="${2}"
    database="${3}"

    # Create the standard user
    kubectl exec "${statefulSetObject}"-0 -c "${containerName}" -- bash -ec "mongo <<EOF
        db.getSiblingDB('admin').auth('${MONGODB_ROOT_ADMIN_NAME}', '${MONGODB_ROOT_ADMIN_PASSWORD}')
        db.getSiblingDB('${database}').createUser({
            user: '${MONGODB_USER_NAME}',
            pwd: '${MONGODB_USER_PASSWORD}',
            roles: [ {role:'readWrite', db: '${database}'} ]
        });
EOF"

    # Check if standard user was created
    isStandardUserCreated="false"
    counter=0
    max=15
    while [[ "${isStandardUserCreated}" == "false" && "${counter}" -le "${max}" ]]; do
        kubectl exec "${statefulSetObject}"-0 -c "${containerName}" -- bash -ec "mongo <<EOF
            if (db.getSiblingDB('${database}').auth('${MONGODB_USER_NAME}', '${MONGODB_USER_PASSWORD}')) {
                true
            } else {
                false
            }
EOF" > tempAuthUser.txt
        
        isStandardUserCreated=$(tail -n 2 tempAuthUser.txt | grep -v "^bye")
        rm ./tempAuthUser.txt
        sleep 2
        (( counter++ ))
    done

    if [ "${isStandardUserCreated}" == "false" ]; then
        echo "Root Admin user could not be created. Abort."
        exit 1
    fi

else
    echo "You must provide the mandatory arguments such as -- [statefulset object] [stateful container name] [database name]"
    exit 1
fi