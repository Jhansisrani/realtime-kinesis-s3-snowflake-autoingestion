import boto3
import json
import time
import random
from datetime import datetime
from io import StringIO
import csv


# ============================================================
# 1. AWS CLIENTS
# ============================================================

# Boto3 client used to communicate with AWS Kinesis
kinesis_client = boto3.client (  'kinesis', region_name='us-east-1' ) # Replace with your AWS region

# Boto3 client used to upload CSV files to Amazon S3
s3_client = boto3.client( 's3', region_name='us-east-1')


# ============================================================
# 2. AWS RESOURCE NAMES
# ============================================================

# Kinesis stream created in AWS
# Python sends each generated sales record to this stream.
kinesis_stream_name = 'sales-e2e-stream'

# S3 bucket where the CSV files are stored
s3_bucket_name = 'snowflake-ingest-data'

# Folder/prefix inside the S3 bucket
# Snowflake external stage points to this location.
s3_key_prefix = 'path/'


# ============================================================
# 3. GENERATE SALES DATA
# ============================================================

def generate_sales_data():
    """
    Generates one dummy sales transaction.
    """

    quantity = random.randint(1, 10)

    price_per_unit = round( random.uniform(10.0, 100.0), 2 )

    sales_data = {
        'transaction_id': random.randint(100000, 999999),
        'timestamp': datetime.utcnow().isoformat(),
        'customer_id': random.randint(1000, 5000),
        'product_id': random.randint(100, 1000),
        'quantity': quantity,
        'price_per_unit': price_per_unit,
        'total_price': round( quantity * price_per_unit, 2 )   }

    return sales_data


# ============================================================
# 4. SEND RECORD TO KINESIS
# ============================================================

def send_to_kinesis(data):
    """
    Sends the generated sales record to the Kinesis stream.
    """

    response = kinesis_client.put_record(

        # Connects this Python program to the Kinesis stream
        StreamName=kinesis_stream_name,

        # Convert Python dictionary into JSON before sending
        Data=json.dumps(data),

        # transaction_id is used as the Kinesis partition key
        PartitionKey=str(data['transaction_id'])
    )

    return response


# ============================================================
# 5. SAVE SAME RECORD AS CSV IN S3
# ============================================================

def save_to_s3_as_csv(data, index):
    """
    Converts the sales record into CSV format
    and uploads it to Amazon S3.
    """

    # Each record gets a different CSV filename.
    s3_key = f"{s3_key_prefix}sales_data_{index}.csv"

    # Create CSV content in memory
    csv_buffer = StringIO()

    csv_writer = csv.writer(csv_buffer)

    # Write column names
    csv_writer.writerow(data.keys())

    # Write sales record
    csv_writer.writerow(data.values())

    # Upload CSV file to S3
    response = s3_client.put_object(

        # S3 bucket
        Bucket=s3_bucket_name,

        # S3 folder + filename
        Key=s3_key,

        # CSV content
        Body=csv_buffer.getvalue()
    )

    return response


# ============================================================
# 6. MAIN PIPELINE
# ============================================================

def main():

    index = 0

    # Number of records for this practice run.
    # Increase/decrease this depending on AWS usage/cost.
    limit = 100

    while index < limit:

        # ----------------------------------------------------
        # Generate one sales record
        # ----------------------------------------------------
        data = generate_sales_data()

        print(f"Generated sales data: {data}")


        # ----------------------------------------------------
        # Send the SAME record to Kinesis
        # ----------------------------------------------------
        # Python
        #    ↓
        # Kinesis Stream: bepec-e2e-stream
        # ----------------------------------------------------
         kinesis_response = send_to_kinesis(data)
         print(f"Sent data to Kinesis: {kinesis_response}")


        # ----------------------------------------------------
        # Save the SAME record as CSV in S3
        # ----------------------------------------------------
        # Python
        #    ↓
        # CSV
        #    ↓
        # S3 bucket
        #    ↓
        # bepec_marketing/bepec-snowflake-stream/
        # ----------------------------------------------------
        s3_response = save_to_s3_as_csv(data, index)
        print(f"Saved data to S3: {s3_response}")


        # Increment record/file number
        index += 1


        # Wait 1 second before generating the next record
        time.sleep(1)


# ============================================================
# START PROGRAM
# ============================================================

main()
