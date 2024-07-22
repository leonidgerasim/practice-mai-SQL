-- 2.1
-- Замени в примере ниже table1 на любое имя таблицы из твоей базы данных из лабораторной работы №1 и изучи данные в этой таблице, 
-- чтобы вместе с Алексом продвигаться дальше по изучению SQL:
SELECT *
FROM film_actor;

-- 3.1
-- Начнём отрабатывать навыки построения запросов. Напиши запрос, который отображает все столбцы и все строки таблицы language:
SELECT *
FROM language;

-- Если же необходимо выбрать не все столбцы, можно указать название только одного имени столбца. Напиши запрос, который отображает только столбец name:
SELECT name
FROM language;

-- Выполни запрос, который представлен ниже, и просмотри на результат. 
-- Подумай, почему он получился именно таким. Также обрати внимание, как используются математические функции и псевдонимы языка SQL.
SELECT language_id, 'COMMON' AS language_usage,
language_id * 3.1415927 AS lang_pi_value,
upper(name) AS language_name
FROM language;

-- Напиши запрос, который выбирает идентификаторы всех актеров, снимавшихся в фильмах:
SELECT actor_id
FROM film_actor
limit 500;

-- А теперь перепиши этот запрос с добавлением DISTINCT и сравни результат выполнения нового запроса с предыдущим:
SELECT DISTINCT actor_id
FROM film_actor;

-- Напиши запрос, представленный ниже, и посмотри, как он работает. Обрати внимание на предложение WHERE, которое детально рассмотрим чуть позже:
SELECT concat(cust.last_name, ', ', cust.first_name)
full_name
FROM
(SELECT first_name, last_name, email
FROM customer
WHERE first_name = 'JESSIE'
) cust;

-- Временные таблицы:
-- Выглядят так же, как и постоянные
-- Любые данные, добавленные во временную таблицу, в какой-то момент исчезают, потому что таблица как временный объект сразу удаляется при окончании работы с базой данных
CREATE TEMPORARY TABLE customer_j (
    c_id integer,
    f_name character varying(45),
    l_name character varying(45)
);

INSERT INTO customer_j (c_id, f_name, l_name)
SELECT customer_id, first_name, last_name
        FROM customer
        WHERE first_name ='JESSIE';


SELECT * FROM customer_j

-- Представления:
-- Представление — это запрос, который хранится в словаре данных. Он выглядит и действует как таблица, однако данных, связанных с представлением, нет
-- При выполнении запроса к представлению этот запрос объединяется с определением представления для создания окончательного запроса, который и будет выполнен
CREATE VIEW cust_vw AS
SELECT customer_id, first_name, last_name, active
FROM customer;
SELECT first_name, last_name
FROM cust_vw
WHERE active = 0;

-- Итак, у Алекса новая задача. Есть фильмы с рейтингом G, которые можно держать у себя не менее недели. Помогите Алексу написать запрос, который отобразит такие фильмы.
SELECT title
FROM film
WHERE rating = 'G' AND rental_duration >= 7;

-- Напиши запрос для поиска фильмов, имеющих рейтинг G и способных храниться не менее недели, ИЛИ фильмов с рейтингом PG-13, которые можно хранить не более 3 дней.
SELECT title, rating, rental_duration
FROM film
WHERE (rating = 'G' AND rental_duration >= 7)
OR (rating = 'PG-13' AND rental_duration < 4);

-- Напиши запрос, который выбирает значения actor_id из таблицы film_actor и группирует их:
SELECT actor_id
FROM film_actor
GROUP BY actor_id;

-- Поможем Алексу написать запрос, который находит всех клиентов, бравших напрокат 40 или более фильмов:
SELECT c.first_name, c.last_name, count(*) --функция count() считает количество взятых фильмов
FROM customer c
INNER JOIN rental r
ON c.customer_id = r.customer_id
GROUP BY c.first_name, c.last_name
HAVING count(*) >= 40;

-- У Алекса получился такой запрос. Функция date( ) используется, чтобы игнорировать компонент времени.
SELECT c.first_name, c.last_name,
date(r.rental_date) rental_time
FROM customer c
INNER JOIN rental r
ON c.customer_id = r.customer_id
WHERE date(r.rental_date) = '2005-06-14';

-- Теперь отсортируем полученный результат по фамилии клиентов в алфавитном порядке, чтобы было проще найти клиентов по фамилии:
SELECT c.first_name, c.last_name,
date(r.rental_date) rental_time
FROM customer c
INNER JOIN rental r
ON c.customer_id = r.customer_id
WHERE date(r.rental_date) = '2005-06-14'
ORDER BY c.last_name;

-- На этот случай Алекс добавил сортировку по второму полю — по имени:
SELECT c.first_name, c.last_name,
date(r.rental_date) rental_time
FROM customer c
INNER JOIN rental r
ON c.customer_id = r.customer_id
WHERE date(r.rental_date) = '2005-06-14'
ORDER BY c.last_name, c.first_name;

-- Алекс предлагает сменить порядок сортировки на обратный, для тренировки:
SELECT c.first_name, c.last_name,
date(r.rental_date) rental_time
FROM customer c
INNER JOIN rental r
ON c.customer_id = r.customer_id
WHERE date(r.rental_date) = '2005-06-14'
ORDER BY c.last_name DESC, c.first_name DESC;

-- Проверь, что будет, если сделать сортировку в обратном направлении только для фамилии:
SELECT c.first_name, c.last_name,
date(r.rental_date) rental_time
FROM customer c
INNER JOIN rental r
ON c.customer_id = r.customer_id
WHERE date(r.rental_date) = '2005-06-14'
ORDER BY c.last_name DESC, c.first_name;

-- Перепиши запрос, чтобы он сортировал результаты по 2-му столбцу, и проверь, каким будет этот столбец:
SELECT c.first_name, c.last_name,
date(r.rental_date) rental_time
FROM customer c
INNER JOIN rental r
ON c.customer_id = r.customer_id
WHERE date(r.rental_date) = '2005-06-14'
ORDER BY 2 DESC;

-- В задании был пример, представленный ниже. Какой результат ты получил? Как работает этот запрос и почему?
-- В пояснении отдельно опиши, что делают SELECT, FROM и WHERE.
SELECT concat(cust.last_name, ', ', cust.first_name)
full_name
FROM
(SELECT first_name, last_name, email
FROM customer
WHERE first_name = 'JESSIE'
) cust;
SELECT выводит данные в виде таблицы, в данном случае это один столбец с псевдонимом full_name, в каждой строке будет помещена строка созданная с помощью функции concat().
FROM показыывает откуда брать данные для вывода, в данном случае из таблицы созданной подзапросом. WHERE описывает условия при которых берутся даннные.



-- 3.2
-- Напиши запрос, который выбирает значения actor_id из таблицы film_actor и группирует их:
SELECT actor_id
FROM film_actor
GROUP BY actor_id;

-- Поможем Алексу написать запрос, который находит всех клиентов, бравших напрокат 40 или более фильмов:
SELECT c.first_name, c.last_name, count(*) --функция count() считает количество взятых фильмов
FROM customer c
INNER JOIN rental r
ON c.customer_id = r.customer_id
GROUP BY c.first_name, c.last_name
HAVING count(*) >= 40;

-- Нужно найти всех клиентов, бравших фильмы 14 июня 2005 года.
-- У Алекса получился такой запрос. Функция date( ) используется, чтобы игнорировать компонент времени.
SELECT c.first_name, c.last_name,
date(r.rental_date) rental_time
FROM customer c
INNER JOIN rental r
ON c.customer_id = r.customer_id
WHERE date(r.rental_date) = '2005-06-14';

-- Теперь отсортируем полученный результат по фамилии клиентов в алфавитном порядке, чтобы было проще найти клиентов по фамилии:
SELECT c.first_name, c.last_name,
date(r.rental_date) rental_time
FROM customer c
INNER JOIN rental r
ON c.customer_id = r.customer_id
WHERE date(r.rental_date) = '2005-06-14'
ORDER BY c.last_name;

-- А вдруг среди клиентов встретятся однофамильцы?
-- На этот случай Алекс добавил сортировку по второму полю — по имени:
SELECT c.first_name, c.last_name,
date(r.rental_date) rental_time
FROM customer c
INNER JOIN rental r
ON c.customer_id = r.customer_id
WHERE date(r.rental_date) = '2005-06-14'
ORDER BY c.last_name, c.first_name;

-- Алекс предлагает сменить порядок сортировки на обратный, для тренировки:
SELECT c.first_name, c.last_name,
date(r.rental_date) rental_time
FROM customer c
INNER JOIN rental r
ON c.customer_id = r.customer_id
WHERE date(r.rental_date) = '2005-06-14'
ORDER BY c.last_name DESC, c.first_name DESC;

-- Обрати внимание: вы сменили сортировку для каждого столбца на обратный. Проверь, что будет, если сделать сортировку в обратном направлении только для фамилии:
SELECT c.first_name, c.last_name,
date(r.rental_date) rental_time
FROM customer c
INNER JOIN rental r
ON c.customer_id = r.customer_id
WHERE date(r.rental_date) = '2005-06-14'
ORDER BY c.last_name DESC, c.first_name;

-- Перепиши запрос, чтобы он сортировал результаты по 2-му столбцу, и проверь, каким будет этот столбец:
SELECT c.first_name, c.last_name,
date(r.rental_date) rental_time
FROM customer c
INNER JOIN rental r
ON c.customer_id = r.customer_id
WHERE date(r.rental_date) = '2005-06-14'
ORDER BY 2 DESC;

-- Нужно получить идентификатор актера, а также имя и фамилию для всех актеров. Отсортируй вывод сначала по фамилии, а затем — по имени.
SELECT actor_id, first_name, last_name
FROM actor
ORDER BY last_name, first_name;

-- Нужно получить идентификатор, имя и фамилию для всех актеров, чьи фамилии — ' WILLIAMS ' или ' DAVIS ‘.
SELECT actor_id, first_name, last_name
FROM actor
WHERE last_name IN ('WILLIAMS', 'DAVIS');

-- Напиши запрос к таблице rental, который возвращает идентификаторы клиентов, бравших фильмы напрокат 5 июля 2005 года.
-- Выведи по одной строке для каждого уникального идентификатора клиента.
SELECT DISTINCT customer_id
FROM rental
WHERE DATE(rental_date) = '2005-07-05';

-- Заполни пропущенные места в следующем многотабличном запросе так, чтобы получить результат, показанный на картинке.
SELECT c.email, r.return_date
FROM customer c
INNER JOIN rental  r
ON c.customer_id = r.customer_id
WHERE (rental_date < '2005.12.31')
ORDER BY 1, 2;
