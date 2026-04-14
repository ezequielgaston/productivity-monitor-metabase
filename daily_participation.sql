/*
  Daily Participation Analysis
  Calculates the percentage of total volume contributed by each day of the week.
*/

WITH date_bounds AS (
  SELECT
    MIN(o.packed_at) AS start_date,
    MAX(o.packed_at) AS end_date,
    DATEDIFF(MAX(o.packed_at), MIN(o.packed_at)) + 1 AS duration_days
  FROM orders o
  WHERE {{period}}
),
raw_data AS (
  SELECT
    'Current' AS period_label,
    DAYOFWEEK(o.packed_at) AS day_num,
    COUNT(os.id) AS units
  FROM orders o
  JOIN orders_shipments os ON o.id = os.order_id
  CROSS JOIN date_bounds db
  WHERE o.warehouse_id IN (1, 6)
    AND o.fulfillment_status_id = 'shipped'
    AND o.packed_at >= db.start_date AND o.packed_at <= db.end_date
    [[AND ('-- ALL --' IN ({{business_name}}) OR o.business_id IN (SELECT id FROM business WHERE name_fantasy IN ({{business_name}})))]]
    [[AND o.channel_id IN ({{channel_name}})]]
    [[AND o.shipping IN ({{shipping_type}})]]
  GROUP BY 1, 2

  UNION ALL

  SELECT
    'Past' AS period_label,
    DAYOFWEEK(o.packed_at) AS day_num,
    COUNT(os.id) AS units
  FROM orders o
  JOIN orders_shipments os ON o.id = os.order_id
  CROSS JOIN date_bounds db
  WHERE o.warehouse_id IN (1, 6)
    AND o.fulfillment_status_id = 'shipped'
    [[AND ('-- ALL --' IN ({{business_name}}) OR o.business_id IN (SELECT id FROM business WHERE name_fantasy IN ({{business_name}})))]]
    [[AND o.channel_id IN ({{channel_name}})]]
    [[AND o.shipping IN ({{shipping_type}})]]
    AND (
      ( {{comparison_type}} = 'Previous Year' AND o.packed_at >= DATE_SUB(db.start_date, INTERVAL 1 YEAR) AND o.packed_at <= DATE_SUB(db.end_date, INTERVAL 1 YEAR) )
      OR 
      ( {{comparison_type}} = 'Previous Period' AND (
          (db.duration_days <= 31 AND o.packed_at >= DATE_SUB(db.start_date, INTERVAL 1 MONTH) AND o.packed_at <= DATE_SUB(db.end_date, INTERVAL 1 MONTH))
          OR
          (db.duration_days > 31 AND o.packed_at >= DATE_SUB(db.start_date, INTERVAL db.duration_days DAY) AND o.packed_at < db.start_date)))
    )
  GROUP BY 1, 2
),
period_totals AS (
  SELECT
    period_label,
    SUM(units) AS total_volume
  FROM raw_data
  GROUP BY period_label
)
SELECT
  CASE d.day_num
    WHEN 2 THEN '1. Monday' WHEN 3 THEN '2. Tuesday' WHEN 4 THEN '3. Wednesday'
    WHEN 5 THEN '4. Thursday' WHEN 6 THEN '5. Friday' WHEN 7 THEN '6. Saturday'
    WHEN 1 THEN '7. Sunday'
  END AS day_of_week,
  d.period_label,
  ROUND(d.units * 100.0 / NULLIF(t.total_volume, 0), 1) AS percentage
FROM raw_data d
JOIN period_totals t ON d.period_label = t.period_label
ORDER BY day_of_week ASC, d.period_label DESC;
