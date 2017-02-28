Import-Module ActiveDirectory

Get-ADGroupMember "F_Mitarbeiter ohne Arbeitsplatz" -Recursive | 
Get-ADUser -Properties PasswordNeverExpires |
where {$_.enabled -eq $true -and $_.PasswordNeverExpires -eq $false} |
select -First 50 | %{

    Write-Host $_.UserPrincipalName
    Set-ADUser $_ -PasswordNeverExpires $true
}