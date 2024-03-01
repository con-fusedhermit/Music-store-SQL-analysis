/* Let's find the country with the most invoices. */
Select billing_country, count(invoice_id) as no_of_invoices 
From invoice
Group by billing_country
Order by 2 desc;

/* Top 3 values of total invoice */ 
Select total From invoice
Order by total desc
limit 3;

/* The company would like to throw a promotional Music Festival, in the city 
that made them the most money. So now we find the city that has the highest sum of 
invoice totals*/
Select billing_city, 
       sum(total) as invoice_total
from invoice
Group by billing_city
Order by 2 desc
Limit 1;

/* Finding the customer that has spent the most amount in the music store. */
Select c.customer_id, 
       c.first_name, 
       c.last_name, 
       sum(i.total) as amount_spent
From invoice i
Join customer c 
On i.customer_id = c.customer_id
Group by c.customer_id, c.first_name, c.last_name
Order by amount_spent desc
Limit 1;

/* Now, We'll find all the Rock music listeners among the customers. 
Let's put them in a list in an alphabetical order*/
Select * from customer;
Select* from genre;

Select distinct c.email, c.first_name, c.last_name
From customer c
Join invoice i
on c.customer_id = i.customer_id
Join invoice_line il
on i.invoice_id = il.invoice_id
Join track t
on il.track_id = t.track_id
Join genre g 
on t.genre_id = g.genre_id
Where g.name = 'Rock'
Order by c.email; 

/* The company wants to invite the artists who have written the most rock music in our dataset.
Let's identify the top 10 rock band artists along ith their total track count */
Select a.artist_id as Artist_id, a.name as Top_10_Rock_Artists, count(t.track_id) as total_track_count 
From track t
Join album ab 
on t.album_id = ab.album_id
Join artist a 
on ab.artist_id = a.artist_id 
Join genre g 
on t.genre_id = g.genre_id
Where g.name = 'Rock'
Group by a.artist_id
Order by 3 desc
limit 10;

/* Now let's find the songs that are longer than average song lengths in our list.
We'll find the song name along with its length in milliseconds and order them from longest 
to shortest. */
Select name as Track_name, milliseconds as Song_length
From track
Where milliseconds > (
	Select Avg(milliseconds) 
    from track)
Order by 2 desc; 

 
 /*Now we'll find out how much each customer spent on the top artist. 
 We'll identify customer name, artist name and total spent */
  
with best_selling_artist as (
 select a.artist_id, a.name as artist_name, sum(vl.unit_price*vl.quantity) as Total_Sales
 from invoice_line vl
 join track t on vl.track_id = t.track_id
 join album al on al.album_id = t.album_id
 join artist a on a.artist_id = al.artist_id
 group by 1,2 
 order by 3 desc
 limit 1
)
select c.customer_id, c.first_name, c.last_name, bsa.artist_name, sum(il.unit_price * il.quantity) as amount_spent
from invoice i 
join customer c  on c.customer_id = i.customer_id
join invoice_line il on il.invoice_id = i.invoice_id 
join track tr on tr.track_id = il.track_id 
join album alb on alb.album_id = tr.album_id 
join best_selling_artist as bsa on bsa.artist_id = alb.artist_id 
group by 1,2,3,4
order by 5 desc ;  

/* We want to find out the most popular music Genre for each country. We determine the most popular genre as the genre 
with the highest amount of purchases. This is a query that returns each country along with the top Genre. For countries where 
the maximum number of purchases is shared return all Genres. */

with most_popular_genre as (

select count(il.quantity) as store_purchases, c.country, g.name as popular_genre, g.genre_id,
      row_number() over(partition by c.country order by count(il.quantity) desc )as rowno 
from invoice_line il 
join invoice i on i.invoice_id = il.invoice_id 
join customer c on i.customer_id = c.customer_id 
join track t on t.track_id = il.track_id
join genre g on g.genre_id = t.genre_id
group by  2, 3, 4
order by 2 asc, 1 desc 

)
select * from most_popular_genre where rowno <=1 ;

/* A query that determines the customer that has spent the most on music for each country. 
This will return the country along with the top customer and how much they spent.*/ 

with customer_country as (

select c.customer_id , c.first_name, c.last_name , i.billing_country, sum(i.total) as total_spent,
       row_number() over(partition by i.billing_country order by sum(i.total) desc ) as rowno
       
from invoice i 
join customer c on c.customer_id= i.customer_id 
group by 1,2,3,4 
order by 4 asc, 5 desc  )
select * from customer_country where rowno <=1 ;
