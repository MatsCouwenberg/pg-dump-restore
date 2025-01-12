#!/bin/bash

# Prompt for the RDS host
read -p "Enter PostgreSQL RDS Host: " PGHOST

# Hardcoded values
PGDUMP_OPTIONS="--port=5432 --username=administrator"
PGDATABASE="FieldSight_db"
AWS_BUCKET="s3-fieldsight-backup"
AWS_REGION="us-east-1"

# Prompt for the AWS credentials
read -p "Enter AWS Access Key ID: " AWS_ACCESS_KEY_ID
echo
read -p "Enter AWS Secret Access Key: " AWS_SECRET_ACCESS_KEY
echo
read -p "Enter AWS Session Token: " AWS_SESSION_TOKEN
echo

# Prompt for the PostgreSQL password
read -p "Enter PostgreSQL password: " PGPASSWORD
echo

# Set AWS environment variables for the session
export AWS_ACCESS_KEY_ID
export AWS_SECRET_ACCESS_KEY
export AWS_SESSION_TOKEN
export AWS_REGION

# Generate a date string in the format YYYY-MM-DD
DATE_STRING=$(date +"%Y-%m-%d")

# Execute pg_dump with the entered password and stream the output directly to S3
PGPASSWORD=$PGPASSWORD pg_dump --host=$PGHOST $PGDUMP_OPTIONS --format=custom $PGDATABASE | aws s3 cp - s3://$AWS_BUCKET/$DATE_STRING.dump
