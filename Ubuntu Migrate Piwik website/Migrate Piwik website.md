# Introduction

This article assumes you're going to move an exisiting piwik website from one server to another.

# Requirements

* Ubuntu server
* Nginx
* Nginx minimal website
* MySQL
* php5-fpm
* php5-mysql, php5-mcrypt
* Nginx php5-fpm website
* Increased Max Upload for php5-fpm website
* phpMyAdmin
* Piwik website


# Instructions

Export the existing SQL Piwik database with phpMyAdmin.

Import the database export into the new Piwik database with phpMyAdmin.

Update the tracking codes or update Piwik urls on the Piwik tracked websites if the hosting has changed.
