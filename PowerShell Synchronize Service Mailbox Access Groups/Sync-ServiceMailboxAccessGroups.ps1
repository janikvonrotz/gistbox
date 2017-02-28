<#
$Metadata = @{
	Title = "Synchronize Service Mailbox Access Groups"
	Filename = "Sync-ServiceMailboxAccessGroups.ps1"
	Description = ""
	Tags = "powershell, activedirectory, exchange, synchronization, access, mailbox, groups, permissions"
	Project = ""
	Author = "Janik von Rotz"
	AuthorContact = "http://janikvonrotz.ch"
	CreateDate = "2014-01-27"
	LastEditDate = "2014-01-27"
	Url = ""
	Version = "0.0.0"
	License = @'
This work is licensed under the Creative Commons Attribution-ShareAlike 3.0 Switzerland License.
To view a copy of this license, visit http://creativecommons.org/licenses/by-sa/3.0/ch/ or 
send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
'@
}
#>

$Config = @{
    OU = "OU=Mailbox,OU=Exchange,OU=Services,OU=vblusers2,DC=vbl,DC=ch"
    ADGroupFilter = @{           
        NamePrefix = "EX_"
        NameInfix = ""
        NameSuffix = ""  
    }    
    ADGroup = @{
        NamePrefix = "EX_"
        PermissionSeperator = "#"        
    }    
	SyncMailboxUsersWith = "F_Service Mailbox"
    ADGroupMailboxReferenceAttribute = "extensionAttribute1"    
    MailBoxFilter = @{
        RecipientTypeDetails = "UserMailbox","EquipmentMailbox","RoomMailbox"
        ADGroupsAndUsers = "F_Mitarbeiter","F_Archivierte Benutzer"
        ExcludeDisplayName = "FederatedEmail.4c1f4d8b-8179-4148-93bf-00a95fa1e042"
    }
    
} | %{New-Object PSObject -Property $_}

# required modules
Import-Module ActiveDirectory

# Connect Exchange Server
$ExchangeServer = (Get-RemoteConnection ex1).Name
if(-not (Get-PSSession | where{$_.ComputerName -eq $ExchangeServer})){
    $PSSession = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri "http://$ExchangeServer/PowerShell/" -Authentication Kerberos
    Import-PSSession $PSSession
}

# get domain name
$Domain = "$(((Get-ADDomain).Name).toupper())\"

# get ad user objects
$Config.MailBoxFilter.ADGroupsAndUsers = $Config.MailBoxFilter.ADGroupsAndUsers | %{
    Get-ADObject -Filter {(Name -eq $_) -or (ObjectGUID -eq $_)} | %{        
        if($_.ObjectClass -eq "user"){$_.DistinguishedName            
        }elseif($_.ObjectClass -eq "group"){ Get-ADGroupMember $_.DistinguishedName -Recursive}
    } | Get-ADUser -Properties Mail
}

# create mail list to filter mailboxes
$Config.MailboxFilter.AllowedMails = $Config.MailBoxFilter.ADGroupsAndUsers | %{"$($_.Mail)"}

# create SamAccountName list to filter mailbox permissions
$Config.ADGroupFilter.AllowedUsers = $Config.MailboxFilter.ADGroupsAndUsers | %{"$($Domain + $_.SamAccountName)"}

# get exisiting mailbox permission ad groups
$ADGroups = Get-ADGroup -Filter * -SearchBase $Config.OU -Properties $Config.ADGroupMailboxReferenceAttribute | where{$_.Name.StartsWith($Config.ADGroupFilter.NamePrefix) -and $_.Name.Contains($Config.ADGroupFilter.NameInfix) -and $_.Name.EndsWith($Config.ADGroupFilter.NameSuffix)}

# sync mailbox access groups for each mailbox
$Mailboxes = Get-Mailbox | where{$Config.MailBoxFilter.RecipientTypeDetails -contains $_.RecipientTypeDetails -and $Config.MailboxFilter.AllowedMails -notcontains $_.PrimarySmtpAddress.tolower() -and $Config.MailBoxFilter.ExcludeDisplayName -notcontains $_.DisplayName}

$MailboxData = $Mailboxes | %{

    # set variables
    $ADPermissionGroups = @()
    $Mailbox = $_
    
    Write-Host "Parsing permissions on mailbox: $($_.Alias)"
        
    # get existing permission groups
    $ADPermissionGroups += $ADGroups | where{(iex "`$_.$($Config.ADGroupMailboxReferenceAttribute)") -eq $Mailbox.Guid}
    $ADExistingPermissionGroupTypes = $ADPermissionGroups| where{$_} | %{$_.Name.split("#")[1]}
    
    # get existing and allowed mailbox permissions
    $MailboxPermissions = $Mailbox | Get-MailboxPermission | where{$Config.ADGroupFilter.AllowedUsers -contains $_.User}
    
    # create an ad group foreach permissiontype that is required
    $NewADPermissionGroupTypes = $MailboxPermissions | %{"$($_.AccessRights)".split(", ") | where{$_} | %{$_} | %{$_ | where{$ADExistingPermissionGroupTypes -notcontains $_}}}
    $ADPermissionGroups += $NewADPermissionGroupTypes | Group | %{
        
        # create ad group name foreach permission type
        $Name = $config.ADGroup.NamePrefix + $Mailbox.Displayname + $Config.ADGroup.PermissionSeperator + $_.Name  
                  
        Write-PPEventLog -Message "Add service mailbox access group: $Name" -Source "Synchronize Service Mailbox Access Groups" -WriteMessage           
        New-ADGroup -Name $Name -SamAccountName $Name -GroupCategory Security -GroupScope Global -DisplayName $Name  -Path $Config.OU -Description "Exchange Access Group for: $($Mailbox.Displayname)" 
        Get-ADGroup $Name
        
    } | %{
        
        # set the reference from the adgroup to the mailbox
        iex "`$_.$($Config.ADGroupMailboxReferenceAttribute) = `"$($Mailbox.Guid)`""
        Set-ADGroup -Instance $_
        $ADGroup = $_    
        
        # add existing members to the permission group
        $MailboxPermissions | where{$_.AccessRights -match $ADGroup.Name.split("#")[1]} | %{                    
            Add-ADGroupMember -Identity $ADGroup -Members ($_.User -replace "$Domain\","")
        }
        
        # output ad permission groups
        $_
    }

    # check members foreach permission group
    $ADPermissionGroups | where{$_} | %{   
    
        # get permission type
        $Permission = $_.Name.split("#")[1]
    
        # get existing ad user groups
        $ADPermissionGroupUsers = $_ | Get-ADGroupMember -Recursive | select @{L="User";E={$($Domain + $_.SamAccountName)}}
        $MailboxUsers =  $MailboxPermissions | where{$_.AccessRights -match $Permission} | select user
        
        # compare these groups and update members       
        if($ADPermissionGroupUsers){
            $PermissionDiff = Compare-Object -ReferenceObject $ADPermissionGroupUsers -DifferenceObject $MailboxUsers -Property User
            
            # add member
            $PermissionDiff | where{$_.SideIndicator -eq "<="} | %{
            
                Write-PPEventLog -Message "Add mailbox permission: $Permission for user: $($_.User) on mailbox: $($Mailbox.Alias)" -Source "Synchronize Service Mailbox Access Groups" -WriteMessage
                Add-MailboxPermission -Identity $Mailbox.Alias -User $_.User -AccessRights $Permission
            }  
            
            # remove member
            $PermissionDiff | where{$_.SideIndicator -eq "=>"} | %{
            
                Write-PPEventLog -Message "Remove mailbox permission: $Permission for user: $($_.User) on mailbox: $($Mailbox.Alias)" -Source "Synchronize Service Mailbox Access Groups" -WriteMessage
                Remove-MailboxPermission -Identity $Mailbox.Alias -User $_.User -AccessRights $Permission -Confirm:$false
            } 
            
            # output ad permission group  
            @{ADGroup = $_}
        }        
    }
    # output mailbox identity
    @{Identity = $Mailbox.UserPrincipalName | %{Get-ADUser -Filter{UserPrincipalName -eq $_}}}
}

$RequiredADGroups = $MailboxData | %{$_.ADGroup}
$ADGroups | where{$RequiredADGroups -notcontains $_} | %{

    Write-PPEventLog -Message "Remove service mailbox access group: $Name" -Source "Synchronize Service Mailbox Access Groups" -WriteMessage  
    Remove-ADGroup -Identity $_ -Confirm:$false
}

$Member = $($MailboxData | %{$_.Identity}) | where{$_}
Sync-ADGroupMember -ADGroup $Config.SyncMailboxUsersWith -Member $Member -LogScriptBlock{Write-PPEventLog $Message -Source "Synchronize Service Mailbox Access Groups" -WriteMessage}
    
Remove-PSSession $PSSession
Write-PPErrorEventLog -Source "Synchronize Service Mailbox Access Groups" -ClearErrorVariable