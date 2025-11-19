#!/bin/bash

# Initialize website directory structure
mkdir -p /var/www
cp -r /app/default_web_site_source /var/www/web_site_source_default
ln -sf /var/www/web_site_source_default /var/www/html

echo "Website initialized with default content"