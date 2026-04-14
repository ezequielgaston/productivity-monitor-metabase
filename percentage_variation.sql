/*
  Percentage Variation Query
  Calculates the WoW or YoY growth rate for packed units.
*/

WITH date_bounds AS (
  SELECT
    MIN(o.packed_at) AS start_date,
    MAX(o.packed_at) AS end_date,
    DATEDIFF(MAX(o.packed_at), MIN(o.packed_at)) + 1 AS duration_days
  FROM orders o
  WHERE {{period}}
),
current_data AS (
  SELECT COUNT(os.id) AS total
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
past_data AS (
  SELECT COUNT(os.id) AS total
  FROM orders o
  JOIN orders_shipments os ON o.id = os.order_id
  CROSS JOIN date_bounds db
  WHERE o.warehouse_id IN (1,6)
    AND o.fulfillment_status_id = 'shipped'
    [[AND ('-- ALL --' IN ({{business_name}}) OR o.business_id IN (SELECT id FROM business WHERE name_fantasy IN ({{business_name}})))]]
    [[AND o.channel_id IN ({{channel_name}})]] 
    [[AND ('-- ALL --' IN ({{shipping_type}}) OR o.shipping IN ({{shipping_type}}))]]
    AND (
      ( {{comparison_type}} = 'Previous Year' AND o.packed_at >= DATE_SUB(db.start_date, INTERVAL 1 YEAR) AND o.packed_at <= DATE_SUB(db.end_date, INTERVAL 1 YEAR) )
      OR 
      ( {{comparison_type}} = 'Previous Period' AND (
          (db.duration_days <= 31 AND o.packed_at >= DATE_SUB(db.start_date, INTERVAL 1 MONTH) AND o.packed_at <= DATE_SUB(db.end_date, INTERVAL 1 MONTH))
          OR
          (db.duration_days > 31 AND o.packed_at >= DATE_SUB(db.start_date, INTERVAL db.duration_days DAY) AND o.packed_at < db.start_date)))
    )
)
SELECT 
  ROUND(((c.total - p.total) * 100.0 / NULLIF(p.total, 0)), 2) AS percentage_variation
FROM current_data c 
CROSS JOIN past_data p;
