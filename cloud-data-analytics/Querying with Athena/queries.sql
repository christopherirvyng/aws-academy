-- ============================================================
-- LAB 1: QUERYING DATA BY USING ATHENA & AWS GLUE
-- Repository Path: aws-academy/cloud-data-analytics/Querying with Athena/queries.sql
-- ============================================================

-- ------------------------------------------------------------
-- TASK 1: Creating and Querying AWS Glue Database & Table
-- ------------------------------------------------------------

-- 1. Create AWS Glue Database
CREATE DATABASE IF NOT EXISTS taxidata;

-- 2. Create External Table for Full Taxi Dataset (S3 CSV Source)
CREATE EXTERNAL TABLE IF NOT EXISTS taxidata.yellow (
    vendor string,
    pickup timestamp,
    dropoff timestamp,
    count int,
    distance int,
    ratecode string,
    storeflag string,
    pulocid string,
    dolocid string,
    paytype string,
    fare decimal,
    extra decimal,
    mta_tax decimal,
    tip decimal,
    tolls decimal,
    surcharge decimal,
    total decimal
)
ROW FORMAT SERDE 'org.apache.hadoop.hive.serde2.lazy.LazySimpleSerDe'
WITH SERDEPROPERTIES (
    'serialization.format' = ',',
    'field.delim' = ','
) 
LOCATION 's3://aws-tc-largeobjects/CUR-TF-200-ACDSCI-1/Lab2/yellow/' 
TBLPROPERTIES ('has_encrypted_data'='false');

-- 3. Preview/Test Query Full Table
SELECT * FROM taxidata.yellow LIMIT 10;


-- ------------------------------------------------------------
-- TASK 2: Optimizing Athena Queries by Using Buckets
-- ------------------------------------------------------------

-- 1. Create External Table for January Bucketized Dataset
CREATE EXTERNAL TABLE IF NOT EXISTS taxidata.jan (
    vendor string,
    pickup timestamp,
    dropoff timestamp,
    count int,
    distance int,
    ratecode string,
    storeflag string,
    pulocid string,
    dolocid string,
    paytype string,
    fare decimal,
    extra decimal,
    mta_tax decimal,
    tip decimal,
    tolls decimal,
    surcharge decimal,
    total decimal
)
ROW FORMAT SERDE 'org.apache.hadoop.hive.serde2.lazy.LazySimpleSerDe'
WITH SERDEPROPERTIES (
    'serialization.format' = ',',
    'field.delim' = ','
)
LOCATION 's3://aws-tc-largeobjects/CUR-TF-200-ACDSCI-1/Lab2/jan/'
TBLPROPERTIES ('has_encrypted_data'='false');

-- 2. Test Query 1: Unoptimized Filter Query against Full Dataset
SELECT * FROM taxidata.yellow 
WHERE pickup >= TIMESTAMP '2017-01-01 00:00:00' 
  AND pickup < TIMESTAMP '2017-02-01 00:00:00';

-- 3. Test Query 2: Optimized Query against Bucketized Dataset
SELECT * FROM taxidata.jan;

-- ============================================================
-- TASK 3: Optimizing Athena Queries by Using Partitions
-- ============================================================

-- 1. Create Partitioned Table in Parquet Format (Partitioned by paytype)
CREATE TABLE taxidata.parquet_paytype
WITH (
    format = 'PARQUET',
    external_location = 's3://aws-tc-largeobjects/CUR-TF-200-ACDSCI-1/Lab2/paytype/',
    partitioned_by = ARRAY['paytype']
) AS
SELECT 
    vendor, pickup, dropoff, count, distance, ratecode, 
    storeflag, pulocid, dolocid, fare, extra, mta_tax, 
    tip, tolls, surcharge, total, paytype
FROM taxidata.yellow;

-- 2. Test Query against Partitioned Table (Filtering Cash Payments: paytype = '2')
SELECT * FROM taxidata.parquet_paytype 
WHERE paytype = '2';
