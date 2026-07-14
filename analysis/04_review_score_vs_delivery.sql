-- =============================================================================
-- 04 | Does late delivery destroy review scores?
-- =============================================================================
-- QUESTION: Quantify the relationship between delivery performance and
-- customer satisfaction.
--
-- Part A: on-time vs late — average score and 1-star share.
-- Part B: score by delivery-speed bucket (CASE-based binning).
--
-- TECHNIQUES: CASE bucketing, conditional aggregation, joining fact + reviews.
-- =============================================================================

-- ---------- Part A: on-time vs late ----------
SELECT
    CASE WHEN f.is_late THEN 'Late' ELSE 'On time' END          AS delivery_status,
    COUNT(*)                                                    AS reviews,
    ROUND(AVG(r.review_score), 2)                               AS avg_score,
    ROUND(100.0 * COUNT(*) FILTER (WHERE r.review_score = 1)
                / COUNT(*), 2)                                  AS one_star_pct,
    ROUND(100.0 * COUNT(*) FILTER (WHERE r.review_score = 5)
                / COUNT(*), 2)                                  AS five_star_pct
FROM analytics_marts.fct_orders f
JOIN analytics_staging.stg_order_reviews r USING (order_id)
WHERE f.delivered_at IS NOT NULL
GROUP BY 1
ORDER BY 1;

-- ---------- Part B: score by delivery speed ----------
SELECT
    CASE
        WHEN f.delivery_days <= 7  THEN '01) Up to 1 week'
        WHEN f.delivery_days <= 14 THEN '02) 1-2 weeks'
        WHEN f.delivery_days <= 21 THEN '03) 2-3 weeks'
        WHEN f.delivery_days <= 30 THEN '04) 3-4 weeks'
        ELSE                            '05) Over a month'
    END                                                         AS delivery_bucket,
    COUNT(*)                                                    AS reviews,
    ROUND(AVG(r.review_score), 2)                               AS avg_score
FROM analytics_marts.fct_orders f
JOIN analytics_staging.stg_order_reviews r USING (order_id)
WHERE f.delivered_at IS NOT NULL
GROUP BY 1
ORDER BY 1;
