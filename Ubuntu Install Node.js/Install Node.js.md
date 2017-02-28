# Introduction

Node.js is a cross-platform runtime environment for server-side and networking applications.

# Requirements

* Ubuntu server
* Git (optional)
* build-essential

# Installation

You can install Node.js either from website or the from the git repo.

## Install from source
	
Download Node.js with wget.

    cd /usr/local/src
    sudo wget http://nodejs.org/dist/node-latest.tar.gz

Unpack Node.js.

    sudo tar -xzf node-latest.tar.gz
    cd node-<version>
	
Install Node.js.

    sudo ./configure
    sudo make
    sudo make install
	
Check version of Node.js and npm.
	
    node -v
    npm -v

## Install with Git

Clone the Node.js repo.

	cd /usr/local/src
	sudo git clone git://github.com/joyent/node.git
	
Or use the https url if ssh is not possible.

  sudo git https://github.com/joyent/node.git

Check git tags to find the latest version.

	cd node
	git tag
	
See the latest stable version on [http://nodejs.org/](http://nodejs.org/).

Checkout the latest version.

	sudo git checkout vX.X.X
	
Install Node.js.

	sudo ./configure
	sudo make
	sudo make install

Check version of Node.js and npm.
	
	node -v
	npm -v

# Update

Depending on how you've installed Node.js theres an update strategy.

## from source

Repeat the installation process above.

## with Git

Pull down the latest source code.

	cd /usr/local/src/node
	sudo git checkout master
	sudo git pull origin master
	
Check git tags to find the latest version.

	git tag
	
See the latest stable version on [http://nodejs.org/](http://nodejs.org/).
	
Compile the latest version.

	sudo git checkout vx.x.x
	sudo ./configure
	sudo make
	sudo make install
