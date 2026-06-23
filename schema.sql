-- ============================================================================
-- schema.sql
-- Run this once after creating the "uk_jobs_db" database to set up the tables.
-- The notebooks (04, 05, 06) will create/replace these automatically when run,
-- but this file documents the exact structure for reference and manual setup.
-- ============================================================================

-- Main jobs table — built by 04_sql_export.ipynb
CREATE TABLE IF NOT EXISTS jobs (
    job_id              TEXT PRIMARY KEY,
    job_title           TEXT,
    company             TEXT,
    company_location    TEXT,
    country             TEXT,
    employment_type     TEXT,
    work_type           TEXT,
    is_remote           BOOLEAN,
    date_posted         TIMESTAMP,
    salary_usd          NUMERIC,
    experience_category TEXT,
    role_category       TEXT,
    company_size_clean  TEXT,
    benefits_score      NUMERIC,
    job_description     TEXT
);

-- Skills table — built by 05_skills_table_creation.ipynb
-- One row per (job, skill) pair found in the job description
CREATE TABLE IF NOT EXISTS job_skills (
    job_id               TEXT REFERENCES jobs (job_id),
    skill                TEXT,
    role                 TEXT,
    experience_category  TEXT,
    salary_usd           NUMERIC
);

-- Live jobs table — built by 06_live_jobs_sql_export.ipynb
-- Refreshed each time collect_live_jobs.py is re-run
CREATE TABLE IF NOT EXISTS live_jobs (
    job_id           TEXT PRIMARY KEY,
    job_title        TEXT,
    company          TEXT,
    location         TEXT,
    country          TEXT,
    employment_type  TEXT,
    job_description  TEXT,
    date_posted      TIMESTAMP,
    job_url           TEXT,
    publisher        TEXT,
    is_remote        BOOLEAN,
    is_remote_flag   INTEGER,
    salary_min       NUMERIC,
    salary_max       NUMERIC,
    salary_period    TEXT,
    search_query     TEXT,
    role_category    TEXT,
    api_source       TEXT
);

-- Helpful indexes for the queries in analysis_queries.sql
CREATE INDEX IF NOT EXISTS idx_jobs_role_category ON jobs (role_category);
CREATE INDEX IF NOT EXISTS idx_jobs_work_type ON jobs (work_type);
CREATE INDEX IF NOT EXISTS idx_job_skills_skill ON job_skills (skill);
CREATE INDEX IF NOT EXISTS idx_live_jobs_role_category ON live_jobs (role_category);
