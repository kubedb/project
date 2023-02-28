# Backup KubeDB managed Databases with KubeStash

In this doc, we are going to note the use-cases, requirements on these various use-cases, possible solutions and the final decisions taken on how backup experience should be with KubeDB and KubeStash.

## Use Cases

We are going to divide use-cases from two perspective. The first one from an admin perspective who is responsible for taking cluster level decisions. The another one is user perspective who is the end user of the database. We will dive into how the experience should be from UI, from CLI and from CI pipeline.

### From Admin Perspective

I am database admin of my organization. I am responsible for managing how databases are deployed, managed by the consumers (different team member, or end user). I have the following requirements for database backup:

1. I want to pre-defined some backup policies where I will define where the backup will be stored, access credentials for the storage, different cleanup policies. In this case, the consumer will have the following options:
   - They can only chose between the pre-configured backup policies (Physical, Incremental, Logical etc.).
   - They should be able to set the schedule for backup.
   - They will have to chose between the cleanup policies I have pre-configured (i.e. last 1 month, last 3 months, daily 1 snapshot etc.).
   - They can view the backup Snapshots and the Repository where they are stored. However, they shouldn't care about or view the underlying backup storage.
   - They can opt-out for backup.

2. I might allow some user to use their own storage to store the backups.

<!-- 3. I want to pre-configure mandatory backup for some critical databases. User can't opt-out from the backup. These backups are fully managed by me. However, user should see the backups and they should be able to recover from them.

4. I want to pre-configure silent backup for some databases. Those backups are used by some analytics or testing tools. So, user don't have to be aware of the backup. The backup shouldn't have any major impact the database performance. They should be hidden from the user. -->

### From User Perspective

I am an user. I can use the database from the UI, CLI or using my CI pipeline. I have the following requirements in various cases:

#### From UI

##### From Database Deployment Wizard

I am provisioning new database. I want to enable backup for my database during provisioning. My requirements are:

1. I should be able to chose which types of backup to enable. I don't care how they are taken. However, I should be informed about how different types of backup will impact my database availability, performance, or recoverability.
2. I should be able to use custom schedule.
3. I should be able to chose/specify a retention policy for the backup.
4. I should be able to use my own Storage when allowed by the admin.

##### From Database Details UI

Similar experience as from database deployment wizard. However, I should be informed if my database will be unavailable during the backup setup.

##### From Dedicated Backup UI

It's not important for me to setup backup for individual database from the dedicated backup UI. I can do it from the database UI. However, I should be able to add Storage and other policy objects like RetentionPolicy, Hooks,Archiver policy etc.

#### From CLI

- I should be able to know the available backup policies for me. There could be APIs that will tell me which policies are available for a database kind and namespace.

### CI Pipeline

- I might put database and all the policy, storage, etc. related resources into same pipeline. I will expect things to work regardless the order of the resources being applied by the pipeline.
- If there is any failure during the entire setup, I will expect it to be reflected into the database phase. My pipeline completion status depends on the database phase.

### Questions

**Should we always backup the database manifest?**
Yes.

**Should we always backup the database Secret?**
Yes.

**Backup respective KubeDB catalog?**

Some user may use custom catalog. We should backup the catalog so that when they restore in a new cluster, the catalog can be re-created.
