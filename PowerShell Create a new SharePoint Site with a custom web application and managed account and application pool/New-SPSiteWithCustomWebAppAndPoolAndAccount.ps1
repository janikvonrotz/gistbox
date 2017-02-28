# modules
Import-Module ActiveDirectory
if((Get-PSSnapin 'Microsoft.SharePoint.PowerShell' -ErrorAction SilentlyContinue) -eq $null){Add-PSSnapin 'Microsoft.SharePoint.PowerShell'}


# new service account
$UserName = "SharePoint Service User Wiki"
$UserUPN = "sa-spwiki@vbl.ch"
$UserSam = "sa-spwiki"
$UserPassword = "pass."
if(-not (Get-ADUser -Filter {sAMAccountName -eq $UserSam})){
    New-ADUser -Name $UserName -UserPrincipalName $UserUPN -SamAccountName $UserSam
    Get-ADUser $UserSam | %{
        Set-ADAccountPassword -Identity $UserSam -NewPassword (ConvertTo-SecureString -String $UserPassword -AsPlainText -Force) -Reset
        Enable-ADAccount -Identity $_
        Set-ADAccountControl -Identity $_ -PasswordNeverExpires $true -CannotChangePassword $true
        Set-ADUser -Identity $_ -ChangePasswordAtLogon $false
        $_
    }
}


# new sp service account
$ManagedAccountName = $UserSam
$ManagedAccountPassword = $UserPassword
if(-not (Get-SPManagedAccount $ManagedAccountName)){New-SPManagedAccount -Credential (New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $ManagedAccountName,(ConvertTo-SecureString -String $ManagedAccountPassword -AsPlainText -Force))}


# New Applicaton Pool
$PoolName = "SP_wiki"
$PoolAccount = $UserSam
if(-not (Get-SPServiceApplicationPool $PoolName)){New-SPServiceApplicationPool -Name $PoolName -Account $UserSam}


# New SPWeb Application
$AppName = "SP_wiki"
$AppPort = 80
$AppUrl = "http://wiki.vbl.ch"
$AppHostHeader = "wiki.vbl.ch"
$AppDatabaseServer = "VBL_SHAREPOINT"
$AppDatabaseName = "SP_Content_wiki"
$AppPoolName = $PoolName
$AppPoolAccount = $UserSam
if(-not (Get-SPWebApplication $AppName)){New-SPWebApplication -Name $AppName  -ApplicationPool $AppPoolName -ApplicationPoolAccount (Get-SPManagedAccount $AppPoolAccount) -HostHeader $AppHostHeader -Port $AppPort -URL $AppUrl -DatabaseServer $AppDatabaseServer -DatabaseName $AppDatabaseName}
    

# New SPSite
$SiteName = "Informatik Wiki"
$SiteUrl = $AppUrl
$SiteTemplate = "ENTERWIKI#0"
$SiteOwnerMail = "janik.vonrotz@vbl.ch"
$SiteOwnerAlias = "vonrotz"
if(-not (Get-SPSite -Identity $Siteurl)){New-SPSite -Url $SiteUrl -Template $SiteTemplate -Name $SiteName -OwnerEmail $SiteOwnerMail -OwnerAlias $SiteOwnerAlias}