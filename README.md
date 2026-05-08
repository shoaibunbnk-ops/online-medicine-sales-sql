# Online Medicine Sales Analysis — E-Pharmacy Business Intelligence

![PostgreSQL](https://img.shields.io/badge/PostgreSQL-16-blue?logo=postgresql) ![Status](https://img.shields.io/badge/Status-Completed-green) ![Domain](https://img.shields.io/badge/Domain-Healthcare%20%7C%20E--Commerce-orange)

---

## Executive Summary

This project analyzes **1,000 online medicine sales orders** across **5 major Indian e-pharmacy platforms** — 1mg, PharmEasy, Netmeds, Apollo Pharmacy, and Flipkart Health — covering the period **January 2023 to December 2024** across **12 cities in India**.

Using **PostgreSQL**, the entire workflow was completed — from raw data ingestion and cleaning to solving 7 real-world business problems. The analysis uncovers key insights around revenue performance, discount effectiveness, delivery operations, customer behaviour, demand trends, customer satisfaction, and prescription compliance.

---

## Business Problem

The Indian e-pharmacy market is growing rapidly but faces key challenges:

- **Which platform is generating the most revenue?**
- **Are discount strategies helping or hurting profitability?**
- **Which platforms have poor delivery and return rates?**
- **Are new or returning customers more valuable?**
- **Which medicine categories are in highest demand?**
- **What factors affect customer satisfaction ratings?**
- **Are prescription medicines being sold without proper compliance tracking?**

---

## Methodology

### Step 1 — Data Collection
- Generated a realistic dataset of **1,000 orders** with 23 columns covering order details, product info, pricing, delivery, and customer feedback

### Step 2 — Data Cleaning (PostgreSQL)
- Imported raw CSV into PostgreSQL as `online_medicine_sales` table (all VARCHAR)
- Checked for **NULL values** across all 23 columns
- Replaced `'N/A'` text with proper **NULL** values in `rating` and `return_reason`
- Replaced `'NONE'` with **NULL** in `discount_code`
- Added new column **`discount_type`** (`Discounted` / `No Discount`)
- Converted data types — VARCHAR → DATE, INTEGER, NUMERIC
- Applied **TRIM**, **INITCAP**, **UPPER** for data standardization
- Created final **`medicine_sales_cleaned`** table with proper data types

### Step 3 — Analysis (PostgreSQL)
- Solved 7 business problems using SQL queries
- Used advanced SQL — **Window Functions, CTEs, CASE WHEN, GROUP BY, aggregations**

---

## Skills

| Category | Tools / Concepts |
|---|---|
| Database | PostgreSQL |
| Editor | VS Code + SQLTools Extension |
| Data Cleaning | NULL handling, Type casting, TRIM, INITCAP, UPPER, CASE WHEN |
| SQL — Basic | SELECT, WHERE, GROUP BY, ORDER BY, LIMIT, COUNT, SUM, AVG |
| SQL — Advanced | Window Functions — `SUM() OVER()`, `LAG()`, `PARTITION BY` |
| SQL — Advanced | CTEs — `WITH` clause, Subqueries |
| SQL — Advanced | `ALTER TABLE`, `UPDATE`, `CREATE TABLE AS SELECT` |
| Business Skills | Revenue analysis, Customer segmentation, Operational efficiency |

---

## Results & Business Recommendations

### Problem 1 — Revenue & Sales Performance
**Finding:** 1mg leads with ~25% revenue share. Flipkart Health is second with ~20%. Diabetes medicines generate the highest revenue despite Supplements having the highest units sold.

> **Recommendation:** Focus marketing budget on 1mg and Flipkart Health. Stock more Diabetes medicines as they are high-value products.

---

### Problem 2 — Discount Strategy Analysis
**Finding:** Discounted orders (511) are only 22 more than non-discounted (489). However, avg order value drops from Rs. 397 to Rs. 339 — a loss of Rs. 58 per order. Total discount given = Rs. 25,659 but only 22 extra orders generated.

> **Recommendation:** Current discount strategy is **not profitable** — Rs. 25,659 discount cost brought only Rs. 7,436 in extra revenue — a net loss of ~Rs. 18,000. Reduce blanket discounts and offer targeted discounts to high-value customers only.

---

### Problem 3 — Delivery & Operational Efficiency
**Finding:** PharmEasy has the highest cancellation rate (14.29%) and return rate (8.48%). Flipkart Health is the most efficient with only 6.60% cancellation and 4.06% return rate.

> **Recommendation:** PharmEasy needs immediate operational review — 1 in 7 orders is being cancelled. Flipkart Health's delivery model should be studied and replicated.

---

### Problem 4 — Customer Behaviour
**Finding:** Surprisingly, New customers (avg Rs. 368) spend more per order than Returning customers (avg Rs. 359). Orders are almost equal — 360 vs 356.

> **Recommendation:** Launch loyalty programs and medicine reminder notifications for returning customers to increase their order value and frequency.

---

### Problem 5 — Monthly Sales Trend
**Finding:** Sales show month-over-month growth with seasonal spikes in winter months for Cough & Cold medicines and consistent year-round demand for Supplements and Diabetes medicines.

> **Recommendation:** Stock up on seasonal medicines before peak months. Plan promotions around high-demand periods.

---

### Problem 6 — Customer Satisfaction
**Finding:** Platforms with faster delivery tend to have higher ratings. Flipkart Health and 1mg score higher on customer satisfaction.

> **Recommendation:** Reduce delivery days to improve ratings — there is a direct correlation between delivery speed and customer satisfaction scores.

---

### Problem 7 — Prescription Compliance Risk
**Finding:** A significant portion of orders are for Prescription medicines. Metro cities show the highest Rx order volumes without clear compliance tracking.

> **Recommendation:** Implement mandatory digital prescription upload before dispatching Rx medicines. Prioritize compliance checks in high-volume cities to reduce legal risk.

---

## Next Steps

- [ ] **Power BI Dashboard** — Visualize all 7 findings in an interactive dashboard
- [ ] **Python Analysis** — Recreate analysis using Pandas and Seaborn for visual EDA
- [ ] **Predictive Modelling** — Predict next month's sales using time-series forecasting
- [ ] **Customer Segmentation** — RFM Analysis (Recency, Frequency, Monetary) on customer data
- [ ] **Expand Dataset** — Add more cities, platforms and 2 more years of data

---

## Project Files

| File | Description |
|---|---|
| `online_medicine_sales.csv` | Raw dataset — 1,000 orders, 23 columns |
| `data_cleaning.sql` | All data cleaning queries — Step by step |
| `medicine_queries.sql` | All 7 business problem queries |
| `Medicine_Sales_Project_Report.docx` | Detailed project report |
| `README.md` | This file |

---

## 🗂️ Dataset Overview

| Feature | Detail |
|---|---|
| Total Records | 1,000 orders |
| Time Period | Jan 2023 — Dec 2024 |
| Platforms | 1mg, PharmEasy, Netmeds, Apollo Pharmacy, Flipkart Health |
| Cities | Mumbai, Delhi, Bangalore, Chennai, Hyderabad, Pune, Kolkata, Ahmedabad, Ludhiana, Jaipur, Surat, Lucknow |
| Medicine Categories | Pain Relief, Supplements, Diabetes, Antibiotics, Antacid, Antiallergic, Blood Pressure, Cholesterol, Skin Care, Cough & Cold |
| Total Columns | 23 (+ 1 added during cleaning) |

---

*Project by — Shoaib Khan | Data Analyst Fresher Portfolio | PostgreSQL | 2024*
