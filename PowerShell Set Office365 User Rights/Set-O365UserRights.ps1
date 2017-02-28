<#
$Metadata = @{
    Title = "Set Office365 User Rights"
    Filename = "Set-O365UserRights.ps1"
    Description = @"
Manage Office365 portal access rights with ActiveDirectory groups.
Assign Administration roles to the members of specified AD groups or by a users userprincipalname.
"@
    Tags = "powershell, activedirectory, office365, user, rights"
    Project = ""
    Author = "Janik von Rotz"
    AuthorContact = "http://janikvonrotz.ch"
    CreateDate = "2013-08-13"
    LastEditDate = "2013-12-30"
    Url = "https://gist.github.com/janikvonrotz/6218401"
    Version = "3.3.0"
    License = @'
This work is licensed under the Creative Commons Attribution-ShareAlike 3.0 Switzerland License.
To view a copy of this license, visit http://creativecommons.org/licenses/by-sa/3.0/ch/ or
send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
'@
}
#>

try{

    #--------------------------------------------------#
    # settings
    #--------------------------------------------------#

    $MsolRoleConfig = @{
        ADGroup = "S-1-5-21-1744926098-708661255-2033415169-37011" # SPOF_Billing Administrator
        MsolRoleName = "Billing Administrator" # Get-MsolRole
    },
    @{
        ADGroup = "S-1-5-21-1744926098-708661255-2033415169-37030" # SPOF_Company Administrator
        MsolRoleName = "Company Administrator" # Get-MsolRole
    },
    @{
        User = "admin@vbluzern.onmicrosoft.com" # O365F_Billing Administrator
        MsolRoleName = "Company Administrator" # Get-MsolRole
    },
	@{
        User = "su-o365admin@vbluzern.onmicrosoft.com" # O365F_Billing Administrator
        MsolRoleName = "Company Administrator" # Get-MsolRole
    },
	@{
        User = "urs.egli@vbluzern.onmicrosoft.com" # O365F_Billing Administrator
        MsolRoleName = "Company Administrator" # Get-MsolRole
    }

    #--------------------------------------------------#
    # modules
    #--------------------------------------------------#
    Import-Module MSOnline
    Import-Module MSOnlineExtended
    Import-Module ActiveDirectory

    #--------------------------------------------------#
    # main
    #--------------------------------------------------#

    # import credentials
    $Credential = Import-PSCredential $(Get-ChildItem -Path $PSconfigs.Path -Filter "Office365.credentials.config.xml" -Recurse).FullName

    # connect to office365
    Connect-MsolService -Credential $Credential

    $UserAndMsolRole = ($MsolRoleConfig | where{$_.ADGroup -ne $null} | %{
            $MsolRole = $_.MsolRoleName; 
            $MsolRole = (Get-MsolRole | where{$_.Name -eq $MsolRole}); 
            Get-ADGroupMember $_.ADGroup -Recursive | Get-ADUser | select UserPrincipalName, @{Name = "MsolRole"; Expression={$MsolRole}}
        }) +
      
        ($MsolRoleConfig | where{$_.User -ne $null}| %{
            $MsolRole = $_.MsolRoleName;
            $_ | select @{L = "UserPrincipalName"; E = {$_.User}},@{L = "MsolRole"; E = {Get-MsolRole | where{$_.Name -eq $MsolRole}}}
        })

    $MsolRoleMembers = Get-MsolRole | %{$MsolRole = $_; Get-MsolRoleMember -RoleObjectId $_.ObjectID -MemberObjectTypes User | select @{L = "UserPrincipalName"; E = {$_.EmailAddress}},@{L = "MsolRole"; E = {$MsolRole}}}

    Get-MsolUser -All | %{

        $MsolUser = $_
        $AlreadyAssigned = $MsolRoleMembers | where{$_.UserPrincipalName -eq $MsolUser.UserPrincipalName}
        $Assign = $UserAndMsolRole | where{$_.UserPrincipalName -eq $MsolUser.UserPrincipalName}

        if($AlreadyAssigned){
        
            if(($Assign) -and ($AlreadyAssigned.MsolRole.ObjectId -ne $Assign.MsolRole.ObjectId)){

                Write-PPEventLog "Replace role: $($AlreadyAssigned.MsolRole.Name) with: $($Assign.MsolRole.Name) for: $($MsolUser.UserPrincipalName)" -Source "Office365 Portal Access Rights" -WriteMessage
                Remove-MsolRoleMember -RoleMemberEmailAddress $MsolUser.UserPrincipalName -RoleMemberType User -RoleName $AlreadyAssigned.MsolRole.Name
                Add-MsolRoleMember -RoleMemberEmailAddress $MsolUser.UserPrincipalName -RoleMemberType User -RoleName $Assign.MsolRole.Name

            }elseif($Assign -eq $null){

                Write-PPEventLog "Remove role: $($AlreadyAssigned.MsolRole.Name) for: $($MsolUser.UserPrincipalName)" -Source "Office365 Portal Access Rights" -WriteMessage
                Remove-MsolRoleMember -RoleMemberEmailAddress $MsolUser.UserPrincipalName -RoleMemberType User -RoleName $AlreadyAssigned.MsolRole.Name

            }else{

                Write-Host "Role: $($AlreadyAssigned.MsolRole.Name) for: $($MsolUser.UserPrincipalName) is already assigned"

            }
        }elseif($Assign){

            Write-PPEventLog "Assign role: $($Assign.MsolRole.Name) for: $($MsolUser.UserPrincipalName)" -Source "Office365 Portal Access Rights" -WriteMessage
            Add-MsolRoleMember -RoleMemberEmailAddress $MsolUser.UserPrincipalName -RoleMemberType User -RoleName $Assign.MsolRole.Name
        }
    }
}catch{

	Write-PPErrorEventLog -Source "Office365 Portal Access Rights" -ClearErrorVariable
}