-- Select Data that we are going to be starting with

Select Location, date, total_cases, new_cases, total_deaths, population
From [Coviddeaths ]
Order by 1,2

--Datatype changes

Alter Table dbo.Coviddeaths
Alter column total_Cases float
go

Alter Table dbo.Coviddeaths
Alter column total_deaths float
go


-- Total Cases vs Total Deaths

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From [Coviddeaths ]
Where total_deaths is not null
and location Like '%States%'
Order by 1,2

--Total cases vs Population

Select Location, date, total_cases, population, (total_cases/population)*100 as PercentofPopulationInfected
From [Coviddeaths ]
Where total_deaths is not null
and location Like '%States%'
Order by 1,2

-- Countries with Highest Infection Rate compared to Population

Select Location, population,Max(total_cases) as HighestInfectionCount, (Max(total_cases) /population)*100 as PercentPopulationInfected
From [Coviddeaths ]
--Where total_deaths is not null
Group by Location,population
Order by PercentPopulationInfected desc

---- Countries with Highest Death Count per Population

Select Location, population,Max(total_deaths) as HighestDeathCount, (Max(total_deaths) /population)*100 as PercentPopulationDied
From [Coviddeaths ]
--Where continent is not null
Group by Location,population
Order by  PercentPopulationDied desc

-- GLOBAL NUMBERS

--Select total_cases,new_cases, total_deaths,new_deaths ,(total_deaths/total_cases)*100 as DeathPercentage
--From [Coviddeaths ]
----Where total_deaths is not null
--Where continent is  not null
--Order by 1,2

--Select *
--From [Coviddeaths ]

-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

Select dea.location,dea.continent,dea.date,dea.population,vac.new_vaccinations,
Sum(cast(vac.new_vaccinations as float))over (Partition by dea.location Order by dea.location,dea.date)
From [Coviddeaths ] dea
Inner join CovidVaccinations vac
On dea.location= vac.location
AND dea.date= vac.date
Where dea.continent is not null
Order by 1,2,3

-- Using CTE to perform Calculation on Partition By in previous query

With popVSvac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
AS
(
Select dea.location,dea.continent,dea.date,dea.population,vac.new_vaccinations,
Sum(cast(vac.new_vaccinations as float))over (Partition by dea.location Order by dea.location,dea.date) as RollingPeopleVaccinated
From [Coviddeaths ] dea
Inner join CovidVaccinations vac
On dea.location= vac.location
AND dea.date= vac.date
Where dea.continent is not null
--Order by 1,2,3
)
Select *,(RollingPeopleVaccinated/Population)*100 as Percentofpopvsvac
From popVSvac

-- Using Temp Table to perform Calculation on Partition By in previous query

Drop table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(Location Nvarchar(255),
Continent Nvarchar(255),
Date Date,
Population Numeric,
NewVaccinations Numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.location,dea.continent,dea.date,dea.population,vac.new_vaccinations,
Sum(cast(vac.new_vaccinations as float))over (Partition by dea.location Order by dea.location,dea.date) as RollingPeopleVaccinated
From [Coviddeaths ] dea
Inner join CovidVaccinations vac
On dea.location= vac.location
AND dea.date= vac.date
Where dea.continent is not null
Order by 1,3

Select *,(RollingPeopleVaccinated/Population)*100 as Percentofpopvsvac
From #PercentPopulationVaccinated

--Creating View to store the Data

Create View PercentPopulationVaccinated2 as
Select dea.location,dea.continent,dea.date,dea.population,vac.new_vaccinations,
Sum(cast(vac.new_vaccinations as float))over (Partition by dea.location Order by dea.location,dea.date) as RollingPeopleVaccinated
From [Coviddeaths ] dea
Inner join CovidVaccinations vac
On dea.location= vac.location
AND dea.date= vac.date
Where dea.continent is not null
--Order by 1,3