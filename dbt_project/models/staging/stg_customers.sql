-- Silver layer: cleaned customers
-- One row per customer-order pairing. customer_unique_id identifies the real person
-- (one person with N orders has N customer_ids but a single customer_unique_id).

SELECT
    customer_id,
    customer_unique_id,
    customer_zip_code_prefix,
    INITCAP(TRIM(customer_city))  AS customer_city,
    UPPER(TRIM(customer_state))   AS customer_state
FROM {{ source('raw', 'customers') }}
WHERE customer_id IS NOT NULL
