#!/bin/bash

# Name of the backup. Append current date (yyyymmdd format) to it.
BACKUP_FILE="backup-$(date +%Y%m%d).tar.gz"

# The source directory (What to backup)
SOURCE_DIR="/path/to/source"

# The destination directory (Where to store the backup)
DEST_DIR="/path/to/destination"

# Create the backup directory if it doesn't exist
mkdir -p $DEST_DIR

# Change to the source directory
cd $SOURCE_DIR

# Create the backup
tar -cpzf $DEST_DIR/$BACKUP_FILE .


## Make sure the script is executable:
# chmod +x backup.sh

## Schedule the script via a cron job (daily at 1am):
# crontab -e
# 0 1 * * * /path/to/backup.sh