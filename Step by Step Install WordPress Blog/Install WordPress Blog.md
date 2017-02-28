Finishing this guide you'll get:

* A running WordPress installation
* Nginx proxy with PHP and Fast CGI
* MySQL server accessible with phpMyAdmin


Specification of latest running installation:

* Date: 03.03.2014  
* OS: Ubuntu 64 bit - 12.04.4 LTS 
* Provider: Amazon EC2
* Browser: Google Chrome - 33.0.1750.117
* WordPress: 3.8.1
* Nginx: 1.1.19
* MySQL: 5.5.35
* PHP: 5.3.10
* phpMyAdmin: 3.4.10.1

Requirements

* Server is behind a firewall, that only allows http, https and ssh
* The server is accessed with ssh keys (user password authentication must be disabled)
* Server is not accessed with the root user
* You're able to edit files with [VI](http://www.cheatography.com/ericg/cheat-sheets/vi-editor/)


## Ubuntu

Update Ubuntu

	sudo apt-get update && sudo apt-get upgrade
    
Install additional packages
    
	sudo aptitude install build-essential zip git

## MySQL

Install MySQL server and php5 MySQL module

	sudo apt-get install mysql-server php5-mysql
    
Set the mysql root user password during the installation

Install the default MySQL databases

	sudo mysql_install_db
    
Run the finisher script and respond every prompt with yes to get a secure MySQL installation

	sudo /usr/bin/mysql_secure_installation
        
Connect to your new MySQL server

	mysql -uroot -p
    
Enter the root password

And run this command to get the MySQL version

	SHOW variables LIKE "%version%";

## Nginx

Install Nginx

	sudo apt-get install nginx
    	
Create a Nginx site configuration file

	sudo touch /etc/nginx/sites-available/wordpress.conf
	sudo vi /etc/nginx/sites-available/wordpress.conf

Paste this config

```
server {    
listen   80;

	root /var/www/wordpress;
	index index.php index.html index.htm;

	server_name [example.com];

	location / {
		try_files $uri $uri/ /index.php?q=$uri&$args;
	}

	error_page 404 /404.html;

	error_page 500 502 503 504 /50x.html;
	location = /50x.html {
		root /usr/share/nginx/www;
	}
    
    client_max_body_size 10M;

	# pass the PHP scripts to FastCGI server listening on 127.0.0.1:9000
	location ~ \.php$ {
		try_files $uri = 404;
		#fastcgi_pass 127.0.0.1:9000;
		# With php5-fpm:
		fastcgi_pass unix:/var/run/php5-fpm.sock;
		fastcgi_index index.php;
		include fastcgi_params;
	}
}
```

Optionally you can rewrite false urls to a specified canonical url

```
server {
    listen       80;
    server_name  www.example.com  example.com;
    if ($http_host = www.example.org) {
        rewrite  (.*)  http://[example.com]$1;
    }
    ...
}
```

Create a symlink to the config file

	sudo ln -s /etc/nginx/sites-available/wordpress.conf /etc/nginx/sites-enabled/wordpress.conf
	    
Restart Ngnix

	sudo service nginx restart
    
Check Nginx version

	nginx -v

## PHP

Install PHP with FastCGI support

	sudo apt-get install php5-fpm

configure PHP installaton

	 sudo vi /etc/php5/fpm/php.ini
     
Find the line `cgi.fix_pathinfo=1` by pressing ESC and enter

	/;cgi.fix_pathinfo=1
    
Uncomment this line and change value to 0

	cgi.fix_pathinfo=0
    
If this number is kept as 1, the php interpreter will do its best to process the file that is as near to the requested file as possible. This is a possible security risk. If this number is set to 0, conversely, the interpreter will only process the exact file path—a much safer alternative.

Find the line `; default extension directory.` and insert below

	extension=mcrypt.so

Update the listening port for the php fpm

	sudo vi /etc/php5/fpm/pool.d/www.conf
	Set listen = /var/run/php5-fpm.sock

Restart the service

	sudo service php5-fpm restart
    
Create the website folder

	sudo mkdir /var/www/wordpress
    
Add a PHP info file

	sudo vi /var/www/wordpress/info.php
    
Set content

```
<?php
phpinfo();
?>
```

Open your browser on http://example.com/info.php

Delete this file if everything works

## phpMyAdmin

Install phpMyAdmin

	sudo apt-get install phpmyadmin
    
When phpMyAdmin prompts you to choose a server (either apache or lighttpd)hit tab, and select neither one. 

When phpMyAdmin asks you wether to configure database for phpmyadmin with dbconfig-common. Chose <Yes> and enter the MySQL root user password

Hit <OK> on the MySQL application password for phpmyadmin prompt.

Create a symbolic link for the phpMyAdmin website

	sudo ln -s /usr/share/phpmyadmin/ /usr/share/nginx/www
    
Create a Nginx configuration file

	sudo touch /etc/nginx/sites-available/phpmyadmin.conf
	sudo vi /etc/nginx/sites-available/phpmyadmin.conf

Paste this config


```
server{
	listen 80;
	
	server_name [Your Public IP];
	root /var/www/;
	
	index index.php index.html index.htm;
	
    client_max_body_size 10M;
    
	location ~ .php$ {
		try_files $uri = 404;
		fastcgi_pass unix:/var/run/php5-fpm.sock;
		fastcgi_index index.php;
		include /etc/nginx/fastcgi_params;
	}
}
```

Create a symlink to the config file

	sudo ln -s /etc/nginx/sites-available/phpmyadmin.conf /etc/nginx/sites-enabled/phpmyadmin.conf
        
Restart Ngnix

	sudo service nginx restart
    
Open the browser on http://[YourPublicIP]/phpmyadmin/

## WordPress
	
Open the WordPress site directory

	cd /var/www/wordpress/

Download latest WordPress package and untar it

	sudo wget http://wordpress.org/latest.tar.gz
	tar -xzvf latest.tar.gz
    
Copy the untared files to the current folder and delete the other files

	sudo cp -r ./wordpress/* ./
    sudo rm -r wordpress
    sudo rm latest.tar.gz

Let's create the MySQL WordPress user

	mysql -u root -p
    
Enter the MySQL root user password

Create the WordPress database

	CREATE DATABASE wordpress;
    
Create the WordPress database user

	CREATE USER wordpress@localhost;

Set the password for the WordPress database user

	SET PASSWORD FOR wordpress@localhost = PASSWORD("[password]");
    
Grant WordPress user full access on WordPress database

	GRANT ALL PRIVILEGES ON wordpress.* TO wordpress@localhost IDENTIFIED BY '[password]';
    
Refresh MySQL and exit

	FLUSH PRIVILEGES;
    exit
    
Copy the WordPress example config file

	sudo cp wp-config-sample.php wp-config.php

Edit the config file

	sudo vi wp-config.php

Set database, database user and his password

```
define('DB_NAME', 'wordpress');

define('DB_USER', 'wordpress');

define('DB_PASSWORD', '[password]');
```

Update permissions for Nginx user

    sudo chown www-data:www-data * -R 
    sudo usermod -a -G www-data www-data

Open the browser on http://example.com and install you WordPress blog

## Source

[Install MySQL](http://dev.mysql.com/doc/refman/5.7/en/linux-installation-native.html)  
[How To Install Linux, nginx, MySQL, PHP (LEMP) stack on Ubuntu 12.04 by Digital Ocean](https://www.digitalocean.com/community/articles/how-to-install-linux-nginx-mysql-php-lemp-stack-on-ubuntu-12-04)  
[How To Install phpMyAdmin on a LEMP server by Digi](https://www.digitalocean.com/community/articles/how-to-install-phpmyadmin-on-a-lemp-server/)  
[How To Install Wordpress with nginx on Ubuntu 12.04 by Digital Ocean](https://www.digitalocean.com/community/articles/how-to-install-wordpress-with-nginx-on-ubuntu-12-04)  
[Nginx rewrite rules](http://nginx.org/en/docs/http/converting_rewrite_rules.html)  
[Get MySQL version](https://dev.mysql.com/doc/refman/5.0/en/installation-version.html)