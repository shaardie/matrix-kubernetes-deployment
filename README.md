# Matrix Kubernetes Deployment

This repository contains the necessary files to setup Matrix on Kubernetes.

There are severeal things missing for production-ready usage, like proper passwords, mtls encryption, resource limits and high avaiable databases, but it is a good starting point.

## Useful Links

* https://microk8s.io/docs
* https://github.com/jetstack/cert-manager
* https://cert-manager.io/docs/
* https://hub.docker.com/_/postgres
* https://github.com/matrix-org/synapse/blob/develop/docs/postgres.md
* https://hub.docker.com/_/redis
* https://hub.docker.com/r/vectorim/element-web
* https://hub.docker.com/r/matrixdotorg/synapse
* https://github.com/matrix-org/synapse/blob/develop/docs/workers.md

## Example Usage

```bash
##################################
# Setup a Kubernetes Environment #
##################################

# Spin up a VM with Vagrant
vagrant init generic/ubuntu2010
vagrant up --provider libvirt
vagrant ssh

# Install microk8s
sudo snap install microk8s --classic

# Allow vagrant user to use microk8s
sudo usermod -a -G microk8s vagrant
sudo chown -f -R vagrant ~/.kube
newgrp microk8s

# Configure microk8s
microk8s status --wait-ready
microk8s enable dns ingress storage metrics-server

# Get kubectl config
microk8s config

########################################
# Install cert-manager with selfsigned #
########################################
helm repo add jetstack https://charts.jetstack.io
helm repo update
helm upgrade --install --namespace cert-manager --create-namespace -f cert-manager/cert-manager.yaml cert-manager jetstack/cert-manager
kubectl apply -f cert-manager/letsencrypt.yaml

#############################
# Namespace
#############################
kubectl create namespace matrix

#############################
# Install minimal Databases #
#############################

# Install postgresql
kubectl -n matrix apply -f postgresql

# Install Redis
kubectl -n matrix apply -f redis

##################
# Install Matrix #
##################

# Install element
kubectl -n matrix apply -f element

# Generate Synapse config
mkdir config
docker run -it --rm \
    -e SYNAPSE_SERVER_NAME=matrix.haardiek.org \
    -e SYNAPSE_CONFIG_DIR=/config \
    -e SYNAPSE_DATA_DIR=/data \
    -e SYNAPSE_REPORT_STATS=no \
    -e UID=$(id -u) \
    -e GID=$(id -g) \
    -v "$PWD/config:/config" \
    matrixdotorg/synapse:latest \
    generate
patch -p0 config/homeserver.yaml < homerserver.patch
kubectl -n matrix create secret generic main --from-file config -o yaml --dry-run=client >> synapse/generated-secrets.yaml

# Install Synapse
kubectl -n matrix apply -f synapse

# Register new user
kubectl -n matrix exec -it "$(kubectl -n matrix get pods --no-headers -o custom-columns=":metadata.name" -l app.kubernetes.io/instance=matrix,app.kubernetes.io/name=synapse-main)" -c synapse -- register_new_matrix_user -c /config/homeserver.yaml http://synapse-main:80
```
