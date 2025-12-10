# PostgreSQL Restore Environment

🐳 Lightweight Docker-based PostgreSQL for database restoration and local development.

## Features

- ✅ Docker Compose setup with configurable resources
- ✅ Environment-based configuration (`.env`)
- ✅ Optimized restore settings for fast import
- ✅ Comprehensive restore guide with best practices
- ✅ SQL scripts for monitoring restore progress

## Quick Start

```bash
# 1. Clone repository
git clone https://github.com/refatriana31/pg-restore.git
cd pg-restore

# 2. Setup environment
cp .env.example .env
# Edit .env and set POSTGRES_PASSWORD

# 3. Place backup file
cp /path/to/backup.sql.gz ./backups/

# 4. Start container
docker-compose up -d

# 5. Restore database
gunzip -c ./backups/backup.sql.gz | docker exec -i pg_restore psql -U postgres -d restore_db
```

## Configuration

All settings are in `.env`:

| Variable | Default | Description |
|----------|---------|-------------|
| `POSTGRES_USER` | `postgres` | Database user |
| `POSTGRES_PASSWORD` | - | **Required** |
| `POSTGRES_DB` | `restore_db` | Database name |
| `PG_VERSION` | `15` | PostgreSQL version (15, 16, 17) |
| `PG_PORT` | `5432` | Host port (change if conflict) |
| `PG_MEMORY_LIMIT` | `512m` | Container memory limit |
| `PG_CPU_LIMIT` | `1.0` | Container CPU limit |

## Documentation

- [RESTORE_GUIDE.md](./RESTORE_GUIDE.md) - Complete restore instructions with best practices
- [db/check_restore_progress.sql](./db/check_restore_progress.sql) - SQL queries for monitoring

## Project Structure

```
pg-restore/
├── backups/                    # Place backup files here (gitignored)
├── db/
│   ├── init/                   # Init scripts (run on first start)
│   └── check_restore_progress.sql
├── docker-compose.yml
├── .env.example                # Template (copy to .env)
├── .gitignore
├── README.md
└── RESTORE_GUIDE.md
```

## Connection

| Client | Connection String |
|--------|-------------------|
| psql | `psql -h localhost -p 5432 -U postgres -d restore_db` |
| URL | `postgresql://postgres:PASSWORD@localhost:5432/restore_db` |

## License

MIT
