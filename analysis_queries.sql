SELECT COUNT(*) AS total_jobs
FROM jobs;
SELECT role_category,
       COUNT(*) AS total_jobs,
       ROUND(AVG(salary_usd), 2) AS avg_salary
FROM jobs
GROUP BY role_category
ORDER BY avg_salary DESC;
SELECT work_type,
       COUNT(*) AS total_jobs,
       ROUND(AVG(salary_usd), 2) AS avg_salary
FROM jobs
GROUP BY work_type
ORDER BY total_jobs DESC;
SELECT experience_category,
       COUNT(*) AS total_jobs,
       ROUND(AVG(salary_usd), 2) AS avg_salary
FROM jobs
GROUP BY experience_category
ORDER BY avg_salary DESC;
SELECT company_location,
       COUNT(*) AS total_jobs
FROM jobs
GROUP BY company_location
ORDER BY total_jobs DESC
limit 10;
