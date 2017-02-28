# get all webapplications
$SPWebApps = Get-SPWebApplication

# set browser mime type
$mimeType = "application/pdf"
$SPWebApps | foreach-object {

  # If the MIME Type is on the allowed list for the Web Application 
  if($_.AllowedInlineDownloadedMimeTypes.Contains($mimeType)){
  
    # Remove the MIME type from the allowed list and update the Web Application 
    $_.AllowedInlineDownloadedMimeTypes.Remove($mimeType) | Out-Null 
    $_.Update() 
    Write-Host Removed $mimeType from the allowed list of Web Application $_.Name 
  
  }else{ 
  
    # The MIME type was not on the list - can't remove. Inform user 
    Write-Host Skipped Web Application $_.Name - $mimeType was not on the allowed list 
  } 
} 