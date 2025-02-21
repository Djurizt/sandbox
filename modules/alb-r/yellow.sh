#!/bin/bash



sudo apt update -y

sudo apt install -y apache2

sudo systemctl start apache2
sudo systemctl enable apache2

sudo mkdir -p /var/www/html/yellow

echo "<html><body style='background-color:yellow;'><h1>Yellow Webserver</h1><p>Hostname: $(hostname)</p><p>IP Address: $(hostname -I | awk '{print $1}')</p></body></html>" | sudo tee /var/www/html/yellow/index.html

sudo chown -R www-data:www-data /var/www/html/yellow
sudo chmod -R 755 /var/www/html/yellow


sudo systemctl restart apache2