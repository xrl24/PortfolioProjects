Select *
From PortfolioProject..Coviddeath$
order by 3,4

Select *
From PortfolioProject..Covidvaccination$
order by 3,4

Select location,date,new_vaccinations
From PortfolioProject..Covidvaccination$
where location like '%Canada%'
order by 1,2


-- seleting columns of interest

Select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..Coviddeath$
order by 1,2



-- Looking at total deaths/total cases 
-- Shows likelihood of dying if got covid
-- (filter total_cases > 0 to avoid division by 0)

Select location, date, total_deaths, total_cases, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..Coviddeath$
where total_cases > 0
--AND location like '%Canada%' 
order by 1,2



-- Looking at total cases/population 
-- shows what percentage of population got covid

Select 
    location, 
	date, 
	total_cases, 
	population, 
	(total_cases/population)*100 as CovidInfectionPercentage
From PortfolioProject..Coviddeath$
--Covid Infection Percentage in Canada
--where location like '%Canada%' 
order by 1,2



--Looking at countries with highest infection rate compared to population

Select 
    location, 
	population,
	max(total_cases) as HighestInfectionCount, 
	max(total_cases/population)*100 as HighestInfectionPercentage
From PortfolioProject..Coviddeath$
--where location like '%Canada%' 
group by Location, population
order by HighestInfectionPercentage desc



--Showing countries with highest Death Count per population

Select 
    location, 
	population, 
	max(total_deaths) as HighestDeathCount
From PortfolioProject..Coviddeath$
--where location like '%Canada%' 
where continent is not null
group by Location, population
order by HighestDeathCount desc
 


-- By CONTINENT
-- Showing continent with the highest death count per population

Select 
    location, 
	max(total_deaths) as HighestDeathCount
From PortfolioProject..Coviddeath$
where continent is null
group by location
order by HighestDeathCount desc




--Global Numbers

Select 
    sum(new_cases) as total_cases, 
	sum(new_deaths) as total_deaths, 
    (sum(new_deaths)/sum(new_cases))*100 as DeathPercentage
From PortfolioProject..Coviddeath$
where continent is not null
order by 1,2




--Looking at Total Population vs Vaccinations

Select 
    dea.continent,
	dea.location, 
	dea.date, 
	dea.population, 
	vac.new_vaccinations, 
	sum(convert(bigint,vac.new_vaccinations)) 
	    OVER (Partition by dea.location Order by dea.location,dea.date) as RollingPeopleVaccinated
From PortfolioProject..Coviddeath$ dea
Join PortfolioProject..Covidvaccination$ vac
    On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3



-- CTE

With PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
Select 
    dea.continent, 
	dea.location, 
	dea.date, 
	dea.population,
	vac.new_vaccinations, 
	sum(convert(bigint,vac.new_vaccinations)) 
	    OVER (Partition by dea.location Order by dea.location
		  ,dea.date) as RollingPeopleVaccinated
From PortfolioProject..Coviddeath$ dea
Join PortfolioProject..Covidvaccination$ vac
    On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
)

Select *, (RollingPeopleVaccinated/population)*100 
From PopvsVac 
--where location like '%Canada%'




-- Creating View to store data for later visualization

Go
Create View PercentPopulationVacccinated as
Select
    dea.continent, 
	dea.location, 
	dea.date, 
	dea.population, 
	vac.new_vaccinations,
	sum(convert(bigint,vac.new_vaccinations)) 
	    OVER (Partition by dea.location Order by dea.location,dea.date) as RollingPeopleVaccinated,
    (sum(convert(bigint,vac.new_vaccinations)) 
	    OVER (Partition by dea.location Order by dea.location,dea.date)/population) * 100 as PercentPopulationVaccinated
From PortfolioProject..Coviddeath$ dea
Join PortfolioProject..Covidvaccination$ vac
    On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
Go

Select *
From PercentPopulationVacccinated

--Drop view PercentPopulationVacccinated
