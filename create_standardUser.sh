#! /bin/bash

if [ "${1:0:2}" = "--" ]; then
    shift

    # Check that the right number of arguments was passed
    if [ "${#}" -ne 11 ]; then
        echo "You must provide the mandatory arguments such as -- [statefulset object] [stateful container name] [database name] -adminu [adminUsername] -adminp [adminPassword] -u [username] -p [password]"
        exit 1
    fi

    statefulSetObject="${1}"
    containerName="${2}"
    database="${3}"
    shift 3

    # allocating -adminu and -adminp flags accordingly
    if [ "${1}" = "-adminu" ]; then
        shift
        adminUsername="${1}"
        shift

        if [ "${1}" = "-adminp" ]; then
            shift
            adminPassword="${1}"
        else
            echo "You must provide an admin password."
            exit 1
        fi
    elif [ "${1}" = "-adminp" ]; then
        shift
        adminPassword="${1}"
        shift

        if [ "${1}" = "-adminu" ]; then
            shift
            adminUsername="${1}"
        else
            echo "You must provide an admin username."
            exit 1
        fi
    else
        echo "You must provide an admin username and an admin password in the correct order."
        exit 1
    fi

    shift

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
    
    # Create the standard user
    kubectl exec "${statefulSetObject}"-0 -c "${containerName}" -- bash -ec "mongo <<EOF
        db.getSiblingDB('admin').auth('${adminUsername}', '${adminPassword}')
        db.getSiblingDB('${database}').createUser({
            user: '${username}',
            pwd: '${password}',
            roles: [ {role:'readWrite', db: '${database}'} ]
        });
EOF"

    # Check if standard user was created
    isStandardUserCreated="false"
    counter=0
    max=15
    while [[ "${isStandardUserCreated}" == "false" && "${counter}" -le "${max}" ]]; do
        kubectl exec "${statefulSetObject}"-0 -c "${containerName}" -- bash -ec "mongo <<EOF
            if (db.getSiblingDB('${database}').auth('${username}', '${password}')) {
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
    echo "You must provide the mandatory arguments such as -- [statefulset object] [stateful container name] [database name] -adminu [adminUsername] -adminp [adminPassword] -u [username] -p [password]"
    exit 1
fi