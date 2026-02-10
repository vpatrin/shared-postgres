#!/bin/bash
# Backup all databases in shared-postgres

set -e

BACKUP_DIR="./backups"
DATE=$(date +%Y%m%d_%H%M%S)

echo "Starting backup at $(date)"

# Create backup directory if it doesn't exist
mkdir -p "$BACKUP_DIR"

# Backup umami database
echo "Backing up umami database..."
docker exec shared-postgres pg_dump -U umami -d umami -F c -f /tmp/umami.dump
docker cp shared-postgres:/tmp/umami.dump "$BACKUP_DIR/umami_$DATE.dump"
echo "✓ Umami backup saved: $BACKUP_DIR/umami_$DATE.dump"

# Backup shortener database
echo "Backing up shortener database..."
docker exec shared-postgres pg_dump -U shortener -d shortener -F c -f /tmp/shortener.dump
docker cp shared-postgres:/tmp/shortener.dump "$BACKUP_DIR/shortener_$DATE.dump"
echo "✓ Shortener backup saved: $BACKUP_DIR/shortener_$DATE.dump"

# Clean up temp files in container
docker exec shared-postgres rm -f /tmp/umami.dump /tmp/shortener.dump

# Show backup sizes
echo ""
echo "Backup Summary:"
ls -lh "$BACKUP_DIR"/*_$DATE.dump

echo ""
echo "Backup completed successfully at $(date)"

# Cleanup: Keep only last 7 days of backups
echo "Cleaning up old backups (keeping last 7 days)..."
find "$BACKUP_DIR" -name "*.dump" -type f -mtime +7 -delete

echo "Total backups in directory:"
ls -lh "$BACKUP_DIR/" | grep dump | wc -l
