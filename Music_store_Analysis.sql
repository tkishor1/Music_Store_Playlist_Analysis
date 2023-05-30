show databases;
use music_store_database;
show tables;

describe music_store_database.album;
describe music_store_database.artist;
describe music_store_database.customer;
describe music_store_database.employee;
describe music_store_database.genre;
describe music_store_database.invoice;
describe music_store_database.invoice_line;
describe music_store_database.media_type;
describe music_store_database.playlist;
describe music_store_database.playlist_track;
describe music_store_database.track;

select table_name,table_rows as Total_No_of_rows
from information_schema.tables
where table_schema='music_store_database';

select table_name,table_rows as Total_no_rows
from information_schema.tables
where table_schema='music_store_database';

select table_name,table_rows as Total_no_of_rows
from information_schema.tables
where table_schema='music_store_database';

select count(*) as No_of_rows from album;
select count(*) as No_of_rows from artist;
select count(*) as No_of_rows from customer;
select count(*) as No_of_rows from employee;
select count(*) as NO_of_rows from genre;
select count(*) as NO_of_rows from invoice;
select count(*) as No_of_rows from invoice_line;
select count(*) as No_of_rows from media_type;
select count(*) as No_of_rows from playlist;
select count(*) as NO_of_rows from playlist_track;
select count(*) as No_of_rows from track;

select * from playlist_track;
select * from invoice_line;
select * from album;
select * from customer;

select 
sum(customer_id is null) as customer_id_NUlls,
sum(first_name is null) as first_name_Nulls,
sum(last_name is null) as last_name_Nulls,
sum(company is null) as company_Nulls,
sum(address is null) as address_Nulls,
sum(city is null) as city_Nulls,
sum(state is null) as state_Nulls,
sum(country is null) as country_Nulls,
sum(postal_code is null) as postal_code_Nulls,
sum(phone is null) as Phone_NUlls,
sum(fax is null) as fax_NUlls,
sum(email is null) as email_Nulls,
sum(support_rep_id is null) as support_rep_id_Null
from customer;


-- Question Set 1 - Easy
-- Q1: Who is the senior most employee based on job title?

show tables;

select * from employee;

select title,last_name,first_name 
from employee
order by levels desc
limit 1;

-- or

select title,last_name,first_name
from employee
order by levels desc
limit 1;

-- Q2: Which countries have the most Invoices?

select * from invoice;

select count(*) as C,billing_country
from invoice
group by billing_country
order by  C desc;

-- Q3: What are top 3 values of total invoice?

select * from invoice;

select total 
from invoice
order by total desc
limit 3;

-- Q4: Which city has the best customers? 
-- We would like to throw a promotional Music Festival in the city we made the most money. 
-- Write a query that returns one city that has the highest sum of invoice totals.
-- Return both the city name & sum of all invoice totals

select * from customer;
select * from invoice;

select billing_city,sum(total) as invoicetotal
from invoice
group by billing_city
order by invoicetotal desc
limit 1;


-- Question 5: Who is the best customer? The customer who has spent the most money will be declared the best customer. 
-- Write a query that returns the person who has spent the most money.

select * from invoice;
select * from customer;

select first_name,last_name,count(total) from customer
join invoice
on customer.customer_id = invoice.customer_id
group by first_name,last_name 
order by count(total) desc
limit 1;

-- Question Set 2 - Moderate
-- Q1: Write query to return the email, first name, last name, & 
-- Genre of all Rock Music listeners. Return your list ordered alphabetically by email starting with A


select * from customer;
select * from genre;
select * from invoice_line;
select * from invoice;

SELECT DISTINCT email,first_name, last_name
FROM customer
JOIN invoice ON customer.customer_id = invoice.customer_id
JOIN invoice_line ON invoice.invoice_id = invoice_line.invoice_id
WHERE track_id IN(
	SELECT track_id FROM track
	JOIN genre ON track.genre_id = genre.genre_id
	WHERE genre.name LIKE 'Rock'
)
ORDER BY email;
	
-- Second Method

select * from invoice_line;
select * from invoice_line;

select distinct email as email,first_name as firstname,last_name as lastname,genre.name as name
from customer
join invoice on invoice.customer_id = customer.customer_id
join invoice_line on invoice_line.invoice_id  = invoice.invoice_id
join track on track.track_id  = invoice_line.track_id
join genre on genre.genre_id = track.genre_id
where genre.name like 'ROCK'
order by email;


-- Q2: Let's invite the artists who have written the most rock music in our dataset. 
-- Write a query that returns the Artist name and total track count of the top 10 rock bands

select * from album;
select * from artist;
select * from genre;
select * from track;

SELECT artist.artist_id, artist.name,COUNT(artist.artist_id) AS number_of_songs
FROM track
JOIN album ON album.album_id = track.album_id
JOIN artist ON artist.artist_id = album.artist_id
JOIN genre ON genre.genre_id = track.genre_id
WHERE genre.name LIKE 'Rock'
GROUP BY artist.artist_id
ORDER BY number_of_songs DESC
LIMIT 10;



-- Q3: Return all the track names that have a song length longer than the average song length.
-- Return the Name and Milliseconds for each track.
-- Order by the song length with the longest songs listed first.

select * from track;

select name,milliseconds
from track
where milliseconds >(
select avg(milliseconds) as avg_track_length
from track)
order by milliseconds desc;
 

-- Question Set 3 - Advance 
-- Q1: Find how much amount spent by each customer on artists?
-- Write a query to return customer name, artist name and total spent

-- Steps to Solve: First, find which artist has earned the most according to the InvoiceLines.
-- Now use this artist to find which customer spent the most on this artist. 
-- For this query, you will need to use the Invoice, InvoiceLine, Track, Customer, Album, and Artist tables.
-- Note, this one is tricky because the Total spent in the Invoice table might not be on a single product, 
-- so you need to use the InvoiceLine table to find out how many of each product was purchased, and then multiply
-- this by the price for each artist.

WITH best_selling_artist as(
select artist.artist_id as artist_id,artist.name as artist_name,sum(invoice_line.unit_price * invoice_line.quantity) as
Total_sales from invoice_line
join track on track.track_id = invoice_line.track_id
join album on album.album_id = track.album_id
join artist on artist.artist_id = album.artist_id
group by 1
order by 3 desc
limit 1
)

select c.customer_id,c.first_name,c.last_name,bsa.artist_name,sum(il.unit_price * il.quantity) as amount_spent
from invoice i 
join customer c on c.customer_id = i.customer_id
join invoice_line il on il.invoice_id = i.invoice_id
join track t on t.track_id = il.track_id
join album alb on alb.album_id = t.ablum_id
join best_selling_artist bsa on bsa.artist_id = alb.artist_id
group by 1,2,3,4
order by 5 desc;

-- Q2: We want to find out the most popular music Genre for each country. 
-- We determine the most popular genre as the genre with the highest amount of purchases. 
-- Write a query that returns each country along with the top Genre. 
-- For countries where the maximum number of purchases is shared return all Genres.
-- Steps to Solve:  There are two parts in question- first most popular music genre and second need data at country level.

-- Method 1: Using CTE 

WITH popular_genre AS 
(
    SELECT COUNT(invoice_line.quantity) AS purchases, customer.country, genre.name, genre.genre_id, 
	ROW_NUMBER() OVER(PARTITION BY customer.country ORDER BY COUNT(invoice_line.quantity) DESC) AS RowNo 
    FROM invoice_line 
	JOIN invoice ON invoice.invoice_id = invoice_line.invoice_id
	JOIN customer ON customer.customer_id = invoice.customer_id
	JOIN track ON track.track_id = invoice_line.track_id
	JOIN genre ON genre.genre_id = track.genre_id
	GROUP BY 2,3,4
	ORDER BY 2 ASC, 1 DESC
)
SELECT * FROM popular_genre WHERE RowNo <= 1;

 -- Method 2: : Using Recursive
 
 WITH RECURSIVE
	sales_per_country AS(
		SELECT COUNT(*) AS purchases_per_genre, customer.country, genre.name, genre.genre_id
		FROM invoice_line
		JOIN invoice ON invoice.invoice_id = invoice_line.invoice_id
		JOIN customer ON customer.customer_id = invoice.customer_id
		JOIN track ON track.track_id = invoice_line.track_id
		JOIN genre ON genre.genre_id = track.genre_id
		GROUP BY 2,3,4
		ORDER BY 2
	),
	max_genre_per_country AS (SELECT MAX(purchases_per_genre) AS max_genre_number, country
		FROM sales_per_country
		GROUP BY 2
		ORDER BY 2)

SELECT sales_per_country.* 
FROM sales_per_country
JOIN max_genre_per_country ON sales_per_country.country = max_genre_per_country.country
WHERE sales_per_country.purchases_per_genre = max_genre_per_country.max_genre_number;


 
-- Q3: Write a query that determines the customer that has spent the most on music for each country.
-- Write a query that returns the country along with the top customer and how much they spent. 
-- For countries where the top amount spent is shared, provide all customers who spent this amount
-- Steps to Solve:  Similar to the above question. 
-- There are two parts in question- first find the most spent on music for each 
-- country and second filter the data for respective customers. 

-- Method 1: using CTE


WITH Customter_with_country AS (
		SELECT customer.customer_id,first_name,last_name,billing_country,SUM(total) AS total_spending,
	    ROW_NUMBER() OVER(PARTITION BY billing_country ORDER BY SUM(total) DESC) AS RowNo 
		FROM invoice
		JOIN customer ON customer.customer_id = invoice.customer_id
		GROUP BY 1,2,3,4
		ORDER BY 4 ASC,5 DESC)
SELECT * FROM Customter_with_country WHERE RowNo <= 1;
          

-- Method 2: Using Recursive

WITH RECURSIVE 
	customter_with_country AS (
		SELECT customer.customer_id,first_name,last_name,billing_country,SUM(total) AS total_spending
		FROM invoice
		JOIN customer ON customer.customer_id = invoice.customer_id
		GROUP BY 1,2,3,4
		ORDER BY 2,3 DESC),

	country_max_spending AS(
		SELECT billing_country,MAX(total_spending) AS max_spending
		FROM customter_with_country
		GROUP BY billing_country)

SELECT cc.billing_country, cc.total_spending, cc.first_name, cc.last_name, cc.customer_id
FROM customter_with_country cc
JOIN country_max_spending ms
ON cc.billing_country = ms.billing_country
WHERE cc.total_spending = ms.max_spending
ORDER BY 1;

select * from customer;
select * from artist;
select * from album;
select * from track;
select * from invoice;
select * from invoice_line;