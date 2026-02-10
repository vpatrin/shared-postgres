# Quick Reference

## Start/Stop
```bash
cd /home/victor/projects/shared-postgres
docker compose up -d         # Start
docker compose down          # Stop
docker compose restart       # Restart
docker compose logs -f       # Logs
```

## Access
```bash
# CLI
docker exec -it shared-postgres psql -U umami -d umami
docker exec -it shared-postgres psql -U shortener -d shortener
docker exec -it shared-postgres psql -U postgres  # Admin
```

## Backup
```bash
./backup.sh                  # All databases

# Manual
docker exec shared-postgres pg_dump -U umami -d umami -F c > umami.dump
```

## Restore
```bash
docker cp backup.dump shared-postgres:/tmp/
docker exec shared-postgres pg_restore -U umami -d umami -c /tmp/backup.dump
```

## Quick Checks
```bash
docker ps | grep shared-postgres                          # Running?
docker exec shared-postgres psql -U postgres -c "\l"     # Databases
docker exec shared-postgres psql -U postgres -c "\du"    # Users
```

## Add Service
```sql
-- As postgres user
CREATE USER newapp WITH PASSWORD 'password';
CREATE DATABASE newapp OWNER newapp;
GRANT ALL PRIVILEGES ON DATABASE newapp TO newapp;
```

## Files
- **.env** - All passwords
- **README.md** - Full guide
- **backup.sh** - Backup script
