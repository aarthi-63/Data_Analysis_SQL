--                                                      JOB MARKET ANALYSIS

-- use database
use JOB

-- DQL Statement

-- 1. How many record does this table contains?
select count(*) as Record_count from JOBS_DATA

-- 2. Does the data has duplicates
with duplicate_count as (select count(*) as total_count, 
						count(distinct job_id) as distinct_job_count 
						from JOBS_DATA)
select *,
case
when total_count=distinct_job_count then 'No Duplicate records'
else 'Duplicate record present' 
end as summary
from duplicate_count

-- 3. Display the duplicate job_id present in the datasource
select job_id as 'Duplicate_job_id_present'
from JOBS_DATA
group by job_id
having count(job_id)>1

-- 4. List the top 5 companies and the number of exact job posting.
select company_name,count(*) as 'Count_similar_job_posting'
from JOBS_DATA
group by company_name,[description]
having count(*)>1

-- 5. LIST FIRST 6 FIELDS (COLUMNS) AND DESCRIPTION TOKENS FOR FIVE RANDOM ROWS
SELECT top 5 [index],
		title,
		company_name,
		[location],
		via,
		description_tokens
from JOBS_DATA
order by newid()

/* 6. Average Standardized Salary by Schedule Type and Remote Status

What is the average salary_standardized for jobs, broken down by schedule_type and whether they are work_from_home or not?
Include only Full-time and Contract jobs for this analysis. */


select schedule_type,
		case
			when work_from_home =0 then 'On-Site'
			else 'Remote'
		end as work_type,
		round(avg(salary_standardized),0) as 'AVG_Salary'
from JOBS_DATA
where schedule_type in ('Contract','Full-time')
group by schedule_type,work_from_home
order by 3 desc

/* 7. Top Job Posting Sources by Total Standardized Salary Offered

Which three job posting sources (via) collectively represent the highest sum 
of standardized salaries (salary_standardized)?*/

select top 1  via as job_posting_Source,
		sum(salary_standardized) as 'Total_Standardized_Salary'
from JOBS_DATA
group by via
order by 2 desc

/* 8. Job Titles with the Highest Proportion of Remote Opportunities

List the top 5 job titles that have the highest proportion of 
work_from_home positions among all their postings. Consider only titles with at least 3 total postings.*/

select top 5 title as 'JOB_Tittle'
from JOBS_DATA
group by title
having count(title)>=2
order by CAST(SUM(CASE WHEN work_from_home = 1 THEN 1 ELSE 0 END) / COUNT(*) AS FLOAT) desc

/* 9. Overall Average Standardized Salary for Hourly vs. Yearly Rates
Compare the overall average standardized salary (salary_standardized) 
for jobs listed as 'hourly' (salary_rate = 'hour') versus 'yearly' (salary_rate = 'year'). */

select salary_rate,
		round(avg(salary_standardized),0) as 'AVG_salary_standardized'
from JOBS_DATA
group by salary_rate
order by 2 desc

/* 10. Locations with a High Concentration of Specific Tech Jobs
Identify locations (excluding 'Remote') that containins "developer" AND ("frontend" or "backend")
in their description_tokens. Count how many such jobs each identified location has.*/

select [location],
		count(*) as 'Count_of_jobs'
from JOBS_DATA
where [location] != 'Remote' and
		description_tokens like '%developer%' and
		(description_tokens like '%frontend%' or description_tokens like '%backend%')
group by [location]

/* 11. Salary Comparison for Recently Posted Jobs

Compare the average salary_standardized for jobs posted in the last 7 days (relative to the 
date_time column, assuming date_time represents "now" for the data point) versus jobs posted earlier. */

select 
		case
		when DATEDIFF(D,posted_at,GETDATE())<7 then 'posted last 7 days'
		else 'posted Earlier'
		end as Data_diff,
		round(avg(salary_standardized),0) as 'AVG_salary_standardized'
from JOBS_DATA 
group by case
		when DATEDIFF(D,posted_at,GETDATE())<7 then 'posted last 7 days'
		else 'posted Earlier'
		end
order by 2 desc

/*12 . Determine Days Since Job Posting
Show the title, company_name, posted_at, date_time (the timestamp of when the record was observed), 
and a new calculated column DaysSincePosting which represents how many days have passed between 
the posted_at date and the date_time of the record.*/

select title,
		company_name,
		posted_at,
		GETDATE(),
		DATEDIFF(d,posted_at,GETDATE()) as 'DaysSincePosting'
from JOBS_DATA
order by 5

/* 13. Categorize Salary Ranges

Create a new column SalaryTier that categorizes jobs based on their salary_standardized:
'High' if salary_standardized is greater than 120,000
'Medium' if salary_standardized is between 75,000 and 120,000 (inclusive)
'Low' if salary_standardized is less than 75,000
'Unspecified' if salary_standardized is NULL. */

select title,
		company_name,
		job_id,
		salary_standardized,
		case
			when salary_standardized > 120000 then 'High'
			when salary_standardized between 75000 and 120000 then 'Medium'
			when salary_standardized <75000 then 'Low'
			else 'Unspecified'
		end as 'Salary_Tier'
from JOBS_DATA
order by 4 desc


/* 14. Identify Potential Data/AI/ML Roles

For each job, display its title, company_name, and a boolean-like calculated column IsDataAIMLRole 
that is 1 if "data", "ai", or "machine learning" (or "ml") is present in description_tokens 
(case-insensitive), otherwise 0. */

select title,
		company_name,
		case
		when description_tokens like '%data%' or 
			description_tokens like '%ai%' or 
			description_tokens like '%machine learning%' or 
			description_tokens like '%ml%' then 1
		else 0
		end as 'IsDataAIMLRole'
from JOBS_DATA

/* 15. Filter all the data where the IsDataAIMLRole is 1

From the results of above query extract title, company_name and description token of the companies that
has "data", "ai", or "machine learning" (or "ml") is present in description_tokens  */

with Specified_Role_tab as (select title,
		company_name,
		description_tokens,
		case
		when description_tokens like '%data%' or 
			description_tokens like '%ai%' or 
			description_tokens like '%machine learning%' or 
			description_tokens like '%ml%' then 1
		else 0
		end as 'IsDataAIMLRole'
from JOBS_DATA)
select * from Specified_Role_tab
where IsDataAIMLRole=1

/* 16.standardized Commute Category and Estimated Commute Time in Hours

Create two calculated columns: 
  1.commuteCategory: 'Short' (<= 20 mins), 'Medium' (>20 and <= 45 mins), 
    'Long' (>45 mins), or 'N/A' if commute_time is not numeric.
  2.CommuteTimeInHours: Converts the commute_time (assuming it's in 'X mins' format) to hours. */

with commute_calc as (select title,
						company_name,
						commute_time,
						case
						when commute_time != 'N/A' then try_cast(replace(commute_time,' mins','') as int)
						else null
						end as 'mins'
					from JOBS_DATA)
select *,
		case
			when mins <= 20 then 'Short'
			when mins between 21 and 45 then 'Medium'
			when mins > 45 then 'Long'
			else 'N/A'
		end as commuteCategory,
		case 
			when mins is not null then round(cast(mins as float)/60,3)
			else null
		end as Time_in_Hours
from commute_calc

/* 17. Analyze Average Salary and Remote Job Proportion for Top 5 Job Titles

For the 5 most frequently posted titles (excluding 'Remote' locations), 
calculate their average salary_standardized. Then, for each of these top 5 titles, 
determine the percentage of jobs that are work_from_home. 
Rank these top titles by their average standardized salary. */

with FrequentlyPostedJob as (select top 5 title
from JOBS_DATA
where location != 'Remote'
group by title
order by count(title) desc)
SELECT j.title,
       AVG(j.salary_standardized) as AverageStandardSalary,
       CAST(SUM(CASE WHEN j.work_from_home = 1 THEN 1 ELSE 0 END) AS FLOAT)  / COUNT(j.job_id)* 100 RemoteJobPercentage,
       RANK() OVER(ORDER BY AVG(j.salary_standardized) DESC) AS SalaryRank
FROM FrequentlyPostedJob fpj
INNER JOIN JOBS_DATA j
ON fpj.TITLE = j.TITLE
GROUP BY j.title;


/*___________________________________________________________________________END__________________________________________________________________*/