-- Retail Sales Analysis

-- creating database
create database Retail_Analysis

--selecting the database
use Retail_Analysis

-- creating table
create table sales_details(
		transactions_id int primary key,
		sale_date date,
		sale_time time,
		customer_id int,
		gender varchar(10),
		age int,
		category varchar(50),
		quantiy int,
		price_per_unit int,
		cogs float,
		total_sale int
)

-- importing the dataset from file to table 

-- Overview of the data

select top 10 * from sales_details

-- total rows count present
select count(*) as 'Total_Rows' from sales_details

/*____________________________________________________________________________________________________________________________*/

-- Data Cleaning

-- Checking rows with null vales
select * from sales_details
where transactions_id is null
	or sale_date is null
	or sale_time is null
	or customer_id is null
	or gender is null
	or age is null
	or category is null
	or quantiy is null
	or price_per_unit is null
	or cogs is null
	or total_sale is null

-- count and percentage of null rows
with null_records as (select * from sales_details
where transactions_id is null
	or sale_date is null
	or sale_time is null
	or customer_id is null
	or gender is null
	or age is null
	or category is null
	or quantiy is null
	or price_per_unit is null
	or cogs is null
	or total_sale is null)
select count(*) as 'Count_of_null_rows'
from null_records

-- as null count is very less, deleting the record from the table
delete from sales_details
where transactions_id in (
select transactions_id from sales_details
where transactions_id is null
	or sale_date is null
	or sale_time is null
	or customer_id is null
	or gender is null
	or age is null
	or category is null
	or quantiy is null
	or price_per_unit is null
	or cogs is null
	or total_sale is null
)

/*_________________________________________________________________________________________________________________________________*/
-- Data Exploration
-- SQL Queries

-- Total sales count available ?
select count(*) from sales_details

-- Number of customers done transactio ?
select count(distinct customer_id) from sales_details


-- Gender Proportion
select gender,count(*) as 'Count'
from sales_details
group by gender

-- Different Category available
select distinct category 
from sales_details

/* _________________________________________________________________________________________________________________________________*/
-- Data Analysis and Business Key Problems

-- Questions
-- 1.  Write a SQL query to retrieve all columns for sales made on '2022-11-05'.
select * 
from sales_details
where sale_date='2022-11-05'

/* 2. Write a SQL query to retrieve all transactions where the category is 'Clothing'
	and the quantity sold is more than or equal to  4 in the month of Nov-2022.*/
select 
* from sales_details
where category='Clothing'
		and quantiy >= 4 
		and year(sale_date) = 2022
		and MONTH(sale_date)= 11

-- 3. Write a SQL query to calculate the total sales (total_sale) for each category.
select category,sum(total_sale) as 'Total_Sales'
from sales_details
group by category
order by 2 desc

-- 4. Write a SQL query to find the average age of customers who purchased items from the 'Beauty' category.
select round(avg(age),0) as 'AVG_Age_Purchase_from_Beauty_Category'
from sales_details
where category='Beauty'

-- 5. Write a SQL query to find all transactions where the total_sale is greater than 1000.
select *
from sales_details
where total_sale > 1000
order by total_sale

-- 6. Write a SQL query to find the total number of transactions (transaction_id) made by each gender in each category.
select category,gender,count(transactions_id) as 'Total_Transaction'
from sales_details
group by category,gender
order by 1,3 desc

-- 7. Write a SQL query to calculate the average sale for each month.
select month(sale_date),avg(total_sale) as 'AVG_Sale'
from sales_details
group by month(sale_date)
order by 1

-- 8. Find out best selling month in each year.
with tab as (select year(sale_date)as 'YEAR',month(sale_date) as 'MONTH',avg(total_sale) as 'AVG_Sale',
		rank() over(partition by year(sale_date) order by avg(total_sale) desc) as [rank]
from sales_details
group by year(sale_date),month(sale_date))
select [YEAR],[month] as 'best_selling_month_in_year',avg_sale from tab
where rank=1

--9. **Write a SQL query to find the top 5 customers based on the highest total sales **.
select top 5 customer_id,sum(total_sale) as 'Total_Sales'
from sales_details
group by customer_id
order by 2 desc

-- 10. Write a SQL query to find the number of unique customers who purchased items from each category.
select category,count(distinct customer_id) as 'Unique_Customer_Count'
from sales_details
group by category

/* 11.  Write a SQL query to create each shift and number of orders 
(Example Morning <12, Afternoon Between 12 & 17, Evening >17).*/

with shift_tab as (
select transactions_id,sale_time,
		case
		when datepart(hour,sale_time) < 12 then 'Morning'
		when datepart(hour,sale_time) between 12 and 17 then 'Afternoon'
		when datepart(hour,sale_time) > 17 then 'Evening'
		end as 'shift_category'
from sales_details)
select shift_category,count(transactions_id)
from shift_tab
group by shift_category
order by 2 desc

/**_________________________________________________ END __________________________________________________________________**/
