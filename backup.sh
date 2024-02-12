#!/bin/bash

# Download and install Backblaze B2 command-line tool
sudo apt-get -y install backblaze-b2

# Authorize Backblaze B2 account
sudo b2 authorize-account 005f539db404da40000000001 K005RFePkWVwW+nIP3x0YyqdGbpNG68

# Create backup script
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

while true; do
    # Timestamp
    TIMESTAMP=\$(date +"%Y-%m-%d_%H-%M-%S")

    # Create backup directory if it doesn't exist
    mkdir -p \$BACKUP_DIR

    # Backup filename
    BACKUP_FILE="\$BACKUP_DIR/\$DB_NAME-\$TIMESTAMP.sql"

    # Dump the MySQL database
    mysqldump -u\$DB_USER -p\$DB_PASS \$DB_NAME > \$BACKUP_FILE

    # Check if the backup was successful
    if [ \$? -eq 0 ]; then
        echo "Database backup created successfully: \$BACKUP_FILE"

        # Upload backup to Backblaze B2
        sudo b2 upload-file \$BUCKET_NAME \$BACKUP_FILE \$DESTINATION_FOLDER\$DB_NAME-\$TIMESTAMP.sql
        if [ \$? -eq 0 ]; then
            echo "Backup uploaded to Backblaze B2 successfully"
        else
            echo "Error: Failed to upload backup to Backblaze B2"
        fi
    else
        echo "Error: Database backup failed!"
    fi

    # Sleep for 5 minutes
    sleep 300
done
EOF

# Make backupSql.sh executable
chmod +x backupSql.sh
sudo rm /etc/systemd/system/backup.service
cat <<EOF | sudo tee /etc/systemd/system/backup.service > /dev/null
[Unit]
Description=Database Backup Service
After=network.target

[Service]
Type=simple
ExecStart=/bin/bash /home/ss/backupSql.sh

[Install]
WantedBy=multi-user.target
EOF

# Reload systemd
sudo systemctl daemon-reload

# Enable and start the backup service
sudo systemctl enable backup.service
sudo systemctl start backup.service
