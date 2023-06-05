Select *
From PortfolioProject..CovidDeaths
Where continent is not null
Order by 3,4

--Select *
--From PortfolioProject..CovidVaccinations
--Order by 3,4

-- Select Data that we are going to be using

Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
Order by 1,2


-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contracted covid
SELECT Location, date, CAST(total_cases AS float) AS total_cases, CAST(total_deaths AS float) AS total_deaths, (CAST(total_deaths AS float)/CAST(total_cases AS float))*100 AS DeathPercentage
FROM  PortfolioProject..CovidDeaths
Where location like '%states%'
and continent is not null
ORDER BY 1,2

-- Looking at Total Cases vs. Population
-- Shows what % of population gets Covid
SELECT Location, date, population, CAST(total_cases AS float) AS total_cases, CAST(population AS float) AS population, (CAST(total_cases AS float)/CAST(population AS float))*100 AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
Where location like '%states%'
ORDER BY 1,2

-- Looking at Countries with highest Infection Rate compared to Population
Select Location, Population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population)) *100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
-- Where location like '%states%'
Group by Location, population
order by PercentPopulationInfected desc

-- Showing Countries with Highest Death Count per Population
Select Location, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
-- Where location like '%states%'
Where continent is not null
Group by Location
order by TotalDeathCount desc


-- By Continent
Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
-- Where location like '%states%'
Where continent is not null
Group by continent
order by TotalDeathCount desc

-- GLOBAL NUMBERS
SELECT SUM(new_cases) as total_cases,SUM(CAST(new_deaths AS int)) as total_deaths,CASE WHEN SUM(new_cases) <> 0 THEN SUM(CAST(new_deaths AS int))/SUM(new_cases) * 100
ELSE 0
END AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
--GROUP BY date
ORDER BY 1,2


-- Looking at Total Population vs Vaccinations
with PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(Convert(bigint,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population) *100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
	WHERE dea.continent IS NOT NULL
	--order by 2,3
)
Select *, (RollingPeopleVaccinated/population)*100
From PopvsVac


--Temp Table
DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)
Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(Convert(bigint,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population) *100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
	--WHERE dea.continent IS NOT NULL
	--order by 2,3

Select *, (RollingPeopleVaccinated/population)*100
From #PercentPopulationVaccinated


-- Creating View to store data for later visualizations
Create view PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(Convert(bigint,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population) *100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
	WHERE dea.continent IS NOT NULL
	--order by 2,3

	Select *
	From PercentPopulationVaccinated