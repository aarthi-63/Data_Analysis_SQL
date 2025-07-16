-- creating the database
create database MusicStore

use MusicStore

select * from employee

-- Importing all the required csv files for analysis as per the schema

-- Question Set 1 - Easy

/* 1. Who is the senior most employee based on job title? */

select top 1 employee_id,first_name,last_name,title,levels from employee 
order by levels desc

/* 2. Which countries have the most Invoices? */

select top 1 billing_country,count(total) count_invoice from invoice
group by billing_country
order by count(total) desc


/* 3. What are top 3 values of total invoice? */

select top 3 * from invoice
order by total desc


/* 4. Which city has the best customers? We would like to throw a promotional Music
Festival in the city we made the most money. Write a query that returns one city that
has the highest sum of invoice totals. Return both the city name & sum of all invoice
totals*/

select top 1 billing_city,sum(total) total_invoice from invoice
group by billing_city
order by sum(total) desc

/* 5. Who is the best customer? The customer who has spent the most money will be
declared the best customer. Write a query that returns the person who has spent the
most money */

select top 1 c.customer_id,first_name,last_name,sum(total) total_invoice from customer c
inner join invoice i
on c.customer_id=i.customer_id
group by c.customer_id,first_name,last_name
order by sum(total) desc

-- ______________________________________________________________________________________________________________________
-- Question Set 2 – Moderate

/* 1. Write query to return the email, first name, last name, & Genre of all Rock Music
listeners. Return your list ordered alphabetically by email starting with A */

select distinct c.first_name,c.last_name,c.email,g.name from customer c
inner join invoice i on c.customer_id=i.customer_id
inner join invoice_line il on i.invoice_id=il.invoice_id
inner join track t on il.track_id=t.track_id
inner join genre g on t.genre_id=g.genre_id
where g.name like 'rock'
order by c.email

/* 2. Let's invite the artists who have written the most rock music in our dataset. Write a
query that returns the Artist name and total track count of the top 10 rock bands */

select top 10 a.name,count(t.track_id) track_count from artist a
inner join album al on a.artist_id=al.artist_id
inner join track t on al.album_id=t.album_id
inner join genre g on t.genre_id=g.genre_id
where g.name like 'rock'
group by a.name
order by count(t.track_id) desc

/* 3. Return all the track names that have a song length longer than the average song length.
Return the Name and Milliseconds for each track. Order by the song length with the
longest songs listed first */

select top 5 name,milliseconds/60000 track_minute from track
where milliseconds>(select avg(milliseconds) from track)
order by 2 desc

-- ______________________________________________________________________________________________________________________ 
-- Question Set 3 – Advance

/* Q1. Find how much amount spent by each customer on artists? Write a query to return
customer name, artist name and total spent */

select c.customer_id,art.name,sum(i.total) from customer c
inner join Invoice i on c.customer_id=i.customer_id
inner join Invoice_Line il on il.invoice_id=i.invoice_id
inner join track t on t.track_id=il.track_id
inner join album  a on t.album_id=a.album_id
inner join artist art on art.artist_id=a.artist_id
group by art.name,c.customer_id

/* 2. We want to find out the most popular music Genre for each country. We determine the
most popular genre as the genre with the highest amount of purchases. Write a query
that returns each country along with the top Genre. For countries where the maximum
number of purchases is shared return all Genres */

WITH popular_genre as (
    SELECT COUNT(IL.quantity) quantity, C.country, G.name, G.genre_id,
    ROW_NUMBER() OVER(PARTITION BY C.country ORDER BY COUNT(IL.quantity) DESC) AS RN
    FROM customer C 
    INNER JOIN invoice I ON C.customer_id = I.customer_id
    INNER JOIN invoice_line IL ON I.invoice_id = IL.invoice_id
    INNER JOIN TRACK T ON T.track_id = IL.track_id
    INNER JOIN genre G ON G.genre_id = T.genre_id
    GROUP BY C.country, G.name, G.genre_id)
SELECT * FROM popular_genre WHERE RN <= 1
ORDER BY 1 DESC 

/* 3. Write a query that determines the customer that has spent the most on music for each
country. Write a query that returns the country along with the top customer and how
much they spent. For countries where the top amount spent is shared, provide all
customers who spent this amount */

WITH top_customer_spent as (
    SELECT C.customer_id, first_name, last_name, billing_country, SUM(total) AS 'total_spent',
    ROW_NUMBER() OVER(PARTITION BY billing_country ORDER BY SUM(total) DESC) AS RN
    FROM customer C 
    INNER JOIN invoice I 
    ON C.customer_id = I.customer_id
    GROUP by C.customer_id, first_name, last_name, billing_country)
SELECT * FROM top_customer_spent
WHERE RN <= 1
ORDER BY 5 DESC