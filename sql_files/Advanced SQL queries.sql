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

SELECT 
	job_id,
	job_title,
	job_location,
	job_schedule_type, 
	salary_year_avg,
	job_posted_date,
	name AS company_name
FROM 
	job_postings_fact
LEFT JOIN 
	company_dim
ON job_postings_fact.company_id = company_dim.company_id
WHERE 
	job_title_short = 'Data Scientist' AND 
	job_location = 'Anywhere' AND 
	salary_year_avg IS NOT NULL
ORDER BY 
	salary_year_avg DESC
LIMIT 10;

WITH top_10 AS ( 
	SELECT 
		job_id,
		job_title,
		job_location,
		job_schedule_type, 
		salary_year_avg,
		job_posted_date,
		name AS company_name
	FROM 
		job_postings_fact
	LEFT JOIN 
		company_dim
	ON job_postings_fact.company_id = company_dim.company_id
	WHERE 
		job_title_short = 'Data Scientist' AND 
		job_location = 'Anywhere' AND 
		salary_year_avg IS NOT NULL
	ORDER BY 
		salary_year_avg DESC
	LIMIT 10
)	

SELECT 
	top_10.job_id,
	top_10.job_title,
	top_10.salary_year_avg,
	top_10.company_name,
	skills
FROM 
	top_10 
INNER JOIN 
	skills_job_dim
ON top_10.job_id = skills_job_dim.job_id
INNER JOIN 
	skills_dim
ON skills_job_dim.skill_id = skills_dim.skill_id;

SELECT 
	skills,
	COUNT(skills_job_dim.job_id) AS skill_count
FROM 
	job_postings_fact
INNER JOIN 
	skills_job_dim
ON job_postings_fact.job_id = skills_job_dim.job_id
INNER JOIN 
	skills_dim
ON skills_job_dim.skill_id = skills_dim.skill_id
WHERE 
	job_postings_fact.job_title_short = 'Data Scientist' AND 
	job_postings_fact.job_work_from_home = True
GROUP BY 
	skills
ORDER BY 
	skill_count DESC
LIMIT 5;

SELECT 
	skills,
	ROUND(AVG(job_postings_fact.salary_year_avg), 2) AS avg_salary
FROM 
	job_postings_fact
INNER JOIN 
	skills_job_dim
ON job_postings_fact.job_id = skills_job_dim.job_id
INNER JOIN 
	skills_dim
ON skills_job_dim.skill_id = skills_dim.skill_id
WHERE 
	job_postings_fact.job_title_short = 'Data Scientist' AND 
	job_postings_fact.job_work_from_home = True AND 
	job_postings_fact.salary_year_avg IS NOT NULL
GROUP BY 
	skills
ORDER BY 
	avg_salary DESC
LIMIT 15;

WITH skills_demand AS (
	SELECT 
		skills_dim.skill_id,
		skills_dim.skills,
		COUNT(skills_job_dim.job_id) AS skill_count
	FROM 
		job_postings_fact
	INNER JOIN 
		skills_job_dim
	ON job_postings_fact.job_id = skills_job_dim.job_id
	INNER JOIN 
		skills_dim
	ON skills_job_dim.skill_id = skills_dim.skill_id
	WHERE 
		job_postings_fact.job_title_short = 'Data Scientist' AND 
		job_postings_fact.job_work_from_home = True AND 
		job_postings_fact.salary_year_avg IS NOT NULL
	GROUP BY 
		skills_dim.skill_id
), average_salaries AS (
	SELECT 
		skills_job_dim.skill_id,
		ROUND(AVG(job_postings_fact.salary_year_avg), 2) AS avg_salary
	FROM 
		job_postings_fact
	INNER JOIN 
		skills_job_dim
	ON job_postings_fact.job_id = skills_job_dim.job_id
	INNER JOIN 
		skills_dim
	ON skills_job_dim.skill_id = skills_dim.skill_id
	WHERE 
		job_postings_fact.job_title_short = 'Data Scientist' AND 
		job_postings_fact.job_work_from_home = True AND 
		job_postings_fact.salary_year_avg IS NOT NULL
	GROUP BY 
		skills_job_dim.skill_id
)

SELECT 
	skills_demand.skill_id,
	skills_demand.skills,
	skills_demand.skill_count,
	avg_salary 
FROM 
	skills_demand 
INNER JOIN 
	average_salaries 
ON skills_demand.skill_id = average_salaries.skill_id
WHERE skills_demand.skill_count > 10
ORDER BY 
	avg_salary DESC, 
	skills_demand.skill_count DESC
LIMIT 25;