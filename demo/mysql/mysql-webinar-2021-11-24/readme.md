# Managing Resilient MySQL Cluster on kubernetes

# Installing KubeDB

`https://kubedb.com/docs/v2021.11.24/setup/install/enterprise/`

```
helm install kubedb appscode/kubedb \
    --version v2021.11.24 \
    --namespace kubedb --create-namespace \
    --set kubedb-enterprise.enabled=true \
    --set kubedb-autoscaler.enabled=true \
    --set-file global.license=/path/to/the/license.txt
```
# Installing Stash
``https://kubedb.com/docs/v2021.11.24/setup/install/enterprise/``
```
helm install stash appscode/stash       \
  --version v2021.10.11                  \
  --namespace kube-system                 \
  --set features.enterprise=true           \
  --set-file global.license=/path/to/the/license.txt
```
