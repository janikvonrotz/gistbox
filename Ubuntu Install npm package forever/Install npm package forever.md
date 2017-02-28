# Introduction

A simple CLI tool for ensuring that a given script runs continuously (i.e. forever).

# Requirements

* Ubuntu server
* Node.js

# Installation

Install forever

    sudo npm install forever -g
	
Start Node.js application with forever

	sudo NODE_ENV=production forever start index.js
    
Start Node.js application without forever

	sudo npm start --production
	
List Node.js applications executed by forever

	forever list
	
Stop forever applications

	forever stop index.js