$wc = New-Object System.Net.WebClient
$wc.Credentials = [System.Net.CredentialCache]::DefaultCredentials
$wc.DownloadString("URL")