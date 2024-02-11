#!/bin/bash

# MySQL database details
DB_USER="root"
DB_PASS="root"
DB_NAME="faca"

# Backup directory
BACKUP_DIR="/var/www/"

# Dropbox access token
DROPBOX_ACCESS_TOKEN="sl.BvZvWTcKklVBzpR1frPKYwp2vJfkJQEvxui7KjkzkZmO6FUEE5sxex4KYG-0PIKIpOlQm2pQ26vJGbXtRvLslMWtzHunnPDM8yJ2MUvtnqFmoD-qlVly-FN2Sc3Zl04nsvSU0s3-F7w5"

while true; do
    # Timestamp
    TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")

    # Create backup directory if it doesn't exist
    mkdir -p $BACKUP_DIR

    # Backup filename
    BACKUP_FILE="$BACKUP_DIR/$DB_NAME-$TIMESTAMP.sql"

    # Dump the MySQL database
    mysqldump -u$DB_USER -p$DB_PASS $DB_NAME > $BACKUP_FILE

    # Check if the backup was successful
    if [ $? -eq 0 ]; then
        echo "Database backup created successfully: $BACKUP_FILE" >> /var/www/log_file.log
        
        # Upload the backup file to Dropbox
        curl -X POST \
             -H "Authorization: Bearer $DROPBOX_ACCESS_TOKEN" \
             -H "Content-Type: application/octet-stream" \
             --data-binary @"$BACKUP_FILE" \
             "https://content.dropboxapi.com/2/files/upload" > /dev/null
        
        # Check if the upload was successful
        if [ $? -eq 0 ]; then
            echo "Backup uploaded to Dropbox successfully"
        else
            echo "Error: Failed to upload backup to Dropbox"
        fi
        
    else
        echo "Error: Database backup failed!" >> /var/www/log_file.log
    fi

    # Sleep for 60 seconds
    sleep 60
done
