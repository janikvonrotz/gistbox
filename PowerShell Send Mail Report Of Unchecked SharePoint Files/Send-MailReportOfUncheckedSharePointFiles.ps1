<#
$Metadata = @{
	Title = "Send Mail Report Of Unchecked SharePoint Files"
	Filename = "Send-MailReportOfUncheckedSharePointFiles.ps1"
	Description = ""
	Tags = ""
	Project = "powershell, script, sharepoint, report, unchecked, file"
	Author = "Janik von Rotz"
	AuthorContact = "http://janikvonrotz.ch"
	CreateDate = "2013-11-14"
	LastEditDate = "2013-01-13"
	Url = ""
	Version = "2.1.0"
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
    Add-Type -AssemblyName System.Web
    if((Get-PSSnapin 'Microsoft.SharePoint.PowerShell' -ErrorAction SilentlyContinue) -eq $null){Add-PSSnapin 'Microsoft.SharePoint.PowerShell'}
    Import-Module ActiveDirectory

    #--------------------------------------------------#
    # settings
    #--------------------------------------------------#
    $Config = Get-PPConfiguration
    $SPSiteFilter = $Config | %{$_.Content.Script.SharePoint.SiteCollection} | where{$_.Feature -contains "ReportUncheckedFiles"} | %{$_.Url}
    $MailConfig = $Config | %{$_.Content.Script.SharePoint.Mail} | select -First 1 

    #--------------------------------------------------#
    # main
    #--------------------------------------------------#
    
    # get unchecked files
    $UncheckedFilesByEmail = Get-SPSite | where{$SPSiteFilter -contains $_.Url} | Get-SPWeb -Limit All | %{
        $SPWeb = $_
        $_.lists | %{
            $_.CheckedOutFiles | %{           
                $_ | select *, @{L="FileUrl";E={$SPWeb.Site.Url + "/" + $_.Url}}, @{L="SiteUrl";E={($SPWeb.Site.Url + "/" + $_.Url) -replace "[^/]+$",""}}        
            }
        }
    } | sort CheckedOutByEmail
    
    # create mails for owner
    $UncheckedFilesByEmail | Group-Object CheckedOutByEmail | %{

        $Subject = "$($_.Count) nicht eingecheckte Dateien auf dem SharePoint"
        
        $BodyTable = $($_.group | select @{L="Name";E={$_.LeafName}}, @{L="FileUrl";E={"<a href='$($_.FileUrl)'>$($_.FileUrl)</a>"}}, @{L="SiteUrl";E={"<a href='$($_.SiteUrl)'>$($_.SiteUrl)</a>"}}, TimeLastModified, @{L="Size";E={Format-FileSize $_.Length}} | where{$_.TimeLastModified -lt $(Get-Date).AddDays(-7)})
        
        if($BodyTable){
        
            $Body = @"    
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN"  "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd"> <html xmlns="http://www.w3.org/1999/xhtml"> <head> <style>
    body{
        font-size: 11pt; 
        font-family: Calibri
    }
    table { 
        margin: 1em;
        border-collapse: collapse; 
    }
    td, th {
        margin: 0.3em; 
        border: 1px #ccc solid; 
    }
</style></head><body>

    <p>Guten Tag $($_.Group[0].CheckedOutByName)</p>

    <p>Sie erhalten diese E-Mail, weil Sie im Besitz von nicht eingecheckten Dateien sind,</br>
    welche als letztes vor einer Woche oder früher bearbeitet worden sind.</p>

    <p>Diese Dateien sind für andere weder bearbeitbar noch sichtbar, da diese noch nie eingecheckt worden sind.</br>
	Das Ein- und Aus-Checken gehört zum SharePoint Dokument Bearbeitungsprozess</p>
	
    <p>Wir bitten Sie diese Dateien einzuchecken oder zu löschen.</p>

    <p>Untersützung zu diesem Thema erhalten Sie <a href="http://office.microsoft.com/de-ch/sharepoint-workspace-help/auschecken-und-einchecken-von-dokumenten-in-ein-dateitool-HA010356922.aspx">hier</a>.</p>

    <h2>Übersicht Ihrer nicht eingecheckten Dateien</h2>

    $($BodyTable | ConvertTo-Html -Fragment)

    <p>ACHTUNG! Dieses E-Mail wurde von einem unbeaufsichtigtem Konto verschickt, Antworten an den Sender dieser E-Mail werden nicht bearbeitet.</p>

</body></html>
"@       
        
            Write-PPEventLog -Message "Send Mail to: $($_.Name) with subject: $Subject" -Source "Send Mail Report Of Unchecked SharePoint Files" -WriteMessage
            Send-MailMessage -To $_.Name -From $MailConfig.From -Subject $Subject -Body ([System.Web.HttpUtility]::HtmlDecode($Body)) -SmtpServer $MailConfig.SmtpServer -BodyAsHtml -Priority High -Encoding ([System.Text.Encoding]::UTF8)   
        }        
    }
        
        # send mail report to sharepoint administrator
    $Config | %{$_.Content.Script.SharePoint.ADUserAndGroupSPAdministrators} | where{$_} | %{
    
        Get-ADObject -Filter {Name -eq $_} | %{
        
            if($_.ObjectClass -eq "user"){
                
                Get-ADUser $_.DistinguishedName -Properties Mail, DisplayName
                
            }elseif($_.ObjectClass -eq "group"){
            
                Get-ADGroupMember $_.DistinguishedName -Recursive | Get-ADUser -Properties Mail, DisplayName
            }
        }
    } | %{
        
        $Subject = "$($UncheckedFilesByEmail.Count) nicht eingecheckte Dateien auf dem SharePoint"
    
        $BodyTable = $($UncheckedFilesByEmail | select @{L="Name";E={$_.LeafName}}, @{L="FileUrl";E={"<a href='$($_.FileUrl)'>$($_.FileUrl)</a>"}}, @{L="Owner";E={$_.CheckedOutByEmail}}, @{L="SiteUrl";E={"<a href='$($_.SiteUrl)'>$($_.SiteUrl)</a>"}}, TimeLastModified, @{L="Size";E={Format-FileSize $_.Length}})
    
        if($BodyTable){
        
                $Body = @"    
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN"  "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd"> <html xmlns="http://www.w3.org/1999/xhtml"> <head> <style>
    body{
        font-size: 11pt; 
        font-family: Calibri
    }
    table { 
        margin: 1em;
        border-collapse: collapse; 
    }
    td, th {
        margin: 0.3em; 
        border: 1px #ccc solid; 
    }
</style></head><body>

    <p>Guten Tag $($_.DisplayName)</p>

    <p>Sie erhalten diese E-Mail zur Übersicht von nicht eingecheckten Dateien.</p>

    <p>Diese Dateien sind für andere weder bearbeitbar noch sichtbar, da diese noch nie eingecheckt worden sind.</br>
	Das Ein- und Aus-Checken gehört zum SharePoint Dokument Bearbeitungsprozess</p>
	
    <h2>Übersicht Ihrer nicht eingecheckten Dateien</h2>

    $($BodyTable | ConvertTo-Html -Fragment)

    <p>ACHTUNG! Dieses E-Mail wurde von einem unbeaufsichtigtem Konto verschickt, Antworten an den Sender dieser E-Mail werden nicht bearbeitet.</p>

</body></html>
"@
        
            Write-PPEventLog -Message "Send Mail to: $($_.Mail) with subject: $Subject" -Source "Send Mail Report Of Unchecked SharePoint Files" -WriteMessage
            Send-MailMessage -To $_.Mail -From $MailConfig.From -Subject $Subject -Body ([System.Web.HttpUtility]::HtmlDecode($Body)) -SmtpServer $MailConfig.SmtpServer -BodyAsHtml -Priority High -Encoding ([System.Text.Encoding]::UTF8) 
        }
    }
}catch{
    
    Write-PPErrorEventLog -Source "Send Mail Report Of Unchecked SharePoint Files" -ClearErrorVariable
}