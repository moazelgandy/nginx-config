#!/bin/bash

# MySQL database details
DB_USER="root"
DB_PASS="root"
DB_NAME="faca"

# Backup directory
BACKUP_DIR="/var/www/"

# Telegram bot details
BOT_TOKEN="6006141820:AAEzNq1h2WYeUWReTgEjjq7j_-V558sCGHs"
GROUP_CHAT_ID="-4171668228"  # Replace with the actual chat ID if different

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

    # Define Telegram message
    MESSAGE="Database backup: $BACKUP_FILE"

    # Send message with backup file to the group using curl
    curl -X POST \
      https://api.telegram.org/bot$BOT_TOKEN/sendDocument \
      -F chat_id=$GROUP_CHAT_ID \
      -F document=@$BACKUP_FILE \
      -F caption="Database backup: $BACKUP_FILE" >> /var/www/log_file.log 2>&1

    # Check if Telegram message was sent successfully
    if [ $? -eq 0 ]; then
      echo "Backup sent to Telegram group successfully" >> /var/www/log_file.log
    else
      echo "Error: Failed to send backup to Telegram group" >> /var/www/log_file.log
    fi

  else
    echo "Error: Database backup failed!" >> /var/www/log_file.log
  fi

  # Sleep for 60 minutes
  sleep 300
done
