#!/bin/bash

# Human Tasks:
# 1. Ensure AWS CLI v2.x is installed and configured with appropriate credentials
# 2. Install PostgreSQL client tools v14.x
# 3. Create S3 bucket 'spring-boot-app-backups' with appropriate permissions
# 4. Configure backup retention policies in AWS S3 lifecycle rules
# 5. Verify write permissions to /tmp/backups directory
# 6. Set up appropriate IAM roles and policies for S3 access

# Required tool versions:
# - aws-cli v2.x
# - postgresql-client v14.x

# Requirement Addressed: Database Backup
# Location: Technical Specification/Database Management
# Description: Automated backup script for H2 database and application state

set -euo pipefail

# Global variables from specification
BACKUP_DIR="/tmp/backups"
RETENTION_DAYS=30
S3_BUCKET="spring-boot-app-backups"

# Source environment configuration
if [ -f "../terraform/environments/dev/terraform.tfvars" ]; then
    # Extract values using grep and cut
    AWS_REGION=$(grep "aws_region" ../terraform/environments/dev/terraform.tfvars | cut -d'"' -f2)
    DB_NAME=$(grep "db_name" ../terraform/environments/dev/terraform.tfvars | cut -d'"' -f2)
    ENVIRONMENT=$(grep "environment" ../terraform/environments/dev/terraform.tfvars | cut -d'"' -f2)
else
    echo "Error: Environment configuration file not found"
    exit 1
fi

# Function to check prerequisites
check_prerequisites() {
    # Check AWS CLI version
    if ! aws --version | grep -q "aws-cli/2"; then
        echo "Error: AWS CLI v2.x is required"
        return 1
    fi

    # Check PostgreSQL client version
    if ! psql --version | grep -q "14."; then
        echo "Error: PostgreSQL client v14.x is required"
        return 1
    }

    # Verify AWS credentials
    if ! aws sts get-caller-identity &>/dev/null; then
        echo "Error: Invalid AWS credentials"
        return 1
    }

    # Check S3 bucket access
    if ! aws s3 ls "s3://${S3_BUCKET}" &>/dev/null; then
        echo "Error: Cannot access S3 bucket ${S3_BUCKET}"
        return 1
    }

    # Verify backup directory
    if [ ! -d "${BACKUP_DIR}" ]; then
        mkdir -p "${BACKUP_DIR}"
    fi
    if [ ! -w "${BACKUP_DIR}" ]; then
        echo "Error: Backup directory ${BACKUP_DIR} is not writable"
        return 1
    }

    return 0
}

# Function to backup database
backup_database() {
    local environment=$1
    local timestamp=$(date +%Y%m%d_%H%M%S)
    local backup_file="${BACKUP_DIR}/${environment}_${DB_NAME}_${timestamp}.sql"

    # Get database credentials from Kubernetes secret
    local db_user=$(kubectl get secret spring-boot-secrets -o jsonpath='{.data.SPRING_DATASOURCE_USERNAME}' | base64 --decode)
    local db_pass=$(kubectl get secret spring-boot-secrets -o jsonpath='{.data.SPRING_DATASOURCE_PASSWORD}' | base64 --decode)

    echo "Starting database backup..."
    PGPASSWORD="${db_pass}" pg_dump \
        -h localhost \
        -U "${db_user}" \
        -d "${DB_NAME}" \
        -F p \
        -f "${backup_file}"

    # Compress backup
    gzip "${backup_file}"
    
    # Verify backup file exists and is not empty
    if [ ! -s "${backup_file}.gz" ]; then
        echo "Error: Database backup failed or is empty"
        return 1
    }

    echo "Database backup completed: ${backup_file}.gz"
    echo "${backup_file}.gz"
}

# Function to backup application configuration
backup_config() {
    local environment=$1
    local timestamp=$(date +%Y%m%d_%H%M%S)
    local config_dir="${BACKUP_DIR}/config_${timestamp}"
    local archive_file="${BACKUP_DIR}/${environment}_config_${timestamp}.tar.gz"

    echo "Starting configuration backup..."
    
    # Create temporary directory for configs
    mkdir -p "${config_dir}"

    # Copy application properties
    cp ../../src/backend/src/main/resources/application.properties "${config_dir}/"
    cp ../terraform/environments/${environment}/terraform.tfvars "${config_dir}/"

    # Create archive excluding sensitive data
    tar --exclude="*secret*" \
        --exclude="*password*" \
        -czf "${archive_file}" \
        -C "${config_dir}" .

    # Clean up temporary directory
    rm -rf "${config_dir}"

    # Verify archive
    if [ ! -s "${archive_file}" ]; then
        echo "Error: Configuration backup failed or is empty"
        return 1
    }

    echo "Configuration backup completed: ${archive_file}"
    echo "${archive_file}"
}

# Function to upload backup to S3
upload_to_s3() {
    local file_path=$1
    local environment=$2
    local filename=$(basename "${file_path}")
    local s3_path="s3://${S3_BUCKET}/${environment}/$(date +%Y/%m)/${filename}"

    echo "Uploading ${filename} to S3..."
    
    # Set AWS region
    export AWS_DEFAULT_REGION="${AWS_REGION}"

    # Upload with checksum verification
    if aws s3 cp "${file_path}" "${s3_path}" --only-show-errors; then
        # Verify upload with checksum
        local local_md5=$(md5sum "${file_path}" | cut -d' ' -f1)
        local s3_md5=$(aws s3api head-object --bucket "${S3_BUCKET}" --key "${environment}/$(date +%Y/%m)/${filename}" --query 'ETag' --output text | tr -d '"')
        
        if [ "${local_md5}" = "${s3_md5}" ]; then
            echo "Upload verified successfully"
            rm -f "${file_path}"
            return 0
        else
            echo "Error: Upload verification failed"
            return 1
        fi
    else
        echo "Error: Upload failed"
        return 1
    fi
}

# Function to clean up old backups
cleanup_old_backups() {
    local environment=$1
    local cutoff_date=$(date -d "${RETENTION_DAYS} days ago" +%Y-%m-%d)
    local count=0

    echo "Cleaning up backups older than ${cutoff_date}..."

    # List old backups
    local old_backups=$(aws s3api list-objects-v2 \
        --bucket "${S3_BUCKET}" \
        --prefix "${environment}/" \
        --query "Contents[?LastModified<='${cutoff_date}'].Key" \
        --output text)

    # Remove old backups
    for backup in ${old_backups}; do
        if aws s3 rm "s3://${S3_BUCKET}/${backup}" --only-show-errors; then
            count=$((count + 1))
        fi
    done

    echo "Cleaned up ${count} old backup(s)"
    return ${count}
}

# Main execution
main() {
    echo "Starting backup process for environment: ${ENVIRONMENT}"

    # Check prerequisites
    if ! check_prerequisites; then
        echo "Prerequisites check failed"
        exit 1
    fi

    # Perform database backup
    local db_backup_file=$(backup_database "${ENVIRONMENT}")
    if [ $? -eq 0 ]; then
        upload_to_s3 "${db_backup_file}" "${ENVIRONMENT}"
    else
        echo "Database backup failed"
        exit 1
    fi

    # Perform configuration backup
    local config_backup_file=$(backup_config "${ENVIRONMENT}")
    if [ $? -eq 0 ]; then
        upload_to_s3 "${config_backup_file}" "${ENVIRONMENT}"
    else
        echo "Configuration backup failed"
        exit 1
    fi

    # Clean up old backups
    cleanup_old_backups "${ENVIRONMENT}"

    echo "Backup process completed successfully"
}

# Execute main function
main