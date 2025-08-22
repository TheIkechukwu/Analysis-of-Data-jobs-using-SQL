/* 
Question: What skills are required fro the top paying data scientist jobs?
- Use the top 10 highest paying Data Scientist jobs from the first query
- Add the specific skills required for these roles 
- Why? It provides a detailed look at which high-paying jobs demand certain skills, 
helping job seekers understand which skills to develop that align with top salaries
*/

WITH top_10 AS ( 
	SELECT 
		job_id,
		job_title,
		salary_year_avg,
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
	top_10.*,
	skills
FROM 
	top_10 
INNER JOIN 
	skills_job_dim
ON top_10.job_id = skills_job_dim.job_id
INNER JOIN 
	skills_dim
ON skills_job_dim.skill_id = skills_dim.skill_id
ORDER BY 
    salary_year_avg DESC;