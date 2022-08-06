/*
Covid 19 Data Exploration 

Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

*/


select *
from Portfolioproject..Coviddeath
where continent is not null
order by 3,4


--Selection of data that we are going to be using

select location, date, total_cases,new_cases,total_deaths,population
from Portfolioproject..Coviddeath
order by 1,2




-- Total Cases vs Total Deaths
-- Shows the likelihood of dying if you contract covid in your country

select location, date, total_cases,total_deaths,(total_deaths/total_cases)*100 as Death_Percentage
from Portfolioproject..Coviddeath
where location like 'india'
order by 1,2




-- Looking at Total cases vs Population
-- Shows what percentage of population got Covid

select location, date, total_cases,population,(total_cases/population)*100 as Infected_by_Covid_Percentage
from Portfolioproject..Coviddeath
--where location like 'india'
order by 1,2



-- Looking at countries with Highest Infection Rate compared to Population

select location,Max(total_cases) as Highest_infection_Count,population,max((total_cases/population))*100 as Max_Infected_by_Covid_Percentage
from Portfolioproject..Coviddeath
--where location like 'india'
group by population,location
order by  Max_Infected_by_Covid_Percentage desc



--Showing Countries with Highest Death counts as per Population

select location,Max(cast (total_deaths as int)) as Total_Death_Count
from Portfolioproject..Coviddeath
--where location like 'india'
where continent is not null
group by location
order by Total_Death_Count desc




--let's try it for Continents with Highest Death counts per population

select continent,Max(cast (total_deaths as int)) as Total_Death_Count
from Portfolioproject..Coviddeath
--where location like 'india'
where continent is not null
group by continent
order by Total_Death_Count desc



--GLOBAL NUMBERS
--Showing Total_cases vs Total_deaths and Death_percentage also per date Globally

select date, sum(new_cases) as Total_cases_per_date,sum(cast(new_deaths as int)) as Total_deaths_per_date,(sum(cast(new_deaths as int))/ sum(new_cases))*100 as Death_Percentage_Global_per_date
from Portfolioproject..Coviddeath
where continent is not null
group by date
order by 1,2



--Showing Total_cases vs Total_deaths and Death_percentage Globally

select  sum(new_cases) as Total_cases,sum(cast(new_deaths as int)) as Total_deaths,(sum(cast(new_deaths as int))/ sum(new_cases))*100 as Death_Percentage_Global
from Portfolioproject..Coviddeath
where continent is not null
order by 1,2




-- JOIN both the Death and Vaccination tables

select *
from Portfolioproject..Coviddeath as Death
join Portfolioproject..Covidvaccination as Vaccine
	on death.location = Vaccine.location
	and Death.date = Vaccine.date




-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

select Death.continent,Death.location,Death.date,Death.population,Vaccine.new_vaccinations
from Portfolioproject..Coviddeath as Death
join Portfolioproject..Covidvaccination as Vaccine
	on death.location = Vaccine.location
	and Death.date = Vaccine.date
where   Death.continent is not null
order by 2,3





--Trying to get the total no. of New_Vaccinations order by Locations for each loactions.

select Death.continent,Death.location,Death.date,Death.population,Vaccine.new_vaccinations
,sum(convert(bigint,Vaccine.new_vaccinations)) over (partition by Death.location order by Death.location,Death.date) as Rolling_People_Vaccinated
from Portfolioproject..Coviddeath as Death
join Portfolioproject..Covidvaccination as Vaccine
	on death.location = Vaccine.location
	and Death.date = Vaccine.date
where   Death.continent is not null
order by 2,3






-- Using CTE to perform Calculation on Partition By in previous query

with PopvsVac(continent,location,date,population,new_vaccinations,Rolling_People_Vaccinated)
as
(
select Death.continent,Death.location,Death.date,Death.population,Vaccine.new_vaccinations
,sum(convert(bigint,Vaccine.new_vaccinations)) over (partition by Death.location order by Death.location,Death.date) as Rolling_People_Vaccinated
from Portfolioproject..Coviddeath as Death
join Portfolioproject..Covidvaccination as Vaccine
	on death.location = Vaccine.location
	and Death.date = Vaccine.date
where  Death.continent is not null
)
select * ,(Rolling_People_Vaccinated)/population * 100 as Percentage_of_People_Vaccinated
from PopvsVac




-- Using Temp Table to perform Calculation on Partition By in previous query

drop table if exists  #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
Rolling_People_Vaccinated numeric
)

insert into #PercentPopulationVaccinated
select Death.continent,Death.location,Death.date,Death.population,Vaccine.new_vaccinations
,sum(convert(bigint,Vaccine.new_vaccinations)) over (partition by Death.location order by Death.location,Death.date) as Rolling_People_Vaccinated
from Portfolioproject..Coviddeath as Death
join Portfolioproject..Covidvaccination as Vaccine
	on death.location = Vaccine.location
	and Death.date = Vaccine.date
where  Death.continent is not null

select * ,(Rolling_People_Vaccinated)/population * 100 as Percentage_of_People_Vaccinated
from #PercentPopulationVaccinated






/*
	Queries used for Tableau Visualization
*/



-- 1. For getting total death percentage

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From Portfolioproject..Coviddeath
where continent is not null 
order by 1,2



-- 2. To get the total number of Deaths per Continent.
--    for location specific no. of deaths we can assign continent as not null .
--    have removed the records we don't want in the list like income division.

Select location, SUM(cast(new_deaths as int)) as TotalDeathCount
From Portfolioproject..Coviddeath
Where continent is null 
and location not in ('World', 'European Union', 'International','Upper middle income','High income','Lower middle income','Low income')
Group by location
order by TotalDeathCount desc


-- 3. To get value of PercentPopulationInfected from Total cases and Population.

Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From Portfolioproject..Coviddeath
Group by Location, Population
order by PercentPopulationInfected desc


-- 4. To get value of PercentPopulationInfected from Total cases and Population per day.

Select Location, Population,date, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From Portfolioproject..Coviddeath
Group by Location, Population, date
order by PercentPopulationInfected desc












-- Queries I originally had, but excluded some because it created too long of video
-- Here only in case you want to check them out


-- 1.

Select death.continent, death.location, death.date, death.population
, MAX(vaccine.total_vaccinations) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From Portfolioproject..Coviddeath death
Join Portfolioproject..Covidvaccination vaccine
	On death.location = vaccine.location
	and death.date = vaccine.date
where death.continent is not null 
group by death.continent, death.location, death.date, death.population
order by 1,2,3




-- 2.
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From Portfolioproject..Coviddeath
--Where location like '%states%'
where continent is not null 
--Group By date
order by 1,2


-- Just a double check based off the data provided
-- numbers are extremely close so we will keep them - The Second includes "International"  Location


--Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
--From PortfolioProject..CovidDeaths
----Where location like '%states%'
--where location = 'World'
----Group By date
--order by 1,2


-- 3.

-- We take these out as they are not inluded in the above queries and want to stay consistent
-- European Union is part of Europe

Select location, SUM(cast(new_deaths as int)) as TotalDeathCount
From Portfolioproject..Coviddeath
--Where location like '%states%'
Where continent is null 
and location not in ('World', 'European Union', 'International')
Group by location
order by TotalDeathCount desc



-- 4.

Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From Portfolioproject..Coviddeath
--Where location like '%states%'
Group by Location, Population
order by PercentPopulationInfected desc



-- 5.

--Select Location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
--From PortfolioProject..CovidDeaths
----Where location like '%states%'
--where continent is not null 
--order by 1,2

-- took the above query and added population
Select Location, date, population, total_cases, total_deaths
From Portfolioproject..Coviddeath
--Where location like '%states%'
where continent is not null 
order by 1,2


-- 6. 


With PopvsVac (Continent, Location, Date, Population, new_Vaccinations, Rolling_People_Vaccinated)
as
(
Select death.continent, death.location, death.date, death.population, vaccine.new_vaccinations
, SUM(CONVERT(int,vaccine.New_vaccinations)) OVER (Partition by death.Location Order by death.location, death.Date) asRolling_People_Vaccinated
--, (RollingPeopleVaccinated/population)*100
From Portfolioproject..Coviddeath death
Join Portfolioproject..Covidvaccination vaccine
	On death.location = vaccine.location
	and death.date = vaccine.date
where death.continent is not null 
--order by 2,3
)
Select *, (Rolling_People_Vaccinated/Population)*100 as PercentPeopleVaccinated
From PopvsVac


-- 7. 

Select Location, Population,date, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From Portfolioproject..Coviddeath
--Where location like '%states%'
Group by Location, Population, date
order by PercentPopulationInfected desc





