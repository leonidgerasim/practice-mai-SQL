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

CREATE VIEW film_ctgry_actor AS
SELECT f.title, c.name AS category_name, a.first_name, a.last_name
FROM film f
JOIN film_category fc ON f.film_id = fc.film_id
JOIN category c ON fc.category_id = c.category_id
JOIN film_actor fa ON f.film_id = fa.film_id
JOIN actor a ON fa.actor_id = a.actor_id;

/*Менеджер фирмы по прокату фильмов хотел бы иметь отчет, который включает в себя название каждой страны, а также общие платежи всех клиентов, 
которые живут в данной стране. 
Создай определение представления, которое запрашивает таблицу country и использует для вычисления значения столбца tot_payments скалярный подзапрос.*/
CREATE VIEW country_payments AS
SELECT
c.country,
(SELECT sum(p.amount)
FROM customer cu
JOIN payment p ON cu.customer_id = p.customer_id
WHERE cu.address_id IN ( 
SELECT address_id FROM address a WHERE a.city_id IN ( 
SELECT city_id FROM city ci WHERE ci.country_id = c.country_id 
) 
)
 ) AS tot_payment
FROM country c;

/*3.1*/
/*Ранее Алекс подготовил запрос, который подсчитывает итоговую сумму общих ежемесячных платежей за прокат фильмов в период с мая по август 2005 года. 
Этот запрос используется для отчета менеджерам продаж и генерирует ежемесячные итоги продаж в течение определенного периода:*/
SELECT extract(quarter from payment_date) as quarter,
       to_char(payment_date, 'Month') as month_nm,
       sum(amount) as monthly_sales
FROM payment
WHERE extract(year from payment_date) = 2005
GROUP BY extract(quarter from payment_date), to_char(payment_date, 'Month');

/*Алекс переписал запрос с использованием оконных функций, теперь он позволяет определить самые высокие значения за все время и за каждый квартал:*/
SELECT extract(quarter from payment_date) as quarter,
       to_char(payment_date, 'Month') as month_nm,
       sum(amount) as monthly_sales,
       max(sum(amount)) over () as max_overall_sales,
       max(sum(amount)) over (partition by extract(quarter from payment_date)) as max_qrtr_sales
FROM payment
WHERE extract(year from payment_date) = 2005
GROUP BY extract(quarter from payment_date), to_char(payment_date, 'Month');

/*Менеджеры по продажам попросил Алекса подготовить рейтинг для каждого месяца, в котором значение 1 отдается месяцу, имеющему самые высокие продажи. 
В запросе Алексу нужно указать, какой столбец используется для вычисления рейтинга: он указал порядок сортировки. используя оконные функции:*/
SELECT extract(quarter from payment_date) as quarter,
       to_char(payment_date, 'Month') as month_nm,
       sum(amount) as monthly_sales,
       rank() over (order by sum(amount) desc) as sales_rank
FROM payment
WHERE extract(year from payment_date) = 2005
GROUP BY extract(quarter from payment_date), to_char(payment_date, 'Month')
ORDER BY sales_rank, month_nm;

/*Однако менеджерам нужно предоставлять поквартальные рейтинги, а не единый рейтинг для всего результирующего набора. Алекс обновил свой запрос:*/
SELECT extract(quarter from payment_date) as quarter,
       to_char(payment_date, 'Month') as month_nm,
       sum(amount) as monthly_sales,
       rank() over (partition by extract(quarter from payment_date) order by sum(amount) desc) as qtr_sales_rank
FROM payment
WHERE extract(year from payment_date) = 2005
GROUP BY extract(quarter from payment_date), to_char(payment_date, 'Month')
ORDER BY qtr_sales_rank, month_nm;

/*Алекс задумался: а как написать запрос, который определит количество прокатов фильмов для каждого клиента и отсортирует результаты в порядке убывания?
Для решения этой задачи можно использовать ранжирование:
row_number — возвращает для каждой строки уникальное число с произвольно назначаемым рейтингом для одинаковых данных
rank — возвращает при одинаковых данных один и тот же рейтинг с соответствующими пропусками в общем рейтинге
dense_rank — возвращает при одинаковых данных один и тот же рейтинг без пропусков в общем рейтинге
Алекс добавил ранжирование в свой запрос:*/
SELECT customer_id, count(*) num_rentals,
row_number() over (order by count(*) desc) row_number_rnk,
rank() over (order by count(*) desc) rank_rnk,
dense_rank() over (order by count(*) desc) dense_rank_rnk
FROM rental
GROUP BY customer_id
ORDER BY 2 desc;

/*Отдел продаж решает предложить бесплатный прокат фильмов для пяти лучших клиентов каждый месяц.
Чтобы сгенерировать такие данные, Алекс добавил к запросу столбец rental_month:*/
SELECT customer_id,
       count(*) as num_rentals,
       rank() over (order by count(*) desc) as rank_rnk,
       dense_rank() over (order by count(*) desc) as dense_rank_rnk
FROM rental
GROUP BY customer_id
ORDER BY 2 desc;

/*Для того чтобы каждый месяц создавать новый набор рейтингов, нужно добавить в функцию rank нечто,
описывающее, как разделить результирующий набор на различные окна. Алекс обновил свой отчет:*/
SELECT customer_id,
       to_char(rental_date, 'Month') as rental_month,
       count(*) as num_rentals,
       rank() over (partition by to_char(rental_date, 'Month') order by count(*) desc) as rank_rnk
FROM rental
GROUP BY customer_id, to_char(rental_date, 'Month')
ORDER BY 2, 3 desc;

/*Чтобы отображать пять лучших клиентов, Алекс добавил это условие в свой запрос:*/
SELECT customer_id, rental_month, num_rentals, rank_rnk as ranking
FROM (
  SELECT customer_id,
         to_char(rental_date, 'Month') as rental_month,
         count(*) as num_rentals,
         rank() over (partition by to_char(rental_date, 'Month') order by count(*) desc) as rank_rnk
  FROM rental
  GROUP BY customer_id, to_char(rental_date, 'Month')
) cust_rankings
WHERE rank_rnk <= 5
ORDER BY rental_month, num_rentals desc, rank_rnk;

/*Бухгалтерия запросила у Алекса несколько отчётов.
Первый должен отображать ежемесячные и общие итоги для всех платежей размером не менее 10 долларов:*/
SELECT to_char(payment_date, 'Month') as payment_month,
       amount,
       sum(amount) over (partition by to_char(payment_date, 'Month')) as monthly_total,
       sum(amount) over () as grand_total
FROM payment
WHERE amount >= 10
ORDER BY 1;

/*Второй вычисляет процент от общей суммы платежей для каждого месяца, округленный до двух знаков после запятой:*/
SELECT to_char(payment_date, 'Month') as payment_month,
       sum(amount) as month_total,
       round(sum(amount) / sum(sum(amount)) over () * 100, 2) as pct_of_total
FROM payment
GROUP BY to_char(payment_date, 'Month');

/*Третий меняет описания каждого месяца на основе суммы платежей. Если сумма платежей за месяц равна максимальной сумме платежей 
среди всех месяцев, то описание будет 'Highest'. Если сумма платежей за 
месяц равна минимальной сумме платежей среди всех месяцев, то описание будет 'Lowest'. В остальных случаях описание будет 'Middle':*/
SELECT to_char(payment_date, 'Month') as payment_month,
       sum(amount) as month_total,
       CASE
         WHEN sum(amount) = max(sum(amount)) over() THEN 'Highest'
         WHEN sum(amount) = min(sum(amount)) over() THEN 'Lowest'
         ELSE 'Middle'
       END as descriptor
FROM payment
GROUP BY to_char(payment_date, 'Month');

/*Алекс написал запрос, который суммирует платежи за каждую неделю и включает функцию отчетности для вычисления суммы:*/
SELECT extract(week from payment_date) as payment_week,
       sum(amount) as week_total,
       sum(sum(amount)) over (order by extract(week from payment_date) rows unbounded preceding) as rolling_sum
FROM payment
GROUP BY extract(week from payment_date)
ORDER BY 1;

/*Алекс экспериментирует с рамками и написал запрос, который суммирует платежи за каждую неделю и включает функцию отчетности для вычисления суммы, 
а также добавляет столбец средней суммы платежей за 3 недели (текущая неделя, предыдущая неделя и следующая неделя):*/
SELECT extract(week from payment_date) as payment_week,
       sum(amount) as week_total,
       avg(sum(amount)) over (order by extract(week from payment_date) rows between 1 preceding and 1 following) as rolling_3wk_avg
FROM payment
GROUP BY extract(week from payment_date)
ORDER BY 1;

/*Далее он подготовил запрос, который суммирует платежи за день и включает функцию отчетности для вычисления суммы, а также добавляет с
толбец средней суммы платежей за 7 дней (3 дня до текущей даты и 3 дня после текущей даты) с помощью:*/
SELECT extract(day from payment_date) as payment_day,
       sum(amount),
       avg(sum(amount)) over (order by extract(day from payment_date) range between 3 preceding and 3 following) as rolling_3_day_avg
FROM payment
GROUP BY extract(day from payment_date)
ORDER BY 1;

/*Алекс с легкостью написал новый отчет, который использует функцию lag:*/
SELECT
    to_char(payment_date, 'YYYY-MM') AS month,
    sum(amount) AS total_sales,
    round(100.0 * (sum(amount) - lag(sum(amount)) OVER (ORDER BY to_char(payment_date, 'YYYY-MM'))) / lag(sum(amount)) OVER (ORDER BY to_char(payment_date, 'YYYY-MM')), 2) AS pct_change
FROM
    payment
GROUP BY
    to_char(payment_date, 'YYYY-MM')
ORDER BY
    month;

/*Напиши запрос, который определяет количество прокатов фильмов для каждого клиента и сортирует результаты в порядке убывания.*/
SELECT customer_id, count(*) num_rentals,
row_number() over (order by count(*) desc) row_number_rnk,
rank() over (order by count(*) desc) rank_rnk,
dense_rank() over (order by count(*) desc) dense_rank_rnk
FROM rental
GROUP BY customer_id
ORDER BY 2 DESC;

/*Отдел продаж решает предложить бесплатный прокат фильмов для пяти 
лучших клиентов каждый месяц. Чтобы сгенерировать такие данные, можно добавить к запросу столбец rental_month.*/
SELECT customer_id,
       count(*) as num_rentals,
       rank() over (order by count(*) desc) as rank_rnk,
       dense_rank() over (order by count(*) desc) as dense_rank_rnk
FROM rental
GROUP BY customer_id
ORDER BY 2 desc;

/*Напиши запрос, который вычисляет процент от общей суммы платежей для каждого месяца, и округли до двух знаков после запятой.*/
SELECT to_char(payment_date, 'Month') as payment_month,
sum(amount) as month_total,
round(sum(amount) / sum(sum(amount)) over () * 100, 2) as pct_of_total
FROM payment 
GROUP BY to_char(payment_date, 'Month');

/*Напиши запрос, который генерирует ежемесячные суммы продаж так, чтобы был дополнительный столбец, показывающий процентное отличие от предыдущего месяца.*/
SELECT
    to_char(payment_date, 'YYYY-MM') AS month,
    sum(amount) AS total_sales,
    round(100.0 * (sum(amount) - lag(sum(amount)) over (ORDER BY to_char(payment_date, 'YYYY-MM'))) / lag(sum(amount)) over (ORDER BY to_char(payment_date, 'YYYY-MM')), 2) AS pct_change
FROM
    payment
GROUP BY
    to_char(payment_date, 'YYYY-MM')
ORDER BY
    month;

/*Напиши запрос, который суммирует платежи за каждую неделю и включает функцию отчетности для вычисления суммы.*/
SELECT
extract(week from payment_date) as payment_week,
       sum(amount) as week_total,
       sum(sum(amount)) over (order by extract(week from payment_date) rows unbounded preceding) as rolling_sum
FROM payment
GROUP BY extract(week from payment_date)
ORDER BY 1;

/*Напиши запрос, который создает таблицу sales_fact, содержащую три столбца: year, month, tot_sales.*/
CREATE TABLE sales_fact (
year INTEGER,
month INTEGER,
tot_sales NUMERIC(10, 2)
);

/*Напиши запрос, который заполняет таблицу помесячно на 2 года (2019 и 2020) произвольными значениями 
от 5000 до 25000 и округленными до целого (вниз). Таким образом, в таблице должно быть 24 строки для каждого месяца двух лет:*/
INSERT INTO sales_fact (year, month, tot_sales)
SELECT sub_y.year, generate_series(1, 12) AS month, FLOOR(random() * 20000 + 5000) tot_sales
FROM (SELECT generate_series(2019, 2020) AS year) sub_y;

/*Напиши запрос, который извлекает каждую строку из таблицы и добавляет столбец для генерации рейтинга на основе значений столбца tot_sales. 
Самое высокое значение должно получить рейтинг 1, а самое низкое — рейтинг 24.*/
SELECT
    year,
    month,
    tot_sales,
    rank() over (ORDER BY tot_sales DESC) AS sales_rank
FROM
    sales_fact;

/*Измени запрос к созданной в предыдущем вопросе таблице sales_fact так, 
чтобы генерировались два набора рейтингов от 1 до 12: один — для 2019 года и один — для 2020 года.*/
SELECT
    year,
    month,
    tot_sales,
    rank() over (partition BY year ORDER BY tot_sales DESC) AS sales_rank
FROM
    sales_fact;

/*Напиши запрос к таблице sales_fact, который извлекает все данные за 2020 год, и включи столбец, который будет содержать значение tot_sales для предыдущего месяца.*/
SELECT year, month, tot_sales, lag(tot_sales) over (ORDER BY year, month) AS prev_month_sales
FROM sales_fact
WHERE year = 2020;



















