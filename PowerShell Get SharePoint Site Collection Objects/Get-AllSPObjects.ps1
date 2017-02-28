# Get all Webapplictons
$SPWebApps = Get-SPWebApplication

# Get all sites
$SPSites = $SPWebApp | Get-SPsite -Limit all 

foreach($SPSite in $SPSites){

  # Get all websites
  $SPWebs = $SPSite | Get-SPWeb -Limit all

  foreach ($SPWeb in $SPWebs){

    foreach($SPList in $SPweb.lists){

      $SPList | select title, DefaultViewUrl

    }
  }
}