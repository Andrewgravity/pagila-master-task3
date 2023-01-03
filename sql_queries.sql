 -- 1 Вывести количество фильмов в каждой категории, отсортировать по убыванию.
SELECT COUNT(*), category.name
FROM film 
INNER JOIN film_category USING(film_id)
INNER JOIN category USING(category_id) 
GROUP BY category.name ORDER BY COUNT(*) DESC;

 -- 2 Вывести 10 актеров, чьи фильмы большего всего арендовали, отсортировать по убыванию.
SELECT COUNT (rental.rental_id), actor.first_name, actor.last_name
FROM film
INNER JOIN film_actor USING(film_id)
INNER JOIN actor USING(actor_id) INNER JOIN inventory USING(film_id)
INNER JOIN rental USING(inventory_id) GROUP BY film.title, actor.first_name, actor.last_name
ORDER BY COUNT(rental.rental_id) DESC LIMIT 10;

 -- 3 Вывести категорию фильмов, на которую потратили больше всего денег.
SELECT db1.title, db1.numOfRented * db2.replacement_cost as total
FROM (SELECT COUNT (rental.rental_id) as numOfRented, film.title FROM film INNER JOIN film_actor USING(film_id) INNER JOIN actor USING(actor_id) INNER JOIN inventory USING(film_id) INNER JOIN rental USING(inventory_id) GROUP BY film.title) as db1
INNER JOIN (SELECT film.title, film.replacement_cost FROM film GROUP BY film.title, film.replacement_cost ORDER BY film.replacement_cost DESC) as db2 
USING(title) 
ORDER BY total DESC;

 -- 4 Вывести названия фильмов, которых нет в inventory. Написать запрос без использования оператора IN.
SELECT film.title, film_id
FROM film
LEFT JOIN inventory USING(film_id)
WHERE inventory.film_id IS NULL
GROUP BY film.title, film_id
ORDER BY film_id DESC;

 -- 5 Вывести топ 3 актеров, которые больше всего появлялись в фильмах в категории “Children”. Если у нескольких актеров одинаковое кол-во фильмов, вывести всех.
SELECT COUNT(film.title) as numOfFilms, actor.first_name, actor.last_name, category.name as category
FROM film
INNER JOIN film_actor USING(film_id)
INNER JOIN actor USING(actor_id)
INNER JOIN film_category USING(film_id)
INNER JOIN category USING(category_id)
WHERE category.name = 'Children'
GROUP BY first_name, last_name, category
HAVING COUNT(film.title) IN (SELECT COUNT(film.title) as numOfFilms FROM film INNER JOIN film_actor USING(film_id) INNER JOIN actor USING(actor_id) INNER JOIN film_category USING(film_id) INNER JOIN category USING(category_id) WHERE category.name = 'Children' GROUP BY actor.first_name, actor.last_name, category.name ORDER BY COUNT(film.title) DESC LIMIT 3)
ORDER BY numOfFilms DESC;

  -- 6 Вывести города с количеством активных и неактивных клиентов (активный — customer.active = 1). Отсортировать по количеству неактивных клиентов по убыванию.
SELECT city, COUNT(active) as num_active, COUNT(inactive) as num_inactive FROM
(SELECT city,
CASE
WHEN customer.active = 1
THEN 'active'
ELSE NULL
END as active,
CASE
WHEN customer.active != 1
THEN 'inactive'
ELSE NULL
END as inactive
FROM city
INNER JOIN address USING(city_id)
INNER JOIN customer USING(address_id)
GROUP BY city, customer.active) as db
GROUP BY city
ORDER BY num_inactive DESC;

 -- 7 Вывести категорию фильмов, у которой самое большое кол-во часов суммарной аренды в городах (customer.address_id в этом city), и которые начинаются на букву “a”. То же самое сделать для городов в которых есть символ “-”. Написать все в одном запросе.
SELECT category.name, city.city, SUM(DATE_PART('hour', rental.rental_date::date) - DATE_PART('hour', rental.return_date::date) + 1) as hours
FROM category 
INNER JOIN film_category USING(category_id)
INNER JOIN film USING(film_id)
INNER JOIN inventory USING(film_id)
INNER JOIN store USING(store_id)
INNER JOIN address USING(address_id)
INNER JOIN city USING(city_id)
INNER JOIN rental USING(inventory_id)
GROUP BY city.city, category.name
ORDER BY hours DESC;


-- SELECT city
-- FROM city
-- WHERE city LIKE 'a%' OR city LIKE 'A%' OR city LIKE '%-%';