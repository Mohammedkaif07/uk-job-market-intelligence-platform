-- ============================================================================
-- analysis_queries.sql
-- UK Job Market Intelligence Platform — Core Analysis Queries
--
-- These queries run against the PostgreSQL tables created by:
--   04_sql_export.ipynb          -> jobs table
--   05_skills_table_creation.ipynb -> job_skills table
--   06_live_jobs_sql_export.ipynb  -> live_jobs table
-- ============================================================================


-- 1. Total number of jobs collected
-- --------------------------------------------------------------------------
SELECT COUNT(*) AS total_jobs
FROM jobs;


-- 2. Job count and average salary by role category
-- --------------------------------------------------------------------------
SELECT
    role_category,
    COUNT(*) AS total_jobs,
    ROUND(AVG(salary_usd), 2) AS avg_salary
FROM jobs
GROUP BY role_category
ORDER BY avg_salary DESC;


-- 3. Job count and average salary by work type (On-site / Hybrid / Remote)
-- --------------------------------------------------------------------------
SELECT
    work_type,
    COUNT(*) AS total_jobs,
    ROUND(AVG(salary_usd), 2) AS avg_salary
FROM jobs
GROUP BY work_type
ORDER BY total_jobs DESC;


-- 4. Job count and average salary by experience level
-- --------------------------------------------------------------------------
SELECT
    experience_category,
    COUNT(*) AS total_jobs,
    ROUND(AVG(salary_usd), 2) AS avg_salary
FROM jobs
GROUP BY experience_category
ORDER BY avg_salary DESC;


-- 5. Top 10 hiring locations
-- --------------------------------------------------------------------------
SELECT
    company_location,
    COUNT(*) AS total_jobs
FROM jobs
GROUP BY company_location
ORDER BY total_jobs DESC
LIMIT 10;


-- 6. Average salary and average benefits score by company size
-- --------------------------------------------------------------------------
SELECT
    company_size_clean,
    COUNT(*) AS total_jobs,
    ROUND(AVG(salary_usd), 2) AS avg_salary,
    ROUND(AVG(benefits_score), 2) AS avg_benefits_score
FROM jobs
GROUP BY company_size_clean
ORDER BY avg_salary DESC;


-- 7. Top 20 most in-demand skills overall
-- --------------------------------------------------------------------------
SELECT
    skill,
    COUNT(*) AS demand_count,
    ROUND(
        COUNT(*) * 100.0 / (SELECT COUNT(DISTINCT job_id) FROM job_skills),
        1
    ) AS pct_of_jobs
FROM job_skills
GROUP BY skill
ORDER BY demand_count DESC
LIMIT 20;


-- 8. Skill demand broken down by role category
-- --------------------------------------------------------------------------
SELECT
    role,
    skill,
    COUNT(*) AS demand_count
FROM job_skills
GROUP BY role, skill
ORDER BY role, demand_count DESC;


-- 9. Top 10 highest-paying skills (average salary of jobs that require each skill)
-- --------------------------------------------------------------------------
SELECT
    skill,
    COUNT(DISTINCT job_id) AS jobs_requiring_skill,
    ROUND(AVG(salary_usd), 2) AS avg_salary
FROM job_skills
GROUP BY skill
ORDER BY avg_salary DESC
LIMIT 10;


-- 10. Skill demand broken down by experience level (matrix-style)
-- --------------------------------------------------------------------------
SELECT
    skill,
    experience_category,
    COUNT(*) AS demand_count
FROM job_skills
GROUP BY skill, experience_category
ORDER BY skill, demand_count DESC;


-- 11. Live job feed — current job count by role
-- --------------------------------------------------------------------------
SELECT
    role_category,
    COUNT(*) AS live_job_count
FROM live_jobs
GROUP BY role_category
ORDER BY live_job_count DESC;


-- 12. Live job feed — top hiring locations right now
-- --------------------------------------------------------------------------
SELECT
    location,
    COUNT(*) AS live_job_count
FROM live_jobs
GROUP BY location
ORDER BY live_job_count DESC
LIMIT 10;


-- 13. Live job feed — remote vs non-remote split
-- --------------------------------------------------------------------------
SELECT
    is_remote,
    COUNT(*) AS job_count,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM live_jobs), 2) AS pct_of_total
FROM live_jobs
GROUP BY is_remote;
