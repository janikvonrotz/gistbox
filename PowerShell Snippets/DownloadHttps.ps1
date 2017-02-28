$Url = "https://server/file.ext"
$Path = "c:\downloads\file.ext"
[Net.ServicePointManager]::ServerCertificateValidationCallback = {$true}
$webClient = new-object System.Net.WebClient
$webClient.DownloadFile( $Url, $Path )