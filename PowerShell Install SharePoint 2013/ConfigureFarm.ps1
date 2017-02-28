#Start Schritt 1
$snapin = Get-PSSnapin Microsoft.SharePoint.Powershell -ErrorVariable err -ErrorAction SilentlyContinue
if($snapin -eq $null){
Add-PSSnapin Microsoft.SharePoint.Powershell 
}

function Write-Info([string]$msg){
    Write-Host "$($global:indent)[$([System.DateTime]::Now)] $msg"
}

function Get-ConfigurationSettings() {
    Write-Info "Loading configuration file."
    [xml]$config = Get-Content .\Configurations.xml

    if ($? -eq $false) {
        Write-Info "Cannot load configuration source XML $config."
        return $null
    }
    return $config.Configurations
}

function Trace([string]$desc, $code) {
    trap {
        Write-Error $_.Exception
        if ($_.Exception.InnerException -ne $null) {
            Write-Error "Inner Exception: $($_.Exception.InnerException)"
        }
        break
    }
    $desc = $desc.TrimEnd(".")
    Write-Info "BEGIN: $desc..."
    Set-Indent 1
    &$code
    Set-Indent -1
    Write-Info "END: $desc."
}

function Set-Indent([int]$incrementLevel)
{
    if ($incrementLevel -eq 0) {$global:indent = ""; return}
    
    if ($incrementLevel -gt 0) {
        for ($i = 0; $i -lt $incrementLevel; $i++) {
            $global:indent = "$($global:indent)`t"
        }
    } else {
        if (($global:indent).Length + $incrementLevel -ge 0) {
            $global:indent = ($global:indent).Remove(($global:indent).Length + $incrementLevel, -$incrementLevel)
        } else {
            $global:indent = ""
        }
    }
}

#Region Security-Related
# ====================================================================================
# Func: Get-AdministratorsGroup
# Desc: Returns the actual (localized) name of the built-in Administrators group
# From: Proposed by Codeplex user Sheppounet at http://autospinstaller.codeplex.com/discussions/265749
# ====================================================================================
Function Get-AdministratorsGroup
{
    If(!$builtinAdminGroup)
    {
        $builtinAdminGroup = (Get-WmiObject -Class Win32_Group -computername $env:COMPUTERNAME -Filter "SID='S-1-5-32-544' AND LocalAccount='True'" -errorAction "Stop").Name
    }
    Return $builtinAdminGroup
}

#Region Add Managed Accounts
# ===================================================================================
# FUNC: AddManagedAccounts
# DESC: Adds existing accounts to SharePoint managed accounts and creates local profiles for each
# TODO: Make this more robust, prompt for blank values etc.
# ===================================================================================
Function AddManagedAccounts([System.Xml.XmlElement]$xmlinput)
{
    #WriteLine
    Write-Host -ForegroundColor White " - Adding Managed Accounts"
    If ($xmlinput.Accounts)
    {
        # Get the members of the local Administrators group
        $builtinAdminGroup = Get-AdministratorsGroup
        $adminGroup = ([ADSI]"WinNT://$env:COMPUTERNAME/$builtinAdminGroup,group")
        # This syntax comes from Ying Li (http://myitforum.com/cs2/blogs/yli628/archive/2007/08/30/powershell-script-to-add-remove-a-domain-user-to-the-local-administrators-group-on-a-remote-machine.aspx)
        $localAdmins = $adminGroup.psbase.invoke("Members") | ForEach-Object {$_.GetType().InvokeMember("Name", 'GetProperty', $null, $_, $null)}
        # Ensure Secondary Logon service is enabled and started
        If (!((Get-Service -Name seclogon).Status -eq "Running"))
        {
            Write-Host -ForegroundColor White " - Enabling Secondary Logon service..."
            Set-Service -Name seclogon -StartupType Manual
            Write-Host -ForegroundColor White " - Starting Secondary Logon service..."
            Start-Service -Name seclogon
        }

        ForEach ($account in $xmlinput.Accounts.Account)
        {
            $username = $account.name
            $password = $account.Password
            $password = ConvertTo-SecureString "$password" -AsPlaintext -Force
            # The following was suggested by Matthias Einig (http://www.codeplex.com/site/users/view/matein78)
            # And inspired by http://todd-carter.com/post/2010/05/03/Give-your-Application-Pool-Accounts-A-Profile.aspx & http://blog.brainlitter.com/archive/2010/06/08/how-to-revolve-event-id-1511-windows-cannot-find-the-local-profile-on-windows-server-2008.aspx
            Try
            {
                Write-Host -ForegroundColor White " - Creating local profile for $username..." -NoNewline
                $credAccount = New-Object System.Management.Automation.PsCredential $username,$password
                $managedAccountDomain,$managedAccountUser = $username -Split "\\"
                # Add managed account to local admins (very) temporarily so it can log in and create its profile
                If (!($localAdmins -contains $managedAccountUser))
                {
                    $builtinAdminGroup = Get-AdministratorsGroup
                    ([ADSI]"WinNT://$env:COMPUTERNAME/$builtinAdminGroup,group").Add("WinNT://$managedAccountDomain/$managedAccountUser")
                }
                Else
                {
                    $alreadyAdmin = $true
                }
                # Spawn a command window using the managed account's credentials, create the profile, and exit immediately
                Start-Process -WorkingDirectory "$env:SYSTEMROOT\System32\" -FilePath "cmd.exe" -ArgumentList "/C" -LoadUserProfile -NoNewWindow -Credential $credAccount
                # Remove managed account from local admins unless it was already there
                $builtinAdminGroup = Get-AdministratorsGroup
                If (-not $alreadyAdmin) {([ADSI]"WinNT://$env:COMPUTERNAME/$builtinAdminGroup,group").Remove("WinNT://$managedAccountDomain/$managedAccountUser")}
                Write-Host -BackgroundColor Blue -ForegroundColor Black "Done."
            }
            Catch
            {
                $_
                Write-Host -ForegroundColor White "."
                Write-Warning "Could not create local user profile for $username"
                break
            }
            $managedAccount = Get-SPManagedAccount | Where-Object {$_.UserName -eq $username}
            If ($managedAccount -eq $null)
            {
                Write-Host -ForegroundColor White " - Registering managed account $username..."
                If ($username -eq $null -or $password -eq $null)
                {
                    Write-Host -BackgroundColor Gray -ForegroundColor DarkBlue " - Prompting for Account: "
                    $credAccount = $host.ui.PromptForCredential("Managed Account", "Enter Account Credentials:", "", "NetBiosUserName" )
                }
                Else
                {
                    $credAccount = New-Object System.Management.Automation.PsCredential $username,$password
                }
                New-SPManagedAccount -Credential $credAccount | Out-Null
                If (-not $?) { Throw " - Failed to create managed account" }
            }
            Else
            {
                Write-Host -ForegroundColor White " - Managed account $username already exists."
            }
        }
    }
    Write-Host -ForegroundColor White " - Done Adding Managed Accounts"
    #WriteLine
}
#EndRegion

function Get-Account([System.Xml.XmlElement]$accountNode){
    while (![string]::IsNullOrEmpty($accountNode.Ref)) {
        $accountNode = $accountNode.PSBase.OwnerDocument.SelectSingleNode("//Accounts/Account[@ID='$($accountNode.Ref)']")
    }

    if ($accountNode.Password.Length -gt 0) {
        $accountCred = New-Object System.Management.Automation.PSCredential $accountNode.Name, (ConvertTo-SecureString $accountNode.Password -AsPlainText -force)
    } else {
        Write-Info "Please specify the credentials for" $accountNode.Name
        $accountCred = Get-Credential $accountNode.Name
    }
    return $accountCred    
}
 
function Get-InstallOnCurrentServer([System.Xml.XmlElement]$node) 
{
    if ($node -eq $null -or $node.Server -eq $null) {
        return $false
    }
    $dbserver = $node.Server | where { (Get-ServerName $_).ToLower() -eq $env:ComputerName.ToLower() }
    if ($dbserver -eq $null -or $dbserver.Count -eq 0) {
        return $false
    }
    return $true
}

function Get-ServerName([System.Xml.XmlElement]$node)
{
    while (![string]::IsNullOrEmpty($node.Ref)) {
        $node = $node.PSBase.OwnerDocument.SelectSingleNode("//Servers/Server[@ID='$($node.Ref)']")
    }
    if ($node -eq $null -or $node.Name -eq $null) { throw "Unable to locate server name!" }
    return $node.Name
}

[System.Xml.XmlElement]$config = Get-ConfigurationSettings

if ($config -eq $null) {
    return $false
}

#Variabeln
$dbserver = $config.Farm.DatabaseServer

AddManagedAccounts $config
#Stop Schritt 1

#Start Schritt 2
Trace "Configure WebApplication" {  
	foreach($item in $config.WebApplications.WebApplication){
		$webappname=$item.Name
	 	$webappport=$item.Port
        $rootsitename=$item.RootSiteName
        $webSitePfad=$item.WebSitePath + $webappname
        $webappdbname=$item.WebAppDBName
		$webappurl=$item.url
		$webappaccount=Get-Account($item.Account)
		$email = $config.email
		$lcid=$item.language
        $secondaryAdmin=$item.SecondaryAdmin
        $ap = New-SPAuthenticationProvider

		#New-SPManagedAccount -Credential $webappaccount
		
		if($webappport -eq "443"){
		   New-SPWebApplication -Name $webappname -SecureSocketsLayer -ApplicationPool $webappname -ApplicationPoolAccount (Get-SPManagedAccount $webappaccount.UserName) -Port $webappport -Url $webappurl -Path $webSitePfad  -DatabaseServer $dbserver -DatabaseName $webappdbname -AuthenticationProvider $ap | Out-Null
		   New-SPSite -url $webappurl -OwnerAlias $webappaccount.UserName -SecondaryOwnerAlias $secondaryAdmin -Name $rootsitename -OwnerEmail $email -Template "STS#0" -language $lcid | Out-Null
           Write-Host -ForegroundColor Yellow "Bind the coresponding SSL Certificate to the IIS WebSite"
           Start-Process "$webappurl" -WindowStyle Minimized
		}else{
	  	   New-SPWebApplication -Name $webappname -ApplicationPool $webappname -ApplicationPoolAccount (Get-SPManagedAccount $webappaccount.UserName) -Port $webappport -Url $webappurl -Path $webSitePfad -DatabaseServer $dbserver -DatabaseName $webappdbname -AuthenticationProvider $ap | Out-Null
		   New-SPSite -url $webappurl -OwnerAlias $webappaccount.UserName -SecondaryOwnerAlias $secondaryAdmin -Name $rootsitename -OwnerEmail $email -Template "STS#0" -language $lcid | Out-Null
           Start-Process "$webappurl" -WindowStyle Minimized
		}
   }
}
#Stop Schritt 2

#Start Schritt 3
Trace "Configure UsageApplicationService" { 
	try
	{
		Write-Host -ForegroundColor Yellow "- Creating WSS Usage Application..."
        New-SPUsageApplication -Name "Usage and Health data collection Service" -DatabaseServer $dbserver -DatabaseName $config.Services.UsageApplicationService.collectioDB | Out-Null
        Set-SPUsageService -LoggingEnabled 1 -UsageLogLocation $config.Services.UsageApplicationService.LogPfad
        $ua = Get-SPServiceApplicationProxy | where {$_.DisplayName -eq "Usage and Health data collection Service"}
        $ua.Provision()
	    Write-Host -ForegroundColor Yellow "- Done Creating WSS Usage Application."
	}
	catch
	{	Write-Output $_
	}
}

Trace "Incoming Email disable" {
    $incommingEmail = Get-SPServiceInstance | Where {$_.TypeName -eq "Microsoft SharePoint Foundation Incoming E-Mail"} 
    If ($incommingEmail.Status -eq "Online") 
    {
    	try
    	{
    		Write-Host "- Stoping Microsoft SharePoint Foundation Incoming E-Mail..."
    		$incommingEmail | Stop-SPServiceInstance -Confirm:$false | Out-Null
    		If (-not $?) {throw}
    	}
    	catch {"- Microsoft SharePoint Foundation Incoming E-Mail"}
    }
}

Trace "Microsoft SharePoint Foundation User Code Service" {
    $UserCodeService = Get-SPServiceInstance | Where {$_.TypeName -eq "Microsoft SharePoint Foundation Sandboxed Code Service"} 
    If ($UserCodeService.Status -eq "Disabled") 
    {
    	try
    	{
    		Write-Host "- Starting Microsoft SharePoint Foundation User Code Service..."
    		$UserCodeService | Start-SPServiceInstance | Out-Null
    		If (-not $?) {throw}
    	}
    	catch {"- An error occurred starting the Microsoft SharePoint Foundation User Code Service"}
    }
}

Trace "Configure State Service" { 
	try
	{
        Write-Host -ForegroundColor Yellow "Creating State Service Application..."
        New-SPStateServiceDatabase -name $config.Services.StateService.DBName | Out-Null
        New-SPStateServiceApplication -Name "State Service Application" -Database $config.Services.StateService.DBName  | Out-Null
        Get-SPStateServiceDatabase | Initialize-SPStateServiceDatabase | Out-Null
        Get-SPStateServiceApplication | New-SPStateServiceApplicationProxy -Name "State Service Application Proxy"  -DefaultProxyGroup | Out-Null
	    Write-Host -ForegroundColor Yellow "Done Creating State Service Application."
	}
	catch
	{	Write-Output $_
	}
}

Trace "Configure Search Service Application" { 
	try
	{
        #Get ServerName
        $searchServerName= $config.Servers.Server.Name

        #Create an Empty Direcotry for the Index
        $IndexLocation=$config.Services.EnterpriseSearch.IndexLocation
        New-Item $IndexLocation -type directory
        if(Test-Path $IndexLocation!=true){
            Write-Host -ForegroundColor Yellow "Create an Empty Index Direcotry Index under D:\Microsoft Office Servers\15.0\Data\Office Server\Applications"
            exit
        }        

        #Start earchService and SearchQueryAndSiteSettingsService Instances
        Start-SPEnterpriseSearchServiceInstance $searchServerName
        Start-SPEnterpriseSearchQueryAndSiteSettingsServiceInstance $searchServerName

        sleep 60

		Write-Host -ForegroundColor Yellow "- Creating Search Application Pool"
        $app = Get-SPServiceApplicationPool -Identity $config.Services.EnterpriseSearch.AppPoolName -ErrorVariable err -ErrorAction SilentlyContinue
        if($app.Name -eq $null){
            $appoolname=$config.Services.EnterpriseSearch.AppPoolName
    		$appooluser=Get-Account($config.Services.EnterpriseSearch.Account[0])
            $app = New-SPServiceApplicationPool -name $appoolname -account (Get-SPManagedAccount $appooluser.username) 
        }

        Write-Host -ForegroundColor Yellow "- Creating Search Application"
        $searchapp = New-SPEnterpriseSearchServiceApplication  -name "Search Service Application" -ApplicationPool $app -databaseName  $config.Services.EnterpriseSearch.DBName -DatabaseServer $dbserver
        $proxy = New-SPEnterpriseSearchServiceApplicationProxy -name "Search Service Application Proxy" -SearchApplication "Search Service Application"
        
        #Set Default Crawl Account
        $crawlaccount=Get-Account($config.Services.EnterpriseSearch.Account[1])
        $searchApp | Set-SPEnterpriseSearchServiceApplication -DefaultContentAccessAccountName $crawlaccount.Username -DefaultContentAccessAccountPassword $crawlaccount.Password
        
        #Get Search Instance
        $searchInstance = Get-SPEnterpriseSearchServiceInstance $searchServerName
        
        #Get Serach Topology
        $InitialSearchTopology = $searchapp | Get-SPEnterpriseSearchTopology -Active 

        #New Search Topology
        $SearchTopology = $searchapp | New-SPEnterpriseSearchTopology 

        #Create Administration Component and Processing Component
        New-SPEnterpriseSearchAdminComponent -SearchTopology $SearchTopology -SearchServiceInstance $searchInstance
        New-SPEnterpriseSearchAnalyticsProcessingComponent -SearchTopology $SearchTopology -SearchServiceInstance $searchInstance
        New-SPEnterpriseSearchContentProcessingComponent -SearchTopology $SearchTopology -SearchServiceInstance $searchInstance
        New-SPEnterpriseSearchQueryProcessingComponent -SearchTopology $SearchTopology -SearchServiceInstance $searchInstance

        #New Crawl Component
        New-SPEnterpriseSearchCrawlComponent -SearchTopology $SearchTopology -SearchServiceInstance $searchInstance 

        #Index (Query) Component
        New-SPEnterpriseSearchIndexComponent -SearchTopology $SearchTopology -SearchServiceInstance $searchInstance -RootDirectory $IndexLocation 

        #new Search Topology
        $SearchTopology | Set-SPEnterpriseSearchTopology 
	}
	catch
	{	Write-Output $_
	}
}


Trace "Preconfigure Managet Metadata Service" { 
	try
{

      #App Pool     
      $ApplicationPool = Get-SPServiceApplicationPool $config.Services.ManagedMetadata.AppPoolName -ea SilentlyContinue
      if($ApplicationPool -eq $null)
	  { 
            $appoolname=$config.ServiceAppPool.Name
			$appooluser=Get-Account($config.ServiceAppPool.Account)
            $ApplicationPool = New-SPServiceApplicationPool -name $appoolname -account (Get-SPManagedAccount $appooluser.username) 
      }

      #Create a Metadata Service Application
      if((Get-SPServiceApplication |?{$_.TypeName -eq "Managed Metadata Service"})-eq $null)
	  {      
			Write-Host -ForegroundColor Yellow "- Creating Managed Metadata Service:"
            #Get the service instance
            $MetadataServiceInstance = (Get-SPServiceInstance |?{$_.TypeName -eq "Managed Metadata Web Service"})
            if (-not $?) { throw "- Failed to find Metadata service instance" }

             #Start Service instance
            if($MetadataserviceInstance.Status -eq "Disabled")
			{ 
                  Write-Host -ForegroundColor Yellow " - Starting Metadata Service Instance..."
                  $MetadataServiceInstance | Start-SPServiceInstance | Out-Null
                  if (-not $?) { throw "- Failed to start Metadata service instance" }
            } 

            #Wait
			Write-Host -ForegroundColor Yellow " - Waiting for Metadata service to provision" -NoNewline
			While ($MetadataServiceInstance.Status -ne "Online") 
			{
				Write-Host -ForegroundColor Yellow "." -NoNewline
				sleep 1
				$MetadataServiceInstance = (Get-SPServiceInstance |?{$_.TypeName -eq "Managed Metadata Web Service"})
			}
			Write-Host -BackgroundColor Yellow -ForegroundColor Black "Started!"

            #Create Service App
   			Write-Host -ForegroundColor Yellow " - Creating Metadata Service Application..."
            $MetaDataServiceApp  = New-SPMetadataServiceApplication -Name $config.Services.ManagedMetadata.Name -ApplicationPool $ApplicationPool -DatabaseName $config.Services.ManagedMetadata.DBName -HubUri $config.Services.ManagedMetadata.CTHubUrl
            if (-not $?) { throw "- Failed to create Metadata Service Application" }

            #create proxy
			Write-Host -ForegroundColor Yellow " - Creating Metadata Service Application Proxy..."
            $MetaDataServiceAppProxy  = New-SPMetadataServiceApplicationProxy -Name "Metadata Service Application Proxy" -ServiceApplication $MetaDataServiceApp -DefaultProxyGroup
            if (-not $?) { throw "- Failed to create Metadata Service Application Proxy" }
            
			Write-Host -ForegroundColor Yellow "- Done creating Managed Metadata Service."
      }
	  Else {Write-Host "- Managed Metadata Service already exists."}
}

 catch
 {
	Write-Output $_ 
 }
}
#Stop Schritt 3




