if(-not (Get-PSSnapin "Microsoft.SharePoint.PowerShell" -ErrorAction SilentlyContinue)){Add-PSSnapin "Microsoft.SharePoint.PowerShell"}

# update SharePoint cache token lifetime

$SPContentService = [Microsoft.SharePoint.Administration.SPWebService]::ContentService
$SPContentService.TokenTimeout = (New-TimeSpan -minutes 5)
$SPContentService.Update()

# udpate SharePoint claims token lifetime

$SPSecurityTokenServiceConfig = Get-SPSecurityTokenServiceConfig
$SPSecurityTokenServiceConfig.WindowsTokenLifetime = (New-TimeSpan –minutes 5)
$SPSecurityTokenServiceConfig.FormsTokenLifetime = (New-TimeSpan -minutes 5)

# if you happen to set a lifetime that is shorter than the expiration window user will be blocked from accessing the site.
$SPSecurityTokenServiceConfig.LogonTokenCacheExpirationWindow = (New-TimeSpan -minutes 4)
$SPSecurityTokenServiceConfig.Update()

iisreset.exe