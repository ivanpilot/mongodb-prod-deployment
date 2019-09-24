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

# set -e >> replaceed by cleaning process

# General variables
mongodb_manifest_file=manifest-test
storage_manifest_file=storage-test

replicas=1 
statefulSetName="mongod" 
statefulService="mongo-service"
containerName="mongod-container" 
replSetName="MainRepSet" 
replicaSecretName="mongodb-replica-secret" 
storageName="local-storage"
database="db_days" 
collectionName="days" 

# adminUsername="${MONGODB_ROOT_ADMIN_NAME}"
# adminPassword="${MONGODB_ROOT_ADMIN_PASSWORD}"
# username="${MONGODB_USERNAME}"
# password="${MONGODB_PASSWORD}"
adminUsername="admin"
adminPassword="admin"
username="ivan"
password="ivan"

cleaning() {
    if [ $? -ne 0 ]; then
        echo "There was a problem during launch phase. Currently cleaning deployment."
        ./cleaning.sh -- ${mongodb_manifest_file} ${storageName} ${replicaSecretName}
        echo "Deployment has been cleaned. Exiting now."
        exit 0
    fi
}

# Launch various scripts in the below order order

# _______  STEP 1: CREATE KEYFILE  ________ 
echo "1. Create a random secret with kubernetes."
./mongodb-replica-secret.sh
cleaning
echo "Step 1 of 6 complete."
echo ""

# _______  STEP 2: GENERATE MANIFEST FILE  ________ 
echo "2. Generate kubernetes statefuleSet manifest."
./create_kube_manifest.sh -- ${replicas} ${mongodb_manifest_file} ${statefulService} ${statefulSetName} ${containerName} ${replSetName} ${replicaSecretName}
cleaning
echo "Step 2 of 6 complete."
echo ""

# _______  STEP 3: APPLY STATEFUL SET MANIFEST  ________ 
echo "3. Apply statefuleSet manifest to deploy mongodb replicas."
./deploy_manifest.sh -- ${replicas} ${statefulSetName} ${mongodb_manifest_file} ${storage_manifest_file} ${storageName}
cleaning
echo "Step 3 of 6 complete."
echo ""

# _______  STEP 4: INITIATE THE REPLICA SET  ________ 
echo "4. Initialize replicas."
# <program_name> -- [replicas] [service] [stateful object] [stateful container name] [replSet] [:option - port (27017 default)]
./initialize_replicaset.sh -- ${replicas} ${statefulService} ${statefulSetName} ${containerName} ${replSetName} 
cleaning
echo "Step 4 of 6 complete."
echo ""
# _______  STEP 5: CREATE ROOT ADMIN USER  ________ 
echo "5. Create the root Admin user."
./create_rootAdmin.sh -- ${statefulSetName} ${containerName} -u ${adminUsername} -p ${adminPassword}
cleaning
echo "Step 5 of 6 complete."
echo ""

# _______  STEP 6: CREATE STANDARD USER  ________ 
echo "6. Create standard user."
./create_standardUser.sh -- ${statefulSetName} ${containerName} ${database} -adminu ${adminUsername} -adminp ${adminPassword} -u ${username} -p ${password}
cleaning
echo "Step 6 of 6 complete."
echo ""

echo "Everything has launched successfully. Enjoy!"
echo ""
echo ""

# _______  STEP X: EXTRA STEP TO SEED DATABASE  ________ 
echo "Extra. Seed the database."
./seed-db.sh -- ${statefulSetName} ${containerName} ${database} ${collectionName} -u ${username} -p ${password}
echo "ALL DONE."