/*
===============================================================================
Project: NexusRetail Executive Analytics
Author: Faaris Muda Dwi Nugraha
Description: Transform raw transactional tables into an analytical fact view
             for executive KPI reporting and Google Data Studio dashboard.
===============================================================================
*/

CREATE OR REPLACE VIEW `nexusretail_dw.nexusretail_sales_fact` AS

WITH cleaned_orders AS (
  -- Filter and extract clean order details
  SELECT
    order_id,
    user_id,
    status AS order_status,
    gender AS customer_gender,
    created_at AS order_created_at,
    shipped_at AS order_shipped_at,
    delivered_at AS order_delivered_at,
    returned_at AS order_returned_at,
    num_of_item
  FROM
    `bigquery-public-data.thelook_ecommerce.orders`
),

enriched_order_items AS (
  -- Join order items with product catalog to compute unit economics
  SELECT
    oi.id AS order_item_id,
    oi.order_id,
    oi.user_id,
    oi.product_id,
    oi.status AS item_status,
    oi.created_at AS item_created_at,
    oi.sale_price,
    p.cost AS product_cost,
    p.category AS product_category,
    p.name AS product_name,
    p.brand AS product_brand,
    p.department AS product_department,
    -- Calculate gross profit and margin per item
    (oi.sale_price - p.cost) AS gross_profit,
    ROUND(SAFE_DIVIDE((oi.sale_price - p.cost), oi.sale_price) * 100, 2) AS profit_margin_pct
  FROM
    `bigquery-public-data.thelook_ecommerce.order_items` oi
  LEFT JOIN
    `bigquery-public-data.thelook_ecommerce.products` p
    ON oi.product_id = p.id
),

user_demographics AS (
  -- Extract demographic and geographic attributes
  SELECT
    id AS user_id,
    age AS customer_age,
    country AS customer_country,
    city AS customer_city,
    traffic_source AS acquisition_channel,
    -- Segment age into standard marketing cohorts
    CASE
      WHEN age < 20 THEN '<20'
      WHEN age BETWEEN 20 AND 29 THEN '20-29'
      WHEN age BETWEEN 30 AND 39 THEN '30-39'
      WHEN age BETWEEN 40 AND 49 THEN '40-49'
      WHEN age BETWEEN 50 AND 59 THEN '50-59'
      ELSE '60+'
    END AS age_group
  FROM
    `bigquery-public-data.thelook_ecommerce.users`
)

SELECT
  -- Identifiers
  eoi.order_item_id,
  co.order_id,
  co.user_id,
  eoi.product_id,

  -- Date and Timestamps
  co.order_created_at,
  DATE(co.order_created_at) AS order_date,
  EXTRACT(YEAR FROM co.order_created_at) AS order_year,
  FORMAT_DATE('%Y-%m', DATE(co.order_created_at)) AS order_year_month,

  -- Order Status & Health Flags
  co.order_status,
  CASE WHEN co.order_status = 'Complete' THEN 1 ELSE 0 END AS is_completed,
  CASE WHEN co.order_status = 'Cancelled' THEN 1 ELSE 0 END AS is_cancelled,
  CASE WHEN co.order_status = 'Returned' THEN 1 ELSE 0 END AS is_returned,

  -- Product Attributes
  eoi.product_category,
  eoi.product_name,
  eoi.product_brand,
  eoi.product_department,

  -- Customer Demographics & Geography
  ud.customer_age,
  ud.age_group,
  co.customer_gender,
  ud.customer_country,
  ud.customer_city,
  ud.acquisition_channel,

  -- Financial Metrics
  eoi.sale_price AS gmv,
  eoi.product_cost,
  eoi.gross_profit,
  eoi.profit_margin_pct,

  -- Operational Metrics (Lead Times in Days)
  ROUND(TIMESTAMP_DIFF(co.order_shipped_at, co.order_created_at, HOUR) / 24.0, 2) AS processing_days,
  ROUND(TIMESTAMP_DIFF(co.order_delivered_at, co.order_shipped_at, HOUR) / 24.0, 2) AS shipping_days,
  ROUND(TIMESTAMP_DIFF(co.order_delivered_at, co.order_created_at, HOUR) / 24.0, 2) AS total_fulfillment_days

FROM
  cleaned_orders co
JOIN
  enriched_order_items eoi ON co.order_id = eoi.order_id
LEFT JOIN
  user_demographics ud ON co.user_id = ud.user_id;