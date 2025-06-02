#find top 10 highest reveue generating products 
SELECT 
    product_id, SUM(sale_price) AS total_sales
FROM
    orders
GROUP BY product_id
ORDER BY total_sales DESC
LIMIT 10;






#find top 5 highest selling products in each region
with my_cte as (select region, product_id , sum(sale_price) as sales
from orders
group by region, product_id),
 pt as (select *, row_number() over (partition by region order by sales desc) as rn
from my_cte)
select region,product_id,sales
from pt
where rn<6;




#find month over month growth comparison for 2022 and 2023 sales eg : jan 2022 vs jan 2023

with my_cte as (select year(order_date) as order_year , monthname(order_date) as order_month , sum(sale_price) as sales
from orders
group by order_year , order_month)
select order_month
, sum(case when order_year=2022 then sales else 0 end) as sales_2022
, sum(case when order_year=2023 then sales else 0 end) as sales_2023
from my_cte 
group by order_month
order by order_month;


#for each category which month had highest sales 

with my_cte as (select category , monthname(order_date) as order_month, sum(sale_price) as sales
from orders
group by category , order_month),
pt as(
select * , row_number() over (partition by category order by sales desc) as rn
from my_cte)
select category , order_month , sales
from pt 
where rn =1;






#which sub category had highest growth by profit in 2023 compare to 2022?

WITH my_cte AS (
    SELECT 
        sub_category, 
        YEAR(order_date) AS order_year,
        SUM(profit) AS profit
    FROM orders
    GROUP BY sub_category, YEAR(order_date)
),
diff_cte AS (
    SELECT 
        sub_category,
        order_year,
        profit,
        LAG(profit) OVER (PARTITION BY sub_category ORDER BY order_year) AS prev_year_profit
    FROM my_cte
)
SELECT 
    sub_category,
    order_year,
    profit,
    prev_year_profit,
    (profit - prev_year_profit)*100/(profit) AS growth
FROM diff_cte
WHERE prev_year_profit IS NOT NULL
order by growth desc
limit 1;








