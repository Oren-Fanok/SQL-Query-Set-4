--Query 1

DROP TABLE if EXISTS owner_year_month1;
CREATE TEMPORARY TABLE owner_year_month1 AS
SELECT card_no,
strftime('%Y', date) as 'year', 
strftime('%m', date) as 'month', 
sum(spend) as 'spend', 
sum(items) as 'items'
FROM owner_spend_date
GROUP BY card_no,year,month


--Query 2 

SELECT year, month, sum(spend) as total_spend
FROM owner_year_month1
GROUP BY year,month
ORDER BY total_spend DESC
LIMIT 5


--Query 3 

SELECT  
Round(avg(owner_year_month1.spend),2) as avg_monthly_spend,
owner_year_month1.month
FROM owner_year_month1
WHERE card_no in (SELECT card_no
				FROM owners
				WHERE zip = '55405')
GROUP BY owner_year_month1.month
ORDER BY month


--Query 4 

SELECT 
sum(owner_year_month1.spend) as ' total spend',
owners.zip
FROM owner_year_month1
JOIN owners ON owners.card_no = owner_year_month1.card_no
GROUP BY owners.zip
ORDER BY sum(owner_year_month1.spend) DESC
Limit 3


--Query 5 

With cte_55408 as(
SELECT  
Round(avg(owner_year_month1.spend),2) as avg_monthly_spend_55408,
owner_year_month1.month
FROM owner_year_month1
WHERE card_no in (SELECT card_no
				FROM owners
				WHERE zip = '55408')
GROUP BY owner_year_month1.month
ORDER BY month),

cte_55403 as(
SELECT  
Round(avg(owner_year_month1.spend),2) as avg_monthly_spend_55403,
owner_year_month1.month
FROM owner_year_month1
WHERE card_no in (SELECT card_no
				FROM owners
				WHERE zip = '55403')
GROUP BY owner_year_month1.month
ORDER BY month)

SELECT  
Round(avg(owner_year_month1.spend),2) as avg_monthly_spend_55405,
cte1.avg_monthly_spend_55408,
cte2.avg_monthly_spend_55403,
owner_year_month1.month
FROM owner_year_month1
JOIN cte_55408 as cte1 on cte1.month = owner_year_month1.month
JOIN cte_55403 as cte2 on cte2.month = owner_year_month1.month
WHERE card_no in (SELECT card_no
				FROM owners
				WHERE zip = '55405')
GROUP BY owner_year_month1.month
ORDER BY owner_year_month1.month


--Query 6 

CREATE TEMPORARY TABLE owner_year_month AS
WITH cte_total_sales AS
(SELECT sum(osp.spend) as total_spend,
card_no
FROM owner_spend_date as osp
GROUP by osp.card_no)
SELECT osp.card_no,
strftime('%Y', osp.date) as 'year', 
strftime('%m', osp.date) as 'month', 
sum(osp.spend) as 'spend', 
sum(osp.items) as 'items',
cte.total_spend
FROM owner_spend_date as osp
JOIN cte_total_sales as cte on cte.card_no = osp.card_no
GROUP BY osp.card_no,year,month

DROP TABLE if EXISTS owner_year_month;
--Result QUERY
SELECT COUNT(DISTINCT(card_no)) AS owners,
COUNT(DISTINCT(year)) AS years,
COUNT(DISTINCT(month)) AS months,
ROUND(AVG(spend),2) AS avg_spend,
ROUND(AVG(items),1) AS avg_items,
ROUND(SUM(spend)/SUM(items),2) AS avg_item_price
FROM owner_year_month


DROP TABLE if EXISTS owner_year_month;


--Query 7 

DROP VIEW IF  EXISTS vw_owner_recent;

CREATE VIEW vw_owner_recent AS
Select card_no,
Sum(spend) as total_spend,
sum(spend)/sum(trans)as avg_spend_per_transaction,
COUNT(DISTINCT date)as number_of_dates_shopped,
sum(trans)as total_trans,
max(date) as last_visit
FROM owner_spend_date
GROUP BY card_no

SELECT COUNT(DISTINCT card_no) AS owners, 
 ROUND(SUM(total_spend)/1000,1) AS spend_k
FROM vw_owner_recent
WHERE 5 < total_trans AND 
 total_trans < 25 AND
 SUBSTR(last_visit,1,4) IN ('2016','2017')
 
 
--Query 8 

DROP TABLE if EXISTS owner_recent;

CREATE TEMPORARY TABLE owner_recent AS
SELECT vw.card_no,
vw.total_spend,
vw.avg_spend_per_transaction,
vw.number_of_dates_shopped,
vw.total_trans,
vw.last_visit,
osp.spend as last_spend
FROM vw_owner_recent as vw
JOIN owner_spend_date as osp on osp.card_no = vw.card_no
and osp.date = vw.last_visit

-- Select a row from the table
SELECT *
FROM owner_recent 
WHERE card_no = "18736"; 

-- Select a row from the view
SELECT *
FROM vw_owner_recent
WHERE card_no = "18736";


-- Query 9 

SELECT 
or1.card_no,
or1.total_spend,
or1.avg_spend_per_transaction,
or1.number_of_dates_shopped,
or1.total_trans,
or1.last_visit,
or1.last_spend
FROM owner_recent as or1
WHERE last_spend < (avg_spend_per_transaction/2) 
and total_spend >= 5000
AND number_of_dates_shopped >= 270
AND last_visit <= '2016-12-02'
AND last_spend > 10
ORDER BY (avg_spend_per_transaction - last_spend) DESC, total_spend

select *
from owner_recent
WHERE number_of_dates_shopped > 100


-- Query 10 

SELECT 
or1.card_no,
or1.total_spend,
or1.avg_spend_per_transaction,
or1.number_of_dates_shopped,
or1.total_trans,
or1.last_visit,
or1.last_spend,
owners.zip as zip
FROM owner_recent as or1
JOIN owners on owners.card_no = or1.card_no
WHERE owners.zip != 55405
AND owners.zip != 55442
AND owners.zip != 55416
AND owners.zip != 55408
AND owners.zip != 55404
AND owners.zip != 55403
AND owners.zip != ' '
AND owners.zip IS NOT NULL
AND last_spend < (avg_spend_per_transaction/2) 
and total_spend >= 5000
AND number_of_dates_shopped >= 270
AND last_visit <= '2016-12-02'
AND last_spend > 10
ORDER BY (avg_spend_per_transaction - last_spend) DESC, total_spend











