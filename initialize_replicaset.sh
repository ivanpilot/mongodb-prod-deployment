#! /bin/bash

# launch program as <program_name> -- [args][options]
# args are
# 1. number of replicas > 3
# 2. name of the stateful service from manifest > mongo-statefulset-service
# 3. name of the statefulSet object from manifest > mongod
# 4. name of the template container from manifest > mongod-container
# 5. name of replSet provide as argument cmd in the manifest > MainRepSet
# option is
# 6. port > 27017

if [ "${1:0:2}" = "--" ]; then
    shift

    # Check that the right number of arguments was passed
    if [ "${#}" -lt 5 ] || [ "${#}" -gt 6 ]; then
        echo "You must provide the mandatory arguments such as -- [replicas] [service] [stateful object] [stateful container name] [replSet] [:option - port]" 
        exit 1
    fi

    if [ -n "${6}" ] && [ "${6}" -eq "${6}" ] && [ "${6}" -ge 0 ] 2>/dev/null; then
        port="${6}"
    else
        port=27017
    fi

    if [ -n "${1}" ] && [ "${1}" -eq "${1}" ] && [ "${1}" -gt 0 ] && [ "${1}" -le 10 ]; then

        replicas="${1}"
        statefulService="${2}"
        statefulSetObject="${3}"
        containerName="${4}"
        replSetName="${5}"

        initializeContent="{_id: '${replSetName}', version: 1, members: "

        # Create each member object for initialization
        for (( i = 0; i < "${replicas}"; i++ )); do
            members[$i]="{ _id: ${i}, host: '"${statefulSetObject}-${i}.${statefulService}.default.svc.cluster.local:${port}"'}"
        done
        
        # Concatenate each member object all together
        for (( i = 0; i < "${replicas}"; i++ )); do
            if [ "${i}" -eq $(( replicas - 1 )) ]; then
                concatmembers+="${members[$i]}"
            else
                concatmembers+="${members[$i]},"
            fi
        done

        # Wrapped the assembled members object with [] to become an array
        initializeContent+="[${concatmembers}]}"
        
        # Initialize the replica set inside the mongo container
        kubectl exec "${statefulSetObject}"-0 -c "${containerName}" -- bash -ec "mongo << EOF
            rs.initiate(${initializeContent})
EOF"

        echo "Waiting for replica set to initialize."
        timer=1
        while [ "${timer}" -le 20 ]; do
            sleep 1
            if [ "${timer}" -lt 20 ]; then
                printf '.'
            else
                echo '.'
            fi
            (( timer++ ))
        done

        echo "Checking if all replicas set were initialized." 
        isReplicaSetCreated="false"
        counter=0
        max=15
        while [[ "${isReplicaSetCreated}" == "false" && "${counter}" -le "${max}" ]]; do
            kubectl exec "${statefulSetObject}"-0 -c "${containerName}" -- bash -ec "mongo <<EOF
                if (rs.status().hasOwnProperty('myState') &&
                rs.status().myState == ${replicas}) {
                    true
                } else {
                    false
                }
EOF" > tempRepSet.txt

echo ""
echo "content of tempRep is"
cat ./tempRepSet.txt
echo ""

            isReplicaSetCreated=$(tail -n 2 tempRepSet.txt | grep -v "^bye")
echo ""
echo "isReplicaSetCreated is ${isReplicaSetCreated}"
echo ""
            rm ./tempRepSet.txt
            (( counter++ ))
            sleep 2
        done

        if [ "${isReplicaSetCreated}" == "false" ]; then
            echo "Replica set could not be initialized. Abort."
            exit 1
        fi

        # Retrieved primary
        kubectl exec "${statefulSetObject}"-0 -c "${containerName}" -- bash -ec "mongo <<EOF
                if (rs.status().hasOwnProperty('members') {
                    for (i = 0; i < rs.status().members.length; i++) {
                        if(rs.status().members[i].stateStr == 'PRIMARY') {
                            ${statefulSetObject}-[i]
                        }
                    }
                }
EOF" > primary.txt

        echo "Confirmed - all replicas initialized and ready." 

    else
        echo "The number of replicas must be between 1 and 10" 
        exit 1
    fi

else
    echo "You must provide the mandatory arguments such as -- [replicas] [service] [stateful object] [stateful container name] [replSet] [:option - port]"
    exit 1
fi