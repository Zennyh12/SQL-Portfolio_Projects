select*
from PortfolioProjects..CovidDeaths
Where continent is not null
order by 3,4

--select*
--from PortfolioProjects..CovidVaccinations
--order by 3,4

--Select Data that we are going to be using

SELECT location, date, total_cases, new_cases, total_deaths, population
from PortfolioProjects..CovidDeaths
Where continent is not null
order by 1,2

--Looking at total cases vs total deaths
----Shows likelihood of dying if you contract COVID in the US

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
from PortfolioProjects..CovidDeaths
WHERE location like '%states%' AND continent is not null
order by 1,2

--Looking at Total Cases vs Population
----Shows percentage of population got Covid in US
SELECT location, date, total_cases, population, (total_cases/population)*100 AS Percentage_Pop_Infected
from PortfolioProjects..CovidDeaths
WHERE location like '%states%' AND continent is not null
order by 1,2

--Looking at Countries with Highest Infection Rate compared to Population

SELECT location, population, MAX(total_cases) as Highest_Infection_Count,MAX((total_cases/population)*100) AS Percent_Pop_Infected
from PortfolioProjects..CovidDeaths
Where continent is not null
Group By location, population
order by Percent_Pop_Infected desc

--Showing Countries with Highest Death Count per Population
SELECT location, MAX(cast(total_deaths as int)) as Total_Death_Count
From PortfolioProjects..CovidDeaths
Where continent is not null
Group By location
order by Total_Death_Count desc

--By Continent
SELECT continent, MAX(cast(total_deaths as int)) as Total_Death_Count
From PortfolioProjects..CovidDeaths
Where continent is not null
Group By continent
order by Total_Death_Count desc

--Global Deaths per day

SELECT date, SUM(new_cases) as Total_Cases, Sum(cast(new_deaths as int)) as Total_Deaths, Sum(cast(new_deaths as int))/SUM(new_cases)*100 AS Death_Percentage
from PortfolioProjects..CovidDeaths
WHERE continent is not null
Group By date
order by 1,2

--Total Population vs Vaccination
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int,vac.new_vaccinations)) 
	OVER (Partition by dea.location Order by dea.location, dea.date) as Rolling_Count_People_Vac
From PortfolioProjects..CovidDeaths dea
JOIN PortfolioProjects..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
Order by 2,3

--CTE

With POPvsVAC (Continent, Location, Date, Population, new_vaccinations, Rolling_Count_People_Vac)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int,vac.new_vaccinations)) 
	OVER (Partition by dea.location Order by dea.location, dea.date) as Rolling_Count_People_Vac
From PortfolioProjects..CovidDeaths dea
JOIN PortfolioProjects..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--Order by 2,3
)

Select*, (Rolling_Count_People_Vac/Population)*100 as Percentage_Vac
From POPvsVAC


--TEMP Table
DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
Rolling_Count_People_Vac numeric
)

INSERT INTO #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int,vac.new_vaccinations)) 
	OVER (Partition by dea.location Order by dea.location, dea.date) as Rolling_Count_People_Vac
From PortfolioProjects..CovidDeaths dea
JOIN PortfolioProjects..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--Order by 2,3

Select*, (Rolling_Count_People_Vac/Population)*100 as Percentage_Vac
From #PercentPopulationVaccinated


--Creating View to store data for later visualizations

CREATE View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int,vac.new_vaccinations)) 
	OVER (Partition by dea.location Order by dea.location, dea.date) as Rolling_Count_People_Vac
From PortfolioProjects..CovidDeaths dea
JOIN PortfolioProjects..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--Order by 2,3