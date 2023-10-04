/*
Maven Movies is a movie rental business which has several branch stores. Maven Movies has a database which includes 16 related tables, containing information about:
- Customers (Name, Adress, etc)
- Business (Staff, Rentals, etc)
- Inventory (Films, Categories, etc) 
*/ 

use mavenmovies;

/* 
1. My partner and I want to come by each of the stores in person and meet the managers. 
Please send over the managers’ names at each store, with the full address 
of each property (street address, district, city, and country please).  
*/ 
SELECT 
	staff.first_name AS manager_first_name,
    staff.last_name AS manager_last_name,
    address.address,
    address.district,
    city.city,
    country.country
FROM store
LEFT JOIN staff ON store.manager_staff_id = staff.staff_id
LEFT JOIN address ON store.address_id = address.address_id
LEFT JOIN city ON address.city_id = city.city_id
LEFT JOIN country ON city.country_id = country.country_id;
	
/*
2.	I would like to get a better understanding of all of the inventory that would come along with the business. 
Please pull together a list of each inventory item you have stocked, including the store_id number, 
the inventory_id, the name of the film, the film’s rating, its rental rate and replacement cost. 
*/
SELECT
	i.store_id,
    i.inventory_id,
    f.title,
    f.rating,
    f.rental_rate,
    f.replacement_cost
FROM inventory i
LEFT JOIN film f ON i.film_id = f.film_id;

/* 
3.	From the same list of films you just pulled, please roll that data up and provide a summary level overview 
of your inventory. We would like to know how many inventory items you have with each rating at each store. 
*/
SELECT
	i.store_id,  
    f.rating,
    COUNT(i.inventory_id) AS inventory_count
FROM inventory i
LEFT JOIN film f ON i.film_id = f.film_id
GROUP BY i.store_id, f.rating; 

/* 
4. Similarly, we want to understand how diversified the inventory is in terms of replacement cost. We want to 
see how big of a hit it would be if a certain category of film became unpopular at a certain store.
We would like to see the number of films, as well as the average replacement cost, and total replacement cost, 
sliced by store and film category. 
*/ 
SELECT
	i.store_id,
    c.name AS category,
    COUNT(i.inventory_id) AS number_of_films,
    ROUND(AVG(f.replacement_cost),2) AS average_replacement_cost,
    SUM(f.replacement_cost) AS total_replacement_cost
FROM film f
LEFT JOIN inventory i ON f.film_id = i.film_id
LEFT JOIN rental r ON r.inventory_id = i.inventory_id
LEFT JOIN film_category fc ON fc.film_id = f.film_id
LEFT JOIN category c ON fc.category_id = c.category_id
GROUP BY i.store_id, c.name;

/*
5.	We want to make sure you folks have a good handle on who your customers are. Please provide a list 
of all customer names, which store they go to, whether or not they are currently active, 
and their full addresses – street address, city, and country. 
*/
SELECT
	customer.first_name,
    customer.last_name,
    customer.store_id,
    customer.active AS active_status,
	address.address,
    city.city,
    country.country
FROM customer
LEFT JOIN address ON customer.address_id = address.address_id
LEFT JOIN city ON address.city_id = city.city_id
LEFT JOIN country ON city.country_id = country.country_id;
 
/*
6.	We would like to understand how much your customers are spending with you, and also to know 
who your most valuable customers are. Please pull together a list of customer names, their total 
lifetime rentals, and the sum of all payments you have collected from them. It would be great to 
see this ordered on total lifetime value, with the most valuable customers at the top of the list. 
*/ 
SELECT 
	customer.first_name,
    customer.last_name,
    COUNT(payment.rental_id) AS rental_count,
    SUM(payment.amount) AS total_payment
FROM payment
LEFT JOIN customer ON payment.customer_id = customer.customer_id
GROUP BY first_name, last_name
ORDER BY total_payment DESC;
    
/*
7. My partner and I would like to get to know your board of advisors and any current investors.
Could you please provide a list of advisor and investor names in one table? 
Could you please note whether they are an investor or an advisor, and for the investors, 
it would be good to include which company they work with. 
*/
SELECT
	first_name,
    last_name,
    'advisor' AS type,
    NULL
FROM advisor
UNION
SELECT
	first_name,
    last_name,
    'investor' AS type,
    company_name
FROM investor;

/*
8. We're interested in how well you have covered the most-awarded actors. 
Of all the actors with three types of awards, for what % of them do we carry a film?
And how about for actors with two types of awards? Same questions. 
Finally, how about actors with just one award? 
*/
SELECT
	award_count,
    COUNT(*) AS actor_count,
    CONCAT(ROUND(COUNT(*) / (SELECT COUNT(*) FROM actor_award) *100, 2), '%') AS percentage
FROM (
	SELECT
		actor_id,
		first_name,
		last_name,
		LENGTH(awards) - LENGTH(REPLACE(awards,',', '')) + 1 AS award_count
	FROM actor_award
    ) AS award_counts
GROUP BY award_count;