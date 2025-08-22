/*
Question: What are the top skills based on salary?
- Look at the average salary aasociated for each skill for Data scientist roles
- Focus on roles with specified salaries (remove nulls)
- Why? It reveals which skills are linked to higher-paying Data Scientist positions,
helping candidates prioritize skill development for better compensation
*/

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