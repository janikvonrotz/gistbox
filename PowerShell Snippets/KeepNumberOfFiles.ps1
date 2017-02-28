gci $SharePointBackupFolder -Recurse | where{$_.PsIsContainer} | %{
    gci $_.FullName | where{-not $_.PsIsContainer} | sort CreationTime -Descending | select -Skip 3 | Remove-Item -Force
}