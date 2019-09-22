#! /bin/bash

if [ "${1:0:2}" = "--" ]; then
    shift

    # Check that the right number of arguments was passed
    if [ "${#}" -ne 8 ]; then
        echo "You must provide the mandatory arguments such as -- [stateful object] [stateful container name] [database name] [collection name] -u [username] -p [password]" 
        exit 1
    fi

    statefulSetObject="${1}" 
    containerName="${2}"
    database="${3}"
    collectionName="${4}"

    shift 4

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

    echo "Currently seeding database..."

    kubectl exec "${statefulSetObject}"-0 -c "${containerName}" -- bash -ec "mongo <<EOF
        db.getSiblingDB('${database}').auth('${username}', '${password}');
        use ${database};
        db.createCollection('${collectionName}');
        db.${collectionName}.insert([
            {
                color: '#BA2C73', 
                darken: '#AA2869',
                name: 'monday',
                votes: 0
            },
            { 
                color: '#6D3B47',
                darken: '#643641',
                name: 'tuesday',
                votes: 0 
            },
            { 
                color: '#554B59',
                darken: '#453A49',
                name: 'wednesday',
                votes: 0
            },
            { 
                color: '#3B4155',
                darken: '#282F44',
                name: 'thursday',
                votes: 0
            },
            { 
                color: '#2D3144',
                darken: '#191D32',
                name: 'friday',
                votes: 0
            },
        ])
EOF"

    echo "Database was successfully seed."
else
    echo "You must provide the mandatory arguments such as -- [stateful object] [stateful container name] [database name] [collection name] -u [username] -p [password]" 
    exit 1
fi