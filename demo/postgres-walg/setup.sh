#!/bin/bash

export LICENSE_FILE=$HOME/archiver/postgres/license.txt
export KUBECONFIG=$HOME/Downloads/pg-walg-test-kubeconfig.yaml
export REGISTRY=rakibulhossain

cd $GOPATH/kubedb.dev/pg-walg

# git checkout poc-wal-g

make push

cd $GOPATH/kubedb.dev/postgres-snapshotter-plugin

# git checkout new_branch

make push

# install external-snapshotter

cd $GOPATH/src/github.com/rakibulhossain/external-snapshotter

# git checkout release 5.0

kubectl kustomize client/config/crd | kubectl create -f -
kubectl -n kube-system kustomize deploy/kubernetes/snapshot-controller | kubectl create -f -
kubectl kustomize deploy/kubernetes/csi-snapshotter | kubectl create -f -

helm install longhorn longhorn/longhorn --namespace longhorn-system --create-namespace


# install sidekick

cd $GOPATH/src/kubeops.dev/sidekick/

make push install


# install kubestash

cd $GOPATH/src/kubestash.dev/kubestash

make push uninstall install

cd ../apimachinery

kubectl delete -f crds

kubectl create -f crds

kubectl delete clusterrole kubestash-kubestash-operator

kubectl create -f $HOME/archiver/postgres/kubestash-cluster-role.yaml


# install kubedb 

cd $GOPATH/src/kubedb.dev/postgres

make push install

cd ../apimachinery

kubectl delete -f crds

kubectl create -f crds

cd ../installer


kubectl delete -f catalog/raw/postgres/

kubectl create -f catalog/raw/postgres/