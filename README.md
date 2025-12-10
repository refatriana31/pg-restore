# PostgreSQL Restore Environment

Lightweight Docker-based PostgreSQL for database restoration and local development.

## Quick Start

```bash
# 1. Check port availability
lsof -i :5432 || echo "Port available"

# 2. Setup environment
cp .env.example .env
# Edit .env: set POSTGRES_PASSWORD and adjust PG_PORT if needed

# 3. Place backup file
cp /path/to/backup.sql.gz ./backups/

# 4. Start container
docker-compose up -d

# 5. Wait for healthy status
docker-compose ps  # Should show "healthy"
```

## Restore Commands

### For `.sql.gz` (compressed SQL):
```bash
gunzip -c ./backups/backupncc_2025_08_05T16_51_15.sql.gz | docker exec -i pg_restore psql -U postgres -d ncc
```

### For `.dump` (custom format, parallel restore):
```bash
docker exec -i pg_restore pg_restore -U postgres -d ncc -j 4 --verbose < ./backups/backup.dump
```

## Post-Restore Checklist

```bash
# Analyze statistics
docker exec pg_restore psql -U postgres -d ncc -c "ANALYZE VERBOSE;"

# Check database size
docker exec pg_restore psql -U postgres -d ncc -c "SELECT pg_size_pretty(pg_database_size('ncc'));"
```

## Reset Environment

```bash
docker-compose down -v  # Removes container AND data volume
```

## Maintenance Notes

- **Version upgrades**: Change `PG_VERSION` in `.env` (15→16→17)
- **Extensions**: Add to `db/init/01-create-app-user.sql`
- **Security**: Never commit `.env` with real passwords
- **Production**: Use managed database, enable SSL, configure WAL archiving
