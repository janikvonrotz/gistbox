# Introduction

HHVM is an open-source virtual machine designed for executing programs written in Hack and PHP. HHVM uses a just-in-time (JIT) compilation approach to achieve superior performance while maintaining the development flexibility that PHP provides.

# Requirements

* Ubuntu server

# Installation

Get the release codename of your Ubuntu installation.

	cat /etc/lsb-release
		
Where `DISTRIB_CODENAME` is the release codename.

Add the installation repository for HHVM.

    wget -O - http://dl.hhvm.com/conf/hhvm.gpg.key | sudo apt-key add -
    echo deb http://dl.hhvm.com/ubuntu <release codename> main | sudo tee /etc/apt/sources.list.d/hhvm.list
    
Install HHVM.
    
    sudo apt-get update
    sudo apt-get install hhvm
    
To run HHVM at boot.

     sudo update-rc.d hhvm defaults
    
Check the HHVM version.
    
    hhvm --version
    
Finally let's change the listener for HHVM.

    sudo hhvm --mode server -vServer.Type=fastcgi -vServer.FileSocket=/var/run/hhvm.sock
    
# Source

[HHVM Prebuilt Packages on Ubuntu 12.04](https://github.com/facebook/hhvm/wiki/Prebuilt-Packages-on-Ubuntu-12.04)  
[FasterCgi with hhvm](http://hhvm.com/blog/1817/fastercgi-with-hhvm])  
[FastCGI configuration on the HHVM GitHub Wiki](https://github.com/facebook/hhvm/wiki/FastCGI)