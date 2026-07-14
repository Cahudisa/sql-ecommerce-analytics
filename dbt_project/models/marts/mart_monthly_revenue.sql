-- Gold layer: monthly revenue KPIs
-- One row per month: revenue, orders, customers, AOV, and MoM growth.

WITH monthly AS (

    SELECT
        purchase_month,
        COUNT(*)                          AS total_orders,
        COUNT(DISTINCT customer_unique_id) AS unique_customers,
        SUM(total_order_value)            AS revenue,
        AVG(total_order_value)            AS avg_order_value
    FROM {{ ref('fct_orders') }}
    GROUP BY purchase_month

)

SELECT
    purchase_month,
    total_orders,
    unique_customers,
    ROUND(revenue, 2)          AS revenue,
    ROUND(avg_order_value, 2)  AS avg_order_value,

    -- Revenue of the PREVIOUS month, brought into this row
    LAG(revenue) OVER (ORDER BY purchase_month)             AS prev_month_revenue,

    -- Month-over-month growth %
    ROUND(
        100.0 * (revenue - LAG(revenue) OVER (ORDER BY purchase_month))
              / NULLIF(LAG(revenue) OVER (ORDER BY purchase_month), 0),
        1
    )                                                       AS revenue_mom_pct,

    -- Running total since the beginning
    SUM(revenue) OVER (ORDER BY purchase_month)             AS cumulative_revenue
FROM monthly
ORDER BY purchase_month