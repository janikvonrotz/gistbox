# get all webapplications
$SPWebApps = Get-SPWebApplication

# set browser mime type
$mimeType = "application/pdf"
$SPWebApps | foreach-object { 

    # If the MIME Type is not already on the allowed list for the Web Application 
    if(!$_.AllowedInlineDownloadedMimeTypes.Contains($mimeType)){ 

        # Add the MIME type to the allowed list and update the Web Application 
        $_.AllowedInlineDownloadedMimeTypes.Add($mimeType) 
        $_.Update() 
        Write-Host Added $mimeType to the allowed list for Web Application $_.Name 

    }else{ 

        # The MIME type was already allowed - can't add. Inform user 
        Write-Host Skipped Web Application $_.Name - $mimeType was already allowed 
    } 
}