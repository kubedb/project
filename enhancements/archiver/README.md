# Backup and PITR Recovery

## Archiver
### Archiver YAML
```yaml
apiVersion: archiver.kubedb.com/v1alpha1
kind: Archiver
metadata:
  name: archiver-demo
  namespace: kubedb
spec:
  usagePolicy:
    allowedNamespace:
      from:
      selector:
    allowedApplications: // empty means all
    - apiGroup: kubedb.com/v1alpha1
      resources: [ mongodbs,elasticsearches]
      selector: // label selector
  pause: true
  fullBackup:
    driver: "CSISnapshotter"
    csiSnapshotter:
      volumeSnapshotClassName: "longhorn-snapshot-vsc"
    retentionPolicy:
      name: keep-last-5
      namespace: stash
    scheduler:
      schedule: "0 * * * *"
      concurrencyPolicy: Forbid
      jobTemplate:
        parallelism: 1
        completions: 1
        backoffLimit: 1
        podTemplate:
          serviceAccountName: "my-sample-sa"
    runtimeSettings:
    failurePolicy: Retry
    retryConfig:
      maxRetry: 2
      delay: 2m
  walBackup:
    runtimeSettings:
    config: (rawExtension)
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
  failedOpsReq:
    - appRef: 
      kind: ""
      reason: ""
```

### Archiver Controller Steps:
- Add/Update/Sync:
  - Select databases according to `usagePolicy`.
  - Check if archiver is configured for each db.
    - if not then configure using OpsRequest CR.
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
  - Update `db.status.archiverResourceVersion`
- If `Operation == Disable`
  - Delete BackupConfiguration CR
  - Remove sidecar.
  - Restarts pod.

## DB Changes (For Restore)
### DB YAML
```yaml
spec:
  disableArchiver: true
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
    resourceVersion: ""
    lastOpsReqStatus: ""
```

### DB Controller Steps
- Get snapshot list and oplog time from backupStorage 
- Pick the snapshot that is before the PITR time
- Restore db using that snapshot 
- Find the closest oplog time before the sanpshot time and closest oplog time from PITR time
- Restore db on that time

## Stash Changes
### ArchiverInfo CR YAML
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
