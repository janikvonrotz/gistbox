# Introduction

LimeSurvey is the leading open source survey application.
<!--more-->
# Requirements

* [Ubuntu server](https://janikvonrotz.ch/2014/03/13/deploy-ubuntu-server/)
* [Nginx](https://janikvonrotz.ch/2014/03/31/install-nginx/)
* [Nginx minimal website](https://janikvonrotz.ch/2014/04/01/nginx-minimal-website/)
* [php5-fpm](https://janikvonrotz.ch/2014/03/20/install-php5-fpm/)
* [php5-mysql](https://janikvonrotz.ch/2014/03/25/install-php5-modules/)
* [Nginx php5-fpm website](https://janikvonrotz.ch/2014/04/11/install-nginx-php5-fpm-website/)
* [MySQL](https://janikvonrotz.ch/2014/04/07/install-mysql/)
* [Increased Max Upload for php5-fpm website](https://janikvonrotz.ch/2014/04/11/increase-max-upload-for-php5-fpm-website/)

# Installation

Create the application directory

    sudo mkdir /var/www/<limesurvey>/

Open the LimeSurvey application directory

    cd /var/www/<limesurvey>/

Download latest LimeSurvey package and untar it. You can get the link to the latest release here: [https://www.limesurvey.org/en/stable-release](https://www.limesurvey.org/en/stable-release).

    sudo wget http://download.limesurvey.org/Latest_stable_release/limesurvey205plus-build150310.tar.gz
    sudo tar -xzvf limesurvey205plus-build150310.tar.gz
    
Copy the extracted files to the current folder and delete the other files
    
    sudo cp -r ./limesurvey/* ./
    sudo rm -r limesurvey
    sudo rm limesurvey205plus-build150310.tar.gz

Let's create the MySQL LimeSurvey database and user.

    mysql -u root -p
    
Enter the MySQL root user password.

Create the LimeSurvey database.

    CREATE DATABASE <limesurvey>;
    
Create the LimeSurvey database user.

    CREATE USER <limesurvey>@localhost;

Set the password for the LimeSurvey database user.

    SET PASSWORD FOR <limesurvey>@localhost = PASSWORD("<password>");
    
Grant LimeSurvey user full access on LimeSurvey database.

    GRANT ALL PRIVILEGES ON <limesurvey>.* TO <limesurvey>@localhost IDENTIFIED BY '<password>';
    
Refresh MySQL and exit.

    FLUSH PRIVILEGES;
    exit

Grant permissions for the `www-data` group and user.

    sudo chown www-data:www-data /var/www/<limesurvey> -R 
    
Test config and reload Nginx service.

    sudo nginx -t && sudo service nginx reload

Open the browser again on `//<host>` and install the LimeSurvey application.