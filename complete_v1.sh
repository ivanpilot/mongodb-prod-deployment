#! /bin/bash

# 1. Create a keyFile
# 2. Apply the statefulSet manifest to deploy mongodb instances
# 3. Check if statefulSet has started
# 4. Initiate the replica set
# 5. Create 3 user types (rootAdmin, clusterAdmin, normal user developer)
# 6. Seed the database if needed
# 7. 

# variables as cmd to execute
# 1. secretFilename
# 2. mainfestFilename
# 3. replicas for number of replicas > must be inline with the manifest


secretFilename=mongo_db_secret
manifestFilename=mongodb-statefulset-manifest
statefulSetName="mongod"
replicas=1
maxAttempts=30
numAttempts=0

# _______  STEP 1  ________ 
echo "1. Generating a secret with kubernetes."
./${secretFilename}.sh
while [[ $secret != ${secretFilename} ]]; do
    read "secret type data age" <<< $(kubectl get secrets ${secretFilename} | grep ${secretFilename})
done
echo "Secret ready."
echo "Step 1 of ... complete."

# _______  STEP 2  ________ 
echo "2. Applying statefuleSet manifest to deploy mongod replicaset."
kubectl apply -f ${manifestFilename}.yml

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
echo "Replica set ready."
echo "Step 2 of ... complete."

# _______  STEP 3  ________ 




# Once confirmed all replicas started, 
