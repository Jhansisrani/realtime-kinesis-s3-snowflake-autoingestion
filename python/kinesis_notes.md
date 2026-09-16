
# Python Boto3 – Kinesis and S3 Sales Data Producer

## Overview

This Python script generates dummy sales records and sends the same generated record to two AWS services:

* **Amazon Kinesis Data Stream** – for streaming data
* **Amazon S3** – saves the same record as a CSV file for Snowflake ingestion

The script uses **Boto3**, the AWS SDK for Python, to connect to AWS services.

## 1. Install Boto3

Install the AWS SDK for Python using pip:

```bash
pip install boto3
```

Verify the installation:

```bash
pip show boto3
```

Then import Boto3 in the Python script:

```python
import boto3
```

## 2. Configure AWS Credentials

Because the Python program connects to AWS Kinesis and S3, Boto3 needs AWS credentials.

Do **not** hard-code AWS credentials inside the Python script.

Configure the credentials using the AWS CLI:

```bash
aws configure
```

The command prompts for:

```text
AWS Access Key ID:
AWS Secret Access Key:
Default region name:
Default output format:
```

For this project, the AWS region used is:

```text
US-******
```

The credentials are stored in the local AWS credentials configuration and are automatically picked up by Boto3.

### Security

The following information must **never** be committed to GitHub:

```text
AWS Access Key ID
AWS Secret Access Key
AWS session tokens
AWS passwords
Private keys
Snowflake passwords
```

The Python source code contains no AWS access keys or secret keys.

## 3. Create Boto3 Clients

The script creates clients for Kinesis and S3:

```python
kinesis_client = boto3.client(
    'kinesis',
    region_name='us-east-1'
)

s3_client = boto3.client(
    's3',
    region_name='us-east-1'
)
```

These clients use the AWS credentials configured locally.

## 4. Kinesis Configuration

The Python program sends records to:

```text
Kinesis Stream:
sales-e2e-stream
```

The `transaction_id` is used as the Kinesis partition key:

```python
PartitionKey=str(data['transaction_id'])
```

## 5. S3 Configuration

The same generated sales record is converted into CSV format and uploaded to:

```text
Bucket:
snowflake-ingest-data

Prefix:
path****/snowflake-stream/
```

Example files:

```text
sales_data_0.csv
sales_data_1.csv
sales_data_2.csv
```

## 6. Generate Sales Data

The script generates dummy sales data containing:

```text
transaction_id
timestamp
customer_id
product_id
quantity
price_per_unit
total_price
```

`total_price` is calculated as:

```text
quantity × price_per_unit
```

## 7. Send the Record to Kinesis

The generated Python dictionary is converted to JSON and sent to the Kinesis stream.

```text
Python
  ↓
Generate sales record
  ↓
JSON
  ↓
Kinesis
```

## 8. Save the Same Record to S3

The same generated record is written as a CSV file and uploaded to S3.

```text
Python
  ↓
Generate sales record
  ↓
CSV
  ↓
S3
```

Kinesis and S3 are therefore **two separate destinations for the same generated record**.

## 9. Test Record Limit

During testing, the script generates only a limited number of records.

Example:

```python
limit = 5
```

This was used to control AWS usage and cost while testing the pipeline.

The limit can be increased when more test data is required.

## 10. Complete Data Flow

```text
                    Python / Boto3
                          |
                   Generate sales data
                          |
                +---------+---------+
                |                   |
                ↓                   ↓
          AWS Kinesis            CSV creation
       sales-e2e-stream              |
                                    ↓
                              Amazon S3
                         snowflake-ingest-data
                                    |
                                    ↓
                         Snowflake ingestion
```

## Python Libraries Used

```python
boto3
json
time
random
datetime
csv
io
```

### Purpose

* `boto3` → connect to AWS services
* `json` → serialize records for Kinesis
* `random` → generate dummy sales values
* `datetime` → generate timestamps
* `csv` → create CSV files
* `StringIO` → create CSV content in memory
* `time` → add a delay between records
