# Deployment of MONGODB replica set

## Local deployment on minikube
For a local deployment we need a kubernetest manifest specifying how to launch mongo and using ONLY 1 replica

1. a script to generate a keyfile that will be use for authentication
2. kubectl manifest
3. a script to initialise and launch the replica set

## Production deployment on GKE
For a production deployment, in addition to what is required for local deployment, we will also need

1. save a folder of instruction on github and link it to TravisCI
2. a script for travis to connect to our GCP project and to perform te deployment
1. a script to generate a keyfile that will be use for authentication
2. kubectl manifest
3. a script to initialise and launch the replica set