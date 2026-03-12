CREATE OR REPLACE PROCEDURE dwh.load_vehicle()
LANGUAGE plpgsql
AS $$
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

    WITH cleaned AS (
        SELECT
            NULLIF(LOWER(TRIM(COALESCE(_id,''))), 'null') AS _id,
            NULLIF(LOWER(TRIM(COALESCE(mispar_rechev,''))), 'null') AS mispar_rechev,
            NULLIF(LOWER(TRIM(COALESCE(tozeret_cd,''))), 'null') AS tozeret_cd,
            NULLIF(LOWER(TRIM(COALESCE(degem_cd,''))), 'null') AS degem_cd,
            NULLIF(LOWER(TRIM(COALESCE(ramat_eivzur_betihuty,''))), 'null') AS ramat_eivzur_betihuty,
            NULLIF(LOWER(TRIM(COALESCE(kvutzat_zihum,''))), 'null') AS kvutzat_zihum,
            NULLIF(LOWER(TRIM(COALESCE(shnat_yitzur,''))), 'null') AS shnat_yitzur,
            NULLIF(LOWER(TRIM(COALESCE(mivchan_acharon_dt,''))), 'null') AS mivchan_acharon_dt,
            NULLIF(LOWER(TRIM(COALESCE(tokef_dt,''))), 'null') AS tokef_dt,
            NULLIF(LOWER(TRIM(COALESCE(tzeva_cd,''))), 'null') AS tzeva_cd,
            NULLIF(LOWER(TRIM(COALESCE(horaat_rishum,''))), 'null') AS horaat_rishum,
            NULLIF(LOWER(TRIM(COALESCE(moed_aliya_lakvish,''))), 'null') AS moed_aliya_lakvish,

            CASE
                WHEN LOWER(TRIM(COALESCE(sug_degem,''))) IN ('', 'null', 'none', '<null>')
                THEN NULL ELSE TRIM(sug_degem)
            END AS sug_degem,

            CASE
                WHEN LOWER(TRIM(COALESCE(degem_nm,''))) IN ('', 'null', 'none', '<null>')
                THEN NULL ELSE TRIM(degem_nm)
            END AS degem_nm,

            CASE
                WHEN LOWER(TRIM(COALESCE(ramat_gimur,''))) IN ('', 'null', 'none', '<null>')
                THEN NULL ELSE TRIM(ramat_gimur)
            END AS ramat_gimur,

            CASE
                WHEN LOWER(TRIM(COALESCE(degem_manoa,''))) IN ('', 'null', 'none', '<null>')
                THEN NULL ELSE TRIM(degem_manoa)
            END AS degem_manoa,

            CASE
                WHEN LOWER(TRIM(COALESCE(baalut,''))) IN ('', 'null', 'none', '<null>')
                THEN NULL ELSE TRIM(baalut)
            END AS baalut,

            CASE
                WHEN LOWER(TRIM(COALESCE(misgeret,''))) IN ('', 'null', 'none', '<null>')
                THEN NULL ELSE TRIM(misgeret)
            END AS misgeret,

            CASE
                WHEN LOWER(TRIM(COALESCE(tzeva_rechev,''))) IN ('', 'null', 'none', '<null>')
                THEN NULL ELSE TRIM(tzeva_rechev)
            END AS tzeva_rechev,

            CASE
                WHEN LOWER(TRIM(COALESCE(zmig_kidmi,''))) IN ('', 'null', 'none', '<null>')
                THEN NULL ELSE TRIM(zmig_kidmi)
            END AS zmig_kidmi,

            CASE
                WHEN LOWER(TRIM(COALESCE(zmig_ahori,''))) IN ('', 'null', 'none', '<null>')
                THEN NULL ELSE TRIM(zmig_ahori)
            END AS zmig_ahori,

            CASE
                WHEN LOWER(TRIM(COALESCE(sug_delek_nm,''))) IN ('', 'null', 'none', '<null>')
                THEN NULL ELSE TRIM(sug_delek_nm)
            END AS sug_delek_nm,

            CASE
                WHEN LOWER(TRIM(COALESCE(kinuy_mishari,''))) IN ('', 'null', 'none', '<null>')
                THEN NULL ELSE TRIM(kinuy_mishari)
            END AS kinuy_mishari,

            -- standardize manufacturer name variations
            CASE
                WHEN LOWER(TRIM(COALESCE(tozeret_nm, ''))) IN ('', 'null', 'none', '<null>')
                    THEN NULL

                WHEN TRIM(tozeret_nm) ILIKE '%אאודי%' OR TRIM(tozeret_nm) ILIKE '%אודי%'
                    THEN 'אאודי'
                WHEN TRIM(tozeret_nm) ILIKE '%אופל%'
                    THEN 'אופל'
                WHEN TRIM(tozeret_nm) ILIKE '%ב מ וו%' OR TRIM(tozeret_nm) ILIKE '%BMW%'
                    THEN 'ב.מ.וו'
                WHEN TRIM(tozeret_nm) ILIKE '%ביואיק%'
                    THEN 'ביואיק'
                WHEN TRIM(tozeret_nm) ILIKE '%וולבו%'
                    THEN 'וולבו'
                WHEN TRIM(tozeret_nm) ILIKE '%טויוטה%'
                    THEN 'טויוטה'
                WHEN TRIM(tozeret_nm) ILIKE '%טסלה%'
                    THEN 'טסלה'
                WHEN TRIM(tozeret_nm) ILIKE '%יונדאי%'
                    THEN 'יונדאי'
                WHEN TRIM(tozeret_nm) ILIKE '%יגואר%'
                    THEN 'יגואר'
                WHEN TRIM(tozeret_nm) ILIKE '%לנדרובר%'
                    THEN 'לנד רובר'
                WHEN TRIM(tozeret_nm) ILIKE '%לקסוס%'
                    THEN 'לקסוס'
                WHEN TRIM(tozeret_nm) ILIKE '%מזדה%'
                    THEN 'מזדה'
                WHEN TRIM(tozeret_nm) ILIKE '%מיני%'
                    THEN 'מיני'
                WHEN TRIM(tozeret_nm) ILIKE '%מיצובישי%'
                    THEN 'מיצובישי'
                WHEN TRIM(tozeret_nm) ILIKE '%מרצדס%' OR TRIM(tozeret_nm) ILIKE '%דימלרקריזלר%'
                    THEN 'מרצדס'
                WHEN TRIM(tozeret_nm) ILIKE '%ניאו%'
                    THEN 'ניאו'
                WHEN TRIM(tozeret_nm) ILIKE '%ניסאן%'
                    THEN 'ניסאן'
                WHEN TRIM(tozeret_nm) ILIKE '%סאאב%'
                    THEN 'סאאב'
                WHEN TRIM(tozeret_nm) ILIKE '%סאנגיונג%'
                    THEN 'סאנגיונג'
                WHEN TRIM(tozeret_nm) ILIKE '%סובארו%'
                    THEN 'סובארו'
                WHEN TRIM(tozeret_nm) ILIKE '%סוזוקי%' OR TRIM(tozeret_nm) ILIKE '%מרוטי%'
                    THEN 'סוזוקי'
                WHEN TRIM(tozeret_nm) ILIKE '%סיאט%'
                    THEN 'סיאט'
                WHEN TRIM(tozeret_nm) ILIKE '%סיטרואן%'
                    THEN 'סיטרואן'
                WHEN TRIM(tozeret_nm) ILIKE '%סקודה%'
                    THEN 'סקודה'
                WHEN TRIM(tozeret_nm) ILIKE '%סמארט%'
                    THEN 'סמארט'
                WHEN TRIM(tozeret_nm) ILIKE '%דאציה%'
                    THEN 'דאציה'
                WHEN TRIM(tozeret_nm) ILIKE '%דודג%'
                    THEN 'דודג'''
                WHEN TRIM(tozeret_nm) ILIKE '%דייהטסו%'
                    THEN 'דייהטסו'
                WHEN TRIM(tozeret_nm) ILIKE '%דייהו%'
                    THEN 'דייהו'
                WHEN TRIM(tozeret_nm) ILIKE '%האמר%'
                    THEN 'האמר'
                WHEN TRIM(tozeret_nm) ILIKE '%הונדה%'
                    THEN 'הונדה'
                WHEN TRIM(tozeret_nm) ILIKE '%פולקסווגן%'
                    THEN 'פולקסווגן'
                WHEN TRIM(tozeret_nm) ILIKE '%פולסטאר%'
                    THEN 'פולסטאר'
                WHEN TRIM(tozeret_nm) ILIKE '%פורד%'
                    THEN 'פורד'
                WHEN TRIM(tozeret_nm) ILIKE '%פורשה%'
                    THEN 'פורשה'
                WHEN TRIM(tozeret_nm) ILIKE '%פיאט%'
                    THEN 'פיאט'
                WHEN TRIM(tozeret_nm) ILIKE '%פיג%'
                    THEN 'פיג''ו'
                WHEN TRIM(tozeret_nm) ILIKE '%קאדילאק%'
                    THEN 'קאדילאק'
                WHEN TRIM(tozeret_nm) ILIKE '%קיה%'
                    THEN 'קיה'
                WHEN TRIM(tozeret_nm) ILIKE '%קרייזלר%'
                    THEN 'קרייזלר'
                WHEN TRIM(tozeret_nm) ILIKE '%רנו%'
                    THEN 'רנו'
                WHEN TRIM(tozeret_nm) ILIKE '%שברולט%'
                    THEN 'שברולט'
                WHEN TRIM(tozeret_nm) ILIKE '%איסוזו%'
                    THEN 'איסוזו'
                WHEN TRIM(tozeret_nm) ILIKE '%לינקולן%'
                    THEN 'לינקולן'
                WHEN TRIM(tozeret_nm) ILIKE '%לנציה%' OR TRIM(tozeret_nm) ILIKE '%לנצ''יה%'
                    THEN 'לנציה'
                WHEN TRIM(tozeret_nm) ILIKE '%די אס%' OR TRIM(tozeret_nm) ILIKE '%די.אס%'
                    THEN 'די.אס'
                WHEN TRIM(tozeret_nm) ILIKE '%גיפ%' OR TRIM(tozeret_nm) ILIKE '%ג''יפ%'
                    THEN 'ג''יפ'
                WHEN TRIM(tozeret_nm) ILIKE '%ג''י.אמ.סי%' OR TRIM(tozeret_nm) ILIKE '%ג''יי.אמ.סי%'
                    THEN 'ג''י.אם.סי'
                WHEN TRIM(tozeret_nm) ILIKE '%גי.אי.סי%' OR TRIM(tozeret_nm) ILIKE '%גיי.איי.סי%'
                    THEN 'גי.אי.סי'
                WHEN TRIM(tozeret_nm) ILIKE '%בי ווי די%' OR TRIM(tozeret_nm) ILIKE '%BYD%'
                    THEN 'BYD'
                WHEN TRIM(tozeret_nm) ILIKE '%גילי%'
                    THEN 'גילי'
                WHEN TRIM(tozeret_nm) ILIKE '%מ.ג%'
                    THEN 'MG'
                WHEN TRIM(tozeret_nm) ILIKE '%גרייט וול%'
                    THEN 'גרייט וול'
            ELSE TRIM(tozeret_nm)
            END AS tozeret_nm

        FROM mrr_fct.vehicle
        WHERE NULLIF(TRIM(COALESCE(_id, '')), '') IS NOT NULL
    )

    SELECT
        CASE
            WHEN _id ~ '^\d+$'
            THEN _id::INTEGER
        END,

        CASE
            WHEN mispar_rechev ~ '^\d+$'
            THEN mispar_rechev::INTEGER
        END,

        CASE
            WHEN tozeret_cd ~ '^\d+$'
            THEN tozeret_cd::INTEGER
        END,

        sug_degem,
        tozeret_nm,

        CASE
            WHEN degem_cd ~ '^\d+$'
            THEN degem_cd::INTEGER
        END,

        degem_nm,
        ramat_gimur,

        CASE
            WHEN ramat_eivzur_betihuty ~ '^\d+(\.\d+)?$'
            THEN ramat_eivzur_betihuty::NUMERIC::INTEGER
        END,

        CASE
            WHEN kvutzat_zihum ~ '^\d+(\.\d+)?$'
            THEN kvutzat_zihum::NUMERIC::INTEGER
        END,

        CASE
            WHEN shnat_yitzur ~ '^\d+$'
                  AND shnat_yitzur::INTEGER BETWEEN 1900 AND 2026
            THEN shnat_yitzur::INTEGER
        END,

        degem_manoa,

        CASE
            WHEN mivchan_acharon_dt ~ '^\d{4}-\d{2}-\d{2}$'
            THEN mivchan_acharon_dt::DATE
        END,

        CASE
            WHEN tokef_dt ~ '^\d{4}-\d{2}-\d{2}$'
            THEN tokef_dt::DATE
        END,

        baalut,
        misgeret,
        CASE
            WHEN tzeva_cd ~ '^\d+$'
            THEN tzeva_cd::INTEGER
        END,

        tzeva_rechev,
        zmig_kidmi,
        zmig_ahori,
        sug_delek_nm,

        CASE
            WHEN horaat_rishum ~ '^\d+(\.\d+)?$'
            THEN horaat_rishum::NUMERIC::INTEGER
        END,

        CASE
            WHEN moed_aliya_lakvish ~ '^\d{4}-\d{1,2}$'
            THEN TO_DATE(moed_aliya_lakvish || '-01', 'YYYY-MM-DD')
        END,

        kinuy_mishari

    FROM cleaned;

END;
$$;

CALL dwh.load_vehicle();
