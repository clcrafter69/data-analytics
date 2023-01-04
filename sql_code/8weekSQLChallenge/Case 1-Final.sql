SET search_path = dannys_diner;

-- Question 1: What is the total amount each customer spent at the restaurant?

-- to answer this question, you must sum all of the price by product for each customer
-- Join the SALES table and the PRODUCT table by product ID to sum the prices of all of 
-- the dishes purchases by the customer

	SELECT CUSTOMER_ID,
			SUM(ME.PRICE)* 1.00 AS TOTAL_SPENT
		FROM SALES S
		INNER JOIN MENU ME ON S.PRODUCT_ID = ME.PRODUCT_ID
		GROUP BY CUSTOMER_ID
		ORDER BY CUSTOMER_ID;
	
--ANSWER #1:
-- Customer A spent 76.00
-- Customer B spent 74.00
-- Customer C spent 36.00

--***************************************************************************************************************************

--Question 2:
--How many days has each customer spent at the restaurant?

-- In the SALES table, an entry is entered each time the customer orders a dish. 
-- There can be multiple entries on the same day for each customer, 
-- depending on the number of dishes ordered.
-- Therefore, we want to get the number of distinct days in the table for each customer

SELECT CUSTOMER_ID AS CUSTOMER,
	COUNT (DISTINCT ORDER_DATE) AS NUMBER_OF_DAYS
FROM SALES S
GROUP BY CUSTOMER_ID
ORDER BY CUSTOMER_ID;

--ANSWER 2:
--Customer A spent 8 days in restaurant
--Customer B spent 6 days in restaurant
--Customer C spent 2 days in restaurant

--***************************************************************************************************************************
--Question 3:
--What was the first item purchased by each customer?


--Retrieve the minimum order date for each customer. Wrap in CTE
--Perform an INNER JOIN on the CTE and the Sales table to get the customer_id, product_id, product_name to determine first item ordered
--Do a DISTINCT on the query because the customer may have ordered the same product on the same day
--We do not the row to appear twice

with min_order
as (
select customer_id, min(order_date) as first_order
from sales S
group by customer_id
order by customer_id
)

select DISTINCT s.customer_id,p.product_id,mu.product_name,first_order
from min_order S
join sales P
on s.customer_id = p.customer_id
and first_order = order_date
join menu mu
on p.product_id = mu.product_id
order by customer_id
;

--ANSWER 3:
--Customer A ordered sushi and curry
--Customer B ordered curry
--Customer C ordered ramen


--***************************************************************************************************************************
--Question 4:
-- What is the most purchased item on menu and how many times was it purchased by all customers?

-- Do an inner join on the SALES and MENU tables using product ID. Count the number of dates (orders) for each product 

SELECT PRODUCT_NAME,
	COUNT(ORDER_DATE) AS NUMBER_OF_PURCHASES
FROM MENU ME
INNER JOIN SALES S ON ME.PRODUCT_ID = S.PRODUCT_ID
GROUP BY PRODUCT_NAME
ORDER BY NUMBER_OF_PURCHASES DESC
LIMIT 1;

--ANSWER 4:
--The most purchased item - Ramen. It was purchased 8 times


--***************************************************************************************************************************
--Question 5:
-- Which item was the most popular for each customer?

-- Group by customer and rank the product for each. Choose Rank = 1 (the popular dish) for each customer

WITH PROD_RANK AS
				(SELECT CUSTOMER_ID,
						PRODUCT_NAME,
						COUNT(ORDER_DATE) AS NUMBER_OF_PURCHASES,
						RANK() OVER (PARTITION BY CUSTOMER_ID
					ORDER BY COUNT(ORDER_DATE)DESC) AS PRODUCT_RANK
					FROM MENU ME
					JOIN SALES S ON ME.PRODUCT_ID = S.PRODUCT_ID
					GROUP BY PRODUCT_NAME,
						CUSTOMER_ID
					ORDER BY CUSTOMER_ID)
SELECT CUSTOMER_ID,
	PRODUCT_NAME,
	PRODUCT_RANK
FROM PROD_RANK
WHERE PRODUCT_RANK = 1;

--ANSWER 5:
-- Customers A and C preferred ramen 
-- Customer B liked ramen, sushi, and curry equally

--***************************************************************************************************************************
--Question 6:
--Which item was purchased first by the customer after they became a member?

--STEP 1:
--Retrieve the products and the order dates for all of the customers that are members
-- Group by customer (customer_ID)
-- Filter orders for each by retrieving only the orders that were placed on or after the membership date
-- Rank the orders based on order date asc. The earliest date will have Rank =1, next date (Rank 2).etc
--Wrap in CTE

--STEP 2:
-- Write simple query to return only the rows for each customer that has a Rank =1 ( which will return the earliest date after the
-- customer became a member)


with first_order_tbl
as
(SELECT DISTINCT M.CUSTOMER_ID,
	PRODUCT_NAME,
	M.JOIN_DATE,
	S.ORDER_DATE AS FIRST_ORDER,
		RANK() OVER (PARTITION BY M.CUSTOMER_ID
				 ORDER BY ORDER_DATE) AS ORDER_RANK
FROM MEMBERS M
JOIN SALES S ON M.CUSTOMER_ID = S.CUSTOMER_ID
JOIN MENU ME ON S.PRODUCT_ID = ME.PRODUCT_ID
GROUP BY M.CUSTOMER_ID,
	PRODUCT_NAME,
	M.JOIN_DATE,
	S.ORDER_DATE
HAVING S.ORDER_DATE > M.JOIN_DATE
ORDER BY CUSTOMER_ID,
	FIRST_ORDER,
	PRODUCT_NAME)
	
select customer_id,product_name, FIRST_ORDER,ORDER_RANK
FROM FIRST_ORDER_TBL 
WHERE ORDER_RANK = 1; 
	
--ANSWER 6:
--Customer A ordered ramen first after becoming a member
--Customer B order sushi. 
	
	
--***************************************************************************************************************************	
--Question 7:
--Which item was purchased just before the customer became a member?

--STEP 1:
--Retrieve the products and the order dates for all of the customers that are members
-- Group by customer (customer_ID)
-- Filter orders for each by retrieving only the orders that were placed BEFORE the membership date (join date)
-- Rank the orders based on order date desc. The latest date will have Rank =1, next date (Rank 2).etc
--Wrap in CTE

--STEP 2:
-- Write simple query to return only the rows for each customer that has a Rank =1 ( which will return the last order date before the
-- customer became a member)

with last_order_tbl
as
(SELECT DISTINCT M.CUSTOMER_ID,
	PRODUCT_NAME,
	M.JOIN_DATE,
	S.ORDER_DATE AS FIRST_ORDER,
		RANK() OVER (PARTITION BY M.CUSTOMER_ID
				 ORDER BY ORDER_DATE DESC) AS ORDER_RANK 
FROM MEMBERS M
JOIN SALES S ON M.CUSTOMER_ID = S.CUSTOMER_ID
JOIN MENU ME ON S.PRODUCT_ID = ME.PRODUCT_ID
GROUP BY M.CUSTOMER_ID,
	PRODUCT_NAME,
	M.JOIN_DATE,
	S.ORDER_DATE
HAVING S.ORDER_DATE < M.JOIN_DATE
ORDER BY CUSTOMER_ID,
	FIRST_ORDER,
	PRODUCT_NAME)
	
select customer_id,product_name,JOIN_DATE, FIRST_ORDER,ORDER_RANK
FROM LAST_ORDER_TBL 
WHERE ORDER_RANK = 1; 

--ANSWER 7:
--Last item purchased by each customer before becoming a member:
--Customer A purchased curry and sushi
--Customer B purchased sushi

--***************************************************************************************************************************
--Question 8:
--What is the total items and amount spent for each member before they became a member?

-- Step 1: Similar to Question 7 except we need count all of the products and sum all of the amounts to get total amount
-- Figure out how many customers are members and what products did they buy


SELECT  M.CUSTOMER_ID,
	COUNT(S.ORDER_DATE) AS ORDER_COUNT,
	SUM(ME.PRICE) *1.00 AS ORDER_AMOUNT
FROM MEMBERS M
JOIN SALES S ON M.CUSTOMER_ID = S.CUSTOMER_ID
JOIN MENU ME ON S.PRODUCT_ID = ME.PRODUCT_ID
WHERE S.ORDER_DATE < M.JOIN_DATE
GROUP BY M.CUSTOMER_ID
ORDER BY CUSTOMER_ID

--ANSWER 8:
--Customer A -- 2 orders - Total amount 25.00
--Customer B -- 3 orders - Total amount 40.00

--***************************************************************************************************************************
--Question 9:
--If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?

--Step 1:
--determine how many orders by product per customer
--count the number of orders based on product
--sum up dollar amount for each customer per product
--Use CASE statement to apply mulitplier based on product

with bonus_points
as (
SELECT S.CUSTOMER_ID,
	ME.PRODUCT_NAME,
	ME.PRODUCT_ID,
	COUNT(ME.PRODUCT_ID),
	SUM(ME.PRICE),
	CASE
					WHEN ME.PRODUCT_ID = 1 THEN SUM(ME.PRICE) * 20
					ELSE SUM(ME.PRICE) * 10
	END AS TOTAL_MULTIPLIER
FROM SALES S
JOIN MENU ME ON S.PRODUCT_ID = ME.PRODUCT_ID
GROUP BY 1,2,3
ORDER BY CUSTOMER_ID,
	ME.PRODUCT_ID)

--sum up all of the points by customer

select customer_id, sum(total_multiplier)
from bonus_points
group by customer_id;

--ANSWER 9:
--Customer A has 860 points
--Customer B has 940 points
--Customer C has 360 points


--***************************************************************************************************************************
-- Question 10:
-- In the first week after a customer joins the program (including their join date)
-- they earn 2x points on all items, not just sushi
-- how many points do customer A and B have at the end of January?


--Plan of attack:
--Determine the number of points earned during the first week of membership
--Determine the number of points earned during the remainder of  membership days in January

--ASSUMPTIONS:
--will not include orders that were placed before they were members (assuming that the membership awards the customers points)


--Step 1:
--calculation for points earned in first week of membership for month of January
with bonus
as(
select s.customer_id,join_date, order_date,s.product_id,product_name,sum(price *20) as total_multiplier
from members M
join sales S
on M.customer_id = S.customer_id 
join menu me
on s.product_id = me.product_id
where (s.order_date >= m.join_date 
and s.order_date <= m.join_date + INTERVAL '6 day')
and s.order_date <= '01-31-2021'
group by s.customer_id,join_date, order_date,s.product_id,product_name),

--Step 2:
--calculations for remaining days in January
without_bonus
as
(
select s.customer_id,join_date, order_date,s.product_id,product_name,
	CASE
					WHEN S.PRODUCT_ID = 1 THEN SUM(me.PRICE) * 20
					ELSE SUM(me.PRICE) *10
	END AS TOTAL_MULTIPLIER
from members M
join sales S
on M.customer_id = S.customer_id 
join menu me
on s.product_id = me.product_id
where ( s.order_date > m.join_date + INTERVAL '6 day') or (s.order_date < m.join_date)
and s.order_date <= '01-31-2021'
group by s.customer_id,join_date,order_date,s.product_id,product_name)


--Step 3:
--Append records using UNION ALL on subquery. Want to include multiple orders placed on same day

select customer_id,sum(total_multiplier) as total_points
from 
(select w.customer_id,w.order_date,w.product_name,w.product_id,w.product_id,w.TOTAL_MULTIPLIER
from without_bonus w
union all
select b.customer_id,b.order_date,b.product_name,b.product_id,b.product_id,b.TOTAL_MULTIPLIER
from bonus b) total_bonus
group by customer_id
order by customer_id

--ANSWER 10:
--Customer A total points - 1370
--Customer B total points - 940






