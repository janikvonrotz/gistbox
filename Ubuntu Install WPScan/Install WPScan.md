# Introduction

WPScan is a black box WordPress vulnerability scanner.

# Requirements

* Ubntu server
* libcurl4-gnutls-dev, libopenssl-ruby, libxml2, libxml2-dev, libxslt1-dev, ruby-dev
* Git
* Ruby and RubyGems with RVM

# Installation

First clone the WPScan repository from GitHub.

    cd /usr/local/src/
    sudo git clone https://github.com/wpscanteam/wpscan.git

Now install the bundler gem.

    sudo chown [current username]:[current username] wpscan/
    cd wpscan/
    gem install bundler
    
Install the WPScan project with user priviliges.
    
    bundle install --without test

Run a scan.

    ruby wpscan.rb --url [url]

# Source

[WPScan Github Repository](https://github.com/wpscanteam/wpscan)