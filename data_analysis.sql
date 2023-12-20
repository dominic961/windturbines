/*Data analysis*/


-- summary statistics
-- total number of projects and total number of turbines
-- average number of wind turbines per project
SELECT 
    count(distinct project_name) as count_projects, 
    count(distinct turbine_id) as count_turbines,
    round(count(turbine_id)/count(distinct project_name)) as avg_turbines_project
FROM US_WIND_TURBINE_COMPLETE;

--total number of installed turbines per year
SELECT
    year_turbine_finished,
    count(distinct turbine_id) as count_turbines
FROM US_WIND_TURBINE_COMPLETE
GROUP BY year_turbine_finished
ORDER BY year_turbine_finished asc;

-- average and median overall turbine capacity in MW
SELECT 
    round(avg(turbine_capacity),2) as avg_capacity, 
    round(median(turbine_capacity),2) as median_capacity
FROM US_WIND_TURBINE_COMPLETE;

-- maximum and minimum turbine capacity in MW
SELECT 
    round(max(turbine_capacity),2) as max_capacity, 
    round(min(turbine_capacity),2) as min_capacity
FROM US_WIND_TURBINE_COMPLETE;

-- correlation between year turbine was produced and turbine capacity
SELECT
    corr(turbine_capacity,year_turbine_finished) as correlation
FROM US_WIND_TURBINE_COMPLETE


-- number of wind turbines per project
-- average and cumulative capacity in MW per project
SELECT 
    project_name, 
    turbine_manufacturer, 
    year_turbine_finished, 
    count(turbine_id) as count_turbines, 
    round(avg(turbine_capacity),2) as avg_capacity, 
    sum(turbine_capacity) as cum_capacity 
FROM US_WIND_TURBINE_COMPLETE
GROUP BY project_name, turbine_manufacturer, year_turbine_finished
ORDER BY year_turbine_finished DESC, project_name ASC;

-- difference between new (>= 2013) and old (< 2013) projects
SELECT
    CASE 
        WHEN year_turbine_finished >= 2013 THEN 'new_projects' 
        ELSE 'old_projects' END AS project_type,
    count(turbine_id) as count_turbines, 
    round(avg(turbine_capacity),2) as avg_capacity, 
    sum(turbine_capacity) as cum_capacity
FROM US_WIND_TURBINE_COMPLETE
GROUP BY project_type;

-- difference between large (>= 100 turbines) and smaller (< 100) projects
SELECT
    CASE 
        WHEN count_turbines >= 100 THEN 'large_projects' 
        ELSE 'small_projects' END AS project_size,
    count(project_name), sum(count_turbines) as count_turbines, 
    sum(cum_capacity) as cum_capacity, 
    sum(cum_capacity)/sum(count_turbines) as avg_capacity
FROM (
    SELECT 
        project_name, 
        count(turbine_id) as count_turbines, 
        sum(turbine_capacity) as cum_capacity
    FROM US_WIND_TURBINE_COMPLETE
    GROUP BY project_name) AS NEW_TABLE
GROUP BY project_size;


--there is a clear difference between new and old projects but not so much between large and small projects
--for the new projects let's see which manufacturers were involved, how many projects they were part of, and how many turbines they produced.
SELECT
    CASE 
        WHEN year_turbine_finished >= 2013 THEN 'new_projects' 
        ELSE 'old_projects' END AS project_type, turbine_manufacturer,
    count(turbine_id) as count_turbines, 
    round(avg(turbine_capacity),2) as avg_capacity, 
    sum(turbine_capacity) as cum_capacity
FROM US_WIND_TURBINE_COMPLETE
GROUP BY project_type, turbine_manufacturer
ORDER BY project_type ASC, count_turbines DESC;


--number of turbines per sq km in a state
--number of people per sq km in a state
SELECT 
    state_name, 
    count(turbine_id) as count_turbines, 
    round(count(turbine_id)/min(state_area),3) as turbines_sqkm, 
    min(population) as population, 
    round(min(population)/min(state_area),2) as population_sqkm
FROM US_WIND_TURBINE_COMPLETE
GROUP BY state_name
ORDER BY count_turbines DESC;

--if population density is low there may be more opportunities to expand
--if turbines per sqkm is low there may be more opportunities to expand
--if count of turbines is low there may be no regulation in place which takes longer to build

--assign ranking and filter states with >1000 turbines
SELECT 
    state_name, 
    count(turbine_id) as count_turbines, 
    round(count(turbine_id)/min(state_area),3) as turbines_sqkm, 
    rank() over (order by round(count(turbine_id)/min(state_area),3) asc) as ranking1,
    min(population) as population, 
    round(min(population)/min(state_area),2) as population_sqkm,
    rank() over (order by round(min(population)/min(state_area),2) asc) as ranking2
FROM US_WIND_TURBINE_COMPLETE
GROUP BY state_name
    HAVING count(turbine_id) > 1000
ORDER BY ranking1 ASC, ranking2 ASC;

--deciding to look into Wyoming, New Mexico, South Dakota based on ranking
--in the states that are selected which manufacturers are most experienced?
SELECT
    state_name,
    turbine_manufacturer,
    count(turbine_id) as count_turbines,
    round(avg(turbine_capacity),2) as avg_capacity, 
    sum(turbine_capacity) as cum_capacity
FROM US_WIND_TURBINE_COMPLETE
WHERE state_name IN ('Wyoming','New Mexico','South Dakota')
    AND year_turbine_finished >= 2013
GROUP BY state_name, turbine_manufacturer
ORDER BY state_name DESC, count_turbines DESC;
