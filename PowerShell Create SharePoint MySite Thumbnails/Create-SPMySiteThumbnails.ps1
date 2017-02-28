if((Get-PSSnapin 'Microsoft.SharePoint.PowerShell' -ErrorAction SilentlyContinue) -eq $null){Add-PSSnapin 'Microsoft.SharePoint.PowerShell'}

Update-SPProfilePhotoStore -CreateThumbnailsForImportedPhotos 1 -MySiteHostLocation http://mysite.vbl.ch
