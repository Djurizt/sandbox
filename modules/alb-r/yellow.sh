#!/bin/bash
set -e  # Exit immediately if a command fails

# Update package lists
sudo apt update -y

# Install Apache (Ubuntu uses 'apache2', not 'httpd')
sudo apt install -y apache2

# Start and enable Apache
sudo systemctl start apache2
sudo systemctl enable apache2

# Create a directory for the Yellow App
sudo mkdir -p /var/www/html/yellow

# Create an HTML file for the Yellow Webserver
echo "<html><body style='background-color:yellow;'><h1>Yellow Webserver</h1><p>Hostname: $(hostname)</p><p>IP Address: $(hostname -I | awk '{print $1}')</p></body></html>" | sudo tee /var/www/html/yellow/index.html

# Set correct ownership (Ubuntu uses 'www-data', not 'apache')
sudo chown -R www-data:www-data /var/www/html/yellow
sudo chmod -R 755 /var/www/html/yellow

# Restart Apache to apply changes
sudo systemctl restart apache2