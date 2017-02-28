# custom report with user password expires and never expires

$DaysUntilExpiration = (Get-ADDefaultDomainPasswordPolicy).MaxPasswordAge.Days

$DaysUntilExpirationForUserPasswordNeverExpires = $DaysUntilExpiration  + 90

if($DaysUntilExpiration -le 0){throw "Domain 'MaximumPasswordAge' password policy is not configured."}

Get-ADGroupMember "F_Mitarbeiter" -Recursive | 

Get-ADUser -Properties Enabled, lastLogonTimestamp, PasswordNeverExpires, PasswordLastSet, Mail, DisplayName |

Select-Object *, @{L="PasswordExpirationDays";E={
    if($_.PasswordNeverExpires){
        $DaysUntilExpirationForUserPasswordNeverExpires - ((Get-Date) - ($_.PasswordLastSet)).Days  
    }else{    
        $DaysUntilExpiration - ((Get-Date) - ($_.PasswordLastSet)).Days
    }
}} |

Select-Object *, @{L="PasswordExpirationDate";E={Get-Date (Get-date).AddDays($_.PasswordExpirationDays) -Format d}},

@{Name = "lastLogonTimestampDate";Expression = {[DateTime]::FromFileTime($_.lastLogonTimestamp)}} |

Where-Object{($_.Enabled -eq $true)} |

Select-Object DisplayName, Mail, PasswordNeverExpires, PasswordExpirationDays, PasswordExpirationDate, PasswordLastSet, lastLogonTimestampDate | 

Out-GridView