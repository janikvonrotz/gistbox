Get-ChildItem "C:\Users\$($env:Username)\AppData\Local\Microsoft\WebsiteCache" | Remove-Item -Force -Recurse