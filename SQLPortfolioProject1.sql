
/*
Covid 19 Data Exploration 
Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types
*/


-- Select Data that we are going to be starting with
SELECT location,date,population,total_cases,new_cases,total_deaths
from dbo.CovidDeaths
order by 1,2,3



--LOOKING AT TOTAL CASES VS TOTAL DEATHS
-- This shows the likelihood of dying when infected with the covid virus in United states

SELECT location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as percentage_death_rate
from dbo.CovidDeaths
where location like '%states%'
order by 1,2,3



--LOOKING AT TOTAL POPULATION VERSUS TOTAL CASES
--This shows the prevalence of covid in United States

SELECT location,date,population,total_cases,(total_cases/population)*100 as percentage_prevalence_rate
from dbo.CovidDeaths
where location like '%states%'
order by 1,2,3



---LOOKING AT COUNTRIES WITH THE HIGHEST INFECTION RATE COMPARED TO POPULATION

SELECT location,population,max(total_cases) as highest_infection_count,max(total_cases/population)*100 as percentage_prevalence_rate
from dbo.CovidDeaths
--where location like '%states%'
where continent is not null
group by location,population
order by percentage_prevalence_rate desc



--THIS SHOWS TOP COUNTRIES WITH THE HIGHEST DEATH COUNT 

SELECT location,MAX(CAST(total_deaths as int)) as total_death_count
from dbo.CovidDeaths
--where location like '%states%'
where continent is not null
group by location
order by total_death_count desc



--BELOW SHOWS CONTINENTS WITH THE HIGHEST DEATH COUNT
SELECT continent,MAX(CAST(total_deaths as int)) as total_death_count
from dbo.CovidDeaths
--where location like '%states%'
where continent is not null
group by continent
order by total_death_count desc



--TOTAL COVID CASES VERSUS TODAY DEATHS DUE TO COVIDS 
Select sum(new_cases) as total_newcases, sum(cast(new_deaths as int)) as total_newdeaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as death_percentage
from dbo.CovidDeaths
where continent is not null
order by 1,2



-- COVID CASES VERSUS DEATHS DUE TO COVIDS ON A DIALY BASIS
Select date, sum(new_cases) as total_newcases, sum(cast(new_deaths as int)) as total_newdeaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as death_percentage
from dbo.CovidDeaths
where continent is not null
group by date
order by 1,2,3


select *
FROM dbo.CovidVaccinations

select*
FRom dbo.CovidDeaths



--TOTAL POPULATION VERSUS TOTAL VACCINATED POPULATION
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations, SUM(cast (vac.new_vaccinations as int)) over(partition by dea.location
order by dea.location,dea.date) as rollingvaccinatedcount
from CovidDeaths dea
join CovidVaccinations vac
on dea.location = vac.location
and dea.date= vac.date
where dea.continent is not null
order by 2,3



--BELOW WOULD FURTHER SHOW THE DIALY PERCENTAGE INCREASE OF PEOPLE GETTING VACCINATED (WITH CTE)
with popvsvac(continent,location,date,population,new_vaccinations,rollingvaccinatedcount)
as
(
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations, SUM(cast (vac.new_vaccinations as int)) over(partition by dea.location
order by dea.location,dea.date) as rollingvaccinatedcount
from CovidDeaths dea
join CovidVaccinations vac
on dea.location = vac.location
and dea.date= vac.date
where dea.continent is not null
)
select*,(rollingvaccinatedcount/population)*100 as dialy_percentage_increase_in_vaccination
from popvsvac




--BELOW WOULD FURTHER SHOW THE DIALY PERCENTAGE INCREASE OF PEOPLE GETTING VACCINATED (WITH TEMP TABLE)
DROP TABLE IF exists #vaccinated_population_in_percentage
CREATE TABLE #vaccinated_population_in_percentage
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
rolling_vaccinated_count numeric
)


INSERT INTO #vaccinated_population_in_percentage
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations, SUM(cast (vac.new_vaccinations as int)) over(partition by dea.location
order by dea.location,dea.date) as rollingvaccinatedcount
from CovidDeaths dea
join CovidVaccinations vac
on dea.location = vac.location
and dea.date= vac.date
where dea.continent is not null

select*,(rolling_vaccinated_count/population)*100 as dialy_percentage_increase_in_vaccination
from #vaccinated_population_in_percentage




--CREATING VIEW TO STORE DATA FOR VISUALIZATION LATER
--create view vaccinated_population_in_percentage
create view vaccinated_population_in_percentage as
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations, SUM(cast (vac.new_vaccinations as int)) over(partition by dea.location
order by dea.location,dea.date) as rollingvaccinatedcount
from CovidDeaths dea
join CovidVaccinations vac
on dea.location = vac.location
and dea.date= vac.date
where dea.continent is not null


--create view for CONTINENTS WITH THE HIGHEST DEATH COUNT
create view CONTINENTSWITHHIGHESTDEATHCOUNT as
SELECT continent,MAX(CAST(total_deaths as int)) as total_death_count
from dbo.CovidDeaths
--where location like '%states%'
where continent is not null
group by continent




