-- Silver layer: cleaned orders
-- One row per order. Casts timestamps, standardizes status casing.

SELECT
    order_id,
    customer_id,
    LOWER(TRIM(order_status))                       AS order_status,
    CAST(order_purchase_timestamp   AS timestamp)   AS purchased_at,
    CAST(order_approved_at          AS timestamp)   AS approved_at,
    CAST(order_delivered_carrier_date AS timestamp) AS delivered_to_carrier_at,
    CAST(order_delivered_customer_date AS timestamp) AS delivered_at,
    CAST(order_estimated_delivery_date AS timestamp) AS estimated_delivery_at
FROM {{ source('raw', 'orders') }}
WHERE order_id IS NOT NULL
