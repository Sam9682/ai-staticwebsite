#!/bin/bash

# Initialize website directory structure
mkdir -p /var/www

# Check if templates/index.html exists
if [ -f "/app/templates/index.html" ]; then
    # Use templates folder if index.html exists
    echo "Found index.html in templates, using custom templates..."
    cp -r /app/templates/* /var/www/html
    echo "Website initialized with custom templates"
else
    # Use default source if no index.html in templates
    echo "No index.html in templates, using default source..."
    cp -r /app/default_web_site_source/* /var/www/html
    echo "Website initialized with default content"
fi