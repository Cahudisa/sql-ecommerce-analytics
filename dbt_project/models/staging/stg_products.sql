-- Silver layer: cleaned products
-- One row per product. Casts measurements to integers.
-- NOTE: ~610 products have NULL category — kept on purpose; handled downstream in Gold.

SELECT
    product_id,
    product_category_name,
    CAST(product_photos_qty AS int)  AS product_photos_qty,
    CAST(product_weight_g   AS int)  AS product_weight_g,
    CAST(product_length_cm  AS int)  AS product_length_cm,
    CAST(product_height_cm  AS int)  AS product_height_cm,
    CAST(product_width_cm   AS int)  AS product_width_cm
FROM {{ source('raw', 'products') }}
WHERE product_id IS NOT NULL
