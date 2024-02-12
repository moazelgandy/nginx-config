#!/bin/bash

# MySQL database details
DB_USER="root"
DB_PASS="root"
DB_NAME="faca"

# Backup directory
BACKUP_DIR="/var/www/"

# Dropbox access token
DROPBOX_ACCESS_TOKEN="$DROPBOX_ACCESS_TOKEN"

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
        
        # Define Dropbox API arguments
        DBX_API_ARG="{\"path\": \"/Backup/$DB_NAME-$TIMESTAMP.sql\",\"mode\": \"add\",\"autorename\": true}"

        # Upload the backup file to Dropbox and log the output
        curl -X POST \
             -H "Authorization: Bearer $DROPBOX_ACCESS_TOKEN" \
             -H "Content-Type: application/octet-stream" \
             -H "Dropbox-API-Arg: $DBX_API_ARG" \
             --data-binary @"$BACKUP_FILE" \
             "https://content.dropboxapi.com/2/files/upload" >> /var/www/log_file.log 2>&1
        
        # Check if the upload was successful
        if [ $? -eq 0 ]; then
            echo "Backup uploaded to Dropbox successfully" >> /var/www/log_file.log
        else
            echo "Error: Failed to upload backup to Dropbox" >> /var/www/log_file.log
        fi
        
    else
        echo "Error: Database backup failed!" >> /var/www/log_file.log
    fi

    # Sleep for 60 minutes
    sleep 300
done
