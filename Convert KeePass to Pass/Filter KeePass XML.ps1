[xml]$Content = Get-Content -Path "KeepassData.xml"

$Entries = $Content.KeePassFile.Root.Group.Group | Where-Object { $_.Times.Expires -eq "False" -and $_.Name -eq "Private" } | %{$_.Entry}

$Entries | % {
    $String = $_.String | where{$_.Value -eq "GitHub"} 
    if($String) {
        $_.String | %{
            if($_.Key -eq "2FA App Passcode") {
                $_.Value -replace "\n","\n"
            }
        }
    }
}