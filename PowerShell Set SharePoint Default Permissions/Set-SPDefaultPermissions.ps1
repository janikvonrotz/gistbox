<#
$Metadata = @{
	Title = "SharePoint Default Settings"
	Filename = "Set-SPDefaultSettings.ps1"
	Description = ""
	Tags = "powershell, script, sharepoint, default settings"
	Project = ""
	Author = "Janik von Rotz"
	AuthorContact = "http://www.janikvonrotz.ch"
	CreateDate = "2013-05-07"
	LastEditDate = "2014-03-26"
	Version = "2.5.0"
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
    if((Get-PSSnapin "Microsoft.SharePoint.PowerShell" -ErrorAction SilentlyContinue) -eq $null){Add-PSSnapin "Microsoft.SharePoint.PowerShell"}
    Import-Module ActiveDirectory
    
    #--------------------------------------------------#
    # settings
    #--------------------------------------------------#
    
    $Configuration = @{
        SPSite = "http://sharepoint.vbl.ch"
        SPADGroupFilter = "SP_*"
        SPADGroupContainer = "OU=SharePoint,OU=Services,OU=vblusers2,DC=vbl,DC=ch"
        SPNavigationWebExclude = "http://sharepoint.vbl.ch/Projekte"
        AllowedVersioningTypes = "Unternehmenswiki-Seite","Dokument","Wiki-Seite"
        DisabledVersioningTypes = "Survey"
    },
    @{
        SPSite = "http://sharepoint.vbl.ch/itwiki"
        SPADGroupFilter = "SP_*"
        SPADGroupContainer = "OU=SharePoint,OU=Services,OU=vblusers2,DC=vbl,DC=ch"
        AllowedVersioningTypes = "Unternehmenswiki-Seite","Dokument","Wiki-Seite"
        DisabledVersioningTypes = "Survey"
    },
    @{
        SPSite = "http://extranetvr.vbl.ch"
        SPADGroupFilter = "SP2_*"
        SPADGroupContainer = "OU=SharePoint,OU=Services,OU=vblusers2,DC=vbl,DC=ch"
        AllowedVersioningTypes = "Unternehmenswiki-Seite","Dokument","Wiki-Seite"
        DisabledVersioningBaseTypes = "Survey"
    }

    $Configuration | ForEach-Object{

        # get domain
        $ADDomain = ((Get-ADDomain).Name).ToUpper()
    
        # Update displayname on adgroups
        $Config = $_
   
        # SharePoint AD Groups 
        $ADGroups = Get-ADGroup -Filter * -SearchBase $_.SPADGroupContainer | Where-Object{$_.Name -like $Config.SPADGroupFilter}
            
        Get-SPUser -Limit All -Web $_.SPSite | Where-Object{$_.IsDomainGroup -and $_.Name -like "$($ADDomain)\$Config.SPADGroupFilter"} | ForEach-Object{
                
            $SPUser = $_
                    
            $ADGroups | Where-Object{
                
                # without claims
                (($_.SID -eq $SPUser.Sid) -or 
                                
                # claims
                ($SPUser.LoginName -like "*$($_.SID)")) -and 

                # check name
                ("$ADDomain\$(($_.Name).ToLower())" -ne $SPUser.Name.ToLower())} | ForEach-Object{
            
                Write-PPEventLog -Message "Change Displayname for SPGroup: $($SPUser.Name) to: " + "$ADDomain\$(($_.Name).ToLower())" -Source "SharePoint Default Settings" -WriteMessage        
                Set-SPUser $SPUser -DisplayName "$ADDomain\$(($_.Name).ToLower())"
            } 
        }        
    
        Get-SPSite | where{$_.Url -eq $Config.SPSite} | Get-SPWeb -Limit All  | ForEach-Object{

            # update navigation inheritance except for excluded sites
    	    if(
            ($_.Url).startsWith($Config.SPSite) -and     
            ($_.Url -ne $Config.SPSite) -and    
            ($Config.SPNavigationWebExclude -notcontains $_.Url)
            ){            
    		    $SPPublishingWeb = [Microsoft.SharePoint.Publishing.PublishingWeb]::GetPublishingWeb($_)
    		    $SPPublishingWeb.Navigation.InheritGlobal = $true
    		    $SPPublishingWeb.Navigation.GlobalIncludeSubSites = $true
    		    $SPPublishingWeb.Update()
            }
        
            # update Site Logo
            $_.SiteLogoUrl = $(Get-SPWeb $Config.SPSite).SiteLogoUrl
            $_.Update()
        
            # Enable versioning on lists
            $_.Lists | Where-Object{ $Config.DisabledVersioningBaseTypes -notcontains $_.basetype} | ForEach-Object{
            
                # get content types foreach list
                $Types = $_.ContentTypes | %{$_.Name}
            
                # enable versionging for document libraries and wiki sites
                if(($Types | where{$Config.AllowedVersioningTypes -contains $_}) -and ($_.EnableVersioning -eq $false)){
            
                    Write-PPEventLog -Message "Enable Versioning for: $($_.title) on: $($_.parentweb.title)." -Source "SharePoint Default Settings" -WriteMessage
                        
                    $_.EnableVersioning = $true
                    $_.MajorVersionLimit = 10   
                    $_.Update()   
                
                # disable versioning fore everything else
                }elseif(($_.EnableVersioning -eq $true) -and -not ($Types | where{$Config.AllowedVersioningTypes -contains $_})){
            
                    Write-PPEventLog -Message "Disable Versioning for: $($_.title) on: $($_.parentweb.title)." -Source "SharePoint Default Settings" -WriteMessage
            
                    $_.EnableVersioning = $false       
                    $_.Update()
                }
            }
        }  
    }
}catch{

    Write-PPErrorEventLog -Source "SharePoint Default Settings" -ClearErrorVariable
}
