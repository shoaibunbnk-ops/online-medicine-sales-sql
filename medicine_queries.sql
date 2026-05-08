-- ============================================================
--   ONLINE MEDICINE SALES ANALYSIS — PostgreSQL Project
--   Dataset: online_medicine_sales.csv
--   Author: Data Analyst Fresher Project
-- ============================================================

-- ============================================================
-- STEP 1: CREATE TABLE & IMPORT DATA
-- ============================================================

CREATE TABLE online_medicine_sales (
    order_id              VARCHAR(10) PRIMARY KEY,
    order_date            DATE,
    platform              VARCHAR(50),
    customer_id           VARCHAR(10),
    customer_type         VARCHAR(20),
    city                  VARCHAR(50),
    state                 VARCHAR(50),
    medicine_name         VARCHAR(100),
    category              VARCHAR(50),
    prescription_required VARCHAR(20),
    quantity              INT,
    unit_price_inr        NUMERIC(10,2),
    discount_code         VARCHAR(20),
    discount_percent      INT,
    total_mrp             NUMERIC(10,2),
    discount_amount       NUMERIC(10,2),
    final_amount_inr      NUMERIC(10,2),
    payment_method        VARCHAR(30),
    delivery_days         INT,
    delivery_status       VARCHAR(20),
    return_reason         VARCHAR(50),
    rating                VARCHAR(5),
    review_given          VARCHAR(5)
);

-- Import CSV (run this in psql terminal):
-- \copy online_medicine_sales FROM 'online_medicine_sales.csv' DELIMITER ',' CSV HEADER;


-- ============================================================
-- PROBLEM 1: Revenue & Sales Performance
-- "Which platform generates the highest revenue,
--  and which medicine category contributes the most?"
-- ============================================================

-- 1A: Total Revenue by Platform
SELECT
    platform,
    COUNT(order_id)                        AS total_orders,
    SUM(final_amount_inr)                  AS total_revenue_inr,
    ROUND(AVG(final_amount_inr), 2)        AS avg_order_value,
    ROUND(SUM(final_amount_inr) * 100.0 /
          SUM(SUM(final_amount_inr)) OVER(), 2) AS revenue_share_pct
FROM online_medicine_sales
WHERE delivery_status = 'Delivered'
GROUP BY platform
ORDER BY total_revenue_inr DESC;

-- 1B: Total Revenue by Medicine Category
SELECT
    category,
    COUNT(order_id)                        AS total_orders,
    SUM(quantity)                          AS total_units_sold,
    SUM(final_amount_inr)                  AS total_revenue_inr,
    ROUND(SUM(final_amount_inr) * 100.0 /
          SUM(SUM(final_amount_inr)) OVER(), 2) AS revenue_share_pct
FROM online_medicine_sales
WHERE delivery_status = 'Delivered'
GROUP BY category
ORDER BY total_revenue_inr DESC;

-- 1C: Top 10 Best Selling Medicines
SELECT
    medicine_name,
    category,
    SUM(quantity)           AS total_units_sold,
    SUM(final_amount_inr)   AS total_revenue_inr
FROM online_medicine_sales
WHERE delivery_status = 'Delivered'
GROUP BY medicine_name, category
ORDER BY total_units_sold DESC
LIMIT 10;


-- ============================================================
-- PROBLEM 2: Discount Strategy Analysis
-- "Are discount codes increasing order value
--  or just reducing profit?"
-- ============================================================

-- 2A: Orders with vs without discount
SELECT
    CASE WHEN discount_percent > 0 THEN 'Discounted' ELSE 'No Discount' END AS discount_type,
    COUNT(order_id)                        AS total_orders,
    ROUND(AVG(quantity), 2)                AS avg_quantity,
    ROUND(AVG(total_mrp), 2)               AS avg_mrp,
    ROUND(AVG(discount_amount), 2)         AS avg_discount_given,
    ROUND(AVG(final_amount_inr), 2)        AS avg_final_amount,
    SUM(discount_amount)                   AS total_discount_given
FROM online_medicine_sales
GROUP BY discount_type
ORDER BY discount_type;

-- 2B: Performance of each Discount Code
SELECT
    discount_code,
    discount_percent,
    COUNT(order_id)                        AS total_orders,
    SUM(final_amount_inr)                  AS total_revenue,
    SUM(discount_amount)                   AS total_discount_loss,
    ROUND(AVG(final_amount_inr), 2)        AS avg_order_value
FROM online_medicine_sales
GROUP BY discount_code, discount_percent
ORDER BY total_revenue DESC;

-- 2C: Does higher discount lead to more quantity ordered?
SELECT
    discount_percent,
    ROUND(AVG(quantity), 2)                AS avg_quantity_ordered,
    COUNT(order_id)                        AS total_orders
FROM online_medicine_sales
GROUP BY discount_percent
ORDER BY discount_percent;


-- ============================================================
-- PROBLEM 3: Delivery & Operational Efficiency
-- "Which platform has highest cancellation/return rate
--  and what are common return reasons?"
-- ============================================================

-- 3A: Delivery Status breakdown by Platform
SELECT
    platform,
    delivery_status,
    COUNT(order_id)                         AS total_orders,
    ROUND(COUNT(order_id) * 100.0 /
          SUM(COUNT(order_id)) OVER(PARTITION BY platform), 2) AS pct_of_platform
FROM online_medicine_sales
GROUP BY platform, delivery_status
ORDER BY platform, total_orders DESC;

-- 3B: Cancellation Rate by Platform
SELECT
    platform,
    COUNT(order_id)                          AS total_orders,
    SUM(CASE WHEN delivery_status = 'Cancelled' THEN 1 ELSE 0 END) AS cancelled,
    SUM(CASE WHEN delivery_status = 'Returned'  THEN 1 ELSE 0 END) AS returned,
    ROUND(SUM(CASE WHEN delivery_status = 'Cancelled' THEN 1 ELSE 0 END) * 100.0
          / COUNT(order_id), 2) AS cancellation_rate_pct,
    ROUND(SUM(CASE WHEN delivery_status = 'Returned'  THEN 1 ELSE 0 END) * 100.0
          / COUNT(order_id), 2) AS return_rate_pct
FROM online_medicine_sales
GROUP BY platform
ORDER BY cancellation_rate_pct DESC;

-- 3C: Common Return Reasons
SELECT
    return_reason,
    COUNT(order_id) AS total_returns
FROM online_medicine_sales
WHERE delivery_status = 'Returned'
  AND return_reason <> 'N/A'
GROUP BY return_reason
ORDER BY total_returns DESC;

-- 3D: Average Delivery Days by Platform
SELECT
    platform,
    ROUND(AVG(delivery_days), 2) AS avg_delivery_days,
    MIN(delivery_days)           AS fastest_delivery,
    MAX(delivery_days)           AS slowest_delivery
FROM online_medicine_sales
WHERE delivery_status = 'Delivered'
GROUP BY platform
ORDER BY avg_delivery_days ASC;


-- ============================================================
-- PROBLEM 4: Customer Behaviour Analysis
-- "Do returning customers spend more than new customers?
--  Which city has highest loyalty?"
-- ============================================================

-- 4A: New vs Returning Customer Spend
SELECT
    customer_type,
    COUNT(DISTINCT customer_id)            AS unique_customers,
    COUNT(order_id)                        AS total_orders,
    ROUND(AVG(final_amount_inr), 2)        AS avg_order_value,
    SUM(final_amount_inr)                  AS total_revenue
FROM online_medicine_sales
WHERE delivery_status = 'Delivered'
GROUP BY customer_type;

-- 4B: City-wise Revenue & Customer Count
SELECT
    city,
    state,
    COUNT(DISTINCT customer_id)            AS unique_customers,
    COUNT(order_id)                        AS total_orders,
    SUM(final_amount_inr)                  AS total_revenue,
    ROUND(AVG(final_amount_inr), 2)        AS avg_order_value
FROM online_medicine_sales
WHERE delivery_status = 'Delivered'
GROUP BY city, state
ORDER BY total_revenue DESC;

-- 4C: Returning Customer Rate by City
SELECT
    city,
    COUNT(DISTINCT customer_id)            AS total_customers,
    SUM(CASE WHEN customer_type = 'Returning' THEN 1 ELSE 0 END) AS returning_orders,
    ROUND(SUM(CASE WHEN customer_type = 'Returning' THEN 1 ELSE 0 END) * 100.0
          / COUNT(order_id), 2) AS returning_customer_pct
FROM online_medicine_sales
GROUP BY city
ORDER BY returning_customer_pct DESC;


-- ============================================================
-- PROBLEM 5: Monthly Sales Trend & Demand Forecasting
-- "Which medicines show rising demand month-over-month?"
-- ============================================================

-- 5A: Monthly Revenue Trend
SELECT
    TO_CHAR(order_date, 'YYYY-MM')         AS month,
    COUNT(order_id)                        AS total_orders,
    SUM(quantity)                          AS total_units_sold,
    SUM(final_amount_inr)                  AS total_revenue
FROM online_medicine_sales
WHERE delivery_status = 'Delivered'
GROUP BY TO_CHAR(order_date, 'YYYY-MM')
ORDER BY month;

-- 5B: Month-over-Month Revenue Growth
WITH monthly AS (
    SELECT
        TO_CHAR(order_date, 'YYYY-MM')     AS month,
        SUM(final_amount_inr)              AS revenue
    FROM online_medicine_sales
    WHERE delivery_status = 'Delivered'
    GROUP BY TO_CHAR(order_date, 'YYYY-MM')
)
SELECT
    month,
    revenue,
    LAG(revenue) OVER (ORDER BY month)    AS prev_month_revenue,
    ROUND((revenue - LAG(revenue) OVER (ORDER BY month)) * 100.0
          / NULLIF(LAG(revenue) OVER (ORDER BY month), 0), 2) AS growth_pct
FROM monthly
ORDER BY month;

-- 5C: Top Growing Medicine Categories (Quarterly)
SELECT
    TO_CHAR(order_date, 'YYYY-Q"Q"')       AS quarter,
    category,
    SUM(quantity)                          AS units_sold,
    SUM(final_amount_inr)                  AS revenue
FROM online_medicine_sales
WHERE delivery_status = 'Delivered'
GROUP BY TO_CHAR(order_date, 'YYYY-Q"Q"'), category
ORDER BY quarter, revenue DESC;


-- ============================================================
-- PROBLEM 6: Rating & Customer Satisfaction Analysis
-- "What factors affect customer ratings?"
-- ============================================================

-- 6A: Average Rating by Platform
SELECT
    platform,
    COUNT(order_id)                        AS rated_orders,
    ROUND(AVG(rating::NUMERIC), 2)         AS avg_rating,
    SUM(CASE WHEN rating::INT >= 4 THEN 1 ELSE 0 END) AS happy_customers,
    SUM(CASE WHEN rating::INT <= 2 THEN 1 ELSE 0 END) AS unhappy_customers
FROM online_medicine_sales
WHERE delivery_status = 'Delivered'
  AND rating <> 'N/A'
GROUP BY platform
ORDER BY avg_rating DESC;

-- 6B: Rating vs Delivery Days
SELECT
    delivery_days,
    ROUND(AVG(rating::NUMERIC), 2)         AS avg_rating,
    COUNT(order_id)                        AS total_orders
FROM online_medicine_sales
WHERE delivery_status = 'Delivered'
  AND rating <> 'N/A'
GROUP BY delivery_days
ORDER BY delivery_days;

-- 6C: Rating by Medicine Category
SELECT
    category,
    ROUND(AVG(rating::NUMERIC), 2)         AS avg_rating,
    COUNT(order_id)                        AS total_orders
FROM online_medicine_sales
WHERE delivery_status = 'Delivered'
  AND rating <> 'N/A'
GROUP BY category
ORDER BY avg_rating DESC;

-- 6D: Rating vs Discount
SELECT
    discount_percent,
    ROUND(AVG(rating::NUMERIC), 2)         AS avg_rating,
    COUNT(order_id)                        AS total_orders
FROM online_medicine_sales
WHERE delivery_status = 'Delivered'
  AND rating <> 'N/A'
GROUP BY discount_percent
ORDER BY discount_percent;


-- ============================================================
-- PROBLEM 7: Prescription Medicine Compliance Risk
-- "How many prescription medicines were ordered,
--  and which cities show highest such orders?"
-- ============================================================

-- 7A: Prescription vs OTC Orders
SELECT
    prescription_required,
    COUNT(order_id)                        AS total_orders,
    SUM(quantity)                          AS total_units,
    SUM(final_amount_inr)                  AS total_revenue,
    ROUND(COUNT(order_id) * 100.0 /
          SUM(COUNT(order_id)) OVER(), 2)  AS order_share_pct
FROM online_medicine_sales
GROUP BY prescription_required;

-- 7B: Prescription Medicines ordered — City-wise Risk
SELECT
    city,
    state,
    COUNT(order_id)                        AS prescription_orders,
    SUM(quantity)                          AS total_units,
    COUNT(DISTINCT medicine_name)          AS unique_medicines
FROM online_medicine_sales
WHERE prescription_required = 'Prescription'
GROUP BY city, state
ORDER BY prescription_orders DESC;

-- 7C: Platform-wise Prescription Order Count
SELECT
    platform,
    COUNT(order_id)                        AS prescription_orders,
    ROUND(COUNT(order_id) * 100.0 /
          SUM(COUNT(order_id)) OVER(), 2)  AS pct_of_total_rx_orders
FROM online_medicine_sales
WHERE prescription_required = 'Prescription'
GROUP BY platform
ORDER BY prescription_orders DESC;

-- 7D: Top Prescription Medicines Ordered
SELECT
    medicine_name,
    category,
    COUNT(order_id)                        AS total_orders,
    SUM(quantity)                          AS total_units
FROM online_medicine_sales
WHERE prescription_required = 'Prescription'
GROUP BY medicine_name, category
ORDER BY total_orders DESC
LIMIT 10;

-- ============================================================
-- END OF PROJECT QUERIES
-- ============================================================
