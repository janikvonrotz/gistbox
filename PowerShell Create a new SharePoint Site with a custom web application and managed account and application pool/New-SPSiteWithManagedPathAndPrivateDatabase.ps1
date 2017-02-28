# Import-Module ActiveDirectory
if((Get-PSSnapin 'Microsoft.SharePoint.PowerShell' -ErrorAction SilentlyContinue) -eq $null){Add-PSSnapin 'Microsoft.SharePoint.PowerShell'}

# add managed path
$WebApplication = "http://sharepoint.domain.ch"
$RelativeURLExplicit = "/itwiki"
New-SPManagedPath -RelativeURL $RelativeURLExplicit -WebApplication $WebApplication -Explicit

# add content database
$SPContentDatabaseName = "SP_Content_ITWiki"
New-SPContentDatabase -Name $SPContentDatabaseName -WebApplication $WebApplication

$SiteName = "Informatik Wiki"
$SiteUrl = "http://sharepoint.domain.ch/itwiki"
$SiteTemplate = "ENTERWIKI#0"
$SiteOwnerAlias = "SP1_Pool_Intranet"
$SiteSecondaryOwnerAlias = "SP1_Admin"
New-SPSite -Url $SiteUrl -Template $SiteTemplate -Name $SiteName -OwnerAlias $SiteOwnerAlias -SecondaryOwnerAlias $SiteSecondaryOwnerAlias -ContentDatabase $SPContentDatabaseName