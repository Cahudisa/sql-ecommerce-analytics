-- Silver layer: cleaned order payments
-- One row per payment within an order (an order can be paid with several methods,
-- identified by payment_sequential).

SELECT
    order_id,
    payment_sequential,
    LOWER(TRIM(payment_type))               AS payment_type,
    CAST(payment_installments AS int)       AS payment_installments,
    CAST(payment_value AS numeric(10,2))    AS payment_value
FROM {{ source('raw', 'order_payments') }}
WHERE order_id IS NOT NULL
