-- Gold layer: delivery performance by customer state
-- One row per state: volume, late-delivery rate and delivery speed stats.
-- Only orders with a real delivery date are considered (a handful of
-- 'delivered' orders have NULL delivered_at in the raw data).

WITH delivered AS (

    SELECT
        customer_state,
        is_late,
        delivery_days,
        total_order_value
    FROM {{ ref('fct_orders') }}
    WHERE delivered_at IS NOT NULL

)

SELECT
    customer_state,
    COUNT(*)                                            AS total_orders,
    ROUND(SUM(total_order_value), 2)                    AS revenue,

    -- Conditional aggregation: count only the late ones
    COUNT(*) FILTER (WHERE is_late)                     AS late_orders,
    ROUND(100.0 * COUNT(*) FILTER (WHERE is_late) / COUNT(*), 2) AS late_pct,

    ROUND(AVG(delivery_days), 1)                        AS avg_delivery_days,
    PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY delivery_days) AS median_delivery_days,
    MAX(delivery_days)                                  AS max_delivery_days
FROM delivered
GROUP BY customer_state
ORDER BY late_pct DESC
