<#
$Metadata = @{
	Title = "Send Password Expiration Reminder"
	Filename = "Send-PasswordExpirationReminder.ps1"
	Description = ""
	Tags = "powershell, script, jobs"
	Project = ""
	Author = "Janik von Rotz"
	AuthorContact = "http://.janikvonrotz.ch"
	CreateDate = "2013-08-08"
	LastEditDate = "2013-11-25"
	Version = "2.1.0"
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
    Import-Module ActiveDirectory
	
    #--------------------------------------------------#
    # settings
    #--------------------------------------------------#   
    $TriggerDays = 25, 10, 5, 1
    $SendLinkOnDays = 25,10, 5, 1
	$DaysBeforeDisablingUsersWithPasswordNeverExpires = 180
	$ADGroup = "S-1-5-21-1744926098-708661255-2033415169-36648" # Memberof GroupName should be "SPO_PasswordNotification"   
    
    #--------------------------------------------------#
    # main
    #--------------------------------------------------#

    # get mail config         
    $Mail = Get-PPConfiguration $PSconfigs.Mail.Filter | %{$_.Content.Mail | where{$_.Name -eq "PasswordReminder"}} | select -first 1

    # get days until password expires
    $MaxDays = (Get-ADDefaultDomainPasswordPolicy).MaxPasswordAge.Days 
    if($MaxDays -le 0){throw "Domain 'MaximumPasswordAge' password policy is not configured."}

    # Set days when an email should be sent to inform the users
    $TriggerDays = 25, 10, 5, 1
    $SendLinkOnDays = 25,10, 5, 1

    foreach($TriggerDay in $TriggerDays){    
    
        # Memberof GroupName should be "SPO_PasswordNotification"       
        Get-ADGroupMember $ADGroup -Recursive | 
        Get-ADUser -Properties Enabled, lastLogonTimestamp, PasswordNeverExpires, PasswordLastSet, Mail, DisplayName |
        Select *, @{L = "PasswordExpires";E = { 
            if($_.PasswordNeverExpires){
                $DaysBeforeDisablingUsersWithPasswordNeverExpires - ((Get-Date) - ($_.PasswordLastSet)).Days
            }else{
                $MaxDays - ((Get-Date) - ($_.PasswordLastSet)).Days
            }
        }} |
        where{($_.Enabled -eq $true) -and ($_.PasswordExpires -eq $TriggerDay)} | %{ 
                              
            # set subject
            $Subject = "Passwort Erinnerung: $($_.DisplayName) ihr Passwort läuft in $($_.PasswordExpires) Tagen ab"
            
            $BodyFont = "font-size: 11pt; font-family: Calibri"
            
            # create mail message
            $Body = "<p style = ""$BodyFont"">Guten Tag $($_.DisplayName) <br/> <br/> Ihr Passwort läuft am $(Get-Date (Get-Date).AddDays($_.PasswordExpires) -Format D) ab.</b></p>"          
            if($SendLinkOnDays -contains $TriggerDay){            
                $Body += "<p style = ""$BodyFont"">Bitte ändern Sie das Passwort bevor es abläuft. Rufen Sie dazu die folgende Seite auf: <a href=""https://vbluzern.sharepoint.com/Support/SitePages/Passwortwechsel.aspx"" target=""_blank"">Link</a></p>"
            }
             $Body += "<p style = ""$BodyFont"">ACHTUNG! Dieses E-Mail wurde von einem unbeaufsichtigtem Konto verschickt, Antworten an den Sender dieser E-Mail werden nicht bearbeitet.</p>"

            # send mail
            Write-PPEventLog "$($MyInvocation.InvocationName)`n`nSend password reminder to $($_.Mail)" -WriteMessage -Source "Send Password Expiration Reminder" 
            Send-MailMessage -To $_.Mail -From $mail.FromAddress -Subject $Subject -Body $Body -SmtpServer $Mail.OutSmtpServer -BodyAsHtml -Priority High -Encoding ([System.Text.Encoding]::UTF8)
        
        }        
    }
   
}catch{

	Write-PPErrorEventLog -Source "Send Password Expiration Reminder" -ClearErrorVariable
}
