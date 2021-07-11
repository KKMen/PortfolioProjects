/****** Script for SelectTopNRows command from SSMS  ******/
SELECT *
  FROM PortfolioProject..CovidDeaths
  order by 3,4


  SELECT *
  FROM PortfolioProject..CovidVaccination
  order by 3,4

  --Select the data that we are going to use

  SELECT location, date, total_cases, new_cases, total_deaths, population
  FROM PortfolioProject..CovidDeaths
  order by 1,2

  -- looking at total cases vs total deaths
  -- shows the likelihood of contracting covid
  SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100  AS DeathPercentage 
  FROM PortfolioProject..CovidDeaths
  Where location like '%states%'
  order by 1,2

  -- Looking at the total cases vs population

  SELECT location, date, total_cases, new_cases, population, 
	ROUND((total_cases/population)*100, 4) as DeathPercentage
  FROM PortfolioProject..CovidDeaths
  order by 1,2

  -- GLOBAL NUMBERS

  Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths,
	ROUND(SUM(cast(new_deaths as int))/ SUM(New_Cases)*100,2) as DeathPercentage
From PortfolioProject..CovidDeaths
Where continent is not null
--Group By date
order by 1,2

-- Joining Tables / Looking at total population vs Total Vaccicantion

Select *
From PortfolioProject..CovidDeaths cdea
Join PortfolioProject..CovidVaccination cvac
	on cdea.location = cvac.location
	and cdea.date = cvac.date
	order by 3,4

-- Looking at a few columns

Select cdea.continent, cdea.location, cdea.date, cdea.population, cvac.new_vaccinations
From PortfolioProject..CovidDeaths cdea
Join PortfolioProject..CovidVaccination cvac
	on cdea.location = cvac.location
	and cdea.date = cvac.date
	where cdea.continent is not null
	order by 2,3

	-- world distinct population

Select DISTINCT (cdea.location),cdea.population 
from PortfolioProject..CovidDeaths cdea
where cdea.continent is not null

-- rolling count

Select cdea.continent, cdea.location, cdea.date, cdea.population, cvac.new_vaccinations,
SUM(CONVERT(int, cvac.new_vaccinations)) OVER (Partition by cdea.location order by cdea.location,cdea.date) AS RollingpeopleVaccinated
--(RollingpeopleVaccinated/cdea.population)*100 as PercentageVaccinated
From PortfolioProject..CovidDeaths cdea
Join PortfolioProject..CovidVaccination cvac
	on cdea.location = cvac.location
	and cdea.date = cvac.date
	where cdea.continent is not null
	order by 2,3

-- USING CTE

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingpeopleVaccinated)
as
(
Select cdea.continent, cdea.location, cdea.date, cdea.population, cvac.new_vaccinations,
SUM(CONVERT(int, cvac.new_vaccinations)) OVER (Partition by cdea.location order by cdea.location,
cdea.date) AS RollingpeopleVaccinated
--(RollingpeopleVaccinated/cdea.population)*100 as PercentageVaccinated
From PortfolioProject..CovidDeaths cdea
Join PortfolioProject..CovidVaccination cvac
	on cdea.location = cvac.location
	and cdea.date = cvac.date
	where cdea.continent is not null
	--order by 2,3
)
Select * , (RollingpeopleVaccinated/population)*100
From PopvsVac

Select cdea.continent, cdea.location, cdea.date, cdea.population, cvac.new_vaccinations,
SUM(CONVERT(int, cvac.new_vaccinations)) OVER (Partition by cdea.location order by cdea.location,cdea.date) AS RollingpeopleVaccinated
--(RollingpeopleVaccinated/cdea.population)*100 as PercentageVaccinated
From PortfolioProject..CovidDeaths cdea
Join PortfolioProject..CovidVaccination cvac
	on cdea.location = cvac.location
	and cdea.date = cvac.date
	where cdea.continent is not null
	order by 2,3


	-- Create table and drop teble if exist
Drop Table if exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
date datetime,
Population numeric,
New_Vaccinations numeric,
RollingpeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
Select cdea.continent, cdea.location, cdea.date, cdea.population, cvac.new_vaccinations,
	SUM(convert(numeric, cvac.new_vaccinations)) OVER (Partition by cdea.location order by cdea.location,
	cdea.date) as RollingpeopleVaccinated
--(RollingpeopleVaccinated/cdea.population)*100 as PercentageVaccinated
From PortfolioProject..CovidDeaths cdea
Join PortfolioProject..CovidVaccination cvac
	on cdea.location = cvac.location
	and cdea.date = cvac.date
--where cdea.continent is not null
--order by 2,3

Select *, (RollingpeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

--Creating Views to store data for visualisations later

Drop View PercentPopulationVaccinated
CREATE View PercentPopulationVaccinated as
Select cdea.continent, cdea.location, cdea.date, cdea.population, cvac.new_vaccinations,
	SUM(convert(numeric, cvac.new_vaccinations)) OVER (Partition by cdea.location order by cdea.location,
	cdea.date) as RollingpeopleVaccinated
--(RollingpeopleVaccinated/cdea.population)*100 as PercentageVaccinated
From PortfolioProject..CovidDeaths cdea
Join PortfolioProject..CovidVaccination cvac
	on cdea.location = cvac.location
	and cdea.date = cvac.date
where cdea.continent is not null
--order by 2,3

Select * from PercentPopulationVaccinated

