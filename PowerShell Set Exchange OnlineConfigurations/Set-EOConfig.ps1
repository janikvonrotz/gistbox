<#
$Metadata = @{
	Title = "Set Exchange Online Configurations"
	Filename = "Set-EOConfig.ps1"
	Description = ""
	Tags = "powershell, office, 365, exchange, online, settings"
	Project = ""
	Author = "Janik von Rotz"
	AuthorContact = "http://janikvonrotz.ch"
	CreateDate = "2014-01-21"
	LastEditDate = "2014-01-21"
	Url = "https://gist.github.com/6294947"
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
    # settings
    #--------------------------------------------------#

    $Language = "de-CH"
    $TimeZone = "W. Europe Standard Time"
    $DateFormat = "dd.MM.yyyy"
    $HtmlSignatureTemplate = "vbl signature.html"
    $TextSignatureTemplate = "vbl signature.txt"
    $SignatureCompanyPhoneNumber = "+41 41 369 65 65"
    $SignatureCompanyFaxNumber = "041 369 65 00"
    
    #--------------------------------------------------#
    # modules
    #--------------------------------------------------#
    Import-Module ActiveDirectory       

    #--------------------------------------------------#
    # sessions
    #--------------------------------------------------#

    $Credential = Import-PSCredential $(Get-ChildItem -Path $PSconfigs.Path -Filter "Office365.credentials.config.xml" -Recurse).FullName
    
    $s = New-PSSession -ConfigurationName Microsoft.Exchange `
    -ConnectionUri https://ps.outlook.com/powershell `
    -Credential $(Get-Credential -Credential $Credential) `
    -Authentication Basic `
    -AllowRedirection
    Import-PSSession $s

    #--------------------------------------------------#
    # main
    #--------------------------------------------------#

    $ADUsers = Get-ADUser -Filter {Mail -like "*"} -Properties sn, telephoneNumber, title
    $Mailboxes = Get-Mailbox

    foreach($Mailbox in $Mailboxes){
        
        Write-Progress -Activity "Update settings" -status $($Mailbox.Name) -percentComplete ([Int32](([Array]::IndexOf($Mailboxes, $Mailbox)/($Mailboxes.count))*100))

        Write-Host "Set mailbox language settings for $($Mailbox.Name)"
        Set-MailboxRegionalConfiguration $Mailbox.Alias -Language $Language -TimeZone $TimeZone -LocalizeDefaultFolderName -DateFormat $DateFormat

        Write-Host "Set signature for $($Mailbox.Name)"
        $ADUsers | where{$_.UserPrincipalName -eq $Mailbox.UserPrincipalName} | select -First 1 | %{           

            $Html = get-Content -Path $(Get-ChildItem -Path $PStemplates.Path -Filter $HtmlSignatureTemplate -Recurse).FullName  
            $Text = get-Content -Path $(Get-ChildItem -Path $PStemplates.Path -Filter $TextSignatureTemplate  -Recurse).FullName  
            
            $PhoneNumber = $(if($_.telephoneNumber -eq $null){$SignatureCompanyPhoneNumber}else{$_.telephoneNumber})

            $Html = $Html -replace "%%Firstname%%",$_.givenname `
                -replace "%%Lastname%%",$_.sn `
                -replace "%%Title%%",$_.title `
                -replace "%%PhoneNumber%%",$PhoneNumber `
                -replace "%%FaxNumber%%",$SignatureCompanyFaxNumber 
                  
            $Text = $Text -replace "%%Firstname%%",$_.givenname `
                -replace "%%Lastname%%",$_.sn `
                -replace "%%Title%%",$_.title `
                -replace "%%PhoneNumber%%",$PhoneNumber `
                -replace "%%FaxNumber%%",$SignatureCompanyFaxNumber

            Set-MailboxMessageConfiguration -Identity $Mailbox.Alias -SignatureHtml $Html -AutoAddSignature $true -SignatureText $Text
        }
    }
}catch{

    Write-PPErrorEventLog -Source "Exchange Online Settings" -ClearErrorVariable

}finally{

    Remove-PSSession $s
}