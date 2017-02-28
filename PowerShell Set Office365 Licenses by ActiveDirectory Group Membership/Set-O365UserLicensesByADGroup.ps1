<#
$Metadata = @{
    Title = "Set Office365 Licenses by ActiveDirectory Group Membership"
    Filename = "Set-O365UserLicensesByADGroup.ps1"
    Description = @"
Adding license to a Office365 user as long the user is in the correct ActiveDirectory group
or in the white list, the users is active, the user has a mailbox.
The script will remove inactive licenses or if necessary replace them.
"@
    Tags = "powershell, activedirectory, office365, user, license, activation"
    Project = ""
    Author = "Janik von Rotz"
    AuthorContact = "http://janikvonrotz.ch"
    CreateDate = "2013-08-13"
    LastEditDate = "2014-05-02"
    Url = "https://gist.github.com/janikvonrotz/6218401"
    Version = "3.5.0"
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
    $UsageLocation = "CH"

    <#
    Name: name of the license configuration, has to be unique
    ADGroupSID: Active Directory group containing the users to apply a license
    Users: for office 365 only users or selected domain users
    License: Office 365 license type
    DisabledPlans: Plans to disable
    Priority: if a user is in both groups the license with the higher priority will be applied
    SecondaryLicenses: in case the license is not available but another is also pssible to add you can add the name of this license configuration here
    Count: counting the number of licenses
    #>

    $LicenseConfig = $(New-Object PSObject -Property @{
        Name = "SharePoint Online Plan 1"
        License = "vbluzern:SHAREPOINTSTANDARD"
        ADGroupSID = "S-1-5-21-1744926098-708661255-2033415169-37562" # SPO_SharePointOnlinePlan1License
        Priority = 3
        SecondaryLicense = "Enterprise Plan 1 - SharePoint Only"
    }), 
    $(New-Object PSObject -Property @{
        Name = "Enterprise Plan 1"
        License = "vbluzern:STANDARDPACK"
        ADGroupSID = "S-1-5-21-1744926098-708661255-2033415169-36657" # SPO_365E1License
        Priority = 2  
    }),
    $(New-Object PSObject -Property @{
        Name = "Enterprise Plan 1 - SharePoint Only"
        License = "vbluzern:STANDARDPACK"
        DisabledPlans = "EXCHANGE_S_STANDARD"
    }),
    $(New-Object PSObject -Property @{
        Name = "Enterprise Plan 1 - O365 users only"
        Users = "admin@vbluzern.onmicrosoft.com"
        License = "vbluzern:STANDARDPACK"
    }),
    $(New-Object PSObject -Property @{
        Name = "SharePoint Online Plan 1 - O365 users only"
        Users = "urs.egli@vbluzern.onmicrosoft.com","innotix@vbluzern.onmicrosoft.com"
        License = "vbluzern:SHAREPOINTSTANDARD"
    })

    #--------------------------------------------------#
    # modules
    #--------------------------------------------------#
    Import-Module MSOnline
    Import-Module MSOnlineExtended
    Import-Module ActiveDirectory

    #--------------------------------------------------#
    # main
    #--------------------------------------------------#
    $Credential = Import-PSCredential $(Get-ChildItem -Path $PSconfigs.Path -Filter "Office365.credentials.config.xml" -Recurse).FullName
    Connect-MsolService -Credential $Credential

    # normalize license config
    $LicenseAndUser = $LicenseConfig | select @{L="Name";E={$_.Name}}, 
        @{L="UserPrincipalName"; E={$_.UserPrincipalName}},
        @{L="ADGroupSID";E={$_.ADGroupSID}},
        @{L="Users";E={$_.Users}},
        @{L="License";E={$_.License}},
        @{L="DisabledPlans";E={if($_.DisabledPlans){$_.DisabledPlans = New-MsolLicenseOptions -AccountSkuId $_.License -DisabledPlans $_.DisabledPlans}}},
        @{L="Priority";E={$_.Priority}},
        @{L="SecondaryLicense";E={$_.SecondaryLicense}}

    # extend the secondary license field with the normalized object
    $LicenseAndUser = $LicenseAndUser | Foreach-Object{
        New-TreeObjectArray -Array $LicenseAndUser -Objects $_ -Attribute "SecondaryLicense" -Filter "Name"
    }

    # get userprincipalnames of the ad group members 
    $LicenseAndUser = $LicenseAndUser | Foreach-Object{   

        if($_.ADGroupSID){

            $License = $_

            Get-ADGroupMember $_.ADGroupSID -Recursive | Get-ADUser | where{$_.Enabled -eq $true} | Foreach-Object{
            
                $UserLicense = $License.psobject.Copy()
                $UserLicense.UserPrincipalName = $_.UserPrincipalName
                $UserLicense
            }
        }

        if($_.Users){

            $License = $_

            $_.Users | Foreach-Object{

                $UserLicense = $License.psobject.Copy()
                $UserLicense.UserPrincipalName  = $_
                $UserLicense
            }
        }
    }

    $Report = @()
    function New-ReportItem{

        param(
            $User,
            $License,
            $Status # NoChanges, NotAllowed, LicenseAssigned, SecondaryLicenseAssigned, UnableToAssignLicense, LicenseRemoved, UnableToRemoveLicense, LicenseReplaced, UnableToReplaceLicense
        )

        
        Return $(New-Object PSObject -Property @{
            User = $User
            License = $License
            Status = $Status
        })

    }
    
    $MsolUsers = Get-MsolUser -All
    $MsolUsers | Foreach-Object{

        $User = $_

        # debug a user, set debugger on $true variable
        if($User.UserPrincipalName -eq ""){
        $true}

        # get license configuration for this user
        $Config = $LicenseAndUser | where{$_.UserPrincipalName -eq $User.UserPrincipalName}

        # check the license configuration with the higher priority
        if($Config.count -gt 1){
            $Config = $Config | sort Priority | select -First 1
        }

        # apply the license

        if($Config){
        
            # licenses are not same

            if($User.IsLicensed -and ($User.Licenses.AccountSkuId -ne $Config.License)){

                # remove license    
                $User.Licenses | Foreach-Object{ 
                
                    $License = $_               
                    
                    try{
                        Set-MsolUserLicense -UserPrincipalName $User.UserPrincipalName -RemoveLicenses $License.AccountSkuId -ErrorAction Stop                        
                    }catch{
                        Write-PPErrorEventLog -Message "Could not remove license: $($License.AccountSkuId) to user: $($User.UserPrincipalName)" -Source "Office365 License Management" -ClearErrorVariable                   
                    }
                }

                # Assign license
                try{
                    Set-MsolUserLicense -UserPrincipalName $User.UserPrincipalName -AddLicenses $Config.License -LicenseOptions $Config.DisabledPlans -ErrorAction Stop
                    Write-PPEventLog "Replacee Office365 license: $($User.Licenses.AccountSkuId) with: $($Config.License) for user: $($User.UserPrincipalName)" -Source "Office365 License Management" -WriteMessage
                    $Report += New-ReportItem -User $User.UserPrincipalName -License $Config.License -Status "LicenseReplaced"
                }catch{
                    Write-PPErrorEventLog -Message "Could not assign license: $($Config.License) to user: $($User.UserPrincipalName)" -Source "Office365 License Management" -ClearErrorVariable
                    $Report += New-ReportItem -User $User.UserPrincipalName -License $Config.License -Status "UnableToReplaceLicense"
                }
    
            # correct license already applied

            }elseif($User.IsLicensed){

                Write-Host "User: $($User.UserPrincipalName) is already licensed with: $($Config.License)"
                $Report += New-ReportItem -User $User.UserPrincipalName -License $Config.License -Status "NoChanges"

            # apply a license

            }else{
                
                # set location in order to apply a license               
                Set-MsolUser -UserPrincipalName $User.UserPrincipalName -UsageLocation $UsageLocation

                # apply license
                try{
                    Set-MsolUserLicense -UserPrincipalName $User.UserPrincipalName -AddLicenses $Config.License -LicenseOptions $Config.DisabledPlans -ErrorAction Stop
                    Write-PPEventLog "Set Office365 license: $($Config.License) for user: $($User.UserPrincipalName)" -Source "Office365 License Management" -WriteMessage
                    $Report += New-ReportItem -User $User.UserPrincipalName -License $Config.License -Status "LicenseAssigned"
                }catch{
                    Write-PPErrorEventLog -Message "Could not assign license: $($Config.License) to user: $($User.UserPrincipalName)" -Source "Office365 License Management" -ClearErrorVariable
                    $Report += New-ReportItem -User $User.UserPrincipalName -License $Config.License -Status "UnableToAssignLicense"
                }
            }

        # ignore the user or remove the license

        }else{

            # remove the license

            if($User.IsLicensed){
                            
                $User.Licenses | Foreach-Object{
                
                    $License = $_

                    try{
                        Set-MsolUserLicense -UserPrincipalName $User.UserPrincipalName -RemoveLicenses $License.AccountSkuId
                        Write-PPEventLog "Removed Office365 license: $($License.AccountSkuId) from user: $($User.UserPrincipalName)" -Source "Office365 License Management" -WriteMessage
                        $Report += New-ReportItem -User $User.UserPrincipalName -License $License.AccountSkuId -Status "LicenseRemoved"
                    }catch{
                        Write-PPErrorEventLog -Message "Could not remove license: $($License.AccountSkuId) to user: $($User.UserPrincipalName)" -Source "Office365 License Management" -ClearErrorVariable
                        $Report += New-ReportItem -User $User.UserPrincipalName -License $License.AccountSkuId -Status "UnableToRemoveLicense"
                    }
                    
                }

            # ignore the user

            }else{

                Write-Host "User: $($User.UserPrincipalName) is not allowed"
                $Report += New-ReportItem -User $User.UserPrincipalName -Status "NotAllowed"
            }
        }
    }

    $Report | Group-Object Status

}catch{
    
    Write-PPErrorEventLog -Source "Office365 License Management" -ClearErrorVariable -Message
}