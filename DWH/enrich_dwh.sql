-- ADD COLUMNS
ALTER TABLE dwh.vehicle
    ADD COLUMN IF NOT EXISTS vehicle_age INTEGER,
    ADD COLUMN IF NOT EXISTS age_category VARCHAR(20),
    ADD COLUMN IF NOT EXISTS years_since_registration INTEGER,
    ADD COLUMN IF NOT EXISTS is_first_owner BOOLEAN,
    ADD COLUMN IF NOT EXISTS license_status VARCHAR(20),
    ADD COLUMN IF NOT EXISTS fuel_category VARCHAR(20),
    ADD COLUMN IF NOT EXISTS pollution_level VARCHAR(20),
    ADD COLUMN IF NOT EXISTS manufacturer_region VARCHAR(20);


-- 1. Vehicle Age
UPDATE dwh.vehicle
SET vehicle_age = 2026 - shnat_yitzur
WHERE shnat_yitzur IS NOT NULL;

-- Age Category
UPDATE dwh.vehicle
SET age_category = CASE
    WHEN vehicle_age BETWEEN 0 AND 3  THEN 'New'
    WHEN vehicle_age BETWEEN 4 AND 7  THEN 'Recent'
    WHEN vehicle_age BETWEEN 8 AND 15 THEN 'Mature'
    WHEN vehicle_age >= 16            THEN 'Old'
    ELSE NULL
END
WHERE vehicle_age IS NOT NULL;

-- 2. Years Since Registration
UPDATE dwh.vehicle
SET years_since_registration =
    EXTRACT(YEAR FROM AGE(CURRENT_DATE, moed_aliya_lakvish))::INTEGER
WHERE moed_aliya_lakvish IS NOT NULL;

-- First Owner
UPDATE dwh.vehicle
SET is_first_owner = (years_since_registration < 1)
WHERE years_since_registration IS NOT NULL;

-- 3. License Status
UPDATE dwh.vehicle
SET license_status = CASE
    WHEN tokef_dt IS NULL                               THEN 'Unknown'
    WHEN tokef_dt < CURRENT_DATE                        THEN 'Expired'
    WHEN tokef_dt <= CURRENT_DATE + INTERVAL '90 days'  THEN 'Expiring Soon'
    ELSE 'Active'
END
WHERE license_status IS NOT NULL;

-- 4. Fuel Category
UPDATE dwh.vehicle
SET fuel_category = CASE
    WHEN sug_delek_nm IS NULL                    THEN NULL
    WHEN TRIM(sug_delek_nm) = 'חשמל/בנזין'      THEN 'Hybrid'
    WHEN TRIM(sug_delek_nm) = 'חשמל/דיזל'       THEN 'Hybrid'
    WHEN TRIM(sug_delek_nm) = 'בנזין'           THEN 'Gasoline'
    WHEN TRIM(sug_delek_nm) = 'דיזל'            THEN 'Diesel'
    WHEN TRIM(sug_delek_nm) = 'חשמל'            THEN 'Electric'
    WHEN TRIM(sug_delek_nm) = 'גפ"מ'            THEN 'Other'
    ELSE 'Other'
END
WHERE fuel_category IS NOT NULL;

-- 5. Environmental Classification
UPDATE dwh.vehicle
SET pollution_level = CASE
    WHEN kvutzat_zihum BETWEEN 0  AND 5  THEN 'Low'
    WHEN kvutzat_zihum BETWEEN 6  AND 10 THEN 'Medium'
    WHEN kvutzat_zihum BETWEEN 11 AND 15 THEN 'High'
    WHEN kvutzat_zihum >= 16             THEN 'Very High'
    ELSE NULL
END
WHERE pollution_level IS NOT NULL;

-- 6. Manufacturer Region
UPDATE dwh.vehicle
SET manufacturer_region = CASE
    WHEN tozeret_nm IN ('טויוטה', 'הונדה', 'מזדה', 'סובארו', 'מיצובישי', 'ניסאן', 'לקסוס', 'סוזוקי')
        THEN 'Japanese'
    WHEN tozeret_nm IN ('פולקסווגן', 'מרצדס', 'ב.מ.וו', 'אאודי', 'פיג''ו', 'רנו', 'סיטרואן', 'פיאט', 'וולבו', 'סקודה',
                        'אופל', 'סיאט', 'דאציה', 'סמארט', 'פורשה', 'יגואר', 'לנד רובר', 'מיני', 'סאאב', 'לנציה', 'די.אס', 'פולסטאר')
        THEN 'European'
    WHEN tozeret_nm IN ('פורד', 'שברולט', 'טסלה', 'ביואיק', 'קאדילאק', 'קרייזלר', 'דודג''', 'האמר', 'לינקולן', 'ג''יפ', 'ג''י.אם.סי')
        THEN 'American'
    WHEN tozeret_nm IN ('קיה', 'יונדאי', 'סאנגיונג')
        THEN 'Korean'
    WHEN tozeret_nm IN ('גילי', 'גרייט וול', 'ניאו', 'גי.אי.סי')
        THEN 'Chinese'
    ELSE 'Other'
END
WHERE manufacturer_region IS NOT NULL;


-- INDEXES
CREATE INDEX IF NOT EXISTS idx_vehicle_age_category
    ON dwh.vehicle(age_category);

CREATE INDEX IF NOT EXISTS idx_vehicle_license_status
    ON dwh.vehicle(license_status);

CREATE INDEX IF NOT EXISTS idx_vehicle_fuel_category
    ON dwh.vehicle(fuel_category);

CREATE INDEX IF NOT EXISTS idx_vehicle_pollution_level
    ON dwh.vehicle(pollution_level);

CREATE INDEX IF NOT EXISTS idx_vehicle_manufacturer_region
    ON dwh.vehicle(manufacturer_region);

CREATE INDEX IF NOT EXISTS idx_vehicle_shnat_yitzur
    ON dwh.vehicle(shnat_yitzur);