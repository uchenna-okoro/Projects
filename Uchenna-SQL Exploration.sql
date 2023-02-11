SELECT*
FROM CovidDeaths
Order by 3,4

Select*
From CovidVacinations

--Selecting Data we will be using
SELECT 
Location, date,total_cases, new_cases, total_deaths,population 
from CovidDeaths
Order by 1,2

--Selecting total cases vs total deaths

SELECT 
Location, date,total_cases, total_deaths,(total_cases/total_deaths)*100 As Deathpercentage ,population 
from CovidDeaths
where continent is not null
--Where Location Like '%Egypt%'
Order by 1,2

--showing percentage of population that got covid
SELECT 
Location, date,total_cases,population ,(total_cases/population)*100 As PercentageofInfectedPopulation 
from CovidDeaths
where continent is not null
--Where Location Like '%Egypt%'
--Group by Location,Population
Order by 1,2

---Looking at Countries with highest infection rate compared to population

SELECT 
Location,Max(total_cases) as MaxCase,Min(total_cases) as MinCase,population ,Max(total_cases/population)*100 As PercentageofHighestInfection
from CovidDeaths
where continent is not null
Group by Location,population
Order by PercentageofHighestInfection DESC

--Countries with highest death count

SELECT
Location,Max(Cast(total_deaths as int)) AS TotalDeathsCount
FROM CovidDeaths
where continent is not null
Group By Location
Order By TotalDeathsCount DESC


----Let's break it out by Continent
SELECT
continent,Max(Cast(total_deaths as int)) AS TotalDeathsCount
FROM CovidDeaths
where continent is not null
Group By continent
Order By TotalDeathsCount DESC

--Showing Continent with highest death count
SELECT
continent,Max(Cast(total_deaths as int)) AS TotalDeathsCount
FROM CovidDeaths
where continent is not null
Group By continent
Order By TotalDeathsCount DESC

--GLOBAL CASES

Select
Sum(new_cases)as totalcases,SUM(Cast(new_deaths as int)) as totalnewdeaths,SUM(Cast(new_deaths as int))/Sum(new_cases) *100 as Deathpercentage
From CovidDeaths
where continent is not null
--Group by date
Order by 1,2


---Covid Vacination Data
---joining death and vacination table

--looking at total population to vacinations

SELECT 
dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(Cast(vac.new_vaccinations as int)) OVER(Partition by dea.location order by dea.location,dea.date) as RollingPeopleVacinated
--,(RollingPeopleVacinated/population)*100
FROM CovidVacinations vac
JOIN CovidDeaths dea
ON dea.location=vac.location
AND dea.date=vac.date
Where dea.continent is not null
order by 1,2,3

---Use CTE
WITH popvsvac(continent,location,date,population,new_vacinations,RollingPeopleVacinated)
AS(
SELECT 
dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(Cast(vac.new_vaccinations as int)) OVER(Partition by dea.location order by dea.location,dea.date) as RollingPeopleVacinated
--,(RollingPeopleVacinated/population)*100
FROM CovidVacinations vac
JOIN CovidDeaths dea
ON dea.location=vac.location
AND dea.date=vac.date
Where dea.continent is not null
--order by 2,3

)
SELECT*,(RollingPeopleVacinated/population)*100
FROM popvsvac


---TEMP TABLE
--drop table if exist
DROP TABLE IF EXISTs #PercentPopulationVacinated
cREATE TABLE #PercentPopulationVacinated(
continent nvarchar(255),

location nvarchar(255),
date datetime,
population numeric,
new_vacinations numeric,
RollingPeopleVacinated numeric


)


INSERT INTO #PercentPopulationVacinated
SELECT 
dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(Cast(vac.new_vaccinations as int)) OVER(Partition by dea.location order by dea.location,dea.date) as RollingPeopleVacinated
--,(RollingPeopleVacinated/population)*100
FROM CovidVacinations vac
JOIN CovidDeaths dea
ON dea.location=vac.location
AND dea.date=vac.date
--Where dea.continent is not null
--order by 2,3

SELECT*,(RollingPeopleVacinated/population)*100
FROM #PercentPopulationVacinated


--CReate view table for later visualization
CREATE VIEW PercentPopulationVacinated as
SELECT 
dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(Cast(vac.new_vaccinations as int)) OVER(Partition by dea.location order by dea.location,dea.date) as RollingPeopleVacinated
--,(RollingPeopleVacinated/population)*100
FROM CovidVacinations vac
JOIN CovidDeaths dea
ON dea.location=vac.location
AND dea.date=vac.date
Where dea.continent is not null
--order by 2,3


---Viewing views

SELECT *
FROM PercentPopulationVacinated