#! /bin/bash

# delete the firewall rule
gcloud compute firewall-rules delete upsource-world-80 --quiet

# delete the service and pod
kubectl delete service upsource-service
kubectl delete pod upsource

# delete the cluster
gcloud beta container clusters delete cluster-upsource

# delete the disk (save your data first, if you need them!)
gcloud compute disks delete upsource-disk