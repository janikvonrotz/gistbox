*This post is part of my [Your own Virtual Private Server hosting solution](http://janikvonrotz.ch/your-own-virtual-private-server-hosting-solution/) project.*  
*Get the latest version of this article here: [https://gist.github.com/ddce334cd8ab21a40941](https://gist.github.com/ddce334cd8ab21a40941).*  

# Introduction

Let’s Encrypt is a free, automated, and open certificate authority (CA), run for the public’s benefit. So far it works well and makes it easy to obtain a free certificate. Now the created certificates will expire withing 90 days. This post will show you how you can auto renew these certificates before they expire.
<!--more-->
# Requirements

* [Ubuntu server](https://janikvonrotz.ch/2014/03/13/deploy-ubuntu-server/)
* [Python](https://janikvonrotz.ch/2015/10/22/install-python/)
* [Nginx](https://janikvonrotz.ch/2014/03/31/install-nginx/)
* [Nginx minimal website](https://janikvonrotz.ch/2014/04/01/nginx-minimal-website/)
* [Nginx SSL website](https://janikvonrotz.ch/2014/04/03/nginx-ssl-website/)
* [Install Let’s Encrypt and create a free SSL certificate](https://janikvonrotz.ch/2015/12/04/install-lets-encrypt-and-create-a-free-ssl-certificate/)

# Installation

Create a new bash script and it to the monthly cron folder for sheduling.

    cd /etc/cron.monthly/
    sudo vi letsencrypt-renew
    sudo chmod +x letsencrypt-renew

Add the following code to the `letsencrypt-renew`script.

    cd /usr/local/src/letsencrypt
    sudo service nginx stop
    sudo -H ./letsencrypt-auto renew
    sudo service nginx start

Now run the script and check if it succeeds.

    sudo ./letsencrypt-renew

# Source

[Official Let's Encrypt client documentation - Renewal](http://letsencrypt.readthedocs.org/en/latest/using.html#renewal)