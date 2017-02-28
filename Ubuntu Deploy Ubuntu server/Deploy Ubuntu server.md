# Introduction

Why Ubuntu?

Because:

* Ubuntu is the leading and most popular Linux distro. 
* It's easy to install, deploy and manage.
* Ubuntu remains the most popular operating system for OpenStack deployments.
* It's available for multiple devices.
* Ubuntu benefits from a huge community support since ever.

# Installation

I don't want to show you how to install an Ubuntu server, that's way to easy and this shouldn't really bother you.

The only decisions you have to make is wether to install it on your own or deploy it as an VPS (Virtual Private Server).

You can host an online VPS installation by several providers.

* [Amazon AWS EC2](https://aws.amazon.com/de/ec2/)
* [Rackspace Cloud Servers](http://www.rackspace.com/cloud/servers/)
* [Windows Azure](http://www.windowsazure.com/de-de/)

If you want to install it on your own on hardware or virtual machine, you can download it from the [offical Ubuntu website](http://www.ubuntu.com/download/server).

Unregarded of the installation and deployment strategy your server must... 

* ...be secured with a dedicated firewall, that only allows http, https and ssh.
* ...being accessed with [ssh keys](https://help.ubuntu.com/community/SSH/OpenSSH/Keys).
* ...being accessed with an user without root privileges (only root substitution should be possible).
 
Personally I recommand to use the LTS (Long Term Support) version, compared to the latest releases they're more stable and secure.

# Source

[Ubuntu server offical Website](http://www.ubuntu.com/server)