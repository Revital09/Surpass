CREATE OR REPLACE PROCEDURE dwh.load_vehicle()
LANGUAGE plpgsql AS $$
BEGIN

TRUNCATE TABLE dwh.vehicle;

INSERT INTO dwh.vehicle (
    _id, mispar_rechev, tozeret_cd, sug_degem, tozeret_nm,
    degem_cd, degem_nm, ramat_gimur, ramat_eivzur_betihuty,
    kvutzat_zihum, shnat_yitzur, degem_manoa, mivchan_acharon_dt,
    tokef_dt, baalut, misgeret, tzeva_cd, tzeva_rechev,
    zmig_kidmi, zmig_ahori, sug_delek_nm, horaat_rishum,
    moed_aliya_lakvish, kinuy_mishari
)
SELECT
    -- INTEGER fields
    CASE WHEN TRIM(_id) ~ '^\d+$' THEN TRIM(_id)::INTEGER END,
    CASE WHEN TRIM(mispar_rechev) ~ '^\d+$' THEN TRIM(mispar_rechev)::INTEGER END,
    CASE WHEN TRIM(tozeret_cd) ~ '^\d+$' THEN TRIM(tozeret_cd)::INTEGER END,

    -- TEXT fields - trim + null handling
    NULLIF(TRIM(sug_degem), ''),
    NULLIF(TRIM(tozeret_nm), ''),

    CASE WHEN TRIM(degem_cd) ~ '^\d+$' THEN TRIM(degem_cd)::INTEGER END,
    NULLIF(TRIM(degem_nm), ''),
    NULLIF(TRIM(ramat_gimur), ''),

    -- FLOAT → INTEGER
    CASE WHEN TRIM(ramat_eivzur_betihuty) ~ '^\d+(\.\d+)?$'
         THEN TRIM(ramat_eivzur_betihuty)::NUMERIC::INTEGER END,
    CASE WHEN TRIM(kvutzat_zihum) ~ '^\d+(\.\d+)?$'
         THEN TRIM(kvutzat_zihum)::NUMERIC::INTEGER END,

    -- shnat_yitzur with validation 1900-2026
    CASE WHEN TRIM(shnat_yitzur) ~ '^\d+$'
              AND TRIM(shnat_yitzur)::INTEGER BETWEEN 1900 AND 2026
         THEN TRIM(shnat_yitzur)::INTEGER END,

    NULLIF(TRIM(degem_manoa), ''),

    -- DATE fields
    CASE WHEN TRIM(mivchan_acharon_dt) ~ '^\d{4}-\d{2}-\d{2}$'
         THEN TRIM(mivchan_acharon_dt)::DATE END,
    CASE WHEN TRIM(tokef_dt) ~ '^\d{4}-\d{2}-\d{2}$'
         THEN TRIM(tokef_dt)::DATE END,

    NULLIF(TRIM(baalut), ''),
    NULLIF(TRIM(misgeret), ''),

    CASE WHEN TRIM(tzeva_cd) ~ '^\d+$' THEN TRIM(tzeva_cd)::INTEGER END,
    NULLIF(TRIM(tzeva_rechev), ''),
    NULLIF(TRIM(zmig_kidmi), ''),
    NULLIF(TRIM(zmig_ahori), ''),
    NULLIF(TRIM(sug_delek_nm), ''),

    CASE WHEN TRIM(horaat_rishum) ~ '^\d+(\.\d+)?$'
         THEN TRIM(horaat_rishum)::NUMERIC::INTEGER END,

    -- moed_aliya_lakvish נשמר כ-VARCHAR כי פורמט "2017-5"
    NULLIF(TRIM(moed_aliya_lakvish), ''),
    NULLIF(TRIM(kinuy_mishari), '')

FROM mrr_fct.vehicle
WHERE TRIM(_id) ~ '^\d+$';  -- רק שורות עם _id תקין

END;
$$;

-- הרצת הפרוצדורה
CALL dwh.load_vehicle();