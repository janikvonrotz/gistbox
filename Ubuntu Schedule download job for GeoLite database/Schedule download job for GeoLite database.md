# Introduction

The GeoLite databases are our free IP geolocation databases. They are updated on the first Tuesday of each month.

# Requirements

* Ubuntu server

# Installation

Add a monthly cron job.

    sudo vi /etc/cron.monthly/downloadgeolitedatabase

with the following content.

```
#!/bin/sh

wget http://geolite.maxmind.com/download/geoip/database/GeoLiteCity.dat.gz -P /tmp/
gunzip /tmp/GeoLiteCity.dat.gz

# add copy and other commands here:
# start region: modification

# cp /tmp/GeoLiteCity.dat [destination]

# end region: modification

rm /tmp/GeoLiteCity.dat
```

Enable execution of the script for the owner.

    sudo chmod o+x /etc/cron.monthly/downloadgeolitedatabase

# Source

[GeoLite Free Downloadable Databases](http://dev.maxmind.com/geoip/legacy/geolite/)  
[How do I get the GeoIP databases to improve accuracy of Country detection, and detect visitors’ Cities and Regions?](http://piwik.org/faq/how-to/faq_163/)