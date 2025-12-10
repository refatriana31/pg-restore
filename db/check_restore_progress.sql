-- =============================================================================
-- PostgreSQL Restore Monitoring & Health Check
-- Jalankan query ini di DBeaver untuk monitor proses restore
-- =============================================================================

-- 1. CEK AKTIVITAS/PROSES YANG SEDANG BERJALAN
SELECT 
    pid,
    usename,
    application_name,
    state,
    query_start,
    NOW() - query_start AS duration,
    LEFT(query, 80) AS query_preview
FROM pg_stat_activity 
WHERE datname = 'ncc-local'
  AND state != 'idle'
ORDER BY query_start;

-- 2. CEK UKURAN DATABASE
SELECT 
    datname AS database_name,
    pg_size_pretty(pg_database_size(datname)) AS size
FROM pg_database 
WHERE datname = 'ncc-local';

-- 3. CEK UKURAN SEMUA TABEL (jalankan setelah restore selesai)
SELECT 
    schemaname AS schema,
    tablename AS table,
    pg_size_pretty(pg_total_relation_size(schemaname || '.' || tablename)) AS total_size,
    pg_size_pretty(pg_relation_size(schemaname || '.' || tablename)) AS data_size
FROM pg_tables 
WHERE schemaname = 'public'
ORDER BY pg_total_relation_size(schemaname || '.' || tablename) DESC
LIMIT 20;

-- 4. CEK JUMLAH TABEL YANG SUDAH DIBUAT
SELECT COUNT(*) AS total_tables 
FROM pg_tables 
WHERE schemaname = 'public';

-- 5. CEK APAKAH ADA LOCK/BLOCKING
SELECT 
    blocked.pid AS blocked_pid,
    blocked.usename AS blocked_user,
    blocking.pid AS blocking_pid,
    blocking.usename AS blocking_user,
    LEFT(blocked.query, 50) AS blocked_query
FROM pg_stat_activity blocked
JOIN pg_stat_activity blocking 
    ON blocking.pid = ANY(pg_blocking_pids(blocked.pid))
WHERE blocked.datname = 'ncc-local';
