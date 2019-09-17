#! /bin/bash

# 1. Create a keyFile
# 2. Apply the statefulSet manifest to deploy mongodb instances
# 3. Initiate the replica set
# 4. Create 3 user types (rootAdmin, clusterAdmin, normal user developer)
# 5. Seed the database if needed

# variables as cmd to execute
# 1. secretFilename
# 2. mainfestFilename
# 3. replicas for number of replicas > must be inline with the manifest


create_secret_file=mongo_db_secret
manifest_file=mongodb-statefulset-manifest
initialize_replica_file=initialize_replicaset
statefulSetName="mongod"
replicas=1
maxAttempts=30
numAttempts=0

# _______  STEP 1: CREATE KEYFILE  ________ 
echo "1. Generating a secret with kubernetes."
./${create_secret_file}.sh

# Name of the secret is the same as the script file name
while [[ $secret != ${create_secret_file} ]]; do
    read "secret type data age" <<< $(kubectl get secrets ${create_secret_file} | grep ${create_secret_file})
done
echo "Secret ready."
echo "Step 1 of ... complete."

# _______  STEP 2: APPLY STATEFUL SET MANIFEST  ________ 
echo "2. Applying statefuleSet manifest to deploy mongod replicaset."
kubectl apply -f ${manifest_file}.yml

# Check if all replicas started up
# Keep checking if this is not the case
# 90s duration for check
while [[ $numPodsRunning -ne $replicas ]]; do
    numPodsRunning=0
    if [ $numAttempts -eq $maxAttempts ]; then
        echo "The replica set did not manage to start properly."
        echo "Exiting the program."
        exit 1
    fi
    if (( $numAttempts > 0 )); then
        sleep 5
    fi


    for (( i = 0; i < $replicas; i++ )); do
        read pods[$i] readys[$i] status[$i] ages[$i] <<< $(kubectl get pods ${pods[$i]} | grep ${statefulSetName})

        if [ ${status[$i]} == 'Running' ]; then
            (( numPodsRunning++ ))
            # echo "pod is_${pods[$i]}_running is running"
        fi
    done
    (( numAttempts++ ))
    echo "The number of pods running is ${numPodsRunning}"
done
echo "Statefulset ready."
echo "Step 2 of ... complete."

# _______  STEP 3: INITIATE THE REPLICA SET  ________ 
echo "3. Initializing replicas."

# <program_name> -- [replicas] [service] [stateful object] [stateful container name] [replSet] [:option - port (27017 default)]
./${initialize_replica_file}.sh -- 1 mongo-statefulset-service mongod mongod-container MainRepSet 
echo "Replicaset are all initialized and ready."
echo "Step 3 of ... complete."

# _______  STEP 4: CREATE USERS  ________ 
echo "4. Creating minimum user config."




# Once confirmed all replicas started, 
