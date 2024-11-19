#!/bin/bash

# Human Tasks:
# 1. Ensure kubectl is installed and configured with proper cluster access
# 2. Verify Helm v3.x is installed and initialized
# 3. Configure Docker registry access if using private registry
# 4. Set up proper RBAC permissions for service accounts
# 5. Generate and configure secrets for database and security credentials
# 6. Review and adjust resource limits based on environment requirements
# 7. Configure proper network policies and ingress rules if needed

# Requirement: Spring Boot Application Deployment
# Deployment automation script for Spring Boot 3 application using Kubernetes and Helm

set -e  # Exit on error
set -o pipefail  # Exit on pipe failure

# Script constants
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
K8S_DIR="${SCRIPT_DIR}/../k8s"
HELM_DIR="${SCRIPT_DIR}/../helm/spring-boot-app"
APP_NAME="spring-boot-app"
NAMESPACE="default"

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Logging function
log() {
    local level=$1
    shift
    local message=$@
    timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    case $level in
        "INFO")
            echo -e "${GREEN}[INFO]${NC} ${timestamp} - $message"
            ;;
        "WARN")
            echo -e "${YELLOW}[WARN]${NC} ${timestamp} - $message"
            ;;
        "ERROR")
            echo -e "${RED}[ERROR]${NC} ${timestamp} - $message" >&2
            ;;
    esac
}

# Requirement: Spring Boot Application Deployment
# Validates that all required tools and configurations are available
check_prerequisites() {
    log "INFO" "Checking prerequisites..."

    # Check kubectl
    if ! command -v kubectl &> /dev/null; then
        log "ERROR" "kubectl is not installed"
        return 1
    fi

    # Check Helm
    if ! command -v helm &> /dev/null; then
        log "ERROR" "helm is not installed"
        return 1
    fi

    # Check Docker
    if ! command -v docker &> /dev/null; then
        log "ERROR" "docker is not installed"
        return 1
    fi

    # Verify Kubernetes connection
    if ! kubectl cluster-info &> /dev/null; then
        log "ERROR" "Unable to connect to Kubernetes cluster"
        return 1
    fi

    # Check required files
    local required_files=(
        "${K8S_DIR}/deployment.yml"
        "${K8S_DIR}/service.yml"
        "${K8S_DIR}/configmap.yml"
        "${K8S_DIR}/secret.yml"
        "${HELM_DIR}/values.yaml"
    )

    for file in "${required_files[@]}"; do
        if [[ ! -f "$file" ]]; then
            log "ERROR" "Required file not found: $file"
            return 1
        fi
    done

    log "INFO" "Prerequisites check completed successfully"
    return 0
}

# Requirement: Spring Boot Application Deployment
# Deploys the Spring Boot 3 application to the specified environment
deploy_application() {
    local environment=$1
    local version=$2

    if [[ -z "$environment" || -z "$version" ]]; then
        log "ERROR" "Environment and version parameters are required"
        return 1
    }

    log "INFO" "Starting deployment for environment: $environment, version: $version"

    # Create namespace if it doesn't exist
    kubectl get namespace "$NAMESPACE" &> /dev/null || kubectl create namespace "$NAMESPACE"

    # Apply ConfigMap with environment-specific configurations
    log "INFO" "Applying ConfigMap..."
    kubectl apply -f "${K8S_DIR}/configmap.yml" -n "$NAMESPACE"

    # Apply Secrets
    log "INFO" "Applying Secrets..."
    kubectl apply -f "${K8S_DIR}/secret.yml" -n "$NAMESPACE"

    # Deploy using Helm
    log "INFO" "Deploying application using Helm..."
    helm upgrade --install "$APP_NAME" "${HELM_DIR}" \
        --namespace "$NAMESPACE" \
        --set image.tag="$version" \
        --set springApplication.profile="$environment" \
        --wait \
        --timeout 5m

    # Wait for deployment rollout
    log "INFO" "Waiting for deployment rollout..."
    kubectl rollout status deployment/"$APP_NAME" -n "$NAMESPACE" --timeout=300s

    # Verify application health
    log "INFO" "Verifying application health..."
    local retries=0
    local max_retries=10
    while [[ $retries -lt $max_retries ]]; do
        if kubectl exec -n "$NAMESPACE" "$(kubectl get pod -l app="$APP_NAME" -n "$NAMESPACE" -o jsonpath='{.items[0].metadata.name}')" \
            -- wget -q -O- http://localhost:8080/actuator/health | grep -q "UP"; then
            log "INFO" "Application is healthy"
            break
        fi
        retries=$((retries + 1))
        sleep 5
    done

    if [[ $retries -eq $max_retries ]]; then
        log "ERROR" "Application health check failed"
        return 1
    fi

    log "INFO" "Deployment completed successfully"
    return 0
}

# Requirement: Spring Boot Application Deployment
# Manages rollback in case of deployment failure
handle_rollback() {
    local previous_version=$1

    if [[ -z "$previous_version" ]]; then
        log "ERROR" "Previous version parameter is required for rollback"
        return 1
    }

    log "INFO" "Initiating rollback to version: $previous_version"

    # Rollback Helm release
    log "INFO" "Rolling back Helm release..."
    if ! helm rollback "$APP_NAME" -n "$NAMESPACE"; then
        log "ERROR" "Helm rollback failed"
        return 1
    fi

    # Wait for rollback completion
    log "INFO" "Waiting for rollback to complete..."
    kubectl rollout status deployment/"$APP_NAME" -n "$NAMESPACE" --timeout=300s

    # Verify application health after rollback
    log "INFO" "Verifying application health after rollback..."
    local retries=0
    local max_retries=10
    while [[ $retries -lt $max_retries ]]; do
        if kubectl exec -n "$NAMESPACE" "$(kubectl get pod -l app="$APP_NAME" -n "$NAMESPACE" -o jsonpath='{.items[0].metadata.name}')" \
            -- wget -q -O- http://localhost:8080/actuator/health | grep -q "UP"; then
            log "INFO" "Application is healthy after rollback"
            break
        fi
        retries=$((retries + 1))
        sleep 5
    done

    if [[ $retries -eq $max_retries ]]; then
        log "ERROR" "Application health check failed after rollback"
        return 1
    fi

    log "INFO" "Rollback completed successfully"
    return 0
}

# Main script execution
case "${1:-}" in
    "deploy")
        if [[ $# -lt 3 ]]; then
            log "ERROR" "Usage: $0 deploy <environment> <version>"
            exit 1
        fi
        if check_prerequisites; then
            deploy_application "$2" "$3"
        fi
        ;;
    "rollback")
        if [[ $# -lt 2 ]]; then
            log "ERROR" "Usage: $0 rollback <previous_version>"
            exit 1
        fi
        if check_prerequisites; then
            handle_rollback "$2"
        fi
        ;;
    *)
        log "ERROR" "Usage: $0 {deploy <environment> <version>|rollback <previous_version>}"
        exit 1
        ;;
esac