-- =============================================================================
-- 01 | Seller delivery performance
-- =============================================================================
-- QUESTION: Which sellers have the worst late-delivery rates?
--
-- Sellers live at the ITEM grain (one order can involve several sellers),
-- so we first build distinct (order, seller) pairs, then join delivery data.
--
-- TECHNIQUES: multi-join at the right grain, conditional aggregation with
-- FILTER, HAVING to remove low-volume noise.
--
-- Run against: local PostgreSQL (schemas created by dbt)
-- =============================================================================

WITH order_seller AS (

    -- One row per (order, seller): a seller participates in an order once,
    -- no matter how many items they sold in it
    SELECT DISTINCT
        i.order_id,
        i.seller_id
    FROM analytics_staging.stg_order_items i

),

seller_orders AS (

    SELECT
        os.seller_id,
        f.is_late,
        f.delivery_days,
        f.total_order_value
    FROM order_seller os
    JOIN analytics_marts.fct_orders f USING (order_id)
    WHERE f.delivered_at IS NOT NULL

)

SELECT
    s.seller_id,
    sl.seller_city,
    sl.seller_state,
    COUNT(*)                                                       AS delivered_orders,
    COUNT(*) FILTER (WHERE s.is_late)                              AS late_orders,
    ROUND(100.0 * COUNT(*) FILTER (WHERE s.is_late) / COUNT(*), 2) AS late_pct,
    ROUND(AVG(s.delivery_days), 1)                                 AS avg_delivery_days
FROM seller_orders s
JOIN analytics_staging.stg_sellers sl USING (seller_id)
GROUP BY s.seller_id, sl.seller_city, sl.seller_state
HAVING COUNT(*) >= 50          -- only sellers with meaningful volume
ORDER BY late_pct DESC
LIMIT 20;
