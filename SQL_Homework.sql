
USE sakila;
# 1a. Display the first and last names of all actors from the table `actor`.
SELECT first_name AS 'First Name', last_name AS 'Last Name'
FROM actor


# 1b. Display the first and last name of each actor in a single column in upper case letters. Name the column `Actor Name`.
SELECT CONCAT(first_name,' ', last_name) AS 'Actor Name'
FROM actor


# 2a. You need to find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe." What is one query would you use to obtain this information?
SELECT actor_id AS 'ID', first_name AS 'First Name', last_name AS 'Last Name'
FROM actor
WHERE first_name like 'Joe'

# 2b. Find all actors whose last name contain the letters `GEN`:
SELECT actor_id AS 'ID', first_name AS 'First Name', last_name AS 'Last Name'
FROM actor
WHERE last_name like '%GEN%'

# 2c. Find all actors whose last names contain the letters `LI`. This time, order the rows by last name and first name, in that order:
SELECT actor_id AS 'ID', first_name AS 'First Name', last_name AS 'Last Name'
FROM actor
WHERE last_name like '%LI%'
ORDER BY last_name, first_name


# 2d. Using `IN`, display the `country_id` and `country` columns of the following countries: Afghanistan, Bangladesh, and China:
SELECT country_id AS 'ID', country AS 'Country'
FROM country
WHERE country IN ("Afghanistan", "Bangladesh", "China")


# 3a. You want to keep a description of each actor. You don't think you will be performing queries on a description, so create a column in the table `actor` named `description` and use the data type `BLOB` (Make sure to research the type `BLOB`, as the difference between it and `VARCHAR` are significant).
ALTER TABLE actor
ADD description BLOB; 


# 3b. Very quickly you realize that entering descriptions for each actor is too much effort. Delete the `description` column.
ALTER TABLE actor
DROP COLUMN description; 
SELECT * FROM actor

# 4a. List the last names of actors, as well as how many actors have that last name.
SELECT last_name AS 'Last Name', COUNT(last_name) AS 'Count of Name'
FROM actor
GROUP BY last_name


# 4b. List last names of actors and the number of actors who have that last name, but only for names that are shared by at least two actors
SELECT last_name AS 'Last Name', COUNT(last_name) AS 'Count of Name'
FROM actor
GROUP BY last_name
HAVING COUNT(last_name) > 1;

# 4c. The actor `HARPO WILLIAMS` was accidentally entered in the `actor` table as `GROUCHO WILLIAMS`. Write a query to fix the record.
SET SQL_SAFE_UPDATES = 0;
UPDATE actor
 SET first_name = 'HARPO'
 WHERE actor_id like 172; 
SET SQL_SAFE_UPDATES = 1; 


# 4d. Perhaps we were too hasty in changing `GROUCHO` to `HARPO`. It turns out that `GROUCHO` was the correct name after all! In a single query, if the first name of the actor is currently `HARPO`, change it to `GROUCHO`.
SET SQL_SAFE_UPDATES = 0;
UPDATE actor
 SET first_name = 'GROUCHO'
 WHERE first_name like 'HARPO'; 
SET SQL_SAFE_UPDATES = 1; 


# 5a. You cannot locate the schema of the `address` table. Which query would you use to re-create it?

  # Hint: [https://dev.mysql.com/doc/refman/5.7/en/show-create-table.html](https://dev.mysql.com/doc/refman/5.7/en/show-create-table.html)

SHOW CREATE TABLE address; 
DESCRIBE address;  
  

# 6a. Use `JOIN` to display the first and last names, as well as the address, of each staff member. Use the tables `staff` and `address`:
SELECT  CONCAT(s.first_name,' ', s.last_name) AS 'Staff Name', a.address AS 'Address', a.address2 AS 'Address 2', c.city AS 'City', a.district AS 'District', a.postal_code AS 'Postal Code'
FROM staff s
INNER JOIN address a
ON (s.address_id = a.address_id)
INNER JOIN city c
ON (a.city_id = c.city_id);


# 6b. Use `JOIN` to display the total amount rung up by each staff member in August of 2005. Use tables `staff` and `payment`.

SELECT CONCAT(s.first_name,' ', s.last_name) AS 'Staff Name', concat('$', format(SUM(amount), 2)) AS 'Amount'
FROM payment p
INNER JOIN staff s
ON (s.staff_id = p.staff_id)
WHERE payment_date 
    BETWEEN CAST('2005-08-01' AS DATETIME) 
    AND CAST('2005-08-31' AS DATETIME) 
GROUP BY s.staff_id;


# 6c. List each film and the number of actors who are listed for that film. Use tables `film_actor` and `film`. Use inner join.
SELECT f.title AS 'Title', count(fa.actor_id) AS 'Actors'
FROM film f
INNER JOIN film_actor fa 
ON (f.film_id = fa.film_id)
GROUP BY f.title;


# 6d. How many copies of the film `Hunchback Impossible` exist in the inventory system?
SELECT f.title AS 'Title', count(i.inventory_id) AS Count
FROM inventory i
JOIN film f 
ON (f.film_id = i.film_id)
WHERE f.title like 'Hunchback Impossible'
GROUP BY f.film_id


# 6e. Using the tables `payment` and `customer` and the `JOIN` command, list the total paid by each customer. List the customers alphabetically by last name:
SELECT CONCAT(c.first_name,' ', c.last_name) AS 'Customer Name', sum(p.amount)
FROM customer c
JOIN payment p 
ON (p.customer_id = c.customer_id)
GROUP BY c.customer_id
ORDER BY c.last_name

# 7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. As an unintended consequence, films starting with the letters `K` and `Q` have also soared in popularity. 
#Use subqueries to display the titles of movies starting with the letters `K` and `Q` whose language is English.
SELECT title
FROM film
WHERE language_id IN
(
  SELECT l.language_id
  FROM language l
  WHERE l.name LIKE 'English'
)
AND title like 'K%' or title like 'Q%';


# 7b. Use subqueries to display all actors who appear in the film `Alone Trip`.
SELECT CONCAT(first_name,' ', last_name) AS 'Actor Name'
FROM actor
WHERE actor_id IN
(
  SELECT actor_id
  FROM film_actor
  WHERE film_id IN
  (
   SELECT film_id
   FROM film
   WHERE title = 'ALONE TRIP'
  )
);

# 7c. You want to run an email marketing campaign in Canada, for which you will need the names and email addresses of all Canadian customers. Use joins to retrieve this information.

SELECT CONCAT(first_name,' ', last_name) AS 'Actor Name', email
    FROM customer
    WHERE address_id
    IN (
        SELECT address_id
            FROM address
            WHERE city_id
            IN (
                SELECT city_id
                    FROM city
                    WHERE country_id
                        IN (
                            SELECT country_id
                                FROM country
                                WHERE country = "Canada"
                            )
                )
        );
        


# 7d. Sales have been lagging among young families, and you wish to target all family movies for a promotion. Identify all movies categorized as _family_ films.
SELECT f.title AS Title, c.name AS Category
from film f
JOIN film_category fc
ON (f.film_id = fc.film_id)
JOIN category c
ON (c.category_id = fc.category_id)
WHERE c.name like "Family"

# 7e. Display the most frequently rented movies in descending order.
SELECT f.title AS Title, count(rental_id) AS 'TimesRented'
FROM rental r
JOIN inventory i
ON (r.inventory_id = i.inventory_id)
JOIN film f
ON (f.film_id = i.film_id)
GROUP BY f.title
ORDER BY TimesRented DESC



# 7f. Write a query to display how much business, in dollars, each store brought in.
SELECT concat(c.city, ', ', cy.country) AS 'Store', concat(w.first_name,', ', w.last_name) AS 'Manager', sum(p.amount) AS 'TotalSales' 
FROM payment p
JOIN rental r
ON (p.rental_id = r.rental_id)
JOIN inventory i
ON (i.inventory_id = r.inventory_id)
JOIN store s
ON (i.store_id = s.store_id)
JOIN address a
ON (a.address_id = s.address_id)
JOIN city c
ON (c.city_id = a.city_id)
JOIN country cy
ON (c.country_id = cy.country_id)
JOIN staff w
ON (s.manager_staff_id = w.staff_id)
GROUP BY s.store_id
ORDER BY cy.country, c.city


# 7g. Write a query to display for each store its store ID, city, and country.
SELECT s.store_id, concat(c.city, ', ', cy.country) AS 'Store'
FROM store s
JOIN address a
ON (a.address_id = s.address_id)
JOIN city c
ON (c.city_id = a.city_id)
JOIN country cy
ON (c.country_id = cy.country_id)
JOIN staff w
ON (s.manager_staff_id = w.staff_id)
GROUP BY s.store_id


# 7h. List the top five genres in gross revenue in descending order. (##Hint##: you may need to use the following tables: category, film_category, inventory, payment, and rental.)
SELECT c.name AS 'Category', concat('$', format(SUM(p.amount), 2)) AS 'TotalSales' 
FROM payment p 
JOIN rental r
ON (p.rental_id = r.rental_id)
JOIN inventory i
ON (r.inventory_id = i.inventory_id)
JOIN film f
ON (i.film_id = f.film_id)
JOIN film_category fc
ON (f.film_id = fc.film_id)
JOIN category c
ON (fc.category_id = c.category_id)
GROUP BY c.name
ORDER BY TotalSales DESC
LIMIT 5;


# 8a. In your new role as an executive, you would like to have an easy way of viewing the Top five genres by gross revenue. Use the solution from the problem above to create a view. If you haven't solved 7h, you can substitute another query to create a view.
CREATE VIEW Top_5_Genres AS
SELECT c.name AS 'Category', concat('$', format(SUM(p.amount), 2)) AS 'TotalSales' 
FROM payment p 
JOIN rental r
ON (p.rental_id = r.rental_id)
JOIN inventory i
ON (r.inventory_id = i.inventory_id)
JOIN film f
ON (i.film_id = f.film_id)
JOIN film_category fc
ON (f.film_id = fc.film_id)
JOIN category c
ON (fc.category_id = c.category_id)
GROUP BY c.name
ORDER BY TotalSales DESC
LIMIT 5


# 8b. How would you display the view that you created in 8a?
SELECT * FROM Top_5_Genres

# 8c. You find that you no longer need the view `top_five_genres`. Write a query to delete it.
DROP VIEW Top_5_Genres
