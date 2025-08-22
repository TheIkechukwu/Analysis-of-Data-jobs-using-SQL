/* 
Question: What are the most optimal skills to learn as a Data Scientist?
(i.e skills that are both in-demand and associated with high salaries)
- Identify skills in high demand and associated with high average salaries
- Concentrate on remote positions with specified salaries
- Why? This helps candidates focus on skills that not only are sought after but also lead to better compensation, 
guiding their learning path effectively
*/

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