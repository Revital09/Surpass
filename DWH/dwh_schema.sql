-- SCHEMA: mrr_fct
CREATE SCHEMA IF NOT EXISTS mrr_fct;

CREATE TABLE IF NOT EXISTS mrr_fct.vehicle (
    _id                      TEXT,
    mispar_rechev            TEXT,
    tozeret_cd               TEXT,
    sug_degem                TEXT,
    tozeret_nm               TEXT,
    degem_cd                 TEXT,
    degem_nm                 TEXT,
    ramat_gimur              TEXT,
    ramat_eivzur_betihuty    TEXT,
    kvutzat_zihum            TEXT,
    shnat_yitzur             TEXT,
    degem_manoa              TEXT,
    mivchan_acharon_dt       TEXT,
    tokef_dt                 TEXT,
    baalut                   TEXT,
    misgeret                 TEXT,
    tzeva_cd                 TEXT,
    tzeva_rechev             TEXT,
    zmig_kidmi               TEXT,
    zmig_ahori               TEXT,
    sug_delek_nm             TEXT,
    horaat_rishum            TEXT,
    moed_aliya_lakvish       TEXT,
    kinuy_mishari            TEXT
);

-- SCHEMA: dwh
CREATE SCHEMA IF NOT EXISTS dwh;

CREATE TABLE IF NOT EXISTS dwh.vehicle (
    _id                      INTEGER PRIMARY KEY,
    mispar_rechev            INTEGER,
    tozeret_cd               INTEGER,
    sug_degem                VARCHAR(10),
    tozeret_nm               VARCHAR(100),
    degem_cd                 INTEGER,
    degem_nm                 VARCHAR(100),
    ramat_gimur              VARCHAR(50),
    ramat_eivzur_betihuty    INTEGER,
    kvutzat_zihum            INTEGER,
    shnat_yitzur             INTEGER,
    degem_manoa              VARCHAR(50),
    mivchan_acharon_dt       DATE,
    tokef_dt                 DATE,
    baalut                   VARCHAR(50),
    misgeret                 VARCHAR(50),
    tzeva_cd                 INTEGER,
    tzeva_rechev             VARCHAR(50),
    zmig_kidmi               VARCHAR(30),
    zmig_ahori               VARCHAR(30),
    sug_delek_nm             VARCHAR(30),
    horaat_rishum            INTEGER,
    moed_aliya_lakvish       DATE,
    kinuy_mishari            VARCHAR(100),
    load_ts                  TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);