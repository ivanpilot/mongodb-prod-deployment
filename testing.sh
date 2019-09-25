#! /bin/bash

replicas=2

kubectl exec mongod-0 -c mongod-container -- bash -ec "mongo <<EOF
    if (rs.status().hasOwnProperty('myState') &&
    rs.status().myState == ${replicas}) {
        true
    } else {
        false
    }
EOF" > tempRepSet.txt
