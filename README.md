# MySQL-Hacks

The project is created to gather some useful mysql hacks, automate some processes/steps and make the life with MySQL easier.

## DB_Backup.sh

This simple script can take a complete MySQL data backup which can be used for variety of reasons. During it's creation, it was used to create initial dump for replicating the database across different AWS accounts

There are two options inside.
1. Each specific database (schema) within mysql could be created as a separate backup file (which is the default one) OR
2. The whole database can be backed up/dumped into a single file (which is commented by default)

Depending on the need, commenting and uncommenting should help.
