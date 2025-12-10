-- =============================================================================
-- Initial Database Setup (Example)
-- Executed ONLY on first container initialization (empty data volume)
-- =============================================================================

-- Create application user (optional, adjust as needed)
-- DO $$
-- BEGIN
--     IF NOT EXISTS (SELECT FROM pg_catalog.pg_roles WHERE rolname = 'app_user') THEN
--         CREATE ROLE app_user WITH LOGIN PASSWORD 'changeme';
--     END IF;
-- END
-- $$;

-- Grant permissions (uncomment and adjust after restore)
-- GRANT CONNECT ON DATABASE ncc TO app_user;
-- GRANT USAGE ON SCHEMA public TO app_user;
-- GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO app_user;

-- =============================================================================
-- NOTE: This file runs BEFORE restore. For post-restore setup, run manually.
-- Add extensions here if needed:
-- CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
-- CREATE EXTENSION IF NOT EXISTS "pg_trgm";
-- =============================================================================

-- Placeholder to ensure file is valid SQL
SELECT 'Init script loaded' AS status;
