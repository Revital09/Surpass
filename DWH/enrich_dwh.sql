-- ADD COLUMNS
ALTER TABLE dwh.vehicle
    ADD COLUMN IF NOT EXISTS vehicle_age            INTEGER,
    ADD COLUMN IF NOT EXISTS age_category           VARCHAR(20),
    ADD COLUMN IF NOT EXISTS years_since_registration INTEGER,
    ADD COLUMN IF NOT EXISTS is_first_owner         BOOLEAN,
    ADD COLUMN IF NOT EXISTS license_status         VARCHAR(20),
    ADD COLUMN IF NOT EXISTS fuel_category          VARCHAR(20),
    ADD COLUMN IF NOT EXISTS pollution_level        VARCHAR(20),
    ADD COLUMN IF NOT EXISTS manufacturer_region    VARCHAR(20);

-- UPDATE VALUES

-- 1. Vehicle Age
UPDATE dwh.vehicle
SET vehicle_age = 2026 - shnat_yitzur
WHERE shnat_yitzur IS NOT NULL;

-- 2. Age Category
UPDATE dwh.vehicle
SET age_category = CASE
    WHEN vehicle_age BETWEEN 0 AND 3  THEN 'New'
    WHEN vehicle_age BETWEEN 4 AND 7  THEN 'Recent'
    WHEN vehicle_age BETWEEN 8 AND 15 THEN 'Mature'
    WHEN vehicle_age >= 16            THEN 'Old'
    ELSE NULL
END;

-- 3. Years Since Registration
UPDATE dwh.vehicle
SET years_since_registration =
    EXTRACT(YEAR FROM AGE(
        CURRENT_DATE,
        TO_DATE(
            SPLIT_PART(moed_aliya_lakvish, '-', 1) || '-' ||
            LPAD(SPLIT_PART(moed_aliya_lakvish, '-', 2), 2, '0') || '-01',
            'YYYY-MM-DD'
        )
    ))::INTEGER
WHERE moed_aliya_lakvish ~ '^\d{4}-\d{1,2}$';

-- 4. Is First Owner
UPDATE dwh.vehicle
SET is_first_owner = (years_since_registration < 1)
WHERE years_since_registration IS NOT NULL;

-- 5. License Status
UPDATE dwh.vehicle
SET license_status = CASE
    WHEN tokef_dt IS NULL                               THEN 'Unknown'
    WHEN tokef_dt < CURRENT_DATE                        THEN 'Expired'
    WHEN tokef_dt <= CURRENT_DATE + INTERVAL '90 days'  THEN 'Expiring Soon'
    ELSE 'Active'
END;

-- 6. Fuel Category
UPDATE dwh.vehicle
SET fuel_category = CASE
    WHEN sug_delek_nm ILIKE '%בנזין%'   THEN 'Gasoline'
    WHEN sug_delek_nm ILIKE '%דיזל%'    THEN 'Diesel'
    WHEN sug_delek_nm ILIKE '%חשמל%'    THEN 'Electric'
    WHEN sug_delek_nm ILIKE '%היברידי%' THEN 'Hybrid'
    WHEN sug_delek_nm IS NULL           THEN NULL
    ELSE 'Other'
END;

-- 7. Pollution Level
UPDATE dwh.vehicle
SET pollution_level = CASE
    WHEN kvutzat_zihum BETWEEN 0  AND 5  THEN 'Low'
    WHEN kvutzat_zihum BETWEEN 6  AND 10 THEN 'Medium'
    WHEN kvutzat_zihum BETWEEN 11 AND 15 THEN 'High'
    WHEN kvutzat_zihum >= 16             THEN 'Very High'
    ELSE NULL
END;

-- 8. Manufacturer Region
UPDATE dwh.vehicle
SET manufacturer_region = CASE
    WHEN tozeret_nm ILIKE '%טויוטה%' OR tozeret_nm ILIKE '%הונדה%'
      OR tozeret_nm ILIKE '%מזדה%'   OR tozeret_nm ILIKE '%סובארו%'
      OR tozeret_nm ILIKE '%מיצובישי%' OR tozeret_nm ILIKE '%ניסאן%'
      OR tozeret_nm ILIKE '%לקסוס%'  OR tozeret_nm ILIKE '%סוזוקי%'   THEN 'Japanese'
    WHEN tozeret_nm ILIKE '%פולקסווגן%' OR tozeret_nm ILIKE '%מרצדס%'
      OR tozeret_nm ILIKE '%ב.מ.וו%'  OR tozeret_nm ILIKE '%אאודי%'
      OR tozeret_nm ILIKE '%פיג%'     OR tozeret_nm ILIKE '%רנו%'
      OR tozeret_nm ILIKE '%סיטרואן%' OR tozeret_nm ILIKE '%פיאט%'
      OR tozeret_nm ILIKE '%וולבו%'   OR tozeret_nm ILIKE '%סקודה%'   THEN 'European'
    WHEN tozeret_nm ILIKE '%פורד%'   OR tozeret_nm ILIKE '%ג''י.מ%'
      OR tozeret_nm ILIKE '%שברולט%' OR tozeret_nm ILIKE '%טסלה%'     THEN 'American'
    WHEN tozeret_nm ILIKE '%קיה%'    OR tozeret_nm ILIKE '%יונדאי%'
      OR tozeret_nm ILIKE '%סאנגיונג%'                                 THEN 'Korean'
    WHEN tozeret_nm ILIKE '%ג''ילי%' OR tozeret_nm ILIKE '%BYD%'
      OR tozeret_nm ILIKE '%חאווה%'  OR tozeret_nm ILIKE '%MG%'       THEN 'Chinese'
    ELSE 'Other'
END;

-- INDEXES
CREATE INDEX IF NOT EXISTS idx_vehicle_age_category      ON dwh.vehicle(age_category);
CREATE INDEX IF NOT EXISTS idx_vehicle_license_status    ON dwh.vehicle(license_status);
CREATE INDEX IF NOT EXISTS idx_vehicle_fuel_category     ON dwh.vehicle(fuel_category);
CREATE INDEX IF NOT EXISTS idx_vehicle_pollution_level   ON dwh.vehicle(pollution_level);
CREATE INDEX IF NOT EXISTS idx_vehicle_manufacturer_region ON dwh.vehicle(manufacturer_region);
CREATE INDEX IF NOT EXISTS idx_vehicle_shnat_yitzur      ON dwh.vehicle(shnat_yitzur);