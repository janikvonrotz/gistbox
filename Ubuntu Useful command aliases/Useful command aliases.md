# Introduction

This is a list of useful commandline aliases for your Ubuntu installation.

# Requirements

* Ubuntu server
* Supported installations (see below)

# Instructions

The structure of the command aliases is a mix of the first 3 letters of the programm you're running and the parameters you're adding.
To set this aliases permanently add them to bash profile scirpt.

    vi ~/.bashrc
    
## duplicity-backup

List current files from your latest backup.

    alias duplcf="sudo /usr/local/src/duplicity-backup/duplicity-backup.sh -c /etc/duplicity-backup/duplicity-backup.conf --list-current-files"

Run a backup.

    alias dupbak="sudo /usr/local/src/duplicity-backup/duplicity-backup.sh -c /etc/duplicity-backup/duplicity-backup.conf -b"

Get the status of the latest backup.

    alias dupsta="sudo /usr/local/src/duplicity-backup/duplicity-backup.sh -c /etc/duplicity-backup/duplicity-backup.conf -s"