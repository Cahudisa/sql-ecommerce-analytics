-- Silver layer: product category translation (Portuguese -> English)
-- Tiny lookup table used in Gold to report categories in English.

SELECT
    product_category_name,
    product_category_name_english
FROM {{ source('raw', 'product_category_translation') }}
WHERE product_category_name IS NOT NULL
