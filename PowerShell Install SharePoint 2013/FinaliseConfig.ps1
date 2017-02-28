#Mit Hilfe von diesem Script kann die SharePoint Konfiguration abgeschlossen werden
#Alle Punkte welche benötigt werden, selectiv ausführen

#Start Schritt 1
$snapin = Get-PSSnapin Microsoft.SharePoint.Powershell -ErrorVariable err -ErrorAction SilentlyContinue
if($snapin -eq $null){
Add-PSSnapin Microsoft.SharePoint.Powershell 
}
#Stop Schritt 1

#Berechtigungen setzen, damit alle Services richtig funktionieren
#----------------------------------------------------------------

#Berechtigung für Work Management Service
$WebApp = Get-SPWebApplication -Identity https://mysite.xyz.ch #MySite ULR
$WebApp.GrantAccessToProcessIdentity("DOMAIN\sa-spservices")

#Berechtigung für Visio und Excel Services
$WebApp = Get-SPWebApplication -Identity https://abc.xyz.ch #Intranet oder andere WebApp
$WebApp.GrantAccessToProcessIdentity("DOMAIN\sa-spservices")

#Berechtigung für MySite Newsfeed
$WebApp = Get-SPWebApplication -Identity https://mysite.xyz.ch #MySite ULR
$WebApp.GrantAccessToProcessIdentity("DOMAIN\sa-spintranet") #Service Account von Intranet oder anderer WebApp
$WebApp = Get-SPWebApplication -Identity https://abc.xyz.ch #Intranet oder andere WebApp
$WebApp.GrantAccessToProcessIdentity("DOMAIN\sa-spmysite") #Service Account von MySite


#Berechtingen setzen für HeatingUpScript (SharePointWarmUpHelper)
#----------------------------------------------------------------

#Set the HeatingUpScript Account to one WebApps
$userOrGroup = "DOMAIN\sa-spadmin" #Entsprechender Service Account, unter welchem das HeatingUpScript ausgeführt wird
$displayName = "HeatingUpScript Account" 

$webApp = Get-SPWebApplication -Identity "https://abc.xyz.ch"
$policy = $webApp.Policies.Add($userOrGroup, $displayName) 
$policyRole = $webApp.PolicyRoles.GetSpecialRole([Microsoft.SharePoint.Administration.SPPolicyRoleType]::FullRead) 
$policy.PolicyRoleBindings.Add($policyRole) 
$webApp.Update() 

#For all WebApps
$userOrGroup = "DOMAIN\sa-spadmin" #Entsprechender Service Account, unter welchem das HeatingUpScript ausgeführt wird
$displayName = "HeatingUpScript Account" 
Get-SPWebApplication | foreach { 
    $webApp = $_ 
    $policy = $webApp.Policies.Add($userOrGroup, $displayName) 
    $policyRole = $webApp.PolicyRoles.GetSpecialRole([Microsoft.SharePoint.Administration.SPPolicyRoleType]::FullControl) 
    $policy.PolicyRoleBindings.Add($policyRole) 
    $webApp.Update() 
}


#Berechtigung für Publishing Feater auf WebApp setzen (dies wird nur für SharePoint Server Standard/Enterprise benötigt)
#-----------------------------------------------------------------------------------------------------------------------

#Set the CacheSuperReader Account to one WebApps
$userOrGroup = "DOMAIN\SP_CacheSuperReader"
$displayName = "CacheSuperReader" 

$webApp = Get-SPWebApplication -Identity "https://abc.xyz.ch"
$policy = $webApp.Policies.Add($userOrGroup, $displayName) 
$policyRole = $webApp.PolicyRoles.GetSpecialRole([Microsoft.SharePoint.Administration.SPPolicyRoleType]::FullRead) 
$policy.PolicyRoleBindings.Add($policyRole) 
$webApp.Update()

#Set the CacheSuperUser Account to one WebApps
$userOrGroup = "DOMAIN\SP_CacheSuperUser"
$displayName = "CacheSuperUser" 

$webApp = Get-SPWebApplication -Identity "https://abc.xyz.ch"
$policy = $webApp.Policies.Add($userOrGroup, $displayName) 
$policyRole = $webApp.PolicyRoles.GetSpecialRole([Microsoft.SharePoint.Administration.SPPolicyRoleType]::FullControl) 
$policy.PolicyRoleBindings.Add($policyRole) 
$webApp.Update()


#Allow PDF to open direct in Browser (Permissive) inkl. RecycleBin auf 40 Tage setzen
#------------------------------------------------------------------------------------
$webapps = Get-SPWebApplication
foreach ($webapp in $webapps) 
{ 
    $webapp.AllowedInlineDownloadedMimeTypes.Add("application/pdf") 
    $webapp.RecycleBinRetentionPeriod = 40
    $webapp.Update() 
}


#Healt Roles Disablen
#--------------------
#The server farm account should not be used for other services
Disable-SPHealthAnalysisRule -Identity 'FarmAccountIsSharedWithUserServices' -Confirm:$false
#Databases exist on servers running SharePoint Foundation
Disable-SPHealthAnalysisRule -Identity 'DatabasesAreOnAppServers' -Confirm:$false
#Database has large amounts of unused space
Disable-SPHealthAnalysisRule -Identity 'DatabaseCanBeShrinked' -Confirm:$false
#Built-in accounts are used as application pool or service identities
Disable-SPHealthAnalysisRule -Identity 'BuiltInAccountsUsedAsProcessIdentities' -Confirm:$false
#Accounts used by application pools or services identities are in the local ma-chine Administrators group
Disable-SPHealthAnalysisRule -Identity 'AdminAccountsUsedAsProcessIdentities' -Confirm:$false
#Drives are at risk of running out of free space. 
Disable-SPHealthAnalysisRule -Identity 'AppServerDrivesAreNearlyFullWarning' -Confirm:$false

Get-SPHealthAnalysisRule | where {!$_.Enabled} | select Summary


#Set Log Settings
#----------------
Set-SPLogLevel -TraceSeverity Unexpected
Set-SPLogLevel -EventSeverity ErrorCritical
Set-SPDiagnosticConfig -LogLocation "D:\Microsoft Office Servers\15.0\Logs" 
Set-SPDiagnosticConfig -LogMaxDiskSpaceUsageEnabled
Set-SPDiagnosticConfig -LogDiskSpaceUsageGB 1


# Minimal Download Strategy (MDS) Für alle Sites in allen WebApplications deaktivieren
#----------------------------------------
$snapin = Get-PSSnapin Microsoft.SharePoint.Powershell -ErrorVariable err -ErrorAction SilentlyContinue
if($snapin -eq $null){
Add-PSSnapin Microsoft.SharePoint.Powershell 
}
# Get All Web Applications
$WebApps=Get-SPWebApplication
foreach($webApp in $WebApps)
{
    foreach ($SPsite in $webApp.Sites)
    {
       # get the collection of webs
       foreach($SPweb in $SPsite.AllWebs)
        {
        $feature = Get-SPFeature -Web $SPweb | Where-Object {$_.DisplayName -eq "MDSFeature"}
        if ($feature -eq $null)
            {
                Write-Host -ForegroundColor Yellow 'MDS already disabled on site : ' $SPweb.title ":" $spweb.URL;
            }
        else
            {
                Write-Host -ForegroundColor Green 'Disable MDS on site : ' $SPweb.title ":" $spweb.URL;
                Disable-SPFeature MDSFeature -url $spweb.URL -Confirm:$false
            }
        }
    }
}


#Office Web Apps Bindings
#------------------------
New-SPWOPIBinding –ServerName officewebapps.xyz.ch
Set-SPWopiZone –Zone “internal-https”


#Neue WebApp inkl. Extend
#------------------------

#New WebApp (with HostHeader)
$webappname = "SP_XYZ"
$webappaccount = "DOMAIN\sa-spxyz" #have to be managed account
$spadmin = "DOMAIN\sa-spadmin"
$webappport = "443"
$webappurl = "https://abc.xyz.ch"
$hostheader = "abc.xyz.ch"
$webSitePfad = "D:\wea\webs\SP_XYZ"
$dbserver = "SQLALIAS"
$webappdbname = "SP_Content_XYZ"
$ap = New-SPAuthenticationProvider
$rootsitename = "XYZ"
$templatename = "STS#0" #Team Site
$lcid = "1031" # 1031 Deutsch; 1033 English; 1036 French; 1040 Italian

New-SPWebApplication -Name $webappname -SecureSocketsLayer -ApplicationPool $webappname -ApplicationPoolAccount (Get-SPManagedAccount $webappaccount) -Port $webappport -Url $webappurl -Path $webSitePfad  -DatabaseServer $dbserver -DatabaseName $webappdbname -AuthenticationProvider $ap -HostHeader $hostheader -Verbose
New-SPSite -url $webappurl -OwnerAlias $webappaccount -SecondaryOwnerAlias $spadmin -Name $rootsitename -Template $templatename -language $lcid | Out-Null
Start-Process "$webappurl" -WindowStyle Minimized

#Extend WebApp
$webappurl = "https://abc.xyz.ch"
$ExtendName = "SP_XYZ_80"
$ExtendPath = "D:\wea\webs\SP_XYZ_80"
$Extendhostheader = "abc.xyz.ch"
$ExtendZone = "Intranet"
$ExtendURL = "http://abc.xyz.ch"
$ExtPort = "80"
$ntlm = New-SPAuthenticationProvider -UseWindowsIntegratedAuthentication -DisableKerberos 
Get-SPWebApplication -Identity $webappurl | New-SPWebApplicationExtension -Name $ExtendName  -Zone $ExtendZone -URL $ExtendURL -Port $ExtPort -AuthenticationProvider $ntlm -Verbose -Path $ExtendPath -HostHeader $Extendhostheader


#Neue WebApp für MySite
#------------------------

#New WebApp (with HostHeader)
$webappname = "SP_MySite"
$webappaccount = "DOMAIN\sa-spmysite" #have to be managed account
$spadmin = "DOMAIN\sa-spadmin"
$webappport = "443"
$webappurl = "https://mysite.xyz.ch"
$hostheader = "mysite.xyz.ch"
$webSitePfad = "D:\wea\webs\SP_MySite"
$dbserver = "SQLALIAS"
$webappdbname = "SP_Content_MySite"
$ap = New-SPAuthenticationProvider
$rootsitename = "MySite Host"
$templatename = "SPSMSITEHOST#0" #Team Site
$lcid = "1031" # 1031 Deutsch; 1033 English; 1036 French; 1040 Italian

New-SPWebApplication -Name $webappname -SecureSocketsLayer -ApplicationPool $webappname -ApplicationPoolAccount (Get-SPManagedAccount $webappaccount) -Port $webappport -Url $webappurl -Path $webSitePfad  -DatabaseServer $dbserver -DatabaseName $webappdbname -AuthenticationProvider $ap -HostHeader $hostheader -Verbose
New-SPSite -url $webappurl -OwnerAlias $webappaccount -SecondaryOwnerAlias $spadmin -Name $rootsitename -Template $templatename -language $lcid | Out-Null
Start-Process "$webappurl" -WindowStyle Minimized

#Extend WebApp
$webappurl = "https://mysite.xyz.ch"
$ExtendName = "SP_MySite_80"
$ExtendPath = "D:\wea\webs\SP_MySite_80"
$Extendhostheader = "mysite.xyz.ch"
$ExtendZone = "Intranet"
$ExtendURL = "http://mysite.xyz.ch"
$ExtPort = "80"
$ntlm = New-SPAuthenticationProvider -UseWindowsIntegratedAuthentication -DisableKerberos 
Get-SPWebApplication -Identity $webappurl | New-SPWebApplicationExtension -Name $ExtendName  -Zone $ExtendZone -URL $ExtendURL -Port $ExtPort -AuthenticationProvider $ntlm -Verbose -Path $ExtendPath -HostHeader $Extendhostheader


#Set Content DB Limits
#---------------------
$dbs = Get-SPContentDatabase | where{$_.Name -ne "SP_Content_XYZ"}
foreach ($db in $dbs) {
    $db.MaximumSiteCount = 1
    $db.WarningSiteCount = 0
    $db.Update()
}


#Business Data Connectivity Service (BDC) Anpassungen
#----------------------------------------------------

#BDC - Enable revert to self
#Damit wird mit dem Service Account von der entsprechenden WebApp auf die Dritt-DB zugegriffen 
$bdc = Get-SPServiceApplication | where {$_ -match “Business Data Connectivity”};
$bdc.RevertToSelfAllowed = $true;
$bdc.Update();  


#Nach SharePoint Update werden folgende DB's nicht aktualisiert
#Mit folgendem Befehl können die DB's aktualisiert werden
#--------------------------------------------------------------- 

#BDC DB Update
(Get-SPDatabase | ?{$_.type -eq "Microsoft.SharePoint.BusinessData.SharedService.BdcServiceDatabase"}).Provision() 

#Secure Store DB Update
$db = (Get-SPDatabase | ?{$_.type -eq "Microsoft.Office.SecureStoreService.Server.SecureStoreServiceDatabase"}).Provision() 
$db.NeedsUpgrade


#Distributed Cache
#-----------------

#Check Cache Cluster Health
Use-CacheCluster
Get-CacheClusterHealth
Get-CacheHost

#Manueller Neustart vom Distributed Cache
Restart-CacheCluster