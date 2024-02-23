Select * 
from PortfolioProject..CovidDeaths
WHERE continent is not null 
order by 3,4

--Select * 
--from PortfolioProject..CovidVaccinations
--order by 3,4

/*SELECTING DATA AM GOING TO BE USING*/

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM CovidDeaths
ORDER BY 1, 2

--Looking at total cases vs total deaths
--This shows likelyhood of dying from contracting covid in your country

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM CovidDeaths
WHERE location like '%igeria%'
ORDER BY 1, 2

SELECT location, date, total_cases, total_deaths, 
(total_deaths/total_cases)*100 AS DeathPercentage
FROM CovidDeaths
WHERE location like '%states%'
ORDER BY 1, 2

--Looking at Total cases vs Population
--This shows what percentage of Population got Covid
SELECT location, date, population, total_cases
, (total_cases/population)*100 AS PercentPopulationInfected, total_deaths
, (total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
--WHERE location like '%states%'
ORDER BY 1, 2  

--Looking at Countries with highest infection rate compared to population
SELECT location, population, MAX(total_cases) AS HighestInfectionCount
, MAX(total_cases/population)*100 AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
--WHERE location like '%states%'
GROUP BY location, population
ORDER BY 4 DESC

--Showing Countries with Highest Death COunt per Population
SELECT location
, MAX(CAST(total_deaths AS int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
--WHERE location like '%states%'
WHERE continent is not null     --##########
--GROUP BY location
GROUP BY continent
ORDER BY TotalDeathCount DESC

--LET'S BREAK THINGS DOWN BY CONTINENT
SELECT continent
, MAX(CAST(total_deaths AS int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
--WHERE location like '%states%'
WHERE continent is not null     --##########
GROUP BY continent
ORDER BY TotalDeathCount DESC

/*check
   
SELECT location
, MAX(CAST(total_deaths AS int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
--WHERE location like '%states%'
WHERE continent is null     --##########
GROUP BY location
ORDER BY TotalDeathCount DESC

*/

-- Showing continents with the highest death count per population

SELECT continent
, MAX(CAST(total_deaths AS int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
--WHERE location like '%states%'
WHERE continent is not null     --##########
GROUP BY continent
ORDER BY TotalDeathCount DESC


--GLOBAL NUMBERS

SELECT date, SUM(new_cases) AS total_cases
, SUM(CAST(new_deaths AS INT)) AS total_deaths
,SUM(CAST(new_deaths AS INT))/SUM(new_cases)*100 AS DeathPercentage
FROM CovidDeaths
--WHERE location like '%igeria%'
WHERE continent is not null
GROUP BY date
ORDER BY 1, 2

--SELECT --date, 
--SUM(new_cases) AS total_cases
--, SUM(CAST(new_deaths AS INT)) AS total_deaths
--,SUM(CAST(new_deaths AS INT))/SUM(new_cases)*100 AS DeathPercentage
--FROM CovidDeaths
----WHERE location like '%igeria%'
--WHERE continent is not null
----GROUP BY date
--ORDER BY 1, 2

--LOOKING AT TOTAL POPULATION VS VACCINATIONS
SELECT dea.continent, dea.location, dea.date
, dea.population, vac.new_vaccinations
FROM PortfolioProject..CovidDeaths AS dea
JOIN PortfolioProject..CovidVaccinations AS vac
	ON dea.location = vac.location
	AND	dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3

SELECT dea.continent, dea.location, dea.date
, dea.population, vac.new_vaccinations
, SUM(CONVERT(INT, vac.new_vaccinations)) --OR CAST( vac.new_vaccinations998, AS INT)
OVER (PARTITION BY dea.location ORDER BY dea.location
, dea.date) AS RollingPeopleVaccinated
--(RollingPeopleVaccinated/Population)*100
FROM PortfolioProject..CovidDeaths AS dea
JOIN PortfolioProject..CovidVaccinations AS vac
	ON dea.location = vac.location
	AND	dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3
  

--##Using CTE to resolve this error##
--"Incorrect syntax near 'RollingPeopleVaccinated'"

WITH PopVsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated) 
--ALL THE COLUMNS OF THE QUERY BELOW HAVE TO BE  INCLUDED 4 THIS CAN WORK
AS
(
-- ****I DON'T KNOW WHY I'M GETTING DUPLICATE ENTRIES IN COLUMNS :
-- new_vaccinations & RollingPeopleVaccinated???????
SELECT dea.continent, dea.location, dea.date
, dea.population, vac.new_vaccinations
, SUM(CONVERT(INT, vac.new_vaccinations)) --OR CAST( vac.new_vaccinations998, AS INT)
OVER (PARTITION BY dea.location ORDER BY dea.location
, dea.date) AS RollingPeopleVaccinated
--(RollingPeopleVaccinated/Population)*100
FROM PortfolioProject..CovidDeaths AS dea
JOIN PortfolioProject..CovidVaccinations AS vac
	ON dea.location = vac.location
	AND	dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3  ##COS OF ....invalid ERROR
)

SELECT *, (RollingPeopleVaccinated/Population)*100
FROM PopVsVac



--##USING TEMP TABLE##

DROP TABLE IF EXISTS #PercentPopulationVaccinated --IF YOU'RE GONNA BE MAKING LOTS OF CHANGES

CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255)
, Location nvarchar(255)
, Date datetime
, Population numeric
, new_vaccinations numeric
, RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date
, dea.population, vac.new_vaccinations
, SUM(CONVERT(INT, vac.new_vaccinations)) --OR CAST( vac.new_vaccinations998, AS INT)
OVER (PARTITION BY dea.location ORDER BY dea.location
, dea.date) AS RollingPeopleVaccinated
--(RollingPeopleVaccinated/Population)*100
FROM PortfolioProject..CovidDeaths AS dea
JOIN PortfolioProject..CovidVaccinations AS vac
	ON dea.location = vac.location
	AND	dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3 


SELECT *, (RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated


-- CREATING VIEW TO STORE DATA FOR LATER VIZs

CREATE VIEW PercentPopulationVaccinated
AS
SELECT dea.continent, dea.location, dea.date
, dea.population, vac.new_vaccinations
, SUM(CONVERT(INT, vac.new_vaccinations)) --OR CAST( vac.new_vaccinations998, AS INT)
OVER (PARTITION BY dea.location ORDER BY dea.location
, dea.date) AS RollingPeopleVaccinated
--(RollingPeopleVaccinated/Population)*100
FROM PortfolioProject..CovidDeaths AS dea
JOIN PortfolioProject..CovidVaccinations AS vac
	ON dea.location = vac.location
	AND	dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3 

SELECT * 
FROM PercentPopulationVaccinated
