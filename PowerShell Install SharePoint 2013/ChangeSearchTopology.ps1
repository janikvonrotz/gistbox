#Start Schritt 1
$snapin = Get-PSSnapin Microsoft.SharePoint.Powershell -ErrorVariable err -ErrorAction SilentlyContinue
if($snapin -eq $null){
Add-PSSnapin Microsoft.SharePoint.Powershell 
}


$SP = Get-SPEnterpriseSearchServiceInstance -Identity "vblw2k12spweb1"
$Search = Get-SPEnterpriseSearchServiceInstance -Identity "vblw2k12spapp1"
Start-SPEnterpriseSearchServiceInstance -Identity $SP
Start-SPEnterpriseSearchServiceInstance -Identity $Search
#Stop Schritt 1 und warten bis die SharePoint Such Dienste gestartet sind

#Start Schritt 2 überprüfen, ob alle Such Dienste gestartet sind
Get-SPEnterpriseSearchServiceInstance -Identity $SP
Get-SPEnterpriseSearchServiceInstance -Identity $Search
#Stop Schritt 2

#Start Schritt 3
$ssa = Get-SPEnterpriseSearchServiceApplication
$newTopology = New-SPEnterpriseSearchTopology -SearchApplication $ssa
#Stop Schritt 3

#Start Schritt 4
#Change Topology
New-SPEnterpriseSearchAdminComponent -SearchTopology $newTopology -SearchServiceInstance $Search
New-SPEnterpriseSearchCrawlComponent -SearchTopology $newTopology -SearchServiceInstance $Search
New-SPEnterpriseSearchContentProcessingComponent -SearchTopology $newTopology -SearchServiceInstance $Search
New-SPEnterpriseSearchAnalyticsProcessingComponent -SearchTopology $newTopology -SearchServiceInstance $Search
New-SPEnterpriseSearchQueryProcessingComponent -SearchTopology $newTopology -SearchServiceInstance $SP
New-SPEnterpriseSearchIndexComponent -SearchTopology $newTopology -SearchServiceInstance $SP -IndexPartition 0
#Stop Schritt 4

#Start Schritt 5
Set-SPEnterpriseSearchTopology -Identity $newTopology
#Stop Schritt 5

#OverView
Get-SPEnterpriseSearchTopology -SearchApplication $ssa

#Check if it works
Get-SPEnterpriseSearchStatus -SearchApplication $ssa -Text
