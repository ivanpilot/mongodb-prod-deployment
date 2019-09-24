#! /bin/bash

if [ "${1:0:2}" = "--" ]; then
    shift

    # Check that the right number of arguments was passed
    if [ "${#}" -lt 7 ] || [ "${#}" -gt 8 ]; then
        echo "You must provide the mandatory arguments such as -- [replicas] [manifest filename] [service] [stateful object] [stateful container name] [replSet] [replicaSecret] [:option - port]" 
        exit 1
    fi

    if [ -n "${8}" ] && [ "${8}" -eq "${8}" ] && [ "${8}" -ge 0 ] 2>/dev/null; then
        port="${8}"
    else
        port=27017
    fi

    if [ -n "${1}" ] && [ "${1}" -eq "${1}" ] && [ "${1}" -gt 0 ] && [ "${1}" -le 10 ]; then

        replicas="${1}"
        manifestFilename="${2}"
        statefulServiceName="${3}"
        statefulSetObject="${4}" 
        containerName="${5}"
        replSetName="${6}"
        replicaSecret="${7}" 

cat << EOF > ${manifestFilename}.yml
apiVersion: v1
kind: Service
metadata:
    name: ${statefulServiceName}
    labels:
        name: mongo-statefulset
spec:
    ports:
      - port: ${port}
        targetPort: ${port}
    clusterIP: None
    selector:
        role: mongo
---
apiVersion: apps/v1
kind: StatefulSet
metadata:
    name: ${statefulSetObject}
spec:
    serviceName: ${statefulServiceName}
    replicas: ${replicas}
    selector:
        matchLabels:
            role: mongo
    template:
        metadata:
            labels:
                role: mongo
        spec:
            terminationGracePeriodSeconds: 10
            volumes:
              - name: secrets-volume
                secret:
                  secretName: ${replicaSecret}
                  defaultMode: 256
            containers:
              - name: ${containerName}
                image: mongo
                command:
                    - "numactl"
                    - "--interleave=all"
                    - "mongod"
                    - "--bind_ip"
                    - "0.0.0.0"
                    - "--replSet"
                    - "${replSetName}"
                    - "--auth"
                    - "--clusterAuthMode"
                    - "keyFile"
                    - "--keyFile"
                    - "/etc/secrets-volume/internal-auth-mongodb-keyfile"
                    - "--setParameter"
                    - "authenticationMechanisms=SCRAM-SHA-1"
                resources:
                  requests:
                    cpu: 0.2
                    memory: 200Mi
                ports:
                  - containerPort: ${port}
                volumeMounts:
                  - name: secrets-volume
                    readOnly: true
                    mountPath: /etc/secrets-volume
                  - name: mongodb-persistent-storage-claim
                    mountPath: /data/db
    volumeClaimTemplates:
        - metadata:
            name: mongodb-persistent-storage-claim
            annotations:
                volume.beta.kubernetes.io/storage-class: "standard"
          spec:
            accessModes: ["ReadWriteOnce"]
            resources:
              requests:
                storage: 1Gi
EOF

    else
        echo "The number of replicas must be between 1 and 10" 
        exit 1
    fi

    chmod u+x "${manifestFilename}".yml

    echo "${manifestFilename}.yml manifest generated."

else
    echo "You must provide the mandatory arguments such as -- [replicas] [manifest filename] [service] [stateful object] [stateful container name] [replSet] [replicaSecret] [:option - port]" 
    exit 1
fi