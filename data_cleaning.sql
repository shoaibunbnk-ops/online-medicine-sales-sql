-- ============================================================
--   ONLINE MEDICINE SALES — DATA CLEANING
--   Tool: PostgreSQL (VS Code + SQLTools Extension)
--   Step: Run BEFORE any analysis queries
-- ============================================================


-- ============================================================
-- STEP 0: VS CODE SETUP REMINDER
-- ============================================================
-- 1. VS Code mein install karo: "SQLTools" extension
-- 2. Phir install karo: "SQLTools PostgreSQL/Cockroach Driver"
-- 3. Left sidebar mein SQLTools icon → New Connection
-- 4. Fill karo: Host=localhost, Port=5432, Database=medicine_db, User=postgres
-- 5. Yeh file open karo aur Ctrl+Shift+P → SQLTools: Run Query



-- ============================================================
-- STEP 1: DATABASE AUR TABLE BANAO
-- ============================================================

-- Pehle database banao (pgAdmin ya psql terminal mein):
-- CREATE DATABASE medicine_db;

-- Table create karo
CREATE TABLE IF NOT EXISTS online_medicine_sales (
    order_id              VARCHAR(10),
    order_date            VARCHAR(20),      -- pehle VARCHAR rakhenge, baad mein convert karenge
    platform              VARCHAR(50),
    customer_id           VARCHAR(10),
    customer_type         VARCHAR(20),
    city                  VARCHAR(50),
    state                 VARCHAR(50),
    medicine_name         VARCHAR(100),
    category              VARCHAR(50),
    prescription_required VARCHAR(20),
    quantity              VARCHAR(10),      -- VARCHAR rakho import ke liye
    unit_price_inr        VARCHAR(15),
    discount_code         VARCHAR(20),
    discount_percent      VARCHAR(10),
    total_mrp             VARCHAR(15),
    discount_amount       VARCHAR(15),
    final_amount_inr      VARCHAR(15),
    payment_method        VARCHAR(30),
    delivery_days         VARCHAR(10),
    delivery_status       VARCHAR(20),
    return_reason         VARCHAR(50),
    rating                VARCHAR(5),
    review_given          VARCHAR(5)
);

-- CSV import karo (psql terminal mein):
-- \copy online_medicine_sales FROM 'C:/path/to/online_medicine_sales.csv' DELIMITER ',' CSV HEADER;



-- ============================================================
-- STEP 2: DATA EXPLORE KARO (Cleaning se pehle samjho)
-- ============================================================

-- 2A: Total rows kitni hain?
SELECT COUNT(*) AS total_rows
FROM online_medicine_sales;

-- 2B: Har column ka sample dekho
SELECT * FROM online_medicine_sales LIMIT 10;

-- 2C: Saare columns ki unique value count
SELECT
    COUNT(DISTINCT order_id)              AS unique_orders,
    COUNT(DISTINCT customer_id)           AS unique_customers,
    COUNT(DISTINCT platform)              AS unique_platforms,
    COUNT(DISTINCT city)                  AS unique_cities,
    COUNT(DISTINCT medicine_name)         AS unique_medicines,
    COUNT(DISTINCT category)              AS unique_categories,
    COUNT(DISTINCT delivery_status)       AS unique_statuses
FROM online_medicine_sales;

-- 2D: Delivery status ki saari values dekho
SELECT delivery_status, COUNT(*) AS count
FROM online_medicine_sales
GROUP BY delivery_status;

-- 2E: Rating ki saari values dekho (N/A bhi hai)
SELECT rating, COUNT(*) AS count
FROM online_medicine_sales
GROUP BY rating
ORDER BY count DESC;

-- 2F: Return reason ki values
SELECT return_reason, COUNT(*) AS count
FROM online_medicine_sales
GROUP BY return_reason
ORDER BY count DESC;



-- ============================================================
-- STEP 3: NULL / MISSING VALUES CHECK KARO
-- ============================================================

-- 3A: Har column mein kitne NULLs hain?
SELECT
    COUNT(*) - COUNT(order_id)              AS null_order_id,
    COUNT(*) - COUNT(order_date)            AS null_order_date,
    COUNT(*) - COUNT(platform)              AS null_platform,
    COUNT(*) - COUNT(customer_id)           AS null_customer_id,
    COUNT(*) - COUNT(customer_type)         AS null_customer_type,
    COUNT(*) - COUNT(city)                  AS null_city,
    COUNT(*) - COUNT(state)                 AS null_state,
    COUNT(*) - COUNT(medicine_name)         AS null_medicine,
    COUNT(*) - COUNT(category)              AS null_category,
    COUNT(*) - COUNT(quantity)              AS null_quantity,
    COUNT(*) - COUNT(unit_price_inr)        AS null_price,
    COUNT(*) - COUNT(discount_code)         AS null_discount_code,
    COUNT(*) - COUNT(final_amount_inr)      AS null_final_amount,
    COUNT(*) - COUNT(payment_method)        AS null_payment,
    COUNT(*) - COUNT(delivery_days)         AS null_delivery_days,
    COUNT(*) - COUNT(delivery_status)       AS null_delivery_status,
    COUNT(*) - COUNT(rating)                AS null_rating,
    COUNT(*) - COUNT(review_given)          AS null_review
FROM online_medicine_sales;

-- 3B: Empty string check (NULL nahi but blank hain)
SELECT COUNT(*) AS blank_platform
FROM online_medicine_sales
WHERE TRIM(platform) = '' OR platform IS NULL;

SELECT COUNT(*) AS blank_city
FROM online_medicine_sales
WHERE TRIM(city) = '' OR city IS NULL;



-- ============================================================
-- STEP 4: DUPLICATE ROWS CHECK KARO
-- ============================================================

-- 4A: Duplicate Order_IDs dhundo
SELECT order_id, COUNT(*) AS duplicate_count
FROM online_medicine_sales
GROUP BY order_id
HAVING COUNT(*) > 1
ORDER BY duplicate_count DESC;

-- 4B: Poori row duplicate hai kya?
SELECT order_id, order_date, platform, customer_id, medicine_name,
       COUNT(*) AS cnt
FROM online_medicine_sales
GROUP BY order_id, order_date, platform, customer_id, medicine_name
HAVING COUNT(*) > 1;



-- ============================================================
-- STEP 5: CLEANED TABLE BANAO (Best Practice)
-- Hamesha original data safe rakho — alag cleaned table banao
-- ============================================================

DROP TABLE IF EXISTS medicine_sales_cleaned;

CREATE TABLE medicine_sales_cleaned AS
SELECT
    -- 5A: Order ID — uppercase trim
    UPPER(TRIM(order_id))                                   AS order_id,

    -- 5B: Date — VARCHAR se proper DATE mein convert
    TO_DATE(TRIM(order_date), 'YYYY-MM-DD')                 AS order_date,

    -- 5C: Platform — trim whitespace, proper case
    INITCAP(TRIM(platform))                                  AS platform,

    -- 5D: Customer ID — uppercase
    UPPER(TRIM(customer_id))                                 AS customer_id,

    -- 5E: Customer type — trim
    INITCAP(TRIM(customer_type))                             AS customer_type,

    -- 5F: City & State — proper case
    INITCAP(TRIM(city))                                      AS city,
    INITCAP(TRIM(state))                                     AS state,

    -- 5G: Medicine name — trim
    TRIM(medicine_name)                                      AS medicine_name,

    -- 5H: Category — trim
    INITCAP(TRIM(category))                                  AS category,

    -- 5I: Prescription — standardize
    CASE
        WHEN UPPER(TRIM(prescription_required)) = 'PRESCRIPTION' THEN 'Prescription'
        WHEN UPPER(TRIM(prescription_required)) = 'OTC'          THEN 'OTC'
        ELSE 'Unknown'
    END                                                      AS prescription_required,

    -- 5J: Numeric columns — VARCHAR se proper types mein
    CAST(TRIM(quantity)        AS INTEGER)                   AS quantity,
    CAST(TRIM(unit_price_inr)  AS NUMERIC(10,2))             AS unit_price_inr,

    -- 5K: Discount code — NONE ko NULL mein badlo (cleaner)
    CASE
        WHEN TRIM(discount_code) = 'NONE' THEN NULL
        ELSE TRIM(discount_code)
    END                                                      AS discount_code,

    CAST(TRIM(discount_percent) AS INTEGER)                  AS discount_percent,
    CAST(TRIM(total_mrp)        AS NUMERIC(10,2))            AS total_mrp,
    CAST(TRIM(discount_amount)  AS NUMERIC(10,2))            AS discount_amount,
    CAST(TRIM(final_amount_inr) AS NUMERIC(10,2))            AS final_amount_inr,

    -- 5L: Payment method — trim
    INITCAP(TRIM(payment_method))                            AS payment_method,

    -- 5M: Delivery days — integer
    CAST(TRIM(delivery_days) AS INTEGER)                     AS delivery_days,

    -- 5N: Delivery status — standardize
    INITCAP(TRIM(delivery_status))                           AS delivery_status,

    -- 5O: Return reason — N/A ko NULL mein badlo
    CASE
        WHEN TRIM(return_reason) = 'N/A' THEN NULL
        ELSE TRIM(return_reason)
    END                                                      AS return_reason,

    -- 5P: Rating — N/A ko NULL, baaki ko numeric
    CASE
        WHEN TRIM(rating) = 'N/A' THEN NULL
        ELSE CAST(TRIM(rating) AS INTEGER)
    END                                                      AS rating,

    -- 5Q: Review given
    INITCAP(TRIM(review_given))                              AS review_given

FROM online_medicine_sales
WHERE
    -- 5R: Blank ya null order_id wali rows hata do
    TRIM(order_id) IS NOT NULL AND TRIM(order_id) <> ''
    -- 5S: Date missing wali rows hata do
    AND TRIM(order_date) IS NOT NULL AND TRIM(order_date) <> '';



-- ============================================================
-- STEP 6: CLEANED DATA VERIFY KARO
-- ============================================================

-- 6A: Row count same hai?
SELECT COUNT(*) AS cleaned_rows FROM medicine_sales_cleaned;

-- 6B: Data types sahi hain?
SELECT
    pg_typeof(order_date)        AS date_type,
    pg_typeof(quantity)          AS qty_type,
    pg_typeof(final_amount_inr)  AS amount_type,
    pg_typeof(rating)            AS rating_type
FROM medicine_sales_cleaned
LIMIT 1;

-- 6C: Sample cleaned data dekho
SELECT * FROM medicine_sales_cleaned LIMIT 10;

-- 6D: NULL values after cleaning
SELECT
    COUNT(*) - COUNT(discount_code)   AS null_discount_code,   -- NULL expected (NONE replaced)
    COUNT(*) - COUNT(return_reason)   AS null_return_reason,   -- NULL expected (N/A replaced)
    COUNT(*) - COUNT(rating)          AS null_rating           -- NULL expected (cancelled orders)
FROM medicine_sales_cleaned;

-- 6E: Date range sahi hai?
SELECT
    MIN(order_date) AS earliest_order,
    MAX(order_date) AS latest_order
FROM medicine_sales_cleaned;

-- 6F: Negative values check (price, quantity kabhi negative nahi honi chahiye)
SELECT COUNT(*) AS negative_prices
FROM medicine_sales_cleaned
WHERE unit_price_inr < 0 OR final_amount_inr < 0 OR quantity <= 0;

-- 6G: Rating range valid hai? (1-5 ke beech hona chahiye)
SELECT rating, COUNT(*) AS count
FROM medicine_sales_cleaned
WHERE rating IS NOT NULL
GROUP BY rating
ORDER BY rating;

-- 6H: Delivery days valid hai? (0 ya negative nahi hona chahiye)
SELECT
    MIN(delivery_days) AS min_days,
    MAX(delivery_days) AS max_days,
    AVG(delivery_days) AS avg_days
FROM medicine_sales_cleaned;



-- ============================================================
-- STEP 7: BUSINESS LOGIC VALIDATION
-- ============================================================

-- 7A: Final amount = Total MRP - Discount amount?
SELECT COUNT(*) AS mismatch_count
FROM medicine_sales_cleaned
WHERE ABS(final_amount_inr - (total_mrp - discount_amount)) > 1;
-- Result 0 hona chahiye

-- 7B: Total MRP = Unit Price x Quantity?
SELECT COUNT(*) AS mrp_mismatch
FROM medicine_sales_cleaned
WHERE ABS(total_mrp - (unit_price_inr * quantity)) > 1;
-- Result 0 hona chahiye

-- 7C: Delivered orders ka return_reason NULL hona chahiye
SELECT COUNT(*) AS wrong_return_reason
FROM medicine_sales_cleaned
WHERE delivery_status = 'Delivered'
  AND return_reason IS NOT NULL;

-- 7D: Returned orders ka return_reason NULL nahi hona chahiye
SELECT COUNT(*) AS missing_return_reason
FROM medicine_sales_cleaned
WHERE delivery_status = 'Returned'
  AND return_reason IS NULL;



-- ============================================================
-- STEP 8: FINAL CLEANING SUMMARY REPORT
-- ============================================================

SELECT
    (SELECT COUNT(*) FROM online_medicine_sales)       AS original_rows,
    (SELECT COUNT(*) FROM medicine_sales_cleaned)      AS cleaned_rows,
    (SELECT COUNT(*) FROM online_medicine_sales) -
    (SELECT COUNT(*) FROM medicine_sales_cleaned)      AS rows_removed,
    (SELECT COUNT(*) FROM medicine_sales_cleaned
     WHERE discount_code IS NULL)                      AS null_discount_codes,
    (SELECT COUNT(*) FROM medicine_sales_cleaned
     WHERE return_reason IS NULL)                      AS null_return_reasons,
    (SELECT COUNT(*) FROM medicine_sales_cleaned
     WHERE rating IS NULL)                             AS null_ratings,
    (SELECT MIN(order_date) FROM medicine_sales_cleaned) AS date_from,
    (SELECT MAX(order_date) FROM medicine_sales_cleaned) AS date_to;



-- ============================================================
-- ✅ DATA CLEANING COMPLETE!
-- Ab analysis ke liye "medicine_sales_cleaned" table use karo
-- Original table "online_medicine_sales" safe hai backup ke liye
-- ============================================================
