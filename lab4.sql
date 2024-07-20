SELECT с.email
FROM customer с
INNER JOIN rental r
ON с.customer_id = r.customer_id
WHERE date(r.rental_date) ='2005-06-14';

SELECT с.email
FROM customer с
INNER JOIN rental r
ON с.customer_id = r.customer_id
WHERE date(r.rental_date) <>'2005-06-14'
LIMIT 500;

DELETE FROM rental
WHERE date_part('year', rental_date) = 2004;

DELETE FROM rental
WHERE date_part('year', rental_date) <> 2005 AND date_part('year', rental_date) <> 2006;

SELECT customer_id, rental_date
FROM rental
WHERE rental_date < '2005-05-25'
AND rental_date >= '2005-05-14';

SELECT customer_id, rental_date
FROM rental
WHERE rental_date BETWEEN '2005-05-25' AND '2005-06-14';

SELECT last_name, first_name
FROM customer
WHERE last_name BETWEEN 'FA' AND 'FR';

SELECT title, rating
FROM film
WHERE rating = 'G' OR rating = 'PG';

SELECT title, rating
FROM film
WHERE rating IN ('G', 'PG', 'R');

SELECT count(payment_id)
FROM payment
WHERE customer_id<>5 
AND (amount > 8 OR date(payment_date) = '2005-08-23');

SELECT count(payment_id)
FROM payment
WHERE customer_id = 5
AND NOT (amount > 6 OR date(payment_date) = '2005-06-19');

SELECT customer_id, rental_date
FROM rental
WHERE rental_date BETWEEN '2005-05-25' AND '2005-06-14';

SELECT *
FROM payment
WHERE amount IN (1.98, 7.98, 9.98);

SELECT title, rating
FROM film
WHERE rating IN ('G', 'PG', 'R');

SELECT customer_id, rental_date
FROM rental
WHERE rental_date BETWEEN '2005-05-25' AND '2005-06-14';

--3.1--
SELECT last_name, first_name
FROM customer
WHERE left(last_name, 1) = 'Q';

SELECT last_name, first_name
FROM customer
WHERE last_name LIKE 'A_T%S';

SELECT last_name, first_name
FROM customer
WHERE last_name LIKE 'Q%' OR last_name LIKE 'Y%';

SELECT last_name, first_name
FROM customer
WHERE last_name ~ (substring(last_name, '^[QY]'));

SELECT rating
FROM film WHERE title LIKE '%PET%';

SELECT title, rating
FROM film
WHERE rating IN (SELECT rating FROM film WHERE title LIKE '%PET%');

SELECT rental_id, customer_id
FROM rental
WHERE return_date IS NULL;

SELECT last_name, first_name
FROM customer
WHERE last_name LIKE 'A%' OR last_name LIKE 'B%';

SELECT last_name, first_name
FROM customer
WHERE last_name ~ (substring(last_name, '^[AB]'));

SELECT last_name, first_name
FROM customer
WHERE last_name LIKE '_A%W%';

SELECT rating
FROM film
WHERE title LIKE '%KILL%';
