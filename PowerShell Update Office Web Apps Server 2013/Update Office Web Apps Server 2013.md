In order to update a Office Web Apps Server installation you have to remove the existing Office Web Apps Farm.

    Remove-OfficeWebAppsMachine

Now you can install the required updates.

If the installation has been finished create the Office Web Apps Farm again according to your settings.

    New-OfficeWebAppsFarm -InternalUrl "http://example.org" -ExternalUrl "http://example.org" -EditingEnabled -AllowHttp:$true
    
The check wether Office Web Apps are running open your browser on:

    http://example.org/hosting/discovery