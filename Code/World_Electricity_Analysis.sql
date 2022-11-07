Use Project_World_Electricity;

---1.Comparison of access to electricity post 2000s in different countries

select Country_Code, Country_Name, AVG(Value_Column) as 'Access_to_Electricity%' 
from access_to_world where Year_Column>2000
group by Country_Code, Country_Name;

---2.Find one interesting insight present in the data (across all the tables)

--DISTRIBUTION LOSSES AND PRODUCTION SOURCES
select l.Country_Code,avg(l.Value_Column) as 'avg_loss_%_of_output',avg(o.Value_Column) as 'avg%_production_of_electricity_by_oil', avg(n.Value_Column) as 'avg%_production_of_electricity_by_nuclear'
from transmission_distribution_losses as l
join production_by_nuclear as n
on l.Country_Code=n.Country_Code and l.Year_column = n.Year_column
join production_by_oil as o
on n.Country_Code=o.Country_Code and n.Year_column = o.Year_column
where l.Year_column >=2000
group by l.Country_Code, l.Country_name
having avg(l.Value_Column)>0
order by avg(l.Value_Column) desc;

--DISTRIBUTION LOSSES AND ACCESSIBILITY
select l.Country_Code, l.Country_name, avg(l.Value_Column) as 'avg_loss_%_of_output', avg(w.Value_Column) as 'avg_access_to_electricity'
from transmission_distribution_losses as l
join access_to_world as w
on l.Country_Code=w.Country_Code and l.Year_column = w.Year_column
where l.Year_column >=2000
group by l.Country_Code, l.Country_name
having avg(l.Value_Column)>0
order by avg(l.Value_Column) desc;


---3.Present a way to compare every country’s performance with respect to world average for every year. 
--As in, if someone wants to check how is the accessibility of electricity in India in 2006 
--as compared to average access of the world to electricity

With World_Avg_Access_to_Electricity as
(select Year_Column,avg(Value_column) as 'World_Avg_Access_to_Electricity' from access_to_world
group by Year_Column)
select Country_Name,Country_Code, Indicator_Name, a.Year_Column, 
Value_Column as 'Country_Access_to_Electricity%', World_Avg_Access_to_Electricity 
from access_to_world as a
join World_Avg_Access_to_Electricity as b
on a.Year_Column=b.Year_Column;

---4.A chart to depict the increase in count of country with greater than 75% electricity
--access in rural areas across different year. For example, what was the count of countries 
--having ≥75% rural electricity access in 2000 as compared to 2010.

select Year_Column, count(Country_Code) as No_of_Countries from access_to_rural
where Value_Column>=75
group by Year_Column
order by Year_Column;

---5.Define a way/KPI to present the evolution of nuclear power presence grouped by Region and IncomeGroup. 
--How was the nuclear power generation in the region of Europe & Central Asia as compared to Sub-Saharan Africa.

--EVOLUTION OF NUCLEAR PRODUCTION % GROUPED BY INCOME GROUP
select Year_Column, IncomeGroup, avg(Value_Column) as '%_of_electricity_by_nuclear_production' 
from production_by_nuclear as n
left join Countries_Metadata as c
on n.Country_Code = c.Country_Code
where IncomeGroup is not null
group by IncomeGroup,Year_Column
order by Year_Column,IncomeGroup;
--EVOLUTION OF NUCLEAR PRODUCTION % GROUPED BY REGION
select Year_Column, Region, avg(Value_Column) as '%_of_electricity_by_nuclear_production' 
from production_by_nuclear as n
left join Countries_Metadata as c
on n.Country_Code = c.Country_Code
where Region is not null
group by Region,Year_Column
order by Year_Column, Region;

---6.A chart to present the production of electricity across different sources (nuclear, oil, etc.) as a function of time

select cast(concat('01-01-',cast(o.Year_Column as nvarchar)) as date) as Year_Column,(avg(o.Value_Column)+avg(n.Value_Column)) as '%production_of_electricity_by_oil_&_nuclear', avg(r.Value_Column) as 'kWh_production_of_electricity_by_renewable'
from production_by_oil as o
join production_by_nuclear as n
on o.Country_Code=n.Country_Code and o.Year_column = n.Year_column
join production_by_renewable as r
on n.Country_Code=r.country_code and n.Year_column = r.Year_column
group by cast(concat('01-01-',cast(o.Year_Column as nvarchar)) as date)
order by cast(concat('01-01-',cast(o.Year_Column as nvarchar))as date);
