#!/bin/bash

# AI-StaticWebsite Deployment Script

set -e

# Handle command line arguments
COMMAND=${1:-help}
USER_ID=${2:-1}
USER_NAME=${3:-"User"}
USER_EMAIL=${4:-"user@example.com"}
DESCRIPTION=${5:-"Basic Information Display"}
# Compute var RANGE_START = APPLICATION_IDENTITY_NUMBER * 100 + RANGE_START
APPLICATION_IDENTITY_NUMBER=4
RANGE_START=6000
PORT_RANGE_BEGIN=$((APPLICATION_IDENTITY_NUMBER * 100 + RANGE_START))

# Calculate ports
PORT=$((PORT_RANGE_BEGIN + USER_ID))
HTTPS_PORT=$((PORT + 443))

case $COMMAND in
    "ps")
        echo "📊 AI-StaticWebsite Service Status:"
        if command -v docker-compose &> /dev/null; then
            PORT=$((PORT_RANGE_BEGIN + USER_ID)) HTTPS_PORT=$((PORT_RANGE_BEGIN + USER_ID + 443)) USER_ID=$USER_ID docker-compose ps
        else
            echo "❌ Docker Compose not installed"
        fi
        exit 0
        ;;
    "stop")
        echo "🛑 Stopping AI-StaticWebsite services..."
        PORT=$((PORT_RANGE_BEGIN + USER_ID)) HTTPS_PORT=$((PORT_RANGE_BEGIN + USER_ID + 443)) USER_ID=$USER_ID docker-compose down
        echo "✅ Services stopped"
        exit 0
        ;;
    "logs")
        PORT=$((PORT_RANGE_BEGIN + USER_ID)) HTTPS_PORT=$((PORT_RANGE_BEGIN + USER_ID + 443)) USER_ID=$USER_ID docker-compose logs -f
        exit 0
        ;;
    "restart")
        echo "🔄 Restarting AI-StaticWebsite services..."
        PORT=$((PORT_RANGE_BEGIN + USER_ID)) HTTPS_PORT=$((PORT_RANGE_BEGIN + USER_ID + 443)) USER_ID=$USER_ID docker-compose restart
        echo "✅ Services restarted"
        exit 0
        ;;
    "start")
        echo "🚀 Starting AI-StaticWebsite deployment..."
        ;;
    *)
        echo "Usage: $0 [start|stop|restart|ps|logs] <user_id> [user_name] [user_email] [description] [port_range_begin]"
        echo "  start        - Start services with user parameters (default)"
        echo "  stop         - Stop all services"
        echo "  restart      - Restart all services"
        echo "  ps           - Show service status"
        echo "  logs         - Show service logs"
        echo ""
        echo "Parameters:"
        echo "  user_id          - User ID (required, used for port calculation: port_range_begin + user_id)"
        echo "  user_name        - User display name (optional, default: 'User')"
        echo "  user_email       - User email (optional, default: 'user@example.com')"
        echo "  description      - Site description (optional, default: 'Basic Information Display')"
        echo "  port_range_begin - Port range start (optional, default: 6000)"
        echo ""
        echo "Example: $0 start 5 'John Doe' 'john@example.com' 'My Personal Site' 7000"
        echo "This will start the service on port 7005"
        exit 1
        ;;
esac

# Validate user_id
if ! [[ "$USER_ID" =~ ^[0-9]+$ ]]; then
    echo "❌ Error: user_id must be a number"
    exit 1
fi

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo "❌ Docker is not installed. Please install Docker first."
    exit 1
fi

if ! command -v docker-compose &> /dev/null; then
    echo "❌ Docker Compose is not installed. Please install Docker Compose first."
    exit 1
fi

# Create necessary directories
echo "📁 Creating directories..."
mkdir -p data ssl logs

# Set proper permissions
chmod 755 data ssl logs

# Generate SSL certificates if they don't exist
if [ ! -f ssl/cert.pem ] || [ ! -f ssl/key.pem ]; then
    echo "🔐 Generating SSL certificates..."
    ./generate_ssl.sh
else
    echo "✅ SSL certificates already exist"
fi

# Generate environment configuration
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

# Clean up existing containers
echo "🧹 Cleaning up..."
PORT=$PORT HTTPS_PORT=$HTTPS_PORT USER_ID=$USER_ID docker-compose down --remove-orphans 2>/dev/null || true

# Build and start services
echo "🔨 Building Docker images..."
PORT=$PORT HTTPS_PORT=$HTTPS_PORT USER_ID=$USER_ID docker-compose build --no-cache

echo "🚀 Starting services..."
PORT=$PORT HTTPS_PORT=$HTTPS_PORT USER_ID=$USER_ID docker-compose up -d

# Wait for services to be ready
echo "⏳ Waiting for services to start..."
sleep 10

# Check if services are running
if PORT=$PORT HTTPS_PORT=$HTTPS_PORT USER_ID=$USER_ID docker-compose ps | grep -q "Up"; then
    echo "✅ Services are running!"
    echo ""
    echo "🌐 Application URLs:"
    echo "   Web Interface: http://localhost:${PORT}"
    echo "   HTTPS:         https://localhost:$((PORT + 443))"
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
else
    echo "❌ Failed to start services. Check logs:"
    PORT=$PORT HTTPS_PORT=$HTTPS_PORT USER_ID=$USER_ID docker-compose logs
    exit 1
fi

echo ""
echo "🎉 Deployment completed successfully!"
echo "🔗 Access your site at: http://localhost:${PORT}"