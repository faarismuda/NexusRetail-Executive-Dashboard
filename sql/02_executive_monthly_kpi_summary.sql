/*
===============================================================================
Project: NexusRetail Executive Analytics
Author: Faaris Muda Dwi Nugraha
Description: Advanced SQL aggregation creating an analytical summary table 
             tracking monthly executive KPIs, MoM growth rates, and logistics SLAs.
===============================================================================
*/

CREATE OR REPLACE TABLE `nexusretail_dw.executive_monthly_kpi_summary` AS

WITH monthly_sales AS (
  -- Aggregate transactional metrics by month
  SELECT
    FORMAT_DATE('%Y-%m', order_date) AS reporting_month,
    DATE_TRUNC(order_date, MONTH) AS month_start_date,
    COUNT(DISTINCT order_id) AS total_orders,
    COUNT(DISTINCT user_id) AS total_customers,
    COUNT(order_item_id) AS total_items_sold,
    
    -- Financial aggregates
    ROUND(SUM(gmv), 2) AS total_gmv,
    ROUND(SUM(product_cost), 2) AS total_cogs,
    ROUND(SUM(gross_profit), 2) AS total_gross_profit,
    ROUND(SAFE_DIVIDE(SUM(gross_profit), SUM(gmv)) * 100, 2) AS gross_margin_pct,
    ROUND(SAFE_DIVIDE(SUM(gmv), COUNT(DISTINCT order_id)), 2) AS average_order_value,

    -- Operational & SLA metrics
    ROUND(AVG(total_fulfillment_days), 2) AS avg_fulfillment_days,
    COUNTIF(order_status = 'Complete' AND total_fulfillment_days <= 3) AS fast_deliveries_under_3d,
    COUNTIF(order_status = 'Complete') AS completed_orders,
    COUNTIF(is_cancelled = 1) AS cancelled_orders,
    COUNTIF(is_returned = 1) AS returned_orders
  FROM
    `nexusretail_dw.nexusretail_sales_fact`
  GROUP BY
    1, 2
)

SELECT
  reporting_month,
  month_start_date,
  total_orders,
  total_customers,
  total_items_sold,
  total_gmv,
  total_gross_profit,
  gross_margin_pct,
  average_order_value,
  avg_fulfillment_days,

  -- Advanced Window Function: Month-over-Month (MoM) GMV Growth %
  ROUND(
    SAFE_DIVIDE(
      total_gmv - LAG(total_gmv) OVER (ORDER BY month_start_date),
      LAG(total_gmv) OVER (ORDER BY month_start_date)
    ) * 100, 2
  ) AS mom_gmv_growth_pct,

  -- Advanced Window Function: Running Cumulative GMV
  ROUND(
    SUM(total_gmv) OVER (ORDER BY month_start_date ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW),
    2
  ) AS cumulative_gmv,

  -- Logistics SLA Fulfillment Rate (Delivery <= 3 days)
  ROUND(SAFE_DIVIDE(fast_deliveries_under_3d, completed_orders) * 100, 2) AS fulfillment_sla_rate_pct,

  -- Leakage Ratios
  ROUND(SAFE_DIVIDE(cancelled_orders, total_orders) * 100, 2) AS cancellation_rate_pct,
  ROUND(SAFE_DIVIDE(returned_orders, total_orders) * 100, 2) AS return_rate_pct

FROM
  monthly_sales
ORDER BY
  month_start_date ASC;