-- below queries are for Google BiqQuery (get only unique location in geolocation table and export cleaned tables to Google Storage then to local files)


-- using ROW_NUMBER and PARTITION BY to get only unique zipcode 
-- then save as a new BigQuery table 'unique_locationzip'
SELECT *
FROM (
  SELECT
        ROW_NUMBER() OVER (PARTITION BY geolocation_zip_code_prefix) row_number,
        *
  FROM `brazilEC_dataset.geolocation`
)
WHERE row_number = 1;

-- check if there are duplicate product IDs in products
SELECT COUNT(*), COUNT (DISTINCT product_id)
FROM `brazilEC_dataset.products`;


-- 1 exporting cleaned tables
--customers

EXPORT DATA
  OPTIONS (
    uri = 'gs://brazil_cleandata/customers.csv',
    format = 'CSV',
    overwrite = true,
    header = true,
    field_delimiter = ';')
AS (
  SELECT *
  FROM `brazilEC_dataset.customers`
);

--geolocation

EXPORT DATA
  OPTIONS (
    uri = 'gs://brazil_cleandata/geolocation*.csv',
    format = 'CSV',
    overwrite = true,
    header = true,
    field_delimiter = ';')
AS (
  SELECT *
  FROM `brazilEC_dataset.geolocation`
);

--order_payments

EXPORT DATA
  OPTIONS (
    uri = 'gs://brazil_cleandata/order_payments*.csv',
    format = 'CSV',
    overwrite = true,
    header = true,
    field_delimiter = ';')
AS (
  SELECT *
  FROM `brazilEC_dataset.order_payments`
);

--products

EXPORT DATA
  OPTIONS (
    uri = 'gs://brazil_cleandata/products*.csv',
    format = 'CSV',
    overwrite = true,
    header = true,
    field_delimiter = ';')
AS (
  SELECT *
  FROM `brazilEC_dataset.products`
);

--sellers

EXPORT DATA
  OPTIONS (
    uri = 'gs://brazil_cleandata/sellers*.csv',
    format = 'CSV',
    overwrite = true,
    header = true,
    field_delimiter = ';')
AS (
  SELECT *
  FROM `brazilEC_dataset.sellers`
);

--unique_locationzip

EXPORT DATA
  OPTIONS (
    uri = 'gs://brazil_cleandata/unique_locationzip*.csv',
    format = 'CSV',
    overwrite = true,
    header = true,
    field_delimiter = ';')
AS (
  SELECT *
  FROM `brazilEC_dataset.unique_locationzip`
);

