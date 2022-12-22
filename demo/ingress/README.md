# Expose KubeDB managed MySQL server using nginx-ingress controller

## Install KubeDB provisioner operator

helm upgrade -i kubedb appscode/kubedb \
  --version v2022.10.18 \
  --namespace kubedb --create-namespace \
  --set kubedb-provisioner.enabled=true \
  --set kubedb-ops-manager.enabled=false \
  --set kubedb-autoscaler.enabled=false \
  --set kubedb-dashboard.enabled=false \
  --set kubedb-schema-manager.enabled=false \
  --set-file global.license=/Users/tamal/Downloads/kubedb-enterprise-license-3a5e373b-6f97-46cc-ba84-3f040a5d3130.txt

k apply -f mysql.yaml

## Install cert-manager

kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.10.1/cert-manager.yaml

k apply -f issuer.yaml

## Setup Ingress to expose MySQL

k apply -f ingress.yaml

helm upgrade -i ingress-nginx ingress-nginx/ingress-nginx  \
  --namespace demo --create-namespace \
  --set tcp.3306="demo/mysql-quickstart:3306"

## Setup DNS using external-dns (optional)

helm upgrade -i ingress-kubedb external-dns/external-dns \
  -n demo \
  -f external-dns.yaml

## Test connection to MySQL from Developer Workstation

> k view-secret mysql-quickstart-auth --all
password=R9TVFK36CZrmeBTy
username=root

> docker run -it mysql:8 bash

> mysql -h mysql.bytebuilders.xyz -u root -p
> mysql -h mysql.bytebuilders.xyz -u root -p'R9TVFK36CZrmeBTy' 
