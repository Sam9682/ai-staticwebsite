#!/bin/bash

# AI-StaticWebsite Deployment Script
# Organized with functions for better maintainability

set -e

# Global Variables
COMMAND=${1:-help}
USER_ID=${2:-0}
USER_NAME=${3:-"admin"}
USER_EMAIL=${4:-"admin@swautomorph.com"}
DESCRIPTION=${5:-"Basic Information Display"}
APPLICATION_IDENTITY_NUMBER=4
RANGE_START=6000
RANGE_RESERVED=10
PORT_RANGE_BEGIN=$((APPLICATION_IDENTITY_NUMBER * 100 + RANGE_START))

# Calculate ports (convert alphanumeric USER_ID to numeric for port calculation)
calculate_ports() {
    USER_ID_NUMERIC=$(echo -n "$USER_ID" | cksum | cut -d' ' -f1)
    USER_ID_NUMERIC=$((USER_ID_NUMERIC % 1000))
    PORT=$((PORT_RANGE_BEGIN + USER_ID_NUMERIC * RANGE_RESERVED))
    HTTPS_PORT=$((PORT + 1))
}

# Display environment variables for operations
show_environment() {
    local operation=$1
    echo "🔍 Starting $operation operation..."
    echo "Environment Variables:"
    echo "  USER_ID=${USER_ID}"
    echo "  USER_NAME=${USER_NAME}"
    echo "  USER_EMAIL=${USER_EMAIL}"
    echo "  PORT=${PORT}"
    echo "  HTTPS_PORT=${HTTPS_PORT}"
    echo ""
}

# Check service status
check_status() {
    show_environment "ps"
    echo "📊 AI-StaticWebsite Service Status:"
    
    if command -v docker-compose &> /dev/null; then
        PORT=$PORT HTTPS_PORT=$HTTPS_PORT USER_ID=$USER_ID docker-compose ps
    else
        echo "❌ Docker Compose not installed"
    fi
}

# Stop services
stop_services() {
    show_environment "stop"
    echo "🛑 Stopping AI-StaticWebsite services..."
    
    PORT=$PORT HTTPS_PORT=$HTTPS_PORT USER_ID=$USER_ID docker-compose down
    echo "✅ Services stopped"
}

# Show logs
show_logs() {
    show_environment "logs"
    PORT=$PORT HTTPS_PORT=$HTTPS_PORT USER_ID=$USER_ID docker-compose logs -f
}

# Restart services
restart_services() {
    show_environment "restart"
    echo "🔄 Restarting AI-StaticWebsite services..."
    
    PORT=$PORT HTTPS_PORT=$HTTPS_PORT USER_ID=$USER_ID docker-compose restart
    echo "✅ Services restarted"
}

# Start services
start_services() {
    show_environment "start"
    echo "🚀 Starting AI-StaticWebsite deployment..."
    
    setup_environment
    cleanup_docker
    build_and_start_services
    verify_deployment
}

# Validate user input
validate_user_id() {
    if ! [[ "$USER_ID" =~ ^[a-zA-Z0-9]+$ ]]; then
        echo "❌ Error: user_id must be alphanumeric"
        exit 1
    fi
}

# Check system requirements
check_requirements() {
    if ! command -v docker &> /dev/null; then
        echo "❌ Docker is not installed. Please install Docker first."
        exit 1
    fi
    
    if ! command -v docker-compose &> /dev/null; then
        echo "❌ Docker Compose is not installed. Please install Docker Compose first."
        exit 1
    fi
}

# Setup directories and certificates
setup_environment() {
    create_directories
    setup_ssl_certificates
    generate_environment_file
}

create_directories() {
    echo "📁 Creating directories..."
    mkdir -p data ssl logs
    chmod 755 data ssl logs
}

setup_ssl_certificates() {
    if [ ! -f ssl/cert.pem ] || [ ! -f ssl/key.pem ]; then
        echo "🔐 Generating SSL certificates..."
        ./generate_ssl.sh
    else
        echo "✅ SSL certificates already exist"
    fi
}

generate_environment_file() {
    echo "🔑 Generating environment configuration..."
    SECRET_KEY=$(python3 -c "import secrets; print(secrets.token_hex(32))")
    cat > .env << EOF
SECRET_KEY=${SECRET_KEY}
FLASK_ENV=production
USER_ID=${USER_ID}
USER_NAME=${USER_NAME}
USER_EMAIL=${USER_EMAIL}
DESCRIPTION=${DESCRIPTION}
PORT=${PORT}
HTTPS_PORT=${HTTPS_PORT}
PORT_RANGE_BEGIN=${PORT_RANGE_BEGIN}
EOF
    echo "✅ Environment file created (.env)"
}

cleanup_docker() {
    echo "🧹 Cleaning up..."
    PORT=$PORT HTTPS_PORT=$HTTPS_PORT USER_ID=$USER_ID docker-compose down --remove-orphans 2>/dev/null || true
}

build_and_start_services() {
    echo "🔨 Building Docker images..."
    PORT=$PORT HTTPS_PORT=$HTTPS_PORT USER_ID=$USER_ID docker-compose build --no-cache
    
    echo "🚀 Starting services..."
    PORT=$PORT HTTPS_PORT=$HTTPS_PORT USER_ID=$USER_ID docker-compose up -d
    
    echo "⏳ Waiting for services to start..."
    sleep 10
}

verify_deployment() {
    if PORT=$PORT HTTPS_PORT=$HTTPS_PORT USER_ID=$USER_ID docker-compose ps | grep -q "Up"; then
        show_success_info
    else
        show_failure_info
        exit 1
    fi
}

show_success_info() {
    echo "✅ Services are running!"
    echo ""
    echo "🌐 Application URLs:"
    echo "   Web Interface: http://localhost:${PORT}"
    echo "   HTTPS:         https://localhost:${HTTPS_PORT}"
    echo ""
    echo "👤 User Information:"
    echo "   User ID:         ${USER_ID}"
    echo "   Name:            ${USER_NAME}"
    echo "   Email:           ${USER_EMAIL}"
    echo "   Description:     ${DESCRIPTION}"
    echo "   Port Range Begin: ${PORT_RANGE_BEGIN}"
    echo "   Assigned Port:   ${PORT}"
    echo ""
    echo "📋 Management Commands:"
    echo "   View logs:     ./deploy.sh logs ${USER_ID}"
    echo "   Stop services: ./deploy.sh stop ${USER_ID}"
    echo "   Restart:       ./deploy.sh restart ${USER_ID}"
    echo "   Check status:  ./deploy.sh ps ${USER_ID}"
    echo ""
    echo "📊 Service Status:"
    PORT=$PORT HTTPS_PORT=$HTTPS_PORT USER_ID=$USER_ID docker-compose ps
}

show_failure_info() {
    echo "❌ Failed to start services. Check logs:"
    PORT=$PORT HTTPS_PORT=$HTTPS_PORT USER_ID=$USER_ID docker-compose logs
}

# Show usage information
show_usage() {
    echo "Usage: $0 [start|stop|restart|ps|logs] <user_id> [user_name] [user_email] [description]"
    echo "  start        - Start services with user parameters (default)"
    echo "  stop         - Stop all services"
    echo "  restart      - Restart all services"
    echo "  ps           - Show service status"
    echo "  logs         - Show service logs"
    echo ""
    echo "Parameters:"
    echo "  user_id          - User ID (required, alphanumeric)"
    echo "  user_name        - User display name (optional, default: 'admin')"
    echo "  user_email       - User email (optional, default: 'admin@swautomorph.com')"
    echo "  description      - Site description (optional, default: 'Basic Information Display')"
    echo ""
    echo "Example: $0 start user123 'John Doe' 'john@example.com' 'My Personal Site'"
}

# Main function - orchestrates the deployment process
main() {
    calculate_ports
    
    case $COMMAND in
        "ps")
            check_status
            exit 0
            ;;
        "stop")
            stop_services
            exit 0
            ;;
        "logs")
            show_logs
            exit 0
            ;;
        "restart")
            restart_services
            exit 0
            ;;
        "start")
            validate_user_id
            check_requirements
            start_services
            echo ""
            echo "🎉 Deployment completed successfully!"
            echo "🔗 Access your site at: https://www.swautomorph.com:${HTTPS_PORT}"
            ;;
        *)
            show_usage
            exit 1
            ;;
    esac
}

# Execute main function
main "$@"