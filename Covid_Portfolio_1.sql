SELECT *
FROM coviddeaths;

SELECT *
FROM covidvaccines;

-- select the data which we gonna use

SELECT location,
	   str_to_date(date,'%d/%m/%Y') AS Date,
       total_cases,
       new_cases,
       total_deaths,
       population
FROM coviddeaths
ORDER BY 1,2;

-- Looking at the total cases vs total deaths
-- shows liklohood of dying if u contract covid in your country

SELECT location,
	   str_to_date(date,'%d/%m/%Y') AS Date,
       total_cases,
       total_deaths,
       (total_deaths/total_cases)*100 AS DeathPercentage
FROM coviddeaths
WHERE location LIKE '%STATES%'
ORDER BY 1,2;

-- Looking at total cases vs population
-- Shows what percentage of people got covid

SELECT location,
	   str_to_date(date,'%d/%m/%Y') AS Date,
       population,
       total_cases,
       (total_cases/population)*100 AS PositivityRate
FROM coviddeaths
WHERE location='INDIA'
-- WHERE location LIKE '%STATES%'
ORDER BY 1,2;

-- Looking at the countries which have highest percentage of covid infection


SELECT location,
       population,
       max(total_cases) as TotalDeaths,
       max((total_cases/population)*100) AS PositivityRate
FROM coviddeaths
GROUP BY location, population
ORDER BY PositivityRate desc;

-- Showing the countries which have highest death count as per population


SELECT location,
       population,
       max(total_deaths) as TotalDeaths,
       max((total_deaths/population)*100) AS FatilityRate
FROM coviddeaths
GROUP BY location, population
ORDER BY TotalDeaths desc;

-- Lets break things by continents
-- Showing the continent withh highest death count

SELECT continent,
       max(total_deaths) as TotalDeaths
FROM coviddeaths
GROUP BY continent
ORDER BY TotalDeaths desc;

-- Global Numbers

SELECT str_to_date(date,'%d/%m/%Y') AS Date,
       SUM(new_cases) as TotalCases,
       SUM(new_deaths) as TotalDeaths,
       SUM(new_deaths)/sum(new_cases)*100 as DeathPercentage
FROM coviddeaths
GROUP BY date
ORDER BY 1,2

-- Total Cases and deaths till 9th of july


SELECT SUM(new_cases) as TotalCases,
       SUM(new_deaths) as TotalDeaths,
       SUM(new_deaths)/sum(new_cases)*100 as DeathPercentage
FROM coviddeaths
-- GROUP BY date
ORDER BY 1,2

-- Joining both vaccine and death tables
-- Looking at total population vs vaccination

-- CTE
WITH popvsca(Continent, Location, Date, Population,New_Vaccination, RollingVaccineCount)
AS
(
SELECT dea.continent,
       dea.location,
       str_to_date(dea.date,'%d/%m/%Y') AS Date,
       dea.population,
       vac.new_vaccinations,
       SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.Date) as RollingVaccineCount
FROM coviddeaths dea
JOIN covidvaccines vac
on dea.location = vac.location
-- order by 2,3;
)
SELECT * , (RollingVaccineCount/Population)*100
FROM popvsxa

-- TEMP table
CREATE TABLE #PercentPopulatedVaccinated
(
continent TEXT
location TEXT
date DATETIME
population INT
newvaccination INT
rollingpeoplevaccination INT
)

INSERT INTO

SELECT dea.continent,
       dea.location,
       str_to_date(dea.date,'%d/%m/%Y') AS Date,
       dea.population,
       vac.new_vaccinations,
       SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.Date) as RollingVaccineCount
FROM coviddeaths dea
JOIN covidvaccines vac
on dea.location = vac.location
-- order by 2,3;

SELECT * , (RollingVaccineCount/Population)*100
FROM #PercentPopulatedVaccinated



