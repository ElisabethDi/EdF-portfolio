select continent, new_cases, date (2021-03-01)
from covid_deaths
order by  date;

-- verifying data has imported correctly from excel.csv to mysql--

SELECT  *
FROM  covidportfolio.covid_vacination;

SELECT  *
FROM  covidportfolio.covid_vacination
order by 3,4;

	-- Exploratory data search--
SELECT  location, date, total_cases, total_cases, new_cases, total_deaths, population
FROM  covidportfolio.covid_death
order by 1,2;

-- Percentage of death per case--
SELECT  location, date, total_cases, total_deaths,  (total_deaths/total_cases)*100 AS 'Death Rate'
FROM  covidportfolio.covid_death
order by 1,2;

-- Death Rate for Canada--
SELECT  location, date, total_cases, total_deaths,  (total_deaths/total_cases)*100 AS 'Death Rate'
FROM  covidportfolio.covid_death
where	location = 'Canada'
order by 1,2;

-- Death Rate for United States--
SELECT  location, date, total_cases, total_deaths,  (total_deaths/total_cases)*100 AS 'Death Rate'
FROM  covidportfolio.covid_death
where	location = 'United States'
order by 1,2;

-- Total Cases VS Population --

SELECT  location, date, total_cases, population,  (total_cases/population)*100 AS 'Case Rate by Population'
FROM  covidportfolio.covid_death
order by 1,2;

SELECT  location, date, total_cases, population,  (total_cases/population)*100 AS 'Case Rate by Population'
FROM  covidportfolio.covid_death
where location = 'Canada'
order by 1,2;


-- Finding highest infection rate per location by covid_death by population --

SELECT  location, population, max(total_cases) as 'Highest Infection Count', max( (total_cases/population))*100 as 'Highest Infection Rate'
FROM  covidportfolio.covid_death
group by location, population
order by 4 desc;

-- show location with highest death count per population --
SELECT  location,  max(total_deaths) as 'HighestDeathCount'
FROM  covidportfolio.covid_death
where continent is not null
group by location
order by 'HighestDeathCount' desc;

-- Breaking down data by continent --
SELECT  location, continent, max(total_deaths) as 'HighestDeathCount'
FROM  covidportfolio.covid_death
where location is not null
group by continent 
order by 3 desc;

-- Data for Visuals --
-- Global Numbers -- 
-- Calculating Global Death Percentage by date --
--  Total Global Death Percentage --
select  sum(new_cases) as TotalCases, sum(new_deaths) as TotalDeaths, (sum(new_deaths)/sum(new_cases))*100 as 'GlobalDeathPercentage'
from covidportfolio.covid_death
where continent is not null;

--  Total Global Death Percentage by Date --
select  date, sum(new_cases) as TotalCases, sum(new_deaths)as TotalDeaths, (sum(new_deaths)/sum(new_cases))*100 as 'GlobalDeathPercentage'
from covidportfolio.covid_death
where continent is not null
group by date
order by 1, 4;

-- JOIN Tables coivd_death and covid_vacination --
select *
from covidportfolio.covid_death d
join covidportfolio.covid_vacination v
	on d.location = v.location
    and d.date = v.date
 order by d.location asc; 
 
 -- Data comparison for Total Population vs Total Vacination  --
 
 select d.continent, d.location, d.population, v.date, v.new_vaccinations
from covidportfolio.covid_death d
join covidportfolio.covid_vacination v
	on d.location = v.location
    and d.date = v.date
where d.continent is not null
order by 2,4 asc; 

-- Creating a Rolling Count of New Vacinations --
--  Using Partion By and Window Function --

 select d.continent, d.location, d.population, v.date, v.new_vaccinations, 
		sum(v.new_vaccinations) over (partition by d.location order by d.location, v.date) as 'TotalVaccinatedPopulace'
from covidportfolio.covid_death d
join covidportfolio.covid_vacination v
	on d.location = v.location
    and d.date = v.date
where d.continent is not null
order by 2,4 asc;

 -- Show how many people from a country are vaccinated --
 -- CTE Mehod --
 with populationVSvaccinations  (continent, location, population, date,  new_vaccinations, TotalVaccinatedPopulace)
 as
(
select d.continent, d.location, d.population, v.date, v.new_vaccinations, 
		sum(v.new_vaccinations) over (partition by d.location order by d.location, v.date) as 'TotalVaccinatedPopulace'
from covidportfolio.covid_death d
join covidportfolio.covid_vacination v
	on d.location = v.location
    and d.date = v.date
where d.continent is not null
order by 2,4 asc

)
select *, (TotalVaccinatedPopulace/population)*100 
from populationVSvaccinations;

 -- Show how many people from a country are vaccinated --
 -- Temp Table Mehod --
 
 drop table if exists PercentagePopulaceVaccinated;
 create table PercentagePopulaceVaccinated
 (	continent text,
    location text,
    population bigint,
    date date,
    new_vaccinations bigint,
    TotalVaccinatedPopulace int
    );
    insert into PercentagePopulaceVaccinated
 
 select d.continent, d.location, d.population, v.date, v.new_vaccinations, 
		sum(v.new_vaccinations) over (partition by d.location order by d.location, v.date) as 'TotalVaccinatedPopulace'
from covidportfolio.covid_death d
join covidportfolio.covid_vacination v
	on d.location = v.location
    and d.date = v.date
where d.continent is not null
order by 2,4 asc;

select *, (TotalVaccinatedPopulace/population)*100 
from PercentagePopulaceVaccinated;

-- Create View for Visualizations --
-- View called Percentage_Populace_Vaccinated--

USE covidportfolio;
CREATE  OR REPLACE 
VIEW `Percentage_Populace_Vaccinated` 
AS
	select d.continent, d.location, d.population, v.date, v.new_vaccinations, 
		sum(v.new_vaccinations) over (partition by d.location order by d.location, v.date) as 'TotalVaccinatedPopulace'
	from covidportfolio.covid_death d
	join covidportfolio.covid_vacination v
		on d.location = v.location
			and d.date = v.date
	where d.continent is not null
	order by 2,4 asc;
    
-- Create View for Visualizations --
-- View called Global_Covid_Deaths
--    USE `covidportfolio`;
-- CREATE  OR REPLACE VIEW `Global_Covid_Deaths` AS
	-- select  date, sum(new_cases) as TotalCases, sum(new_deaths)as TotalDeaths, (sum(new_deaths)/sum(new_cases))*100 as 'GlobalDeathPercentage'
	-- from covidportfolio.covid_death
	-- where continent is not null
	-- group by date
	-- order by 1, 4;
 






