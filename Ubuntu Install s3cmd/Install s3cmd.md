# Introduction

S3cmd is a command line tool for uploading, retrieving and managing data in Amazon S3 and other Cloud Storage Service Providers that use the S3 protocol

# Requirements

* Ubuntu server
* GnuPG
* [Amazon AWS account](http://aws.amazon.com/)
* [Amazon IAM service user](https://console.aws.amazon.com/iam)
* [Amazon S3 bucket](https://console.aws.amazon.com/s3)

# Installation

Install the package with aptitude.

    sudo apt-get install s3cmd

Configure s3cmd.

    s3cmd --configure

Enter your Amazon AWS credentials.

    Access Key: [your access key]
    Secret Key: [your secret key]

Enter an encryption passwort for secure transmissions.

    Encryption password: [secure password]

Answert the next prompts as showed below.

    Path To GPG programm: [enter]
    Use HTTPS protocol [No]: [enter]
    HTTP Proxy server name: [depends on your network environment]
    Test access with supplied credentials: Y
    
If you'll get the following message.

    Error: Test failed: 4103 (AccessDenied): Access Denied
    
Try my policy.

```
{
  "Statement": [
    {
      "Action": [
        "s3:ListAllMyBuckets"
      ],
      "Effect": "Allow",
      "Resource": "arn:aws:s3:::*"
    },
    {
      "Action": [ 
          "s3:ListBucket", 
          "s3:PutObject",
          "s3:GetObject"
      ],
      "Effect": "Allow",
      "Resource": [
          "arn:aws:s3:::[bucket name]", 
          "arn:aws:s3:::[bucket name]/*"
      ]
    }
  ]
}
```
    
# Source

[s3cmd website](http://s3tools.org/s3cmd)