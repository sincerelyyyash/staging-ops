#!/bin/bash

DB_NAME=$(yq eval '.cms.application.name' /staging-ops/prod/cms/application.yml)
DB_USER=$(yq eval '.cms.application.user' /staging-ops/prod/cms/application.yml)
DB_PASSWORD=$(yq eval '.cms.application.password' /staging-ops/prod/cms/application.yml)
BACKUP_DIR="/backup/directory"
DATE=$(date +"%Y%m%d_%H%M%S")
BACKUP_FILE="$BACKUP_DIR/${DB_NAME}_$DATE.sql"


mkdir -p "$BACKUP_DIR"


if [[ ! -d "$BACKUP_DIR" ]]; then
    echo "Failed to create backup directory: $BACKUP_DIR" >> /staging-ops/backup.log
    exit 1
fi


if mysqldump -u "$DB_USER" -p"$DB_PASSWORD" "$DB_NAME" > "$BACKUP_FILE"; then
    echo "Backup successful: $BACKUP_FILE" >> /staging-ops/backup.log
else
    echo "Database backup failed!" >> /staging-ops/backup.log
    exit 1
fi


if command -v bunny &> /dev/null; then
    bunny upload --path "$BACKUP_FILE" "bunny_storage_path" >> /staging-ops/backup.log 2>&1
else
    echo "Bunny CLI is not installed. Backup upload skipped." >> /staging-ops/backup.log
fi


rm -f "$BACKUP_FILE"
echo "Local backup file removed: $BACKUP_FILE" >> /staging-ops/backup.log
