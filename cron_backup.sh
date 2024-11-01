
if ! crontab -l | grep -q "/staging-ops/backup_db.sh"; then
    (crontab -l 2>/dev/null; echo "0 0 * * * /staging-ops/backup_db.sh >> /staging-ops/backup.log 2>&1") | crontab -
    echo "Cron job added: /staging-ops/backup_db.sh" >> /staging-ops/backup.log
else
    echo "Cron job already exists for: /staging-ops/backup_db.sh" >> /staging-ops/backup.log
fi
