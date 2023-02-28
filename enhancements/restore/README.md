# Restore KubeDB managed Databases with KubeStash

In this doc, we are going to note the use-cases, requirements on these various use-cases, possible solutions and the final decisions taken on how restore experience should be with KubeDB and KubeStash.

## Use Cases

We are going to use-cases from UI, CLI, and CI perspective.

### From UI

I would expect the following experiences from the UI:

##### From Database Deployment Wizard

I am provisioning new database. I want to initialize it from my backup of my previous database. The backup can be physical or logical. I might have or haven't enabled incremental backup in my previous databases. My requirements are:

1. I want to do a PITR recovery when I have enabled incremental backup data in my previous backup. I just want to give a timestamp up-to which I want to restore.
2. My database was big, so I did only physical backup. I didn't enabled incremental backup. I want to restore from the physical backup. I want to give a Snapshot that I want to restore. UI should suggest me the available Physical snapshots.
3. I have logical backup of my database. I want to restore from it. I want provide a particular Snapshot.

##### From Database Details UI

My database is running. However, I have lost some data accidentally. Now, I want to restore from a backup. My requirements are:

1. I should see the available Snapshot for this database. I just want to point to select a Snapshot that I want to restore.
2. I would expect KubeDB/KubeStash to figure out which process to use a particular Snapshot. As a user, I don't care about the implementation details. I just want my data restored.
3. It is okay to have down time during restore. However, I would expect my database not to accept any connection during the restore process. This should be done automatically.
4. Once the data has been restored, I might want to run some checks before making the database available for the applications. This checks can be manual or automatic.

##### From Dedicated Backup UI

I have a backup of a database. It could be from another cluster, namespace. I am on dedicated backup UI where I can see all the backed up snapshots in my Repository. Now, I want to restore a Snapshot. My requirements are:

1. I just want to point a Snapshot to restore. The database should be deployed automatically with data from this Snapshot.
2. I might want change the name, namespace, storage size, storage class etc. from the original database.

### From CLI

When I restore on a running database, my database should be become unavailable automatically for my applications. I should have a command to make the database available again.

### CI Pipeline

My CI pipeline may apply database and other backup related resources (i.e. BackupStorage) at any order. I will expect to things to work without any issue.

### Questions

**How should we pause and resume database traffic before/after restore?**

There could be a phase like `Halt` (maybe `Down`) in database. In this phase, the operator will remove the database from it's Service endpoint. User can chose during restore whether to automatically resume the connection or user will do it manually.

We may add a extra label in the Service that will cause none of the database pod to get selected. However, we may still need another maintenance Service for our internal usage (i.e. connecting to database shell).
