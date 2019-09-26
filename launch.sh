#! /bin/bash

statefulSetObject=mongod
containerName=mongod-container
primaryFilename=my-primary.txt

kubectl exec "${statefulSetObject}"-0 -c "${containerName}" -- bash -ec "mongo <<EOF
    if (rs.status().hasOwnProperty('members')) {
        for (i = 0; i < rs.status().members.length; i++) {
            if(rs.status().members[i].stateStr == 'PRIMARY') {
                print('${statefulSetObject}' + '-' + i)
            }
        }
    } 
EOF" > "${primaryFilename}"
