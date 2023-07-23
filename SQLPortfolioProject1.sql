SELECT TOP (1000) [iso_code]
      ,[continent]
      ,[location]
      ,[date]
      ,[total_cases]
      ,[new_cases]
      ,[new_cases_smoothed]
      ,[total_deaths]
      ,[new_deaths]
      ,[new_deaths_smoothed]
      ,[total_cases_per_million]
      ,[new_cases_per_million]
      ,[new_cases_smoothed_per_million]
      ,[total_deaths_per_million]
      ,[new_deaths_per_million]
      ,[new_deaths_smoothed_per_million]
      ,[reproduction_rate]
      ,[icu_patients]
      ,[icu_patients_per_million]
      ,[hosp_patients]
      ,[hosp_patients_per_million]
      ,[weekly_icu_admissions]
      ,[weekly_icu_admissions_per_million]
      ,[weekly_hosp_admissions]
      ,[weekly_hosp_admissions_per_million]
      ,[new_tests]
      ,[total_tests]
      ,[total_tests_per_thousand]
      ,[new_tests_per_thousand]
      ,[new_tests_smoothed]
      ,[new_tests_smoothed_per_thousand]
      ,[positive_rate]
      ,[tests_per_case]
      ,[tests_units]
      ,[total_vaccinations]
      ,[people_vaccinated]
      ,[people_fully_vaccinated]
      ,[new_vaccinations]
      ,[new_vaccinations_smoothed]
      ,[total_vaccinations_per_hundred]
      ,[people_vaccinated_per_hundred]
      ,[people_fully_vaccinated_per_hundred]
      ,[new_vaccinations_smoothed_per_million]
      ,[stringency_index]
      ,[population]
      ,[population_density]
      ,[median_age]
      ,[aged_65_older]
      ,[aged_70_older]
      ,[gdp_per_capita]
      ,[extreme_poverty]
      ,[cardiovasc_death_rate]
      ,[diabetes_prevalence]
      ,[female_smokers]
      ,[male_smokers]
      ,[handwashing_facilities]
      ,[hospital_beds_per_thousand]
      ,[life_expectancy]
      ,[human_development_index]
  FROM [PortfolioProject].[dbo].[CovidDeaths$]

Select*
From PortfolioProject..CovidDeaths
Where continent is not null
Order by 3,4

--Select*
--From PortfolioProject..CovidVaccinations
--Order by 3,4

-- Select the Data that We are going to be using
Select Location, Date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
Order by 1,2

-- Looking at Total Cases vs Total Deaths
Select Location, Date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where location like '%states%'
Order by 1,2

--Looking at Total Cases vs Population
Select Location, Date, total_cases, Population, (total_cases/Population)*100 as InfectedPopPercentage
From PortfolioProject..CovidDeaths
Where location like '%states%'
Order by 1,2

-- Looking at Countries with the highest infection rate compared to population
Select Location, Population, MAX(total_cases) as HighestInfectionCount, Max((total_cases/Population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
Group by Population, Location
Order by PercentPopulationInfected desc

--Looking at Countries with highest death count per Popularion
Select Location, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
where continent is not null
Group by Location
Order by TotalDeathCount desc

--LETS'S BREAK THINGS DOWN BY CONTITNENT

--Showing the Continents with the highest Death count
Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
where continent is not null
Group by continent
Order by TotalDeathCount desc

-- Looking at Continents with the highest infection rate compared to population
Select location, Population, MAX(total_cases) as HighestInfectionCount, Max((total_cases/Population))*100 as PercentPopulationInfected 
From PortfolioProject..CovidDeaths
Where continent is null and population is not null
Group by Population, location
Order by PercentPopulationInfected desc

--GLOBAL NUMBERS
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
where continent is not null
--group by date
Order by 1,2

--USE CTE
With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, Rollingpeoplevaccinated)
as
(
--Looking at total population vs Vaccinations
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(Convert(int,vac.new_vaccinations)) over (Partition by dea.location order by dea.location, dea.date)
as rollingpeoplevaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location=vac.location
	and dea.date=vac.date
Where dea.continent is not null
)

Select*, (Rollingpeoplevaccinated/Population)*100
From PopvsVac

-- TEMP TABLE
DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
rollingpeoplevaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(Convert(int,vac.new_vaccinations)) over (Partition by dea.location order by dea.location, dea.date)
as rollingpeoplevaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location=vac.location
	and dea.date=vac.date
--Where dea.continent is not null

Select*, (Rollingpeoplevaccinated/Population)*100
From #PercentPopulationVaccinated

 -- Creating VIEW to store data for later visualisations
 Create View PercentPopulationVaccinated as
 Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(Convert(int,vac.new_vaccinations)) over (Partition by dea.location order by dea.location, dea.date)
as rollingpeoplevaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location=vac.location
	and dea.date=vac.date
Where dea.continent is not null
--order by 2,3

Select*
From PercentPopulationVaccinated