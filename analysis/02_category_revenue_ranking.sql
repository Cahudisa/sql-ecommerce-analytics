-- =============================================================================
-- 02 | Category revenue ranking + Pareto analysis
-- =============================================================================
-- QUESTION: Which product categories drive revenue, and how concentrated is it?
-- (Do ~20% of categories generate ~80% of revenue?)
--
-- TECHNIQUES: LEFT JOIN with COALESCE for missing categories/translations,
-- DENSE_RANK, and a cumulative-share window (running SUM / total SUM).
-- =============================================================================

WITH category_revenue AS (

    SELECT
        COALESCE(
            t.product_category_name_english,
            p.product_category_name,
            'uncategorized'
        )                        AS category,
        SUM(i.price)             AS revenue,
        COUNT(DISTINCT i.order_id) AS orders
    FROM analytics_staging.stg_order_items i
    JOIN analytics_marts.fct_orders f USING (order_id)   -- delivered orders only
    LEFT JOIN analytics_staging.stg_products p USING (product_id)
    LEFT JOIN analytics_staging.stg_product_category_translation t
           ON p.product_category_name = t.product_category_name
    GROUP BY 1

)

SELECT
    DENSE_RANK() OVER (ORDER BY revenue DESC)                    AS revenue_rank,
    category,
    orders,
    ROUND(revenue, 2)                                            AS revenue,
    ROUND(100.0 * revenue / SUM(revenue) OVER (), 2)             AS revenue_share_pct,

    -- Cumulative share: how much of total revenue the top-N categories cover
    ROUND(
        100.0 * SUM(revenue) OVER (ORDER BY revenue DESC)
              / SUM(revenue) OVER (),
        2
    )                                                            AS cumulative_share_pct
FROM category_revenue
ORDER BY revenue DESC
LIMIT 20;
