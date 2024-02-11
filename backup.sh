#!/bin/bash

# MySQL database details
DB_USER="root"
DB_PASS="root"
DB_NAME="faca"

# Backup directory
BACKUP_DIR="/var/www/"

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
    else
        echo "Error: Database backup failed!" >> /var/www/log_file.log
        # Send email notification
        mail -s "Database backup failed!" /var/www/log_file.log
    fi

    # Sleep for 60 seconds
    sleep 60
done
