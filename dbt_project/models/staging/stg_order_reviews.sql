-- Silver layer: cleaned + deduplicated order reviews
--
-- DATA QUALITY ISSUE (real, in the raw data): review_id is NOT unique.
-- Some review_ids appear multiple times (linked to different orders or repeated
-- answers). We keep ONE row per review_id: the one with the latest answer timestamp.
--
-- Technique: ROW_NUMBER() window function.
--   PARTITION BY review_id  -> restart the numbering for each review_id
--   ORDER BY ... DESC       -> row #1 = the most recent record of that review
-- Then we keep only row #1 of each group.

WITH ranked AS (

    SELECT
        review_id,
        order_id,
        CAST(review_score AS int)                    AS review_score,
        review_comment_title,
        review_comment_message,
        CAST(review_creation_date    AS timestamp)   AS review_created_at,
        CAST(review_answer_timestamp AS timestamp)   AS review_answered_at,
        ROW_NUMBER() OVER (
            PARTITION BY review_id
            ORDER BY review_answer_timestamp DESC NULLS LAST
        ) AS row_num
    FROM {{ source('raw', 'order_reviews') }}
    WHERE review_id IS NOT NULL

)

SELECT
    review_id,
    order_id,
    review_score,
    review_comment_title,
    review_comment_message,
    review_created_at,
    review_answered_at
FROM ranked
WHERE row_num = 1
