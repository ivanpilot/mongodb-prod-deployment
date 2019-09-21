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

set -e

# General variables
mongodb_manifest_file=statefulset-manifest-test
storage_manifest_file=storage-test

replicas=1 
statefulSetName="mongod" 
statefulService="mongo-service"
containerName="mongod-container" 
replSetName="MainRepSet" 
storageName="local-storage"
database="db_days" 

# adminUsername="${MONGODB_ROOT_ADMIN_NAME}"
# adminPassword="${MONGODB_ROOT_ADMIN_PASSWORD}"
# username="${MONGODB_USERNAME}"
# password="${MONGODB_PASSWORD}"
adminUsername="admin"
adminPassword="admin"
username="ivan"
password="ivan"

# Launch various scripts in the below order order

# _______  STEP 1: CREATE KEYFILE  ________ 
echo "1. Create a random secret with kubernetes."
./mongodb-replica-secret.sh
echo "Step 1 of 5 complete."

# _______  STEP 2: APPLY STATEFUL SET MANIFEST  ________ 
echo "2. Apply statefuleSet manifest to deploy mongodb replicas."
./deploy_manifest.sh -- ${replicas} ${statefulSetName} ${mongodb_manifest_file} ${storage_manifest_file} ${storageName}
echo "Step 2 of 5 complete."

# _______  STEP 3: INITIATE THE REPLICA SET  ________ 
echo "3. Initialize replicas."
# <program_name> -- [replicas] [service] [stateful object] [stateful container name] [replSet] [:option - port (27017 default)]
./initialize_replicaset.sh -- ${replicas} ${statefulService} ${statefulSetName} ${containerName} ${replSetName} 
echo "Replicas are all initialized and ready."
echo "Step 3 of 5 complete."

# _______  STEP 4: CREATE ROOT ADMIN USER  ________ 
echo "4. Create the root Admin user."
./create_rootAdmin.sh -- ${statefulSetName} ${containerName} -u ${adminUsername} -p ${adminPassword}
echo "Root admin user was successfully created."
echo "Step 4 of 5 complete."

# _______  STEP 5: CREATE STANDARD USER  ________ 
echo "5. Create standard user."
./create_standardUser.sh -- ${statefulSetName} ${containerName} ${database} -adminu ${adminUsername} -adminp ${adminPassword} -u ${username} -p ${password}
echo "Root admin user was successfully created."
echo "Step 5 of 5 complete."

echo "Everything has launched. go check if it is working"