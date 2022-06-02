#!/bin/bash
sudo apt-get -y update

# set up a silent install of MySQL
source yobichain.conf

# install the LAMP stack
echo ''
echo ''
echo ''
echo '---------------------------------'
echo -e 'INSTALLING APACHE AND PHP...'
echo '---------------------------------'
echo ''
echo ''

sudo apt-add-repository -y ppa:ondrej/php
sudo apt-get -y update

sudo apt-get -y install apache2 apache2-utils
sudo apt-get -y install php"$phpversion" php"$phpversion"-curl

# restart Apache
echo ''
echo ''
echo ''
echo '------------------------------'
echo -e 'RESTARTING APACHE...'
echo '------------------------------'
echo ''
echo ''
sudo sed -i -e 's,PrivateTmp=true,PrivateTmp=false\nNoNewPrivileges=yes,g' /lib/systemd/system/apache2.service
sudo systemctl daemon-reload
sudo systemctl restart apache2