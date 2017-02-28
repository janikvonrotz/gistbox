# Introduction

Let’s Encrypt is a free, automated, and open certificate authority (CA), run for the public’s benefit. Let’s Encrypt is a service provided by the Internet Security Research Group (ISRG). This guide shows you how you can obtain a free SSL certificate.
<!--more-->
# Requirements

* [Ubuntu server](https://janikvonrotz.ch/2014/03/13/deploy-ubuntu-server/)
* [Python](https://janikvonrotz.ch/2015/10/22/install-python/)
* [Nginx](https://janikvonrotz.ch/2014/03/31/install-nginx/)
* [Nginx minimal website](https://janikvonrotz.ch/2014/04/01/nginx-minimal-website/)
* [Nginx SSL website](https://janikvonrotz.ch/2014/04/03/nginx-ssl-website/)

# Installation

Download the client code from the Github repository.

    cd /usr/local/src/
    sudo git clone https://github.com/letsencrypt/letsencrypt
    cd letsencrypt

Run the letsencrypt wrapper script.

    sudo -h ./letsencrypt-auto

If you experience an error like this:
```
/usr/local/lib/python2.7/dist-packages/requests/packages/urllib3/util/ssl_.py:79: 
          InsecurePlatformWarning: A true SSLContext object is not available. 
          This prevents urllib3 from configuring SSL appropriately and may cause certain SSL connections to fail. 
          For more information, see https://urllib3.readthedocs.org/en/latest/security.html#insecureplatformwarning.
  InsecurePlatformWarning
```

You have to update some pyhton libraries by running this command.

    pip install pyopenssl ndg-httpsclient pyasn1

Now you can request a new ssl certificate. I assume you're running Nignx as your web server. To request a certificate we have to stop the web service temporarily.

    sudo service nginx stop
    sudo -H ./letsencrypt-auto certonly --email hostmaster@domain.com -d domain.com
    sudo service nginx start

The new certificates are stored here: `/etc/letsencrypt/live/domain.com`

Update the Nginx configuration file for your domain.

    sudo vi /etc/nginx/conf.d/domain.com.conf

Add the new certificates:

    ssl_certificate /etc/letsencrypt/live/domain.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/domain.com/privkey.pem;

Test your Nginx configuration file.

    sudo nginx -t

And restart the service

    sudo service nginx reload

Finally check your Nginx SSL configuration here: [https://globalsign.ssllabs.com/](https://globalsign.ssllabs.com/)

# Source

[Official Let's Encrypt client documentation](https://letsencrypt.readthedocs.org/en/latest/)