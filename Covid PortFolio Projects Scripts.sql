SELECT *
FROM PortfolioProject.[dbo].[Covid Deaths EXCEL]
WHERE continent is not null
ORDER BY 3,4

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject.[dbo].[Covid Deaths EXCEL]
ORDER BY 1,2

--Total Cases vs Total Deaths 
--Shows Likelihood of dying if you contract covid in your country

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProject.[dbo].[Covid Deaths EXCEL]
WHERE location like '%somalia%'
and continent is not null
ORDER BY 1,2

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProject.[dbo].[Covid Deaths EXCEL]
WHERE location like '%states%'
ORDER BY 1,2

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProject.[dbo].[Covid Deaths EXCEL]
WHERE location like '%united kingdom%'
ORDER BY 1,2

-- Percentage of Population Infected with covid


SELECT location, date, population, total_cases, (total_cases/population)*100 AS DeathPercentage
FROM PortfolioProject.[dbo].[Covid Deaths EXCEL]
WHERE location like '%united kingdom%'
ORDER BY 1,2

SELECT location, date, population, total_cases, (total_cases/population)*100 AS DeathPercentage
FROM PortfolioProject.[dbo].[Covid Deaths EXCEL]
WHERE location like '%somalia%'
ORDER BY 1,2

SELECT location, date, population, total_cases, (total_cases/population)*100 AS DeathPercentage
FROM PortfolioProject.[dbo].[Covid Deaths EXCEL]
WHERE location like '%china%'
ORDER BY 1,2

--Which country has the highest rate of infection when compared to its population?

 SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS PercentangeOfPopulationInfected
FROM PortfolioProject.[dbo].[Covid Deaths EXCEL]
--WHERE location like '%united kingdom%'
GROUP BY Location, Population
ORDER BY PercentangeOfPopulationInfected desc


--Which country have the highest death count per population?

 SELECT location, MAX(Total_deaths) AS TotalDeathCount
 FROM PortfolioProject.[dbo].[Covid Deaths EXCEL]
--WHERE location like '%united kingdom%'
WHERE Continent Is Not Null
GROUP BY Location
ORDER BY TotalDeathCount desc
 
  --Looking at the Continent with the highest death count per population

 SELECT Continent, MAX(Total_deaths) AS TotalDeathCount
 FROM PortfolioProject.[dbo].[Covid Deaths EXCEL]
--WHERE location like '%united kingdom%'
WHERE Continent Is not Null
GROUP BY Continent
ORDER BY TotalDeathCount desc
 
--Gblobal Numbers 

Select location, SUM(cast(new_deaths as int)) as TotalDeathCount
From PortfolioProject.[dbo].[Covid Deaths EXCEL]
--Where location like '%states%'
Where continent is null 
and location not in ('World', 'European Union', 'International')
Group by location
order by TotalDeathCount desc

SELECT date, SUM(new_cases), SUM(cast(new_deaths as int)), SUM(cast(new_deaths as int))/SUM(New_cases)*100 as DeathPercentage
FROM PortfolioProject..[Covid Deaths EXCEL]
--WHERE location like '%somalia%'
WHERE continent is not null
Group By date
ORDER BY 1,2


--I createda case becasue the previous calculations were not working as expected

SELECT 
SUM(new_cases),
Sum(cast(new_deaths as int)),
Case When Sum(new_cases)=0 THEN 0 
ELSE SUM(cast(new_deaths as int))/SUM(new_cases)*100
END AS DeathPercentage
FROM PortfolioProject..[Covid Deaths EXCEL]
--WHERE location like '%somalia%'
WHERE continent is not null 
ORDER BY 1,2

--Looking at Total Population vs Vaccinations


SELECT dea.continent, dea.location,dea.date, dea.population, vac.new_vaccinations
,SUM(Convert(int,vac.new_vaccinations)) OVER (Partition By dea.location)
FROM PortfolioProject.[dbo].[Covid Deaths EXCEL] Dea
JOIN PortfolioProject..CovidVaccinations Vac
ON Dea.Location = Vac.location
and Dea.date = Vac.date
WHERE dea.continent is not null
ORDER BY 1,2,3


SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations 
,SUM(CAST(vac.new_vaccinations as int)) OVER (Partition by dea.location ORDER BY dea.location, dea.date)
as CumulativeVaccinationCount
--(CumulativeVaccinationCount/population)*100
FROM PortfolioProject.[dbo].[Covid Deaths EXCEL] dea
JOIN PortfolioProject..CovidVaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent is not null  
ORDER BY 2,3

--CTE 

 WITH PopvsVac (Continent, Location, Date, Population, New_vaccinations, CumulativeVaccinationCount)
 AS 
 (
 SELECT dea.continent, dea.location, dea.date, dea.population, Vac.New_Vaccinations
,SUM(CAST(vac.new_vaccinations as int)) OVER (Partition by dea.location ORDER BY dea.location, dea.date)as CumulativeVaccinationCount
--(CumulativeVaccinationCount/population)*100
FROM PortfolioProject.[dbo].[Covid Deaths EXCEL] dea
JOIN PortfolioProject..CovidVaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3
)
SELECT*, (CumulativeVaccinationCount/Population)*100
FROM PopvsVac

--Temp Table 

Create Table #PercentPopulationVaccinated
(
Continent Nvarchar(255),
Location Nvarchar(255),
Date Datetime,
Population Numeric,
New_Vaccinations Numeric,
CumulativeVaccinationCount numeric
)
Insert into #PercentPopulationVaccinated
 SELECT dea.continent, dea.location, dea.date, dea.population, Vac.New_Vaccinations
,SUM(CAST(vac.new_vaccinations as int)) OVER (Partition by dea.location ORDER BY dea.location, dea.date)as CumulativeVaccinationCount
--(CumulativeVaccinationCount/population)*100
FROM PortfolioProject.[dbo].[Covid Deaths EXCEL] dea
JOIN PortfolioProject..CovidVaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3

SELECT*, (CumulativeVaccinationCount/Population)*100
FROM #PercentPopulationVaccinated

--Using the Drop Clause (Use this WHEN Making any ALTERATIONS

DROP Table If Exists ##PercentPopulationVaccinated
Create Table #PercentagePopulationVaccination
(
Continent Nvarchar(255),
Location Nvarchar(255),
Date Datetime,
Population Numeric,
New_Vaccinations Numeric,
CumulativeVaccinationCount numeric
)
Insert into #PercentPopulationVaccinated
 SELECT dea.continent, dea.location, dea.date, dea.population, Vac.New_Vaccinations
,SUM(CAST(vac.new_vaccinations as int)) OVER (Partition by dea.location ORDER BY dea.location, dea.date)as CumulativeVaccinationCount
--(CumulativeVaccinationCount/population)*100
FROM PortfolioProject.[dbo].[Covid Deaths EXCEL] dea
JOIN PortfolioProject..CovidVaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
--WHERE dea.continent is not null
--ORDER BY 2,3

SELECT*, (CumulativeVaccinationCount/Population)*100
FROM #PercentPopulationVaccinated


--Creating View To store Data For Later 


Create View PercentPopulationVaccinated AS 
 SELECT dea.continent, dea.location, dea.date, dea.population, Vac.New_Vaccinations
,SUM(CAST(vac.new_vaccinations as int)) OVER (Partition by dea.location ORDER BY dea.location, dea.date)as CumulativeVaccinationCount
--(CumulativeVaccinationCount/population)*100
FROM PortfolioProject.[dbo].[Covid Deaths EXCEL] dea
JOIN PortfolioProject..CovidVaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent is not Null
--ORDER BY 2,3

SELECT *
FROM PercentPopulationVaccinated

