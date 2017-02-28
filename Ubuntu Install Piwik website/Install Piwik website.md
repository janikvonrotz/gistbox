# Introduction

Piwik is the leading open source web analytics platform that gives you valuable insights into your website’s visitors, your marketing campaigns and much more, so you can optimize your strategy and online experience of your visitors.

# Requirements

* Ubuntu server
* Nginx
* Nginx minimal website
* php5-fpm
* MySQL
* php5-mysql
* Nginx php5-fpm website


# Installation

Create the new Piwik website folder.

    sudo mkdir /var/www/[piwik]
    cd /var/www/[piwik]

Download latest piwik

    sudo wget http://builds.piwik.org/latest.tar.gz
    sudo tar -xzvf latest.tar.gz

Copy Piwik content and delete unnecessary files.
    
    sudo cp -r ./piwik/* ./
    sudo rm -r piwik
    sudo rm latest.tar.gz "How to install Piwik.html"
  
Let's create the MySQL Piwik database and user.

    mysql -u root -p
    
Enter the MySQL root user password.

Create the Piwik database.

    CREATE DATABASE [piwik];
    
Create the Piwik database user.

    CREATE USER [piwik]@localhost;

Set the password for the Piwik database user.

    SET PASSWORD FOR [piwik]@localhost = PASSWORD("[password]");
    
Grant Piwik user full access on Piwik database.

    GRANT ALL PRIVILEGES ON [piwik].* TO [piwik]@localhost IDENTIFIED BY '[password]';
    
Refresh MySQL and exit.

    FLUSH PRIVILEGES;
    exit
    
Add the Nginx configuration to an existing website.
```
server{
    
    ...
    
    location /piwik{
        root /var/www;
    }
    
    ...
    
    location ~ .php$ {
        
        ...
        
        if ($request_uri ~* /piwik) {
            set $php_root /var/www;
        }
        
        ...
    }
}
```
Provide access to the piwik folder.

    sudo chown -R www-data:www-data /var/www/piwik

Finally let's add the archive cron job which will highly improve the processing time for your piwik reports.

Add a new cron job.

    sudo vi /etc/cron.d/piwik-archive

Add this content to the cron file.

    MAILTO="[mail@example.com]"
    5 * * * * www-data /usr/bin/php5 /var/www/[piwik]/console core:archive --url=http://[host]/piwik/ > /var/log/piwik/archive.log

Then create the log folder and grant access for the user.

    sudo mkdir /var/log/piwik
    sudo chown www-data:www-data piwik

Test config and reload Nginx service.

    sudo nginx -t && sudo service nginx reload
    
Open your browser on `//[host]/piwik` and install the Piwik website.

# Source

[How to Install Piwik on Ubuntu by AdminEmpire](http://www.adminempire.com/how-to-install-piwik-on-ubuntu/)  