






--select *from 
--portfolioProject..CovidVaccinations
--where location is not null
--order by 3, 4;

select*
from portfolioProject..covidDeaths
where continent is not null
group by 3,4
--select data that we are going to be using 

select location, date, total_cases, new_cases, total_deaths, population
from portfolioProject..CovidDeaths 
order by 1,2 ;


--looking at the total cases verses the total deaths using the float and the convert key word to convert the big numbers pulling out the Us death % 
--shows the liklihood of dying if you contract covid in your country 
select location, date, total_cases, total_deaths, 
(convert (float, total_deaths)/Nullif(convert(float, total_cases), 0))*100 as DeathPercentage
from portfolioProject..CovidDeaths 
where location like '%states%'
order by 1,2 ;

--looking at the total cases vs population 
--shows what percentage got covid

select location, date, population ,total_cases,
(convert (float, total_cases)/Nullif(convert(float, population), 0))*100 as PercentageOfPopulation 
from portfolioProject..CovidDeaths 
--where location like '%states%'
order by 1,2 ;

-- looking at the countries with the highest infection rate compared to population 

select location , population, max(total_cases) as highestInfectionCount, 
max(convert (float, total_cases)/Nullif(convert(float, population), 0))*100 as Percentpopulationinfected
from PortfolioProject..covidDeaths
group by location, population
order by percentPopulationInfected desc;

--showing the countries with the highest death counts per populations 
select location, max(cast(total_deaths as bigint)) as totaldeathsCount
from PortfolioProject..covidDeaths
where continent is not null
group by location
order by totaldeathsCount desc;


-- break things down by continent 


--showing the continent with the highest deaths counts 
select continent, max(cast(total_deaths as bigint)) as totaldeathsCount
from PortfolioProject..covidDeaths
where continent is not null
group by continent
order by totaldeathsCount desc;


--Global Numbers across the world total percentages of deaths 

select date, 
SUM(new_cases)as total_cases, 
SUM(cast(new_deaths as bigint)) as total_deaths,
case when sum(new_cases) = 0 then null --if it is equals to 0 then we will divide it
else SUM(cast(new_deaths as bigint))/sum(new_cases)*100 end as DeathPercentage
from PortfolioProject..CovidDeaths
where continent is not null
Group By date
order by 1,2;

-- total cases, total death and deaths percentages across the world 
select
SUM(new_cases)as total_cases, 
SUM(cast(new_deaths as bigint)) as total_deaths,
case when sum(new_cases) = 0 then null --if it is equals to 0 then we will divide it
else SUM(cast(new_deaths as bigint))/sum(new_cases)*100 end as DeathPercentage
from PortfolioProject..CovidDeaths
where continent is not null
order by 1,2;

--covid vaccinations and covid deaths joined
select *
from portfolioProject..CovidDeaths dea
join portfolioProject..covidvaccinations vac
on dea.location = vac.location
and dea.date = vac.date;

--looking at total population vs vaccinations 

select  dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
from portfolioProject..CovidDeaths dea
join portfolioProject..covidvaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 1, 2, 3 ;

--


select  dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(convert(bigint, vac.new_vaccinations)) over(partition by dea.location order by dea.location,
dea.Death) as RollingPeopleVaccinated,

from portfolioProject..CovidDeaths dea
join portfolioProject..covidvaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by  2, 3;




-- USe CTE
With PopvsVac(Continent, location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as 
(
select  dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(convert(bigint, vac.new_vaccinations)) over(partition by dea.location order by dea.location,
dea.Date) as RollingPeopleVaccinated
from portfolioProject..CovidDeaths dea
join portfolioProject..covidvaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by  2, 3
)
select *, (RollingPeopleVaccinated/population)*100
from popvsVac

--Tempt table 
create table #PercentPopulationVaccinated(
continent nvarchar(255), 
location nvarchar(255), 
date dateTime, 
population numeric, 
new_Vaccinations numeric, 
RollingPeopleVaccinated numeric
) 
insert into #PercentPopulationVaccinated
select  dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(convert(bigint, vac.new_vaccinations)) over(partition by dea.location order by dea.location,
dea.Date) as RollingPeopleVaccinated
from portfolioProject..CovidDeaths dea
join portfolioProject..covidvaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by  2, 3
select * , (RollingPeopleVaccinated/Population) * 100
From #PercentPopulationVaccinated



--creating view to store data for later visualizations 
create view PercentPopulationVaccinated as 
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(bigint, vac.new_vaccinations)) over (partition by dea.location order by dea.location, 
dea.date) as RollingPeopleVaccinated
from portfolioProject..covidDeaths dea
join portfolioProject..covidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2, 3

--see my view table
select * from percentpopulationVaccinated;