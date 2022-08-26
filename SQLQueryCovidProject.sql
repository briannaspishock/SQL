---Running queries to view the table to ensure we have the right datasets imported
Select *
From CovidProject..CovidDeaths
Where continent is not null
Order By 3,4

--Select *
--From CovidProject..CovidVaccinations
--Order By 3,4

--Select the data that we are going to be using

Select location, date, total_cases, new_cases, total_deaths, population
From CovidProject..CovidDeaths
Where continent is not null
Order By 1,2

-- Look at Total Cases vs Total Deaths
-- Shows the likelihood of dying if you contract Covid in US
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From CovidProject..CovidDeaths
Where location like '%states%'
And continent is not null
Order By 1,2

-- Look at Total Cases vs Population
-- Shows what percentage of the population has contracted Covid
Select location, date, total_cases, population, (total_cases/population)*100 as ContractedCovid
From CovidProject..CovidDeaths
Where location like '%states%'
And continent is not null
Order By 1,2
-- Look at countries with the highest infection rate compared to population
Select location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentInfected
From CovidProject..CovidDeaths
Where continent is not null
Group By location, population
Order By PercentInfected DESC

--Look at countries with the highest death count per population
Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
From CovidProject..CovidDeaths
Where continent is not null
Group By location
Order By TotalDeathCount DESC

-- Look at data coming in from continents 

--Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
--From CovidProject..CovidDeaths
--Where continent is null
--Group By location
--Order By TotalDeathCount DESC

-- Showing the continents with the highest death count per population
Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From CovidProject..CovidDeaths
Where continent is not null
Group By continent
Order By TotalDeathCount DESC

Select continent, date, total_cases, new_cases, total_deaths, population
From CovidProject..CovidDeaths
Where continent is not null
Order By 1,2

-- Shows the likelihood of dying if you contract Covid
Select continent, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From CovidProject..CovidDeaths
Where continent is not null
Order By 1,2

-- Shows what percentage of the population has contracted Covid
Select continent, date, total_cases, population, (total_cases/population)*100 as ContractedCovid
From CovidProject..CovidDeaths
Where continent is not null
Order By 1,2

-- Look at countries with the highest infection rate compared to population
Select continent, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentInfected
From CovidProject..CovidDeaths
Where continent is not null
Group By continent, population
Order By PercentInfected DESC

-- Global numbers
-- Must do some aggregate functions to sort by date
Select date, sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
From CovidProject..CovidDeaths
Where continent is not null
Group By date
Order By 1,2

Select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
From CovidProject..CovidDeaths
Where continent is not null
Order By 1,2

--Look at Total Popultion vs Vaccinations 
-- Partion by location for new vaccinations, use bigint instead of int for large vac
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(cast (vac.new_vaccinations as bigint)) over (partition by dea.location Order By dea.location, 
dea.date) as RollingPeopleVaccinated
From CovidProject..CovidDeaths dea
Join CovidProject..CovidVaccinations vac
	On dea.location = vac.location 
	And dea.date = vac.date
Where dea.continent is not null
Order by 2,3

-- How many people in the country are vaccinated 
-- Use CTE 

With PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as 
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(cast (vac.new_vaccinations as bigint)) over (partition by dea.location Order By dea.location, 
dea.date) as RollingPeopleVaccinated
From CovidProject..CovidDeaths dea
Join CovidProject..CovidVaccinations vac
	On dea.location = vac.location 
	And dea.date = vac.date
Where dea.continent is not null
)
Select * , (RollingPeopleVaccinated/population)*100
From PopvsVac

--TEMP TABLE
-- Drop table so you don't have to close view
Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(cast (vac.new_vaccinations as bigint)) over (partition by dea.location Order By dea.location, 
dea.date) as RollingPeopleVaccinated
From CovidProject..CovidDeaths dea
Join CovidProject..CovidVaccinations vac
	On dea.location = vac.location 
	And dea.date = vac.date
Where dea.continent is not null

Select * , (RollingPeopleVaccinated/population)*100
From #PercentPopulationVaccinated

--Create view to store data for later visualizations

Create View PercentPopulationVaccinated as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location Order By dea.location, 
dea.date) as RollingPeopleVaccinated
From CovidProject..CovidDeaths dea
Join CovidProject..CovidVaccinations vac
	On dea.location = vac.location 
	And dea.date = vac.date
Where dea.continent is not null

Select *
PercentPopulationVaccinated 