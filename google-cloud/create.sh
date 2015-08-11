#! /bin/bash

# create clusters and disks
gcloud config set compute/zone europe-west1-d
gcloud beta container clusters create cluster-upsource --num-nodes 1 --disk-size 40 --machine-type n1-standard-2
gcloud compute disks create upsource-disk --size 50GB --type pd-ssd

# create the service (load balancer)
kubectl create -f upsource-service.yaml
kubectl get service upsource-service --no-headers | tail -1 | awk '{print $1}'
# forward ports
gcloud compute firewall-rules create upsource-world-80 --allow tcp:80 --target-tags $(kubectl get nodes | grep -o 'hostname=gke.*-node' | grep -o 'gke.*-node')

# set the service IP in the Dockerfile at this step
# build and push the Docker image
docker build -t gcr.io/droidcon-backend/upsource .
gcloud docker push gcr.io/droidcon-backend/upsource
# create the container pod
kubectl create -f upsource.yaml
