# Universal Application Deployment Tooling

## Objective

This tooling provides a **standardized, automated deployment system** for containerized applications that enables:

- **Zero-configuration deployment** of new applications
- **Multi-user, multi-application** support with automatic port management
- **GenAI-friendly automation** requiring only configuration file changes
- **Production-ready** SSL, security, monitoring, and backup capabilities

**Key Principle**: Same deployment script (`deploy.sh`) works for ALL applications. Only `deploy.ini` needs modification per application.

## Installation & Configuration Guide

### Prerequisites Installation

```bash
# Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo usermod -aG docker $USER

# Install Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Install required tools
sudo apt-get update
sudo apt-get install -y curl jq ufw git
```

### Application Setup

#### 1. Clone Application Template
```bash
git clone <repository-url> my-new-app
cd my-new-app
```

#### 2. Configure Application (ONLY file to modify)

Edit `deploy.ini`:
```ini
# Global Variables
NAME_OF_APPLICATION="my-new-app"           # Change this
APPLICATION_IDENTITY_NUMBER=5              # Unique number
RANGE_START=6000                           # Port range start
RANGE_RESERVED=10                          # Ports per user
```

**Port Calculation**: `PORT = RANGE_START + (USER_ID * RANGE_RESERVED)`

#### 3. Deploy Application
```bash
# Make deploy script executable
chmod +x deploy.sh

# Deploy with user parameters
./deploy.sh start [USER_ID] [USER_NAME] [USER_EMAIL] [DESCRIPTION]
```

### Complete Deployment Example

```bash
# Example: Deploy for user ID 1
./deploy.sh start 1 "john" "john@example.com" "My Production App"

# This automatically:
# - Calculates ports: HTTP=6010, HTTPS=6011
# - Generates SSL certificates
# - Creates environment variables
# - Builds and starts containers
# - Configures firewall
# - Sets up monitoring and backups
```

### Management Commands

```bash
# Check application status (returns JSON)
./deploy.sh ps

# Stop application
./deploy.sh stop

# Restart application
./deploy.sh restart 1 "john" "john@example.com"

# View logs
./deploy.sh logs
```

### Configuration Files Overview

#### Core Files (DO NOT MODIFY)
- `deploy.sh` - Universal deployment script
- `docker-compose.yml` - Development environment
- `docker-compose.prod.yml` - Production environment
- `Dockerfile` - Container definition
- `nginx.conf` - Reverse proxy configuration

#### Application-Specific Files (MODIFY AS NEEDED)
- `deploy.ini` - **ONLY file requiring changes per application**
- `src/` - Application source code
- `templates/` - HTML templates
- `static/` - CSS, JS, images
- `requirements.txt` - Python dependencies

### Port Management System

**Automatic Port Allocation**:
```
User ID 0: Ports 6000-6009
User ID 1: Ports 6010-6019
User ID 2: Ports 6020-6029
...
```

**Port Assignment**:
- HTTP Port: `RANGE_START + (USER_ID * RANGE_RESERVED)`
- HTTPS Port: `HTTP_PORT + 1`

### GenAI Integration Workflow

1. **Generate Application Code**: GenAI creates application-specific files
2. **Update Configuration**: Modify only `deploy.ini` with new application details
3. **Deploy**: Run `./deploy.sh start` with user parameters
4. **Scale**: Deploy multiple instances with different USER_IDs

### Security & Production Features

**Automatically Configured**:
- SSL/TLS certificates (Let's Encrypt or self-signed)
- UFW firewall rules
- Container health checks
- Application monitoring
- Automated backups
- Log rotation

### Troubleshooting

```bash
# Check Docker status
sudo systemctl status docker

# View application logs
docker-compose -f docker-compose.prod.yml logs -f

# Check port usage
sudo netstat -tlnp | grep :6010

# Verify firewall
sudo ufw status
```

### Multi-Application Deployment

```bash
# Deploy multiple applications for same user
./deploy.sh start 1 "john" "john@example.com" "App 1"
cd ../another-app
./deploy.sh start 1 "john" "john@example.com" "App 2"

# Deploy same application for different users
./deploy.sh start 1 "john" "john@example.com" "John's Instance"
./deploy.sh start 2 "jane" "jane@example.com" "Jane's Instance"
```

This tooling enables rapid, consistent deployment of containerized applications with zero manual configuration, making it ideal for GenAI-driven development workflows.