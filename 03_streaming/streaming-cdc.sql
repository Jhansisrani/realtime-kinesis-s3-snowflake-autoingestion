```sql
-- ============================================================
-- CDC STREAM
-- ============================================================

USE DATABASE janu_kinesis;
USE SCHEMA streaming;

-- Source table where new/changed sales records arrive.
CREATE OR REPLACE TABLE sales_data_raw (
    transaction_id INTEGER,
    timestamp TIMESTAMP,
    customer_id INTEGER,
    product_id INTEGER,
    quantity INTEGER,
    price_per_unit FLOAT,
    total_price FLOAT
);

-- Production/target table.
CREATE OR REPLACE TABLE sales_data_prod (
    transaction_id INTEGER,
    timestamp TIMESTAMP,
    customer_id INTEGER,
    product_id INTEGER,
    quantity INTEGER,
    price_per_unit FLOAT,
    total_price FLOAT
);

-- Create a standard Stream to capture CDC changes.
CREATE OR REPLACE STREAM sales_data_stream ON TABLE sales_data_raw;

-- Check the Stream.
SELECT * FROM sales_data_stream;

-- Test data.
INSERT INTO sales_data_raw
VALUES
(100001, CURRENT_TIMESTAMP(), 1001, 101, 2, 25.00, 50.00),
(100002, CURRENT_TIMESTAMP(), 1002, 102, 3, 30.00, 90.00);

-- View captured CDC records.
SELECT * FROM sales_data_stream;

-- Check the CDC action.
SELECT
    transaction_id,
    customer_id,
    quantity,
    total_price,
    METADATA$ACTION,
    METADATA$ISUPDATE
FROM sales_data_stream;
```
