# Shared PostgreSQL Instance

One PostgreSQL container serving multiple applications with isolated databases.

## Quick Start

```bash
cd /home/victor/projects/shared-postgres

# Manage
docker compose up -d      # Start
docker compose down       # Stop  
docker compose logs -f    # Logs

# Backup
./backup.sh              # Backup all

# Access
docker exec -it shared-postgres psql -U umami -d umami
docker exec -it shared-postgres psql -U shortener -d shortener
docker exec -it shared-postgres psql -U postgres  # Admin
```

---

## Architecture

```
shared-postgres:16-alpine
├─ umami DB (umami user)
├─ shortener DB (shortener user)  
└─ postgres DB (admin)
```

**Services:**
- Umami Analytics → umami DB
- URL Shortener → shortener DB

**Security:**
- Port 5432 → localhost only (127.0.0.1)
- SSH tunnel required for external access
- Each app has dedicated limited user

---

## Backup & Restore

```bash
# Backup
./backup.sh                    # All databases
# Stored in: ./backups/

# Download to local (important!)
scp -r victor@vps-ip:/home/victor/projects/shared-postgres/backups/ ./

# Restore
docker cp backup.dump shared-postgres:/tmp/
docker exec shared-postgres pg_restore -U umami -d umami -c /tmp/backup.dump
```

## Fresh Deployment

**Init script automatically creates databases/users on first run:**
- `init-scripts/01-init-databases.sh` runs only when volume is empty
- Creates umami + shortener users with passwords from .env
- No manual setup needed for new deployments

---

## Add Service

```bash
# 1. Create DB & user
docker exec -it shared-postgres psql -U postgres
CREATE USER newapp WITH PASSWORD 'secure-pass';
CREATE DATABASE newapp OWNER newapp;
GRANT ALL PRIVILEGES ON DATABASE newapp TO newapp;

# 2. Add to .env
echo "NEWAPP_PASSWORD=secure-pass" >> .env

# 3. Configure app
DATABASE_URL=postgresql://newapp:secure-pass@shared-postgres:5432/newapp
```

---

## Remove Service

```bash
# 1. Backup!
docker exec shared-postgres pg_dump -U myapp -d myapp -F c > final.dump

# 2. Drop
docker exec -it shared-postgres psql -U postgres
DROP DATABASE myapp;
DROP USER myapp;
```

---

## Monitor

```bash
# Databases
docker exec shared-postgres psql -U postgres -c "\l"

# Sizes  
docker exec shared-postgres psql -U postgres -c "
SELECT datname, pg_size_pretty(pg_database_size(datname))
FROM pg_database WHERE datname IN ('umami','shortener');"

# Connections
docker exec shared-postgres psql -U postgres -c "
SELECT datname, usename, count(*) FROM pg_stat_activity GROUP BY 1,2;"
```

---

## Troubleshoot

```bash
# Check running
docker ps | grep shared-postgres

# Check logs
docker logs shared-postgres

# Test connection
docker exec shared-postgres psql -U umami -d umami -c "SELECT 1;"

# Reset password
docker exec shared-postgres psql -U postgres -c "ALTER USER umami WITH PASSWORD 'new';"
```

---

## Schema Changes

Apps manage their own schemas:
- **Umami:** Prisma migrations (auto on restart)
- **Shortener:** SQLAlchemy (auto on restart)
- **Manual:** Connect via DBeaver, backup first

---

## Security

✅ Localhost binding (not internet-facing)
✅ Dedicated non-superuser per app
✅ SSH required for external access
⚠️ Never use postgres user in apps
⚠️ Regular backups + off-site storage

---

**Version:** PostgreSQL 16-alpine
**Location:** `/home/victor/projects/shared-postgres/`
