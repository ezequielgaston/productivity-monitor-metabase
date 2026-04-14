/*
  Productivity Heatmap
  Aggregates packing activity by hour and day of the week to identify peak times.
*/

SELECT 
    HOUR(o.packed_at) AS hour_of_day,
    SUM(CASE WHEN DAYOFWEEK(o.packed_at) = 2 THEN 1 ELSE 0 END) AS "1. Monday",
    SUM(CASE WHEN DAYOFWEEK(o.packed_at) = 3 THEN 1 ELSE 0 END) AS "2. Tuesday",
    SUM(CASE WHEN DAYOFWEEK(o.packed_at) = 4 THEN 1 ELSE 0 END) AS "3. Wednesday",
    SUM(CASE WHEN DAYOFWEEK(o.packed_at) = 5 THEN 1 ELSE 0 END) AS "4. Thursday",
    SUM(CASE WHEN DAYOFWEEK(o.packed_at) = 6 THEN 1 ELSE 0 END) AS "5. Friday",
    SUM(CASE WHEN DAYOFWEEK(o.packed_at) = 7 THEN 1 ELSE 0 END) AS "6. Saturday"
FROM orders o
JOIN orders_shipments os ON o.id = os.order_id
WHERE o.warehouse_id IN (1, 6)
  AND o.fulfillment_status_id = 'shipped'
  AND {{period}}
  [[AND ('-- ALL --' IN ({{business_name}}) OR o.business_id IN (SELECT id FROM business WHERE name_fantasy IN ({{business_name}})))]]
  [[AND o.channel_id IN ({{channel_name}})]] 
  [[AND o.shipping IN ({{shipping_type}})]]
GROUP BY 1
ORDER BY 1 ASC;
