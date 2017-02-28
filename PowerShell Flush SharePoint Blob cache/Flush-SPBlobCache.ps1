# http://technet.microsoft.com/en-us/library/gg277249(v=office.15).aspx

$SPWebApp = Get-SPWebApplication "[WebApplicationURL]"
[Microsoft.SharePoint.Publishing.PublishingCache]::FlushBlobCache($SPWebApp)
Write-Host "Flushed the BLOB cache for:" $SPWebApp