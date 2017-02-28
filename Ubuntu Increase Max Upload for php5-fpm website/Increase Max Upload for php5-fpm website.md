# Introduction

Some php based websites require more than the default of 2 MB of upload filesize.
To increase this value you have to update the php5-fpm and Nginx configuration.

# Requirements

* Ubuntu server
* Nginx
* php5-fpm
* Nginx minimal website
* Nginx php5-fpm website

# Instruction

First update the php5-fpm config.

    sudo vi /etc/php5/fpm/php.ini
    Set upload_max_filesize = 10M
    Set post_max_size = 10M

Restart the php5-fpm service.

    sudo service php5-fpm restart


Add this Nginx configuration to your website config.
```
server{

  ...

  # change upload max size
  client_max_body_size 10M;

  ... 
}
```
    
    
Test config and reload Nginx service.

    sudo nginx -t && sudo service nginx reload
    