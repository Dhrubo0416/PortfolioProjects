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




--Creating view to store the data for later visualizations

create view PercentPopulationVaccinated as
select Death.continent,Death.location,Death.date,Death.population,Vaccine.new_vaccinations
,sum(convert(bigint,Vaccine.new_vaccinations)) over (partition by Death.location order by Death.location,Death.date) as Rolling_People_Vaccinated
from Portfolioproject..Coviddeath as Death
join Portfolioproject..Covidvaccination as Vaccine
	on death.location = Vaccine.location
	and Death.date = Vaccine.date
where  Death.continent is not null
