#! /bin/bash

# kubectl exec mongod-0 -c mongod-container -- mongo --eval "
#     db
# "



# echo "Step 1: Initialize the replica set"
# echo "... Waiting for initialization ..."

# kubectl exec mongod-0 -c mongod-container -- mongo << EOF
#     rs.initiate({_id: "MainRepSet", version: 1, members: [
#        { _id: 0, host : "mongod-0.mongo-statefulset-service.default.svc.cluster.local:27017" }
#     ]})
# EOF
# sleep 10

# echo "Initialization of replica set completed"
# echo
# echo "Step 1: Creation of users and assigning them roles"
# echo "Creating the admin user..."

# kubectl exec mongod-0 -c mongod-container -- mongo << EOF
#     db.getSiblingDB('admin').auth('ivan', 'ivan');
#     use admin;
#     show users;
#     show dbs;
# EOF
# kubectl exec mongod-0 -c mongod-container -- mongo << EOF
#     db.getSiblingDB('admin').auth('ivan', 'ivan');
#     db.getSiblingDB("admin").createUser({
#         user: "admin",
#         pwd: "admin",
#         roles: [ { role: "userAdminAnyDatabase", db: "admin" } ]
#     })
# EOF
# sleep 5

# echo "Creation of admin user completed"
# echo
# echo "Creating the clusterAdmin user..."

# kubectl exec mongod-0 -c mongod-container -- mongo --eval "
#     db.getSiblingDB('admin').auth('ivan', 'ivan')
#     db.getSiblingDB("admin").createUser({
#         user: "cluster",
#         pwd: "cluster",
#         roles: [ { role: "clusterAdmin", db: "admin" } ]
#     })
# "
# sleep 5

# echo "Creation of clusterAdmin user completed"
# echo
echo "Creating user user..."

kubectl exec mongod-0 -c mongod-container -- bash -ec "mongo <<EOF
    db.getSiblingDB('admin').auth('ivan', 'ivan');
    db.getSiblingDB('db_days').createUser({
        user: 'ivan',
        pwd: 'ivan',
        roles: [ {role:'readWrite', db: 'db_days'} ]
    });
    use db_days;
    db.getUsers();
EOF"
# kubectl exec mongod-0 -c mongod-container -- bash -ec "mongo <<EOF
#     db.getSiblingDB('admin').auth('ivan', 'ivan');
#     use admin;
#     db.getSiblingDB('admin').createUser({
#         user: 'user',
#         pwd: 'user',
#         roles: [ {role:'readWrite', db: 'db_days'} ]
#     });
#     db.getUsers();
# EOF"
