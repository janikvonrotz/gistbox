Import-Module ActiveDirectory

Get-ADGroup -Filter * -SearchBase "OU=Projekte,OU=SharePoint,OU=Services,OU=vblusers2,DC=vbl,DC=ch" | where{$_.Name -like "SP_Projekt *"} | sort Name | %{

    $Group = $_

    Write-Host "Update group: $($_.Name)"

    $Members = Get-ADGroupMember $_ -Recursive | select -Unique    
    Remove-ADGroupMember -Identity $_ -Members $(Get-ADGroupMember -Identity $_) -Confirm:$false    
    $Members | %{Add-ADGroupMember -Identity $Group -Members $_}    
}