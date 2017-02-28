# based on ISO 8601
# http://technet.microsoft.com/en-us/library/ee692801.aspx

$Filename = $Name + "#" + $((Get-Date -Format s) -replace ":","-") + ".bak"