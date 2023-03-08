SELECT *
FROM PortfolioProjectCovid..CovidDeaths
WHERE continent is not NULL
ORDER BY 3,4

--SELECT *
--FROM PortfolioProjectCovid..CovidVaccinations
----WHERE continent is not NULL
--ORDER BY 3,4



--Select data we will be using
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProjectCovid..CovidDeaths
WHERE continent is not NULL
ORDER BY 1,2



--Looking at Total Cases vs Total Deaths with rough percentage of DeathPercentage
--Likelihood of one dying if contracting COVID based by country
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProjectCovid..CovidDeaths
--WHERE location LIKE '%states%'
WHERE continent is not NULL
ORDER BY 1,2



--Looking at Total Cases vs Population
--Show what percentage of population got COVID
SELECT location, date, population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
FROM PortfolioProjectCovid..CovidDeaths
--WHERE location LIKE '%states%'
WHERE continent is not NULL
ORDER BY 1,2



--Countries with Highest Infection Rate compared to Population
SELECT location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as MaxPercentPopulationInfected
FROM PortfolioProjectCovid..CovidDeaths
--WHERE location LIKE '%states%'
WHERE continent is not NULL
GROUP BY location, population
ORDER BY MaxPercentPopulationInfected DESC



-- BROKEN DOWN BY CONTINENT

--**ignore for now, will test this query to ensure end product isn't disturbed
--SELECT location, MAX(CONVERT(INT, total_deaths)) as TotalDeathCount
--FROM PortfolioProjectCovid..CovidDeaths
--WHERE continent is NULL
--GROUP BY location
--ORDER BY TotalDeathCount DESC

--Continent: Highest Death Count per population
SELECT continent, MAX(CONVERT(INT, total_deaths)) as TotalDeathCount
FROM PortfolioProjectCovid..CovidDeaths
WHERE continent is not NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC

--Countries: Highest Death Count per Population
SELECT location, MAX(CONVERT(INT, total_deaths)) as TotalDeathCount
FROM PortfolioProjectCovid..CovidDeaths
WHERE continent is not NULL
GROUP BY location
ORDER BY TotalDeathCount DESC




----Global numbers
SELECT date, sum(new_cases) as total_new_cases, sum(cast(new_deaths as int)) as total_new_deaths, sum(cast(new_deaths as int))/Sum(new_cases)*100 as NewDeathPercentage
FROM PortfolioProjectCovid..CovidDeaths
WHERE continent is not null
GROUP BY date
ORDER BY 1,2


--Global Numbers: Total
SELECT SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_cases)*100 as DeathPercentage
FROM PortfolioProjectCovid..CovidDeaths
WHERE continent is not null
ORDER BY 1, 2


--Looking at Total Population vs Vaccinations
--Total amount of people who are vaccinated (per day)
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(CONVERT(INT, vac.new_vaccinations))
		OVER (PARTITION BY dea.location
		ORDER BY dea.location, dea.date) as VaccinationCountByCountry,
	--(VaccinationCountByCountry/population)*100
FROM PortfolioProjectCovid..CovidDeaths dea
JOIN PortfolioProjectCovid..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not NULL
ORDER BY 2,3


--USE CTE
WITH PopvsVac(continent, location, date, population, new_vaccinations, VaccinationCountByCountry)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(CONVERT(INT, vac.new_vaccinations))
		OVER (PARTITION BY dea.location
		ORDER BY dea.location, dea.date) as VaccinationCountByCountry
	--(VaccinationCountByCountry/population)*100
FROM PortfolioProjectCovid..CovidDeaths dea
JOIN PortfolioProjectCovid..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not NULL
)
SELECT *, (VaccinationCountByCountry/population)*100
FROM PopvsVac
ORDER BY 2, 3

--max**^^


--TEMP TABLE
DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
VaccinationCountByCountry numeric
)
INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(CONVERT(INT, vac.new_vaccinations))
		OVER (PARTITION BY dea.location
		ORDER BY dea.location, dea.date) as VaccinationCountByCountry
	--(VaccinationCountByCountry/population)*100
FROM PortfolioProjectCovid..CovidDeaths dea
JOIN PortfolioProjectCovid..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not NULL

SELECT *, (VaccinationCountByCountry/population)*100 as TotalPopulationVaccinated
FROM #PercentPopulationVaccinated
--ORDER BY 2, 3





--CREATING VIEW TO STORE DATA FOR LATER VISUALIZATIONS
CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(CONVERT(INT, vac.new_vaccinations))
		OVER (PARTITION BY dea.location
		ORDER BY dea.location, dea.date) as VaccinationCountByCountry
	--(VaccinationCountByCountry/population)*100
FROM PortfolioProjectCovid..CovidDeaths dea
JOIN PortfolioProjectCovid..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not NULL
----ORDER BY 2,3

SELECT *
FROM PercentPopulationVaccinated