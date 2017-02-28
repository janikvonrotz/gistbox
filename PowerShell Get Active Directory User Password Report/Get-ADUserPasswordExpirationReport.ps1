# Users which don't have password expiration enabled

Get-ADUser -Filter{Enabled -eq $True -and PasswordNeverExpires -eq  $true} -SearchBase "OU=vblusers2,DC=vbl,DC=ch"  -Properties lastLogonTimestamp, pwdLastSet, displayName |
foreach{$_ | Select-Object -Property Name, UserPrincipalName, displayName, `
@{Name = "lastLogonTimestamp";Expression = {[DateTime]::FromFileTime($_.lastLogonTimestamp)}}, `
@{Name = "pwdLastSet";Expression = {[DateTime]::FromFileTime($_.pwdLastSet)}} } |
Out-GridView