# Introduction

Ghost is a free, open, simple blogging platform that's available to anyone who wants to use it.

# Requirements

* Ubuntu server
* Nginx
* Node.js
* Node.js Nginx proxy website

# Installation

Download the Ghost project from the official site and install it with npm.

    sudo mkdir /var/www/<ghost>
    cd /var/www/<ghost>
    sudo wget https://ghost.org/zip/ghost-<version>.zip
    sudo unzip ghost-<version>.zip
    sudo rm ghost-<version>.zip
    npm install --production

Let's create the Ghost configuration file.

    sudo cp config.example.js config.js
    sudo vi config.js

Please remember the port number for your production environment.



Create a new service config file.

    sudo vi /etc/init/ghost.conf
    
Then in this file put.

```
#/etc/init/ghost.conf

# start the service after everything loaded
start on (local-filesystems and net-device-up IFACE=eth0)
stop on shutdown

# automatically restart service
respawn
respawn limit 99 5

script

    # navigate to your app directory
    cd /var/www/<ghost>

    # run the script with Node.js and output to a log
    export NODE_ENV=production
    exec /usr/local/bin/npm start /var/www/<ghost> 2>&1 >> /var/log/<ghost>.log
    
end script
```

Then you can control the service as follows.

    sudo service ghost start
    sudo service ghost stop
    sudo service ghost restart
    sudo service ghost status

Note: Now if you restart your server or Ghost crashes, init will spin up another instance of Ghost for you automatically.

Start Ghost by running.

    sudo service ghost start

# Source

[How to Install the Ghost Blogging Platform on a DigitalOcean Droplet in 10 Steps by Corbett Barr](http://ghosted.co/install-ghost-digitalocean/)  
[Installing Ghost on Ubuntu by Gilbert Pellegrom](http://ghost.pellegrom.me/installing-ghost-on-ubuntu/)  
[Official Ghost GitHub repository](https://github.com/TryGhost/Ghost)