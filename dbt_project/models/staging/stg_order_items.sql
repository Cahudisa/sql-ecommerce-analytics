-- Silver layer: cleaned order items
-- One row per item within an order. Casts dates and monetary values.

SELECT
    order_id,
    order_item_id,
    product_id,
    seller_id,
    CAST(shipping_limit_date AS timestamp)      AS shipping_limit_at,
    CAST(price               AS numeric(10,2))  AS price,
    CAST(freight_value       AS numeric(10,2))  AS freight_value
FROM {{ source('raw', 'order_items') }}
WHERE order_id IS NOT NULL
