
<#
$Metadata = @{
    Title = "Update ActiveDirectory Distribution Groups"
    Filename = "Update-ADDistributionGroups.ps1"
    Description = "Create or update ActiveDirectory distribution groups"
    Tags = "powershell, activedirectory, distribution, groups, create, update"
    Project = ""
    Author = "Janik von Rotz"
    AuthorContact = "http://janikvonrotz.ch"
    CreateDate = "2013-08-27"
    LastEditDate = "2013-11-11"
    Url = "https://gist.github.com/6352037"
    Version = "2.0.0"
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

#--------------------------------------------------#
# settings
#--------------------------------------------------# 

# run the script in these OUs
$OUs = @(    
    @{Name = "OU=Betrieb,OU=vblusers2,DC=vbl,DC=ch"},
    @{Name = "OU=Direktion,OU=vblusers2,DC=vbl,DC=ch"},
    @{Name = "OU=Finanzen,OU=vblusers2,DC=vbl,DC=ch"},
    @{Name = "OU=Personal,OU=vblusers2,DC=vbl,DC=ch"},         
    @{Name = "OU=Technik,OU=vblusers2,DC=vbl,DC=ch"}
)

# list of distribution groups to exclude
$ExcludeOUs = "Extern",""

# list of users to exclude in distribution groups
$ExcludeADUsers = ""
$ExcludeADGroups = "F_Service Benutzer"

# groupmembers and users to include on specific lists
$IncludeADUserAndGroup = @(
    @{
        DistributionGroupName = "Betriebszentrale"
        UsersAndGroups = "Leitst"
    },
    @{
        DistributionGroupName = "Fahrdienst"
        UsersAndGroups = "Betriebszentrale"
    }
)

# config task to create advanced distribution lists
$Configs = @(
    @{
        Name = "KST-Verantwortlichen"
        Options = @("UpdateFromGroups")
        AddGroups = @("F_Verantwortlicher Kostenstelle")
    },
    @{
        Name = "GL"
        Options = @("UpdateFromGroups")
        AddGroups = @("Geschäftsleitung Gruppe")
    }, 
    @{
        Name = "GL erw"
        Options = @("UpdateFromGroups")
        AddGroups = @("Erweiterte Geschäftsleitung Gruppe")
    },       
    @{
        Name = "Alle"
        Options = @("UpdateFromGroups")
        AddGroups = @("vblusers2 Abteilungen")
    },      
    @{
        Name = "Alle mit Arbeitsplatz"
        Options = @("UpdateFromGroups")
        AddGroups = @("F_Mitarbeiter mit Arbeitsplatz")
    },        
    @{
        Name = "Alle ohne Arbeitsplatz"
        Options = @("UpdateFromGroups")
        AddGroups = @("F_Mitarbeiter ohne Arbeitsplatz")
    },
    @{
        Name = "Personalkommission"
        Options = @("UpdateFromGroups")
        AddGroups = @("Personalkommission Abteilung")
    },
	@{
        Name = "Adressmutationen"
        Options = @("UpdateFromGroups")
        AddGroups = @("Teamleitung Abteilung","F_Kaufm. Mitarbeiter Empfang","F_Betriebsdisponent","F_Personalassistentin","F_Leiter Einkauf")
    }
)

#--------------------------------------------------#
# functions
#--------------------------------------------------# 
function Validate-ADUserForDistributionGroups{

    param(
        $Identity,
        $DistributionGroupName
    )
        
    $Identity | %{        
        $User =$_        
        $_ | where{
            ($_.enabled -eq $true) -and 
            (($ExcludeADUsers -notcontains $_.UserPrincipalName) -or 
            ($IncludeADUserAndGroup | where{
                ($_.DistributionGroupName -eq $DistributionGroupName) -and
                ($IncludeADUser -contains $User.UserPrincipalName)
            }
            ))
        }
    } | select -Unique
}

# extend exclude users
$ExcludeADUsers = ($ExcludeADUsers | where{$_ -ne ""} | %{(Get-ADUser $_).UserPrincipalName}) + ($ExcludeADGroups | %{Get-ADGroupMember $_ | Get-ADUser | %{$_.UserPrincipalName}})

# extend include users
$IncludeADUser = @()
$IncludeADUserAndGroup = $IncludeADUserAndGroup | %{

    $_.UsersAndGroups = $_.UsersAndGroups | %{
        Get-ADObject -Filter {Name -eq $_} | %{
            
            if($_.ObjectClass -eq "user"){
                
                Get-ADUser $_.DistinguishedName
                
            }elseif($_.ObjectClass -eq "group"){
            
                Get-ADGroupMember $_.DistinguishedName -Recursive | Get-ADUser 
            }
        } | %{
            
            $_
            
            $IncludeADUser += "$($_.UserPrincipalName)"
        }
    }
    
    $_
}

# get all OUs recursive
$OUs = $OUs | %{Get-ADOrganizationalUnit -Filter "*" -SearchBase $_.Name} | where {-not ($ExcludeOUs -contains $_.Name)}

# check in every OU if a distribution group with the same name as the OU exist
$OUs | %{$OU = $_.DistinguishedName;
    if(Get-ADGroup -Filter {SamAccountName -eq $_.Name -and GroupCategory -eq "Distribution"} | Where-Object{$_.DistinguishedName -like "*$OU"}){
                   
        Write-Host "Update users in distribution group $($_.Name)."
        $ADGroup = Get-ADGroup -Filter {SamAccountName -eq $_.Name -and GroupCategory -eq "Distribution"}
        $Name = $_.Name
        $Member = $(Get-ADUser -Filter {EmailAddress -like "*"} -SearchBase $OU)
        $($IncludeADUserAndGroup | where{$_.DistributionGroupName -eq $Name} | %{$Member += $_.UsersAndGroups})
        $Member = Validate-ADUserForDistributionGroups $Member -DistributionGroupName $_.Name        
        if($Member){Sync-ADGroupMember -ADGroup $ADGroup -Member $Member -LogScriptBlock{Write-PPEventLog $Message -Source "Update Distribution Groups"  -WriteMessage}}
        
    }else{
    
        Write-PPEventLog -Message "Create distribution group $($_.Name)." -Source "Update Distribution Groups" -WriteMessage
        New-ADGroup -Name $_.Name -SamAccountName $_.Name -GroupCategory Distribution -GroupScope Universal -DisplayName $_.Name -Path $($_.DistinguishedName) -Description "Distribution group for $($_.Name)."
        $ADGroup = Get-ADGroup $_.Name
        Get-ADUser -Filter {EmailAddress -like "*"} -SearchBase $_.DistinguishedName | where{($_.enabled -eq $true) -and ($ExcludeADUsers -notcontains $_.UserPrincipalName)} | where{$_ -ne $null} | %{Add-ADGroupMember -Identity $ADGroup -Members $_}       
    }
}

# custom configuration  
$Configs | %{      
    
    $ADGroup = Get-ADGroup -Identity $_.Name
    $Config = $_
    
    if($_.Options -match "UpdateFromGroups"){
        
        Write-Host "Update users in distribution group $($ADGroup.Name)."       
        $Member = Validate-ADUserForDistributionGroups ($Config.AddGroups | %{Get-ADGroupMember -Identity $_ -Recursive | Get-ADUser}) -DistributionGroupName $ADGroup.Name
        if($Member){Sync-ADGroupMember -ADGroup $ADGroup -Member $Member -LogScriptBlock{Write-PPEventLog $Message -Source "Update Distribution Groups" -WriteMessage}}
    }         
    
    if($_.Options -match "AddFromGroups"){
        
        Write-Host "Add users in distribution group $($ADGroup.Name)."       
        $Member = Validate-ADUserForDistributionGroups ($Config.AddGroups | %{Get-ADGroupMember -Identity $_ -Recursive | Get-ADUser}) -DistributionGroupName $ADGroup.Name
        if($Member){Sync-ADGroupMember -OnlyAdd -ADGroup $ADGroup -Member $Member -LogScriptBlock{Write-PPEventLog $Message -Source "Update Distribution Groups" -WriteMessage}}
    }    
}

Write-PPErrorEventLog -Source "Update Distribution Groups" -ClearErrorVariable
