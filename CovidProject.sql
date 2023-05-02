Select *
FROM PortfolioProject.dbo.CovidDeaths$
Where continent is not null 
order by 3,4

--Select *
--FROM PortfolioProject.dbo.CovidVaccinations$
--order by 3, 4

--Select Data that we are going to be using

Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject.dbo.CovidDeaths$
Where continent is not null
order by 1,2 


--Looking at Total Cases vs Total Deaths


SELECT CAST(total_deaths As Integer) FROM PortfolioProject.dbo.CovidDeaths$


SELECT CAST(total_cases As Integer) FROM PortfolioProject.dbo.CovidDeaths$

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject.dbo.CovidDeaths$
order by 1, 2


--Looking at Total Cases vs Total Deaths
--Shows likelihood of dying if you contract covid in your country 

Select Location, date, total_cases, total_deaths, 100* CAST(total_deaths AS Integer)/CAST(total_cases AS Integer) as DeathPercentage
From PortfolioProject.dbo.CovidDeaths$
Where Location like '%states%'
And continent is not null
Order by 1, 2



--Looking at Total Cases vs Population
--Shows what percentage of population got Covid


Select Location, date, total_cases, Population, 100* CAST(total_cases AS Decimal)/CAST(Population AS Decimal) as PercentPopulationInfected
From PortfolioProject.dbo.CovidDeaths$
Where Location like '%states%'
Order by 1, 2

--Looking at Countries with Highest Infection Rate compared to Population

Select Location, Population, MAX(total_cases) as HighestInfectionCount, 100* MAX(CAST(total_cases AS Decimal)/CAST(Population AS Decimal)) as PercentPopulationInfected
From PortfolioProject.dbo.CovidDeaths$
--Where Location like '%states%'
Group by Location, Population
Order by PercentPopulationInfected desc
 

--Showing Countries with Highest Death Count per Population

Select Location, MAX(cast(total_deaths as int)) as TotalDeathCount 
From PortfolioProject.dbo.CovidDeaths$
--Where Location like '%states%'
Where continent is not null
Group by Location
Order by TotalDeathCount desc


--LET'S BREAK THINGS DOWN BY CONTINENT

--Showing continents with the highest death count per population

Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount 
From PortfolioProject.dbo.CovidDeaths$
--Where Location like '%states%'
Where continent is not null 
Group by continent
Order by TotalDeathCount desc


-- GlOBAL NUMBERS

Select SUM(new_cases), SUM(cast(new_deaths as int)), SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From PortfolioProject.dbo.CovidDeaths$
--Where Location like '%states%'
Where continent is not null 
--Group by date
Order by 1, 2

--Across the world, we are looking at a death percentage of a little under 1%

SET ANSI_WARNINGS ON

--Looking at Total Populaton vs Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as Decimal)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject.dbo.CovidDeaths$ dea 
Join PortfolioProject.dbo.CovidVaccinations$ vac
	On dea.location = vac.location 
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3 

--USE CTE
With PopvsVac (Continent, Location, Date, Population, new_vaccinations, RollingPeopleVaccinated) 
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as Decimal)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject.dbo.CovidDeaths$ dea 
Join PortfolioProject.dbo.CovidVaccinations$ vac
	On dea.location = vac.location 
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac

--TEMP TABLE

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime, 
Population numeric
New_vaccinations numeric
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as Decimal)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject.dbo.CovidDeaths$ dea 
Join PortfolioProject.dbo.CovidVaccinations$ vac
	On dea.location = vac.location 
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated


--Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as Decimal)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject.dbo.CovidDeaths$ dea 
Join PortfolioProject.dbo.CovidVaccinations$ vac
	On dea.location = vac.location 
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3


Select *
From PercentPopulationVaccinated 