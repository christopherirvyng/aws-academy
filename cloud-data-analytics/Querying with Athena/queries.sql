-- ============================================================
-- LAB: QUERYING DATA BY USING ATHENA & AWS GLUE
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
LOCATION 's3://aws-tc-largeobjects/CUR-TF-200-ACDSCI-1/Lab2/January2017/'
TBLPROPERTIES ('has_encrypted_data'='false');

-- 2. Test Query 1: Unoptimized Filter Query against Full Dataset
SELECT count(count) AS "Number of trips",
       sum(total) AS "Total fares",
       pickup AS "Trip date" 
FROM yellow 
WHERE pickup BETWEEN TIMESTAMP '2017-01-01 00:00:00' AND TIMESTAMP '2017-02-01 00:00:01' 
GROUP BY pickup;

-- 3. Test Query 2: Optimized Query against Bucketized Dataset
SELECT count(count) AS "Number of trips",
       sum(total) AS "Total fares",
       pickup AS "Trip date" 
FROM jan 
GROUP BY pickup;


-- ------------------------------------------------------------
-- TASK 3: Optimizing Athena Queries by Using Partitions
-- ------------------------------------------------------------

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


-- ------------------------------------------------------------
-- TASK 4: Creating Views in Athena for Data Analysis
-- ------------------------------------------------------------

-- 1. Create View for Credit Card Transactions (paytype = '1')
CREATE VIEW cctrips AS
SELECT vendor, count, distance, fare, tip, tolls, total
FROM yellow
WHERE paytype = '1';

-- 2. Create View for Cash Transactions (paytype = '2')
CREATE VIEW cashtrips AS
SELECT vendor, count, distance, fare, tip, tolls, total
FROM yellow
WHERE paytype = '2';

-- 3. Query Credit Card Trips View
SELECT * FROM cctrips;

-- 4. Query Cash Trips View
SELECT * FROM cashtrips;

-- 5. Step 18: Create Joined View to Compare Credit Card vs Cash Payments (comparepay)
CREATE VIEW comparepay AS
WITH
  cc AS
  (SELECT sum(fare) AS cctotal,
         vendor
   FROM yellow
   WHERE paytype = '1'
   GROUP BY paytype, vendor),
  cs AS
  (SELECT sum(fare) AS cashtotal,
         vendor, paytype
   FROM yellow
   WHERE paytype = '2'
   GROUP BY paytype, vendor)
SELECT cc.cctotal, cs.cashtotal
FROM cc
JOIN cs
  ON cc.vendor = cs.vendor;

-- 6. Step 19: Query comparepay View
SELECT * FROM comparepay;
