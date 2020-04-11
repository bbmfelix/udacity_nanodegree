-- PROJECT 1 - SQL
-- STUDENT: BRUNO FELIX


-- QUESTION SET #1

---------------------------------------------------------------------------------------------------------
-- QUESTION 1 QUERY

SELECT
	F.TITLE as FILM_TITLE,
	C.NAME as CATEGORY_NAME,
	COUNT (R.RENTAL_ID) as RENTAL_COUNT

FROM
	FILM as F 

	LEFT JOIN FILM_CATEGORY as FC
	ON F.FILM_ID = FC.FILM_ID

	LEFT JOIN CATEGORY AS C
	ON C.CATEGORY_ID = FC.CATEGORY_ID

	LEFT JOIN INVENTORY as I
	ON I.FILM_ID = F.FILM_ID

	LEFT JOIN RENTAL AS R
	ON R.INVENTORY_ID = I.INVENTORY_ID

WHERE
	C.NAME IN ('Animation','Children','Classics','Comedy','Family','Music')

GROUP BY
	1,2

ORDER BY
	3 DESC
;


---------------------------------------------------------------------------------------------------------
-- QUESTION 2 QUERY

 WITH PERC AS 
(
SELECT
	PERCENTILE_CONT(.25) WITHIN GROUP (ORDER BY RENTAL_DURATION) AS PERC_25,
	PERCENTILE_CONT(.5) WITHIN GROUP (ORDER BY RENTAL_DURATION) AS PERC_50,
	PERCENTILE_CONT(.75) WITHIN GROUP (ORDER BY RENTAL_DURATION) AS PERC_75
FROM
	FILM
)

SELECT
	F.TITLE AS FILM_TITLE,
	C.NAME AS CATEGORY_NAME,

	CASE 
		WHEN F.RENTAL_DURATION <= (SELECT PERC.PERC_25 FROM PERC) THEN '1'
		WHEN F.RENTAL_DURATION > (SELECT PERC.PERC_25 FROM PERC) AND F.RENTAL_DURATION <= (SELECT PERC.PERC_50 FROM PERC) THEN '2'
		WHEN F.RENTAL_DURATION > (SELECT PERC.PERC_50 FROM PERC) AND F.RENTAL_DURATION <= (SELECT PERC.PERC_75 FROM PERC) THEN '3'
		WHEN F.RENTAL_DURATION > (SELECT PERC.PERC_75 FROM PERC) THEN '4'
	ELSE NULL END AS QUARTILE

FROM
	FILM as F 

	LEFT JOIN FILM_CATEGORY as FC
	ON F.FILM_ID = FC.FILM_ID

	LEFT JOIN CATEGORY AS C
	ON C.CATEGORY_ID = FC.CATEGORY_ID

WHERE
	C.NAME IN ('Animation','Children','Classics','Comedy','Family','Music')
;

---------------------------------------------------------------------------------------------------------
-- QUESTION 3 QUERY

 WITH PERC AS 
(
SELECT
	PERCENTILE_CONT(.25) WITHIN GROUP (ORDER BY RENTAL_DURATION) AS PERC_25,
	PERCENTILE_CONT(.5) WITHIN GROUP (ORDER BY RENTAL_DURATION) AS PERC_50,
	PERCENTILE_CONT(.75) WITHIN GROUP (ORDER BY RENTAL_DURATION) AS PERC_75
FROM
	FILM
)

SELECT
	C.NAME AS CATEGORY_NAME,

	CASE 
		WHEN F.RENTAL_DURATION <= (SELECT PERC.PERC_25 FROM PERC) THEN '1'
		WHEN F.RENTAL_DURATION > (SELECT PERC.PERC_25 FROM PERC) AND F.RENTAL_DURATION <= (SELECT PERC.PERC_50 FROM PERC) THEN '2'
		WHEN F.RENTAL_DURATION > (SELECT PERC.PERC_50 FROM PERC) AND F.RENTAL_DURATION <= (SELECT PERC.PERC_75 FROM PERC) THEN '3'
		WHEN F.RENTAL_DURATION > (SELECT PERC.PERC_75 FROM PERC) THEN '4'
	ELSE NULL END AS QUARTILE,

	COUNT (F.TITLE) as QTY_MOVIES

FROM
	FILM as F 

	LEFT JOIN FILM_CATEGORY as FC
	ON F.FILM_ID = FC.FILM_ID

	LEFT JOIN CATEGORY AS C
	ON C.CATEGORY_ID = FC.CATEGORY_ID

WHERE
	C.NAME IN ('Animation','Children','Classics','Comedy','Family','Music')

GROUP BY 
	1,2
ORDER BY
	1,2
;


-- QUESTION SET #2

---------------------------------------------------------------------------------------------------------
-- QUESTION 3 QUERY

---------------------
-- Q1 OVERVIEW
SELECT
	DATE_PART('month',R.RENTAL_DATE) AS RENTAL_MONTH,
    DATE_PART('year',R.RENTAL_DATE) AS RENTAL_YEAR,
    S.STORE_ID,
    COUNT(RENTAL_ID)
FROM
	RENTAL as R
    LEFT JOIN STAFF AS F
    ON F.STAFF_ID = R.STAFF_ID
    LEFT JOIN STORE as S
    ON F.STORE_ID = S.STORE_ID
GROUP BY
	1,2,3
;

---------------------
-- Q2 OVERVIEW

SELECT 
	DATE_TRUNC('month', P.PAYMENT_DATE) AS pay_mon,
	CONCAT (C.FIRST_NAME, ' ', C.LAST_NAME) as fullname,
	COUNT(P.PAYMENT_ID) AS pay_countpermon,
	SUM(P.AMOUNT) as pay_amount


FROM PAYMENT AS P

LEFT JOIN CUSTOMER AS C
	ON p.customer_id = c.customer_id


WHERE P.CUSTOMER_ID in 

(
SELECT
	ID
FROM
	(
	SELECT 
		CUSTOMER_ID as ID,
		SUM(AMOUNT) as PAYMENT_SUM

	FROM 
		PAYMENT
	
	GROUP BY 
		1
	ORDER BY
		2 DESC
LIMIT 10
) as t1

)

GROUP BY 
	1, 2, P.CUSTOMER_ID
ORDER BY
	2, 1

------------------
-- Q3 SOLUTION

WITH t3 AS 

(
SELECT 
	t2.payment_mon, 
	t2.full_name, 
	t2.count, 
	t2.sum,
	LEAD(t2.sum) OVER (PARTITION BY t2.full_name ORDER BY t2.payment_mon) - t2.sum AS lead_difference

FROM 
	(
	SELECT 
		c.customer_id, 
		CONCAT(c.first_name, ' ', c.last_name) AS full_name,
		SUM(p.amount) AS total_payment
	FROM customer AS c

	LEFT JOIN payment AS p
	ON c.customer_id = p.customer_id

	GROUP BY 
		1

	ORDER BY 
		3 DESC

	LIMIT 10
	) t1

JOIN 
	(
	SELECT 
		c.customer_id, 
		DATE_TRUNC('month',p.payment_date) AS payment_mon,
		CONCAT(c.first_name, ' ', c.last_name) AS full_name,
		SUM(p.amount) AS sum,
		COUNT(p.amount) AS count

	FROM customer AS c

	INNER JOIN payment AS p
	ON c.customer_id = p.customer_id

	GROUP BY 
	1,2

	ORDER BY 
	1
	) t2

ON t1.full_name = t2.full_name

ORDER BY 2, 1
)

SELECT *

FROM t3

WHERE lead_difference = (SELECT MAX(lead_difference) FROM t3)