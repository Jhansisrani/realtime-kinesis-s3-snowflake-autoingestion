-- ============================================================
-- TEST MANUAL INGESTION
-- ============================================================

-- First test:
-- S3 CSV files → Snowflake sales_data1
COPY INTO sales_data1 FROM @sales_stg1
ON_ERROR = CONTINUE;


SELECT * FROM sales_data1;


-- ============================================================
-- SNOWPIPE AUTOMATIC INGESTION
-- ============================================================

-- Snowpipe automatically loads new files
-- arriving in the S3 location into sales_data1.

CREATE OR REPLACE PIPE sales_datapipe1   AUTO_INGEST = TRUE
AS
COPY INTO sales_data1 FROM @sales_stg1
ON_ERROR = CONTINUE;


-- Check Snowpipe configuration.
SHOW PIPES;


-- Check loaded data.
SELECT * FROM sales_data1;
