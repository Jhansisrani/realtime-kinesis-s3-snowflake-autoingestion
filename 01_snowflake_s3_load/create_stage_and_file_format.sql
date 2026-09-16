-- ============================================================
-- AWS S3 → SNOWFLAKE CONNECTION
-- ============================================================

USE ROLE ACCOUNTADMIN;

-- Storage Integration creates the secure connection
-- between Snowflake and the AWS S3 location.

CREATE OR REPLACE STORAGE INTEGRATION aws_sf_data2
  TYPE = EXTERNAL_STAGE
  STORAGE_PROVIDER = S3
  ENABLED = TRUE
  STORAGE_AWS_ROLE_ARN = 'arn:aws:iam::<>'
  STORAGE_ALLOWED_LOCATIONS =
    ('s3://<>path/');




-- These details are used when configuring the AWS IAM trust relationship.

DESC INTEGRATION aws_sf_data2;
-- Check the integration details.


-- ============================================================
-- DATABASE / SCHEMA
-- ============================================================

USE ROLE SYSADMIN;

CREATE OR REPLACE DATABASE janu_kinesis;

USE DATABASE janu_kinesis;

CREATE SCHEMA streaming;

USE SCHEMA streaming;


-- ============================================================
-- TARGET TABLE
-- ============================================================

CREATE TABLE sales_data1 (
    transaction_id INTEGER,
    timestamp TIMESTAMP,
    customer_id INTEGER,
    product_id INTEGER,
    quantity INTEGER,
    price_per_unit FLOAT,
    total_price FLOAT
);


-- ============================================================
-- CSV FILE FORMAT
-- ============================================================

CREATE OR REPLACE FILE FORMAT my_csv_format
  TYPE = 'CSV'
  FIELD_OPTIONALLY_ENCLOSED_BY = '"'
  SKIP_HEADER = 1
  FIELD_DELIMITER = ','
  NULL_IF = ('NULL', 'null');


-- ============================================================
-- S3 → SNOWFLAKE STAGE
-- ============================================================

CREATE OR REPLACE STAGE sales_stg1

  -- Uses the secure AWS/Snowflake integration
  STORAGE_INTEGRATION = aws_sf_data2

  -- This is the same S3 location where Python created the CSV files.
  URL = 's3://<path>/'

  -- Tell Snowflake how to read the CSV files.
  FILE_FORMAT = my_csv_format;


-- Check files visible through the Snowflake stage.
LIST @sales_stg1;

