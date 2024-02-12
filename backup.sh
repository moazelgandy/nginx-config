#!/bin/bash

# Full path to the b2 executable
B2_EXECUTABLE="/usr/bin/b2"

# Download and install Backblaze B2 command-line tool
sudo apt-get -y install backblaze-b2

# Authorize Backblaze B2 account
sudo $B2_EXECUTABLE authorize-account 005f539db404da40000000001 K005RFePkWVwW+nIP3x0YyqdGbpNG68

# Create backup script with logfile
cat <<EOF > /home/ss/backupSql.sh
#!/bin/bash

# MySQL database details
DB_USER="root"
DB_PASS="root"
DB_NAME="faca"

# Backup directory
BACKUP_DIR="/var/www/"

# Backblaze B2 bucket name and destination folder
BUCKET_NAME="EDU-DB-BackUp"
DESTINATION_FOLDER="backups/"

# Log file
LOG_FILE="/var/www/backup.log"

while true; do
    # Timestamp
    TIMESTAMP=\$(date +"%Y-%m-%d_%H-%M-%S")

    # Create backup directory if it doesn't exist
    mkdir -p \$BACKUP_DIR

    # Backup filename
    BACKUP_FILE="\$BACKUP_DIR/\$DB_NAME-\$TIMESTAMP.sql"

    # Dump the MySQL database and log output
    mysqldump -u\$DB_USER -p\$DB_PASS \$DB_NAME > \$BACKUP_FILE 2>> \$LOG_FILE

    # Check if the backup was successful
    if [ \$? -eq 0 ]; then
        echo "Database backup created successfully: \$BACKUP_FILE" >> \$LOG_FILE

        # Upload backup to Backblaze B2
        sudo b2 upload-file \$BUCKET_NAME \$BACKUP_FILE \$DESTINATION_FOLDER\$DB_NAME-\$TIMESTAMP.sql 2>> \$LOG_FILE
        if [ \$? -eq 0 ]; then
            echo "Backup uploaded to Backblaze B2 successfully" >> \$LOG_FILE
        else
            echo "Error: Failed to upload backup to Backblaze B2" >> \$LOG_FILE
        fi
    else
        echo "Error: Database backup failed!" >> \$LOG_FILE
    fi

    # Sleep for 5 minutes
    sleep 300
done
EOF

# Make backupSql.sh executable
chmod +x /home/ss/backupSql.sh
