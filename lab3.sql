-- 2.1
-- Попробуй выполнить следующий запрос, чтобы изучить его результат:
SELECT с.email
FROM customer с
INNER JOIN rental r
ON с.customer_id = r.customer_id
WHERE date(r.rental_date) ='2005-06-14';

-- А теперь сравни этот результат с условием неравенства:
SELECT с.email
FROM customer с
INNER JOIN rental r
ON с.customer_id = r.customer_id
WHERE date(r.rental_date) <>'2005-06-14'
LIMIT 500;

-- Алекс написал такой запрос с условием равенства:
DELETE FROM rental
WHERE date_part('year', rental_date) = 2004;

-- Или, наоборот, можно составить запрос с условием неравенства, который удалит все года, не соответствующие 2005 и 2006-му:
DELETE FROM rental
WHERE date_part('year', rental_date) <> 2005 AND 
date_part('year', rental_date) <> 2006;


-- 2.2
-- Руководитель Алекса просит найти тех клиентов, которые брали напрокат фильмы между 14 и 25 мая 2005 года, достаточно знать только customer_id пользователей:
SELECT customer_id, rental_date
FROM rental
WHERE rental_date < '2005-05-25'
AND rental_date >= '2005-05-14';


-- Перепишем предыдущий запрос, который выбирает клиентов, бравших фильмы напрокат между 25 мая и 14 июня 2005 года, но теперь используем оператор BETWEEN:
SELECT customer_id, rental_date
FROM rental
WHERE rental_date BETWEEN '2005-05-25' AND '2005-06-14';


-- Обратимся за помощью к Алексу: нужно создать запрос, который возвращает клиентов, фамилии которых находятся между FA и FR:
SELECT last_name, first_name
FROM customer
WHERE last_name BETWEEN 'FA' AND 'FR';


-- Отдельно выделяют условия вхождения в определенную группу. Например, Алексу необходимо найти все фильмы с рейтингом G или PG. Он пишет такой запрос:
SELECT title, rating
FROM film
WHERE rating = 'G' OR rating = 'PG';


-- Перепиши предыдущий запрос, который находит все фильмы с рейтингом G, PG и добавим ещё рейтинг R:
SELECT title, rating
FROM film
WHERE rating IN ('G', 'PG', 'R');


-- Сколько идентификаторов платежей будет возвращено при следующих условиях фильтрации?
SELECT count(payment_id)
FROM payment
WHERE customer_id<>5
AND (amount > 8 OR date(payment_date) = '2005-08-23');
-- Ответ: 1419.


-- Сколько идентификаторов платежей будет возвращено при следующих условиях фильтрации?
SELECT count(payment_id)
FROM payment
WHERE customer_id = 5
AND NOT (amount > 6 OR date(payment_date) = '2005-06-19');
-- Ответ: 32.


-- Какой результат будет после исполнения этого запроса?
SELECT customer_id, rental_date
FROM rental
WHERE rental_date BETWEEN '2005-05-25' AND '2005-06-14';
-- Будут выбраны клиенты, которые брали фильмы между 25 мая и 14 июня 2005 года.


-- Нужно извлечь из таблицы payments все строки, в которых сумма равна 1,98, 7,98 или 9,98.
SELECT *
FROM payment
WHERE amount IN (1.98, 7.98, 9.98);


-- Какой результат будет после исполнения этого запроса?
SELECT title, rating
FROM film
WHERE rating IN ('G', 'PG', 'R');
-- Будут найдены все фильмы с рейтингом G, PG или R.


-- Нужно выбрать тех клиентов, которые брали напрокат фильмы между 25 мая и 14 июня 2005 года.
SELECT customer_id, rental_date
FROM rental
WHERE rental_date BETWEEN '2005-05-25' AND '2005-06-14';

-- 3.1
-- Алексу поступила более сложная задача: нужно найти клиентов, фамилии которых начинаются с буквы Q. Он написал такой запрос:
SELECT last_name, first_name
FROM customer
WHERE left(last_name, 1) = 'Q';

-- Конечно, такое условие мало похоже на реальный бизнес-запрос. Чаще всего оператор LIKE используется для
-- фильтрации сложных логов сервера для поиска в них, например, инцидентов за определенный день. Или действий определенного пользователя.
SELECT last_name, first_name
FROM customer
WHERE last_name LIKE 'A_T%S';

-- Оператор LIKE можно использовать с логическими операторами. Алексу необходимо решить задачу,
-- где это может пригодиться: нужно найти клиентов, фамилии которых начинаются на буквы Q и Y. У него получился такой запрос:
SELECT last_name, first_name
FROM customer
WHERE last_name LIKE 'Q%' OR last_name LIKE 'Y%';

-- Однако посмотри, как можно переписать предыдущий пример, используя регулярные выражения:
SELECT last_name, first_name
FROM customer
WHERE last_name ~ (substring(last_name, '^[QY]'));

-- Алекс полагает, что любой фильм, название которого включает строку ‘РЕТ’, будет безопасным для 
-- семейного просмотра, и хочет написать запрос, чтобы проверить эту гипотезу. Для этого надо узнать рейтинги фильмов, которые отвечают этому требованию: включают строку ‘РЕТ’.
SELECT rating
FROM film WHERE title LIKE '%PET%';

-- Он написал запрос, в котором использовал написанный выше запрос как подзапрос в условии вхождения:
SELECT title, rating
FROM film
WHERE rating IN (SELECT rating FROM film WHERE title LIKE '%PET%');

-- Отработаем эти знания на практике вместе с Алексом. Ему нужно выбрать всех клиентов и номера аренды фильмов из таблицы rental, 
-- у которых не определена или неизвестна (не применима) дата, когда они брали фильм напрокат.
-- Алекс написал такой запрос:
SELECT rental_id, customer_id
FROM rental
WHERE return_date IS NULL;

-- Какой результат будет после исполнения этого запроса?
SELECT last_name, first_name
FROM customer
WHERE last_name LIKE 'A%' OR last_name LIKE 'B%';
-- Выбирает клиентов, фамилии которых начинаются на буквы A и B.

-- Какой результат будет после исполнения этого запроса?
SELECT last_name, first_name
FROM customer
WHERE last_name ~ (substring(last_name, '^[AB]'));
-- Выбирает клиентов, фамилии которых начинаются на буквы A и B.

-- Нужно найти всех клиентов, в фамилиях которых содержится буква А во второй позиции и буква W — в любом месте после А.
SELECT last_name, first_name
FROM customer
WHERE last_name LIKE '_A%W%';


-- Нужно найти фильмы, название которых включает строку «KILL», и, скорее всего, будет не лучшим выбором для семейного просмотра. Найди все рейтинги, связанные с этими фильмами.
SELECT rating
FROM film
WHERE title LIKE '%KILL%';
