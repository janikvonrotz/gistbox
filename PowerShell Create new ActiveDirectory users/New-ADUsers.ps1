<#
$Metadata = @{
    Title = "Create new ActiveDirectory users"
    Filename = "New-ADUsers.ps1"
    Description = ""
    Tags = "powershell, activedirectory, user"
    Project = ""
    Author = "Janik von Rotz"
    AuthorContact = "http://janikvonrotz.ch"
    CreateDate = "2013-08-16"
    LastEditDate = "2013-08-21"
    Url = "https://gist.github.com/janikvonrotz/6247871"
    Version = "1.1.0"
    License = @'
This work is licensed under the Creative Commons Attribution-ShareAlike 3.0 Switzerland License.
To view a copy of this license, visit http://creativecommons.org/licenses/by-sa/3.0/ch/ or
send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
'@
}
#>

Import-Module Quest.ActiveRoles.ArsPowerShellSnapIn

$ADUsers = Import-CSV "ADUsers.csv" -Delimiter ";"
$ADUsers | foreach{
    if(!(Get-QADUser $_.Name)){

        Write-Host "Creating user" $_.Name

        # create a new user
        New-QADUser -Name $_.Name `
            -DisplayName $_.DisplayName `
            -FirstName $_.givenName `
            -LastName $_.LastName `
            -Company $_.company `
            -PostalCode $_.postalCode `
            -PostOfficeBox $_.postOfficeBox `
            -StreetAddress $_.streetAddress `
            -WebPage $_.wWWHomePage `
            -City $_.l `
            -Department $_.department `
            -Manager $_.manager `
            -Title $_.title `
            -Email $_.mail `
            -UserPrincipalName $_.UserPrincipalName `
            -ParentContainer $_.OU `
            -samAccountName $_.samAccountName `
            -UserPassword $_.Password `
            -ObjectAttributes @{
                extensionAttribute1= $_.extensionAttribute1;
                extensionAttribute2 = $_.extensionAttribute2;
                extensionAttribute3 = $_.extensionAttribute3;
                co = $_.co;
                c = $_.c

            } | 
        Set-QADUser -PasswordNeverExpires $true |         
        Out-Null
        
        # update group memberships        
        $ADMemberOfs = $_.MemberOf -split ","
        foreach( $ADMemberOf in  $ADMemberOfs){
            Write-Host "Add User $($_.Name) to the group $ADMemberOf"
            Add-QADMemberOf $_.Name -Group $ADMemberOf | Out-Null
        }
         
    }else{
        
        Write-Host $_.Name "already exist"

    }
}