-- Gold layer: order fact table
-- One row per DELIVERED order, enriched with customer identity,
-- order value and delivery performance metrics.
-- All downstream marts (cohorts, RFM, delivery) build on this model.

WITH order_values AS (

    -- An order has N items: aggregate to order grain first
    SELECT
        order_id,
        SUM(price)          AS items_value,
        SUM(freight_value)  AS freight_value,
        COUNT(*)            AS items_count
    FROM {{ ref('stg_order_items') }}
    GROUP BY order_id

)

SELECT
    o.order_id,
    c.customer_unique_id,
    c.customer_state,
    o.purchased_at,
    DATE_TRUNC('month', o.purchased_at)  AS purchase_month,
    v.items_value,
    v.freight_value,
    v.items_value + v.freight_value      AS total_order_value,
    v.items_count,
    o.delivered_at,
    o.estimated_delivery_at,
    (o.delivered_at > o.estimated_delivery_at)                    AS is_late,
    EXTRACT(DAY FROM o.delivered_at - o.purchased_at)::int        AS delivery_days
FROM {{ ref('stg_orders') }} o
JOIN {{ ref('stg_customers') }} c  ON o.customer_id = c.customer_id
JOIN order_values v                ON o.order_id    = v.order_id
WHERE o.order_status = 'delivered'
  AND o.purchased_at IS NOT NULL
