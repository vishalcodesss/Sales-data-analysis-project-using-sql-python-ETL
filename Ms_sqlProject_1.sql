create table df_orders (
[order_id] int primary key
, [order_date] date
, [ship_mode] varchar(20)
, [segment] varchar(20)
, [country] varchar(20)
, [city] varchar (20)
, [state] varchar (20)
, [postal_code] varchar (20)
, [region] varchar (20)
, [category] varchar (20)
, [sub_category] varchar(20)
, [product_id] varchar(50)
, [quantity] int
, [discount] decimal (7, 2)
, [sale_price] decimal (7, 2)
, [profit] decimal (7, 2))


select * from df_orders

-- find top 10 highest revenue generating products

select top 10 product_id, SUM(sale_price) as sales
from df_orders
group by product_id
order by sales desc

-- here top keyword is used to find top 10 products whereas in mysql limit is used to find the top 10 products

-- find top 5 highest selling products in each region

WITH cte as (
select region,product_id, SUM(sale_price) as sales
from df_orders
group by region, product_id
)
select * from (
	select *,
	ROW_NUMBER() over(partition by region order by sales desc) as rnk
	from cte) as a
	where rnk <=5

-- here cte is used to simplify the complexity of the query.
-- Basically, cte are temporary tables created by you to extract data from the main query or outer query.


-- find month over month growth comparison for 2022 and 2023 sales. eg : jan 2022 vs jan 2023

with growthcte as (
	select YEAR(order_date) as order_year, MONTH(order_date) as order_month,
		SUM(sale_price) as sales
		from df_orders
		group by YEAR(order_date), MONTH(order_date)
		--order by YEAR(order_date), MONTH(order_date)

)
	select order_month,
		SUM(case when order_year = 2022 then sales else 0 end) as sales_2022,
		SUM(case when order_year = 2023 then sales else 0 end) as sales_2023
		from growthcte
		group by order_month
		order by order_month

-- For each category, which month had highest sales

with categorysales as (
select category, FORMAT(order_date,'yyyyMM') as order_year_month,
SUM(sale_price) as sales
from df_orders
group by category, FORMAT(order_date,'yyyyMM')
)

select * from (
select *,
ROW_NUMBER() over(partition by category order by sales desc) as rnk
from categorysales
) as a
where rnk = 1

-- since there are two years, so a total of 24 months. Out of those, we have to use both year and month in the query. 
-- hence we have used format to take both month and year
-- We are using rownumber function to find the highest sales in each category 

-- Q. which sub category had highest growth by profit in 2023 compared to 2022

WITH subcategoryprofit as (
	select sub_category,
			YEAR(order_date) as orderyear,
		    SUM(sale_price) as sales
	from df_orders
	group by sub_category,YEAR(order_date)
)
, subcategorygrowth as(
select sub_category,
		sum(case when orderyear= 2022 then sales else 0 end) as sales_2022,
		sum(case when orderyear= 2023 then sales else 0 end) as sales_2023
from subcategoryprofit
group by sub_category 
)


SELECT top 1 *,
    CAST(((sales_2023 - sales_2022) * 100.0 / sales_2022) AS VARCHAR(10)) + '%' AS Percentage_Change
FROM 
  subcategorygrowth
  order by ((sales_2023 - sales_2022) * 100.0 / sales_2022) desc



/*select *,
		((sales_2023-sales_2022) * 100/sales_2022) as growth_percent
from subcategorygrowth
order by  growth_percent desc */