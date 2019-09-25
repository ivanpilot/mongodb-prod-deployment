#! /bin/bash

if [ "${1:0:2}" = "--" ]; then
    shift

    # Check that the right number of arguments was passed
    if [ "${#}" -ne 4 ]; then
        echo "You must provide the mandatory arguments such as -- [storage class filename] [storage name] [provisioner - no-provision / gce-pd] [diskType: pd-standard / pd-sdd]" 
        exit 1
    fi

    storageclassFilename="${1}"
    storageName="${2}"
    provisioner="${3}"
    diskType="${4}"

cat << EOF > ${storageclassFilename}.yml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
    name: ${storageName}
provisioner: kubernetes.io/${provisioner}
parameters:
    type: ${diskType}
    fsType: xfs
reclaimPolicy: Retain
allowVolumeExpansion: true
mountOptions:
    - debug
volumeBindingMode: Immediate
EOF


    chmod u+x "${storageclassFilename}".yml

    echo "${storageclassFilename}.yml manifest generated."

else
    echo "You must provide the mandatory arguments such as -- [storage class filename] [storage name] [provisioner - no-provision / gce-pd] [diskType: pd-standard / pd-sdd]" 
    exit 1
fi