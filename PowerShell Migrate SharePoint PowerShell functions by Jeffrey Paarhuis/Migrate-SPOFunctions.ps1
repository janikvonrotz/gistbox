# change function directory
cd (join-path $PSfunctions.Path "SharePoint Online")

# download latest source code
Install-PPApp "Client-side SharePoint PowerShell" -Force -IgnoreDependencies

# delete example files
Get-ChildItem | where{$_.extension -eq ".ps1" -or $_.PSIsContainer} | Remove-Item -Force -Recurse -Confirm:$false

# copy dlls to lib folder
Copy-Item ".\*.dll" -Destination $PSlib.Path -Force

# delete dlls
Remove-Item ".\*.dll" -Force -Recurse -Confirm:$false

# reset variabes
$Temp = @()
$OpenBracketCount = 0
$Scripts = @()

# cycle through script content
$Scripts = Get-ChildItem ".\*.psm1" | Get-Content | ForEach-Object{

    Write-Host $_

    if($_ -match "function"){
        
        # new script object
        $Script = @{
            Name = ""
            OldName = ""
            Content = @()
        }
       
        # get new names
        $Script.OldName = $_ -replace "function" -replace " "
        $Script.Name = if($Script.OldName -notmatch "SPPS"){$Script.OldName -replace "-","-SPO"}else{$Script.OldName -replace "-SPPS","-SPO"}
        if($Script.OldName -eq "GetRole"){$Script.Name = "Get-SPORole"}
        if($Script.OldName -eq "Initialize-SPPS"){$Script.Name = "Connect-SPO"}
    }

    # check when to trim the function
    $OpenBracketCount += @($_.ToCharArray() | Where-Object{$_ -eq "{"}).count
    $OpenBracketCount -= @($_.ToCharArray() | Where-Object{$_ -eq "}"}).count
    
    # trim function
    if($OpenBracketCount -gt 0 -or ($_ -contains "}")){  

        $Script.Content += $_

        if($OpenBracketCount -eq 0){
            
            # output script object
            $Script
        }    
    }
}

# replace new function names and specific script content
$ScriptsNew = $Scripts
$Scripts | ForEach-Object{
    $Script = $_
    $ScriptsNew = $ScriptsNew | ForEach-Object{
        $_.Content = $_.Content -replace $Script.OldName, $Script.Name `
            -replace '"\$scriptdir\\Microsoft.SharePoint.Client.dll"','(Get-ChildItem -Path $PSlib.Path -Filter "Microsoft.SharePoint.Client.dll" -Recurse).FullName' `
            -replace '\$context','$SPOContext'
        $_
    }    
}
$Scripts = $ScriptsNew

# create script file foreach function
$Scripts | foreach{

    $_.Filename = "$($_.Name).ps1"

    $Content = @()
    $Content += @"
<#
`$Metadata = @{
	Title = "$($_.Name)"
	Filename = "$($_.Filename)"
	Description = ""
	Tags = "powershell, sharepoint, online"
	Project = "https://sharepointpowershell.codeplex.com"
	Author = "Jeffrey Paarhuis"
	AuthorContact = "http://jeffreypaarhuis.com/"
	CreateDate = "2013-02-2"
	LastEditDate = "2014-02-2"
	Url = ""
	Version = "0.1.2"
	License = @'
The MIT License (MIT)
Copyright (c) 2014 Jeffrey Paarhuis
Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
'@
}
#>

"@

    $Content += "function $($_.Name)"
    $Content += $_.Content

    Set-Content -Value $Content -Path $_.Filename
}

Remove-Item ".\*.psm1" -Force -Recurse -Confirm:$false