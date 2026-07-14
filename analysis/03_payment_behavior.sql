-- =============================================================================
-- 03 | Payment behavior
-- =============================================================================
-- QUESTION: How do Brazilians pay online? Share, ticket size and installment
-- culture per payment method.
--
-- Brazil context: installments ("parcelas") are a defining feature of its
-- e-commerce — this query quantifies it.
--
-- TECHNIQUES: share-of-total via window SUM, per-group averages.
-- =============================================================================

SELECT
    p.payment_type,
    COUNT(*)                                                  AS payments,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 2)        AS payment_share_pct,
    ROUND(SUM(p.payment_value), 2)                            AS total_value,
    ROUND(AVG(p.payment_value), 2)                            AS avg_payment_value,
    ROUND(AVG(p.payment_installments), 1)                     AS avg_installments,
    MAX(p.payment_installments)                               AS max_installments
FROM analytics_staging.stg_order_payments p
JOIN analytics_marts.fct_orders f USING (order_id)   -- delivered orders only
GROUP BY p.payment_type
ORDER BY payments DESC;
