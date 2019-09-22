#! /bin/bash

# kubectl exec mongod-0 -c mongod-container -- bash -ec "mongo <<EOF
#     db;
#     use admin;
#     db;
#     db.getSiblingDB('admin').auth('ivan', 'ivan');
#     show users;
# EOF"

echo "Currently seeding database..."

kubectl exec mongod-0 -c mongod-container -- bash -ec "mongo <<EOF
    db.getSiblingDB('db_days').auth('ivan', 'ivan');
    use db_days;
    db.createCollection('days');
    db.days.insert([
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
    db.days.count({})
EOF"

echo "Database was successfully seed."