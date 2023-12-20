/*Data cleaning and preparation in Snowflake using SQL*/


--Extract State from 'Federal_State' field
--Join the US Wind Turbine Dataset with the US states dataset, keeping all states, therefore right join

CREATE TABLE US_WIND_TURBINE_COMPLETE AS
SELECT *, substring(federal_state, position('(', federal_state)+1, 2) AS s_state
FROM US_WIND_TURBINE_DATABASE
    RIGHT JOIN US_STATES_DATA
        ON t_state = s_state;

--Check for duplicate wind turbine IDs
SELECT case_id, count(*)
FROM US_WIND_TURBINE_COMPLETE
GROUP BY case_id
ORDER BY 2 DESC;

--Delete the duplicate values as they do not have a case_id
DELETE FROM US_WIND_TURBINE_COMPLETE 
WHERE case_id IS null;

--Check the number of NULLS per column, also gain a better understanding of the metadata
SELECT
    count(*)-count(case_id) AS wind_turbine_id,
    count(*)-count(t_state) AS turbine_state_location,
    count(*)-count(p_year) AS year_turbine_finished, --554 null values
    count(*)-count(p_name) AS project_name, 
    count(*)-count(p_cap) AS project_cum_capacity, --3413 null values
    count(*)-count(p_tnum) AS number_of_turbines_in_project,
    count(*)-count(t_manu) AS turbine_manufacturer, --4570 null values
    count(*)-count(t_model) AS turbine_model_name, --4707 null values
    count(*)-count(t_cap) AS turbine_capacity, --4401 null values
    count(*)-count(t_hh) AS turbine_hubheight, --4897 null values
    count(*)-count(t_rd) AS turbine_rotor_diameter, --4839 null values
    count(*)-count(retrofit) AS retrofit
FROM US_WIND_TURBINE_COMPLETE

--Check number of Wind Turbine IDs per state AND number of Wind Turbine IDs where turbine_manufacturer is missing
--It seems that California is the State with most missing data 1924 out of 5974 turbines miss crucial data
SELECT 
    t_state, 
    count(case_id) as turbine_count, 
    count(case when t_manu IS null then 1 end) as turbine_count_cleaned
FROM US_WIND_TURBINE_COMPLETE
GROUP BY t_state
ORDER BY 3 DESC;

--Delete wind turbines that are missing crucial data for analysis (year_turbine_finished, turbine_manufacturer, turbine_capacity).
DELETE FROM US_WIND_TURBINE_COMPLETE
WHERE 
    p_year IS null OR
    t_manu IS null OR
    t_cap IS null;

--Renaming columns and updating data types
CREATE OR replace TABLE US_WIND_TURBINE_COMPLETE AS
SELECT
    CAST(case_id as string) AS turbine_id,
    t_state AS turbine_state_location,
    p_year AS year_turbine_finished,
    p_name AS project_name,
    p_cap AS project_capacity,
    p_tnum AS number_of_turbines_in_project,
    t_manu AS turbine_manufacturer,
    t_model AS turbine_model_name,
    round(t_cap/1000,2) AS turbine_capacity, --convert turbine capacity to MW
    t_hh AS turbine_hubheight,
    t_rd AS turbine_rotor_diameter,
    retrofit,
    xlong AS longitude,
    ylat AS latitude,
    LEFT(federal_state,position('(',federal_state)-2) AS state_name, --only keep state name
    cast(replace(LEFT(AREA,position(' ',AREA)-1),',','') AS int) AS state_area, --remove 'km2' and ',', then convert to integer
    cast(replace(population,',','') AS int) AS population --remove ',', then convert to integer
FROM US_WIND_TURBINE_COMPLETE;