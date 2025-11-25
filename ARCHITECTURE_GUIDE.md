# Architecture Guide

## System Overview

This universal deployment system follows a **template-based architecture** that enables zero-configuration deployment of containerized applications through standardized components and GenAI automation.

## Core Architecture Components

### 1. Universal Deployment Script (`deploy.sh`)
**Purpose**: Single script that handles all deployment operations across all applications

**Key Features**:
- Reads configuration from `deploy.ini`
- Calculates ports dynamically based on user ID
- Manages Docker Compose environments (dev/prod)
- Handles SSL certificate generation
- Configures firewall rules
- Provides unified CLI interface

**Operations**:
```bash
./deploy.sh start [USER_ID] [USER_NAME] [USER_EMAIL] [DESCRIPTION]
./deploy.sh stop
./deploy.sh restart [USER_ID] [USER_NAME] [USER_EMAIL]
./deploy.sh ps
./deploy.sh logs
```

### 2. Configuration System (`deploy.ini`)
**Purpose**: Single source of truth for application-specific settings

**Structure**:
```ini
NAME_OF_APPLICATION="app-name"
APPLICATION_IDENTITY_NUMBER=5
RANGE_START=6000
RANGE_RESERVED=10
```

**Why This Works**:
- Only file that changes between applications
- GenAI can easily modify this single file
- All other components remain identical

### 3. Docker Compose Architecture

#### Development Environment (`docker-compose.yml`)
```yaml
services:
  app:
    build: .
    ports:
      - "${HTTP_PORT}:5000"
    environment:
      - FLASK_ENV=development
```

#### Production Environment (`docker-compose.prod.yml`)
```yaml
services:
  app:
    build: .
    restart: unless-stopped
    
  nginx:
    image: nginx:alpine
    ports:
      - "${HTTP_PORT}:80"
      - "${HTTPS_PORT}:443"
    volumes:
      - ./ssl:/etc/nginx/ssl
```

**Environment Variable Injection**:
- `deploy.sh` generates `.env` file dynamically
- Variables calculated from `deploy.ini` + user parameters
- Same compose files work for all applications

## Port Management Architecture

### Dynamic Port Allocation
```
Formula: PORT = RANGE_START + (USER_ID * RANGE_RESERVED)

Example with RANGE_START=6000, RANGE_RESERVED=10:
User 0: HTTP=6000, HTTPS=6001
User 1: HTTP=6010, HTTPS=6011
User 2: HTTP=6020, HTTPS=6021
```

### Multi-Tenant Support
- Each user gets dedicated port range
- No port conflicts between users
- Automatic firewall rule generation
- SSL certificates per port

## GenAI Automation Workflow

### 1. Application Generation Phase
```
GenAI Input: "Create a blog application"
↓
GenAI Generates:
├── src/app.py (application code)
├── templates/ (HTML files)
├── static/ (CSS/JS)
├── requirements.txt
└── deploy.ini (ONLY file needing modification)
```

### 2. Configuration Phase
```
GenAI Modifies deploy.ini:
NAME_OF_APPLICATION="blog-app"
APPLICATION_IDENTITY_NUMBER=7
RANGE_START=6000
RANGE_RESERVED=10
```

### 3. Deployment Phase
```bash
# GenAI executes:
./deploy.sh start 1 "user" "user@email.com" "Blog Application"

# System automatically:
# 1. Reads deploy.ini
# 2. Calculates ports (6010, 6011)
# 3. Generates .env file
# 4. Builds containers
# 5. Configures SSL
# 6. Opens firewall ports
# 7. Starts services
```

## File Structure Architecture

### Template Structure (Same for All Apps)
```
application/
├── deploy.sh              # Universal deployment script
├── deploy.ini             # Application-specific config
├── docker-compose.yml     # Development environment
├── docker-compose.prod.yml # Production environment
├── Dockerfile             # Container definition
├── nginx.conf             # Reverse proxy config
├── src/                   # Application source
├── templates/             # HTML templates
├── static/               # Static assets
└── requirements.txt      # Dependencies
```

### Generated Files (Runtime)
```
application/
├── .env                  # Generated environment variables
├── ssl/                  # Generated SSL certificates
└── logs/                # Application logs
```

## Container Architecture

### Multi-Container Setup
```
┌─────────────────┐    ┌─────────────────┐
│     Nginx       │    │   Application   │
│  (Reverse Proxy)│◄───┤   Container     │
│   SSL Termination│    │   (Flask/etc)   │
└─────────────────┘    └─────────────────┘
        │
        ▼
┌─────────────────┐
│   Host Network  │
│  Ports: 6010,   │
│         6011    │
└─────────────────┘
```

### Container Communication
- Nginx forwards requests to application container
- Internal Docker network for service communication
- External ports exposed only through Nginx
- SSL termination at proxy level

## Security Architecture

### Automated Security Features
```
deploy.sh automatically configures:
├── UFW Firewall Rules
├── SSL/TLS Certificates
├── Container Isolation
├── Non-root Container Users
└── Log Rotation
```

### Certificate Management
```bash
# Self-signed for development
openssl req -x509 -newkey rsa:4096 -nodes -out ssl/cert.pem -keyout ssl/key.pem

# Let's Encrypt for production (future enhancement)
certbot --nginx -d domain.com
```

## Scalability Architecture

### Horizontal Scaling
```
Same Application, Multiple Users:
├── User 1: Ports 6010-6019
├── User 2: Ports 6020-6029
└── User N: Ports 6000+(N*10) to 6009+(N*10)
```

### Multi-Application Scaling
```
Different Applications, Same User:
├── Blog App:     Ports 6010-6011
├── Shop App:     Ports 7010-7011
└── API App:      Ports 8010-8011
```

## GenAI Integration Points

### 1. Code Generation
- GenAI creates application-specific source code
- Follows standard project structure
- Generates appropriate Dockerfile and requirements

### 2. Configuration Management
- GenAI modifies only `deploy.ini`
- Calculates unique APPLICATION_IDENTITY_NUMBER
- Sets appropriate port ranges

### 3. Deployment Automation
- GenAI executes deployment commands
- Monitors deployment status
- Handles error recovery

### 4. Evolution Management
```
GenAI Workflow for App Updates:
1. Modify source code files
2. Update requirements.txt if needed
3. Keep deploy.ini unchanged (unless ports conflict)
4. Run: ./deploy.sh restart [USER_ID] [USER_NAME] [USER_EMAIL]
```

## Benefits of This Architecture

### For GenAI
- **Predictable Structure**: Same files, same locations
- **Single Configuration Point**: Only `deploy.ini` changes
- **Standardized Commands**: Same `deploy.sh` for all apps
- **Error Handling**: Consistent error patterns

### For Developers
- **Zero Learning Curve**: Same process for all applications
- **Rapid Deployment**: One command deployment
- **Production Ready**: Built-in SSL, monitoring, backups
- **Multi-Tenant**: Automatic user isolation

### For Operations
- **Consistent Monitoring**: Same log locations, same metrics
- **Predictable Troubleshooting**: Same debugging process
- **Automated Security**: Built-in best practices
- **Easy Scaling**: Add users/apps without conflicts

## Extension Points

### Adding New Application Types
1. Create new Dockerfile for different runtime
2. Modify docker-compose templates if needed
3. Keep `deploy.sh` and `deploy.ini` structure
4. GenAI can now deploy this new type

### Adding New Features
1. Extend `deploy.sh` with new commands
2. Add configuration options to `deploy.ini`
3. Update docker-compose templates
4. All existing applications inherit new features

This architecture enables true **Infrastructure as Code** where GenAI can rapidly create, deploy, and evolve applications with minimal human intervention while maintaining production-grade reliability and security.