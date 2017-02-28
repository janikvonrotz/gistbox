<#
$Metadata = @{
    Title = "Update ActiveDirectory Security Groups"
    Filename = "Update-ADSecurityGroups.ps1"
    Description = ""
    Tags = "powershell, activedirectory, security, groups, update"
    Project = ""
    Author = "Janik von Rotz"
    AuthorContact = "http://janikvonrotz.ch"
    CreateDate = "2013-10-07"
    LastEditDate = "2014-01-30"
    Url = "https://gist.github.com/7137592"
    Version = "1.1.1"
    License = @'
This work is licensed under the Creative Commons Attribution-ShareAlike 3.0 Switzerland License.
To view a copy of this license, visit http://creativecommons.org/licenses/by-sa/3.0/ch/ or
send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
'@
}
#>


#--------------------------------------------------#
# modules
#--------------------------------------------------#    
Import-Module ActiveDirectory

$OUConfigs = @(
    @{
        OU = "OU=vblusers2,DC=vbl,DC=ch"
        
        GroupSuffix = " Abteilung"
        GroupMemberPrefix = "F_"

        ParentGroupSuffix = " Abteilungen"
        ParentGroupMemberSuffix = " Abteilung"

        ExcludeOUs = "Extern","ServiceAccounts","Services"
        
        ExcludeADGroups = "F_Mitarbeiter ohne Arbeitsplatz",
            "F_Mitarbeiter mit Arbeitsplatz",
            "F_Verwaltungsrat"
    }
)

$Tasks = @(
    @{
        Name = "F_Mitarbeiter mit Arbeitsplatz"
        Options = @("CleanGroup","UpdateFromGroups","RemoveGroups","ProcessUsers")
        AddGroups = @("vblusers2 Abteilungen")
		RemoveGroups = @("F_Mitarbeiter ohne Arbeitsplatz","F_Service Benutzer","F_Archivierte Benutzer")
    },
    @{
        Name = "F_Mitarbeiter"
        Options = @("CleanGroup","UpdateFromGroups","RemoveGroups","ProcessUsers")
        AddGroups = @("F_Mitarbeiter ohne Arbeitsplatz","F_Mitarbeiter mit Arbeitsplatz")
        RemoveGroups = @("F_Archivierte Benutzer")
    },
    @{
        Name = "F_Service Benutzer"
        Options = @("CleanGroup","UpdateFromOU","RemoveGroups","IncludeDisabledUsers","ProcessUsers")
        AddOU = @("OU=vblusers2,DC=vbl,DC=ch")
		RemoveGroups = @("F_Mitarbeiter","F_Archivierte Benutzer")
    } 
)

$OUConfigs | %{
    $OUConfig = $_
    Get-ADOrganizationalUnit -Filter "*" -SearchBase $_.OU | 
    where{$ThisOU = $_; -not ($OUConfig.ExcludeOUs | where{$ThisOU.DistinguishedName -match $_})} | %{
            
        $OUconfig.OU = $_
            
        $ParentGroupName = ($_.Name + $OUconfig.ParentGroupSuffix)          
        $ParentGroupMembers = Get-ADOrganizationalUnit -Filter * -SearchBase $_.DistinguishedName | %{Get-ADGroup -SearchScope OneLevel -Filter * -SearchBase $_.DistinguishedName | where{$_.Name.EndsWith($OUconfig.ParentGroupMemberSuffix)}} | select -Unique
        $ParentGroup = Get-ADGroup -SearchScope OneLevel -Filter {SamAccountName -eq $ParentGroupName -and GroupCategory -eq "Security"}  -SearchBase $_.DistinguishedName
        
        $GroupName = ($_.Name + $OUconfig.GroupSuffix)
        $GroupMembers = Get-ADGroup -SearchScope OneLevel -Filter * -SearchBase $_.DistinguishedName | where{$_.Name.StartsWith($OUconfig.GroupMemberPrefix) -and ($OUconfig.ExcludeADGroups -notcontains $_.Name)}
        $Group = Get-ADGroup -SearchScope OneLevel -Filter{SamAccountName -eq $GroupName -and GroupCategory -eq "Security"} -SearchBase $_.DistinguishedName
        
        if($ParentGroupMembers -and $ParentGroup){
            
            "Update members in parent group: $($ParentGroup.Name)." | %{$Message += "`n" + $_; Write-Host $_}
            Get-ADGroupMember -Identity $ParentGroup | %{Remove-ADGroupMember -Identity $ParentGroup -Members $_ -Confirm:$false}
            $ParentGroupMembers | %{Add-ADGroupMember -Identity $ParentGroup -Members $_}
                    
        }elseif($ParentGroupMembers -and $ParentGroupMembers.count -gt 1){
        
            "Add parent group: $ParentGroupName." | %{$Message += "`n" + $_; Write-Host $_}
            New-ADGroup -Name $ParentGroupName -SamAccountName $ParentGroupName -GroupCategory Security -GroupScope Global -DisplayName $ParentGroupName -Path $($_.DistinguishedName) -Description "Department group for $($_.Name)"
            $ParentGroupMembers | %{Add-ADGroupMember -Identity $ParentGroupName -Members $_}
        }
        
        if($Group -and $GroupMembers){
            
            #"Update members in group: $($Group.Name)." | %{$Message += "`n" + $_; Write-Host $_}
            $GroupMembersIS = Get-ADGroupMember -Identity $Group | %{"$($_.DistinguishedName)"}
            $GroupMemberTO = $GroupMembers | %{"$($_.DistinguishedName)"}
                                    
            Get-ADGroupMember -Identity $Group | where{(-not $_.Name.StartsWith($OUconfig.GroupMemberPrefix)) -or ($GroupMemberTO -notcontains $_.DistinguishedName)} | %{
                "Remove member: $($_.Name) from group: $($Group.Name)." | %{$Message += "`n" + $_; Write-Host $_}
                Remove-ADGroupMember -Identity $Group -Members $_ -Confirm:$false
            }            
            
            $GroupMembers | where{($GroupMembersIS -notcontains $_.DistinguishedName)} | %{
                "Add member: $($_.Name) to group: $($Group.Name)." | %{$Message += "`n" + $_; Write-Host $_}
                Add-ADGroupMember -Identity $Group -Members $_
            }
                    
        }elseif($GroupMembers){
        
            "Add group: $GroupName." | %{$Message += "`n" + $_; Write-Host $_}
            New-ADGroup -Name $GroupName -SamAccountName $GroupName -GroupCategory Security -GroupScope Global -DisplayName $GroupName -Path $($_.DistinguishedName) -Description "Department group for $($_.Name)"
            $GroupMembers | %{Add-ADGroupMember -Identity $GroupName -Members $_}
        }
    }
}

$Tasks | %{
    
    $ADGroup = Get-ADGroup -Identity $_.Name
    $Options = $_.Options
        
    if($_.Options -match "CleanGroup"){
        
        "Remove members from: $($_.Name)." | %{$Message += "`n" + $_; Write-Host $_}
        Get-ADGroupMember -Identity $ADGroup | %{Remove-ADGroupMember -Identity $ADGroup -Members $_ -Confirm:$false}
    }
    
    if($_.Options -match "UpdateFromOU"){
        
        "Add users from OU: $($_.AddOU) to: $($_.Name)." | %{$Message += "`n" + $_; Write-Host $_}
        $_.AddOU | %{Get-ADUser -Filter * -SearchBase $_ | where{($Options -match "IncludeDisabledUsers") -or ($Options -notmatch "IncludeDisabledUsers" -and $_.Enabled -eq $true)}} | select -Unique | %{Add-ADGroupMember -Identity $ADGroup -Members $_}
    
    } 
    
    if($_.Options -match "UpdateFromGroups"){        
        
        if($_.Options -match "ProcessUsers"){
        
            "Add users from: $($_.AddGroups) to: $($_.Name)." | %{$Message += "`n" + $_; Write-Host $_}
            $_.AddGroups | %{Get-ADGroupMember $_ -Recursive | Get-ADUser | where{($Options -match "IncludeDisabledUsers") -or ($Options -notmatch "IncludeDisabledUsers" -and $_.Enabled -eq $true)}} | select -Unique | %{Add-ADGroupMember -Identity $ADGroup -Members $_}
        
        }else{
        
            "Add groups: $($_.AddGroups) to: $($_.Name)." | %{$Message += "`n" + $_; Write-Host $_}
            $_.AddGroups | %{Add-ADGroupMember -Identity $ADGroup -Members $_}        
        }               
    }   
    
    if($_.Options -match "RemoveGroups"){
    
        if($_.Options -match "ProcessUsers"){
        
            "Remove users from: $($_.RemoveGroups) in: $($_.Name)." | %{$Message += "`n" + $_; Write-Host $_}
            $ADGroupMembers = Get-ADGroupMember -Identity $ADGroup
            $_.RemoveGroups | %{Get-ADGroupMember $_ -Recursive | Get-ADUser | where{($Options -match "IncludeDisabledUsers") -or ($Options -notmatch "IncludeDisabledUsers" -and $_.Enabled -eq $true) -and ($ADGroupMembers -match $_)}} | select -Unique |  %{Remove-ADGroupMember -Identity $ADGroup -Members $_  -Confirm:$false}
            
        }else{
        
            "Remove groups: $($_.RemoveGroups) in: $($_.Name)." | %{$Message += "`n" + $_; Write-Host $_}
            $_.RemoveGroups | %{Remove-ADGroupMember -Identity $ADGroup -Members $_ -Confirm:$false}
        }                  
    }           
}

Write-PPEventLog $($MyInvocation.InvocationName + "`n`n" + $Message ) -Source "Update Security Groups"
Write-PPErrorEventLog -Source "Update Security Groups" -ClearErrorVariable