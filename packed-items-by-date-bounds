/*
  Warehouse Productivity Comparison Query
  This script calculates the total number of packed items for the current selected period 
  and compares it against a past period (either Previous Year or Previous Period).
*/

WITH date_bounds AS (
  SELECT 
    MIN(o.packed_at) AS start_date, 
    MAX(o.packed_at) AS end_date,
    DATEDIFF(MAX(o.packed_at), MIN(o.packed_at)) + 1 AS duration_days
  FROM orders o
  WHERE {{period}} -- Metabase variable
),
current_period AS (
  SELECT 'Current' AS label, COUNT(os.id) AS total
  FROM orders o
  JOIN orders_shipments os ON o.id = os.order_id
  CROSS JOIN date_bounds db
  WHERE o.warehouse_id IN (1,6) 
    AND o.fulfillment_status_id = 'shipped'
    [[AND ('-- ALL --' IN ({{business_name}}) OR o.business_id IN (SELECT id FROM business WHERE name_fantasy IN ({{business_name}})))]]
    [[AND o.channel_id IN ({{channel_name}})]]
    [[AND ('-- ALL --' IN ({{shipping_type}}) OR o.shipping IN ({{shipping_type}}))]]
    AND o.packed_at >= db.start_date AND o.packed_at <= db.end_date
),
past_period AS (
  SELECT 'Past' AS label, COUNT(os.id) AS total
  FROM orders o
  JOIN orders_shipments os ON o.id = os.order_id
  CROSS JOIN date_bounds db
  WHERE o.warehouse_id IN (1,6)
    AND o.fulfillment_status_id = 'shipped'
    [[AND ('-- ALL --' IN ({{business_name}}) OR o.business_id IN (SELECT id FROM business WHERE name_fantasy IN ({{business_name}})))]]
    [[AND o.channel_id IN ({{channel_name}})]]
    [[AND ('-- ALL --' IN ({{shipping_type}}) OR o.shipping IN ({{shipping_type}}))]]
    AND (
      -- Condition 1: Year-over-Year comparison
      ( {{comparison_type}} = 'Previous Year' AND o.packed_at >= DATE_SUB(db.start_date, INTERVAL 1 YEAR) AND o.packed_at <= DATE_SUB(db.end_date, INTERVAL 1 YEAR) )
      OR 
      ( {{comparison_type}} = 'Previous Period' 
        AND (
          -- Sub-condition A: Short range (<= 31 days), shifts back exactly 1 month
          (db.duration_days <= 31 AND o.packed_at >= DATE_SUB(db.start_date, INTERVAL 1 MONTH) AND o.packed_at <= DATE_SUB(db.end_date, INTERVAL 1 MONTH))
          OR
          -- Sub-condition B: Long range (> 31 days), shifts back by the exact number of days to avoid overlap
          (db.duration_days > 31 AND o.packed_at >= DATE_SUB(db.start_date, INTERVAL db.duration_days DAY) AND o.packed_at < db.start_date)
        )
      )
    )
)

-- Final result set combining both periods
SELECT label, NULLIF(total, 0) AS total_units
FROM current_period
UNION ALL
SELECT label, NULLIF(total, 0) AS total_units
FROM past_period;
