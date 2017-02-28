# Introduction

MySQL is the world's most popular open source database system.

# Requirements

* Ubuntu server

# Installation

Install MySQL server

    sudo apt-get install mysql-server
    
Set the mysql root user password during the installation

Install the default MySQL databases

    sudo mysql_install_db
    
Run the finisher script and respond except for the first prompt with yes in order to get a secure MySQL installation

    sudo /usr/bin/mysql_secure_installation
        
Connect to your new MySQL server

    mysql -uroot -p
    
Enter the root password

And run this command to get the MySQL version

    SHOW variables LIKE "%version%";
	
# Source

[Ubuntu MySQL server guide](https://help.ubuntu.com/12.04/serverguide/mysql.html)