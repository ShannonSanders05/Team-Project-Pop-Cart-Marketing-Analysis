
 /*
 -------------------------------------------------------------------
 ________  ________  ________  ___  ___  ________        ________  
|\   ____\|\   __  \|\   __  \|\  \|\  \|\   __  \      |\_____  \ 
\ \  \___|\ \  \|\  \ \  \|\  \ \  \\\  \ \  \|\  \      \|___/  /|
 \ \  \  __\ \   _  _\ \  \\\  \ \  \\\  \ \   ____\         /  / /
  \ \  \|\  \ \  \\  \\ \  \\\  \ \  \\\  \ \  \___|        /  / / 
   \ \_______\ \__\\ _\\ \_______\ \_______\ \__\          /__/ /  
    \|_______|\|__|\|__|\|_______|\|_______|\|__|          |__|/   
                                                                   
Members:
-Shannon Sanders - Group Lead
-Ralph Vender Orprecio
-Cherrisse Joy Paggao
-Jareth Rodillo
-Ryan Neal Salapa
-Jeffrey Sulit***

-------------------------------------------------------------------
*/                                                                  
 
 
/*
-------------------------------------------------------------------
CREATING SALES DATA TABLE
-------------------------------------------------------------------
*/


CREATE TABLE
IF NOT EXISTS sales_data (
	session_id INTEGER,
	user_id INTEGER,
	product_category TEXT,
	region TEXT,
	is_campaign BOOLEAN,
	total_php NUMERIC

);

SELECT * FROM sales_data


/*
-------------------------------------------------------------------
CREATING MARKETING IMPRESSIONS TABLE
-------------------------------------------------------------------
*/


CREATE TABLE
IF NOT EXISTS marketing_impressions (
	session_id INTEGER,
	user_id INTEGER,
	campaign_id INTEGER,
	campaign_name TEXT,
	webpage_id NUMERIC,
	product_category TEXT,
	gender TEXT,
	age_level TEXT,
	region TEXT,
	is_click BOOLEAN

);

SELECT * FROM marketing_impressions


/*
-------------------------------------------------------------------
CLEANING DATA FOR SALES DATA TABLE
-------------------------------------------------------------------
*/


SELECT DISTINCT product_category FROM sales_data

SELECT DISTINCT region FROM sales_data

SELECT * FROM sales_data
order by session_id ASC

/*
-------------------------------------------------------------------
CLEANING DATA FOR MARKETING IMPRESSIONS TABLE
-------------------------------------------------------------------
*/



SELECT DISTINCT campaign_name FROM marketing_impressions

SELECT DISTINCT product_category FROM marketing_impressions

SELECT DISTINCT gender FROM marketing_impressions

SELECT DISTINCT age_level FROM marketing_impressions

SELECT DISTINCT region FROM marketing_impressions

SELECT user_id FROM marketing_impressions

SELECT * FROM marketing_impressions
order by session_id ASC


/*
-------------------------------------------------------------------
GOAL 1: CALCULATING OVERALL CTR
-------------------------------------------------------------------
*/


SELECT COUNT(*) AS total_impressions,
COUNT(CASE WHEN is_click IS TRUE THEN 1 END) AS total_clicks,
ROUND((SUM 
	(CASE
		WHEN is_click THEN 1
		ELSE 0
	END) / COUNT (campaign_name)::numeric)*100,2) AS overall_ctr
FROM marketing_impressions


/*
-------------------------------------------------------------------
GOAL 2: CALCULATING CTR FOR EACH PRODUCT CATEGORY 
-------------------------------------------------------------------
*/


SELECT product_category,
ROUND((SUM 
	(CASE
		WHEN is_click THEN 1
		ELSE 0
	END) / COUNT (campaign_name)::numeric)*100,2) AS ctr
FROM marketing_impressions
GROUP BY product_category


/*
-------------------------------------------------------------------
JOINING SALES DATA AND MARKETING IMPRESSIONS BY SESSION ID
-------------------------------------------------------------------
*/


SELECT 
sales_data.session_id,
sales_data.user_id,
sales_data.is_campaign,
marketing_impressions.is_click,
marketing_impressions.gender,
marketing_impressions.region,
marketing_impressions.campaign_id,
marketing_impressions.campaign_name,
marketing_impressions.product_category,
marketing_impressions.age_level,
marketing_impressions.product_category,
sales_data.total_php

FROM sales_data
INNER JOIN marketing_impressions
ON sales_data.session_id = marketing_impressions.session_id


/*
----------------------------------------------------------------------
GOAL 3: CALCULATING PERCENTAGE OF TOTAL REVENUE CONTRIBUTION BY GENDER
----------------------------------------------------------------------
*/


SELECT gender, 
	SUM(total_php) AS sum_total_php,
	ROUND(SUM(total_php) / (SELECT SUM(total_php) FROM marketing_impressions
INNER JOIN sales_data 
ON marketing_impressions.session_id = sales_data.session_id) * 100,2) AS total_percentage
FROM marketing_impressions
INNER JOIN sales_data
ON marketing_impressions.session_id = sales_data.session_id
GROUP BY gender


/*
-------------------------------------------------------------------
GOAL 4: CALCULATING THE CAMPAIGN WITH MOST IMPRESSIONS
-------------------------------------------------------------------
*/


SELECT campaign_name,COUNT(campaign_name) AS total_impressions 
FROM marketing_impressions
GROUP BY campaign_name
ORDER BY COUNT(campaign_name) DESC


/*
-------------------------------------------------------------------
GOAL 5: UNIQUE USERS PER LOCATION WITH MOST IMPRESSIONS
-------------------------------------------------------------------
*/


SELECT region,
COUNT (DISTINCT 
CASE
	WHEN campaign_name = '12 Days of Christmas Deals' THEN user_id
END) AS unique_users
FROM marketing_impressions
GROUP BY region


/*
-------------------------------------------------------------------
ADDITIONAL:

Popularity of product categories based on location, age groups,
and gender. 

Total impressions and CTR for each product category
per user segment.
-------------------------------------------------------------------
*/


SELECT product_category, gender, age_level, region,
COUNT(*) AS count_of_impressions,
SUM(
CASE
	WHEN is_click is true THEN 1
	ELSE 0
END) AS number_of_clicks,
ROUND((SUM(
CASE
	WHEN is_click is true THEN 1
	ELSE 0
END)/COUNT(*)::numeric)*100,2) AS ctr
FROM marketing_impressions 
GROUP BY product_category, age_level, region, gender
ORDER BY  number_of_clicks DESC;