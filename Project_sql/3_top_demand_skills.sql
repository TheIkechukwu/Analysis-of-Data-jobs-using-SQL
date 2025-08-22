/* 
Question: What are the most in-demand skills for Data Scientists?
- Join job postings to inner join table similar to query 2
- Identify the top 5 in-demand skills for a data scientist
- Focus on all job postings 
- Why? Reveals the most sought-after skills in the job market for Data Scientists, 
helping candidates align their skill sets with industry demands
*/ 

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