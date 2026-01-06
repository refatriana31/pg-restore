# 📥 Panduan Restore Database PostgreSQL

Panduan lengkap untuk merestore database dari file backup ke container PostgreSQL.

---

## 🚀 Quick Start

```bash
# 1. Copy file backup ke folder backups/
cp /path/to/your/backup.sql.gz ./backups/

# 2. Pastikan container running
docker-compose up -d

# 3. Restore (ganti nama file sesuai kebutuhan)
gunzip -c ./backups/your_backup.sql.gz | docker exec -i pg_restore psql -U ncc_admin -d ncc-local
```

---

## 📋 Langkah Detail

### 1. Persiapan

```bash
# Cek container status
docker-compose ps

# Jika belum running
docker-compose up -d

# Tunggu sampai healthy
docker exec pg_restore pg_isready -U ncc_admin
```

### 2. Buat Database Baru (Opsional)

Jika ingin restore ke database baru (bukan `ncc-local`):

```bash
# Buat database baru
docker exec pg_restore psql -U ncc_admin -d postgres -c "CREATE DATABASE nama_db_baru;"

# Restore ke database baru
gunzip -c ./backups/backup.sql.gz | docker exec -i pg_restore psql -U ncc_admin -d nama_db_baru

# Restore dengan progress
pv ./backups/backup.sql.gz | gunzip -c | docker exec -i pg_restore psql -U ncc_admin -d nama_db_baru
```

### 3. Optimasi Sebelum Restore (Rekomendasi untuk file besar)

```bash
# Apply tuning untuk restore cepat
docker exec pg_restore psql -U ncc_admin -d nama_db_baru -c "ALTER SYSTEM SET maintenance_work_mem = '256MB';"
docker exec pg_restore psql -U ncc_admin -d nama_db_baru -c "ALTER SYSTEM SET synchronous_commit = off;"
docker exec pg_restore psql -U ncc_admin -d nama_db_baru -c "ALTER SYSTEM SET autovacuum = off;"
docker exec pg_restore psql -U ncc_admin -d nama_db_baru -c "ALTER SYSTEM SET fsync = off;"
docker exec pg_restore psql -U ncc_admin -d nama_db_baru -c "ALTER SYSTEM SET full_page_writes = off;"
docker exec pg_restore psql -U ncc_admin -d nama_db_baru -c "SELECT pg_reload_conf();"
```

### 4. Jalankan Restore

#### Format `.sql.gz` (compressed SQL):
```bash
gunzip -c ./backups/backup.sql.gz | docker exec -i pg_restore psql -U ncc_admin -d ncc-local
```

#### Format `.dump` (custom format, parallel restore):
```bash
docker exec -i pg_restore pg_restore -U ncc_admin -d ncc-local -j 4 --verbose < ./backups/backup.dump
```

### 5. Reset Settings Setelah Restore

```bash
docker exec pg_restore psql -U ncc_admin -d ncc-local -c "ALTER SYSTEM RESET ALL;"
docker exec pg_restore psql -U ncc_admin -d ncc-local -c "SELECT pg_reload_conf();"
```

### 6. Post-Restore Optimization

```bash
# Analyze untuk update statistics
docker exec pg_restore psql -U ncc_admin -d ncc-local -c "ANALYZE VERBOSE;"

# Cek ukuran database
docker exec pg_restore psql -U ncc_admin -d ncc-local -c "SELECT pg_size_pretty(pg_database_size('ncc-local'));"

# Cek jumlah tabel
docker exec pg_restore psql -U ncc_admin -d ncc-local -c "SELECT COUNT(*) FROM pg_tables WHERE schemaname = 'public';"
```

---

## 🔄 Reset & Mulai Ulang

Jika perlu reset total dan restore ulang:

```bash
# Stop dan hapus semua data
docker-compose down -v

# Start fresh
docker-compose up -d

# Restore lagi
gunzip -c ./backups/backup.sql.gz | docker exec -i pg_restore psql -U ncc_admin -d ncc-local
```

---

## 📊 Monitoring Restore

Jalankan di DBeaver atau psql untuk monitor progress:

```sql
-- Cek aktivitas restore
SELECT pid, state, NOW() - query_start AS duration, LEFT(query, 60) AS query
FROM pg_stat_activity WHERE datname = 'ncc-local' AND state != 'idle';

-- Cek ukuran database (refresh berkala)
SELECT pg_size_pretty(pg_database_size('ncc-local')) AS size;

-- Cek jumlah tabel
SELECT COUNT(*) AS tables FROM pg_tables WHERE schemaname = 'public';
```

---

## 🔗 Koneksi Database

| Client | Connection String |
|--------|-------------------|
| **psql** | `psql -h localhost -p 15432 -U ncc_admin -d ncc-local` |
| **DBeaver** | Host: `localhost`, Port: `15432`, User: `ncc_admin`, DB: `ncc-local` |
| **Application** | `postgresql://ncc_admin:PASSWORD@localhost:15432/ncc-local` |

---

## ⚠️ Troubleshooting

| Masalah | Solusi |
|---------|--------|
| Port conflict | Ubah `PG_PORT` di `.env` (e.g., `25432`) |
| Permission denied | Cek ownership file backup |
| Out of memory | Kurangi `PG_MEMORY_LIMIT` di `.env` |
| Restore lambat | Apply tuning di langkah 3 |

---

## 📁 Struktur Folder

```
pg-restore/
├── backups/              ← Taruh file backup di sini
│   ├── backup1.sql.gz
│   └── backup2.dump
├── db/
│   ├── init/             ← Script init (run on first start)
│   └── check_restore_progress.sql
├── docker-compose.yml
├── .env                  ← Konfigurasi (JANGAN commit!)
├── .env.example
└── RESTORE_GUIDE.md      ← File ini
```
