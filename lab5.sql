/*2.1*/
/*Для своих экспериментов Алекс создал новую таблицу в БД:*/
CREATE TABLE string_tbl(
    char_fld CHAR(30),
    vchar_fld VARCHAR(30),
    text_fld TEXT
);

/*Добавил немного данных в эту таблицу:*/
INSERT INTO string_tbl (char_fld, vchar_fld, text_fld)
VALUES ('This is char data', 'This is varchar data', 'This is text data');

/*И далее решил обновить данные:*/
UPDATE string_tbl
SET text_fld = 'This string doesn''t work'
WHERE text_fld = 'This is text data';

/*Можно использовать функцию quote_literal(), которая добавляет необходимые кавычки в текст:*/
SELECT quote_literal(text_fld)
FROM string_tbl;

/*Эта функция добавляет не только кавычки, она также дублирует обратную косую черту — \. Посмотри на пример:*/
UPDATE string_tbl
SET text_fld = 'This string doesn\t work'
WHERE text_fld = 'This string doesn''t work';

SELECT quote_literal(text_fld)
FROM string_tbl;

/*Ниже показан пример использования данной функции:*/
SELECT CHR(65) AS character_1, CHR(66) AS character_2;

/*Алекс вспомнил про функцию CONCAT(), которая нам уже встречалась. 
Она используется для соединения отдельных строк. Например, можно соединить фамилии и имена актеров:*/
SELECT concat(last_name,' ',first_name)
FROM actor;

/*Так же можно добавлять текст в какие-то существующие записи ячеек:*/
TRUNCATE string_tbl;

INSERT INTO string_tbl(text_fld)
VALUES ('This string was 29 characters');

UPDATE string_tbl
SET text_fld = concat(text_fld, ', but now it is longer')
WHERE text_fld = 'This string was 29 characters';

/*Функция overlay() возвращает новую строку, в которой указанная подстрока заменяет или перекрывает существующую подстроку. В общем виде она записывается так:*/
overlay(string placing overlay_string from 8 for 5)

/*Функция replace() заменяет каждый экземпляр искомой подстроки заменяемой строкой. В общем виде функция replace() записывается следующим образом:*/
REPLACE(str,from_str,to_str)

/*Посмотри на результат работы запроса, который возвращает символы строки 
'Please find the substring in this string' с 17-го по 25-й (третий аргумент — 9 — это длина подстроки):*/
SELECT substring('Please find the substring in this string', 17, 9);

/*У Алекса новая идея: он хочет узнать длину строк, которые есть в его экспериментальной таблице. 
Для этого он использует функцию LENGTH() — она возвращает количество символов в строке:*/
TRUNCATE string_tbl;

INSERT INTO string_tbl (char_fld, vchar_fld, text_fld)
VALUES ('This string is 28 characters', 'This string is 29 characters!', 'Are there 39 characters in this string?');

SELECT length(char_fld) char_length, length(vchar_fld) varchar_length, length(text_fld) text_length
FROM string_tbl;

/*Если тебе потребуется найти местоположение подстроки в строке, в этом поможет функция POSITION(). Она определяет местоположение подстроки внутри строки.
Следующий запрос будет искать местоположение подстроки 'characters' в ячейках таблицы string_tbl:*/
SELECT position('characters' IN char_fld), position('characters' IN vchar_fld), position('characters' IN text_fld)
FROM string_tbl;

/*Посмотри на следующие запросы:*/
SELECT name, name LIKE '%y' ends_in_y
FROM category;

SELECT name, name ~ 'y$' ends_in_y
FROM category;
/*Оба запроса сработают аналогично: они возвращают TRUE, если имя заканчивается буквой ‘у’, или FALSE — в противном случае.*/

/*Удалите таблицу string_tbl, она была временной и больше не потребуется:*/
DROP TABLE string_tbl;

/*Запусти примеры использования этих функций и проанализируй результаты:*/
SELECT (37 * 59) / (78 - (8 * 6));

SELECT sqrt(POW(2,8));

SELECT POW(2,10) kilobyte, POW(2,20) megabyte, POW(2,30);

SELECT MOD(10,4);

SELECT MOD(22.75, 5);

SELECT sin(1), cos(1);

SELECT ln(exp(5)), log(POW(10,2)), log(2,8);

SELECT abs(-10);

SELECT  PI();

SELECT  CEIL(4.6), FLOOR(4.6);

SELECT ROUND(72.499), ROUND(72.500), ROUND(72.501, 2), ROUND(72.501, 3);

SELECT SIGN(-1), SIGN(1);

/*С помощью функции CAST() можно преобразовать строку в другой тип: например, текстовый формат в тип данных для хранения даты и времени с помощью TIMESTAMP:*/
SELECT CAST('2019-09-17 15:30:00' AS TIMESTAMP);

/*С помощью функции CAST() также можно преобразовать строковые данные в тип данных для отдельного хранения даты и времени с помощью DATE и TIME:*/
SELECT CAST('2019-09-17' AS DATE) date_field,
       CAST('18:17:57' AS TIME) time_field;

/*Функция CAST() также может преобразовать TIMESTAMP, оставив только дату. Это понадобилось Алексу, когда он готовил отчет о том, 
с какой даты конкретные люди стали клиентами, используя функцию concat() для соединения строк:*/
SELECT concat(first_name, ' ', last_name, ' has been a customer since ', cast(create_date AS DATE)) cust_narrative
FROM customer;

/*При преобразовании строки в число функция CAST() пытается преобразовать всю строку слева направо; если в строке обнаруживается знак, которого не может быть в числе, 
преобразование останавливается с сообщением об ошибке. Сравни результаты работы двух запросов:*/
SELECT CAST('999АВС111' AS INTEGER);
SELECT CAST('999111' AS INTEGER);

/*Чтобы продолжить знакомство с функциями и не испортить данные в существующих таблицах, Алекс решил экспериментировать с новыми данными. 
Добавим данные в таблицу rental:*/
INSERT INTO rental (rental_id,rental_date,inventory_id,customer_id,return_date,staff_id,last_update)
VALUES ('99999','2019-09-10 15:30:00','367','130','2019-09-11 15:30:00','1','2020-09-17 15:30:00');

/*Функция TO_TIMESTAMP() используется для преобразования строки в дату и время по заданному шаблону:*/
UPDATE rental
SET return_date = TO_TIMESTAMP('September 17, 2019', 'Month DD, YYYY')
WHERE rental_id = 99999;

/*Тем более, если таким образом сгенерировать текущую дату/время, не нужно создавать строку, потому что есть следующие встроенные функции, 
которые обращаются к системным часам и возвращают текущую дату и/или время в виде строки:*/
SELECT CURRENT_DATE, CURRENT_TIME, CURRENT_TIMESTAMP;

/*Обнови запрос, чтобы исправить разницу во времени, замеченную Алексом:*/
SELECT CURRENT_DATE, CURRENT_TIME + INTERVAL '3 hours', CURRENT_TIMESTAMP + INTERVAL '3 hours';
/*Всё бы хорошо, если не одно «но»: запрос будет работать неправильно , если затрагивает смену суток. 
Он не исправит дату, если у Алекса будет 00:05, а системные часы показывают 21:05.*/

/*Алекс нашёл решение, которое будет работать правильно, но только в интервале с 21:00 до 00:00. В остальное время добавление 1 дня будет неверным:*/
SELECT CURRENT_DATE + INTERVAL '1 days', CURRENT_TIME + INTERVAL '3 hours', CURRENT_TIMESTAMP + INTERVAL '3 hours';

/*Алексу стало интересно, в какой день недели он родился: он воспользовался функцией TO_CHAR() для текущей даты и для даты своего рождения:*/
SELECT TO_CHAR(CURRENT_DATE, 'Day');
SELECT TO_CHAR(DATE '1982-09-09', 'Day');

/*Например, так можно извлечь год из даты, используя эту функцию с помощью TIMESTAMP:*/
SELECT EXTRACT(YEAR FROM TIMESTAMP '2019-09-18 22:19:05');

/*Если нам нужно посчитать, сколько полных дней прошло между двумя датами, воспользуемся новым оператором '::'. 
Оператор :: используется для явного приведения типов.*/
SELECT '2019-09-03'::DATE - '2019-06-21'::DATE;

/*Напиши запрос, который возвращает символы строки 'Please find the substring in this string' с 17-го по 33-й.*/
SELECT substring('Please find the substring in this string', 17, 17);

/*Напиши запрос, который возвращает абсолютное значение и знак (-1, 0 или 1) числа -25,76823. 
Верни также число, округленное до ближайших двух знаков после запятой.*/
SELECT abs(-25.76823) AS absolute_value,
       SIGN(-25.76823) AS sign,
       ROUND(-25.76823, 2) AS rounded_value;

/*Напиши запрос, возвращающий для текущей даты только часть, соответствующую месяцу.*/
SELECT EXTRACT(MONTH FROM CURRENT_DATE);

/*3.1*/
/*Запрос для получения количества фильмов, взятых напрокат каждым клиентом по идентификатору клиента, с группировкой и агрегатной функцией count(*):*/
SELECT customer_id, count(*)
FROM rental
GROUP BY customer_id
ORDER BY customer_id;

/*Чтобы подготовить отчёт, который позволит отсортировать результаты, нужно просто добавить сортировку, 
но в этот раз не по customer_id, а по count(*), используя предложение ORDER BY для второго столбца:*/
SELECT customer_id, count(*)
FROM rental
GROUP BY customer_id
ORDER BY 2 DESC;

/*Алекс решил усовершенствовать запрос, так как руководство хочет выдавать купоны только тем клиентам, 
которые брали напрокат более 40 фильмов.*/
SELECT customer_id, count(*) 
FROM rental
GROUP BY customer_id
HAVING count(*) >= 40
ORDER BY 2 DESC;

/*Алекс решил использовать эти функции для анализа потраченных клиентами средств на аренду фильмов:*/
SELECT MAX(amount) max_amt, MIN(amount) min_amt, AVG(amount) avg_amt, SUM(amount) tot_amt, COUNT(*) num_payments
FROM payment;

/*Можно расширить предыдущий запрос и выполнить те же пять агрегатных функций, но не для всех клиентов одновременно, 
а для каждого клиента. Для такого запроса нужно вместе с пятью агрегатными функциями выполнить выборку customer_id. 
Но если не сделать группировку по customer_id, запрос выдаст ошибку, поэтому попробуй такой вариант:*/
SELECT customer_id, MAX(amount) max_amt, MIN(amount) min_amt, AVG(amount) avg_amt, SUM(amount) tot_amt, COUNT(*) num_payments
FROM payment
GROUP BY customer_id;

/*При использовании функции count(*) для определения количества членов в каждой группе у тебя есть выбор: 
подсчитать все элементы группы или только различные значения столбца среди всех элементов группы. Рассмотри следующий запрос, 
в котором функция count(*) и столбец customer_id используются двумя разными способами:*/
SELECT COUNT(customer_id) num_rows,
COUNT(DISTINCT customer_id) num_customers
FROM payment;

/*Наряду с использованием столбцов в качестве аргументов агрегатных функций можно использовать и выражения.
Алекс решил найти максимальное количество дней между моментом, когда фильм был взят напрокат, и его возвратом. 
Эту информацию можно получить с помощью следующего запроса:*/
SELECT MAX(return_date - rental_date)
FROM rental;

/*Алекс решил проверить это в новой таблице, чтобы не портить данные в таблицах фирмы. Для этого он создал таблицу, 
наполнил её данными и выполнил пять агрегатных функций для указанного множества чисел:*/
CREATE TABLE number_tbl (val SMALLINT); 
INSERT INTO number_tbl 
VALUES (1); 
INSERT INTO number_tbl 
VALUES (3); 
INSERT INTO number_tbl 
VALUES (5);

SELECT COUNT(*) num_rows, COUNT(val) num_vals, SUM(val) total, MAX(val) max_val, AVG(val) avg_val
FROM number_tbl;

/*А теперь проверь, что будет, если добавить в таблицу значение NULL и снова выполнить предыдущий запрос:*/
INSERT INTO number_tbl 
VALUES (NULL);

SELECT count(*) num_rows, count(val) num_vals, sum(val) total, max(val) max_val, avg(val) avg_val
FROM number_tbl;

/*У Алекса как раз новая задача — найти количество фильмов, связанных с каждым актером. 
Для этого он использовал группировку по единственному столбцу film_actor.actor_id:*/
SELECT actor_id, count(*)
FROM film_actor
GROUP BY actor_id;

/*В некоторых случаях может понадобиться создавать группы, охватывающие более одного столбца, это так называемая многостолбцовая группировка. 
Расширим запрос Алекса и найдем общее число фильмов с разными рейтингами (G, PG, ...):*/
SELECT fa.actor_id, f.rating, count(*)
FROM film_actor fa
INNER JOIN film f
ON fa.film_id = f.film_id
GROUP BY fa.actor_id, f.rating
ORDER BY 1,2;

/*Алекс решил сделать группировку по годам, чтобы посмотреть, сколько фильмов брали напрокат в каждый отдельно взятый год:*/
SELECT extract(YEAR FROM rental_date) rental_year, count(*) how_many
FROM rental
GROUP BY extract(YEAR FROM rental_date);

/*Новая задача, которую предстоит решить Алексу, состоит в том, чтобы выявить 
предпочтения определенных актеров в зависимости от рейтинга фильмов, в которых они снимались. 
Такой анализ может помочь компании давать правильные рекомендации клиентам. Необходимо создать запрос, который покажет, 
какие актеры снялись в фильмах определенного рейтинга с указанием количества таких фильмов:*/
SELECT fa.actor_id, f.rating, count(*)
FROM film_actor fa
INNER JOIN film f
ON fa.film_id = f.film_id
GROUP BY ROLLUP (fa.actor_id, f.rating)
ORDER BY 1,2;

/*При группировке данных также можно применить фильтрующее условие к данным после того, как были сгенерированы группы, 
— условия группового фильтра. Эти типы условий фильтрации должны быть размещены в предложении HAVING.*/
SELECT fa.actor_id, f.rating, count(*)
FROM  film_actor fa
INNER JOIN film f
ON fa.film_id = f.film_id
WHERE f.rating IN ('G', 'PG')
GROUP BY fa.actor_id, f.rating
HAVING count(*) > 9;

/*Создай запрос, который подсчитывает количество строк в таблице payment.*/
SELECT count(*) AS row_count FROM payment;

/*Измени предыдущий запрос так, чтобы подсчитать количество платежей, произведенных каждым клиентом. 
Выведи идентификатор клиента и общую уплаченную сумму для каждого клиента.*/
SELECT customer_id, count(*) AS payment_count, sum(amount) AS total_amount
FROM payment
GROUP BY customer_id;

/*Измени предыдущий запрос, включив в него только тех клиентов, у которых имеется не менее 40 выплат.*/
SELECT customer_id, count(*) AS payment_count, sum(amount) AS total_amount
FROM payment
GROUP BY customer_id
HAVING count(*) >= 40;






