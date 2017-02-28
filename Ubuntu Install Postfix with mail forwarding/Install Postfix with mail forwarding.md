# Introduction

Postfix is a commonly used MTA (Mail Transfer Agent) program that can receive, deliver or route emails. In this guide you'll learn how to forward mails from a certain domain to another e-mail address. It's a recommanded approach if you want to publish a mail contact based on your domain and redirect the received mails to another provider, such as Outlook or Gmail.

# Requirements

* [Ubuntu server](https://janikvonrotz.ch/2014/03/13/deploy-ubuntu-server/)

# Installation

Install Postfix with aptitude.

    sudo apt-get install postfix

In the wizard chose as showed below.

    Setup type: Internet Site
    System mail name: <domain>

After the installation check, wether the Postfix agent is running or not.

    sudo service postfix status

Verfify your mail DNS records. Here's an example.

    example.org.  85100  IN  MX  10 mail.example.org
    mail.example.org.  85045  IN  CNAME  example.org

Also Verifiy open Ports, postfix is accessable via these ports.

    smtp port 25

We assume the mail server runs on the web server.

Let's configure the postfix server.

    sudo vi /etc/postfix/main.cf

Add at these line at the end of the file.

    # acceptable mail domains for postifx
    virtual_alias_domains = example.org example.com
    virtual_alias_maps = hash:/etc/postfix/virtual

Lets add some mail forwarding rules

    sudo vi /etc/postfix/virtual

Now you can add your mail adresses, here's an exmaple with gmail.

    contact@example.org name@gmail.com
    sales@example.com name@gmail.com sombodyelse@gmail.com

Update the postfix lookup table

    sudo postmap /etc/postfix/virtual

Restart the postix service

    sudo service postfix reload

And last check wether the config has been load propberly

    postconf -n | grep virtual

You should see the virtual config instructions

# Source 

[Setup mail forwarding in postfix on Ubuntu or Debian](http://www.binarytides.com/postfix-mail-forwarding-debian/)
