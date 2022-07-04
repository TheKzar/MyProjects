SELECT location, date, total_cases, new_cases, total_deaths, population 
FROM CovidDeaths


--Total Cases vs Total Deaths
-- THIS SHOWS THE PERCENTAGE OF DEATHS IN NIGERIA FROM COVID BTWN 2020-2021

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM CovidDeaths
WHERE location LIKE '%nigeria' 
AND continent is not null

-------------------------
-- SHOWS WHAT PERCENTAGE OF POPULATION GOT COVID IN NIGERIA BTWN 2020-2021

SELECT location, date, population, total_cases, (total_cases/population)*100 AS PercentOfPopulationInfected
FROM CovidDeaths
WHERE location LIKE '%nigeria'
AND continent is not null


---COUNTRIES WITH THE HIGHEST INFECTION RATE

SELECT location, population, MAX (total_cases) AS HihgestInfectionCount, MAX ((total_cases/population))*100 AS PercentOfPopulationInfected
FROM CovidDeaths 
--WHERE location LIKE '%nigeria'
WHERE continent is not null
GROUP BY location, population
ORDER BY PercentOfPopulationInfected DESC


---COUNTRIES WITH THE HIGHEST DEATH COUNT PER POPULATION

SELECT location, MAX (cast(total_deaths as int)) AS TotalDeathCount
FROM CovidDeaths 
--WHERE location LIKE '%nigeria'
WHERE continent is not null
GROUP BY location
ORDER BY TotalDeathCount DESC

---- BY CONTNIENT 

---MAX DEATH COUNT BY CONTITNENT

SELECT continent, MAX (cast(total_deaths as int)) AS TotalDeathCount
FROM CovidDeaths 
--WHERE location LIKE '%nigeria'
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount DESC


------GLOBAL NUMBERS


SELECT SUM (new_cases) AS TotalCases, SUM (cast(new_deaths as int)) AS TotalDeaths, SUM (cast(new_deaths as int))/ SUM (new_cases) * 100 AS DeathPercentage
FROM CovidDeaths
--WHERE location LIKE '%nigeria' 
WHERE continent is not null
--GROUP BY date

---- TOTAL POPULATION VS VACCINATION 

SELECT dea.continent, dea.location, dea.date, dea.population,  vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM CovidDeaths dea
JOIN CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null


----WITH CTE

WITH POPVSVAC (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population,  vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM CovidDeaths dea
JOIN CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
)

SELECT *, (RollingPeopleVaccinated/Population) * 100
FROM POPVSVAC



---CREATING VIEWS FOR VISUALIZATION 

CREATE VIEW POPVSVAC AS
SELECT dea.continent, dea.location, dea.date, dea.population,  vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM CovidDeaths dea
JOIN CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null

SELECT *
FROM POPVSVAC