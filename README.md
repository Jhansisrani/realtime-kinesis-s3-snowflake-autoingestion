# Real-Time Sales Data Ingestion Pipeline

## Project Overview

This project demonstrates a real-time sales data ingestion and incremental processing pipeline using **Python, Boto3, Amazon Kinesis, AWS S3, and Snowflake**.

Simulated sales transactions are generated using Python and sent to Amazon Kinesis. The same generated records are converted to CSV files and uploaded to Amazon S3. Snowflake then ingests the S3 files using an External Stage and Snowpipe.

Snowflake Streams, Tasks, and MERGE logic are used to demonstrate incremental change processing into a downstream production table.

---

## Architecture

```text
                    Python Application
                           |
                   generate_sales_data()
                           |
              +------------+------------+
              |                         |
              ↓                         ↓
        Amazon Kinesis              CSV Creation
       sales-e2e-stream                 |
                                        ↓
                                  Amazon S3 Bucket
                                        |
                                        ↓
                              Snowflake External Stage
                                        |
                                        ↓
                                    Snowpipe
                                        |
                                        ↓
                                  sales_data_raw 
                              (Raw / Landing Table)
                                        |
                                        ↓
                              sales_data_stream
                                  (CDC Stream)
                                        |
                                        ↓
                                  Snowflake Task
                                        |
                                        ↓
                                      MERGE
                                        |
                                        ↓
                                sales_data_prod
                              (Target Table)
```

### Important

Amazon Kinesis and Amazon S3 are two destinations for the generated sales records.

The Snowflake ingestion path demonstrated in this project is:

**Python → CSV → S3 → Snowflake Stage → Snowpipe → Snowflake**

Kinesis is used separately to demonstrate real-time event streaming with AWS.

---

## Technologies

* **Python**
* **Boto3**
* **Amazon Kinesis**
* **Amazon S3**
* **Snowflake**
* **Snowflake Snowpipe**
* **Snowflake Streams**
* **Snowflake Tasks**
* **SQL**
* **SQL MERGE**

---

## Project Components

### 1. Python Sales Data Generator

A Python application generates simulated sales transactions with fields such as:

* Transaction ID
* Timestamp
* Customer ID
* Product ID
* Quantity
* Price per unit
* Total price

The application generates test records at one-second intervals.

Boto3 is used to communicate with AWS services.

### 2. Amazon Kinesis

Generated sales records are published to the Kinesis stream:

```text
sales-e2e-stream
```

The transaction ID is used as the Kinesis partition key.

### 3. Amazon S3

The same generated sales records are converted into CSV format and uploaded to:

```text
s3://<path>/
```

Using the project prefix:

```text
<path>/snowflake-stream/
```

### 4. Snowflake External Stage

A Snowflake Storage Integration provides a secure connection between Snowflake and Amazon S3.

An External Stage points to the S3 location containing the generated CSV files.

```text
S3
 ↓
Snowflake External Stage
```

### 5. Snowpipe

Snowpipe is configured for automated ingestion of new CSV files from the S3 location.

```text
S3
 ↓
Snowpipe
 ↓
sales_data_raw 
```

`sales_data_raw ` acts as the **raw/landing table** in this project because the incoming S3 data is loaded directly into it.

### 6. Snowflake Stream

A standard Snowflake Stream is created on `sales_data_raw ` to capture changes occurring after the Stream is created.

```text
sales_data_raw 
      ↓
sales_data_stream
```

The Stream provides CDC metadata such as:

* `METADATA$ACTION`
* `METADATA$ISUPDATE`

### 7. Snowflake Task

A Snowflake Task checks whether the Stream contains data using:

```sql
SYSTEM$STREAM_HAS_DATA()
```

When changes are available, the Task processes the Stream data.

### 8. MERGE Processing

The Stream data is processed using SQL `MERGE` logic into the downstream target table:

```text
sales_data_stream
        ↓
       MERGE
        ↓
sales_data_prod
```

The MERGE handles both:

* Matching records → `UPDATE`
* New records → `INSERT`

---

## Repository Structure

```text
realtime-kinesis-s3-snowflake-autoingestion/
│
├── README.md
│
├── python/
│   └── kinesis_s3_sales_producer.py
│
├── 01_snowflake_staging/
│   └── create_stage_and_file_format.sql
│
├── 02_snowflake_loading/
│   └── copy_into_and_snowpipe.sql
│
├── 03_stream/
│   └── stream.sql
│
└── 04_stream_task/
    └── stream_task_merge.sql
```

---

## Key Snowflake Concepts Practiced

### External Stage

Used a Snowflake External Stage to reference files stored in Amazon S3.

### Snowpipe

Used Snowpipe to demonstrate automated ingestion of newly arriving files.

### Raw / Landing Layer

Used `sales_data_raw ` as the landing table receiving data from Snowpipe.

### Streams

Used a standard Stream to capture incremental changes from the landing table.

### Tasks

Used a scheduled Task with `SYSTEM$STREAM_HAS_DATA()` to process available changes.

### MERGE

Used MERGE logic to synchronize incremental changes into a downstream target table.

---

## End-to-End Flow

```text
1. Python generates simulated sales data
                 ↓
2. Boto3 sends the record to Amazon Kinesis
                 ↓
3. Python converts the record to CSV
                 ↓
4. Boto3 uploads the CSV to Amazon S3
                 ↓
5. Snowflake External Stage references the S3 location
                 ↓
6. Snowpipe loads new CSV data
                 ↓
7. Data arrives in sales_data1
                 ↓
8. Snowflake Stream captures changes
                 ↓
9. Snowflake Task checks for Stream data
                 ↓
10. MERGE processes incremental records
                 ↓
11. Data is synchronized into sales_data_prod
```

---

## Learning Outcome

Through this project, I practiced building an end-to-end cloud data pipeline combining AWS services with Snowflake.

Key areas practiced:

* Python-based data generation
* Boto3 AWS integration
* Amazon Kinesis event streaming
* Amazon S3 file storage
* Snowflake Storage Integration
* Snowflake External Stage
* Snowpipe automated ingestion
* Raw / landing table design
* Snowflake Streams and CDC concepts
* Snowflake Tasks
* SQL MERGE
* Incremental data processing
* End-to-end pipeline validation

---

## Validation and Monitoring

The pipeline was validated using Snowflake SQL commands and queries including:

```sql
LIST @sales_stg1;

SHOW PIPES;

SHOW TASKS;

SELECT * FROM sales_data_raw;

SELECT * FROM sales_data_prod;
```

These checks were used to verify file availability, Snowpipe configuration, Task configuration, and loaded data.

---

## Security Note

AWS credentials and other sensitive connection information are **not stored in this repository**.

Boto3 credentials should be configured using secure AWS credential mechanisms rather than hard-coded in Python source code.

---

## Project Status

**Completed hands-on practice project**

The project demonstrates the complete design and implementation of:

**Python → AWS Kinesis / S3 → Snowflake → Snowpipe → Stream → Task → MERGE**

This repository contains the SQL and Python code used during the hands-on learning and implementation process.
