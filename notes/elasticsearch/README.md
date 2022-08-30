# Elasticsearch

## Debugging Commands

### Health

- Check cluster health status
  
```bash
$ curl -XGET -k -u 'admin:v1CX*BN$~xTFUNyz' "https://localhost:9200/_cluster/health?pretty"
```

- Shard status:

```bash
$ curl -XGET -k -u 'admin:v1CX*BN$~xTFUNyz' "https://localhost:9200/_cluster/health?filter_path=status,*_shards?pretty"
```

- If the Health status is Yellow or Red, Check shard allocation

```bash
$ curl -XGET -k -u 'admin:9nooN;Y78(Xh~ZmS' "localhost:9200/_cat/indices?v"
```

- If there is a problem in shard allocation try to explain the allocation API

```bash
$ curl -XGET -k -u 'admin:v1CX*BN$~xTFUNyz' "https://localhost:9200/_cluster/allocation/explain?pretty"
```

### Heap

- You can also use the cat nodes API to get the current `heap.percent` for each node.
  
```
$ curl -XGET -k -u 'admin:v1CX*BN$~xTFUNyz' "https://localhost:9200/_cat/nodes?v=true&h=name,node*,heap*"
```

### Breaker

- breaker status:
  
```bash
curl -XGET -k -u 'admin:v1CX*BN$~xTFUNyz' "https://localhost:9200/_nodes/stats/breaker?pretty"
```

- Clear Cache:

```bash
$ curl -XPOST -k -u 'admin:v1CX*BN$~xTFUNyz' "https://localhost:9200/_cache/clear?fielddata=true"
```

- Update limit:

```bash  
$ curl -XPUT -k 'https://localhost:9200/_cluster/settings' -d '{ "persistent" : { "indices.breaker.total.limit" : "70%" } }'
```

- [Circuit Breaker Issue](https://github.com/kubedb/project/issues/836)

### Setting

- Index setting:

```bash
$ curl -XGET -k -u 'admin:v1CX*BN$~xTFUNyz' "https://localhost:9200/.opendistro_security/_settings?pretty"
```

- List index template:

```bash
$ curl -XGET -k -u 'admin:v1CX*BN$~xTFUNyz' "https://localhost:9200/_index_template?pretty"
```

- List specific index template:

    /_index_template/<index-template>

- Check the mapping:

```bash
$ curl -XGET -k -u 'admin:v1CX*BN$~xTFUNyz' "https://localhost:9200/.opendistro_security/_mapping?pretty"
```