# Shared PostgreSQL

One PostgreSQL container, isolated databases per project. Only `.env` changes between environments.

## Architecture

```text
shared-postgres:16-alpine
├─ umami DB (umami user)         → Umami Analytics
├─ shortener DB (shortener user) → URL Shortener
├─ saq_sommelier DB (saq_sommelier user) → SAQ Sommelier
└─ postgres DB (admin)
```

## Local Dev

```bash
# Start
docker compose up -d

# Access
docker exec -it shared-postgres psql -U saq_sommelier -d saq_sommelier
docker exec -it shared-postgres psql -U umami -d umami
docker exec -it shared-postgres psql -U shortener -d shortener
docker exec -it shared-postgres psql -U postgres  # Admin

# Stop (data preserved)
docker compose down

# Full reset (data deleted, init script re-runs)
docker compose down -v && docker compose up -d
```

**Convention:** database = user = password (e.g. `saq_sommelier` / `saq_sommelier` / `saq_sommelier`)

## Production

Same setup on Hetzner VPS. Only `.env` differs (secure passwords).

```bash
# Deploy
docker compose up -d
# Init script creates all databases on first run

# Backup (all databases, no hardcoding)
docker exec shared-postgres pg_dumpall -U postgres > backup_$(date +%Y%m%d).sql

# Restore
docker cp backup.dump shared-postgres:/tmp/
docker exec shared-postgres pg_restore -U umami -d umami -c /tmp/backup.dump
```

## Add a Database

```bash
# 1. Add to .env and .env.example
NEWAPP_DB_NAME=newapp
NEWAPP_DB_USER=newapp
NEWAPP_DB_PASSWORD=newapp  # secure password in prod

# 2. Add to init-scripts/01-init-databases.sh (copy existing pattern)

# 3. Create on running instance
docker exec -i shared-postgres psql -U postgres <<-EOSQL
    CREATE USER newapp WITH PASSWORD 'newapp';
    CREATE DATABASE newapp OWNER newapp;
    GRANT ALL PRIVILEGES ON DATABASE newapp TO newapp;
EOSQL

# 4. Configure app
DATABASE_URL=postgresql://newapp:newapp@localhost:5432/newapp
```

## Remove a Database

```bash
# 1. Backup first!
docker exec shared-postgres pg_dump -U myapp -d myapp -F c > final.dump

# 2. Drop
docker exec -i shared-postgres psql -U postgres -c "DROP DATABASE myapp;"
docker exec -i shared-postgres psql -U postgres -c "DROP USER myapp;"

# 3. Remove from .env, .env.example, and init script
```

## Quick Checks

```bash
docker ps | grep shared-postgres                          # Running?
docker logs shared-postgres                               # Logs
docker exec shared-postgres psql -U postgres -c "\l"      # Databases
docker exec shared-postgres psql -U postgres -c "\du"     # Users
```

## Schema Changes

Each app manages its own schema:

- **Umami:** Prisma migrations (auto on restart)
- **Shortener:** SQLAlchemy (auto on restart)
- **SAQ Sommelier:** Alembic migrations (manual)

## Data Volume

All database data lives in the `pgdata` Docker volume.

- **`docker compose down`** - Volume preserved, all data intact
- **`docker compose down -v`** - Volume deleted, all data gone
- **Dev:** Safe to reset anytime (`down -v`), init script recreates everything
- **Prod:** Never use `-v` unless you have a backup

```bash
# Inspect volume
docker volume inspect shared-postgres_pgdata

# Volume size
docker system df -v | grep shared-postgres
```

## Files

- **`.env`** - Database credentials (gitignored)
- **`.env.example`** - Template for new environments
- **`init-scripts/`** - Runs on first container start (empty volume only)

**Security:** Port 5432 bound to localhost only. SSH tunnel required for external access. Never use postgres user in apps.
