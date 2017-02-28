# change function directory
cd (join-path $PSfunctions.Path "Carbon")

# Remove Content
Get-ChildItem -Recurse | Remove-Item -Force -Recurse

# download latest source code
Install-PPApp "PowerShell Carbon" -Force -IgnoreDependencies

# move the content of the carbon folder
Move-Item -Path ./Carbon/* -Destination .\ -ErrorAction SilentlyContinue

# delete files other an PowerShell functions
Get-ChildItem -Recurse | where{$_.extension -ne ".ps1" -and -not $_.PSIsContainer} | Remove-Item -Force
"Xml", "bin", "Import-Carbon.ps1","Website", "examples", "Carbon" | ForEach-Object{Remove-Item -Path $_ -Force -Recurse -ErrorAction SilentlyContinue}

# cycle through script content
Get-ChildItem -Filter *.ps1 -Recurse | ForEach-Object{

    $Trim = $false
    $Name = $_.Name -replace ".ps1"
    $Verb = $Name.Split("-")[0]
    $Noun = $Name.Split("-")[1]
    $NewContent = @()    
    $NewContent += @"
<#
`$Metadata = @{
	Title = "$Verb $Noun"
	Filename = "$($_.Name)"
	Description = ""
	Tags = "powershell, carbon"
	Project = "http://get-carbon.org/"
	Author = "Aaron Jensen"
	AuthorContact = "http://pshdo.com/"
	CreateDate = "2012-01-01"
	LastEditDate = "2014-04-17"
	Url = ""
	Version = "1.6.0"
	License = @'
# Copyright 2012 Aaron Jensen
# 
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# 
#     http://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
'@
}
#>

"@

    $NewContent += Get-Content $_.fullname | ForEach-Object{       
                
        if($_ -match "function" -or $_ -match "filter" -or $Trim){
        
            $Trim = $true
            $_
        }
    }
    
    Set-Content -Path $_.fullname -Value $NewContent
}