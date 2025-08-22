SELECT *
FROM company_dim
LIMIT 10;

SELECT *
FROM job_postings_fact
LIMIT 10;

SELECT 
	job_posted_date,
	EXTRACT(QUARTER FROM job_posted_date)
FROM 
	job_postings_fact;

SELECT 
	company_dim.name,
	COUNT(job_postings_fact.job_id) AS job_counts
FROM job_postings_fact 
LEFT JOIN company_dim 
ON job_postings_fact.company_id = company_dim.company_id
WHERE EXTRACT(QUARTER FROM job_postings_fact.job_posted_date) = 2 
	AND job_postings_fact.job_health_insurance IS TRUE
GROUP BY company_dim.name
ORDER BY job_counts DESC;

CREATE TABLE january_jobs AS
	SELECT *
	FROM 
		job_postings_fact
	WHERE EXTRACT(MONTH FROM job_posted_date) = 1;

CREATE TABLE february_jobs AS
	SELECT *
	FROM 
		job_postings_fact
	WHERE EXTRACT(MONTH FROM job_posted_date) = 2;

CREATE TABLE march_jobs AS
	SELECT *
	FROM 
		job_postings_fact
	WHERE EXTRACT(MONTH FROM job_posted_date) = 3;

SELECT *
FROM 
	march_jobs;

SELECT * 
FROM skills_dim;

WITH q1_jobs AS (
	SELECT job_id, salary_year_avg
	FROM january_jobs
	UNION ALL 
	SELECT job_id, salary_year_avg
	FROM february_jobs
	UNION ALL 
	SELECT job_id, salary_year_avg
	FROM march_jobs
)

SELECT q1_jobs.job_id, s.skills, s.type, q1_jobs.salary_year_avg
FROM q1_jobs
LEFT JOIN skills_job_dim 
ON q1_jobs.job_id = skills_job_dim.job_id
LEFT JOIN skills_dim AS s
ON skills_job_dim.skill_id = s.skill_id
WHERE q1_jobs.salary_year_avg > 70000;