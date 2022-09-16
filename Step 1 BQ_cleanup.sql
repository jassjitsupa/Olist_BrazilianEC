-- Below queries are for Google BigQuery to clean up some tables before using it in SQL Server

-- 1 clean up table 'geolocation'

-- Using INITCAP to make each word start in Uppercase for column 'geolocation_city'
-- input city in uppercases in city_upper column that we created
UPDATE `brazilEC_dataset.geolocation`
SET city_upper = REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(INITCAP(geolocation_city), ' Do ', ' do '), ' De ', ' de '), ' Dos ', ' dos '), ' Das ', ' das '), ' Da ', ' da ')
WHERE geolocation_city IS NOT NULL;

-- then drop 'geolocation_city' column
ALTER TABLE `brazilEC_dataset.geolocation`
DROP COLUMN geolocation_city;

-- then change the column name 'city_upper' to 'geo_city_upper' in 'Schema' menu
-- have to click on 'MORE' so that you can choose to overwrite your existing 'geolocation' table
SELECT * EXCEPT(city_upper), city_upper AS geo_city_upper
FROM `brazilEC_dataset.geolocation`

-- TRY SOME QUERIES: Using SUBSTR to see only cities starting with specific characters & HAVING
-- Using CHAR_LENGTH to order by the shortest city name to the longest
SELECT geo_city_upper
FROM `brazilEC_dataset.geolocation`
GROUP BY geo_city_upper
HAVING SUBSTR(geo_city_upper, 1, 3) = 'Ita'
ORDER BY CHAR_LENGTH(geo_city_upper) ASC
LIMIT 100;

-- TRY SOME QUERIES: Query cities by first two digits of zip code
-- use CAST to change datatype
SELECT geolocation_zip_code_prefix, COUNT(geolocation_zip_code_prefix), geo_city_upper
FROM `brazilEC_dataset.geolocation`
WHERE LEFT(CAST (geolocation_zip_code_prefix AS STRING), 2) = "46"
GROUP BY 1, 3;

-- 2 clean up table 'customers'

-- Using INITCAP to make each word start in Uppercase for column 'customer_city'
-- input city in uppercases in customer_city_upper column that we created
UPDATE `brazilEC_dataset.customers`
SET customer_city_upper = REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(INITCAP(customer_city), ' Do ', ' do '), ' De ', ' de '), ' Dos ', ' dos '), ' Das ', ' das '), ' Da ', ' da ')
WHERE customer_city IS NOT NULL;

-- then drop 'customer_city' column
ALTER TABLE `brazilEC_dataset.customers`
DROP COLUMN customer_city;

-- 3 clean up 'products table'

-- rearrange column orders, while dropping columns that we won't use
CREATE OR REPLACE TABLE `brazilEC_dataset.products` AS
SELECT product_id, product_category_name FROM `brazilEC_dataset.products`;

-- change only the first character in the cell in uppercase
-- input city in uppercases in pr column that we created
UPDATE `brazilEC_dataset.products`
SET product_category_name = CONCAT(UPPER(SUBSTR(product_category_name, 1, 1)), SUBSTR(REPLACE(product_category_name, '_', ' '), 2))
WHERE product_category_name IS NOT NULL;

-- 4 clean up order_payments

--remove _ from payment type
UPDATE `brazilEC_dataset.order_payments`
SET payment_type = REPLACE(payment_type, '_', ' ')
WHERE payment_type IS NOT NULL;

-- Using INITCAP to make each word start in Uppercase for column 'payment_type'
UPDATE `brazilEC_dataset.order_payments`
SET payment_type = INITCAP(payment_type)
WHERE payment_type IS NOT NULL;

-- 5 clean up sellers
UPDATE `brazilEC_dataset.sellers`
SET seller_city = REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(INITCAP(seller_city), ' Do ', ' do '), ' De ', ' de '), ' Dos ', ' dos '), ' Das ', ' das '), ' Da ', ' da ')
WHERE seller_city IS NOT NULL;





