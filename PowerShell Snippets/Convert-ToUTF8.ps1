$FilePath = "FILENAME" 
Set-Content (Get-Content $FilePath) -Encoding utf8 -Path $FilePath