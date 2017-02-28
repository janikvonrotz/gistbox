
    sudo mkdir /var/www/<typo3>
    cd /var/www/<typo3>
    sudo wget http://prdownloads.sourceforge.net/typo3/typo3_src-<version>.tar.gz
    
    sudo tar xzf typo3_src-<version>.tar.gz
    
    sudo ln -s typo3_src-<version> ./typo3_src
    sudo ln -s typo3_src/index.php ./index.php
    sudo ln -s typo3_src/typo3 ./typo3
    
    sudo touch FIRST_INSTALL
    
Let's create the MySQL Typo3 database and user.

    mysql -u root -p
    
Enter the MySQL root user password.

Create the WordPress database.

    CREATE DATABASE <typo3>;
    
Create the WordPress database user.

    CREATE USER <typo3>@localhost;

Set the password for the WordPress database user.

    SET PASSWORD FOR <typo3>@localhost = PASSWORD("<password>");
    
Grant WordPress user full access on WordPress database.

    GRANT ALL PRIVILEGES ON <typo3>.* TO <wordpress>@localhost IDENTIFIED BY '<password>';
    
Refresh MySQL and exit.

    FLUSH PRIVILEGES;
    exit

NGINX config



# Source

[INSTALLING TYPO3](https://github.com/TYPO3/TYPO3.CMS/blob/master/INSTALL.md)