<#
$Metadata = @{
    Title = "Update ActiveDirectory users"
    Filename = "Update-ADUsers.ps1"
    Description = ""
    Tags = "powershell, activedirectory, user, update"
    Project = ""
    Author = "Janik von Rotz"
    AuthorContact = "http://janikvonrotz.ch"
    CreateDate = "2013-08-16"
    LastEditDate = "2013-08-16"
    Url = "https://gist.github.com/janikvonrotz/6247876"
    Version = "1.0.0"
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
    if((Get-QADUser $_.Name)){       
        
        <# change Attributes

        Write-Host "Updating User" $_.Name
        Set-QADUser -Identity $_.Name `
            -Company $_.company `
            | Out-Null
        
        #>


        # update group memberships        
        $ADMemberOfs = $_.MemberOf -split ","
        foreach( $ADMemberOf in  $ADMemberOfs){
            Write-Host "Add User $($_.Name) to the group $ADMemberOf"
            Add-QADMemberOf $_.Name -Group $ADMemberOf | Out-Null
        }


    }else{
        
        Write-Host $_.Name "doesnt' exist"

    }
}