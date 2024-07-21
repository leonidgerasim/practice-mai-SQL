/*2.1*/
/*Алекс решил написать запрос о последнем клиенте, который был добавлен в базу. Для этого он использовал подзапрос с использованием агрегатной функции.
У него получился подзапрос, который возвращает максимальное значение, найденное в столбце customer_id в таблице customer, а затем содержащая его инструкция возвращает данные об этом клиенте:*/
SELECT customer_id, first_name, last_name
FROM customer
WHERE customer_id =
(SELECT max(customer_id)
FROM customer);

/*Алекс решил найти все города, находящиеся не в Индии, используя скалярный подзапрос, который возвращает идентификатор страны для Индии*/
SELECT city_id, city
FROM city
WHERE country_id <>
(SELECT country_id
FROM country
WHERE country = 'India');

/*Алекс задался вопросом: что будет, если подзапрос используется в условии равенства, но возвращает более одной строки?
Он решил изменить запрос так, чтобы в подзапросе было условие на поиск идентификаторов стран не равных Индии, 
а основной запрос должен искать города для этих идентификаторов. Но в результате получил ошибку:*/
SELECT city_id, city
FROM city
WHERE country_id =
(SELECT country_id
FROM country
WHERE country <> 'India');

/*Как ее исправить? Можно использовать операторы IN или NOT IN. Ведь проверить на равенство одно значение с набором значений нельзя, но можно проверить, 
входит ли конкретное значение в набор. Перепиши запрос с ошибкой так, чтобы он работал, используя оператор IN:*/
SELECT city_id, city
FROM city
WHERE country_id IN
(SELECT country_id
FROM country
WHERE country <> 'India');

/*Отлично, Алекс разобрался, что нужно делать, и решил проверить, как работает запрос с операторами вхождения. В запросе оператор IN используется 
с подзапросом в правой части условия фильтра, чтобы получить все города, которые не находятся (NOT IN) в Канаде или Мексике:*/
SELECT city_id, city
FROM city
WHERE country_id IN
(SELECT country_id
FROM country
WHERE country NOT IN ('Canada', 'Mexico'));

/*Алекс придумал новый запрос, который находит всех клиентов, которые никогда не получали фильмы напрокат бесплатно. Для этого он использовал оператор ALL, 
который позволяет сравнивать отдельное значение и каждое значение в наборе.
Чтобы создать такое условие, нужно использовать один из операторов сравнения (=, <>, <, > и т. д.) в сочетании с оператором ALL.*/
SELECT first_name, last_name 
FROM customer
WHERE customer_id <> ALL
(SELECT customer_id
FROM payment
WHERE amount = 0);

/*Сравните результат его работы с запросом, который использует оператор NOT IN:*/
SELECT first_name, last_name
FROM customer
WHERE customer_id NOT IN
(SELECT customer_id
FROM payment
WHERE amount = 0);

/*Руководство компании попросило Алекса найти клиентов, общее количество прокатов фильмов у которых не превышает значение
у любого из североамериканских клиентов. Для этого Алексу потребуется подзапрос, 
который  выдавал бы общее количество прокатов фильмов для каждого клиента в Северной Америке: Канаде, США и Мексике:*/
SELECT customer_id, count(*)
FROM rental
GROUP BY customer_id
HAVING count(*) > ALL
(SELECT count(*)
FROM rental r
INNER JOIN customer c
ON r.customer_id = c.customer_id
INNER JOIN address a
ON c.address_id = a.address_id
INNER JOIN city ct
ON a.city_id = ct.city_id
INNER JOIN country co
ON ct.country_id = co.country_id
WHERE co.country IN ('United States', 'Mexico', 'Canada')
 GROUP BY r.customer_id );

/*Теперь нужно найти всех клиентов, чьи суммарные платежи за прокат фильмов превышают суммарные платежи всех клиентов в Боливии, 
Парагвае или Чили. Для этого Алекс решил использовать в качестве примера предыдущий запрос, но изменил его в соответствии с требованиями задачи: 
на этот раз он использовал оператор ANY, который позволяет сравнивать значение с членами набора значений. В отличие от ALL, условие, использующее оператор ANY, 
вычисляется как истинное, как только найдется хотя бы одно выполняющееся сравнение.
Подзапрос должен вернуть общую стоимость проката фильмов для всех клиентов в Боливии, Парагвае, Чили, а сам запрос — клиентов,
которые израсходовали сумму, превышающую расходы клиентов хотя бы одной из этих трех стран:*/
SELECT customer_id, sum(amount)
FROM payment
GROUP BY customer_id
HAVING sum(amount) > ANY
(SELECT sum(p.amount)
FROM payment p
INNER JOIN customer c
ON p.customer_id = c.customer_id
INNER JOIN address a
ON c.address_id = a.address_id
INNER JOIN city ct
ON a.city_id = ct.city_id
INNER JOIN country co
ON ct.country_id = co.country_id
WHERE co.country IN ('Bolivia', 'Paraguay', 'Chile')
GROUP BY co.country);

/*Чтобы потренироваться, Алекс решил идентифицировать всех участников с фамилией MONROE и все фильмы с рейтингом PG. 
Для этого он написал два подзапроса, а затем содержащий их запрос использует 
эту информацию для извлечения всех случаев, когда актер с фамилией MONROE появляется в фильме с рейтингом PG — например, так:*/
SELECT fa.actor_id, fa.film_id 
FROM film_actor fa
WHERE fa.actor_id IN
(SELECT actor_id
FROM actor
WHERE last_name = 'MONROE')
AND fa.film_id IN 
(SELECT film_id FROM film
WHERE rating = 'PG');

/*Ты можешь предложить Алексу другое решение. Например, можно объединить два подзапроса с одним столбцом в один подзапрос с 
несколькими столбцами и сравнивать результаты с двумя столбцами таблицы film_actor. 
Не забудь указать в условии фильтрации два столбца из таблицы film_actor в круглых скобках и в том же порядке, что и в подзапросе:*/
SELECT fa.actor_id, fa.film_id
FROM film_actor fa
WHERE (fa.actor_id, fa.film_id) IN (
  SELECT a.actor_id, f.film_id
  FROM actor a
  CROSS JOIN film f
  WHERE a.last_name = 'MONROE' AND f.rating = 'PG'
);

/*Cоздай запрос к таблице film, который использует условие фильтрации с некоррелированным подзапросом к таблице category, чтобы найти все боевики (category.name = 'Action')*/
SELECT * FROM film
WHERE film_id IN (
    SELECT film_id FROM film_category
    WHERE category_id = (SELECT category_id FROM category WHERE name = 'Action')
);

/*Найди всех клиентов, которые никогда не получали фильмы напрокат бесплатно.*/
SELECT * FROM customer
WHERE customer_id NOT IN (
    SELECT customer_id FROM payment WHERE amount = 0
);

/*Найди всех актеров, которые снимались в фильмах с рейтингом PG.*/
SELECT first_name,last_name FROM actor
WHERE actor_id IN (
    SELECT actor_id FROM film_actor WHERE film_id IN (
    SELECT film_id FROM film WHERE rating = 'PG')
);

/*3.1*/
/*Алекс решил рассчитать количество прокатов фильмов для каждого клиента, а затем извлечь тех клиентов, которые взяли напрокат ровно 20 фильмов. Он написал запрос с кореллированным подзапросом:*/
SELECT c.first_name, c.last_name FROM customer c
WHERE 20 =
(SELECT count(*) FROM rental r
WHERE r.customer_id = c.customer_id);

/*Руководству компании понравился такой подход, и оно поставило задачу Алексу найти всех клиентов, чьи общие платежи за все прокаты фильмов составляют от 180 до 240 долларов:*/
SELECT c.first_name, c.last_name
FROM customer c
WHERE
(SELECT sum(p.amount) FROM payment p
WHERE p.customer_id = c.customer_id)
BETWEEN 180 AND 240;

/*Теперь Алексу нужно найти всех клиентов, которые взяли напрокат хотя бы один фильм до 25 мая 2005 года, без учета того, сколько фильмов всего было взято.
Для этого Алекс использовал оператор EXISTS. Оператор EXISTS применяется, когда нужно определить существование связи безотносительно к количеству.*/
SELECT c.first_name, c.last_name
FROM customer c
WHERE EXISTS
(SELECT 1 FROM rental r
WHERE r.customer_id = c.customer_id
AND date(r.rental_date) < '2005-05-25');

/*Поможем Алексу найти всех актеров, которые никогда не снимались в фильмах с рейтингом R:*/
SELECT a.first_name, a.last_name
FROM actor a
WHERE NOT EXISTS
(SELECT 1
FROM film_actor fa
INNER JOIN film f
ON f.film_id = fa.film_id
WHERE fa.actor_id = a.actor_id
AND f.rating = 'R');

/*Коррелированные подзапросы можно применять и в инструкциях UPDATE. Алекс использовал это при решении задачи обновления данных клиентов: 
нужно установить в поле последнего обновления last_update дату последнего проката.
Он написал инструкцию, которая изменяет каждую строку в таблице клиентов, находя дату последнего проката для каждого клиента в таблице rental, но она выдаёт ошибку:*/
UPDATE customer c
SET last_update =
(SELECT max(r.rental_date)
FROM rental r
WHERE r.customer_id = c.customer_id);
/*Причина в том, что нет следующего за подзапросом условия WHERE. Правильно было бы использовать два подзапроса с предложениями SELECT, причем настроить подзапрос в SET так, чтобы он выполнялся, 
только если условие в предложении WHERE инструкции UPDATE истинно (то есть если для клиента был найден хотя бы один прокат).*/

/*Это можно сделать, используя предыдущие примеры с EXISTS. Такой подход поможет защитить данные в столбце last_update от перезаписывания значением NULL.
Напиши такой запрос, в котором два коррелированных подзапроса:*/
UPDATE customer c
SET last_update =
(SELECT max(r.rental_date) FROM rental r
WHERE r.customer_id = c.customer_id)
WHERE EXISTS
(SELECT 1 FROM rental r
WHERE r.customer_id = c.customer_id);

/*Алекс решил немного упростить себе работу и запускать сценарий обслуживания базы данных в конце каждого месяца, который удаляет ненужные данные. 
Сценарий может включать инструкцию, которая будет удалять те строки из таблицы customer, 
для которых в прошлом году не было проката фильмов, используя инструкцию DELETE и коррелированные запросы.*/
DELETE FROM customer
WHERE 365 < ALL
(SELECT EXTRACT(DAY FROM (now() - r.rental_date)) AS days_since_last_rental
FROM rental r
WHERE r.customer_id = customer.customer_id);
/*Этот запрос должен либо вызвать ошибку (по причине того, что нарушает ограничение внешнего ключа), либо сработать, но ничего не удалить, 
потому что данные в таблице отвечают 2005 году, и удаление данных за 202Х год не повредит данным таблицы.*/

/*Подзапросы можно использовать как источники данных. Поскольку подзапрос генерирует результирующий набор, 
содержащий строки и столбцы данных, вполне допустимо включать подзапросы в предложение FROM вместе с таблицами.
Чтобы проверить эту возможность, Алекс решил создать запрос, в котором подзапрос генерирует 
список идентификаторов клиентов вместе с количеством прокатов фильмов и общими платежами:*/
SELECT c.first_name, c.last_name,  pymnt.num_rentals, pymnt.tot_payments
FROM customer c
INNER JOIN
(SELECT customer_id, count(*) num_rentals, sum(amount) tot_payments
FROM payment
GROUP BY customer_id
) pymnt
ON c.customer_id = pymnt.customer_id;
/*Результат получился не слишком удобным для восприятия. Поэтому руководство фирмы предложило сгруппировать клиентов по сумме денег,
потраченной на прокат фильмов, используя при этом определения групп, которых нет в базе данных:
Small Fry — от 0 до 74.99 долл.
Average Joes — от 75 до 149.99 долл.
Heavy Hitters — от 150 до 9 999 999.00 долл.*/

/*Сгенерируем определения групп:*/
SELECT 'Small Fry' name, 0 low_limit, 74.99 high_limit
UNION ALL
SELECT 'Average Joes' name, 75 low_limit, 149.99 high_limit
UNION ALL
SELECT 'Heavy Hitters' name, 150 low_limit, 9999999.99 high_limit

/*Теперь можем сгруппировать клиентов по сумме денег, потраченной на прокат фильмов, с учетом созданных подзапросом групп:*/
SELECT pymnt_grps.name, count(*) num_customers
FROM
(SELECT customer_id, count(*) num_rentals, sum(amount) tot_payments
FROM payment
GROUP BY customer_id
) pymnt
INNER JOIN
(SELECT 'Small Fry' name, 0 low_limit, 74.99 high_limit
UNION ALL
SELECT 'Average Joes' name, 75 low_limit, 149.99 high_limit
UNION ALL
SELECT 'Heavy Hitters' name, 150 low_limit, 9999999.99 high_limit
) pymnt_grps
ON pymnt.tot_payments
BETWEEN pymnt_grps.low_limit AND  pymnt_grps.high_limit
GROUP BY pymnt_grps.name;

/*Для региональных менеджеров компании потребовался отчёт, в котором будут указаны имя каждого клиента, а также его город, общее количество прокатов и общая сумма платежа.
Алекс решил задачу, соединив таблицы payment, customer, address и city, а затем сгруппировав их по имени и фамилии клиента:*/
SELECT ct.city, c.first_name, c.last_name, sum(p.amount) tot_payments, count(*) tot_rentals
FROM payment p
INNER JOIN customer c
ON p.customer_id = c.customer_id
INNER JOIN address a
ON c.address_id = a.address_id
INNER JOIN city ct
ON a.city_id = ct.city_id
GROUP BY c.first_name, c.last_name, ct.city
ORDER BY 1;

/*Этот запрос возвращает желаемые данные, но таблицы customer, address и city нужны только для отображения. Улучшим запрос Алекса, отделив в подзапрос задачу создания групп:*/
SELECT customer_id, count(*) tot_rentals,  sum(amount) tot_payments
FROM payment
GROUP BY customer_id;

/*А теперь присоединим остальные три таблицы:*/
SELECT ct.city, c.first_name, c.last_name, pymnt.tot_payments, pymnt.tot_rentals
FROM
(SELECT customer_id, count(*) tot_rentals, sum(amount) tot_payments
FROM payment
GROUP BY customer_id
) pymnt
INNER JOIN customer c
ON pymnt.customer_id = c.customer_id
INNER JOIN address a
ON c.address_id = a.address_id
INNER JOIN city ct
ON a.city_id = ct.city_id
ORDER BY 1;

/*Финансовый отдел попросил Алекса подготовить отчет, вычисляющий общий доход от проката тех фильмов с рейтингом PG, актерский состав которых включает актера с фамилией, начинающейся с S. 
В результате у Алекса получилось три обобщенных табличных выражения, причем второе ссылается на первое, а третье — на второе:*/
WITH actors_s AS (
  SELECT actor_id, first_name, last_name
  FROM actor
  WHERE last_name LIKE 'S%'
),
actors_s_pg AS (
  SELECT a.actor_id, a.first_name, a.last_name, f.film_id, f.title
  FROM actors_s a
  JOIN film_actor fa ON a.actor_id = fa.actor_id
  JOIN film f ON fa.film_id = f.film_id
  WHERE f.rating = 'PG'
),
actors_s_pg_revenue AS (
  SELECT a.actor_id, a.first_name, a.last_name, p.amount
  FROM actors_s_pg a
  JOIN inventory i ON a.film_id = i.film_id
  JOIN rental r ON i.inventory_id = r.inventory_id
  JOIN payment p ON r.rental_id = p.rental_id
)
SELECT first_name, last_name, SUM(amount) AS total_revenue
FROM actors_s_pg_revenue
GROUP BY first_name, last_name;

/*Попробуем написать новый запрос, действующий так же тот, что написал Алекс. Используем подзапрос в предложении FROM, но, 
вместо того чтобы соединять таблицы customer, address и city с данными о платежах, новый запрос должен использовать коррелированные скалярные подзапросы в предложении SELECT для поиска имен, фамилии и города клиента.
Обрати внимание на то, что к таблице customer должно быть три обращения (по одному в каждом из трех подзапросов), а не одно*/
SELECT
  (SELECT first_name FROM customer c WHERE c.customer_id = pymnt.customer_id) AS first_name,
  (SELECT last_name FROM customer c WHERE c.customer_id = pymnt.customer_id) AS last_name,
  (SELECT ct.city
   FROM customer c
   INNER JOIN address a ON c.address_id = a.address_id
   INNER JOIN city ct ON a.city_id = ct.city_id
   WHERE c.customer_id = pymnt.customer_id) AS city,
  pymnt.tot_payments,
  pymnt.tot_rentals
FROM
  (SELECT customer_id, count(*) tot_rentals, sum(amount) tot_payments
   FROM payment
   GROUP BY customer_id
  ) pymnt;

/*Скалярные подзапросы могут появляться и в предложении ORDER BY. Алекс решил написать запрос, извлекающий имена и 
фамилии актеров и сортирующий их по количеству фильмов, в которых снялся актер. При этом его запрос использует коррелированный скалярный подзапрос в
предложении ORDER BY только для возврата количества фильмов. Это значение применяется исключительно для сортировки.*/
SELECT a.actor_id, a.first_name, a.last_name
FROM actor a
ORDER BY
(SELECT count(*) FROM film_actor fa
WHERE fa.actor_id = a.actor_id) DESC;

/*Алексу необходимо создать новую строку в таблице film_actor со следующими данными:
Имя и фамилия актера
Название фильма
Для этого он создал два запроса, чтобы получить значения первичных ключей из таблиц film и actor, и поместил значения в инструкцию INSERT. 
Используем эти запросы для получения двух значений ключей в предложении VALUE как подзапросы*/
INSERT INTO film_actor (actor_id, film_id,   last_update)
VALUES (
(SELECT actor_id FROM actor
WHERE first_name = 'JENNIFER'
AND last_name = 'DAVIS'),
(SELECT film_id FROM film
WHERE title = 'ACE GOLDFINGER'),
now()
);

/*Создай запрос к таблице film, который использует условие фильтрации с коррелированным подзапросом к таблицам category и film_category для получения тех же результатов.*/
SELECT * FROM film f
WHERE EXISTS (
  SELECT 1 FROM film_category fc
  JOIN category c ON fc.category_id = c.category_id
  WHERE fc.film_id = f.film_id AND c.name = 'Action'
);

/*Рассчитай количество прокатов фильмов для каждого клиента, а затем извлеки тех клиентов, которые взяли напрокат ровно 20 фильмов.*/
SELECT customer_id, count(*) AS rental_count
FROM rental
GROUP BY customer_id
HAVING count(*) = 20;

/*Найди всех актеров, которые никогда не снимались в фильмах с рейтингом R.*/
SELECT * FROM actor
WHERE actor_id NOT IN (
  SELECT actor_id FROM film_actor
  JOIN film ON film_actor.film_id = film.film_id
  WHERE film.rating = 'R'
);

/*Создай запрос, в котором подзапрос генерирует список идентификаторов клиентов вместе с количеством прокатов фильмов и общими платежами.*/
SELECT customer_id, (
  SELECT count(*) FROM rental WHERE rental.customer_id = customer.customer_id
) AS rental_count, (
  SELECT sum(amount) FROM payment WHERE payment.customer_id = customer.customer_id
) AS total_payments
FROM customer;

/*Напиши запрос, вычисляющий общий доход от проката тех фильмов с рейтингом PG, актерский состав которых включает актера с фамилией, начинающейся с S.*/
SELECT sum(amount) AS total_revenue
FROM payment
WHERE rental_id IN (
  SELECT rental_id FROM rental
  WHERE inventory_id IN (
    SELECT inventory_id FROM inventory
    WHERE film_id IN (
      SELECT film_id FROM film
      WHERE rating = 'PG' AND film_id IN (
        SELECT film_id FROM film_actor
        WHERE actor_id IN (
          SELECT actor_id FROM actor WHERE last_name LIKE 'S%'
        )
      )
    )
  )
);

/*Напиши запрос, извлекающий имена и фамилии актеров и сортирующий их по количеству фильмов, в которых снялся актер.*/
SELECT first_name, last_name, (
  SELECT count(*) FROM film_actor WHERE actor.actor_id = film_actor.actor_id
) AS film_count
FROM actor
ORDER BY film_count DESC;



















