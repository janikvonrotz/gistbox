# Requirements

* Ubuntu server
* Nginx
* Nginx minimal website
* php5-fpm
* php5-mysql, php5-mcrypt
* Nginx php5-fpm website
* MySQL

# Installation

Start the installation phpMyAdmin.

    sudo apt-get install phpmyadmin
  
As we use nginx for this installation, hit Tab and Enter on the first prompt.

Chose <Yes> and enter the MySQL root password on the second prompt.

Create a secure password for phpMyAdmin. Don't use the MySQL root password!

Add the phpMyAdmin Nginx configuration to one of your websites.

```
server{
    ...
    
    root /usr/share;

    ...

    location ~ .php$ {
        
        ...
        
        # change the php root for phpMyAdmin
        if ($request_uri ~* /phpmyadmin) {
            set $php_root /usr/share;
        }
        
        ...
    }
}
```

Test config and reload Nginx service.

    sudo nginx -t && sudo service nginx reload
    
Open your browser on `//[host]/phpmyadmin`.
