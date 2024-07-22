-- 2.2
-- Ниже — SQL-запрос создания таблицы film_actor с определенным набором полей:
CREATE TABLE film_actor (
    actor_id smallint NOT NULL,
    film_id smallint NOT NULL,
    last_update timestamp without time zone DEFAULT now() NOT NULL
);
-- Запрос добавления данных в ранее созданную таблицу:
INSERT INTO film_actor (actor_id,film_id,last_update)
VALUES ('1','1','2006-02-15 05:05:03.000');


-- 2.3
-- Запроси названия таблиц и их типов из базы данных Sakila следующим запросом и проанализируй их:
SELECT table_name, table_type
FROM information_schema.tables
WHERE table_schema = 'sakila'
ORDER BY 1;


-- 3.1
-- Создай таблицу customer_clone:
CREATE TABLE customer_clone (
    customer_id integer NOT NULL,
    first_name character varying(45) NOT NULL,
    last_name character varying(45) NOT NULL,
    email character varying(50),
    address_id smallint NOT NULL,
    active integer
);
-- 3.2
-- Измени таблицу customer_clone, добавь в неё столбец create_date:
ALTER TABLE customer_clone
ADD COLUMN create_date DATE;


-- Измени таблицу customer_clone, но на это раз удали столбец create_date:
ALTER TABLE customer_clone
DROP COLUMN create_date;


-- Добавь данные в customer_clone:
INSERT INTO customer_clone (customer_id, first_name, last_name, email, address_id, active)
VALUES (1, 'Susan','Smith', 'smith_s@outlook.com', '1', '1');

-- Проверь, добавились ли данные в таблицу:
SELECT *
FROM customer_clone;

-- Данные можно добавлять не по одной строке: если использовать несколько SQL-запросов, разделенных точкой с запятой, можно добавлять 2 и более записей:
INSERT INTO customer_clone (customer_id, first_name, last_name, email, address_id, active)
VALUES (2, 'William','Turner', 'turner_w@outlook.com', '2', '1');
INSERT INTO customer_clone (customer_id, first_name, last_name, email, address_id, active)
VALUES (3, 'Jorn','Turner', 'turner_j@outlook.com', '2', '1');

-- Проверь, добавились ли данные в таблицу:
SELECT *
FROM customer_clone;

-- Допустим, что в email Susan Smith закралась опечатка. Измени данные для неё, указав правильную почту – smith_susan@outlook.com:
UPDATE customer_clone
SET email = 'smith_susan@outlook.com'
WHERE customer_id = '1';

-- Проверь, обновились ли данные в таблице:
SELECT *
FROM customer_clone
ORDER BY customer_id ASC;

-- Удали данные о клиенте в таблице customer_clone, у которого customer_id равен 3:
DELETE FROM customer_clone
WHERE customer_id = 3;


-- Проверь, обновились ли данные в таблице customer_clone. Должно остаться 2 записи:
SELECT *
FROM customer_clone
ORDER BY customer_id;

-- А теперь очисти таблицу customer_clone полностью:
TRUNCATE customer_clone;

-- Проверь, удалились ли данные в таблице customer_clone. Таблица должна быть пуста:
SELECT *
FROM customer_clone;

-- Удали созданную таблицу customer_clone:
DROP TABLE customer_clone;

-- Необходимо создать таблицу.
CREATE TABLE customer_clone (
    customer_id integer NOT NULL,
    first_name character varying(45) NOT NULL,
    last_name character varying(45) NOT NULL,
    email character varying(50),
    address_id smallint NOT NULL,
    active integer
);


-- Необходимо заполнить данными таблицу.
INSERT INTO customer_clone (customer_id, first_name, last_name, email, address_id, active)
VALUES (1, 'Susan','Smith', 'smith_s@outlook.com', '1', '1');

-- Необходимо обновить данные в таблице.
UPDATE customer_clone
SET email = 'smith_susan@outlook.com'
WHERE customer_id = '1';
