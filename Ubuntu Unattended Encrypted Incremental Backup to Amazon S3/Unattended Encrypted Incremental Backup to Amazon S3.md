# Introduction

For this task we are going to configure a duplicity script wrapper.
Unregarded of the installation instructions it's expected that you have already signed up for an Amazon account and know how to use their services.

# Requirements

* Ubuntu server
* duplicity, Git, GnuPG
* MySQL
* automysqlbackup
* GPG Keys
* s3cmd
* [Amazon AWS account](http://aws.amazon.com/)
* [Amazon IAM service user](https://console.aws.amazon.com/iam)
* [Amazon S3 bucket](https://console.aws.amazon.com/s3)

# Installation

Clone the GitHub project.

    cd /usr/local/src
    sudo git clone https://github.com/zertrin/duplicity-backup.git

Copy the configuration file.

    cd /usr/local/src/duplicity-backup
    sudo mkdir /etc/duplicity-backup
    sudo cp duplicity-backup.conf.example /etc/duplicity-backup/duplicity-backup.conf

Edit the configuration file.

    sudo vi /etc/duplicity-backup/duplicity-backup.conf
    
Update the AWS credentials.

    AWS_ACCESS_KEY_ID="[aws key id]"
    AWS_SECRET_ACCESS_KEY="[aws access key]"
    
Update the gpg encryption settings.

    PASSPHRASE="[gpg passphrase]"
    GPG_ENC_KEY="[gpg key id]"
    GPG_SIGN_KEY="[gpg key id]"

In case you can't remember the `gpg key id` use the GnuPG tool.

    gpg -k
    
Where the `gpg key id` is displayed in the line `pub   2048R/>>C58886FB<< 2014-03-14`

Set the backup start directory.

    ROOT="/var"
    
Set the S3 destination bucket.

    DEST="s3+http://[bucket name]/[backup-folder]/"

Define which folder should be included in the backup.
```
INCLIST=(  "/var/backups/mysql/latest" \
           "/var/www/<wordpress>/wp-content" \
        )
```
Define which folders inside the include folders should be ignored.

    EXCLIST=(  "/var/www/[wordpress]/wp-content/backupwordpress*" )

Update the logging settings.
```
LOGDIR="/var/log/duplicity-backup/"
LOG_FILE="duplicity-`date +%Y-%m-%d_%H-%M`.txt"
LOG_FILE_OWNER="[group]:[user]"
```
Don't forget to create the log folder.

    sudo mkdir /var/log/duplicity-backup

Run the script to check wether it works or not.

    sudo /usr/local/src/duplicity-backup/duplicity-backup.sh -c /etc/duplicity-backup/duplicity-backup.conf -b

To debug errors you can add the parameter `-d`, adjust the verbosity level with `-v[1-9]` and check the duplicity log.

In case you'll get the error `Import of duplicity.backends.giobackend Failed: No module named gio` or `BackendException: Could not initialize backend: No module named paramiko` you have to install some additional pyhton packages.

    sudo apt-get install python-paramiko python-gobject-2
    
In addition if you want to use gdocs as a destination you have to install the according python libarary.

    sudo apt-get install pyhton-gdata

You can list the current backup with the parameter `--list-current-files`.

    sudo /usr/local/src/duplicity-backup/duplicity-backup.sh -c /etc/duplicity-backup/duplicity-backup.conf --list-current-files
    
Get further help for the backup script by running the script without parameters.

     sudo /usr/local/src/duplicity-backup/duplicity-backup.sh

scheduling the job is easily done by adding a new line to the cron configuration file.

    sudo vi /etc/crontab
    
Add the backup schedule command. The following example is executed daily a 7 o'clock.

    00 7    * * *   [user]   sudo /usr/local/src/duplicity-backup/duplicity-backup.sh -c /etc/duplicity-backup/duplicity-backup.conf -b

Watch out for the schedule time of the automysqlbackup, you should schedule the duplicity backup job after the automysqlbackup job is done.

Finally backup your configurations.

    cd ~
    sudo /usr/local/src/duplicity-backup/duplicity-backup.sh -c /etc/duplicity-backup/duplicity-backup.conf --backup-script
    
Answert the prompt as showed bleow.

    >> Are you sure you want to do that ('yes' to continue)?
    yes
    
    Enter passphrase: [gpg passphrase]


# Source

[Automatic Amazon s3 Backups on Ubuntu / Debian](http://www.problogdesign.com/how-to/automatic-amazon-s3-backups-on-ubuntu-debian/)  
[GitHub duplicity-backup by zertrin](https://github.com/zertrin/duplicity-backup)  
[GitHub issue: No module named gio](https://github.com/zertrin/duplicity-backup/issues/63)  
[Missing modules for paramiko and gio in duplicity foo](http://www.rfc3092.net/2013/09/missing-modules-for-paramiko-and-gio-in-duplicity-foo/)  