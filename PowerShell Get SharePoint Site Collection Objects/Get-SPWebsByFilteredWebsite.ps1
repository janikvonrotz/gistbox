$SPSiteFilter = "http://sharepoint.domain.ch"
Get-SPSite | where{$SPSiteFilter -contains $_.Url} | Get-SPWeb -Limit All | %{}