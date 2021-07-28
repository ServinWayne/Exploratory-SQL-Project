-- Selecting the data that we are going to be using:
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM CovidDeaths
WHERE continent IS NOT NULL
ORDER BY location

-- Taking a look at Total Cases vs Total Deaths
-- This shows the likelyhood of death if you contract COVID-19 by country.
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS death_percentage
FROM CovidDeaths
WHERE location LIKE '%states%'
AND continent IS NOT NULL
ORDER BY location, date

-- Looking at Total Cases vs Population
-- Shows what percentage of the population has gotten covid
SELECT location, date, total_cases, population, (total_cases/population)*100 AS infected_percentage
FROM CovidDeaths
WHERE location LIKE '%states%'
and continent IS NOT NULL
ORDER BY location, date

-- Checking to see which countries have highest infection rates compared to population
SELECT location, population, MAX(total_cases) AS highest_infection_count, MAX((total_cases/population))*100 AS percent_infected
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY percent_infected DESC

-- Checking to see which countries have highest death count compared to population
SELECT location, MAX(cast(total_deaths AS INT)) AS total_deaths
FROM CovidDeaths
WHERE continent IS NULL
GROUP BY location
ORDER BY total_deaths DESC

-- Lets check the same but with continents instead of countries
SELECT continent, MAX(cast(total_deaths AS INT)) AS total_deaths
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY total_deaths DESC

-- Global Numbers:
SELECT date, SUM(new_cases) AS total_cases, SUM(cast(new_deaths AS INT)) AS total_deaths, (SUM(cast(new_deaths AS INT))/SUM(new_cases))*100 AS death_percentage
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1, 2


-- Looking at Total Population vs Vaccination using CTE.
WITH pop_vs_vac (continent, location, date, population, new_vaccinations, rolling_vaccination_count)
AS 
(
SELECT cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations, SUM(cast(cv.new_vaccinations as INT)) 
	OVER (PARTITION BY cd.location ORDER BY cd.location, cd.date) AS rolling_vaccination_count
FROM CovidDeaths cd
JOIN CovidVaccinations cv
	ON cd.location = cv.location
	and cd.date = cv.date
WHERE cd.continent IS NOT NULL
)
SELECT *, (rolling_vaccination_count/population)*100 
FROM pop_vs_vac

-- Creating a view to store data for later visualizations
CREATE VIEW percent_population_vaccinated AS 
SELECT cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations, SUM(cast(cv.new_vaccinations as INT)) 
	OVER (PARTITION BY cd.location ORDER BY cd.location, cd.date) AS rolling_vaccination_count
FROM CovidDeaths cd
JOIN CovidVaccinations cv
	ON cd.location = cv.location
	and cd.date = cv.date
WHERE cd.continent IS NOT NULL