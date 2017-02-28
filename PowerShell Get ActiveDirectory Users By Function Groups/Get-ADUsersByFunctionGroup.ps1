Import-Module activedirectory

cls

$GroupMembershipReportByPrefix = "F_"
$IgnoreGroups = "F_Lehrlingsbetreuer","F_Mitarbeiter","F_Mitarbeiter mit Arbeitsplatz","F_Mitarbeiter ohne Arbeitsplatz","F_Verantwortlicher Kostenstelle","F_Fahrdienstleiter"
$ReportInOUs = "OU=Dienste,OU=Betrieb,OU=vblusers2,DC=vbl,DC=ch"

$ReportInOUs | %{

    Get-ADOrganizationalUnit -Filter * -SearchBase $_ | %{

        Write-Host "`n### $($_.Name) ###"

        Get-ADUser -SearchBase $_.DistinguishedName  -filter * -properties Title, Manager, department, displayname | sort Name | %{

            Write-Host "`n$($_.Name)`n"

            Get-ADPrincipalGroupMembership $_ | where{$_.Name.StartsWith($GroupMembershipReportByPrefix) -and $IgnoreGroups -notcontains $_.Name} | %{

                Write-Host ("- $($_.Name)" -replace "F_","")
            }  
        }
    } 
}