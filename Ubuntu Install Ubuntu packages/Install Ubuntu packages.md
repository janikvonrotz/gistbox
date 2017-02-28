*This post of is part of my [Your own Virtual Private Server hosting solution](http://janikvonrotz.ch/your-own-virtual-private-server-hosting-solution/) project.*  
*Get the latest version of this article here: [https://gist.github.com/9758741](https://gist.github.com/9758741).*  

# Introduction

This is a list of essential programs to run an Ubuntu server.
<!--more-->
# Requirements

* [Ubuntu server](http://janikvonrotz.ch/2014/03/13/deploy-ubuntu-server/)

## bind9

BIND, or named, is the most widely used Domain Name System software on the Internet.

    sudo apt-get install bind8

## cURL

Curl is a command line tool for transferring data with URL syntax, supporting various protocols such as ftp, http or smtp.

    sudo apt-get install curl

## dnsmasq

Dnsmasq provides network infrastructure for small networks: DNS, DHCP, router advertisement and network boot. It is designed to be lightweight and have a small footprint, suitable for resource constrained routers and firewalls. 

    sudo apt-get install dnsmasq

## duplicity

The duplicity program allows you to backup directories and upload them to a remote server.

    sudo apt-get install duplicity

## Git

Git is a free and open source distributed version control system designed to handle everything from small to very large projects with speed and efficiency.

    sudo apt-get install git

## GnuPG

GnuPG allows to encrypt and sign your data and communication, features a versatile key management system as well as access modules for all kinds of public key directories. GnuPG, also known as GPG, is a command line tool with features for easy integration with other applications.

    sudo apt-get install gnupg
    
## NcFTP    
    
This program allows a user to transfer files to and from a remote network site, and offers additional features that are not found in the standard interface, ftp.

Search for the package definitons in order to update the package defintions.

    aptitude search ncftp

Install the NcFTP package.

    sudo apt-get install ncftp
    
## rng-tools
    
The rngd daemon acts as a bridge between a Hardware TRNG (true random number generator) such as the ones in some Intel/AMD/VIA chipsets, and the kernel's PRNG (pseudo-random number generator).
It tests the data received from the TRNG using the FIPS 140-2 (2002-10-10) tests to verify that it is indeed random, and feeds the random data to the kernel entropy pool.

    sudo apt-get install rng-tools
    
## unzip

InfoZIP's unzip program. With the exception of multi-volume archives (ie, .ZIP files that are split across several disks using PKZIP's /& option), this can handle any file produced either by PKZIP, or the corresponding InfoZIP zip program.

    sudo apt-get install unzip