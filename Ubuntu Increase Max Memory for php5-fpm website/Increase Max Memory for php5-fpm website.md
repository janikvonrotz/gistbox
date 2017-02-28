# Introduction

In some cases the default memory allocation for php is not enough to run an application properly.

# Requirements

* Ubuntu server
* Nginx
* php5-fpm
* Nginx minimal website
* Nginx php5-fpm website

# Instruction

Update the php5-fpm config.

    sudo vi /etc/php5/fpm/php.ini
    Set memory_limit = 512M

Restart the php5-fpm service.

    sudo service php5-fpm restart
    