# Backup and PITR Recovery

## Archiver
### Archiver YAML
```yaml
apiVersion: archiver.kubedb.com/v1alpha1
kind: MongoDBArchiver
metadata:
  name: archiver-demo
  namespace: kubedb
spec:
  databases:
    selector: {}
    namespaces:
      from:
      selector: {}
  pause: true
  retentionPolicy:
      name: keep-last-5
      namespace: stash
  fullBackup:
    driver: "CSISnapshotter"
    csiSnapshotter:
      volumeSnapshotClassName: "longhorn-snapshot-vsc"
    scheduler:
      schedule: "0 * * * *"
      concurrencyPolicy: Forbid
      jobTemplate:
        parallelism: 1
        completions: 1
        backoffLimit: 1
        podTemplate:
          serviceAccountName: "my-sample-sa"
    runtimeSettings: <>
    failurePolicy: Retry
    retryConfig:
      maxRetry: 2
      delay: 2m
  walBackup:
    runtimeSettings: <>
    config: <> # rawExtension or different for each?
  backupStorage:
    ref:
      apiGroup: storage.kubestash.com
      kind: BackupStorage
      name: gcs-storage
      namespace: stash
    prefix: "db/$APP_KIND/$APP_NAMESPACE/$APP_NAME"
  deletionPolicy: "Delete" / "WipeOut" / "DoNotDelete"
status:
  phase: "Current" 
  databaseRefs:
    - name: ""
      namespace: ""
      opsReqName: ""
      opsReqPhase: ""
```

### Archiver Controller Steps:
- Add/Update/Sync:
  - Select databases according to `usagePolicy`.
  - Check if each db is configured with the latest archiver (according to the `spec-hash` annotations).
    - if not then configure using OpsRequest CR. 
    	- If any previous ops req is in `Failed` state don't create a new one.
- Delete:
  - according to deletionPolicy create OpsRequest CR.


## Ops Request Changes
### Ops Request YAML
```yaml
apiVersion: ops.kubedb.com/v1alpha1
kind: MongoDBOpsRequest
metadata:
  name: archiver-ops-demo
  namespace: demo
spec:
  type: Backup
  databaseRef:
    name: mg-rs
  archiver:
    operation: "ConfigureArchiver"/ "DisableArchiver"
    ref:
      name: "archiver-demo"
      namespace: "kubedb"
```

### Ops Request Steps
- If `Operation == Configure`
  - Create BackupConfiguration CR
  - Create ArchiveInfo CR
  - Inject walg sidecar
  - Restart pods
  - Update `db.spec.archiver` and `db.status.archiver`
- If `Operation == Disable`
  - Delete BackupConfiguration CR
  - Remove sidecar.
  - Restarts pod.

## DB Changes (For Restore)
### DB YAML
```yaml
apiVersion: kubedb.com/v1alpha2
kind: MongoDB
metadata:
  annotations:
  	archiver.kubedb.com/spec-hash: "dfgdfgdg"
  name: archiver-ops-demo
  namespace: demo
spec:
  archiver:
    pause: true
    ref:
      name: <>
      namespace: <>
  init:
    archiver:
      recoveryTimeStamp: "2020-10-28T01:48:23.121314+03:00"
      repository:
        name: gcs-storage
        namespace: stash
status:
  archiver:
    phase: ""
    conditions: []
```

### DB Controller

#### Backup Steps
- From mutator: 
	- Check if there is any archiver that is selecting this database
	- If yes, then update `db.spec.archiver`
- From db operator:
	- If `db.spec.archiver != nil`
		- Create BackupConfiguration CR
		- Create ArchiveInfo CR
		- Inject walg sidecar
		- Continue with other db reconcilation tasks.

#### Restore Steps
- Get snapshot list and oplog time from backupStorage 
- Pick the snapshot that is before the PITR time
- Restore db using that snapshot 
- Find the closest oplog time before the sanpshot time and closest oplog time from PITR time
- Restore db on that time

## Stash Changes
### ArchiveInfo CR YAML

```yaml
apiVersion: storage.kubestash.com/v1alpha1
kind: Snapshot
metadata:
  name: sample-mongodb-backup-1561974001
  namespace: demo
spec:
  version: v1
  snapshotID: 9m4e2mr0ui3e8a215n4g
  type: IncrementalBackup
  appRef:
    apiGroup: kubedb.com
    kind: MongoDB
    name: sample-mongodb
  repository: sample-mongodb-backup
  deletionPolicy: WipeOut # One of "WipeOut, DoNotDelete"
  snapshotTime:
    created: "2020-07-25T17:41:28Z"
    lastUpdated: "2020-07-25T17:41:28Z"
  components: # Information about individual components
    - name: mongo-sh-0
      path: repository/v1/wal-g/mongo-sh-0 # relative to repository
      phase: Succeeded
      driver: WalG
      walSegment:
        start: 2020-10-28T12:11:10+03:00
        end: 2020-10-28T12:11:10+03:00
```
