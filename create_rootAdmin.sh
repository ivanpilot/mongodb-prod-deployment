#! /bin/bash

if [ "${1:0:2}" = "--" ]; then
    shift

    # Check that the right number of arguments was passed
    if [ "${#}" -ne 6 ]; then
        echo "You must provide the mandatory arguments such as -- [primary] [stateful container name] -u [username] -p [password]"
        exit 1
    fi

    primary="${1}"
    containerName="${2}"
    shift 2

    # allocating -u and -p flags accordingly
    if [ "${1:0:2}" = "-u" ]; then
        shift
        username="${1}"
        shift

        if [ "${1:0:2}" = "-p" ]; then
            shift
            password="${1}"
        else
            echo "You must provide a password."
            exit 1
        fi
    elif [ "${1:0:2}" = "-p" ]; then
        shift
        password="${1}"
        shift

        if [ "${1:0:2}" = "-u" ]; then
            shift
            username="${1}"
        else
            echo "You must provide a username."
            exit 1
        fi
    else
        echo "You must provide a username and a password in the correct order."
        exit 1
    fi

    # Create the root admin user
    kubectl exec "${primary}" -c "${containerName}" -- bash -ec "mongo <<EOF
        db.getSiblingDB('admin').createUser({
            user: '${username}',
            pwd: '${password}',
            roles: [ { role: 'root', db: 'admin' } ]
        })
EOF"

    echo "Checking if root admin user was created."
    isRootAdminUserCreated="false"
    counter=0
    max=15
    while [[ "${isRootAdminUserCreated}" == "false" && "${counter}" -le "${max}" ]]; do
        kubectl exec "${primary}" -c "${containerName}" -- bash -ec "mongo <<EOF
            if (db.getSiblingDB('admin').auth('${username}', '${password}')) {
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
    echo "Confirmed - root admin user created."

else
    echo "You must provide the mandatory arguments such as -- [primary] [stateful container name] -u [username] -p [password]"
    exit 1
fi