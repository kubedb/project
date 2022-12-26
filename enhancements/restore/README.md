# Backup KubeDB managed Databases with KubeStash

## Use Cases

### From UI

#### From Database Deployment Wizard

I am provisioning new database. I want to initialize it from my backup of my previous database. The backup can be physical or logical. I might have or haven't enabled incremental backup in my previous databases. My requirements are:

1. I want to do a PITR recovery when I have enabled incremental backup data in my previous backup. I just want to give a timestamp up to which I want to restore.
2. My database was big, so I did only physical backup. I didn't enabled incremental backup. I want to restore from the physical backup. I wan't to give a Snapshot that I want to restore. UI should suggest me the available Physical snapshots.
3. I have logical backup of my database. I wan't to restore from it. I wan't provide a particular Snapshot.

#### From Database Details UI

#### From Dedicated Backup UI

### From CLI

#### During Provisioning

#### On Running Database

#### Using CI Pipeline
