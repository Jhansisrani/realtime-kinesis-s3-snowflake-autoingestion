```sql
-- ============================================================
-- STREAM + TASK + MERGE
-- ============================================================

USE DATABASE janu_kinesis;
USE SCHEMA streaming;

-- Create Task to process CDC changes automatically.
CREATE OR REPLACE TASK sales_cdc_task
    WAREHOUSE = compute_wh
    SCHEDULE = '1 MINUTE'
    WHEN SYSTEM$STREAM_HAS_DATA('sales_data_stream')
AS
MERGE INTO sales_data_prod AS target
USING (
    SELECT
        transaction_id,
        timestamp,
        customer_id,
        product_id,
        quantity,
        price_per_unit,
        total_price
    FROM sales_data_stream
    WHERE METADATA$ACTION = 'INSERT'
) AS source

ON target.transaction_id = source.transaction_id

WHEN MATCHED THEN
    UPDATE SET
        target.timestamp = source.timestamp,
        target.customer_id = source.customer_id,
        target.product_id = source.product_id,
        target.quantity = source.quantity,
        target.price_per_unit = source.price_per_unit,
        target.total_price = source.total_price

WHEN NOT MATCHED THEN
    INSERT (
        transaction_id,
        timestamp,
        customer_id,
        product_id,
        quantity,
        price_per_unit,
        total_price
    )
    VALUES (
        source.transaction_id,
        source.timestamp,
        source.customer_id,
        source.product_id,
        source.quantity,
        source.price_per_unit,
        source.total_price
    );


-- Check Task definition.
SHOW TASKS;


-- Start the Task.
ALTER TASK sales_cdc_task RESUME;


-- Check the target table.
SELECT * FROM sales_data_prod;
```
