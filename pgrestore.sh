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

# Prompt for the .dump file to restore
read -p "Enter the S3 path of the .dump file to restore (e.g., 2025-01-12.dump): " DUMP_FILE_PATH

# Generate the full S3 URI for the dump file
S3_URI="s3://$AWS_BUCKET/$DUMP_FILE_PATH"

# Download the .dump file from S3 to a local file
aws s3 cp $S3_URI /tmp/backup.dump

# Connect to the default 'postgres' database before restoring
psql -h $PGHOST -U administrator -d postgres -c "SELECT pg_terminate_backend(pid) FROM pg_stat_activity WHERE datname = '$PGDATABASE';"

# Restore the database from the .dump file with adjusted options
PGPASSWORD=$PGPASSWORD pg_restore --host=$PGHOST --username=administrator --dbname=$PGDATABASE --no-create-db --no-owner --no-acl --clean /tmp/backup.dump

# Clean up by removing the downloaded .dump file
rm /tmp/backup.dump
