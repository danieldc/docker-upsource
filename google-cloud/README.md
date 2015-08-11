# Run docker-upsource on the Google Cloud

The following is a mini-tutorial on how to run `frapontillo/upsource` on the Google Cloud. This directory also contains some example files you may need to setup your Google Cloud project.

## Initial setup

At first, you need to create a new project on the Google Cloud Console and give it an id (e.g. 'your-awesome-project-id').

Then, make sure you have `gcloud` and `kubectl` [installed and properly configured](https://cloud.google.com/container-engine/docs/before-you-begin).

Specify the project you're currently configuring:

```shell
gcloud config set project your-awesome-project-id
```

Set the VM zone for Compute Engine:

```shell
gcloud config set compute/zone europe-west1-d
```

## Init your cluster

According to your preferences, you need to create your cluster with the following parameters:

* cluster name
* number of nodes
* the size of the disk
* the type of machine (for Upsource, always choose `n1-standard-2` or better machines)

An example cluster creation would be:

```shell
gcloud beta container clusters create cluster-jetbrains --num-nodes 1 --disk-size 40 --machine-type n1-standard-2
```

## Create a persistent disk

Since Compute Engine containers are ephemeral, their contents are wiped out at every reboot (which always happen for maintenance reasons), therefore you need a persistent disk to store your data, e.g.:

```shell
gcloud compute disks create disk-jetbrains --size 50GB --type pd-ssd
```

## Create the LoadBalancer

Compute Engine containers can't be accessed directly, but they need to be referenced by a `LoadBalancer`.

Create a file named `upsource-service.yaml` (see [example](upsource-service.yaml)), e.g.:

```yaml
apiVersion: v1
kind: Service
metadata:
  labels:
    name: upsource-service
  name: upsource-service
spec:
  type: LoadBalancer
  ports:
    # The port that this service should serve on.
    - port: 80
      targetPort: 8080
      protocol: TCP
  # Label keys and values that must match in order to receive traffic for this service.
  selector:
    name: upsource
```

Remember the name you give the `selector`, as your container will need to have this very name.

Then, deploy the load balancer by calling:

```shell
kubectl create -f upsource-service.yaml
```

You will then have a load balancer whose external IP can be retrieved by calling `kubectl get service upsource-service` (it's the second one in the `IP(S)` column), e.g.:

```shell
kubectl get service upsource-service --no-headers | tail -1 | awk '{print $1}'
```

You're going to need this IP in a couple of steps.

## Port forwarding

Now you need to let the cluster node accept connections on the port 80 we just mapped:

```shell
gcloud compute firewall-rules create upsource-world-80 --allow tcp:80 --target-tags $(kubectl get nodes | grep -o 'hostname=gke.*-node' | grep -o 'gke.*-node')
```

**NOTE**: `kubectl get nodes` gives you the list of the nodes in the cluster, you need to set as a target the `gke`-to-`node` part of the node name.

## Create your image

In order to run Upsource on Compute Engine, you need to set some environment variables in your own custom Upsource image so that your container will automatically pick them up on re-creation, without prompting you with the wizard configurator.

Write a custom `Dockerfile` (see [example](Dockerfile)) and assign the following environment variables:

* `UPSOURCE_BASE_URL`, the HTTP server of the load balancer, use the IP we retrieved two steps before
* `UPSOURCE_LOGS_DIR`, the path you wish to save your logs to
* `UPSOURCE_TEMP_DIR`, the path you wish to save your temp files to
* `UPSOURCE_DATA_DIR`, the path you wish to save your data to
* `UPSOURCE_BACKUPS_DIR`, the path you wish to save your backups to
* `UPSOURCE_LICENSE_USER_NAME`, your Upsource user name (don't specify for trial version)
* `UPSOURCE_LICENSE_KEY`, your Upsource license key (don't specify for trial version)

## Build your image

After completing the `Dockerfile`, you must build the image and give it a valid name in the form of `gcr.io/your-awesome-project-id/my-upsource`:

```shell
docker build -t gcr.io/your-awesome-project-id/my-upsource .
```

This image then needs to be pushed to your private Google Container Repository:

```shell
gcloud docker push gcr.io/your-awesome-project-id/my-upsource
```

## Create the Pod

To run the container, you must create a [Container Pod](https://cloud.google.com/container-engine/docs/pods/multi-container) YAML file (see [example](upsource.yaml)):

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: upsource
  labels:
    name: upsource
spec:
  containers:
    - image: gcr.io/your-awesome-project-id/my-upsource:latest
      name: upsource
      ports:
        - name: http
          hostPort: 8080
          containerPort: 80
      volumeMounts:
          # Name must match the volume name below.
        - name: disk-jetbrains
          # Mount path within the container.
          mountPath: /var/upsource
  volumes:
    - name: disk-jetbrains
      gcePersistentDisk:
        # This GCE persistent disk must already exist.
        pdName: disk-jetbrains
        fsType: ext4
```

The container's volume `mountPath` should contain all of the directories you specified in the environment variables (logs, temp, data, backups), so that they will be persisted on the disk, not the container.

The volume `pdName` must match the disk name you created during the initial setup.

Now, simply create your pod as follows:

```shell
kubectl create -f upsource.yaml
```

Now:

* wait for your pod to enter the `running` state (you can check it via `kubectl get pod upsource`)
* access the service external HTTP address
* profit!

## Uninstall and clean

To uninstall Upsource and remove all the resources from your Google Cloud project, execute the following commands (you may want to change some parameters in it first accordingly to the ones you set in the previous steps):

```shell
gcloud compute firewall-rules delete upsource-world-80 --quiet
kubectl delete service upsource-service
kubectl delete pod upsource
gcloud beta container clusters delete cluster-jetbrains
gcloud compute disks delete jetbrains-disk
```