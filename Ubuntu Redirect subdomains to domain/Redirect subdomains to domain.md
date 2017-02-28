# Introduction

A website has to be only accessible by one specific host name. Otherwise search engines will index your website two or more times.
A lot of people think that a website should only be published as `www.[host]`.
I think this is wrong, using the `www` section is a old fashioned way of how companies have structured their DNS records.
There are users which still use the `www` before tipping an url and others who don't.
However we will allow both of them to access our website.

# Requirements

* Ubuntu server
* Nginx
* Nginx minimal website

# Installation

Redirecting every possible subdomain f.g. containing www.example.org is easily redirected to a prefrered url by adding the following Nginx configuration to the host config file.

```
server{

    server_name *.[host];
    
    return 301 http://[host]$request_uri;
}
    
```
Test config and reload Nginx service.

    sudo nginx -t && sudo service nginx reload

# Source

[Nginx server names](http://nginx.org/en/docs/http/server_names.html)  
[Nginx converting rewrite rules](http://nginx.org/en/docs/http/converting_rewrite_rules.html)  