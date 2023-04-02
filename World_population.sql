/*  Display top 10 countries population wise in 2023 and 2020*/

select top 10 world_population.Country, dbo.world_population.[Population2020], data_2023.Population2023 as Population2023
	from data_2023 join world_population on data_2023.Country=world_population.Country 
	group by world_population.[Population2020], data_2023.Population2023, world_population.Country 
	order by Population2023 desc;

/*  Display the countries which have lowest population in 2023 and 2020*/
select top 5 world_population.Country, dbo.world_population.Population2020, data_2023.Population2023 
	from data_2023 join world_population on data_2023.Country=world_population.Country 
	group by world_population.Population2020, data_2023.Population2023, world_population.Country 
	order by Population2023;

/** show the country which has highest growth in population from 2020 to 2023**/
select * from
(
	select round((((Population2023-Population2020)/Population2020)*100),2) as growth, data_2023.Country 
		from data_2023 join world_population on data_2023.Country=world_population.Country
	)w where w.growth = ( select max(round((((Population2023-Population2020)/Population2020)*100),2)
		) 
		from data_2023 join world_population on data_2023.Country=world_population.Country 
)


/* show the country which is highly densed*/

select Density, Country from world_population where Density =
( select 
MAX(Density) from world_population );

/* Show top 5 countries with high density*/
select top 5 Density, country from world_population order by Density desc

/** show the country which has highest urban population**/

select top 5 Urban_Pop *100 as Urban_population_percentage, Country from world_population order by 1 desc;

/** show the top 10 country with largest land area and also show its capital, continent and  region**/

select top 10 Capital, data_2023.Country, Continent, region, [Land Area] 
	from data_2023 join countries_details on data_2023.Country=countries_details.Country 
	order by [Land Area] desc;

/** Show the region wise population in year 2023**/

select SUM(Population2023), region 
	from data_2023 join countries_details on data_2023.Country=countries_details.Country 
	group by region order by 1 desc

/** Show the average median age in different subregions from highest to lowest or Which subregion has highest median age**/

select round(AVG(world_population.Median_Age),2) as Average_age, data_2023.subregion
	from world_population join data_2023 on data_2023.Country=world_population.Country 
	group by data_2023.subregion order by 1 desc

/** Show the top 3 continent population wise with the rank and also shows respective median age **/

WITH cte_pop (Continent, Population2020, Rank_1, Median_Age) AS
(
select a.Continent, SUM(b.Population2020), RANK() over ( order by SUM(b.Population2020) desc), ROUND(AVG(b.Median_Age),2)
	from dbo.countries_details a join world_population b on a.Country=b.Country 
	group by a.Continent
)
select * from cte_pop where Rank_1<4

/**Show the top 3 regions where most migrants are coming in 2023**/

WITH cte (region, Migrants, top_Rank) AS 
(
select b.region, SUM(a.Migrants) as migrants, ROW_NUMBER() over (order by SUM(a.Migrants)desc) as top_rank
	from dbo.world_population a join data_2023 b on a.Country=b.Country 
	group by b.region
	)
select * from cte where top_rank<4

/**Show the top 3 regions where most migrants are leaving in 2023**/

WITH cte (region, Migrants, top_Rank) AS 
(
select b.region, SUM(a.Migrants) as migrants, ROW_NUMBER() over (order by SUM(a.Migrants)) as top_rank
	from dbo.world_population a join data_2023 b on a.Country=b.Country 
	group by b.region
	)
select * from cte where top_rank<4

/* male and female population in each country in 2023 */

with cte_a ( male, Country) as
(
select convert(int,(ratio_m_f/(ratio_m_f + 100))*Population2023) as male, Country 
	from dbo.data_2023
)
select b.Country, convert(int,b.Population2023) - male as female, male, convert(int,b.Population2023) as Population 
	from cte_a a join data_2023 b on a.Country=b.Country order by 2 desc

/* lowest female population % in country in 2023 */

with cte_a ( female, Country, row_num) as
(
select convert(int,(100/(ratio_m_f + 100))*100) as female, Country, ROW_NUMBER() over (order by  convert(int,(100/(ratio_m_f + 100))*100))
	from dbo.data_2023
)
select * from cte_a where row_num<4

/* Show the top 3 countries where population grew the most from 2020 to 2023*/

select * from
(
select (b.Population2023 - a.Population2020) as pop_change, a.Country, ROW_NUMBER() over (order by (b.Population2023 - a.Population2020)desc) as row_num
	from dbo.world_population a join dbo.data_2023 b on a.Country=b.Country
)x where x.row_num < 4

/*which country has the highest share of population of world population in 2020*/

select * from 
(
select ROW_NUMBER() over (order by World_Share desc) as rn, Country, World_Share*100 as Share 
	from dbo.world_population
)x where x.rn<=3;





