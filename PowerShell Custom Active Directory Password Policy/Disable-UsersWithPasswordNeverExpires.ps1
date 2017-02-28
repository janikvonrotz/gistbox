<#
$Metadata = @{
	Title = "Disabe Users With Password Never Expires"
	Filename = "Disable-UsersWithPasswordNeverExpires.ps1"
	Description = ""
	Tags = "powershell, script, jobs"
	Project = ""
	Author = "Janik von Rotz"
	AuthorContact = "http://.janikvonrotz.ch"
	CreateDate = "2013-12-13"
	LastEditDate = "2013-12-13"
	Version = "1.0.0"
	License = @'
This work is licensed under the Creative Commons Attribution-NonCommercial-NoDerivs 3.0 Unported License.
To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-nd/3.0/ or
send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
'@
}
#>

try{

    #--------------------------------------------------#
    # modules
    #--------------------------------------------------#    
    Import-Module ActiveDirectory
	
    #--------------------------------------------------#
    # settings
    #--------------------------------------------------#   
	$DaysBeforeDisablingUsersWithPasswordNeverExpires = 180
	$ADGroupWithUsersPasswordNeverExpires = "S-1-5-21-1744926098-708661255-2033415169-36648" # Memberof GroupName should be "SPO_PasswordNotification"      
    
    #--------------------------------------------------#
    # main
    #--------------------------------------------------#
             
    Get-ADGroupMember $ADGroupWithUsersPasswordNeverExpires -Recursive | 
    Get-ADUser -Properties Enabled, PasswordNeverExpires, PasswordLastSet |
    Select *, @{L = "PasswordExpires";E = {((Get-Date) - ($_.PasswordLastSet)).Days}} |
    where{($_.Enabled -eq $true) -and ($_.PasswordNeverExpires -eq $true) -and ($_.PasswordExpires -eq $DaysBeforeDisablingUsersWithPasswordNeverExpires)} | %{ 
         
       Write-PPEventLog "Enabled Passwort Expiration for: $($_.UserPrincipalName)." -WriteMessage -Source "Disabe Users With Password Never Expires"                  
       Set-ADUser -Identity $_.DistinguishedName -PasswordNeverExpires $false        
    }   
}catch{

	Write-PPErrorEventLog -Source "Disabe Users With Password Never Expires" -ClearErrorVariable
}
