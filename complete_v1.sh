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
create_secret_file=mongo_db_secret
mongodb_manifest_file=mongodb-statefulset-manifest
storage_manifest_file=storage-days-db
initialize_replica_file=initialize_replicaset
create_rootAdmin=create_rootAdmin

replicas=1
statefulSetName="mongod"
statefulService="mongo-statefulset-service"
containerName="mongod-container"
replSetName="MainRepSet"
storageName="local"
database="db_days"

# _______  STEP 1: CREATE KEYFILE  ________ 
echo "1. Create a random secret with kubernetes."
./${create_secret_file}.sh
echo "Secret was successfully generated."
echo "Step 1 of ... complete."

# _______  STEP 2: APPLY STATEFUL SET MANIFEST  ________ 
echo "2. Apply statefuleSet manifest to deploy mongodb replicas."
./${deploy_manifest}.sh -- ${replicas} ${statefulSetName} ${mongodb_manifest_file} ${storage-days-db} ${storageName}
echo "mongodb was successfully deployed."
echo "Step 2 of ... complete."

# _______  STEP 3: INITIATE THE REPLICA SET  ________ 
echo "3. Initialize replicas."
# <program_name> -- [replicas] [service] [stateful object] [stateful container name] [replSet] [:option - port (27017 default)]
./${initialize_replica_file}.sh -- ${replicas} ${statefulService} ${statefulSetName} ${containerName} ${replSetName} 
echo "Replicas are all initialized and ready."
echo "Step 3 of ... complete."

# _______  STEP 4: CREATE ROOT ADMIN USER  ________ 
echo "4. Create the root Admin user."
./${create_rootAdmin}.sh -- ${statefulSetName} ${containerName}
echo "Root admin user was successfully created."
echo "Step 4 of ... complete."

# _______  STEP 5: CREATE STANDARD USER  ________ 
echo "5. Create standard user."
./${create_rootAdmin}.sh -- ${statefulSetName} ${containerName} ${database}
echo "Root admin user was successfully created."
echo "Step 4 of ... complete."


# Once confirmed all replicas started, 
