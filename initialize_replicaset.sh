#! /bin/bash

# launch program as <program_name> - [options]
# options are
# 1. number of replicas > 3
# 2. name of the stateful service from manifest > mongo-statefulset-service
# 3. name of the statefulSet object from manifest > mongod
# 4. name of the template container from manifest > mongod-container
# 5. name of replSet provide as argument cmd in the manifest > MainRepSet
# 6. port > 27017




if [ "${1:0:1}" = "-" ]; then
    shift
    statefulService=$3
    statefulSetObject=$2
    replicas=$1
    containerName=$4
    replSetName=$5
    port=$6

    initializeContent="{_id: ${replSetName}, version: 1, members: "

    if [ -n $1 -a "${replicas}" -eq "${replicas}" ]; then
        
        # # Create each member object for initialization
        # for (( i = 0; i < $replicas; i++ )); do
        #     members[$i]="{ _id: ${i}, host: "${statefulSetObject}-${i}.${statefulService}.default.svc.cluster.local:${port}"}"
        # done
        
        # # Assemble each member object all together
        # for (( i = 0; i < $replicas; i++ )); do
        #     if [ $i -eq $(( replicas - 1 )) ]; then
        #         members+="${members[$i]}"
        #     else
        #         members+="${members[$i]},"
        #     fi
        # done

        # # Wrapped the assembled members object with [] to become an array
        # initializeContent+="[${members}]}"
        # # echo ${initializeContent}
        
        # # Initialize the replica set inside the mongo container
        # kubectl exec ${statefulSetObject}-0 -c ${containerName} -- bash -ec "mongo << EOF
        #     rs.initiate($(initializeContent))
        # EOF"

        # # Wait for replica set to initialize
        # sleep 20

        # # Check that replica set has initialized 
#         rsCount=0
#         while [[ ${rsCount} -ne ${replicas} ]]; do
        
#             # # heredoc indent is not working as it is enclose inside quote
#             # # thus, the closing heredoc must not have any indentation other it returns an error
#             kubectl exec mongod-0 -c mongod-container -- bash -ec "mongo <<EOF
#                 db.getSiblingDB('admin').auth('ivan', 'ivan')
#                 rs.status()
# EOF" > rs_status.txt

#             rsCount=$(grep -c '"health" : 1' rs_status.txt)
#         done

#         rm -rf rs_status.txt

            kubectl exec mongod-0 -c mongod-container -- bash -ec "mongo <<EOF
                db.getSiblingDB('admin').auth('ivan', 'ivan');
                while (
                    rs.status().hasOwnProperty('myState') &&
                    rs.status().myState != 1
                ) {
                    print('.');
                    sleep(1000);
                };
EOF"


        

    fi

fi