Select *
From dbo.CovidDeaths$
Order by 3,4

Select *
from dbo.CovidVaccinations$
order by 3,4

----------------------------------------------------------------------------------


Select location, date, total_cases, new_cases, total_deaths, population
From dbo.CovidDeaths$
order by 1,2
-----------------------------------------------------------------------------------
-- we are looking for the total amount of cases & total deaths
-- this quere will show the percentage of how likely death would be per country 

Select location, date, total_cases, total_deaths, (total_deaths/ total_cases)*100 as Death_percent
From dbo.CovidDeaths$
order by  1,2
------------------------------------------------------------------------------------
-- total cases vs population 
-- I decided to make this a bit more relevant to me 

Select location, date, total_cases, population, (total_cases/ population)*100 as state_cases
From dbo.CovidDeaths$
Where location like '%states%'
order by 1,2 desc
------------------------------------------------------------------------------------
-- countries with highest rate of infection 

Select location,population, MAX(total_cases) as HighestInf, MAx((total_cases/population))*100 as percentpopinf
From dbo.CovidDeaths$
Group by location, population
Order by  percentpopinf Desc

Select location, Max(Cast(total_deaths as int )) as tdc -- tdc = total death count
from dbo.CovidDeaths$
where continent is not null
group by location
order by Tdc desc
------------------------------------------------------------------------------------
-- grouping by continent

Select location , Max(Cast(total_deaths as int )) as tdc --tdc = total death count
from dbo.CovidDeaths$
where continent is null
group by location
order by Tdc desc
-----------------------------------------------------------------------------------
-- going global by date

Select date, Sum(new_Cases)as total_cases ,Sum(cast (new_deaths as int)) as total_deaths, Sum(cast(new_deaths as int))/Sum(new_Cases)*100 as Deathpercent
From dbo.CovidDeaths$
Where continent is not null
Group by date
order by 1,2
-----------------------------------------------------------------------------------
---- global numbers

Select Sum(new_Cases)as total_cases ,Sum(cast (new_deaths as int)) as total_deaths, Sum(cast(new_deaths as int))/Sum(new_Cases)*100 as Deathpercent
from dbo.CovidDeaths$
where continent is not null
order by 1,2
-----------------------------------------------------------------------------------
-- loking at total population vs Vaccinations


Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert (int ,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as countingVac
from dbo.CovidDeaths$ as dea
join dbo.CovidVaccinations$ as vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not Null
order by 2,3 
------------------------------------------------------------------------------------
--Using CTE
-- becuase I cant use countingVac / population to figure out the percent

With PopVSVac (continent, location, date, population, new_vaccinations, CountingVac)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert (int ,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as CountingVac
From dbo.CovidDeaths$ as dea
Join dbo.CovidVaccinations$ as vac
  on dea.location = vac.location
  and dea.date = vac.date
 Where dea.continent is not Null
)
Select *, (CountingVac/population)*100
from PopVSVac
---------------------------------------------------------------------------------------
-- making a temp table to calculate

Drop table  if exists #PercPopVac
Create table #PercPopVac
(
  continent nvarchar(250),
  location nvarchar(250),
  DATE datetime,
  Population numeric,
  new_vaccinations numeric,
  CountingVac numeric
)


Insert into #PercPopVac
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(convert (int,vac.new_vaccinations)) Over (partition by dea.location order by dea.location, dea.date) 
as countingVac
from dbo.CovidDeaths$ as dea
join dbo.CovidVaccinations$ as vac
on dea.location = vac.location
and dea.date = vac.date

Select *, (CountingVac/population)*100
From #PercPopVac
-------------------------------------------------------------------------------------------
----creating view
Create view PercPopVac as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert (int ,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as countingVac
From dbo.CovidDeaths$ as dea
join dbo.CovidVaccinations$ as vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not Null

