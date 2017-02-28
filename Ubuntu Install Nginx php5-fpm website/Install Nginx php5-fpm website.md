# Introduction

This is a minimal Nginx configuration to run php based websites/ applications.

# Requirements

* Ubuntu server
* Nginx
* Nginx minimal website
* php5-fpm

# Installation

Add this Nginx configuration to your website config.
```
server{

    ...
    
    # php5-fpm configuration
    location ~ \.php$ {
        
        set $php_root /var/www/[host];
        
        fastcgi_pass unix:/var/run/php5-fpm.sock;
        fastcgi_index index.php;
        fastcgi_param SCRIPT_FILENAME $php_root$fastcgi_script_name;
        include /etc/nginx/fastcgi_params;
    }
}
```
Test config and reload Nginx service.

    sudo nginx -t && sudo service nginx reload