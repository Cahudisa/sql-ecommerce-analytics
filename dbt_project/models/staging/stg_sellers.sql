-- Silver layer: cleaned sellers
-- One row per seller. Standardizes city/state casing.

SELECT
    seller_id,
    seller_zip_code_prefix,
    INITCAP(TRIM(seller_city))  AS seller_city,
    UPPER(TRIM(seller_state))   AS seller_state
FROM {{ source('raw', 'sellers') }}
WHERE seller_id IS NOT NULL
