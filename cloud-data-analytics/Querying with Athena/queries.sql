-- 1. Create Database
CREATE DATABASE taxidata;

-- 2. Create External Table (Yellow Taxi Data)
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

-- 3. Query Analysis & Optimization Tests
SELECT * FROM "taxidata"."yellow" limit 10;
