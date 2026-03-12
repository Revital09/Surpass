SELECT 'age_category' AS field, COALESCE(age_category, 'NULL') AS value, COUNT(*) AS cnt
FROM dwh.vehicle
GROUP BY age_category

UNION ALL

SELECT 'is_first_owner' AS field, COALESCE(CAST(is_first_owner AS TEXT), 'NULL') AS value, COUNT(*) AS cnt
FROM dwh.vehicle
GROUP BY is_first_owner

UNION ALL

SELECT 'license_status' AS field, COALESCE(license_status, 'NULL') AS value, COUNT(*) AS cnt
FROM dwh.vehicle
GROUP BY license_status

UNION ALL

SELECT 'fuel_category' AS field, COALESCE(fuel_category, 'NULL') AS value, COUNT(*) AS cnt
FROM dwh.vehicle
GROUP BY fuel_category

UNION ALL

SELECT 'pollution_level' AS field, COALESCE(pollution_level, 'NULL') AS value, COUNT(*) AS cnt
FROM dwh.vehicle
GROUP BY pollution_level

UNION ALL

SELECT 'manufacturer_region' AS field, COALESCE(manufacturer_region, 'NULL') AS value, COUNT(*) AS cnt
FROM dwh.vehicle
GROUP BY manufacturer_region

ORDER BY field, cnt DESC;