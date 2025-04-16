--View all column from each table--
SELECT *
FROM CovidDeaths
WHERE continent is not null

SELECT *
FROM CovidVaccinations

--Data that are going to be used--

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM CovidDeaths
ORDER BY 1,2


--Looking at Total Cases vs Total Deaths
--Shows the probability of death, if you catch COVID in your country
--Use this CONCAT((total_cases/population)*100, '%') for adding "%" into rows
SELECT Location, date, total_cases, total_deaths, CONCAT((total_deaths/total_cases)*100, '%') AS 'DeathPercentage'
FROM CovidDeaths
--WHERE Location = 'United States'
ORDER BY 1,2


--Lookling at Total Cases vs Population
--Shows what percentage of population got COVID by country
SELECT Location, date, population, total_cases, CONCAT((total_cases/population)*100, '%') AS 'PopulationCasesPercentage'
FROM CovidDeaths
WHERE Location = 'United States'
ORDER BY 1,2


--Looking at countries with hihghest infection rate compared to population
SELECT Location, Population, MAX(total_cases) AS 'HighestInfectionCount', MAX((total_cases/population))*100 AS 'PopulationInfectedPercentage'
FROM CovidDeaths
GROUP BY Location, population
ORDER BY PopulationInfectedPercentage DESC


--Showing countries with the highest death count per population
--Because total_deaths uses varchar as the data type from the original file, we can cast/convert it into INT
SELECT Location, MAX(CAST(total_deaths AS INT)) AS 'TotalDeathCount'
FROM CovidDeaths
--For countries data only, not fully contintents
WHERE continent is not null
Group BY Location
ORDER BY TotalDeathCount DESC


--BY CONTINENT

--Shows total death count by continents
SELECT Location, MAX(CAST(total_deaths AS INT)) AS 'TotalDeathCount'
FROM CovidDeaths
WHERE continent is null
Group BY location
ORDER BY TotalDeathCount DESC


--Showing continents with the highest death count per population
SELECT Continent, MAX(CAST(total_deaths AS INT)) AS 'TotalDeathCount'
FROM CovidDeaths
WHERE continent is not null
Group BY continent
ORDER BY TotalDeathCount DESC


--Global Numbers
SELECT SUM(new_cases) AS 'total_cases', SUM(cast(new_deaths AS INT)) AS 'total_deatch', SUM(cast(new_deaths AS INT)) / SUM(new_cases)*100 AS 'DeathPercentage'
FROM CovidDeaths
WHERE continent is not null
ORDER BY 1,2

--View all column
--Looking at Total Population vs Vaccinations
SELECT cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations
FROM CovidDeaths cd
JOIN CovidVaccinations cv 
ON cd.location = cv.location and cd.date = cv.date
WHERE cd.continent is not null
ORDER BY 2,3

SELECT cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations,
 SUM(CONVERT(INT, cv.new_vaccinations)) OVER (Partition BY cd.location ORDER BY cd.location, cd.date) AS 'RollingPeopleVaccinated'
FROM CovidDeaths cd
JOIN CovidVaccinations cv 
ON cd.location = cv.location and cd.date = cv.date
WHERE cd.continent is not null
ORDER BY 2,3

--USE CTE
WITH PopulatoinVsVaccination (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated) 
AS
(
	SELECT cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations
	, SUM(CONVERT(INT, cv.new_vaccinations)) OVER (Partition BY cd.location ORDER BY cd.location, cd.date) AS 'RollingPeopleVaccinated'
	FROM CovidDeaths cd
	JOIN CovidVaccinations cv 
	ON cd.location = cv.location and cd.date = cv.date
	WHERE cd.continent is not null
)
SELECT *, (RollingPeopleVaccinated/population)*100
FROM PopulatoinVsVaccination


--TEMP TABLE

CREATE TABLE PercentPopulationVaccinated (
continent varchar(255),
Location varchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO PercentPopulationVaccinated
SELECT cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations
, SUM(CONVERT(INT, cv.new_vaccinations)) OVER (Partition BY cd.location ORDER BY cd.location, cd.date) AS 'RollingPeopleVaccinated'
FROM CovidDeaths cd
JOIN CovidVaccinations cv 
ON cd.location = cv.location and cd.date = cv.date
--WHERE cd.continent is not null

SELECT *, (RollingPeopleVaccinated/Population)*100
FROM PercentPopulationVaccinated


--Creating view to store data for later visualization
CREATE VIEW PercentagePopulationVaccinated AS 
SELECT cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations
, SUM(CONVERT(INT, cv.new_vaccinations)) OVER (Partition BY cd.location ORDER BY cd.location, cd.date) AS 'RollingPeopleVaccinated'
FROM CovidDeaths cd
JOIN CovidVaccinations cv 
ON cd.location = cv.location and cd.date = cv.date
WHERE cd.continent is not null


SELECT *
FROM PercentagePopulationVaccinated
