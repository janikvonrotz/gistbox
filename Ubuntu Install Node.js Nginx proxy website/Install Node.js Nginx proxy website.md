# Introduction

It's recommanded to publish a Node.js application with a Nginx proxy website.

# Requirements

* Ubuntu server
* Node.js
* Nginx
* Nginx minimal website

# Installation

Add this Nginx config to one of your website.
```
server {

    location / {
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header Host $http_host;
        proxy_pass http://127.0.0.1:[port];
    }
}
```
Where `proxy_pass` port is the must be equal with the port of the Node.js application.

Restart the Nginx service.

    sudo service nginx restart
