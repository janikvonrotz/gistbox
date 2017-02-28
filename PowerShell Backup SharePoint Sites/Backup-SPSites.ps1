#Backup Settings
$backupPath = "E:\SharePointBackups";
$RentationDays = "1"
#Mail Settings
$emailFrom = "sharepointbackup@vbl.ch"
$emailTo = "helpdesk@vbl.ch"
$smtpServer = "mail.vbl.ch"
$SuccessNotification = 0

######################
#DO NOT MODIFY BELOW #
######################

# Init vars
$err=$NULL
$site=""
$errorMessage=""

#region backup sharepoint sitecollections
Write-Host "Starting SharePoint Backup..."
Write-Host "------------------------------"
$snapin = Get-PSSnapin Microsoft.SharePoint.Powershell -ErrorAction SilentlyContinue
if($snapin -eq $null){
	Add-PSSnapin Microsoft.SharePoint.Powershell 
}
Get-SPWebApplication | foreach {
   $readonly = Get-SPSite -Filter {$_.Lockstate -eq "ReadOnly"}    
   $noaccess = Get-SPSite -Filter {$_.Lockstate -eq "NoAccess"}
   $noadditions = Get-SPSite -Filter {$_.Lockstate -eq "NoAdditions"}

   $_ | Get-SPSite -Limit ALL | ForEach-Object {
	   try 
	   {
			$err=$NULL
            Write-Host "Backing up site "+ $_.Url +"..." -NoNewline
			$timestamp = Get-Date -Format "yyyyMMdd-HHmm"
			$url=$_.URL
			if($url.StartsWith("https")){
				$url = $url.Replace("https://", "")
			}else{
				$url = $url.Replace("http://", "")
			}
			$url = $url.Replace("/", ".") 		
			$FilePath = [System.IO.Path]::Combine($backupPath, $url.Replace("/", ".").Replace(":","-") + "-$timestamp.bak")
			$site = $_.Url
            
                    
			Set-SPSite -Identity $_.url -Lockstate "ReadOnly"
			Backup-SPSite -Identity $_.Url -Path $FilePath -ErrorVariable err -ErrorAction SilentlyContinue
			Set-SPSite -Identity $_.url -Lockstate "Unlock"
		            
            if($err -ne $NULL) {
				$errorMessage += "failed to backup site $site reason: $err`n"
				Write-Host "failed" -ForegroundColor red
			} else {
				Write-Host "done" -ForegroundColor yellow
			}
            
		} catch {
			$errorMessage += "failed to backup site $site reason $_`n"
		}
    }
    
    if($readonly){
        foreach ($site in $readonly){
            Set-SPSite -Identity $site -Lockstate "ReadOnly"
        }
    }
    if($noaccess){
        foreach ($site in $noaccess){
            Set-SPSite -Identity $site -Lockstate "NoAccess"
        }
    }
    if($noadditions){
        foreach ($site in $noadditions){
            Set-SPSite -Identity $site -Lockstate "NoAdditions"
        }
    }
}
#endregion

Write-Host "------------------------------"

#region Clean old backup files
$Files = Get-Childitem $backupPath -Include "*" -Recurse | Where {$_.LastWriteTime -le (Get-Date).AddDays(-$RentationDays)}
foreach ($File in $Files){
	if ($File -ne $NULL){
        Write-Host "- " -ForegroundColor Red -NoNewline
    	Write-Host "Deleting old backup" $File.Name "... " -NoNewline
		try{
    		Remove-Item $File.FullName | Out-Null
			Write-Host "ok" -ForegroundColor green
		}
		catch{
			$errorMessage += "failed to delete old backupfile $File - Reason $_`n"
			Write-Host "failed" -ForegroundColor red
		}
    }
}
#endregion

#region Send Mail if failed actions
if($errorMessage -ine  "") {
    $subject = "Backup failed"
    $body = "Errors while backing up sites:`n$errorMessage"
    $smtp = new-object Net.Mail.SmtpClient($smtpServer)
    $smtp.Send($emailFrom, $emailTo, $subject, $body)
}
elseif($SuccessNotification) {
    $subject = "Backup succeeded"
    $body = "Site Collection SharePoint Backup konnte erfolgreich durchgeführt werden."
    $smtp = new-object Net.Mail.SmtpClient($smtpServer)
    $smtp.Send($emailFrom, $emailTo, $subject, $body)
}
#endregion
Write-Host "------------------------------"
Write-Host "SharePoint Backup finished"