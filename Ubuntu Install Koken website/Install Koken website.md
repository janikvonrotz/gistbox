# Introduction

Koken is a content management system and image publishing application for photographers.
Head over to [http://koken.me/](http://koken.me/) to learn more about Koken.

# Requirements

* [Ubuntu server](https://janikvonrotz.ch/2014/03/13/deploy-ubuntu-server/)
* [Nginx](https://janikvonrotz.ch/2014/03/31/install-nginx/)
* [Nginx minimal website](https://janikvonrotz.ch/2014/04/01/nginx-minimal-website/)
* [php5-fpm](https://janikvonrotz.ch/2014/03/20/install-php5-fpm/)
* [php5-mysql, php5-curl](https://janikvonrotz.ch/2014/03/25/install-php5-modules/)
* [Nginx php5-fpm website](https://janikvonrotz.ch/2014/04/11/install-nginx-php5-fpm-website/)
* [MySQL](https://janikvonrotz.ch/2014/04/07/install-mysql/)
* [Increased Max Upload for php5-fpm website](https://janikvonrotz.ch/2014/04/11/increase-max-upload-for-php5-fpm-website/)

# Installation

Create the application directory

    sudo mkdir /var/www/<Koken>/

Open the Koken application directory

    cd /var/www/<Koken>/

Download latest Koken package and unzip it. You can get the link to the latest release here: [http://help.koken.me/customer/portal/articles/632102-installation](http://help.koken.me/customer/portal/articles/632102-installation).

    sudo wget https://s3.amazonaws.com/install.koken.me/releases/Koken_Installer.zip
    sudo unzip Koken_Installer.zip
    
Copy the extracted files to the current folder and delete the other files
    
    sudo cp -r ./Koken_Installer/koken/* ./
    sudo rm -r Koken_Installer
    sudo rm Koken_Installer.zip

Let's create the MySQL Koken database and user.

    mysql -u root -p
    
Enter the MySQL root user password.

Create the Koken database.

    CREATE DATABASE <koken>;
    
Create the Koken database user.

    CREATE USER <koken>@localhost;

Set the password for the Koken database user.

    SET PASSWORD FOR <koken>@localhost = PASSWORD("<password>");
    
Grant Koken user full access on the Koken database.

    GRANT ALL PRIVILEGES ON <koken>.* TO <koken>@localhost IDENTIFIED BY '<password>';
    
Refresh MySQL and exit.

    FLUSH PRIVILEGES;
    exit

Add the Nginx configuration to the Koken website configuration file.

```
server{    
 
  ...
 
     # Standard site requests are cached with .html extensions
    set $cache_ext 'html';
    
    # Enable gzip. Highly recommending for best peformance
    gzip on;
    gzip_comp_level 6;
    gzip_types text/html text/css text/javascript application/json application/javascript application/x-javascript;

    # By default, do not set expire headers
    expires 0;

    # Set expires header for console CSS and JS.
    # These files are timestamped with each new release, so it is safe to cache them agressively.
    location ~ "console_.*\.(js|css)$" {
        expires max;
    }
    
    # Catch image requests and pass them back to PHP if a cache does not yet exist
    location ~ "^/storage/cache/images(/(([0-9]{3}/[0-9]{3})|custom)/.*)$" {
        # Cached images have timestamps in the URL, so it is safe to set
        # aggresive cache headers here.
        expires max;
        try_files $uri /i.php?path=$1;
    }

    # Catch .css.lens requests and serve cache when possible
    location ~ "(lightbox-)?settings.css.lens$" {
        default_type text/css;
        try_files /storage/cache/site/${uri} /app/site/site.php?url=/$1settings.css.lens;
    }

    # Catch koken.js requests and serve cache when possible
    location ~ koken.js$ {
        default_type text/javascript;
        try_files /storage/cache/site/${uri} /app/site/site.php?url=/koken.js;
    }

    # PJAX requests contain the _pjax GET parameter and are cached with .phtml extensions
    if ($arg__pjax) {
        set $cache_ext 'phtml';
    }

    # Do not check for a cache for non-GET requests
    if ($request_method != 'GET') {
        set $cache_ext 'nocache';
    }

    # If share_to_tumblr cookie is preset, disable caching (long story)
    if ($http_cookie ~* "share_to_tumblr" ) {
        set $cache_ext 'nocache';
    }

    # Catch root requests
    location ~ ^/?$ {
        try_files /storage/cache/site/index/cache.$cache_ext /app/site/site.php?url=/;
    }
  
    # All other requests get passed back to Koken unless file already exists
    location / {
        try_files $uri $uri/ /storage/cache/site/${uri} /storage/cache/site/${uri}cache.$cache_ext /app/site/site.php?url=$uri&$args;
    }
 
  ...
 
```

Grant permissions for the `www-data` group and user.

    sudo chown www-data:www-data /var/www/<koken> -R 
    
Test config and reload Nginx service.

    sudo nginx -t && sudo service nginx reload

Open the browser again on `//<host>` and install the Koken application.

# Source

[nginx rewrite setup for Koken](https://gist.github.com/bradleyboy/26ffd2ec7da68919ecd1)