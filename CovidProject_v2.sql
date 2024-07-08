Select *
From PortfolioProject..CovidDeaths
Where continent is not null
order by 3,4

--Select *
--From PortfolioProject..CovidVaccinations
--order by 3,4

-- Select Data that we are going to be using

Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
order by 1,2

-- Looking at Total Cases vs Total Deaths
-- Shows the likelihood of dying if you contract covid in your country
Select Location, date, total_cases, total_deaths, (cast(total_deaths as float)/cast(total_cases as float))*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where Location like '%states%'
and continent is not null
order by 1,2

-- Looking at Total Cases vs Population
-- Shows what percentage of population got Covid

Select Location, date, Population, total_cases,  (cast(total_cases as float)/cast(population as float))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
Where Location like '%states%'
order by 1,2

-- Looking at Countries with Highest Infection Rate compared to Population

SELECT 
    Location, 
    Population, 
    MAX(total_cases) AS HighestInfectionCount,  
    CAST((MAX(total_cases) / Population) AS FLOAT) * 100 AS PercentPopulationInfected
FROM 
    PortfolioProject..CovidDeaths
--WHERE 
--    Location LIKE '%states%'
Where continent is not null
GROUP BY Location, Population
Order by PercentPopulationInfected desc

-- Showing Countries with Highest Death Count per Population
Select Location, MAX(cast(total_deaths as int)) AS TotalDeathCount 
FROM PortfolioProject..CovidDeaths
Where continent is not null
GROUP BY Location
Order by TotalDeathCount desc

--LET'S BREAK THINGS DOWN BY CONTINENT

-- Showing continents with the highest death count per population
Select continent, MAX(cast(total_deaths as int)) AS TotalDeathCount 
FROM PortfolioProject..CovidDeaths
Where continent is not null
GROUP BY continent
Order by TotalDeathCount desc


-- GLOBAL NUMBERS

SELECT 
    date, 
    SUM(new_cases) AS total_cases, 
    SUM(new_deaths) AS total_deaths, 
    CASE 
        WHEN SUM(new_cases) = 0 THEN 0
        ELSE (SUM(CAST(new_deaths as float)) / SUM(CAST(new_cases as float))) * 100 
    END AS DeathPercentage
FROM 
    PortfolioProject..CovidDeaths
WHERE 
    continent IS NOT NULL
GROUP BY 
    date
ORDER BY 1,2

-- Looking at Total Population vs Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as float)) OVER (Partition by dea.Location)
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

-- Creating View to store data for later visualizations
CREATE VIEW PercentPopulationVaccinated AS
SELECT 
    dea.continent, 
    dea.location, 
    dea.date, 
    dea.population, 
    vac.new_vaccinations,
    SUM(CONVERT(int, vac.new_vaccinations)) 
        OVER (PARTITION BY dea.location ORDER BY dea.date ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS RollingPeopleVaccinated
FROM 
    PortfolioProject..CovidDeaths dea
JOIN 
    PortfolioProject..CovidVaccinations vac
    ON dea.location = vac.location
    AND dea.date = vac.date
WHERE 
    dea.continent IS NOT NULL

Select *
From PercentPopulationVaccinated