# KubeDB Enhancement Meeting Notes

#### Backup & Restore Experience

**Date:** 28 December 2022
**Type:** Offline

**Participants:**

- Tamal Saha
- Emruz Hossain

**Decisions:**

- Always backup database Secret and Manifest.
- Always backup database catalog.
- Extend `Archiver` CRD to make it suitable for act as template for various type of backup.
- There shouldn't be any shadow or mandatory backup. User always should have option to opt-out.
- Use a `Halt` like phase for database during restore. This will remove the database from Service endpoint.
- User should be able to chose whether the database should accept connection automatically after restore succeeded or not.
