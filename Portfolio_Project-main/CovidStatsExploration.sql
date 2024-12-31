--This organizes the dataset in ASCENDING order

SELECT * 
FROM CovidDeaths
WHERE continent is NOT NULL
ORDER BY 3,4


--Looking at Total Cases VS Total Deaths
--This shows the death percentage till that particular day
SELECT location, date, total_cases, total_deaths, (total_deaths / total_cases)*100 AS Death_Percentage
FROM CovidDeaths
WHERE location like 'India'
AND continent is NOT NULL
ORDER BY 1,2


--Looking at Total Cases VS Population
--This shows the Covid Case percentage till that particular day
SELECT location, date, total_cases, population, (total_cases / population)*100 AS Covid_Percentage
FROM CovidDeaths
WHERE continent is NOT NULL
ORDER BY 1,2


--This shows the highest Infected Region 
SELECT location, population, MAX(total_cases) AS Highest_Cases, (MAX(total_cases)/population)*100 AS Highest_Infection_Rate
FROM CovidDeaths
WHERE continent is NOT NULL
GROUP BY location, population 
ORDER BY 4 Desc


--Showing Countries with Highest Death Count per population
SELECT location, MAX(CAST(total_deaths	AS int)) AS TotalDeathCount
FROM CovidDeaths
WHERE continent is NOT NULL
GROUP BY location
ORDER BY TotalDeathCount DESC

--LETS BREAKDOWN THINGS USING CONTINENT


--Showing the continents with highest death count per population
SELECT continent, MAX(CAST(total_deaths	AS int)) AS TotalDeathCount
FROM CovidDeaths
WHERE continent is not NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC

--GLOBAL NUMBERS
SELECT date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM CovidDeaths
WHERE continent is NOT NULL
GROUP BY date
ORDER BY 1,2

--Looking at Total Vaccinations Till Day
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CAST(vac.new_vaccinations as int)) 
OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS Total_Vaccinations_Till_Day
FROM CovidDeaths dea
JOIN CovidVaccinations vac
ON dea.location = vac.location
and dea.date = vac.date
WHERE dea.continent is NOT NULL
ORDER BY 2,3


--Looking at Total Population VS Vaccinations 
--Using CTE
WITH PopVsVac(continent, location, date, population, new_vaccinations,Total_Vaccinations_Till_Day)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CAST(vac.new_vaccinations as int)) 
OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS Total_Vaccinations_Till_Day
FROM CovidDeaths dea
JOIN CovidVaccinations vac
ON dea.location = vac.location
and dea.date = vac.date
WHERE dea.continent is NOT NULL
)
SELECT *, (Total_Vaccinations_Till_Day / population)*100 AS PopVsVac 
FROM PopVsVac 


--Using Temp Table
DROP TABLE if Exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
Date datetime,
population numeric,
new_vaccinations numeric,
Total_Vaccinations_Till_Day numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int,vac.new_vaccinations)) 
OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS Total_Vaccinations_Till_Day
FROM CovidDeaths dea
JOIN CovidVaccinations vac
ON dea.location = vac.location
and dea.date = vac.date
--WHERE dea.continent is NOT NULL
SELECT *, (Total_Vaccinations_Till_Day / population)*100 AS PopVsVac 
FROM #PercentPopulationVaccinated 

--CREATING VIEW TO STORE DATA FOR LATER VISUALISATION
CREATE VIEW PercentPopulationVaccinated
as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CAST(vac.new_vaccinations as int)) 
OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS Total_Vaccinations_Till_Day
FROM CovidDeaths dea
JOIN CovidVaccinations vac
ON dea.location = vac.location
and dea.date = vac.date
WHERE dea.continent is NOT NULL

SELECT * FROM PercentPopulationVaccinated