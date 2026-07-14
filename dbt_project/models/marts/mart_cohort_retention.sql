-- Gold layer: monthly cohort retention
-- Cohort = month of a customer's FIRST purchase (by customer_unique_id, the real person).
-- One row per (cohort_month, months_since_first) with retention percentage.
-- FINDING: Olist behaves as a one-time purchase marketplace — monthly retention
-- never exceeds ~0.5%.

WITH first_purchase AS (

    -- Each person's cohort: the month of their first delivered order
    SELECT
        customer_unique_id,
        MIN(purchase_month) AS cohort_month
    FROM {{ ref('fct_orders') }}
    GROUP BY customer_unique_id

),

orders_with_cohort AS (

    -- Every order, tagged with its owner's cohort and the month offset
    SELECT
        f.customer_unique_id,
        fp.cohort_month,
        (
            EXTRACT(YEAR  FROM AGE(f.purchase_month, fp.cohort_month)) * 12
          + EXTRACT(MONTH FROM AGE(f.purchase_month, fp.cohort_month))
        )::int AS months_since_first
    FROM {{ ref('fct_orders') }} f
    JOIN first_purchase fp USING (customer_unique_id)

),

cohort_activity AS (

    -- How many distinct people from each cohort were active at each offset
    SELECT
        cohort_month,
        months_since_first,
        COUNT(DISTINCT customer_unique_id) AS active_customers
    FROM orders_with_cohort
    GROUP BY cohort_month, months_since_first

)

SELECT
    cohort_month,
    months_since_first,
    active_customers,

    -- Cohort size = active customers at month 0, spread to all rows via window
    FIRST_VALUE(active_customers) OVER (
        PARTITION BY cohort_month
        ORDER BY months_since_first
    ) AS cohort_size,

    ROUND(
        100.0 * active_customers
              / FIRST_VALUE(active_customers) OVER (
                    PARTITION BY cohort_month
                    ORDER BY months_since_first
                ),
        2
    ) AS retention_pct
FROM cohort_activity
ORDER BY cohort_month, months_since_first
