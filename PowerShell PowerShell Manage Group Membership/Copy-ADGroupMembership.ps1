Get-ADPrincipalGroupMembership "" | %{Add-ADGroupMember -Identity $_ -Members ""}