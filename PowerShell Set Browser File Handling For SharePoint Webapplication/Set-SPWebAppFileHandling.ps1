# get all webapplications
$SPWebApps = Get-SPWebApplication

# set global file handling
$SPWebApps | foreach-object {
 if($_.BrowserFileHandling -ne "strict" ){
      $_.BrowserFileHandling = "strict" 
      $_.Update()
  }
}