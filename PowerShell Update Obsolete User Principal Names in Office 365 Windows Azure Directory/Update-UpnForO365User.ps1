#--------------------------------------------------#
# settings
#--------------------------------------------------#

$OU = "OU=vblusers2,DC=vbl,DC=ch"

#--------------------------------------------------#
# modules
#--------------------------------------------------#

Import-Module MSOnline
Import-Module MSOnlineExtended
Import-Module ActiveDirectory

#--------------------------------------------------#
# main
#--------------------------------------------------#

$ADUsers = Get-ADUser -Filter * -SearchBase $OU -Properties GivenName, Surname, DisplayName

$Credential = Import-PSCredential $(Get-ChildItem -Path $PSconfigs.Path -Filter "Office365.credentials.config.xml" -Recurse).FullName
Connect-MsolService -Credential $Credential
$MsolUsers = Get-MsolUser -All

$MsolUsers | %{

    $MsolUser = $_
    $ADUsers | where{($_.GivenName -eq $MsolUser.FirstName) -and 
        ($_.Surname -eq $MsolUser.LastName) -and
        ($_.DisplayName -eq $MsolUser.DisplayName) -and 
        ($_.UserPrincipalName -ne $MsolUser.UserPrincipalName)
    } | %{

        
        Write-Host "Change UserPrincipalName for: $($MsolUser.UserPrincipalName) to: $($_.UserPrincipalName)"
        Set-MsolUserPrincipalName -UserPrincipalName $MsolUser.UserPrincipalName -NewUserPrincipalName $_.UserPrincipalName

    }
}