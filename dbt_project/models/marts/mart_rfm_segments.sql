-- Gold layer: RFM customer segmentation
-- One row per customer (customer_unique_id) with R/F/M scores (1-5 via NTILE)
-- and a business-friendly segment label.
-- Reference date = latest purchase in the dataset (static snapshot).
-- NOTE: frequency is ~1 for most customers (one-time marketplace), so
-- high-frequency segments (Champions/Loyal) are expectedly small.

WITH reference_date AS (

    SELECT MAX(purchased_at) AS max_date
    FROM {{ ref('fct_orders') }}

),

customer_metrics AS (

    SELECT
        f.customer_unique_id,
        EXTRACT(DAY FROM r.max_date - MAX(f.purchased_at))::int AS recency_days,
        COUNT(*)                                                AS frequency,
        SUM(f.total_order_value)                                AS monetary
    FROM {{ ref('fct_orders') }} f
    CROSS JOIN reference_date r
    GROUP BY f.customer_unique_id, r.max_date

),

scored AS (

    SELECT
        customer_unique_id,
        recency_days,
        frequency,
        monetary,
        -- Recency: FEWER days = better = higher score, hence ORDER BY ... DESC
        NTILE(5) OVER (ORDER BY recency_days DESC) AS r_score,
        -- Frequency & monetary: more = better
        NTILE(5) OVER (ORDER BY frequency ASC)     AS f_score,
        NTILE(5) OVER (ORDER BY monetary ASC)      AS m_score
    FROM customer_metrics

)

SELECT
    customer_unique_id,
    recency_days,
    frequency,
    ROUND(monetary, 2) AS monetary,
    r_score,
    f_score,
    m_score,
    CASE
        WHEN r_score >= 4 AND f_score >= 4 THEN 'Champions'
        WHEN r_score >= 3 AND f_score >= 3 THEN 'Loyal Customers'
        WHEN r_score >= 4 AND f_score <= 2 THEN 'Recent Customers'
        WHEN r_score <= 2 AND f_score >= 3 THEN 'At Risk'
        WHEN r_score <= 2 AND f_score <= 2 AND m_score >= 4 THEN 'Big Spenders Lost'
        WHEN r_score <= 1 THEN 'Lost'
        ELSE 'Regular'
    END AS rfm_segment
FROM scored
