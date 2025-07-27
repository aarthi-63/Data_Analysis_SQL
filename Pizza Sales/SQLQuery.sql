--                                                 PIZZA SALES - DATA ANALYSIS


-- creating the database
create database pizza_sales

-- importing the dataset into the database
-- Tables
-- 1. pizzaz
-- 2. pizza_types
-- 3. orders
-- 4. order_details

-- using the created database
use pizza_sales

-- DQL Queries

-- BASIC

-- Q1. Retrieve the total number of orders placed.
select count(*) as 'Tota_Orders_Placed' from orders

-- Q2. Calculate the total revenue generated from pizza sales.

select sum(price*quantity) as Total_Revenue_Generated
from order_details o
inner join pizzas p 
on p.pizza_id=o.pizza_id


-- Q3. Identify the highest-priced pizza.

select top 1 * from pizzas
order by price desc

-- Q4. Identify the most common pizza size ordered.

select top 1 size,count(order_id) as Max_Size_Pizza_Count from order_details o
inner join pizzas p
on o.pizza_id=p.pizza_id
group by size
order by count(order_id) desc

-- Q5. List the top 5 most ordered pizza types along with their quantities.

select top 5 pt.pizza_type_id,name,sum(quantity) as Total_Quantity_Ordered
from order_details o
inner join pizzas p
on o.pizza_id=p.pizza_id
inner join pizza_types pt
on p.pizza_type_id=pt.pizza_type_id
group by pt.pizza_type_id,name
order by sum(quantity) desc

--_______________________________________________________________________________________________________________________________________

-- INTERMEDIATE

--Q1. Join the necessary tables to find the total quantity of each pizza category ordered.

select category,sum(quantity) as Quantity_Ordered from order_details o
inner join pizzas p on o.pizza_id=p.pizza_id
inner join pizza_types pt on p.pizza_type_id=pt.pizza_type_id
group by category
order by sum(quantity) desc

--Q2. Determine the distribution of orders by hour of the day.

select datepart(hour,time),count(order_id) from orders
group by datepart(hour,time)
order by count(order_id) desc

--Q3. Join relevant tables to find the category-wise distribution of pizzas.

select category,count(pizza_id) from pizza_types pt
inner join pizzas p
on pt.pizza_type_id=p.pizza_type_id
group by category
order by count(pizza_id) desc

--Q4. Group the orders by date and calculate the average number of pizzas ordered per day.

with Ordered_Per_Day 
as
(select date,sum(quantity) as Quantity_Ordered from orders o
inner join order_details od
on o.order_id=od.order_id
group by date)
select avg(Quantity_Ordered) as 'Average_Per_Day' from Ordered_Per_Day

--Q5. Determine the top 3 most ordered pizza types based on revenue.

select top 3 p.pizza_type_id,name,sum(quantity*price) as Revenue
from pizzas p
inner join order_details od
on p.pizza_id=od.pizza_id
inner join pizza_types pt
on pt.pizza_type_id=p.pizza_type_id
group by p.pizza_type_id,name
order by revenue desc

--______________________________________________________________________________________________________________________________________________

-- ADVANCED

-- Q1. Calculate the percentage contribution of each pizza type to total revenue.

with Total_Revenue as 
(select sum(quantity*price) as total 
from order_details od inner join pizzas p 
on od.pizza_id=p.pizza_id)

select p.pizza_type_id,name,round((sum(quantity*price)/(select * from Total_Revenue))*100,2) as Per_of_Total_Revenue
from order_details od
inner join pizzas p on p.pizza_id=od.pizza_id
inner join pizza_types pt on p.pizza_type_id=pt.pizza_type_id 
group by p.pizza_type_id,name
order by Per_of_Total_Revenue desc

-- Q2. Analyze the cumulative revenue generated over time.

select [date],round(sum(total_revenue) over (order by date),0) as cum_sum
from(
select [date],sum(price*quantity) as total_revenue from orders o
inner join order_details od on o.order_id=od.order_id
inner join pizzas p on p.pizza_id=od.pizza_id
group by [date]) as sales

-- Q3. Determine the top 3 most ordered pizza types based on revenue for each pizza category.

select category,pizza_type_id,revenue,
		rank() over (partition by category order by revenue desc) as rn 
from
 (select category, p.pizza_type_id,name,
		sum(price*quantity) as Revenue
from pizza_types pt 
inner join pizzas p on p.pizza_type_id=pt.pizza_type_id
inner join order_details od on od.pizza_id=p.pizza_id
group by category,p.pizza_type_id,name) as revenue_total
where rn <= 3;



--__________________________________________________________________________END__________________________________________________________________________