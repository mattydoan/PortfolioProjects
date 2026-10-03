SELECT *
FROM CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 3,4;

# Convert date column to DATE type

UPDATE CovidDeaths SET date = STR_TO_DATE(date, '%m/%d/%y');
ALTER TABLE CovidDeaths MODIFY date DATE;

UPDATE CovidVaccinations SET date = STR_TO_DATE(date, '%m/%d/%y');
ALTER TABLE CovidVaccinations MODIFY date DATE;

# Select Data that we are going to be using

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1, 2;

# Looking at Total Cases vs Total Deaths
# Shows likelihood of dying if you contract COVID in your country 

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases) * 100 AS DeathPercentage
FROM CovidDeaths
WHERE location like '%States%'
ORDER BY 1, 2; 

# Looking at Total Cases vs population
# Shows what percentage of population got Covid

SELECT location, date, population, total_cases, (total_cases/population) * 100 AS InfectionPercentage
FROM CovidDeaths
#WHERE location like '%States%'
ORDER BY 1, 2; 

# Looking at Countries with highest Infection Rate compared to Population

SELECT Location, Population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population)) * 100 AS InfectionPercentage
FROM CovidDeaths
#WHERE location like '%States%'
GROUP BY location, population
ORDER BY InfectionPercentage DESC;

# Showing Countires with Highest Death Count per Population

SELECT Location, MAX(total_deaths) AS TotalDeathCount
FROM CovidDeaths
#WHERE location like '%States%'
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount DESC;

# Breaking things down by continent
# Showing Continents with highest death count per population

SELECT Continent, SUM(new_deaths) AS TotalDeathCount
FROM CovidDeaths
#WHERE location like '%States%'
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC;

# Global numbers

SELECT date, SUM(new_cases) AS total_cases, SUM(new_deaths) AS total_deaths, SUM(new_deaths)/SUM(new_cases) * 100 AS DeathPercentage
FROM CovidDeaths
WHERE continent is not null
GROUP BY date
ORDER BY 1, 2; 

# Global numbers

SELECT SUM(new_cases) AS total_cases, SUM(new_deaths) AS total_deaths, SUM(new_deaths)/SUM(new_cases) * 100 AS DeathPercentage
FROM CovidDeaths
WHERE continent is not null
ORDER BY 1, 2; 

# Looking at Total Population vs Vaccinations
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(vac.new_vaccinations) OVER(PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM CovidDeaths AS dea
JOIN CovidVaccinations AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2, 3;
		
# USE CTE

WITH PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated) AS 
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(vac.new_vaccinations) OVER(PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM CovidDeaths AS dea
JOIN CovidVaccinations AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
#ORDER BY 2, 3
)

SELECT *, (RollingPeopleVaccinated/Population) * 100
FROM PopvsVac;

# TEMP TABLE

DROP TABLE IF EXISTS PercentPopulationVaccinated
CREATE TABLE PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(vac.new_vaccinations) OVER(PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM CovidDeaths AS dea
JOIN CovidVaccinations AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2, 3

SELECT *, (RollingPeopleVaccinated/Population) * 100
FROM PercentPopulationVaccinated;

# Creating View to store data for later visualizations

Create View PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(vac.new_vaccinations) OVER(PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM CovidDeaths AS dea
JOIN CovidVaccinations AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL;

SELECT *
FROM percentpopulationvaccinated
