Import-Module ActiveDirectory

$Domain = "$((Get-ADDomain).Name)"

$ADGroups = Get-ADGroup -Filter "*" -SearchBase "OU=SharePoint,OU=Services,OU=vblusers2,DC=vbl,DC=ch"

$SPGroups = (
    Get-SPWebs | %{
        if($_.HasUniqueRoleAssignments){
            $Url = $_.Url
            $_.RoleAssignments | Where{$_.Member.IsDomainGroup} | %{ $_ | Select-Object @{Name = "Member"; Expression = {$_.member -replace ($Domain + "\\"),""}}, @{Name = "Url"; Expression = {$Url}},@{Name = "Type"; Expression = {"Website"}}}   
        }
    }
    )+(
        
    Get-SPLists | %{        
        if($_.HasUniqueRoleAssignments){
            $Url = ([uri]$_.Parentweb.Url).Scheme + "://" + ([uri]$_.Parentweb.Url).host + $_.DefaultViewUrl
            $_.RoleAssignments | Where{$_.Member.IsDomainGroup} | %{ $_ | Select-Object @{Name = "Member"; Expression = {$_.member -replace ($Domain + "\\"),""}}, @{Name = "Url"; Expression = {$Url}},@{Name = "Type"; Expression = {"List"}}}  
        }
    }
)

$ADGroups | where{ -not (($SPGroups | select Member) -match $_.Name)} | select name