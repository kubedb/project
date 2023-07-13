# ocm Demo

## CLIs

- kind
- kubectl
- helm
- clusteradm

```
sudo apt install python-is-python3

sudo sysctl fs.inotify.max_user_instances=65534

clusteradm get token
```

```
kind create cluster --name=hub
kind create cluster --name=c1
kind create cluster --name=c2

kind export kubeconfig --name=hub
```

```
# Install FluxCD
helm upgrade -i flux flux2 \
  --repo https://fluxcd-community.github.io/helm-charts \
  --namespace flux-system --create-namespace \
  --set helmController.create=true \
  --set-string helmController.labels."byte\.builders/managed=true" \
  --set sourceController.create=true \
  --set-string sourceController.labels."byte\.builders/managed=true" \
  --set imageAutomationController.create=false \
  --set imageReflectionController.create=false \
  --set kustomizeController.create=false \
  --set notificationController.create=false \
  --wait --debug --burst-limit=10000
```

```
clusteradm init --wait
```

- https://open-cluster-management.io/concepts/manifestworkreplicaset/#release-and-enable-feature

## Clustersets

```
clusteradm create clusterset app1
clusteradm clusterset set app1 --clusters c1

clusteradm create clusterset app2
clusteradm clusterset set app2 --clusters c2

k create ns app1
clusteradm clusterset bind app1 --namespace app1

k create ns app2
clusteradm clusterset bind app2 --namespace app2

> k create ns kubeops
> clusteradm clusterset bind global --namespace kubeops

> clusteradm get clustersets
```

```
<ManagedClusterSet> 
└── <app2> 
│   ├── <BoundNamespace> app2
│   ├── <Status> 1 ManagedClusters selected
│   ├── <Clusters> [c2]
└── <default> 
│   ├── <BoundNamespace> 
│   ├── <Status> No ManagedCluster selected
│   ├── <Clusters> []
└── <global> 
│   ├── <BoundNamespace> kubedb,kubeops
│   ├── <Status> 2 ManagedClusters selected
│   ├── <Clusters> [c1 c2]
└── <app1> 
    └── <BoundNamespace> app1
    └── <Status> 1 ManagedClusters selected
    └── <Clusters> [c1]
```
