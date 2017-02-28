<#
$Metadata = @{
	Title = "Assign Temporary Administrator Rights"
	Filename = "Assign-TemporaryAdministratorRights.ps1"
	Description = ""
	Tags = "powershell, script, activedirectory, assign, temporary, administrator, rights, computer"
	Project = ""
	Author = "Janik von Rotz"
	AuthorContact = "http://janikvonrotz.ch"
	CreateDate = "2013-11-15"
	LastEditDate = "2013-11-18"
	Url = ""
	Version = "1.0.0"
	License = @'
This work is licensed under the Creative Commons Attribution-ShareAlike 3.0 Switzerland License.
To view a copy of this license, visit http://creativecommons.org/licenses/by-sa/3.0/ch/ or 
send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
'@
}
#>

try{
    #--------------------------------------------------#
    # modules
    #--------------------------------------------------#
    Import-Module ActiveDirectory
    Import-Module GroupPolicy

    #--------------------------------------------------#
    # settings
    #--------------------------------------------------#

    # var #Username# replaces username, var #Computername# replaces computername
    $GPOTemplate = "Windows User #Username# - #Computername# Lokaler Administrator"
    $TempFolder = "C:\export"
    $SPWebUrl = (Get-SPUrl "http://sharepoint.vbl.ch/finanzen/it/Abteilungssite/SitePages/Homepage.aspx").Url
    $SPListName = "Temporäre Adminrechte"
    $RemoteConnectionKey = "sp1"

    #--------------------------------------------------#
    # main
    #--------------------------------------------------#
    
    $Computer = Get-RemoteConnection -Name $RemoteConnectionKey
    $Credential = Import-PSCredential -Path (Get-ChildItem $PSconfigs.Path -Filter "SharePoint.credential.config.xml" -Recurse).FullName
    $Session = New-PSSession -ComputerName $Computer.Name -Credential $Credential -ConfigurationName microsoft.powershell
    $Computer.SnapIns | %{ Invoke-Command -Session $Session -ScriptBlock {param ($Name) Add-PSSnapin -Name $Name} -ArgumentList $_}
    [ScriptBlock]$ScriptBlock = [scriptblock]::Create(@"
Get-SPWeb '$SPWebUrl' | %{
    `$_.Lists['$SPListName'].GetItems() | %{
        `$(New-Object PSObject -Property @{
            Mail = `$_["Title"].toString()
            Computer = `$_["Computer"].toString()
            From = `$_["From"].toString()
            To = `$_["To"].toString()
        })
    }
}
"@)
    $Config = Invoke-Command -Session $Session -ScriptBlock $ScriptBlock
    Remove-PSSession $Session

    <#
     $Config = @(      
          $(New-Object PSObject -Property @{
              Mail = "name.surname@domain.ch"
              Computer = "tpbmar1"
              From = "18.11.2013"
              To = "25.11.2013"
          }),
          
          $(New-Object PSObject -Property @{
              Mail = "name.surname@vbl.ch"
              Computer = "tpfit9"
              From = "15.11.2013"
              To = "21.11.2013"
          }),
      )
    #>
    $Config | %{
        
        # get settings
        $ADComputer = Get-ADComputer $_.Computer
        $ADUser = Get-ADUser -Filter "mail -eq '$($_.Mail)'" | select -first 1
        $GPOName = ($GPOTemplate -replace "#Username#", $ADUser.Name -replace "#Computername#", $ADComputer.Name)
        $SourceGPO = Get-GPO $GPOTemplate
        $TargetOU = $ADComputer.DistinguishedName -replace "CN=$($ADComputer.Name),",""
        $FromDate = Get-Date $_.From
        $ToDate = Get-Date $_.To
        $Date = $(Get-Date)
        
        # create temp folder
        if(-not (Test-Path $TempFolder)){New-Item -Path $TempFolder -ItemType Directory}
            
        # get gpo
        $GPO = Get-GPO -Name $GPOName -ErrorAction SilentlyContinue
        
        # create if not exist
        if(-not $GPO -and $Date -gt $FromDate -and $Date -lt $ToDate){
        
            # create new gpo
            $GPO = New-GPO -Name $GPOName
            $GPO | New-GPLink -Target $TargetOU
            $GPO | Set-GPPermissions -Replace -PermissionLevel None -TargetName "Authentifizierte Benutzer" -TargetType Group
            $GPO | Set-GPPermissions -PermissionLevel GpoApply -TargetName $ADComputer.Name -TargetType Computer
            
            # backup template gpo
            $GPOBackup = $SourceGPO | Backup-GPO -Path $TempFolder    
            $PathToXML = Join-Path $TempFolder ("{" + $GPOBackup.Id + "}\DomainSysvol\GPO\Machine\Preferences\Groups\Groups.xml")
            $PathToFolder = Join-Path $TempFolder ("{" + $GPOBackup.Id + "}")
            [xml]$GroupXML = Get-Content $PathToXML
                
            # update template gpo settings
            $GroupXML.Groups.Group.Properties.Members.Member.name = $(Get-ADDomain).NetBIOSName + "\" +$ADUser.SamAccountName
            $GroupXML.Groups.Group.Properties.Members.Member.sid = "$($ADUser.SID)"
            $GroupXML.Save($PathToXML)    
         
            # import to new gpo
            Import-GPO -BackupId $GPOBackup.Id -TargetGuid $GPO.Id -path $TempFolder
           
            # clean up tempfolder
            Remove-Item $PathToFolder -Force -confirm:$false -Recurse
            
            Write-PPEventLog -Message "Added temporary administrator rights for: $($_.Mail) on computer: $($_.Computer)" -Source "Assign Temporary Administrator Rights" -WriteMessage
                    
        # delete gpo
        }elseif($GPO -and $Date -gt $ToDate ){
        
           $GPO | Remove-GPO
           Write-PPEventLog -Message "Removed temporary administrator rights for: $($_.Mail) on computer: $($_.Computer)" -Source "Assign Temporary Administrator Rights" -WriteMessage
        }
    }
}catch{

    Write-PPErrorEventLog -Source "Assign Temporary Administrator Rights"
}