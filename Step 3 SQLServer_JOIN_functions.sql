-- JOIN orders_items & products & orders & customers & sellers & payments
WITH temp AS (
    SELECT 
    oi.order_id, -- oi
    order_item_id, -- oi
    oi.product_id, -- oi
    product_category_name, -- pr
    oi.seller_id, -- oi
    shipping_limit_date, -- oi 
    price, -- oi
    freight_value, -- oi
    o.customer_id, -- o
    order_status, -- o
    order_purchase_timestamp, -- o
    order_approved_at, -- o
    order_delivered_carrier_date -- o
    order_delivered_customer_date, -- o
    order_estimated_delivery_date, -- o
    customer_unique_id, -- c
    customer_zip_code_prefix, -- c
    customer_city_upper, -- c
    customer_state, -- c
    seller_zip_code_prefix, -- s 
    seller_city, -- s
    seller_state, -- s
    payment_sequential, -- pa
    payment_type, -- pa
    payment_installments, -- pa
    payment_value -- pa
    FROM dbo.order_items oi 
    LEFT JOIN dbo.products pr -- join with products
        ON oi.product_id = pr.product_id
    LEFT JOIN dbo.orders o -- join with orders
        ON oi.order_id = o.order_id
    LEFT JOIN dbo.customers c -- join with customer
        ON o.customer_id = c.customer_id
    LEFT JOIN dbo.sellers s -- join with sellers
        ON oi.seller_id = s.seller_id
    LEFT JOIN dbo.payments pa -- join with payments
        ON oi.order_id = pa.order_id
    )
SELECT *
INTO order_items_all
FROM temp
