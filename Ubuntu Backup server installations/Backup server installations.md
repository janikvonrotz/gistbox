# Introduction

This article shows a list of the most important files and folders of your VPC installations, you definitely should backup.
It assumes you'll run a daily backup for this ressources.

# Requirements

* [Ubuntu server](https://janikvonrotz.ch/2014/03/13/deploy-ubuntu-server/)
* Supported installations (see below)

# Instructions

As long new versions of your installations are released frequently, it's recommanded to backup data and configuration files only.

## Ubuntu

    -
    
## duplicity-backup

    /etc/duplicity-backup/*

## Koken

    /var/www/<koken>
    
## MySQL

If you have automysqlbackup running.

    /var/backups/mysql/latest/*
    
## Nginx

    /etc/nginx/conf.d/*  

## Postfix

    /etc/postfix/virtual
    /etc/postfix/main.cf

## Piwik

    /var/www/<piwik>/config/*
    
## WordPress

    /var/www/<wordpress>/wp-config.php
    /var/www/<wordpress>/wp-content/*