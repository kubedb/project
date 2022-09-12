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
  usagePolicy:
    allowedNamespace:
      from: <>
      selector: <>
    resourceSelector: <>
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
  opsRequests:
    - appRef: 
        name: ""
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
  type: ConfigureArchiver
  databaseRef:
    name: mg-rs
  archiver:
    operation: "Configure"/ "Disable"
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
      pitr:
        targetTime: ""
        exclusive: true 
      repository:
        name: gcs-storage
        namespace: stash
status:
  archiver:
    phase: ""
    conditions: ""
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
kind: ArchiveInfo
metadata:
  name: sample-mongodb-backup-1561974001
  namespace: demo
spec:
  ulid: 01D78XYFJ1PRM1WPBCBT3VHMNV
  repository: sample-mongodb-backup
  version: v1
  appRef:
    apiGroup: kubedb.com
    kind: MongoDB
    name: sample-mongodb
  deletionPolicy: WipeOut # One of "WipeOut, DoNotDelete"
  paused: true
components:
 - name: mongo-sh-0
   path: db/mongodb/demo/sample-mongo/repository/v1/wal-g/mongo-sh-0
   segments:
   - start: 2020-10-28T12:11:10+03:00
     end: 2020-10-28T12:12:10+03:00
```
