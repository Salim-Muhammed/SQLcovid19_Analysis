-- This project focuses the global Covid19 pandamic Analysis by using death and vaccination data

-- looking unique country names
SELECT distinct location FROM Portfolioproject..coviddeath 

--Two tables that we are going to analysis
SELECT * FROM Portfolioproject..coviddeath 
SELECT * FROM Portfolioproject..vaccination 


-- Selecting the required data
select location ,date ,total_cases ,new_cases,total_deaths,population
from Portfolioproject..coviddeath 
where continent is not null
order by 1,2


--Looking total cases vs total deaths
select location ,date ,total_cases ,total_deaths,(cast(total_deaths as float)/cast(total_cases as float))*100 as death_percentage
from Portfolioproject..coviddeath 
where location  like '%state%'
and continent is not null
order by 1,2


-- Shows how much percentage of population got covid
select location ,date ,population,total_cases,(cast(total_cases as float)/cast(population as float))*100 as covid_percentage
from Portfolioproject..coviddeath 
where continent is not null
order by 1,2


--Shows how much percentage of population got covid where location like state
select location ,date ,population,total_cases,(cast(total_cases as float)/cast(population as float))*100 as covid_percentage
from Portfolioproject..coviddeath 
where location like '%state%'
where continent is not null
order by 1,2


--Shows how much percentage of indian population got covid
select location ,date ,population,total_cases,(cast(total_cases as float)/cast(population as float))*100 as covid_percentage
from Portfolioproject..coviddeath 
where location='india'
order by 1,2


--To know which location was mostly affected covid19
select location ,population,max(total_cases)as highinfected,max(cast(total_cases as float)/cast(population as float))*100 as percentage_infected
from Portfolioproject..coviddeath 
where continent is not null
group by location,population
order by percentage_infected desc


--Covid infected rate in india
select location ,population,max(total_cases)as highinfected,max(cast(total_cases as float)/cast(population as float))*100 as percentage_infected
from Portfolioproject..coviddeath 
where location ='india'
group by location,population


--Showing locations with highest death counts per populations
select location ,max(cast(total_deaths as int))as Total_death
from Portfolioproject..coviddeath 
where continent is not null
group by location
order by Total_death desc


--Looking highest death counts and percentage of indian population
select location ,population,max(total_deaths)as highest_death,max(cast(total_deaths as float)/cast(population as float))*100 as percentage_of_death
from Portfolioproject..coviddeath 
where location='india'
group by location,population


-- Fetching total death count by continent basis
select continent ,max(cast(total_deaths as int))as Total_death_count
from Portfolioproject..coviddeath 
where continent is not null
group by continent
order by Total_death_count desc


--Looking total new covid cases in each date
select date ,sum(new_cases) as total_covid_cases,
sum(cast(new_deaths as int)) as total_death,
sum(cast(new_deaths as int))/sum(new_cases)*100 as percentage_total_death
from Portfolioproject..coviddeath 
where continent is not null 
group by date
having sum(new_cases) <> 0
order by 1


--Looking total new covid cases 
select sum(new_cases) as total_covid_cases,
sum(cast(new_deaths as int)) as total_death,
sum(cast(new_deaths as int))/sum(new_cases)*100 as total_death_percentage
from Portfolioproject..coviddeath 
where continent is not null 


--Query that fetches average death in each location
select location,population,
avg(cast(total_deaths as int)) as average_death
from Portfolioproject..coviddeath
where continent  is not null 
group by location,population
order by 1


--Looking total patients who are now in ICU
select location,
sum(cast(icu_patients as int)) as patients_in_icu
from Portfolioproject..coviddeath
where icu_patients  is not null 
group by location
order by 1


--Joining two tables
select * 
from Portfolioproject..coviddeath dea
join Portfolioproject..vaccination vac
on dea.location=vac.location
and dea.date=vac.date
order by 3,4


--Looking at total population vs vaccination
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
from Portfolioproject..coviddeath dea
join Portfolioproject..vaccination vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null and vac.new_vaccinations is not null
order by 1,2,3


--Looking cumulative people vaccinated by using aggregate window function
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(convert(bigint, vac.new_vaccinations)) over (partition by dea.location order by dea.location,
dea.date) as cum_vaccination
from Portfolioproject..coviddeath dea
join Portfolioproject..vaccination vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null and vac.new_vaccinations is not null
order by 1,2,3


--Using CTE
with popvsvac (Continent,Location,Date,Population,New_Vaccinations,Cum_Vaccination) 
as
(
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(convert(bigint, vac.new_vaccinations)) over (partition by dea.location order by dea.location,
dea.date) as cum_vaccination
from Portfolioproject..coviddeath dea
join Portfolioproject..vaccination vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null and vac.new_vaccinations is not null
)
select *,(Cum_Vaccination/Population)*100 as percent_cum_vac
from popvsvac


--Temp Table
drop table if exists #percentPopulationVaccinated
create table #percentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
cum_vaccination numeric
)
insert into #percentPopulationVaccinated
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(convert(bigint, vac.new_vaccinations)) over (partition by dea.location order by dea.location,
dea.date) as cum_vaccination
from Portfolioproject..coviddeath dea
join Portfolioproject..vaccination vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null and vac.new_vaccinations is not null

select *,(Cum_Vaccination/Population)*100 as percent_cum_vac
from #percentPopulationVaccinated


-- Creating view to store data for later visualization
create view PercentPopulation_Vac as
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(convert(bigint, vac.new_vaccinations)) over (partition by dea.location order by dea.location,
dea.date) as cum_vaccination
from Portfolioproject..coviddeath dea
join Portfolioproject..vaccination vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null and vac.new_vaccinations is not null

select * from PercentPopulation_Vac

