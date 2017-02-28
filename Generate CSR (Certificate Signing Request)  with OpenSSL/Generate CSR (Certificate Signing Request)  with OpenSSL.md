Define the following attributes, you have to set them in the wizard when generating the CSR.

* Common Name (the domain name certificate should be issued for)
* Country
* State (or province)
* Locality (or city)
* Organization
* Organizational Unit (Department)
* E-mail address

To generate a CSR run the command below in terminal:

    openssl req -new -newkey rsa:2048 -nodes -keyout <domain>.key -out <domain>.csr
    
The command starts the process of CSR and Private Key generation. The Private Key will be required for certificate installation.

Make sure the store the challenge password and set the commom name according your domain name.

Finally send the `<domain>.csr` to your hosting provider. They will respond with your new ssl certificate.