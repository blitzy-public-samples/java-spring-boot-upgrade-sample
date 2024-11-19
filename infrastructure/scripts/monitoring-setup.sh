#!/bin/bash

# Human Tasks:
# 1. Ensure Docker and Docker Compose are installed with minimum versions:
#    - Docker >= 20.10.0
#    - Docker Compose >= 1.29.2
# 2. Verify ports 9090 (Prometheus), 3000 (Grafana), and 9093 (Alertmanager) are available
# 3. Configure SMTP_PASSWORD and SLACK_API_URL environment variables for alerts
# 4. Review alert thresholds in rules.yml before deploying to production
# 5. Update email addresses and SMTP settings in alertmanager.yml

# Requirement: Application Monitoring - Setup monitoring infrastructure for Spring Boot actuator metrics

# Set error handling
set -euo pipefail
trap 'echo "Error on line $LINENO"' ERR

# Version requirements
REQUIRED_DOCKER_VERSION="20.10.0"
REQUIRED_COMPOSE_VERSION="1.29.2"
PROMETHEUS_VERSION="2.45.0"
GRAFANA_VERSION="9.5.2"
ALERTMANAGER_VERSION="0.25.0"

# Configuration paths relative to script location
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MONITORING_DIR="${SCRIPT_DIR}/../monitoring"
PROMETHEUS_CONFIG="${MONITORING_DIR}/prometheus.yml"
GRAFANA_DASHBOARD="${MONITORING_DIR}/grafana-dashboard.json"
ALERTMANAGER_CONFIG="${MONITORING_DIR}/alertmanager.yml"
RULES_CONFIG="${MONITORING_DIR}/rules.yml"

check_prerequisites() {
    echo "Checking prerequisites..."
    
    # Check Docker installation
    if ! command -v docker &> /dev/null; then
        echo "Docker is not installed"
        return 1
    fi
    
    # Check Docker version
    DOCKER_VERSION=$(docker version --format '{{.Server.Version}}' 2>/dev/null)
    if ! printf '%s\n%s\n' "${REQUIRED_DOCKER_VERSION}" "${DOCKER_VERSION}" | sort -V -C; then
        echo "Docker version ${REQUIRED_DOCKER_VERSION} or higher is required"
        return 1
    }
    
    # Check Docker Compose installation
    if ! command -v docker-compose &> /dev/null; then
        echo "Docker Compose is not installed"
        return 1
    }
    
    # Check Docker Compose version
    COMPOSE_VERSION=$(docker-compose version --short)
    if ! printf '%s\n%s\n' "${REQUIRED_COMPOSE_VERSION}" "${COMPOSE_VERSION}" | sort -V -C; then
        echo "Docker Compose version ${REQUIRED_COMPOSE_VERSION} or higher is required"
        return 1
    }
    
    # Check configuration files
    for config in "$PROMETHEUS_CONFIG" "$GRAFANA_DASHBOARD" "$ALERTMANAGER_CONFIG" "$RULES_CONFIG"; do
        if [[ ! -f "$config" ]]; then
            echo "Missing configuration file: $config"
            return 1
        fi
    done
    
    # Check port availability
    for port in 9090 3000 9093; do
        if netstat -tuln | grep -q ":${port} "; then
            echo "Port ${port} is already in use"
            return 1
        fi
    done
    
    return 0
}

setup_prometheus() {
    echo "Setting up Prometheus..."
    
    # Create Prometheus data directory
    mkdir -p "${MONITORING_DIR}/prometheus_data"
    
    # Start Prometheus container
    docker run -d \
        --name prometheus \
        --network monitoring \
        -p 9090:9090 \
        -v "${PROMETHEUS_CONFIG}:/etc/prometheus/prometheus.yml" \
        -v "${RULES_CONFIG}:/etc/prometheus/rules.yml" \
        -v "${MONITORING_DIR}/prometheus_data:/prometheus" \
        "prom/prometheus:v${PROMETHEUS_VERSION}" \
        --config.file=/etc/prometheus/prometheus.yml \
        --storage.tsdb.path=/prometheus \
        --web.enable-lifecycle
    
    # Wait for Prometheus to start
    sleep 5
    
    # Verify Prometheus is healthy
    if ! curl -s "http://localhost:9090/-/healthy" | grep -q "Prometheus is Healthy"; then
        echo "Prometheus health check failed"
        return 1
    fi
    
    return 0
}

setup_grafana() {
    echo "Setting up Grafana..."
    
    # Create Grafana data directory
    mkdir -p "${MONITORING_DIR}/grafana_data"
    
    # Create Grafana provisioning directories
    mkdir -p "${MONITORING_DIR}/grafana_provisioning/datasources"
    mkdir -p "${MONITORING_DIR}/grafana_provisioning/dashboards"
    
    # Create Prometheus datasource configuration
    cat > "${MONITORING_DIR}/grafana_provisioning/datasources/prometheus.yml" <<EOF
apiVersion: 1
datasources:
  - name: Prometheus
    type: prometheus
    access: proxy
    url: http://prometheus:9090
    isDefault: true
EOF
    
    # Copy dashboard configuration
    cp "${GRAFANA_DASHBOARD}" "${MONITORING_DIR}/grafana_provisioning/dashboards/"
    
    # Start Grafana container
    docker run -d \
        --name grafana \
        --network monitoring \
        -p 3000:3000 \
        -v "${MONITORING_DIR}/grafana_data:/var/lib/grafana" \
        -v "${MONITORING_DIR}/grafana_provisioning:/etc/grafana/provisioning" \
        -e "GF_SECURITY_ADMIN_PASSWORD=admin" \
        "grafana/grafana:${GRAFANA_VERSION}"
    
    # Wait for Grafana to start
    sleep 5
    
    # Verify Grafana is responding
    if ! curl -s "http://localhost:3000/api/health" | grep -q "ok"; then
        echo "Grafana health check failed"
        return 1
    fi
    
    return 0
}

setup_alertmanager() {
    echo "Setting up Alertmanager..."
    
    # Create Alertmanager data directory
    mkdir -p "${MONITORING_DIR}/alertmanager_data"
    
    # Start Alertmanager container
    docker run -d \
        --name alertmanager \
        --network monitoring \
        -p 9093:9093 \
        -v "${ALERTMANAGER_CONFIG}:/etc/alertmanager/alertmanager.yml" \
        -v "${MONITORING_DIR}/alertmanager_data:/alertmanager" \
        "prom/alertmanager:v${ALERTMANAGER_VERSION}" \
        --config.file=/etc/alertmanager/alertmanager.yml \
        --storage.path=/alertmanager
    
    # Wait for Alertmanager to start
    sleep 5
    
    # Verify Alertmanager is healthy
    if ! curl -s "http://localhost:9093/-/healthy" | grep -q "ok"; then
        echo "Alertmanager health check failed"
        return 1
    fi
    
    return 0
}

verify_monitoring() {
    echo "Verifying monitoring stack..."
    
    # Check container status
    for container in prometheus grafana alertmanager; do
        if [[ "$(docker inspect -f '{{.State.Running}}' "$container" 2>/dev/null)" != "true" ]]; then
            echo "Container $container is not running"
            return 1
        fi
    done
    
    # Verify Spring Boot metrics collection
    if ! curl -s "http://localhost:9090/api/v1/query?query=up{job='spring-boot'}" | grep -q "success"; then
        echo "Unable to collect Spring Boot metrics"
        return 1
    fi
    
    # Verify Grafana dashboard
    if ! curl -s -u admin:admin "http://localhost:3000/api/dashboards/uid/spring-boot-metrics" | grep -q "Spring Boot Application Metrics"; then
        echo "Grafana dashboard not found"
        return 1
    }
    
    echo "Monitoring stack verification completed successfully"
    return 0
}

main() {
    echo "Starting monitoring setup..."
    
    # Create Docker network if it doesn't exist
    docker network create monitoring 2>/dev/null || true
    
    # Run setup steps
    check_prerequisites || exit 1
    setup_prometheus || exit 1
    setup_grafana || exit 1
    setup_alertmanager || exit 1
    verify_monitoring || exit 1
    
    echo "Monitoring setup completed successfully"
    echo "Access URLs:"
    echo "Prometheus: http://localhost:9090"
    echo "Grafana: http://localhost:3000 (admin/admin)"
    echo "Alertmanager: http://localhost:9093"
}

# Execute main function
main