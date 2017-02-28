<#
$Metadata = @{
    Title = "Archive User ActiveDirectory and Mailbox"
    Filename = "Archive-ADUserAndMailbox.ps1"
    Description = ""
    Tags = "powershell, activedirectory, archive, user, mailbox"
    Project = ""
    Author = "Janik von Rotz"
    AuthorContact = "http://janikvonrotz.ch"
    CreateDate = "2013-10-21"
    LastEditDate = "2014-01-22"
    Url = "https://gist.github.com/6780143"
    Version = "1.4.1"
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
    $ExchangeServer = "vblw2k8mail05"
    $FilterRecipientTypeDetails = @("UserMailbox","RemoteUserMailbox")
    $DescriptionFilter = "archived"
    $ADArchivedUserGroup = "F_Archivierte Benutzer"

    #--------------------------------------------------#
    # functions
    #--------------------------------------------------# 

    function Rename-ADUserAndMailbox{

        param(
            [Parameter(Mandatory=$true)]
            $ADUser,
            
            [Parameter(Mandatory=$true)]
            $MailBox
        )

        $ArchivedIdentity = ($($ADUser.SID).tostring() -replace "-","").substring(0,20)
       
        if(-not (Get-ADUser -Filter{SamAccountName -eq $ArchivedIdentity} -ErrorAction SilentlyContinue)){
                       
            $NewName = ("$($ADUser.Name) $($ADUser.SID)")
            if($NewName.Length -ge 64){$NewName.Substring(0,64)}
            $NewUserPrincipalName =  "$($ADUser.UserPrincipalName.split('@')[0])$($ADUser.SID)@$($ADUser.UserPrincipalName.split('@')[1])" -replace "-",""
            $NewSamAccountName = ($($ADUser.SID).tostring() -replace "-","").substring(20)
            
            "Add Name: $($ADUser.Name) to group: $ADArchivedUserGroup" | %{$Message += "`n" + $_; Write-Host $_}
            Add-ADGroupMember -Identity $ADArchivedUserGroup -Members $Aduser
            
            "Rename Name: $($ADUser.Name) to: $NewName" | %{$Message += "`n" + $_; Write-Host $_}
            Rename-ADObject $ADUser -NewName $NewName
            
            "Rename UserPrincipalName: $($ADUser.UserPrincipalName) to: $NewUserPrincipalName" | %{$Message += "`n" + $_; Write-Host $_}
            Set-ADUser -Identity $ADUser.SamAccountName -UserPrincipalName $NewUserPrincipalName -Description $DescriptionFilter
            
            "Remove manager from: $($ADUser.Name)" | %{$Message += "`n" + $_; Write-Host $_}
            Set-ADUser -Identity $ADUser.SamAccountName -Manager $null
            
            "Rename SamAccountName: $($ADUser.SamAccountName) to: $NewSamAccountName" | %{$Message += "`n" + $_; Write-Host $_}
            Get-ADUser $ADUser.SamAccountName | Set-ADUser -SamAccountName $NewSamAccountName                
            
            $NewPrimarySmtpAddress = "$($ADUser.UserPrincipalName.split('@')[0])$($ADUser.SID)@$($ADUser.UserPrincipalName.split('@')[1])" -replace "-",""
            $OldPrimarySmtpAddress = $Mailbox.PrimarySmtpAddress
            
            if($Mailbox.psObject.TypeNames -contains "Deserialized.Microsoft.Exchange.Data.Directory.Management.RemoteMailbox"){

                $NewRemoteRoutingAddress = "$($Mailbox.RemoteRoutingAddress.split("@")[0])$($ADUser.SID)@$($Mailbox.RemoteRoutingAddress.split("@")[1])" -replace "-",""
                $OldRemoteRoutingAddress = $Mailbox.RemoteRoutingAddress      
                                   
                $RemoteMailbox = Get-RemoteMailbox $ADuser.Name
                $RemoteMailbox | %{
                
                    "Update remotemailbox email address policy" | %{$Message += "`n" + $_; Write-Host $_}
                    Set-RemoteMailBox $_.Alias -EmailAddressPolicyEnabled:$false
                
                    "Hide remotemailbox: $($_.Name) from address lists." | %{$Message += "`n" + $_; Write-Host $_}
                    Set-RemoteMailbox $_.Alias -HiddenFromAddressListsEnabled:$true
                
                    "Rename PrimarySmtpAddress for: $($_.PrimarySmtpAddress) to: $NewPrimarySmtpAddress" | %{$Message += "`n" + $_; Write-Host $_}
                    Set-RemoteMailbox $_.Alias -PrimarySmtpAddress $NewPrimarySmtpAddress;           
                    
                    "Rename RemoteRoutingAddress for: $($_.RemoteRoutingAddress) to: $NewRemoteRoutingAddress" | %{$Message += "`n" + $_; Write-Host $_}
                    Set-RemoteMailbox $_.Alias -RemoteRoutingAddress $NewRemoteRoutingAddress
                    
                    "Remove default mail addresses: $OldRemoteRoutingAddress, $PrimarySmtpAddress on: $($_.Alias)" | %{$Message += "`n" + $_; Write-Host $_}
                    Set-RemoteMailbox $_.Alias -EmailAddresses @{remove = $OldRemoteRoutingAddress, $OldPrimarySmtpAddress}
                }
                
            }elseif($Mailbox.psObject.TypeNames -contains "Deserialized.Microsoft.Exchange.Data.Directory.Management.Mailbox"){
            
               $MailBox = Get-Mailbox $ADuser.Name
               $MailBox | %{
               
                    "Udate mailbox email address policy" | %{$Message += "`n" + $_; Write-Host $_}
                    Set-Mailbox $_.Alias -EmailAddressPolicyEnabled:$false
               
                    "Hide mailbox: $($_.Name) from address lists." | %{$Message += "`n" + $_; Write-Host $_}
                    Set-Mailbox $_.Alias -HiddenFromAddressListsEnabled:$true
                
                    "Rename PrimarySmtpAddress for: $($_.PrimarySmtpAddress) to: $NewPrimarySmtpAddress" | %{$Message += "`n" + $_; Write-Host $_}
                    Set-Mailbox $_.Alias -PrimarySmtpAddress $NewPrimarySmtpAddress 
                
                    "Remove default mail addresses: $OldPrimarySmtpAddress on: $($Mailbox.Alias)" | %{$Message += "`n" + $_; Write-Host $_}
                    Set-Mailbox $_.Alias -EmailAddresses @{remove = $OldPrimarySmtpAddress}
               }
            }
            
            Write-PPEventLog -Message $Message -Source "Archiv ActiveDirectory User and Mailbox"
        }
    }

    #--------------------------------------------------#
    # modules
    #--------------------------------------------------#  
    Import-Module ActiveDirectory

    #--------------------------------------------------#
    # main
    #--------------------------------------------------#  

    # open remote connection
    $PSSession = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri "http://$ExchangeServer/PowerShell/" -Authentication Kerberos

    # import 
    Import-PSSession $PSSession -AllowClobber

    $Mailboxes = Get-Mailbox
    $RemoteMailboxes = Get-RemoteMailbox

    # disable mailbox and remote mailbox
    Get-ADUser -Filter{Enabled -eq $false} -Properties mail, description | where{$_.mail -ne $null -and $_.description -ne $DescriptionFilter} | 
        %{$ADUser = $_; $Mailboxes | where{$_.Name -eq $ADuser.Name -and $FilterRecipientTypeDetails -contains $_.RecipientTypeDetails}} |%{
            $Message = $MyInvocation.InvocationName;
            Rename-ADUserAndMailbox -ADUser $ADUser -MailBox $_
        }

    # disable remote mailbox
    Get-ADUser -Filter{Enabled -eq $false} -Properties mail, description | where{$_.mail -ne $null -and $_.description -ne $DescriptionFilter} | 
        %{$ADUser = $_; $RemoteMailboxes | where{$_.Name -eq $ADuser.Name -and $FilterRecipientTypeDetails -contains $_.RecipientTypeDetails}} | %{
            $Message = $MyInvocation.InvocationName;
            Rename-ADUserAndMailbox -ADUser $ADUser -MailBox $_
    }

    # destroy pssession
    Remove-PSSession $PSSession

}catch{

    Write-PPErrorEventLog  -Source "Archiv ActiveDirectory User and Mailbox" -ClearErrorVariable
}