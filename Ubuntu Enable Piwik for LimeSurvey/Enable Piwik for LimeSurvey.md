# Introduction

Piwik is an Open Source webanalytics software. In this tutorial you'll learn how to integrate the Piwiks plugin for LimeSurvey.
<!--more-->
# Requirements

* [Ubuntu server](https://janikvonrotz.ch/2014/03/13/deploy-ubuntu-server/)
* [Nginx](https://janikvonrotz.ch/2014/03/31/install-nginx/)
* [Nginx minimal website](https://janikvonrotz.ch/2014/04/01/nginx-minimal-website/)
* [php5-fpm](https://janikvonrotz.ch/2014/03/20/install-php5-fpm/)
* [php5-mysql](https://janikvonrotz.ch/2014/03/25/install-php5-modules/)
* [Nginx php5-fpm website](https://janikvonrotz.ch/2014/04/11/install-nginx-php5-fpm-website/)
* [MySQL](https://janikvonrotz.ch/2014/04/07/install-mysql/)
* [Increased Max Upload for php5-fpm website](https://janikvonrotz.ch/2014/04/11/increase-max-upload-for-php5-fpm-website/)
* [LimeSurvey webapp](https://janikvonrotz.ch/2015/04/08/install-limesurvey-webapp/)

# Installation

Navigate to the LimeSurvey plugin directory.

    cd /var/www/<limesurvey>/plugin

Clone the Piwik LimeSurvey plugin.

    sudo git clone https://github.com/SteveCohen/Piwik-for-Limesurvey.git PiwikPlugin

Copy the scripts from the sub folder in to the main plugin folder.

    cd PiwikPlugin/
    sudo mv ./PiwikPlugin/* ./
    sudo rm -R PiwikPlugin

Add access rights for the webserver user.

    sudo chown www-data:www-data -R ./*

Open your Piwik website `//<piwik host>/index.php?module=SitesManager` and optionally add a new site.

Copy the ID of the site where you want to store your LimeSurvey tracking data.

Open the LimeSurvey plugin manager `//<limesurvey host>/index.php?r=plugins` and click the settings icon of the *Piwik for Limesurvey* plugin.

Update the `URL to Piwik's directory` field with the url of your piwik installation `//<piwik host>`.

Add the ID of the Piwik site to the `Piwik SiteId` field.

Save the settings and enable the plugin.

Whenever a user access one of your suveys their actions are tracked with Piwik. 