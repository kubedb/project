# ocm Demo

```
sudo apt install python-is-python3

sudo sysctl fs.inotify.max_user_instances=65534

clusteradm get token
```

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

> k create ns kubedb
> k create ns kubeops
> clusteradm clusterset bind global --namespace kubedb
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
