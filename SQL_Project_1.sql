select * from orders
;
/*top 1 outlets by cuisine type without using limit and top*/
with cte as(
select
Cuisine,Restaurant_id,count(*) as num_of_orders
from orders
group by Cuisine,Restaurant_id),
cte1 as (
select *,
row_number() over (partition by cuisine order by num_of_orders) as r_num
from cte)
select * from cte1 where r_num=1
order by cuisine, restaurant_id;

/*Find the daily new customer count from launch date*/
with cte as (
select customer_code, date(min(Placed_at)) as first_order_date
from orders
group by Customer_code)
select first_order_date,count(*) as new_customers
from cte
group by first_order_date
order by first_order_date;

/*Count all customers who werre acy=quired in Jan 2025 and only placed one order in jan 
but not placed any order later*/

select customer_code,count(*) as num_of_orders from orders
where month(Placed_at)=1 and year(placed_at)=2025 and 
Customer_code not in (select distinct Customer_code from orders
where not (month(Placed_at)=1 and year(placed_at)=2025))
group by Customer_code
having count(*)=1;

/*List all customers who placed more than one and all their orders are with promo code only*/

with cte as (
select customer_code, count(*) as num_of_orders, count(promo_code_name) as promo_code_orders
from orders
group by Customer_code)
select customer_code from cte where num_of_orders=promo_code_orders and num_of_orders>1;

select customer_code, count(*) as num_of_orders, count(promo_code_name) as promo_code_orders
from orders
group by Customer_code
having count(*)>1 and count(*)=count(Promo_code_Name);

/*what % of customers were organically acquired(orders placed without promo code)*/
with cte as (
select *,
row_number() over(partition by customer_code order by placed_at) as rn
from orders
where month(placed_at)=1)
select (count(case when rn=1 and promo_code_name is null then customer_code end)*100/count(distinct customer_code)) as pct
from cte;

