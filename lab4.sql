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

/*2.1*/
SELECT c.first_name, c.last_name, a.address, ct.city
    FROM customer c
    INNER JOIN address a
    ON c.address_id = a.address_id
    INNER JOIN city ct
    ON a.city_id = ct.city_id
WHERE a.district='California';

