#!/bin/bash
# PostgreSQL backup script

BACKUP_DIR="/tmp/postgres_backup_$(date +%Y%m%d_%H%M%S)"
mkdir -p $BACKUP_DIR

echo "=== BACKING UP POSTGRESQL DATABASES ==="

# Get list of databases
DBS=$(sudo -u postgres psql -t -c "SELECT datname FROM pg_database WHERE datname NOT IN ('template0', 'template1', 'postgres');")

for db in $DBS; do
    echo "Backing up database: $db"
    sudo -u postgres pg_dump $db > "$BACKUP_DIR/${db}.sql"
done

# Create archive
tar -czf postgres_backup_$(date +%Y%m%d_%H%M%S).tar.gz -C /tmp $(basename $BACKUP_DIR)
echo "Backup created: postgres_backup_$(date +%Y%m%d_%H%M%S).tar.gz"
echo "Location: $(pwd)"

# List backup contents
echo ""
echo "=== BACKUP CONTENTS ==="
ls -lh $BACKUP_DIR/
