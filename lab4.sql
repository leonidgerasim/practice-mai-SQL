/*2.1*/
/*Алекс вспоминает, что во время выполнения курсовой работы ему попалась задача, в которой нужно было использовать соединение таблиц. 
Тогда он проходил практику в метеослужбе и работал с базой данных, которая содержала таблицу городов и таблицу погоды. Чтобы вернуть 
все погодные события вместе с координатами соответствующих городов, запрос к БД должен сравнить столбец city каждой строки таблицы 
weather со столбцом name всех строк таблицы cities и выбрать пары строк, для которых эти значения совпадают. Тогда он использовал такой запрос:*/
SELECT * 
    FROM weather 
        JOIN cities ON city = name;

/*Кроме того, название города San Francisco оказалось в двух столбцах. Это правильно и объясняется тем, что столбцы таблиц weather и cities были объединены.
Хотя на практике это нежелательно, поэтому лучше перечислять нужные столбцы явно:*/
SELECT city, temp_lo, temp_hi, prcp, date, location
    FROM weather JOIN cities ON city = name;

/*Такой же результат можно получить и без JOIN, используя только знания из предыдущих лабораторных работ:*/
SELECT *
    FROM weather, cities
    WHERE city = name;

/*Алексу было важно вернуть записи о погоде в городе Хейуорд. Для этого он подготовил запрос, 
который просканировал таблицу weather и для каждой ее строки нашел соответствующую строку в таблице cities. 
Если же такая строка не будет найдена, нужно, чтобы вместо значений столбцов из таблицы cities были подставлены «пустые значения». 
Запросы такого типа называются внешними соединениями. Соединения, которые Алекс использовал ранее, называются внутренними. Новый запрос выглядит так:*/
SELECT *
    FROM weather LEFT OUTER JOIN cities ON weather.city = cities.name;

/*Далее Алексу требовалось найти все записи погоды, в которых температура лежит в диапазоне температур других записей. Для этого ему пришлось замкнуть таблицу на себя. 
Это называется замкнутым соединением. Для этого он сравнил столбцы temp_lo и temp_hi каждой строки таблицы weather со столбцами temp_lo и temp_hi другого набора строк 
weather с помощью следующего запроса:*/
SELECT w1.city, w1.temp_lo AS low, w1.temp_hi AS high,
       w2.city, w2.temp_lo AS low, w2.temp_hi AS high
    FROM weather w1 JOIN weather w2 
        ON w1.temp_lo < w2.temp_lo AND w1.temp_hi > w2.temp_hi;

/*Здесь Алекс ввел новые обозначения таблицы weather: w1 и w2, чтобы можно было различить левую и правую стороны соединения. 
Подобные псевдонимы часто используются и в других запросах для сокращения:*/
SELECT *
    FROM weather w JOIN cities c ON w.city = c.name;

/*Алекс столкнулся с проблемой: он хочет сделать простой запрос в БД Sakila, чтобы в результате получить таблицу, в которой будут фамилия и имя клиентов и их адрес.*/
SELECT c.first_name, c.last_name, a.address
    FROM customer c JOIN address a ON c.address_id = a.address_id;

/*Перепиши запрос выше в следующем виде, указывая на то, что соединение внутреннее, и используя выражения INNER JOIN и USING:*/
SELECT c.first_name, c.last_name, a.address
    FROM customer c INNER JOIN address a
        USING (address_id);

/*Или используя предложение WHERE, однако это не самое лучшее решение, хотя возможное:*/
SELECT c.first_name, c.last_name, a.address 
    FROM customer c, address a
    WHERE c.address_id = a.address_id;

/*Чтобы показать город каждого клиента, необходимо перейти от таблицы customer к таблице address, используя столбец address_id, а затем — 
от таблицы address к таблице city с использованием столбца city_id:*/
SELECT c.first_name, c.last_name, ct.city
    FROM customer c
        INNER JOIN address a
            ON c.address_id = a.address_id 
        INNER JOIN city ct
            ON a.city_id = ct.city_id;

/*У Алекса снова проблема: он решил выбрать тех клиентов, которые живут в штате California, но не получил ничего. 
Для этого он использовал запрос с тремя таблицами, но добавил еще подзапрос в качестве таблицы для соединения:*/
SELECT c.first_name, c.last_name, addr.address, addr.city
    FROM customer c
    INNER JOIN
        (SELECT a.address_id, a.address, ct.city
            FROM address a
                INNER JOIN city ct
                ON a.city_id = ct.city_id
            WHERE a.district = 'California'
        ) addr
    ON c.address_id = addr.address_id;

/*Добавь несколько значений 'California' в таблицу, например, так:*/
UPDATE address
    SET district = 'California'
WHERE address_id IN (10, 20, 30, 40);

/*Добавь в первоначальный запрос поле c.address_id, чтобы удостовериться в том, что это действительно те записи, в которых ты сделал изменения:*/
SELECT c.first_name, c.last_name, c.address_id, addr.address, addr.city
    FROM customer c
    INNER JOIN
        (SELECT a.address_id, a.address, ct.city
            FROM address a
                INNER JOIN city ct
                ON a.city_id = ct.city_id
            WHERE a.district = 'California'
        ) addr
    ON c.address_id = addr.address_id;

/*Обрати внимание: в запросе Алекса использован подзапрос, который делает соединение на ту же таблицу address, и результат этого подзапроса мы используем в качестве addr:*/
SELECT a.address_id, a.address, ct.city
    FROM address a
        INNER JOIN city ct
        ON a.city_id = ct.city_id
    WHERE a.district = 'California';

/*Чтобы исправить запрос, нужно найти все строки в таблице films, у которых есть две строки в таблице film_actor, одна из которых связана с Cate McQueen, 
а другая — с Cuba Birch. Следовательно, требуется включить таблицы film_actor и actor дважды, каждый раз с иным псевдонимом, чтобы сервер знал, на что именно вы ссылаетесь в различных предложениях.*/
SELECT f.title
    FROM film f
        INNER JOIN film_actor fa1
        ON f.film_id = fa1.film_id
        INNER JOIN actor al
        ON fa1.actor_id = al.actor_id
        INNER JOIN film_actor fa2
        ON f.film_id = fa2.film_id
        INNER JOIN actor a2
        ON fa2.actor_id = a2.actor_id
    WHERE (al.first_name = 'CATE' AND al.last_name = 'MCQUEEN')
    AND (a2.first_name = 'CUBA' AND a2.last_name = 'BIRCH');

/*2.1 вопрос 1*/
SELECT c.first_name, c.last_name, a.address, ct.city
    FROM customer c
    INNER JOIN address a
    ON c.address_id = a.address_id
    INNER JOIN city ct
    ON a.city_id = ct.city_id
WHERE a.district='California';

/*Создай запрос, который возвращает все адреса в одном и том же городе. 
Тебе нужно соединить таблицу адресов саму с собой, и каждая строка должна включать два разных адреса.*/
SELECT a1.address, a2.address
FROM address a1
JOIN address a2 ON a1.city_id = a2.city_id AND a1.address_id <> a2.address_id;

/*2.2*/
/*Алекс написал запрос, который подсчитывает количество доступных копий каждого фильма с помощью соединения этих двух таблиц:*/
SELECT f.film_id, f.title, count(*) num_copies
    FROM film f
    INNER JOIN inventory i
    ON f.film_id = i.film_id
    GROUP BY f.film_id, f.title;

/*Для его задачи нужно, чтобы запрос возвращал все 1000 фильмов, независимо от того, имеются ли соответствующие строки в 
таблице inventory или нет. В этом случае можно использовать внешнее соединение, которое, по сути, делает условие соединения необязательным:*/
SELECT f.film_id, f.title, count(i.inventory_id) num_copies
    FROM film f
    LEFT OUTER JOIN inventory i
    ON f.film_id = i.film_id
GROUP BY f.film_id, f.title;

/*Алекс пришёл с новой задачей. Ему нужно получить информацию о фильмах с film_id между 13 и 15, 
их инвентарных номерах (если есть) и датах проката (если есть).
Если для фильма нет инвентарных единиц или записей о прокате, соответствующие столбцы (inventory_id и rental_date) должны содержать значения NULL.*/
SELECT f.film_id, f.title, i.inventory_id, r.rental_date
    FROM film f
    LEFT OUTER JOIN inventory i
    ON f.film_id = i.film_id
    LEFT OUTER JOIN rental r
    ON i.inventory_id = r.inventory_id
WHERE f.film_id BETWEEN 13 AND 15;

/*Алекс решает очередную задачу, но запутался. Ему нужно составить отчет по всем дням 2005 года с количеством фильмов, взятых напрокат.
Однако он уже выяснил, что не каждый день фильмы брали на прокат, 
и в целом важно не потерять информацию о днях года в будущем. При этом в базе данных нет таблицы, которая содержит по строке для каждого дня.*/
SELECT date_trunc('day', dd)::date AS date
FROM generate_series('2005-01-01'::timestamp, '2005-12-31'::timestamp, '1 day'::interval) dd;

/*Теперь, используя правое внешнее соединение и подзапрос, Алекс может получить отчет по дням с количеством фильмов, взятых напрокат:*/
SELECT days.date, count(r.rental_id) num_rentals
    FROM rental r
    RIGHT OUTER JOIN
    (SELECT date_trunc('day', dd)::date AS date
        FROM generate_series('2005-01-01'::timestamp, '2006-12-31'::timestamp, '1 
        day'::interval) dd) days
    ON days.date = date(r.rental_date)
    GROUP BY days.date
ORDER BY 1;

/*Алекс составил перекрестный запрос, который генерирует декартово произведение таблиц category и language, 
в результате чего должен получиться результирующий набор из 96 строк (16 строк category х 6 строк language):*/
SELECT c.name category_name, l.name language_name
FROM category c
CROSS JOIN language l;

/*Алексу нужно написать простой запрос, который выбирает и отображает имена клиентов и даты аренды из базы данных, 
объединяя таблицы customer и rental по общему столбцу customer_id. Таблица rental включает столбец с именем customer_id, 
который является внешним ключом к таблице customer, первичный ключ которой также имеет имя customer_id.*/
SELECT cust.first_name, cust.last_name, date(r.rental_date)
     FROM (SELECT customer_id, first_name, last_name
         FROM customer) cust
NATURAL JOIN rental r
LIMIT 500;

/*Выполни три запроса с разными видами соединений и сравни результаты их работы:*/
SELECT f.film_id, f.title, i.inventory_id
FROM film f
LEFT OUTER JOIN inventory I
ON f.film_id = i.film_id
WHERE f.film_id BETWEEN 13 AND 15;

SELECT f.film_id, f.title, i.inventory_id
FROM film f
INNER JOIN inventory i
ON f.film_id = i.film_id
WHERE f.film_id BETWEEN 13 AND 15;

SELECT f.film_id, f.title, i.inventory_id
FROM inventory i
RIGHT OUTER JOIN film f
ON f.film_id = i.film_id
WHERE f.film_id BETWEEN 13 AND 15;

/*Ответ: 11 10 11*/

/*Напиши запрос, который выводил бы названия всех фильмов, в которых играл актер с именем JOHN.*/
SELECT f.title
FROM film f
JOIN film_actor fa ON f.film_id = fa.film_id
JOIN actor a ON fa.actor_id = a.actor_id
WHERE a.first_name = 'JOHN';

/*Используя следующие определения таблиц и данные, напиши запрос, который возвращает имя каждого клиента вместе с его суммами платежей.
Включи в результирующий набор всех клиентов, даже если для клиента нет записей о платежах.*/
CREATE TABLE customer_new (
customer_id INT,
name VARCHAR(255)
);

INSERT INTO customer_new (customer_id, name)
VALUES
(1, 'John Smith'),
(2, 'Kathy Jones'),
(3, 'Greg Oliver');

CREATE TABLE payment_new (
payment_id INT,
customer_id INT,
amount DECIMAL(5,2)
);

INSERT INTO payment_new (payment_id, customer_id, amount)
VALUES
(101, 1, 8.99),
(102, 3, 4.99),
(103, 1, 7.99);

SELECT c.name, p.amount
FROM customer_new c
LEFT JOIN payment_new p ON c.customer_id = p.customer_id;

/*Составь отчет по дням с количеством фильмов, взятых напрокат за 2005 и 2006 годы.*/
SELECT days.date, count(r.rental_id) num_rentals
  FROM rental r
  RIGHT OUTER JOIN
  (SELECT date_trunc('day', dd)::date AS date
  FROM generate_series('2005-01-01'::timestamp, '2006-12-31'::timestamp, '1  day'::interval) dd) days
  ON days.date = date(r.rental_date)
  GROUP BY days.date
ORDER BY 1;

/*3.1*/
/*Алекс раздумывает над тем, что произойдет, если сгенерировать объединение таблицы клиентов и таблицы города:*/
SELECT *
FROM customer
UNION
SELECT *
FROM city;

/*Кажется, Алекс понял, в чём проблема. Тогда попробуем написать запрос, который объединит данные о клиентах и актёрах в один отчет:*/
SELECT 'CUST' typ, c.first_name, c.last_name
FROM customer c
UNION ALL
SELECT 'ACTR' typ, a.first_name, a.last_name
FROM actor a;

/*Следующий запрос выполняет задачу, но не очень хорошо: из пяти строк в результирующем наборе одна является дубликатом (Jennifer Davis):*/
SELECT c.first_name, c.last_name
FROM customer c
WHERE c.first_name LIKE 'J%' AND c.last_name LIKE 'D%'
UNION ALL
SELECT a.first_name, a.last_name
FROM actor a
WHERE a.first_name LIKE 'J%' AND a.last_name LIKE 'D%';

/*Алекс убрал дубликаты, используя оператор UNION. В этой версии запроса в конечный результат включены только четыре различных имени:*/
SELECT c.first_name, c.last_name
FROM customer c
WHERE c.first_name LIKE 'J%' AND c.last_name LIKE 'D%'
UNION
SELECT a.first_name, a.last_name
FROM actor a
WHERE a.first_name LIKE 'J%' AND a.last_name LIKE 'D%';

/*Перепиши предыдущий запрос, но вместо оператора UNION укажи оператор INTERSECT:*/
SELECT c.first_name, c.last_name
FROM customer c
WHERE c.first_name LIKE 'J%' AND c.last_name LIKE 'D%'
INTERSECT
SELECT a.first_name, a.last_name
FROM actor a
WHERE a.first_name LIKE 'J%' AND a.last_name LIKE 'D%';

/*Дело в том, что в первом запросе присутствует результат, который есть во втором запросе, 
и он единственный, поэтому в результате разности ты получишь в отчёте 0 строк. Проверь это, используя только первый запрос:*/
SELECT c.first_name, c.last_name
FROM customer c
WHERE c.first_name LIKE 'J%' AND c.last_name LIKE 'D%';

/*Поменяй первый и второй SELECT местами и получите три строки в отчете:*/
SELECT a.first_name, a.last_name
FROM actor a
WHERE a.first_name LIKE 'J%' AND a.last_name LIKE 'D%'
EXCEPT
SELECT c.first_name, c.last_name
FROM customer c
WHERE c.first_name LIKE 'J%' AND c.last_name LIKE 'D%';

/*Измени запрос так, чтобы второй SELECT был с условием, распространяющимся только на имена, и отсортируй полученный результат по фамилии и имени:*/
SELECT a.first_name fname , a.last_name lname
FROM actor a
WHERE a.first_name LIKE 'J%' AND a.last_name LIKE 'D%'
UNION ALL
SELECT c.first_name, c.last_name
FROM customer c
WHERE c.first_name LIKE 'J%'
ORDER BY lname, fname;

/*Напиши составной запрос, который находит имена и фамилии всех актеров и клиентов, чьи фамилии начинаются с буквы L. 
Отсортируй результаты по столбцу last_name.*/
SELECT first_name, last_name
FROM (
    SELECT first_name, last_name FROM actor
    UNION
    SELECT first_name, last_name FROM customer
) AS combined
WHERE last_name LIKE 'L%'
ORDER BY last_name;

/*Напиши запрос, который объединит данные (фамилия и имя) о клиентах и актерах с именем JOHN в один отчет.*/
SELECT first_name, last_name
FROM (
    SELECT first_name, last_name FROM actor WHERE first_name = 'JOHN'
    UNION ALL
    SELECT first_name, last_name FROM customer WHERE first_name = 'JOHN'
) AS combined;

/*Перепиши запрос из предыдущего вопроса так, чтобы найти только пересекающиеся значения.*/
SELECT first_name, last_name
FROM (
    SELECT first_name, last_name FROM actor WHERE first_name = 'JOHN'
    INTERSECT
    SELECT first_name, last_name FROM customer WHERE first_name = 'JOHN'

/*Перепиши запрос из вопроса 2 так, чтобы найти только те значения, которые уникальны.*/
SELECT first_name, last_name
FROM (
    SELECT first_name, last_name FROM actor WHERE first_name = 'JOHN'
    UNION
    SELECT first_name, last_name FROM customer WHERE first_name = 'JOHN'
) AS combined;

/*Соедини следующий запрос с подзапросом к таблице film_actor, чтобы показать уровень мастерства каждого актера:*/
SELECT 'Hollywood Star' level, 30 min_roles,
99999 max_roles
UNION ALL
SELECT 'Prolific Actor' level, 20 min_roles, 29 max_roles UNION ALL
SELECT 'Newcomer' level, 1 min roles, 19 max roles
/*Подзапрос к таблице film_actor должен подсчитывать количество строк для каждого актера с использованием group by actor_id, 
и результат подсчета должен сравниваться со столбцами min_roles/max_roles, чтобы определить, какой уровень мастерства имеет каждый актер.*/
SELECT
    a.actor_id,
    a.first_name,
    a.last_name,
    f.total_films,
    s.level
    FROM actor a
LEFT OUTER JOIN (
 SELECT actor_id, COUNT(film_id) AS total_films
    FROM film_actor
    GROUP BY actor_id) AS f
ON a.actor_id= f.actor_id
LEFT JOIN (
        SELECT 'Hollywood Star' level, 30 min_roles, 99999 max_roles
        UNION ALL
        SELECT 'Prolific Actor' level, 20 min_roles, 29 max_roles
        UNION ALL
        SELECT 'Newcomer' level, 1 min_roles, 19 min_roles) AS s
ON f.total_films >= s.min_roles AND f.total_films <= s.max_roles;

