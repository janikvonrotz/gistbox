# Introduction

By default Piwik uses the provider location to guess a visitor's country based on the language they use. This is not very accurate, so they recommend installing and using GeoIP.

# Requirements

* Ubuntu server
* libgeoip-dev
* Nginx
* Nginx minimal website
* php5-fpm
* MySQL
* php5-dev, php5-geoip, php5-mysql
* Nginx php5-fpm website
* Piwik website

# Installation

Download the latest GeoLite database

    sudo wget http://geolite.maxmind.com/download/geoip/database/GeoLiteCity.dat.gz -P /var/www/[piwik]/misc/

Unzip the database.

    sudo gunzip /var/www/[piwik]/misc/GeoLiteCity.dat.gz

Rename the file.

    cd /var/www/[piwik]/misc
    sudo mv GeoLiteCity.dat GeoIPCity.dat

Update the access rights.

    sudo chown www-data:www-data GeoIPCity.dat

Update the php configuration file.

    sudo vi /etc/php5/fpm/php.ini

Add the geoip configuration.
    
    geoip.custom_directory = /var/www/[piwik]/misc

Restart Nginx and php5-fpm service.

    sudo nginx -t && sudo service nginx reload
    sudo service php5-fpm restart

Now open your piwik installation on `//[host]/piwik/index.php?module=UserCountry&action=adminIndex` and check the `GeoIP (PECL)` option.

In addition the the GeoLite download url to the `Download URL` field and click save.

# Source

[How do I install the GeoIP Geo location PECL extension?](http://piwik.org/faq/how-to/#faq_164)