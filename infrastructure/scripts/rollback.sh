#!/bin/bash

# Human Tasks:
# 1. Ensure kubectl is installed and configured with proper cluster access
# 2. Verify Helm v3.x is installed and initialized
# 3. Configure proper RBAC permissions for service accounts
# 4. Set up monitoring and alerting for rollback events
# 5. Review and adjust ROLLBACK_TIMEOUT based on application startup time

# Requirement: Deployment Rollback
# Script to handle rollback operations for Spring Boot application deployment failures

set -e  # Exit on error
set -o pipefail  # Exit on pipe failure

# Script constants and configuration
SCRIPT_DIR="$(dirname "${BASH_SOURCE[0]}")"
ROLLBACK_TIMEOUT=300  # 5 minutes timeout for rollback operations
MAX_ROLLBACK_ATTEMPTS=3

# Source deploy.sh to access shared configurations and functions
# Requirement: Deployment Rollback - Integration with deployment configuration
source "${SCRIPT_DIR}/deploy.sh"

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

# Requirement: Deployment Rollback
# Checks the status of the current deployment using Kubernetes health checks
check_deployment_status() {
    local namespace=$1
    
    log "INFO" "Checking deployment status in namespace: $namespace"
    
    # Check deployment replicas
    local ready_replicas=$(kubectl get deployment spring-boot-app -n "$namespace" -o jsonpath='{.status.readyReplicas}' 2>/dev/null || echo "0")
    local desired_replicas=$(kubectl get deployment spring-boot-app -n "$namespace" -o jsonpath='{.spec.replicas}' 2>/dev/null || echo "0")
    
    if [[ "$ready_replicas" != "$desired_replicas" ]]; then
        log "ERROR" "Deployment replicas mismatch. Ready: $ready_replicas, Desired: $desired_replicas"
        return 1
    fi
    
    # Check pod health through Spring Boot actuator
    local pod_name=$(kubectl get pod -n "$namespace" -l app=spring-boot-app -o jsonpath='{.items[0].metadata.name}' 2>/dev/null)
    if [[ -n "$pod_name" ]]; then
        if ! kubectl exec -n "$namespace" "$pod_name" -- wget -q -O- http://localhost:8080/actuator/health | grep -q "UP"; then
            log "ERROR" "Application health check failed"
            return 1
        fi
    else
        log "ERROR" "No pods found for the application"
        return 1
    fi
    
    # Check service connectivity
    if ! kubectl get service spring-boot-app-service -n "$namespace" &>/dev/null; then
        log "ERROR" "Service not found"
        return 1
    fi
    
    log "INFO" "Deployment status check passed"
    return 0
}

# Requirement: Deployment Rollback
# Executes the rollback to previous known good deployment
perform_rollback() {
    local namespace=$1
    local deployment_name=$2
    
    log "INFO" "Initiating rollback for deployment: $deployment_name in namespace: $namespace"
    
    # Get previous revision from Helm history
    local previous_revision=$(helm history "$deployment_name" -n "$namespace" | grep -E '^[0-9]+\s+DEPLOYED' | tail -n 2 | head -n 1 | awk '{print $1}')
    
    if [[ -z "$previous_revision" ]]; then
        log "ERROR" "No previous revision found for rollback"
        return 1
    }
    
    # Call handle_rollback from deploy.sh
    if ! handle_rollback "$previous_revision"; then
        log "ERROR" "Failed to execute rollback operation"
        return 1
    }
    
    # Wait for rollback completion
    local timeout=$ROLLBACK_TIMEOUT
    while [[ $timeout -gt 0 ]]; do
        if check_deployment_status "$namespace"; then
            log "INFO" "Rollback completed successfully"
            return 0
        fi
        sleep 5
        timeout=$((timeout - 5))
    done
    
    log "ERROR" "Rollback timed out after $ROLLBACK_TIMEOUT seconds"
    return 1
}

# Requirement: Deployment Rollback
# Cleans up resources from failed deployment
cleanup_failed_deployment() {
    local namespace=$1
    
    log "INFO" "Cleaning up failed deployment resources in namespace: $namespace"
    
    # Archive deployment logs
    local timestamp=$(date '+%Y%m%d_%H%M%S')
    local log_dir="/var/log/spring-boot-app/rollbacks/${timestamp}"
    mkdir -p "$log_dir"
    
    # Collect pod logs
    kubectl get pods -n "$namespace" -l app=spring-boot-app -o name | while read pod; do
        kubectl logs "$pod" -n "$namespace" > "${log_dir}/$(basename "$pod").log" 2>/dev/null || true
    done
    
    # Clean up failed resources
    kubectl delete pods -n "$namespace" -l app=spring-boot-app --grace-period=0 --force 2>/dev/null || true
    
    # Clean up orphaned config maps
    kubectl get configmaps -n "$namespace" -l app=spring-boot-app -o name | while read cm; do
        kubectl delete "$cm" -n "$namespace" 2>/dev/null || true
    done
    
    # Verify cleanup
    if kubectl get pods -n "$namespace" -l app=spring-boot-app 2>/dev/null | grep -q "Terminating"; then
        log "WARN" "Some resources are still being terminated"
        return 1
    fi
    
    log "INFO" "Cleanup completed successfully"
    return 0
}

# Main script execution
case "${1:-}" in
    "check")
        if [[ $# -lt 2 ]]; then
            log "ERROR" "Usage: $0 check <namespace>"
            exit 1
        fi
        check_deployment_status "$2"
        ;;
    "rollback")
        if [[ $# -lt 3 ]]; then
            log "ERROR" "Usage: $0 rollback <namespace> <deployment_name>"
            exit 1
        fi
        perform_rollback "$2" "$3"
        ;;
    "cleanup")
        if [[ $# -lt 2 ]]; then
            log "ERROR" "Usage: $0 cleanup <namespace>"
            exit 1
        fi
        cleanup_failed_deployment "$2"
        ;;
    *)
        log "ERROR" "Usage: $0 {check <namespace>|rollback <namespace> <deployment_name>|cleanup <namespace>}"
        exit 1
        ;;
esac