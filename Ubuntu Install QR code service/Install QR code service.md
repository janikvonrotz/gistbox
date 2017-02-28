# Introduction

To generate QR codes with php we are using the project [QR Generator PHP](https://github.com/janikvonrotz/QR-Generator-PHP) hosted on GitHub.

# Requirements

* Ubuntu server
* Nginx
* Nginx minimal website
* php5-fpm
* Nginx php5-fpm website

# Installation

Clone project with git.

    cd /usr/local/src
    sudo git clone https://github.com/janikvonrotz/QR-Generator-PHP.git

Rename the project directory to get a shorter url.

    sudo mv QR-Generator-PHP qr

Add the config to one of your Nginx sites.


```
server{
    
    ...
    
    # change location for QR code requests
    location /qr{
        root /usr/local/src;
        index index.php;
    }
    
    location ~ .php$ {
        
        ...
        
        # change the php root for QR code requests
        if ($request_uri ~* /qr) {
            set $php_root /usr/local/src;
        }
        
        ...
    }
}
```

Test config and reload Nginx service.

    sudo nginx -t && sudo service nginx reload

Test the new QR code service by open a browser on `//[host]/qr/?d=example.org`.