# Introduction

# Requirements

* Ubuntu server
* Nginx
* Nginx minimal website
* HHVM

# Installation

    fastcgi_pass unix:/var/run/hhvm.socket;
    fastcgi_index index.php;
    fastcgi_param SCRIPT_FILENAME $php_root$fastcgi_script_name;
    include fastcgi_params;

Test the Nginx configurations.

    sudo nginx -t

Reload Nginx service.

    sudo service nginx reload
    
    
    server{
        
        listen 80;
        server_name test.janikvonrotz.ch;
    
        location / {
    
            root /usr/share/phpmyadmin;
            index index.php;
    
        }
    
        location ~ \.(hh|php)$ {
    
            set $php_root /usr/share/phpmyadmin;
    
            fastcgi_keep_conn on;
            fastcgi_pass   127.0.0.1:9000;
            fastcgi_index  index.php;
            fastcgi_param  SCRIPT_FILENAME $document_root$fastcgi_script_name;
            include        fastcgi_params;
        }
    }

# Source

[FasterCGI with HHVM](http://hhvm.com/blog/1817/fastercgi-with-hhvm)  
[HHVM, Nginx and Laravel](http://fideloper.com/hhvm-nginx-laravel)  
[GitHub HHVM Wiki Prebuilt Packages on Ubuntu 12.04](https://github.com/facebook/hhvm/wiki/Prebuilt-Packages-on-Ubuntu-12.04)