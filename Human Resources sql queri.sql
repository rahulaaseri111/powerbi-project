create database projects;
use projects;
select * from hr;
alter table hr change column ï»¿id emp_id varchar(20) null;
set sql_safe_updates = 0;
UPDATE hr
SET termdate = CASE
    WHEN termdate = ' ' THEN '0000-00-00'
    ELSE DATE_FORMAT(str_to_date(termdate,'%Y-%m-%d %H:%i:%s UTC'), '%Y-%m-%d')
END
WHERE termdate IS NOT NULL AND termdate != '';
UPDATE hr
SET termdate = '0000-00-00'
WHERE termdate = '';
update hr 
set termdate = date(str_to_date(termdate,'%Y-%m-%d'));
SET sql_mode = (SELECT REPLACE(@@sql_mode,'NO_ZERO_DATE',''));
alter table hr modify column  termdate date;
update hr 
set birthdate = case
	when birthdate like'%/%' then date_format(str_to_date(birthdate,'%m/%d/%Y'),'%Y-%m-%d')
    when birthdate like'%-%' then date_format(str_to_date(birthdate,'%m-%d-%Y'),'%Y-%m-%d')
end;
alter table hr
modify column birthdate date;
update hr 
set hire_date = case
	when hire_date like'%/%' then date_format(str_to_date(hire_date,'%m/%d/%Y'),'%Y-%m-%d')
    when hire_date like'%-%' then date_format(str_to_date(hire_date,'%m-%d-%Y'),'%Y-%m-%d')
end;
alter table hr
modify column hire_date date;
alter table hr add column age int;
update hr set age =timestampdiff(year,birthdate,curdate());
select birthdate,age from hr;
select min(age),max(age) from hr;
-- Question
-- 1 What is the gender breakdown of employees in the company-
select gender ,count(*) as count from hr where age >=18 and termdate='0000-00-00' group by gender ;
-- 2 what is the race /ethnicity breakdown of employees in the company
select race, count(*) as count from hr where age >=18 and termdate='0000-00-00' group by race order by count desc;
-- age distribution of the employees in the company
select
 case 
	when age >=18 and age <=24 then '18-24'
    when age >=25 and age <=34 then '25-34'
    when age >=35 and age <=44 then '35-44'
    when age >=45 and age <=54 then '45-54'
    when age >=55 and age <=64 then '55-64'
    else '65+'
end as age_group,count(*) as count from hr where age >=18 and termdate='0000-00-00' group by age_group order by age_group;
select
 case 
	when age >=18 and age <=24 then '18-24'
    when age >=25 and age <=34 then '25-34'
    when age >=35 and age <=44 then '35-44'
    when age >=45 and age <=54 then '45-54'
    when age >=55 and age <=64 then '55-64'
    else '65+'
end as age_group,gender,count(*) as count from hr where age >=18 and termdate='0000-00-00' group by age_group,gender order by age_group,gender;

-- How many employees work at headquarters versus remote locations?
select location, count(*) as No_of_employees from hr where age >=18 and termdate='0000-00-00' group by location;

-- what is the average length of employment for employees who have been terminated?
select round(avg(datediff(termdate,hire_date))/365,0) as avg_length_employment
from hr where termdate <=curdate() and termdate<>'0000-00-00' and age>=18;

-- how does the gender distribution vary across departments and job titles?
select department ,gender ,count(*) as count from hr where age >=18 and termdate='0000-00-00' group by department, gender order by department;

-- what is the distribution of job titles across the company?
select jobtitle, count(*) as count from hr where age >=18 and termdate='0000-00-00' group by jobtitle order by jobtitle desc;

-- which department has highest turnover rate?
select department, total_count, terminated_count, terminated_count/total_count as termination_rate 
from (select department, count(*) as total_count, sum( case when termdate <> '0000-00-00' and termdate <= curdate() then 1 else 0 end) 
as terminated_count from hr where age >=18 group by department) as subquery order by termination_rate desc;

-- what is the distribution of employees across location  state?
select location_state,  count(*) as count from hr where age >=18 and termdate='0000-00-00' group by location_state order by count desc;

-- how has the company's employee count changed over time based on hire and term dates?
select
	year,
    hires,
    terminations,
    hires-terminations as net_change,
    round((hires-terminations)/hires*100,2) as net_change_percent
from(
	select
		year(hire_date) as year,
        count(*) as hires,
        sum(case when termdate<> '0000-00-00' and termdate<=curdate() then 1 else 0 end) as terminations
        from hr 
        where age>=18
        group by year(hire_date)) as subquery
	order by year asc;
    
-- what is the tenure distribution for each department?
select department , round(avg(datediff(termdate ,hire_date))/365,0) as avg_tenure
from hr
where termdate <>'0000-00-00' and age >=18 and termdate <= curdate()
group by department;
    




