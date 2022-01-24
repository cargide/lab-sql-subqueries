-- 1) How many copies of the film Hunchback Impossible exist in the inventory system?
SELECT COUNT(I.inventory_id) AS available_copies
FROM sakila.inventory I 
JOIN sakila.film F USING(film_id)
WHERE F.title = 'Hunchback Impossible';

-- 2) List all films whose length is longer than the average of all the films.
SELECT title FROM sakila.film
WHERE length > (
	SELECT AVG(length)
    FROM sakila.film
);

-- 3) Use subqueries to display all actors who appear in the film Alone Trip.
-- Testing the subquery
SELECT A.actor_id from sakila.film_actor A
join sakila.film F using(film_id) 
where F.title = 'Alone Trip';

SELECT CONCAT(first_name, ' ', last_name) AS actor 
FROM sakila.actor
WHERE actor_id IN(
	SELECT A.actor_id from sakila.film_actor A
	join sakila.film F using(film_id) 
	where F.title = 'Alone Trip'
);


-- 4) Sales have been lagging among young families, and you wish to target all family movies for a promotion. Identify all movies categorized as family films.
-- Get list of Family movies
SELECT film_id FROM sakila.film_category F
JOIN sakila.category C USING(category_id)
WHERE name = 'Family';

SELECT title FROM sakila.film
WHERE film_id IN (
	SELECT film_id FROM sakila.film_category F
	JOIN sakila.category C USING(category_id)
	WHERE name = 'Family'
);
	
-- 5) Get name and email from customers from Canada using subqueries.
-- Only with subqueries
SELECT CONCAT(first_name, ' ', last_name) AS name, email 
FROM sakila.customer
WHERE address_id IN(
	SELECT address_id FROM sakila.address
	WHERE city_id IN (
		SELECT city_id FROM sakila.city
        WHERE country_id IN(
			SELECT country_id FROM sakila.country
            WHERE country = 'Canada'
        )
    )
);

-- Only with joins

SELECT CONCAT(CU.first_name, ' ', CU.last_name) AS name, CU.email 
FROM sakila.customer CU
INNER JOIN sakila.address USING(address_id)
INNER JOIN sakila.city USING(city_id)
INNER JOIN sakila.country CO USING(country_id)
WHERE CO.country = 'Canada';

-- 6) Which are films starred by the most prolific actor?
-- Find the most prolific actor
SELECT actor_id, count(film_id) FROM sakila.film_actor 
group by actor_id
order by count(film_id) desc;

-- Clean the query to get only one ID
SELECT actor_id FROM sakila.film_actor 
group by actor_id
order by count(film_id) DESC
LIMIT 1;

-- Get the list of movies
SELECT title FROM sakila.film F
JOIN sakila.film_actor A USING(film_id)
WHERE A.actor_id = (
	SELECT actor_id FROM sakila.film_actor 
	group by actor_id
	order by count(film_id) DESC
	LIMIT 1
);

-- 7) Films rented by most profitable customer. 
-- Most profitable customer
SELECT customer_id from sakila.payment
GROUP BY customer_id
ORDER BY sum(amount) DESC
LIMIT 1;

-- Get the list of movies
SELECT F.title FROM sakila.film F
INNER JOIN sakila.inventory USING(film_id)
INNER JOIN sakila.rental R USING(inventory_id)
WHERE customer_id = (
	SELECT customer_id from sakila.payment
	GROUP BY customer_id
	ORDER BY sum(amount) DESC
	LIMIT 1
);

-- 8) Customers who spent more than the average payments.
SELECT CONCAT(first_name, ' ', last_name) AS customer
FROM sakila.customer
WHERE customer_id IN(
	SELECT customer_id FROM sakila.payment
	WHERE amount >(
		SELECT avg(amount)
		FROM sakila.payment
    )
);

-- RESCUED QUESTIONS
-- Get all pairs of customers that have rented the same film more than 3 times.
-- I still don't understand how to do this with subqueries


-- For each film, list the actor that has acted in the most films.
-- Apparently there are 3 movies in the film table that don't appear in the film_actor table, that could mean they have no actors
SELECT F.title, CONCAT(A.first_name, ' ', A.last_name) AS actor FROM sakila.film_actor FA
INNER JOIN sakila.actor A USING (actor_id)
INNER JOIN sakila.film F USING (film_id)
WHERE FA.actor_id = (
	SELECT actor_id FROM sakila.film_actor 
    WHERE film_id = FA.film_id 
	GROUP BY actor_id
	ORDER BY count(film_id) DESC
    LIMIT 1
);

