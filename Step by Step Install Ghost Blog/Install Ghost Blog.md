Finishing this guide you'll get:

* A running Ghost installation
* Amazon SES mail configuration
* Simple ssh hardenings
* Nginx proxy
* Node.js configured with forever

Specification of latest running installation:

* Date: 21.01.2014  
* OS: Ubuntu 64 bit - 12.04.4 LTS 
* Provider: Amazon EC2
* Mail service: Amazon SES
* Browser: Google Chrome - 31.0.1650.63  
* Ghost: 0.4  
* Node: 0.10.24  
* npm: 1.3.21  

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
    
## SSH

Change the default ssh port and disable root login

	sudo vi /etc/ssh/sshd_config
    Set Port [custom ssh port number]
	Set PermitRootLogin no
    
Restart the ssh service

	sudo /etc/init.d/ssh restart
    
Update firewall rules now to enable ssh connection with your custom port

Reconnect your ssh host with the new port number
    
    ssh -p [custom ssh port number] user@host
    
## Fail2Ban

Install Fail2Ban

	sudo apt-get install fail2ban
    
Copy the configuration file

	sudo cp /etc/fail2ban/jail.conf /etc/fail2ban/jail.local
    
Edit the config file

	sudo vi /etc/fail2ban/jail.local
    
Make the following changes:

	[ssh]
	port     = [custom ssh port number]

And

	[ssh-ddos]
    enabled  = true
    port     = [custom ssh port number]

Finish editing and restart fail2ban service

	sudo service fail2ban restart

## Network

Edit the network configuration file

	sudo vi /etc/sysctl.conf

Paste the this configuration file to improve network security

```
#
# /etc/sysctl.conf - Configuration file for setting system variables
# See /etc/sysctl.d/ for additional system variables
# See sysctl.conf (5) for information.
#

# Uncomment the next two lines to enable Spoof protection (reverse-path filter)
# Turn on Source Address Verification in all interfaces to
# prevent some spoofing attacks
net.ipv4.conf.default.rp_filter=1
net.ipv4.conf.all.rp_filter=1

# Uncomment the next line to enable TCP/IP SYN cookies
net.ipv4.tcp_syncookies=1
net.ipv4.tcp_max_syn_backlog = 2048
net.ipv4.tcp_synack_retries = 2
net.ipv4.tcp_syn_retries = 5

# Do not accept ICMP redirects (prevent MITM attacks)
net.ipv4.conf.all.accept_redirects = 0
net.ipv6.conf.all.accept_redirects = 0
net.ipv4.conf.default.accept_redirects = 0 
net.ipv6.conf.default.accept_redirects = 0

# Do not send ICMP redirects (we are not a router)
net.ipv4.conf.all.send_redirects = 0
net.ipv4.conf.default.send_redirects = 0

# Do not accept IP source route packets (we are not a router)
net.ipv4.conf.all.accept_source_route = 0
net.ipv6.conf.all.accept_source_route = 0
net.ipv4.conf.default.accept_source_route = 0
net.ipv6.conf.default.accept_source_route = 0

# Log Martian Packets
net.ipv4.conf.all.log_martians = 1
net.ipv4.icmp_ignore_bogus_error_responses = 1

# Ignore ICMP broadcast requests
net.ipv4.icmp_echo_ignore_broadcasts = 1

# Ignore Directed pings
net.ipv4.icmp_echo_ignore_all = 1
```
	
## Node.js 

You can install node either from website or the from the git repo.

### Install from source
	
Download Node.js with wget

	wget http://nodejs.org/dist/node-latest.tar.gz

Unpack Node.js

	tar -xzf node-latest.tar.gz
	cd [node folder]
	
Install Node.js

	sudo ./configure
	sudo make
	sudo make install
	
Check version of Node.js and npm
	
	node -v
	npm -v

### Install with Git

Clone the Node.js repo

	cd /usr/local/src
    sudo git clone git://github.com/joyent/node.git

Check git tags to find the latest version

	cd node
	git tag
    
See the latest stable version on http://nodejs.org/

Checkout the latest version

	sudo git checkout vX.X.X
    
Install Node.js

	sudo ./configure
    sudo make
	sudo make install

Check version of Node.js and npm
	
	node -v
	npm -v

## Update Node.js

Depending on how you've installed Node.js theres an update strategy

### from source

Repeat the installation process above

### with Git

Pull down the latest source code

    cd /usr/local/src/node
    sudo git checkout master
    sudo git pull origin master
    
Check git tags to find the latest version

	git tag
    
See the latest stable version on http://nodejs.org/
    
Compile the latest version

    sudo git checkout vx.x.x
    sudo ./configure
    sudo make
    sudo make install

## Nginx

Install Nginx

	sudo apt-get install nginx
	
Create a Nginx site configuration file

	sudo touch /etc/nginx/sites-available/ghost.conf
	sudo vi /etc/nginx/sites-available/ghost.conf

Paste this config

	server {
		listen 80;
		server_name [example.com];

		location / {
			proxy_set_header   X-Real-IP $remote_addr;
			proxy_set_header   Host      $http_host;
			proxy_pass         http://127.0.0.1:2368;
		}
	}
	
Create a symlink to your config file

	sudo ln -s /etc/nginx/sites-available/ghost.conf /etc/nginx/sites-enabled/ghost.conf
	
Restart Ngnix

	sudo service nginx restart
    
In case you'll get this error

	Restarting nginx: nginx: [emerg] could not build the server_names_hash, you should increase server_names_hash_bucket_size: 64
    
Do

	sudo vi /etc/nginx/nginx.conf
    Set server_names_hash_bucket_size 128;
    sudo service nginx restart

## Ghost
	
Create the website folder

	sudo mkdir -p /var/www/
	cd /var/www/
	
Download Ghost with wget
	
	sudo wget https://ghost.org/zip/ghost-latest.zip
	
Unpack Ghost

	sudo unzip -d ghost ghost-latest.zip
	cd ghost/
	
Install Ghost

	sudo npm install --production
        
In case of errors for sqlite3 installation

	npm install sqlite3 --build-from-source
	
Install forever

	sudo npm install forever -g
	
Configure Ghost (productive environment only)

    sudo cp config.example.js config.js
	sudo vi config.js
    Set url: 'http://[example.com]',
    
Start Ghost

	sudo NODE_ENV=production forever start index.js
    
Start Ghost without forever

	sudo npm start --production
	
Check if Ghost is running

	forever list
	
Stop Ghost

	forever stop index.js
	
Register your Ghost Account

	Open your browser on http://[example.com]/ghost
    
## Ghost Mail

Ghost uses [Nodemailer](https://github.com/andris9/Nodemailer) to send e-mails, this modules has to be configured.
Ghost supports various mail providers, you can see all of them in the [Ghost mail documentation](http://docs.ghost.org/mail/)

### SES

Amazon's SES (Simple EMail Service) provides a reliable service to send mails.

Requirements

* Amazon Account
* Verified domain and mail address on SES

Create a new user in the [IAM service console](https://console.aws.amazon.com/iam/#users) and store the access keys in a  secure place.

Allow new user to send mail via SES with this policy configuration

```
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "ses:SendRawEmail",
      "Resource": "*"
    }
  ]
}
```

Edit the Ghost config

	sudo vi config.js
    
Add this mail configuration

```
mail: {
    transport: 'SES',
    options: {
        AWSAccessKeyID: '[acccess key]',
        AWSSecretKey: '[secret key]'
    }
},
```
Update mail settings

	http://[example.com]/ghost/settings/general/
    Set Email Address: [verified SES mail address]
    
Or

	sudo vi config.js
    
And add this mail configuration

	mail: {
    	fromaddress: '[verified SES mail address]',
	}
    
Now you should be able to reset your Ghost password

However at the time of writting this mail configuration doesn't seem to work despite it's an offical Ghost configuration

In case you'll get this error when trying to reset your password

	Email Error: Email failed: 400 Sender MessageRejected Email address is not verified. 5a07d838-8381-11e3-ad96-5f67c4a04b97

Replace the the Ghost mail configuration with
```
mail: {
    transport: 'SMTP',
    fromaddress: '[verified SES mail address]',
    host: 'ssl://[SES smpt server address]',
    options: {
        port: 465,
        service: 'SES',
        auth: {
            user: '[acccess key]',
            pass: '[secret key]'
        }
    }
},
```

You can get your smtp settings [here](https://console.aws.amazon.com/ses/home?#smtp-settings:)

## Source

[Install Node](https://github.com/joyent/node/wiki/Installation)  
[Install Node on Ubuntu](http://davidtsadler.com/archives/2012/05/06/installing-node-js-on-ubuntu/)  
[Install Ghost](http://docs.ghost.org/installation/linux/)  
[Deployment of Ghost](http://docs.ghost.org/installation/deploy/)  
[sqlite3 troubleshooting](http://docs.ghost.org/installation/troubleshooting/)  
[nginx fix hash buck size](http://charles.lescampeurs.org/2008/11/14/fix-nginx-increase-server_names_hash_bucket_size)  
[Install Ghost on Ubuntu, Nginx and MySQL](http://0v.org/installing-ghost-on-ubuntu-nginx-and-mysql/#.Ut5q2RBwZaQ)  
[Fail2Ban SSH Hardening](https://www.digitalocean.com/community/articles/how-to-protect-ssh-with-fail2ban-on-ubuntu-12-04)  
[Amazon EC2 Node Stack](https://github.com/niftylettuce/amazon-ec2-node-stack)  
[SES mail configuration](https://blog.ls20.com/install-ghost-0-3-3-with-nginx-and-modsecurity/#settingupemailonghost)

## Todo

* Add Backup tutorial
* ModSecurity for Nginx
* PageSpeed for Nginx 

## Issues

[SES configuratio doesn't now working, even with a provided fix](https://ghost.org/forum/installation/4885-my-mail-ses-configuration-doesn-t-seem-to-work/)

## Issues solved

[Sign up for a Ghost account might not possible](https://ghost.org/forum/installation/4627-can-t-sign-up-for-an-account-after-installation/)

## Backup (coming soon)
http://manpages.ubuntu.com/manpages/intrepid/man1/s3cmd.1.html  
http://mikerogers.io/2013/08/01/backing-up-site-to-s3-on-ubuntu.html  
http://9ol.es/TheEmperorsNewClothes.html

```
{
  "Backup": {
    "Name": "[FileBackupName]",
    "OutputName": "[FileBackup.Name]#[TimeStamp]",
    "TimeStampFormat": "YYYY-MM-DD",
    "WeekStartsOn": "Monday",
    "Database": {},
    "File": {
      "Path": [
        "/var/www/ghost/",
        "/etc/nginx/sites-available/ghost"
      ]
    },
    "Store": [
      {
        "Name": "Local Backup",
        "Provider": "LocalDisk",
        "Path": "/var/backup/",
        "RetentionTime": "7 Days",
        "BackupType": "Daily",
        "Options": ""
      },
      {
        "Name": "Remote Backup to S3",
        "Provider": "S3",
        "ConfigFile": "/etc/s3cmd/GhostBackup.s3cfg",
        "Url": "http:s3.amazonaws.com/(Bucket Name)/backup/",
        "ID": "",
        "Key": "",
        "RetentionTime": "10 Years",
        "BackupType": [
          "Daily",
          "Weekly",
          "Monthly",
          "Yearly"
        ],
        "Options": [
          "DeleteDailyBackupsAfterOneWeek",
          "DeleteWeeklyBackupsAfterOneMonth",
          "DeleteMonthlyBackupsAfterOneYear",
          "CompressFiles"
        ]
      }
    ]
  }
}
```