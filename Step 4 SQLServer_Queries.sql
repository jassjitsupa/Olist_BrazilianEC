-- TIME PERFORMANCE

-- 1) Average time from purchase to delivered (group by seller state)
SELECT seller_state, COUNT(*), ROUND(avg((DATEDIFF(second,order_purchase_timestamp, order_delivered_customer_date)/86400.0)), 2)
FROM order_items_all
GROUP BY seller_state;

-- 2) How long the process take if the seller is in SP (Sao Paulo)? (from purchase to delivered)
SELECT t.day_range,
        COUNT(t.seller_city) as count_city,
        COUNT(*) * 100.0 / SUM(COUNT(*)) OVER () AS percent_city, -- OVER() Determines the partitioning and ordering of a rowset before the associated window function is applied.
        STRING_AGG(t.seller_city, ', ') as city_names
FROM
(SELECT seller_city, AVG(DATEDIFF(day, order_purchase_timestamp, order_delivered_customer_date)) as AVG_timetodeliver, 
    CASE
        WHEN AVG(DATEDIFF(day, order_purchase_timestamp, order_delivered_customer_date)) < 1 THEN '<1 day'
        WHEN AVG(DATEDIFF(day, order_purchase_timestamp, order_delivered_customer_date)) BETWEEN 1 AND 2 THEN '1-2 days'
        WHEN AVG(DATEDIFF(day, order_purchase_timestamp, order_delivered_customer_date)) BETWEEN 2 AND 3 THEN '2-3 days'
        ELSE 'more than 3 days'
    END AS 'day_range'
FROM order_items_all
WHERE seller_state = 'SP'
GROUP BY seller_city) t
GROUP BY t.day_range
ORDER BY t.day_range;

-- 3) Waiting time for SP to SP vs SP to other states
SELECT seller_state, customer_state, ROUND(AVG(waiting_time), 2) AS num_days
FROM
(SELECT 
    seller_state,
    CASE
    WHEN customer_state <> 'SP' THEN 'Other states'
    ELSE 'to SP'
    END AS customer_state,
    ROUND(AVG(DATEDIFF(second, order_purchase_timestamp, order_delivered_customer_date)/86400.0), 2) AS waiting_time
FROM dbo.order_items_all
WHERE seller_state = 'SP'
GROUP BY seller_state, customer_state) t
GROUP BY seller_state, customer_state;

-- 4) How many hours most customers waited for their purchase to be approved (how many hours)? (seller response time)
SELECT hour_time_range, COUNT(customer_unique_id) AS count_customer, COUNT(*) * 100.0 / SUM(COUNT(*)) OVER () AS percent_customer
FROM 
(SELECT customer_unique_id, 
        AVG(DATEDIFF(minute, order_purchase_timestamp, order_approved_at)) AS avg_wait_time_min,
        CASE
            WHEN AVG(DATEDIFF(minute, order_purchase_timestamp, order_approved_at)) <= 59 THEN 'less than 1 hr'
            WHEN AVG(DATEDIFF(minute, order_purchase_timestamp, order_approved_at)) BETWEEN 60 AND 180 THEN '1-3 hrs'
            WHEN AVG(DATEDIFF(minute, order_purchase_timestamp, order_approved_at)) BETWEEN 180 AND 360 THEN '3-6 hrs'
            WHEN AVG(DATEDIFF(minute, order_purchase_timestamp, order_approved_at)) BETWEEN 360 AND 720 THEN '6-12 hrs'
            WHEN AVG(DATEDIFF(minute, order_purchase_timestamp, order_approved_at)) BETWEEN 720 AND 1440 THEN '12-24 hrs'
            WHEN AVG(DATEDIFF(minute, order_purchase_timestamp, order_approved_at)) BETWEEN 1440 AND 2880 THEN '1-2 days'
            WHEN AVG(DATEDIFF(minute, order_purchase_timestamp, order_approved_at)) >= 2880 THEN 'more than 2 days'
        END AS hour_time_range,
        CASE -- for grouping
            WHEN AVG(DATEDIFF(minute, order_purchase_timestamp, order_approved_at)) <= 59 THEN 1
            WHEN AVG(DATEDIFF(minute, order_purchase_timestamp, order_approved_at)) BETWEEN 60 AND 180 THEN 2
            WHEN AVG(DATEDIFF(minute, order_purchase_timestamp, order_approved_at)) BETWEEN 180 AND 360 THEN 3
            WHEN AVG(DATEDIFF(minute, order_purchase_timestamp, order_approved_at)) BETWEEN 360 AND 720 THEN 4
            WHEN AVG(DATEDIFF(minute, order_purchase_timestamp, order_approved_at)) BETWEEN 720 AND 1440 THEN 5
            WHEN AVG(DATEDIFF(minute, order_purchase_timestamp, order_approved_at)) BETWEEN 1440 AND 2880 THEN 6
            WHEN AVG(DATEDIFF(minute, order_purchase_timestamp, order_approved_at)) >= 2880 THEN 7
        END AS num_grouping
FROM order_items_all
GROUP BY customer_unique_id) t
WHERE hour_time_range IS NOT NULL
GROUP BY num_grouping, hour_time_range
ORDER BY num_grouping;

-- 5) Count number of orders that are delivered after expected delivery date
SELECT late_orders, total_orders, FORMAT(late_orders/total_orders, 'P') AS percent_late_orders
FROM(
SELECT count(distinct order_id) as total_orders, count(late_order) AS late_orders
FROM
(SELECT order_id,
        CASE
        WHEN order_estimated_delivery_date < order_delivered_customer_date THEN 'yes'
        ELSE NULL
        END AS late_order,
        ROW_NUMBER () OVER (PARTITION BY order_id ORDER BY order_id) AS dup_order
FROM dbo.order_items_all) t
WHERE dup_order = 1) tt;

-- 6) How many days most customer have to wait for their order to be delivered after it is approved?
SELECT hour_time_range, COUNT(customer_unique_id) AS count_customer, COUNT(*) * 100.0 / SUM(COUNT(*)) OVER () AS percent_customer
FROM 
(SELECT customer_unique_id, 
        AVG(DATEDIFF(minute, order_approved_at, order_delivered_customer_date)) AS avg_delivery_time_min,
        CASE
            WHEN AVG(DATEDIFF(minute, order_approved_at, order_delivered_customer_date)) <= 1440 THEN 'less than 1 day'
            WHEN AVG(DATEDIFF(minute, order_approved_at, order_delivered_customer_date)) BETWEEN 1440 AND 2880 THEN '1-2 days'
            WHEN AVG(DATEDIFF(minute, order_approved_at, order_delivered_customer_date)) BETWEEN 2880 AND 4320 THEN '2-3 days'
            WHEN AVG(DATEDIFF(minute, order_approved_at, order_delivered_customer_date)) >= 4320 THEN 'more than 3 days'

        END AS hour_time_range,
        CASE -- for grouping
            WHEN AVG(DATEDIFF(minute, order_approved_at, order_delivered_customer_date)) <= 1440 THEN 1
            WHEN AVG(DATEDIFF(minute, order_approved_at, order_delivered_customer_date)) BETWEEN 1440 AND 2880 THEN 2
            WHEN AVG(DATEDIFF(minute, order_approved_at, order_delivered_customer_date)) BETWEEN 2880 AND 4320 THEN 3
            WHEN AVG(DATEDIFF(minute, order_approved_at, order_delivered_customer_date)) >= 4320 THEN 4
        END AS num_grouping
FROM order_items_all
GROUP BY customer_unique_id) t
WHERE hour_time_range IS NOT NULL
GROUP BY num_grouping, hour_time_range
ORDER BY num_grouping;

-- PRODUCT PERFORMANCE

-- 7) Product ranking per month
SELECT  DATEPART(year, order_purchase_timestamp) AS purchase_year, 
        DATEPART(month, order_purchase_timestamp) AS purchase_month, 
        product_id,
        product_category_name, 
        count(*) AS prod_count,
        ROW_NUMBER() OVER (PARTITION BY DATEPART(year, order_purchase_timestamp), DATEPART(month, order_purchase_timestamp) ORDER BY count(*) DESC) As Ranking
FROM dbo.order_items_all
GROUP BY DATEPART(year, order_purchase_timestamp), DATEPART(month, order_purchase_timestamp), product_id, product_category_name
ORDER BY DATEPART(year, order_purchase_timestamp), DATEPART(month, order_purchase_timestamp), count(*) DESC;

-- 8) Three most purchased products per month
SELECT purchase_year, purchase_month, STRING_AGG(product_category_name, ', ') AS prod_names
FROM
(
SELECT  DATEPART(year, order_purchase_timestamp) AS purchase_year, 
        DATEPART(month, order_purchase_timestamp) AS purchase_month, 
        product_id,
        product_category_name, 
        count(*) AS prod_count,
        ROW_NUMBER() OVER (PARTITION BY DATEPART(year, order_purchase_timestamp), DATEPART(month, order_purchase_timestamp) ORDER BY count(*) DESC) As Ranking
FROM dbo.order_items_all
GROUP BY DATEPART(year, order_purchase_timestamp), DATEPART(month, order_purchase_timestamp), product_id, product_category_name
) t
WHERE RANKING <= 3
GROUP BY purchase_year, purchase_month
ORDER BY purchase_year, purchase_month;

-- 9) Monthly sales changes in Rio de Janeiro
SELECT seller_state,
        purchase_year,
        total_sales,
        LAG(total_sales, 1, 0) OVER (PARTITION BY seller_state ORDER BY purchase_year, purchase_month) AS previous_month_sales,
        total_sales - LAG(total_sales, 1, 0) OVER (PARTITION BY seller_state ORDER BY purchase_year, purchase_month) AS sales_change
FROM(
SELECT seller_state, 
        DATEPART(year, order_purchase_timestamp) AS purchase_year, 
        DATEPART(month, order_purchase_timestamp) AS purchase_month,
        sum(price) AS total_sales
FROM dbo.order_items_all
GROUP BY seller_state, DATEPART(year, order_purchase_timestamp), DATEPART(month, order_purchase_timestamp)) t;

-- PURCHASE BEHAVIOR

-- 10) Most popular day of purchase
SELECT dow, num_times
FROM(
SELECT DATEPART(weekday, order_purchase_timestamp) AS dow_num, DATENAME(weekday, order_purchase_timestamp) AS dow, COUNT(*) AS num_times
FROM dbo.order_items_all
GROUP BY DATEPART(weekday, order_purchase_timestamp), DATENAME(weekday, order_purchase_timestamp)
)t
ORDER BY num_times DESC;

-- 11) Most popular purchase time of day 
SELECT hour_of_day = 
    CASE DATEPART(HOUR, order_purchase_timestamp)
    WHEN 0 THEN  '12AM'
    WHEN 1 THEN   '1AM'
    WHEN 2 THEN   '2AM'
    WHEN 3 THEN   '3AM'
    WHEN 4 THEN   '4AM'
    WHEN 5 THEN   '5AM'
    WHEN 6 THEN   '6AM'
    WHEN 7 THEN   '7AM'
    WHEN 8 THEN   '8AM'
    WHEN 9 THEN   '9AM'
    WHEN 10 THEN '10AM'
    WHEN 11 THEN '11AM'
    WHEN 12 THEN '12PM'
    WHEN 13 THEN  '1PM'
    WHEN 14 THEN   '2PM'
    WHEN 15 THEN   '3PM'
    WHEN 16 THEN   '4PM'
    WHEN 17 THEN   '5PM'
    WHEN 18 THEN   '6PM'
    WHEN 19 THEN   '7PM'
    WHEN 20 THEN   '8PM'
    WHEN 21 THEN   '9PM'
    WHEN 22 THEN   '10PM'
    WHEN 23 THEN '11PAM'
    ELSE NULL
    END,
    COUNT(distinct order_id) as num_orders
FROM dbo.order_items_all
GROUP BY DATEPART(HOUR, order_purchase_timestamp)
ORDER BY COUNT(distinct order_id) DESC

-- 12) Payment methods that are used the most
SELECT payment_type, COUNT(*) AS num_times, ROUND(sum(payment_value), 2) AS total_amount
FROM dbo.order_items_all
GROUP  BY payment_type
HAVING payment_type IS NOT NULL
ORDER BY COUNT(*) DESC;

-- CUSTOMER CHURN

-- 13) Number of customer who reordered the same category in a different order
-- first create a table of first_time order
SELECT * INTO first_orders
FROM
(
SELECT customer_unique_id, order_id, product_category_name,
    ROW_NUMBER() OVER (PARTITION BY customer_unique_id, product_category_name ORDER BY customer_unique_id, product_category_name) AS order_record
FROM dbo.order_items_all) t
WHERE order_record = 1

-- then get a list of products that this customer used to order before
-- then count distinct customer_unique_id
SELECT count(distinct customer_unique_id)
FROM
(SELECT customer_unique_id,
        order_id,
        product_category_name
FROM dbo.order_items_all
WHERE 
customer_unique_id IN (SELECT customer_unique_id FROM first_orders)
AND
order_id NOT IN (SELECT order_id FROM first_orders)
AND
product_category_name IN (SELECT product_category_name FROM first_orders)) t;

-- 14) How many more items of the same category was ordered by each customer
SELECT customer_unique_id, product_category_name, COUNT(*) AS num_items
FROM
(SELECT customer_unique_id,
        order_id,
        product_category_name
FROM dbo.order_items_all
WHERE 
customer_unique_id IN (SELECT customer_unique_id FROM first_orders)
AND
order_id NOT IN (SELECT order_id FROM first_orders)
AND
product_category_name IN (SELECT product_category_name FROM first_orders)) t
GROUP BY customer_unique_id, product_category_name
ORDER BY COUNT(*) DESC

-- OTHERS

-- 15) Sellers/Customers are from which city the most
SELECT TOP 5 seller_city, count(distinct seller_id) AS num_sellers, COUNT(*) * 100.0 / SUM(COUNT(*)) OVER() AS percent_seller_city
FROM dbo.order_items_all
GROUP BY seller_city
ORDER BY count(distinct seller_id) DESC;
SELECT TOP 5 customer_city_upper, count(distinct customer_unique_id) AS num_customers, COUNT(*) * 100.0 / SUM(COUNT(*)) OVER() AS percent_customer_city
FROM dbo.order_items_all
GROUP BY customer_city_upper
ORDER BY num_customers DESC

-- 16) Select all products related to 'game'
SELECT distinct product_category_name
FROM dbo.order_items_all
WHERE product_category_name LIKE '%game%'

-- 17) Percentile ranking for sellers in Rio de Janeiro (using CUME_DIST)
SELECT t.seller_state, t.seller_id, t.total_sales,
        CUME_DIST() OVER (PARTITION BY seller_state ORDER BY total_sales) AS percentile_rank
FROM (
    SELECT seller_state, seller_id, sum(price) AS total_sales
    FROM dbo.order_items_all
    WHERE seller_state = 'RJ'
    GROUP BY seller_state, seller_id
) t
ORDER BY seller_state, total_sales DESC;

-- 18) Highest freight costs ever costed for each product category
SELECT product_category_name, MAX(freight_value)
FROM  order_items_all
GROUP BY product_category_name
ORDER BY MAX(freight_value) DESC;



