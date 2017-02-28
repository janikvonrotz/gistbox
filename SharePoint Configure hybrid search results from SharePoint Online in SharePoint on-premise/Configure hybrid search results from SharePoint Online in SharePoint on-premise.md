# Introduction

In this post I'll show you how to get search results from your SharePoint Online in your SharePoint 2013 on-premise search center.

# Requirements

* User synchronisation ActiveDirectory to Office 365 with DirSync
* DirSync password sync or ADFS SSO
* SharePoint Online
* SharePoint 2013 on-premise
  * Enterprise Search service
  * SharePoint Online Management Shell

# Instructions

All configuration will be done either in the Search Administration of the Central Administration or in the PowerShell console of your on-premise SharePoint 2013 server.

# Set up Sever to Server Trust

Before we start with configuring and installing I highly recommand you to make a backup of your SharePoint databases and severs.

The most risky configuration of this tutorial will be the replacing of the signing certificate of the secure token service.

By running the command `Backup-SPFarm -ShowTree` you'll get an summary of all install services on your SharePoint.

Select the most important services and create a backup with:

```powershell
Backup-SPFarm -Directory <BackupFolder> -BackupMethod {Full | Differential} -Item <ServiceApplicationName> [-Verbose]
```

A restore is simply done by checking the backup history and restore a selected backup.

```powershell
Get-SPBackupHistory -Directory <BackupFolder>
Restore-SPFarm -Directory <BackupFolder> -Item <ServiceApplicationName> -RestoreMethod Overwrite [-BackupId <GUID>] [-Verbose]
```

## Export certificates

To create a server to server trust we need two certificates.

**[certificate name].pfx**: In order to replace the STS certificate, the certificate is needed in Personal Information Exchange (PFX) format including the private key.

**[certificate name].cer**: In order to set up a trust with Office 365 and Windows Azure ACS, the certificate is needed in CER Base64 format.

1. First launch the **Internet Information Services (IIS) Manager**
2. Select your **SharePoint web server** and double-click **Server Certificates**
3. In the **Actions** pane, click **Create Self-Signed Certificate**
4. Enter a name for the certificate and save it with **OK**
5. To export the new certificate in the Pfx format select it and click **Export** in the **Actions** pane
6. Fill the fields and click **OK**
Export to: `C:\[certificate name].pfx`
Password: `[password]`
7. Also we need to export the certificate in the CER Base64 format. For that purpose make a **right-click** on the certificate and click on **View...**
8. Click the **Details** tab and then click **Copy to File**
9. On the Welcome to the Certificate Export Wizard page, click **Next**
10. On the Export Private Key page, click **Next**
11. On the Export File Format page, click **Base-64 encoded X.509** (.CER), and then click **Next**.
12. As file name enter `C:\[certificate name].cer` and then click **Next**
13. Finish the export

## Import the new STS (SharePoint Token Service) certificate

Let's update the certificate on the STS. Configure and run the PowerShell script below on your SharePoint server.

```powershell
if(-not (Get-PSSnapin "Microsoft.SharePoint.PowerShell" -ErrorAction SilentlyContinue)){Add-PSSnapin "Microsoft.SharePoint.PowerShell"}

# set the cerficates paths and password
$PfxCertPath = "c:\[certificate name].pfx"
$PfxCertPassword = "[password]"
$X64CertPath = "c:\[certificate name].cer"

# get the encrypted pfx certificate object
$PfxCert = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2 $PfxCertPath, $PfxCertPassword, 20

# import it
Set-SPSecurityTokenServiceConfig -ImportSigningCertificate $PfxCert
certutil -addstore -enterprise -f -v root $stsCertificate
```

Type **Yes** when prompted with the following message.

> You are about to change the signing certificate for the Security Token Service. Changing the certificate to an invalid, inaccessible or non-existent certificate will cause your SharePoint installation to stop functioning. Refer to the following article for instructions on how to change this certificate: http://go.microsoft.com/fwlink/?LinkID=178475. Are you sure, you want to continue?

Restart IIS so STS picks up the new certificate.

```powershell
& iisreset
& net stop SPTimerV4
& net start SPTimerV4
```

Now validate the certificate replacement by running several PowerShell commands and compare their outputs.

```powershell
# set the cerficates paths and password
$PfxCertPath = "c:\[certificate name].pfx"
$PfxCertPassword = "[password]"

# get the encrypted pfx certificate object
New-Object System.Security.Cryptography.X509Certificates.X509Certificate2 $PfxCertPath, $PfxCertPassword, 20

# compare the output above with this output
(Get-SPSecurityTokenServiceConfig).LocalLoginProvider.SigningCertificate
```

## Establish the server to server trust

```powershell
if(-not (Get-PSSnapin "Microsoft.SharePoint.PowerShell" -ErrorAction SilentlyContinue)){Add-PSSnapin "Microsoft.SharePoint.PowerShell"}
Import-Module MSOnline 
Import-Module MSOnlineExtended

# set the cerficates paths and password
$PfxCertPath = "c:\[certificate name].pfx"
$PfxCertPassword = "[password]"
$X64CertPath = "c:\[certificate name].cer"

# set the onpremise domain that you added to Office 365
$SPCN = "sharepoint.domain.com" 

# your onpremise SharePoint site url
$SPSite="http://sharepoint"

# don't change this value
$SPOAppID="00000003-0000-0ff1-ce00-000000000000"

# get the encrypted pfx certificate object
$PfxCert = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2 $PfxCertPath, $PfxCertPassword, 20

# get the raw data
$PfxCertBin = $PfxCert.GetRawCertData()

# create a new certificate object
$X64Cert = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2

# import the base 64 encoded certificate
$X64Cert.Import($X64CertPath)

# get the raw data
$X64CertBin = $X64Cert.GetRawCertData()

# save base 64 string in variable
$CredValue = [System.Convert]::ToBase64String($X64CertBin)

# connect to office 3656
Connect-MsolService

# register the on-premise STS as service principal in Office 365

# add a new service principal
New-MsolServicePrincipalCredential -AppPrincipalId $SPOAppID -Type asymmetric -Usage Verify -Value $CredValue
$MsolServicePrincipal = Get-MsolServicePrincipal -AppPrincipalId $SPOAppID
$SPServicePrincipalNames = $MsolServicePrincipal.ServicePrincipalNames
$SPServicePrincipalNames.Add("$SPOAppID/$SPCN")
Set-MsolServicePrincipal -AppPrincipalId $SPOAppID -ServicePrincipalNames $SPServicePrincipalNames

# get the online name identifier
$MsolCompanyInformationID = (Get-MsolCompanyInformation).ObjectID
$MsolServicePrincipalID = (Get-MsolServicePrincipal -ServicePrincipalName $SPOAppID).ObjectID
$MsolNameIdentifier = "$MsolServicePrincipalID@$MsolCompanyInformationID"

# establish the trust from on-premise with ACS (Azure Control Service)

# add a new authenticatio realm
$SPSite = Get-SPSite $SPSite
$SPAppPrincipal = Register-SPAppPrincipal -site $SPSite.rootweb -nameIdentifier $MsolNameIdentifier -displayName "SharePoint Online"
Set-SPAuthenticationRealm -realm $MsolServicePrincipalID

# register the ACS application proxy and token issuer
New-SPAzureAccessControlServiceApplicationProxy -Name "ACS" -MetadataServiceEndpointUri "https://accounts.accesscontrol.windows.net/metadata/json/1/" -DefaultProxyGroup
New-SPTrustedSecurityTokenIssuer -MetadataEndpoint "https://accounts.accesscontrol.windows.net/metadata/json/1/" -IsTrustBroker -Name "ACS"
```

# Add a new result source

To get search results from SharePoint Online we have to add a new result source. Run the following script in a PowerShell ISE session on your SharePoint 2013 on-premise server.
Don't forget to update the settings region

```powershell
if(-not (Get-PSSnapin "Microsoft.SharePoint.PowerShell" -ErrorAction SilentlyContinue)){Add-PSSnapin "Microsoft.SharePoint.PowerShell"}

# region settings 
$RemoteSharePointUrl = "http://[example].sharepoint.com"
$ResultSourceName = "SharePoint Online"
$QueryTransform = "{searchTerms}"
$Provier = "SharePoint-Remoteanbieter"
# region settings end

$SPEnterpriseSearchServiceApplication = Get-SPEnterpriseSearchServiceApplication
$FederationManager = New-Object Microsoft.Office.Server.Search.Administration.Query.FederationManager($SPEnterpriseSearchServiceApplication)
$SPEnterpriseSearchOwner = Get-SPEnterpriseSearchOwner -Level Ssa  

$ResultSource = $FederationManager.GetSourceByName($ResultSourceName, $SPEnterpriseSearchOwner)
if(!$ResultSource){
    Write-Host "Result source does not exist. Creating..."
    $ResultSource = $FederationManager.CreateSource($SPEnterpriseSearchOwner)
}

$ResultSource.Name = $ResultSourceName
$ResultSource.ProviderId = $FederationManager.ListProviders()[$Provier].Id
$ResultSource.ConnectionUrlTemplate = $RemoteSharePointUrl
$ResultSource.CreateQueryTransform($QueryTransform)
$ResultSource.Commit()
```

## Add a new query rule

1. In the Search Administration click on **Query Rules**
2. Select **Local SharePoint** as Result Source
3. Click **New Query Rule**
4. Enter a Rule name f.g. Search results from SharePoint Online
5. Expand the **Context** section
6. Under **Query is performed on these sources** click on **Add Source**
7. Select your SharePoint Online result source
8. In the **Query Conditions** section click on **Remove Condition**
9. In the **Actions** section click on **Add Result Block**
10. As **title** enter **Results for "{subjectTerms}" from SharePoint Online**
11. In the **Search this Source** dropdown select your SharePoint Online result source
12. Select 3 in the **Items** dropdown
13. Expand the **Settings** section and select **"More" link goes to the following URL**
14. In the box below enter this Url **https://[example].sharepoint.com/search/pages/results.aspx?k={subjectTerms}**
15. Select **This block is always shown above core results** and click the OK button
16. Save the new query rule

# Source

[Replace the STS certificate for the on-premises environment](http://technet.microsoft.com/en-us/library/dn551378.aspx)  
[Display hybrid search results in SharePoint Server 2013](http://technet.microsoft.com/en-us/library/dn197173.aspx)  
[Office 365-Configure Hybrid Search with Directory Synchronization –Password Sync](http://blogs.msdn.com/b/spses/archive/2013/10/22/office-365-configure-hybrid-search-with-directory-synchronization.aspx)  
[Office 365-Configure Hybrid Search with Directory Synchronization –Password Sync –Part2](http://blogs.msdn.com/b/spses/archive/2014/01/05/office-365-configure-hybrid-search-with-directory-synchronization-password-sync-part2.aspx)  
[Back up service applications in SharePoint 2013](http://technet.microsoft.com/en-us/library/ee428318.aspx)  