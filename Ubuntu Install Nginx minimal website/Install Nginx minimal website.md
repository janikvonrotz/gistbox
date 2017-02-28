# Introduction

This is a minimal Nginx website configuration. It's a good way to start your next project.

# Requirements

* Ubuntu server
* Nginx

# Installation

Add this configuration file to the config folder `/etc/nginx/conf.d`.

    sudo vi /etc/nginx/conf.d/[host].conf


With the content showed below.

```
server{

    listen 80;
    server_name [host];
    
    root /var/www/[host];
    index index.php index.html;
    
    # host error and access log
    access_log /var/log/nginx/[host].access.log;
    error_log /var/log/nginx/[host].error.log;
    
    location / {
    }
    
    # redirect server error pages to the static page /50x.html
    error_page   500 502 503 504  /50x.html;
    location = /50x.html {
        root   /usr/share/nginx/html;
    }
}
```
Update permissions for the `www-data` group.

    sudo chown www-data:www-data /var/www/[host] -R 
    
Test config and reload Nginx service.

    sudo nginx -t && sudo service nginx reload