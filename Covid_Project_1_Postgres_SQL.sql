-- Create two tables, one for covid deaths dataset and one for covid vaccination dataset
-- Once tables are created, import the csv files

create table covid_deaths(
    iso_code varchar(10)
  , continent varchar(255)
  , location varchar(255)
  , date date
  , population bigint
  , total_cases	int
  , new_cases int
  , new_cases_smoothed decimal(10,3)
  , total_deaths int
  , new_deaths int
  , new_deaths_smoothed	decimal(10,3)
  , total_cases_per_million decimal(10,3)
  , new_cases_per_million decimal(10,3)
  , new_cases_smoothed_per_million decimal(10,3)
  , total_deaths_per_million decimal(10,3)
  , new_deaths_per_million decimal(10,3)
  , new_deaths_smoothed_per_million decimal(10,3)
  , reproduction_rate decimal(10,2)
  , icu_patients int
  , icu_patients_per_million decimal(10,3)
  , hosp_patients int
  , hosp_patients_per_million decimal(10,3)
  , weekly_icu_admissions int
  , weekly_icu_admissions_per_million decimal(10,3)
  , weekly_hosp_admissions int
  , weekly_hosp_admissions_per_million decimal(10,3)

)
;
create table covid_vaccinations(
    iso_code varchar(10)
  , continent varchar(255)
  , location varchar(255)
  , date date
  , total_tests bigint
  , new_tests bigint
  , total_tests_per_thousand decimal(10,3)
  , new_tests_per_thousand decimal(10,3)
  , new_tests_smoothed bigint
  , new_tests_smoothed_per_thousand decimal(10,3)
  , positive_rate decimal(10,3)
  , tests_per_case decimal(10,3)
  , tests_units varchar(255)
  , total_vaccinations bigint
  , people_vaccinated bigint
  , people_fully_vaccinated bigint
  , total_boosters bigint
  , new_vaccinations bigint
  , new_vaccinations_smoothed bigint
  , total_vaccinations_per_hundred decimal(10,3)
  , people_vaccinated_per_hundred decimal(10,3)
  , people_fully_vaccinated_per_hundred decimal(10,3)
  , total_boosters_per_hundred decimal(10,3)
  , new_vaccinations_smoothed_per_million bigint
  , new_people_vaccinated_smoothed bigint
  , new_people_vaccinated_smoothed_per_hundred decimal(10,3)
  , stringency_index decimal(10,3)
  , population_density decimal(10,3)
  , median_age decimal(10,3)
  , aged_65_older decimal(10,3)
  , aged_70_older decimal(10,3)
  , gdp_per_capita decimal(10,3)
  , extreme_poverty decimal(10,3)
  , cardiovasc_death_rate decimal(10,3)
  , diabetes_prevalence decimal(10,3)
  , female_smokers decimal(10,3)
  , male_smokers decimal(10,3)
  , handwashing_facilities decimal(10,3)
  , hospital_beds_per_thousand decimal(10,3)
  , life_expectancy decimal(10,3)
  , human_development_index decimal(10,3)
  , excess_mortality_cumulative_absolute decimal(10,3)
  , excess_mortality_cumulative decimal(10,3)
  , excess_mortality decimal(10,3)
  , excess_mortality_cumulative_per_million decimal(10,3)
	
)

-- Calculate total death percentage

select
	c.location
      , c.date
      , c.total_cases
      , c.total_deaths
      , (cast(c.total_deaths as decimal)/c.total_cases)*100 as death_perc
from
	covid_deaths c

/* 
	Here we can infer that as of April 07, 2021 ~ the chances of dying from covid in Afghanistan was 4.4%
*/

-- Calculate Total death percentage specific to the United States

select
	c.location
      , c.date
      , c.total_cases
      , c.total_deaths
      , (cast(c.total_deaths as decimal)/c.total_cases)*100 as death_perc
from
	covid_deaths c
where
	location ilike '%states'


-- Create CTE to find min, max and average death percentages

with death_perc as (
				select
					c.location
				      , c.date
				      , c.total_cases
				      , c.total_deaths
				      , (cast(c.total_deaths as decimal)/c.total_cases)*100 as death_perc
				from
					covid_deaths c
				where
					location ilike '%states'

			)

select
	max(d.death_perc)
      , min(d.death_perc)
      , avg(d.death_perc)
from
	death_perc d


-- Percentage of the population that has gotten covid; Total Cases vs Population

select
	c.location
      , c.date
      , c.total_cases
      , c.population
      , (cast(c.total_cases as decimal)/ c.population)*100 as perc_cases
from
	covid_deaths c
where
	location ilike '%states'

/*
	We can infer that by February 24, 2024 ~ 30.58% of the US population has contracted covid atleast once
*/


-- Max Total Cases, total cases per location

select
	c.location
      , max(c.total_cases)
from
	covid_deaths c
group by
	c.location


-- Looking at countries with the highest infection rate compared to the population

select
	c.location
      , c.population
      , max(c.total_cases) as highest_infection_cnt
      , max((cast(c.total_cases as decimal)/ c.population))*100 as perc_pop_infected
from
	covid_deaths c
group by
	c.location
      , c.population
order by
	perc_pop_infected desc

/*
	Our result set shows the highest infection count per location (which is total infection count) and we used that
	to calculate the percentage of the population that was infected
*/


-- Showing countries with highest death count per population

select
	c.location
      , max(c.total_deaths) as total_death_count
from
	covid_deaths c
where
	cotinent is not null
group by
	c.location
order by
	total_death_count desc
	
/*
	We found total death count specific to each location and we ordered it by descending to view the highest total
	death counts; NOTE : we added a where clause to specify continent is not null because we have null values in our 
	cotinent column that affects the result of our data
*/


-- Total Death Count by Location

select 
	c.location
      , sum(c.new_deaths) as total_death_count
from 	
	covid_deaths c
where 
	c.continent is null and c.location not in ('World', 'European Union', 'International') -- European Union apart of Europe
	and c.location not like '%income%' -- so we don't include different income brackets for location
group by 
	c.location
order by
	total_death_count desc



-- Continents with the highest death count

select
	c.continent
      , max(c.total_deaths) as total_death_count
from
	covid_deaths c
where 
	continent is not null
group by
	c.continent
order by
	total_death_count desc


-- GLOBAL NUMBERS, WORLDWIDE DATA

select
	c.date
      , sum(c.new_cases) as total_cases -- new cases added up is the total cases
      , sum(c.new_deaths) as total_deaths
      , sum(c.new_deaths)/sum(c.new_cases)*100 as death_perc
from
	covid_deaths c
where
	continent is not null
group by
	c.date
order by
	c.date


/* 
	The result set shows on specific dates (grouped by dates) the total cases, total deaths and death percentage worldwide
*/

select
	sum(c.new_cases) as total_cases -- new cases added up is the total cases
      , sum(c.new_deaths) as total_deaths
      , sum(c.new_deaths)/sum(c.new_cases)*100 as death_perc
from
	covid_deaths c
where
	continent is not null

/*
	If we take the date column out of the select statement, we get total cases, deaths and death percentage across all data
*/


-- Join the covid deaths dataset with the covid vaccination dataset to make more inferences

select
	*
from
	covid_deaths d
		join covid_vaccinations v
			on d.date = v.date and d.location = v.location
			
-- Total Population vs Vaccinations; ROLLING COUNT OF VACCINATIONS

select
	d.continent
      , d.location
      , d.date
      , d.population
      , v.new_vaccinations -- new vaccination per day
      , sum(v.new_vaccinations) over(partition by d.location order by d.date) as rolling_cnt
  -- rolling count
from
	covid_deaths d
		join covid_vaccinations v
			on d.date = v.date and d.location = v.location
where
	d.continent is not null
order by
	d.location
      , d.date


-- Percentage of the population that is vaccinated on any specific date (grouped by location and date), CTE

with rolling_count as (

			select
				  d.continent
			  	, d.location
			  	, d.date
			  	, d.population
			  	, v.new_vaccinations -- new vaccination per day
			  	, sum(v.new_vaccinations) over(partition by d.location order by  d.date) as rolling_cnt
			  -- rolling count
			from
				covid_deaths d
					join covid_vaccinations v
						on d.date = v.date and d.location = v.location
			where
				d.continent is not null
			order by
				d.location
			      , d.date

			)
select
	  r.continent
  	, r.location
  	, r.date
  	, r.population
  	, r.new_vaccinations
  	, r.rolling_cnt
  	, (r.rolling_cnt/ r.population)*100 as pop_perc_vacc
  
from
	rolling_count r
	-- shows what percentage of the population is vaccinated at specific date and locations


-- If instead we want to use a Temp Table vs CTE

drop table if exists rolling_count 
create temp table rolling_count as (

			select
				  d.continent
			  	, d.location
			  	, d.date
			  	, d.population
			  	, v.new_vaccinations 
			  	, sum(v.new_vaccinations) over(partition by d.location order by  d.date) as rolling_cnt
			from
				covid_deaths d
					join covid_vaccinations v
						on d.date = v.date and d.location = v.location
			where
				d.continent is not null
			order by
				d.location
			      , d.date

			)
;			
select
	  r.continent
  	, r.location
  	, r.date
  	, r.population
  	, r.new_vaccinations
  	, r.rolling_cnt
  	, (r.rolling_cnt/ r.population)*100 as pop_perc_vacc
  
from
	rolling_count r

/*
	NOTE : drop table if exists makes it easier for us to update the temp table, so we don't need to manually drop the table
*/


-- Create view, more permanent than temp tables or CTE's 

create view rolling_cnt as(
		select
			  r.continent
			, r.location
			, r.date
			, r.population
			, r.new_vaccinations
			, r.rolling_cnt
			, (r.rolling_cnt/ r.population)*100 as pop_perc_vacc

		from
			rolling_count r
)


-- Percent Population Infected

select 
	c.location
      , c.population
      , max(total_cases) as highest_infection_count
      , max((cast(total_cases as decimal)/population))*100 as percent_pop_infected
from 
	covid_deaths c
group by 
	c.location
      , c.population
order by 
	percent_pop_infected desc









