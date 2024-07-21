/*2.1*/
/*Таким образом, если мы хотим  частично скрыть адрес электронной почты, вместо того, чтобы разрешить прямой доступ к таблице клиентов,
Алекс может определить представление с именем customer_vw и требовать, чтобы все, кроме персонала маркетинга, использовали его для доступа к данным о клиентах.*/
CREATE VIEW customer_vw
(customer_id,
first_name,
last_name, email )
AS
SELECT
customer_id,
first_name,
last_name,
concat(substr(email,1,2), '*****', substr(email, length(email) - 3, 4)) e_mail
FROM customer;

/*Алекс решил поступить именно так и указать, к каким строкам могут иметь доступ пользователи, добавив в определение представления предложение WHERE:*/
CREATE VIEW customer_no_mail AS
SELECT customer_id, first_name, last_name
FROM customer
WHERE active = 1;

/*Чтобы воспользоваться созданными представлениями, Алексу надо просто сделать из них выборку:*/
SELECT * FROM customer_vw;

SELECT * FROM customer_no_mail;

/*Приложениям для создания отчетов обычно требуются агрегированные данные, а представления — отличное средство создания впечатления, 
что в базе данных сохраняются предварительно агрегированные данные.
Именно поэтому Алекс решил: вместо того чтобы позволять разработчикам приложений писать запросы, обращающиеся к базовым таблицам, 
им можно предложить представление, которое показывает общий объем продаж по каждой категории фильмов:*/
CREATE VIEW sales_by_film_category_new AS
SELECT c.name AS category, SUM(p.amount) AS total_sales
FROM payment p
JOIN rental r ON p.rental_id = r.rental_id
JOIN inventory i ON r.inventory_id = i.inventory_id
JOIN film f ON i.film_id = f.film_id
JOIN film_category fc ON f.film_id = fc.film_id
JOIN category c ON fc.category_id = c.category_id
GROUP BY c.name;

/*Каждый месяц он создает отчет, в котором отображается информация обо всех фильмах наряду с категорией фильмов, количеством актеров,
фигурирующих в фильме, общим наличным количеством копий и количеством прокатов каждого фильма.
Для этого Алексу приходится каждый раз выбирать информацию из шести разных таблиц для сбора необходимых данных. Вместо этого он создает представление:*/
CREATE VIEW film_report AS
SELECT f.title, c.name AS category, COUNT(fa.actor_id) AS num_actors,
       COUNT(i.inventory_id) AS total_inventory, COUNT(r.rental_id) AS num_rentals
FROM film f
JOIN film_category fc ON f.film_id = fc.film_id
JOIN category c ON fc.category_id = c.category_id
JOIN film_actor fa ON f.film_id = fa.film_id
JOIN inventory i ON f.film_id = i.film_id
LEFT JOIN rental r ON i.inventory_id = r.inventory_id
GROUP BY f.title, c.name;

/*Создавая представление, которое запрашивает обе таблицы и объединяет полученные результаты, можно просмотреть результаты, как если бы все данные о платежах хранились в одной таблице:*/
CREATE VIEW payment_combined AS
SELECT payment_id, customer_id, staff_id, rental_id, amount, payment_date
FROM payment_p2007_01
UNION ALL
SELECT payment_id, customer_id, staff_id, rental_id, amount, payment_date
FROM payment_p2007_02;

/*Напиши представление с именем customer_vw для доступа к данным о клиентах, в котором столбец e_mail отображает 
только первые два символа адреса электронной почты со строкой '*****', а затем — последние четыре символа электронного адреса.*/
CREATE VIEW customer_vw
(customer_id,
first_name,
last_name, email )
AS
SELECT
customer_id,
first_name,
last_name,
concat(substr(email,1,2), '*****', substr(email, length(email) - 3, 4)) e_mail
FROM customer;

/*Создай отчет, в котором отображается информация обо всех фильмах наряду с категорией фильмов,
количеством актеров, фигурирующих в фильме, общим наличным количеством копий и количеством прокатов каждого фильма.*/
CREATE VIEW film_report AS

SELECT f.title, c.name AS category, count(fa.actor_id) AS num_actors, count(i.inventory_id) AS total_inventory, count(r.rental_id) AS num_rentals

FROM film f

JOIN film_category fc ON f.film_id = fc.film_id

JOIN category c ON fc.category_id = c.category_id

JOIN film_actor fa ON f.film_id = fa.film_id

JOIN inventory i ON f.film_id = i.film_id

LEFT JOIN rental r ON i.inventory_id = r.inventory_id

GROUP BY f.title, c.name;

/*2.1*/
/*Создай определение представления, которое можно использовать с помощью следующего запроса для генерации результирующего набора, приведенного на скриншоте.*/
SELECT
title,
category_name,
first_name,
last_name
FROM
film_ctgry_actor
WHERE
last_name = 'FAWCETT';



















