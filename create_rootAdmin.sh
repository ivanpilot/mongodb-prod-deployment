#! /bin/bash

if [ "${1:0:2}" = "--" ]; then
    shift

    # Check that the right number of arguments was passed
    if [ -z "${1}" ] || [ -z "${2}" ] || [ "${#@}" -ne 2 ]; then
        echo "You must provide the mandatory arguments such as -- [statefulset object] [stateful container name]"
        exit 1
    fi

    statefulSetObject="${1}"
    containerName="${2}"

    # Create the root admin user
    kubectl exec "${statefulSetObject}"-0 -c "${containerName}" -- bash -ec "mongo <<EOF
        db.getSiblingDB('admin').createUser({
            user: '${MONGODB_ROOT_ADMIN_NAME}',
            pwd: '${MONGODB_ROOT_ADMIN_PASSWORD}',
            roles: [ { role: 'root', db: 'admin' } ]
        })
EOF"

    # Check if root admin user was created
    isRootAdminUserCreated="false"
    counter=0
    max=15
    while [[ "${isRootAdminUserCreated}" == "false" && "${counter}" -le "${max}" ]]; do
        kubectl exec "${statefulSetObject}"-0 -c "${containerName}" -- bash -ec "mongo <<EOF
            if (db.getSiblingDB('admin').auth('${MONGODB_ROOT_ADMIN_NAME}', '${MONGODB_ROOT_ADMIN_PASSWORD}')) {
                true
            } else {
                false
            }
EOF" > tempAuthAdmin.txt
        
        isRootAdminUserCreated=$(tail -n 2 tempAuthAdmin.txt | grep -v "^bye")
        rm ./tempAuthAdmin.txt
        sleep 2
        (( counter++ ))
    done

    if [ "${isRootAdminUserCreated}" == "false" ]; then
        echo "Root Admin user could not be created. Abort."
        exit 1
    fi

else
    echo "You must provide the mandatory arguments such as -- [statefulset object] [stateful container name]"
    exit 1
fi