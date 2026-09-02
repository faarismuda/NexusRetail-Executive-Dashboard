# NexusRetail: Executive Business Performance & Operations Dashboard

![Dashboard Preview](assets/dashboard_preview.png)

> **Live Interactive Dashboard:** [Launch NexusRetail Executive Dashboard](https://datastudio.google.com/reporting/2f002a24-e5dc-4b9c-9244-f2a88573801b)

---

## 1. Executive Summary & Core KPIs

NexusRetail is a global multi-category e-commerce enterprise. This project delivers an end-to-end cloud analytics solution tracking revenue growth, category profitability, and fulfillment operations. By transforming raw relational transaction tables in **Google BigQuery** into an analytical fact view, the resulting executive dashboard empowers leadership to make data-backed decisions on inventory replenishment, pricing strategies, and regional logistics.

### Executive KPI Snapshot

| Metric | Verified Value | Benchmark / Significance |
|---|---|---|
| **Total Gross Merchandise Value (GMV)** | **$10.77M** | Total gross top-line revenue generated across global transactions |
| **Gross Profit** | **$5.54M** | Net earnings after product costs (**51.4% cumulative profit margin**) |
| **Average Order Value (AOV)** | **$86.39** | Average basket spend per unique customer transaction |
| **Avg Fulfillment Lead Time** | **4.0 Days** | Average end-to-end operational transit time (order creation to delivery) |

---

## 2. Business Problem & Objectives

Executive stakeholders lacked unified visibility across transactional data, requiring analytics on:
- **Revenue vs. Profit Disparity:** Identifying product departments that drive high volume versus those that capture true gross margin.
- **Logistics Delivery Efficiency:** Measuring fulfillment lead times to maintain operational service-level agreements (SLAs).
- **Customer Basket Economics:** Analyzing average basket size to identify opportunities for upselling and cross-selling.

---

## 3. Tech Stack & Architecture

- **Data Warehouse:** Google BigQuery (Cloud SQL)
- **Data Modeling:** Star-schema optimized Analytical Fact View using Common Table Expressions (CTEs)
- **BI & Visual Analytics:** Google Data Studio
- **Version Control:** Git & GitHub

```
[Google BigQuery Public Dataset]
  ├── orders
  ├── order_items
  ├── products
  └── users
         │
         ▼ (SQL CTEs & Unit Economics Transformation)
[Analytical Fact View: nexusretail_dw.nexusretail_sales_fact]
         │
         ▼ (BigQuery Native Connector)
[Google Data Studio Executive Dashboard]
  ├── Global Filter Bar (Date Range, Country, Category, Status)
  ├── 4 KPI Summary Cards (GMV, Profit, AOV, Fulfillment)
  ├── Monthly Revenue & Profit Trend (Time Series)
  └── Top 10 Product Categories by Gross Profit (Horizontal Bar)
```

---

## 4. Key Business Insights

1. **High-Margin Category Dominance:**
   - **Outerwear & Coats** (> $579K gross profit) and **Jeans** (~ $428K gross profit) are the highest absolute profit generators for NexusRetail.
   - High unit economics in outerwear compensate for lower sales frequency, whereas denim maintains high volume alongside strong margins.

2. **Sustained Top-Line Revenue Growth:**
   - The monthly revenue trend shows continuous upward acceleration from 2020 through 2024+, with gross profit closely tracking GMV growth, indicating consistent cost controls.

3. **Consistent Fulfillment Operational Stability:**
   - Global fulfillment lead time averages **4.0 days**, demonstrating a dependable fulfillment supply chain across international hubs.

4. **Healthy Customer Basket Size:**
   - An **Average Order Value of $86.39** confirms multi-item purchasing behavior across key apparel and accessory categories.

---

## 5. Strategic Recommendations

- **Dynamic Inventory Redistribution:** Prioritize warehouse replenishment and safety stock allocation for top-margin categories (Outerwear and Jeans) prior to peak retail seasons.
- **Cross-Selling & Bundle Incentives:** Package complementary accessories or sweaters with high-volume jeans purchases to lift AOV beyond the $100 threshold.
- **Regional Fulfillment Monitoring:** Set alert thresholds for cross-border transit exceeding 4.5 days to mitigate delivery-related customer churn.

---

## 6. How to Reproduce

1. **Clone the repository:**
   ```bash
   git clone https://github.com/faarismuda/nexusretail-executive-dashboard.git
   cd nexusretail-executive-dashboard
   ```

2. **Set up BigQuery Data Warehouse:**
   - Open the [Google BigQuery Console](https://console.cloud.google.com/bigquery).
   - Create a dataset named `nexusretail_dw` in the `US` multi-region.
   - Execute the transformation script located in [`sql/01_sales_fact_transformation.sql`](sql/01_sales_fact_transformation.sql).

3. **Connect to Google Data Studio:**
   - Open [Google Data Studio](https://datastudio.google.com/).
   - Create a new report and connect to BigQuery $\rightarrow$ `nexusretail_dw.nexusretail_sales_fact`.
   - Add calculated field for **Average Order Value**:
     ```sql
     SUM(gmv) / COUNT_DISTINCT(order_id)
     ```
   - Build charts and KPI scorecards following the executive layout.