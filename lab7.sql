/*2.1*/
/*Используя синтаксис поискового выражения CASE, теперь Алекс может решить интересную задачу: сделать классификацию фильмов в зависимости от их категории. 
Он написал запрос для получения строки, которую после можно использовать для классификации фильмов:*/
SELECT name,
    CASE
        WHEN name IN ('Children','Family','Sports','Animation')
            THEN 'All Ages'
        WHEN name = 'Horror'
            THEN 'Adult'
        WHEN name IN ('Music','Games')
            THEN 'Teens'
        ELSE 'Other'
    END category_type
FROM category;


/*Алекс подготовил запрос информации о клиенте с добавлением столбца active, в котором хранится 1 для обозначения активного и 0 — для обозначения неактивного клиента. Включим в этот запрос выражение 
CASE для генерации значения столбца activity_type, которое возвращает строку ACTIVE или INACTIVE в зависимости от значения столбца active:*/
SELECT
    c.first_name,
    c.last_name,
    c.active,
    CASE
        WHEN c.active = 1 THEN 'ACTIVE'
        ELSE 'INACTIVE'
    END AS activity_type
FROM customer c;

/*Алекс полагает, что было бы полезно расширить предыдущий запрос добавлением столбца num_rentals, 
который содержит информацию о количестве прокатов — но только для активных клиентов. Для неактивных нужно поставить значение «0»:*/
SELECT
    c.first_name,
    c.last_name,
    CASE
        WHEN c.active = 1 THEN 'ACTIVE'
        ELSE 'INACTIVE'
    END AS activity_type,
    CASE
        WHEN c.active = 1 THEN
            (SELECT count(*) FROM rental r WHERE r.customer_id = c.customer_id)
        ELSE '0'
    END AS num_rentals
FROM customer c;

/*Ранее Алекс подготовил для них запрос, который показывает количество прокатов фильмов в мае, июне и июле 2005 года, но выводит три строки и не очень легко читается:*/
SELECT DATE_TRUNC('month', rental_date) rental_month,
count(*) num_rentals
FROM rental
WHERE rental_date BETWEEN '2005-05-01' AND '2005-08-01'
GROUP BY rental_month
ORDER BY rental_month;

/*Алекс решил преобразовать результирующий набор этого запроса так, чтобы запрос возвращал одну строку данных с тремя столбцами (по одному для каждого из трех месяцев). 
Чтобы преобразовать этот результирующий набор в единую строку, нужно создать три столбца и в каждом столбце суммировать только те строки, которые относятся к рассматриваемому месяцу:*/
SELECT
    SUM(CASE WHEN DATE_TRUNC('month', rental_date) = '2005-05-01' THEN 1 ELSE 0 END) AS may_rentals,
    SUM(CASE WHEN DATE_TRUNC('month', rental_date) = '2005-06-01' THEN 1 ELSE 0 END) AS june_rentals,
    SUM(CASE WHEN DATE_TRUNC('month', rental_date) = '2005-07-01' THEN 1 ELSE 0 END) AS july_rentals
FROM rental
WHERE rental_date >= '2005-05-01' AND rental_date < '2005-08-01';

/*Как раз Алексу прилетела задача, где можно использовать эту проверку: нужно найти актёров, которые снялись хотя бы в одном фильме с рейтингом G, без учета фактического количества фильмов.
Алекс использовал конструкцию CASE WHEN EXISTS для проверки на существование таких актеров:*/
SELECT
    a.first_name,
    a.last_name,
    CASE WHEN EXISTS (
        SELECT 1
        FROM film f
        JOIN film_actor fa ON f.film_id = fa.film_id
        WHERE fa.actor_id = a.actor_id AND f.rating = 'G'
    ) THEN 'Yes' ELSE 'No' END AS acted_in_g_rated_film
FROM actor a;

/*Менеджерам продаж очень понравился отчет, который подготовил Алекс для них в прошлый раз. Теперь у них новая идея. 
Они хотят подсчитать количество копий в прокате для каждого фильма, возвращая строки 'Out Of Stock', 'Scarce', 'Available' или 'Common':*/
SELECT
    f.title,
    CASE
        WHEN COUNT(i.inventory_id) = 0 THEN 'Out Of Stock'
        WHEN COUNT(i.inventory_id) BETWEEN 1 AND 2 THEN 'Scarce'
        WHEN COUNT(i.inventory_id) BETWEEN 3 AND 5 THEN 'Available'
        ELSE 'Common'
    END AS availability
FROM film f
LEFT JOIN inventory i ON f.film_id = i.film_id
GROUP BY f.title;

/*Теперь руководство хочет видеть среднюю сумму платежа для каждого клиента. Следует помнить, что некоторые клиенты могут
быть новыми и еще не брали напрокат ни одного фильма, поэтому лучше включить выражение CASE, чтобы знаменатель никогда не был равен нулю:*/
SELECT
    c.first_name,
    c.last_name,
    CASE
        WHEN count(p.amount) = 0 THEN 0
        ELSE round(avg(p.amount), 1)
    END AS average_payment
FROM customer c
LEFT JOIN payment p ON c.customer_id = p.customer_id
GROUP BY c.first_name, c.last_name
ORDER BY 3;

/*Алексу стало любопытно посмотреть, был ли активен клиент в определенный период. Он написал запрос, который выводит столбец active 
и устанавливает его равным 'INACTIVE' для тех клиентов, которые ни разу не брали фильм напрокат за период с '2005-05-01' по '2005-08-01'. 
И устанавливает столбец active равным 'ACTIVE' для тех клиентов, которые брали хотя бы один фильм напрокат за этот период:*/
SELECT
    c.first_name,
    c.last_name,
CASE
    WHEN EXISTS (
        SELECT *
        FROM rental r
        WHERE r.customer_id = c.customer_id
        AND r.rental_date BETWEEN '2005-05-01' AND '2005-06-01'
    ) THEN 'ACTIVE'
    ELSE 'INACTIVE'
END AS active
FROM customer c;

/*В оператор WHEN можно добавлять и логические операторы. Алекс решил предложить менеджерам по продажам отчет, 
в котором они смогут увидеть, сколько клиенты потратили на прокат фильмов каждый раз, когда обращались в компанию:*/
SELECT
    c.last_name,
    c.first_name,
    p.amount,
    p.payment_date,
    CASE
        WHEN p.amount >= 0 AND p.amount <= 5 THEN 'low'
        WHEN p.amount > 5 AND p.amount <= 10 THEN 'medium'
        WHEN p.amount > 10 THEN 'high'
    END AS spending_category
FROM payment p
JOIN customer c ON p.customer_id = c.customer_id;

/*Перепиши следующий запрос, в котором используется простое выражение CASE, так, чтобы получить те же результаты с использованием поискового выражения CASE. 
Старайся, насколько это возможно, использовать меньше предложений WHEN.*/
SELECT name,
CASE name
WHEN 'English' THEN 'latin1'
WHEN 'Italian' THEN 'latin1'
WHEN 'French' THEN 'latin1'
WHEN 'German' THEN 'latin1'
WHEN 'Japanese' THEN 'utf8'
WHEN 'Mandarin' THEN 'utf8'
ELSE 'Unknown'
END AS character_set
FROM language;

SELECT name,
CASE
WHEN name IN ('English', 'Italian', 'French', 'German') THEN 'latin1'
WHEN name IN ('Japanese', 'Mandarin') THEN 'utf8'
ELSE 'Unknown'
END AS character_set
FROM language;

/*Перепиши следующий запрос так, чтобы результирующий набор содержал одну строку с пятью столбцами (по одному для каждого рейтинга). Назови эти пять столбцов G, PG, PG_13, R и NC_17.*/
SELECT rating, count(*)
FROM film
GROUP BY rating;

SELECT
  count(CASE WHEN rating = 'G' THEN 1 END) AS G,
  count(CASE WHEN rating = 'PG' THEN 1 END) AS PG,
  count(CASE WHEN rating = 'PG-13' THEN 1 END) AS PG_13,
  count(CASE WHEN rating = 'R' THEN 1 END) AS R,
  count(CASE WHEN rating = 'NC-17' THEN 1 END) AS NC_17
FROM film;

/*2.2*/
/*Алекс захотел проверить, как работают циклы, и написал небольшой запрос, в котором считает количество фильмов в таблице film.
Цикл получился бесконечным, поэтому Алекс добавил EXIT, который прекращает цикл, когда количество фильмов превышает 100:*/
DO $$
DECLARE
    film_count INT := 0;
BEGIN
    LISTEN bootcamp;
    LOOP
        SELECT count(*) INTO film_count FROM film;
        -- Печатаем текущее количество фильмов
        PERFORM pg_notify('bootcamp', 'Current film count: ' || film_count);
        EXIT WHEN film_count > 100; 
        -- Некоторая операция, например, ожидание
        PERFORM pg_sleep(1);
    END LOOP;
END $$;

/*Алекс для проверки написал запрос, который перебирает все записи в таблице actor. 
Если actor_id меньше 10, он пропускает обработку этой записи. Цикл завершается, когда количество обработанных записей превышает 20:*/
DO $$
DECLARE
    actor_record RECORD;
    actor_count INT := 0;
BEGIN
    LISTEN bootcamp;
    FOR actor_record IN SELECT * FROM actor LOOP
        actor_count := actor_count + 1;
        CONTINUE WHEN actor_record.actor_id < 10;
        -- Некоторая операция с актером
        PERFORM pg_notify('bootcamp', 'Processing actor: ' || actor_record.actor_id);
        EXIT WHEN actor_count > 20; -- Замени 20 на нужное значение
    END LOOP;
END $$;

/*Алекс решил провести эксперимент с WHILE и написал запрос, который считает максимальное количество фильмов, взятых напрокат за один день, в течение месяца в 2005 году:*/
DO $$
    DECLARE
        max_rentals INTEGER := 0;
        current_day DATE := '2005-01-01';
        rentals_per_month INTEGER;
    BEGIN
        LISTEN bootcamp;
        WHILE current_day <= '2005-12-31' LOOP
            SELECT count(*) INTO rentals_per_month
            FROM rental
            WHERE rental_date >= current_day
            AND rental_date < current_day + INTERVAL '1 day';
            IF rentals_per_month > max_rentals THEN
                max_rentals := rentals_per_month;
            END IF;
            current_day := current_day + INTERVAL '1 day';
        END LOOP;
        PERFORM pg_notify('bootcamp', 'Maximum rentals per day: ' || max_rentals);
    END
$$;

/*Алекс решил посмотреть, как работает этот вариант цикла на категориях фильмов. Он написал запрос, в котором цикл FOR проходит по 10 первым значениям категорий фильмов и выводит их номер и название:*/
DO $$
DECLARE
    category_number INTEGER;
    category_name TEXT;
BEGIN
    LISTEN bootcamp;
    FOR i IN 1..10 LOOP
        SELECT category_id, name INTO category_number, category_name
        FROM category
        WHERE category_id = i;
        IF FOUND THEN
            PERFORM pg_notify('bootcamp', 'Found category: ' || category_number || ' - ' || category_name);
        ELSE
            PERFORM pg_notify('bootcamp', 'No category found with ID ' || i);
        END IF;
    END LOOP;
END $$;

/*И после использовал вариант с REVERSE для обратного порядка выдачи информации:*/
DO $$
DECLARE
    category_number INTEGER;
    category_name TEXT;
BEGIN
    LISTEN bootcamp;
    FOR i IN REVERSE 10..1 LOOP
        SELECT category_id, name INTO category_number, category_name
        FROM category
        WHERE category_id = i;
        IF FOUND THEN
            PERFORM pg_notify('bootcamp', 'Found category: ' || category_number || ' - ' || category_name);
        ELSE
            PERFORM pg_notify('bootcamp', 'No category found with ID ' || i);
        END IF;
    END LOOP;
END $$;

/*Алекс придумал запрос для поиска номеров категорий фильмов внутри цикла FOR:*/
DO $$
DECLARE
    category_number INTEGER;
BEGIN
    LISTEN bootcamp;
    FOR category_number IN (SELECT category_id FROM category WHERE category_id BETWEEN 1 AND 10) LOOP
        PERFORM pg_notify('bootcamp', 'Found category_id: ' || category_number);
    END LOOP;
END $$;

/*Алекс исправил предыдущий запрос так, чтобы использовать EXECUTE:*/
DO $$
DECLARE
    category_number INTEGER;
BEGIN
    LISTEN bootcamp;
    FOR category_number IN EXECUTE 'SELECT category_id FROM category WHERE category_id BETWEEN 1 AND 10' LOOP
        PERFORM pg_notify('bootcamp', 'Found category_id: ' || category_number);
    END LOOP;
END $$;

/*Алекс переписал предыдущий запрос так, чтобы находить определенные категории фильмов и выводить соответствующие сообщения:*/
DO $$
DECLARE
    category_number INTEGER;
    category_names TEXT[] := ARRAY['Action', 'Comedy', 'Drama', 'Horror'];
    category_name TEXT;
    cat_name TEXT;
BEGIN
    LISTEN bootcamp;
    FOREACH category_name IN ARRAY category_names LOOP
        SELECT category_id, name INTO category_number, cat_name
        FROM category
        WHERE name = category_name;

        IF FOUND THEN
            PERFORM pg_notify('bootcamp', 'Found category: ' || category_number || ' - ' || cat_name);
        ELSE
            PERFORM pg_notify('bootcamp', 'No category found with name ' || category_name);
        END IF;
    END LOOP;
END $$;

/*Напиши запрос при помощи цикла WHILE, который считает максимальное количество среди взятых напрокат фильмов за 1 день в 2006 году.*/
DO $$
    DECLARE
        max_rentals INTEGER := 0;
        current_day DATE := '2006-01-01';
        rentals_per_month INTEGER;
    BEGIN
        WHILE current_day <= '2006-12-31' LOOP
            SELECT count(*) INTO rentals_per_month
            FROM rental
            WHERE rental_date >= current_day
            AND rental_date < current_day + INTERVAL '1 day';
            IF rentals_per_month > max_rentals THEN
                max_rentals := rentals_per_month;
            END IF;
            current_day := current_day + INTERVAL '1 day';
        END LOOP;    

        PERFORM pg_notify('bootcamp', 'Maximum rentals per day: ' || max_rentals);
    END
$$;

/*Напиши запрос, который проходит по 10 первым значениям категорий фильмов и выводит их номер и название.*/
DO $$
DECLARE
    category_number INTEGER;
    category_name TEXT;
BEGIN
    FOR i IN 1..10 LOOP
        SELECT category_id, name INTO category_number, category_name
        FROM category
        WHERE category_id = i;
        IF FOUND THEN
            PERFORM pg_notify('bootcamp', 'Found category: ' || category_number || ' - ' || category_name);
        ELSE
            PERFORM pg_notify('bootcamp', 'No category found with ID: ' || i);
        END IF;
    END LOOP;
END $$;

/*3.1*/
/*Создать индекс для столбца email таблицы customer можно с помощью следующей инструкции:*/
CREATE INDEX idx_email ON customer (email);

/*Чтобы удалить индекс, достаточно знать его имя:*/
DROP INDEX idx_email;

/*Алекс решил удалить созданный ранее обычный индекс, как было описано выше, и добавить уникальный 
индекс для столбца email таблицы customer: адреса электронной почты клиентов действительно не должны дублироваться:*/
CREATE UNIQUE INDEX idx_email ON customer (email);

/*Алекс принял решение добавить многостолбцовый индекс для столбцов last_name и first_name таблицы customer:*/
CREATE INDEX idx_full_name ON customer (last_name, first_name);

/*Алекс решил добавить битовый индекс таблицы клиентов customer для столбца их активности active:*/
CREATE EXTENSION IF NOT EXISTS btree_gin;

CREATE INDEX idx_customer_active ON customer USING gin (active);

SELECT * FROM customer WHERE active = 0;

/*Алекс решил проверить результаты своей работы с индексами:*/
EXPLAIN
SELECT * FROM customer WHERE active = 0;

/*Однако лучшая проверка — это сокращение времени работы запросов. Поэтому Алекс, для чистоты эксперимента, 
сначала удалил индексы из таблицы customer (удали их и у себя) и написал запрос поиска клиентов, фамилия которых начинается на P, а имя — на S:*/
SELECT customer_id, first_name, last_name
FROM customer
WHERE first_name LIKE 'S%' AND last_name LIKE 'P%';

/*Далее Алекс добавил индекс столбца last_name, чтобы найти всех клиентов, чьи фамилии начинается с Р; 
затем посетить каждую строку таблицы клиентов, чтобы найти только те строки, имя в которых начинается с S.*/
CREATE INDEX idx_last_name ON customer (last_name);

/*Алекс решил проверить: что если сделать то же самое, но только для индекса имени, предварительно удалив индекс для фамилии:*/
DROP INDEX idx_last_name;

CREATE INDEX idx_first_name ON customer (last_name);

/*Для последнего эксперимента Алекс добавил многостолбцовый индекс для столбцов last_name и first_name, предварительно удалив индекс для имени:*/
DROP INDEX idx_first_name;
DROP INDEX idx_full_name; --удаляем индексы, созданные ранее

CREATE INDEX idx_full_name ON customer (last_name, first_name);

/*Чтобы самому не испортить данные, Алекс решил сперва потренироваться. Он создал новую таблицу для тестирования ограничений:*/
CREATE TABLE customer_new (
    customer_id SMALLSERIAL PRIMARY KEY,
    store_id SMALLINT NOT NULL,
    first_name VARCHAR(45) NOT NULL,
    last_name VARCHAR(45) NOT NULL,
    email VARCHAR(50) DEFAULT NULL,
    address_id SMALLINT NOT NULL,
    active BOOLEAN NOT NULL DEFAULT TRUE,
    create_date TIMESTAMP NOT NULL,
    last_update TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_customer_address FOREIGN KEY (address_id)
        REFERENCES address (address_id)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_customer_store FOREIGN KEY (store_id)
        REFERENCES store (store_id)
        ON DELETE RESTRICT ON UPDATE CASCADE
);

CREATE INDEX idx_fk_store_new_id ON customer_new (store_id);
CREATE INDEX idx_fk_address_new_id ON customer_new (address_id);
CREATE INDEX idx_last_name_new ON customer_new (last_name);

/*Алекс решил в первую очередь добавить ограничения на удаление и разрешение обновления:*/
ALTER TABLE customer_new
ADD CONSTRAINT fk_customer_address_new FOREIGN KEY (address_id)
    REFERENCES address (address_id)
    ON DELETE RESTRICT ON UPDATE CASCADE;

ALTER TABLE customer_new
ADD CONSTRAINT fk_customer_store_new FOREIGN KEY (store_id)
    REFERENCES store (store_id)
    ON DELETE RESTRICT ON UPDATE CASCADE;

/*Для проверки он предложил стажеру удалить строку в таблице address в нарушение внешнего ключа:*/
SELECT c.first_name, c.last_name, c.address_id, a.address
FROM customer c
INNER JOIN address a
    ON c.address_id = a.address_id
WHERE a.address_id = 123;
DELETE FROM address WHERE address_id = 123;

/*Стажер удивился, потому что удаление не сработало, и Алекс пояснил ему причину.
После чего предложил ему обновить значение в таблице address в нарушение внешнего ключа:*/
UPDATE address
SET address_id = 9999
WHERE address_id = 123;

SELECT c.first_name, c.last_name, c.address_id, a.address
FROM customer c
INNER JOIN address a
    ON c.address_id = a.address_id
WHERE a.address_id = 9999;

/*Добавь уникальный индекс для столбца email таблицы customer.*/
CREATE UNIQUE INDEX idx_customer_email ON customer (email);

/*Создай таблицу и добавь ограничение на обновление для адреса и магазина: при удалении нужно автоматически удалить связанные строки из зависимой таблицы;
при попытке обновления нужно сгенерировать ошибку и выполнить проверку на связанность между таблицами.*/
CREATE TABLE customer_new (
customer_id SMALLSERIAL PRIMARY KEY,
    store_id SMALLINT NOT NULL,
    first_name VARCHAR(45) NOT NULL,
    last_name VARCHAR(45) NOT NULL,
    email VARCHAR(50) DEFAULT NULL,
    address_id SMALLINT NOT NULL,
    active BOOLEAN NOT NULL DEFAULT TRUE,
    create_date TIMESTAMP NOT NULL,
    last_update TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_customer_address FOREIGN KEY (address_id)
        REFERENCES address (address_id)
        ON DELETE CASCADE ON UPDATE NO ACTION,
    CONSTRAINT fk_customer_store FOREIGN KEY (store_id)
        REFERENCES store (store_id)
        ON DELETE CASCADE ON UPDATE NO ACTION

/*Создай многостолбцовый индекс в таблице payment, который может использоваться обоими запросами:*/
SELECT customer_id, payment_date, amount
FROM payment
WHERE payment_date > cast('2005-12-31 23:59:59' as timestamp);

SELECT customer_id, payment_date, amount
FROM payment
WHERE payment_date > cast('2005-12-31 23:59:59' as timestamp)
AND amount < 5;

CREATE INDEX idx_payment_date_amount
ON payment (payment_date, amount);

/*Сгенерируй инструкцию ALTER TABLE для таблицы rental так, чтобы генерировалось сообщение об ошибке, когда строка со значением, имеющимся в столбце rent.customer_id, удаляется из таблицы customer.*/
ALTER TABLE rental
ADD CONSTRAINT fk_rental_customer
FOREIGN KEY (customer_id)
REFERENCES customer (customer_id)
ON DELETE RESTRICT;

/*3.2*/
/*Допустим, клиенты MARIA MILLER, SUSAN WILSON и NANCY THOMAS хотят одновременно взять фильм AMELIE HELLFIGHTERS. Этих фильмов в распоряжении всего 3, 
поэтому Алекс уверен, что его запрос разрешит провести эту операцию, так как фильмов достаточно:*/
DO $$
    DECLARE
        film_count INTEGER;
        rental_count INTEGER;
    BEGIN
        SELECT COUNT(inventory_id) INTO film_count
        FROM inventory
        WHERE film_id = (SELECT film_id FROM film WHERE title = 'AMELIE HELLFIGHTERS')
        GROUP BY film_id;
        SELECT COUNT(*) INTO rental_count
          FROM customer
          WHERE CONCAT(customer.first_name, ' ', customer.last_name) IN ('MARIA MILLER','SUSAN WILSON', 'NANCY THOMAS');

        IF film_count < rental_count THEN
            RAISE NOTICE 'Недостаточно фильмов для аренды';
        ELSE
            RAISE NOTICE 'Достаточно фильмов для аренды';
            INSERT INTO rental (rental_date, inventory_id, customer_id, return_date, staff_id)
            SELECT NOW(), inv.inventory_id, cust.customer_id, NULL, 1
            FROM (SELECT customer_id, row_number() over (order by 1) as rn FROM customer WHERE CONCAT(customer.first_name, ' ', customer.last_name) IN ('MARIA MILLER','SUSAN WILSON', 'NANCY THOMAS')) cust
            JOIN (SELECT inventory.inventory_id, row_number() over (order by 1) as rn, inventory.film_id FROM inventory INNER JOIN film ON inventory.film_id = film.film_id WHERE film.title = 'AMELIE HELLFIGHTERS') inv
            ON inv.rn = cust.rn;
        END IF;
    END
$$;

/*Допустим, теперь MARIA MILLER, SUSAN WILSON, LISA ANDERSON и NANCY THOMAS хотят взять фильм AMELIE HELLFIGHTERS, 
но, как вы помните, этих фильмов всего 3, а клиентов, которые хотят взять этот фильм — 4. 
Алекс составил запрос, который запрещает провести такую операцию, так как фильмов недостаточно:*/
DO $$
    DECLARE
        film_count INTEGER;
        rental_count INTEGER;
    BEGIN
        SELECT COUNT(inventory_id) INTO film_count
        FROM inventory
        WHERE film_id = (SELECT film_id FROM film WHERE title = 'AMELIE HELLFIGHTERS')
        GROUP BY film_id;
        SELECT COUNT(*) INTO rental_count
          FROM customer
          WHERE CONCAT(customer.first_name, ' ', customer.last_name) IN ('MARIA MILLER','SUSAN WILSON', 'LISA ANDERSON', 'NANCY THOMAS');

        IF film_count < rental_count THEN
            RAISE NOTICE 'Недостаточно фильмов для аренды';
        ELSE
            RAISE NOTICE 'Достаточно фильмов для аренды';
            INSERT INTO rental (rental_date, inventory_id, customer_id, return_date, staff_id)
            SELECT NOW(), inv.inventory_id, cust.customer_id, NULL, 1
            FROM (SELECT customer_id, row_number() over (order by 1) as rn FROM customer WHERE CONCAT(customer.first_name, ' ', customer.last_name) IN ('MARIA MILLER','SUSAN WILSON', 'LISA ANDERSON', 'NANCY THOMAS')) cust
            JOIN (SELECT inventory.inventory_id, row_number() over (order by 1) as rn, inventory.film_id FROM inventory INNER JOIN film ON inventory.film_id = film.film_id WHERE film.title = 'AMELIE HELLFIGHTERS') inv
            ON inv.rn = cust.rn;
        END IF;
    END
$$;

/*Создай две таблицы и заполни их данными:*/
CREATE TABLE account (
  account_id INT,
  avail_balance DECIMAL(10,2),
  last_activity_date TIMESTAMP
);

INSERT INTO account (account_id, avail_balance, last_activity_date)
VALUES
  (123, 500, '2019-07-10 20:53:27'),
  (789, 75, '2019-06-22 15:18:35');

CREATE TABLE transaction (
  txn_id INT,
  txn_date DATE,
  account_id INT,
  txn_type_cd CHAR(1),
  amount DECIMAL(10,2)
);

INSERT INTO transaction (txn_id, txn_date, account_id, txn_type_cd, amount)
VALUES
  (1001, '2019-05-15', 123, 'C', 500),
  (1002, '2019-06-01', 789, 'C', 75);

/*Создай логическую единицу работы для перевода 50 долларов со счета 123 на счет 789. 
Для этого вставь две строки в таблицу transaction и обнови две строки в таблице account. Используй txn_type_cd = ‘С’, 
чтобы указать операцию кредита (добавление на счет), и txn_type_cd = ‘D’ для обозначения дебета (снятия со счета).*/
BEGIN;
INSERT INTO transaction (txn_id, txn_date, account_id, txn_type_cd, amount)
VALUES
  (1003, CURRENT_DATE, 123, 'D', 50),
  (1004, CURRENT_DATE, 789, 'C', 50);

UPDATE account
SET avail_balance = avail_balance - 50,
    last_activity_date = CURRENT_TIMESTAMP
WHERE account_id = 123;


UPDATE account
SET avail_balance = avail_balance + 50,
    last_activity_date = CURRENT_TIMESTAMP
WHERE account_id = 789;
COMMIT;

/*Напиши запрос, который перечисляет все индексы в схеме Sakila. Не забудь включить в результаты имена таблиц.*/
SELECT
    t.relname AS table_name,
    i.relname AS index_name,
    a.attname AS column_name
FROM
    pg_class t,
    pg_class i,
    pg_index ix,
    pg_attribute a
WHERE
    t.oid = ix.indrelid
    AND i.oid = ix.indexrelid
    AND a.attrelid = t.oid
    AND a.attnum = ANY(ix.indkey)
    AND t.relkind = 'r'
    AND t.relname IN (
        SELECT table_name
        FROM information_schema.tables
        WHERE table_schema = 'public'
    )
ORDER BY
    t.relname,
    i.relname;

/*Напиши запрос, генерирующий вывод, который можно было бы использовать для создания всех индексов таблицы sakila.customer.*/
SELECT
    '  CREATE INDEX ' || index_name || ' ON ' || table_name || ' (' || array_to_string(array_agg(column_name), ', ') || ');'
FROM
    (
        SELECT
            t.relname AS table_name,
            i.relname AS index_name,
            a.attname AS column_name
        FROM
            pg_class t,
            pg_class i,
            pg_index ix,
            pg_attribute a
        WHERE
            t.oid = ix.indrelid
            AND i.oid = ix.indexrelid
            AND a.attrelid = t.oid
            AND a.attnum = ANY(ix.indkey)
            AND t.relkind = 'r'
            AND t.relname = 'customer'
    ) sub
GROUP BY
    table_name,
    index_name;






















