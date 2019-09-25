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
replica_manifest_filename=days-replica-manifest
storage_manifest_filename=days-storageclass-manifest

replicas=2
statefulSetName="mongod" 
statefulService="mongo-service"
containerName="mongod-container" 
replSetName="MainRepSet" 
replicaSecretName="mongodb-replica-secret" 
storageName="fast-storage"
provisioner="gce-pd"
diskType="pd-standard"
# diskType="pd-sdd"
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
        ./cleaning.sh -- ${replicas} ${replica_manifest_filename} ${storageName} ${replicaSecretName}
        echo "Deployment has been cleaned. Exiting now."
        exit 0
    fi
}

# Launch various scripts in the below order order

# _______  STEP 1: CREATE KEYFILE  ________ 
echo "1. Create a random secret with kubernetes."
./mongodb-replica-secret.sh
cleaning
echo "Step 1 of 7 complete."
echo ""

# _______  STEP 2: GENERATE STORAGE CLASS MANIFEST FILE  ________ 
echo "2. Generate storageClass manifest."
./generate_storageclass_manifest.sh -- ${storage_manifest_filename} ${storageName} ${provisioner} ${diskType}
cleaning
echo "Step 2 of 7 complete."
echo ""

# _______  STEP 3: GENERATE REPLICA MANIFEST FILE  ________ 
echo "3. Generate mongodb replica manifest."
./generate_replica_manifest.sh -- ${replicas} ${replica_manifest_filename} ${statefulService} ${statefulSetName} ${containerName} ${replSetName} ${replicaSecretName} ${storageName}
cleaning
echo "Step 3 of 7 complete."
echo ""

# _______  STEP 4: APPLY STATEFUL SET MANIFEST  ________ 
echo "4. Apply statefuleSet manifest to deploy mongodb replicas."
./deploy_manifest.sh -- ${replicas} ${statefulSetName} ${replica_manifest_filename} ${storage_manifest_filename} ${storageName}
cleaning
echo "Step 4 of 7 complete."
echo ""

cleaning

# # _______  STEP 5: INITIATE THE REPLICA SET  ________ 
# echo "5. Initialize replicas."
# # <program_name> -- [replicas] [service] [stateful object] [stateful container name] [replSet] [:option - port (27017 default)]
# ./initialize_replicaset.sh -- ${replicas} ${statefulService} ${statefulSetName} ${containerName} ${replSetName} 
# cleaning
# echo "Step 5 of 7 complete."
# echo ""

# # _______  DEFINE PRIMARY REPLICA  ________ 
# primary=$(cat ./primary.txt)

# # _______  STEP 6: CREATE ROOT ADMIN USER  ________ 
# echo "6. Create the root Admin user."
# ./create_rootAdmin.sh -- ${primary} ${containerName} -u ${adminUsername} -p ${adminPassword}
# cleaning
# echo "Step 6 of 7 complete."
# echo ""

# # _______  STEP 7: CREATE STANDARD USER  ________ 
# echo "7. Create standard user."
# ./create_standardUser.sh -- ${primary} ${containerName} ${database} -adminu ${adminUsername} -adminp ${adminPassword} -u ${username} -p ${password}
# cleaning
# echo "Step 7 of 7 complete."
# echo ""

# echo "Everything has launched successfully. Enjoy!"
# echo ""
# echo ""

# # _______  STEP X: EXTRA STEP TO SEED DATABASE  ________ 
# echo "Extra. Seed the database."
# ./seed-db.sh -- ${primary} ${containerName} ${database} ${collectionName} -u ${username} -p ${password}
# echo "ALL DONE."