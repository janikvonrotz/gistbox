
# convert to utf8
(Get-ChildItem "test.csv") | %{if((Get-FileEncoding $_) -ne "UTF8"){Set-Content (Get-Content $_) -Encoding utf8 -Path $_}}

# export csv file
$Content | Export-Csv "test.csv" -Delimiter ";" -Encoding "UTF8" -NoTypeInformation

# import csv file
$Content = Import-CSV "test.csv" -Delimiter ";"