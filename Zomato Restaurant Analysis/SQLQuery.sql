--                                                     ZOMATO RESTAURANTS ANALYSIS

-- creating the database
create database zomato_data

-- selecting the database
use zomato_data

/* importing the dataset file
1. Zomato_Dataset
2. Country-Code */

-- Creating constraint
alter table Zomato_Dataset
add constraint fk_countrycode foreign key (CountryCode) references Country_Code(CountryCode)

-- Explore the imported data
select * from Zomato_Dataset
select * from Country_Code

-- ANALYSIS QUESTIONS

-- Q1. Get overall statistics for the Indian restaurant market.

select count(*) as Total_Restaurant,
		count(distinct city) as Total_City,
		avg(Votes) as Average_Voting,
		avg(Average_Cost_for_two) as Average_Cost_for_two,
		avg(Rating) as Average_Rating
from Zomato_Dataset z
inner join Country_Code c
on z.CountryCode=c.CountryCode
where Country='India'

-- Q2. Top 10 Indian cities with number of restaurant, average rating, average cost 

select top 10 City,
		count(*) Restaurant_Counts,
		avg(Rating) as Average_Rating,
		avg(Average_Cost_for_two) as Average_Cost
from Zomato_Dataset z
inner join Country_Code c
on z.CountryCode=c.CountryCode
where Country='India'
group by city
order by 2 desc

-- Q3. Understand pricing segments and their relationship with ratings in India. 

select Price_range,
		count(*) as 'Total_Restaurants',
		count(*)*100 / (select count(*) from Zomato_Dataset where CountryCode=1) as Percentage_Contribution,
		avg(Average_Cost_for_two) as 'Average_Cost',
		min(Average_Cost_for_two) as 'Minimum_Cost',
		max(Average_Cost_for_two) as 'Maximum_Cost',
		avg(Rating) as 'Average_Rating'
from Zomato_Dataset z
inner join Country_Code c
on z.CountryCode=c.CountryCode
where Country='India'
group by Price_range
order by Price_range desc

/* Q4. Compare restaurant types based on service offerings in India.
Online Delivery vs Dine-in Analysis */

select Has_Online_delivery,Has_Table_booking,
		count(*) as Restaurant_Count,
		avg(Average_Cost_for_two) as Average_Cost,
		avg(Rating) as Average_Rating,
		avg(Votes) as Average_Votes
from Zomato_Dataset z
inner join Country_Code c
on  z.CountryCode=c.CountryCode
where Country='India'
group by Has_Online_delivery,Has_Table_booking
order by 5 desc

-- Q5. Identify top 15 most popular cuisine types and their performance metrics in India. 

select top 15 Cuisines,
		count(*) as Restaurant_Count,
		avg(Average_Cost_for_two) as Average_Cost,
		avg(Rating) as Average_Rating,
		avg(Votes) as Average_Votes
from Zomato_Dataset z
inner join Country_Code c
on  z.CountryCode=c.CountryCode
where Country='India'
group by Cuisines
order by 2 desc

-- Q6. Compare budget vs premium restaurant segments in India 

select case	
		when Price_range<=2 then 'Budget'
		when Price_range>2 then 'Premium'
		end as Restaurant_Segment,
		count(*) as Restaurant_Count,
		sum(case when Has_Table_booking='Yes' then 1 else 0 end) as Booking_Service_Count,
		sum(case when Has_Online_delivery ='Yes' then 1 else 0 end) as Online_Service_Count,
		avg(Average_Cost_for_two) as Average_Cost,
		avg(Rating) as Average_Rating,
		avg(Votes) as Average_Votes
from Zomato_Dataset z
inner join Country_Code c
on  z.CountryCode=c.CountryCode
where Country='India'
GROUP BY case	
		when Price_range<=2 then 'Budget'
		when Price_range>2 then 'Premium'
		end

-- Q7. City-wise Rating Distribution in Top 5 Indian Cities 

with Top_Cities as (select top 5 City
from Zomato_Dataset z
inner join Country_Code c
on  z.CountryCode=c.CountryCode
where Country='India'
group by City
order by count(*) desc)

select z.City,
		count(*) as Restaurant_Count,
		sum(case when Rating>=4 then 1 else 0 end) as Excellent_Rating,
		sum(case when Rating>=3 and Rating<4 then 1 else 0 end) as Good_Rating,
		sum(case when Rating>0 and Rating<3 then 1 else 0 end) as Poor_Rating,
		sum(case when Rating=0 and Rating is null then 1 else 0 end) as No_Rating
from Zomato_Dataset z
inner join Top_Cities c
on z.City =c.City
group by z.City
order by COUNT(z.city) desc

-- Q8. Compare average dining costs across different countries

select Country,
		count(*) as Restaurant_Count,
		avg(Average_Cost_for_two) as Average_Dining_Costs,
		Currency
from Zomato_Dataset z
inner join Country_Code c
on  z.CountryCode=c.CountryCode
group by Country,Currency
order by 2 desc

-- Q9. Analyze digital service adoption across Indian cities 

select City,
		count(*) as Total_Restaurant,
		sum(case when Has_Table_booking='Yes' or Has_Online_delivery='Yes' then 1 else 0 end) as Digital_adopted_count,
		sum(case when Has_Table_booking='Yes' or Has_Online_delivery='Yes' then 1 else 0 end)*100 / count(*) as Digital_adopted_Percenatge
from Zomato_Dataset z
inner join Country_Code c
on  z.CountryCode=c.CountryCode
where Country='India'
group by City
order by count(*) desc

-- Q10. Top Rated Restaurants in India with High Vote Count 

select RestaurantID,
		RestaurantName,
		City,
		Cuisines,
		Has_Table_booking,
		Has_Online_delivery,
		Votes,
		Rating
from Zomato_Dataset z
inner join Country_Code c
on  z.CountryCode=c.CountryCode
where Country='India'
	and Rating>=4
order by Votes desc

-- Q11. India vs Other Countries - Service Features Comparison 

select case
		when Country='India' then 'India' else 'Other Country'
		end as Countries,
		count(*) as Restaurant_Count,
		sum(case when Has_Table_booking='Yes' then 1 else 0 end) as Table_Booking_Service_Count,
		sum(case when Has_Online_delivery='Yes' then 1 else 0 end) as Online_delivery_Service_Count,
		avg(Rating) as Average_Rating,
		avg(Votes) as Average_Votes
from Zomato_Dataset z
inner join Country_Code c
on  z.CountryCode=c.CountryCode
group by case
		when Country='India' then 'India' else 'Other Country'
		end
order by 2 desc

/** Q12. Market Penetration Analysis - India vs International 
    - Compare Zomato's market presence and performance across key countries.
    - 'India', 'United States', 'UAE', 'Singapore', 'Australia' **/

select Country,
		count(*) as Restaurant_Count,
		sum(case when Has_Table_booking='Yes' then 1 else 0 end) as Booking_Service_Count,
		sum(case when Has_Online_delivery ='Yes' then 1 else 0 end) as Online_Service_Count,
		avg(Votes) as Average_Votes,
		avg(Rating)as Average_Rating,
		avg(Average_Cost_for_two) as Average_Cost
from Zomato_Dataset z
inner join Country_Code c
on  z.CountryCode=c.CountryCode
where Country in ('India', 'United States', 'UAE', 'Singapore', 'Australia')
group by Country
order by 2 desc

/*	Q13. Cuisine Diversity Analysis by Indian Cities
    - Measure culinary diversity across Indian cities. */

SELECT City,Cuisines,
		count(*) as 'Restaurant_Count',
		avg(Votes) as Average_Votes,
		avg(Average_Cost_for_two) as Average_Cost,
		avg(Rating) as Average_Rating
from Zomato_Dataset z
inner join Country_Code c
on  z.CountryCode=c.CountryCode
where Country='India'
group by City,Cuisines
order by City,count(*) desc

--_________________________________________________________________ END _______________________________________________________________