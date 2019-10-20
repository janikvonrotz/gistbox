[xml]$Content = Get-Content -Path "KeepassData.xml"

<#
Access the xml data:

Content.KeePassFile.Root.Group.Group.Entry[67].String[0].Value
#>

function Traverse-Tree ($Node, $ParentPath) {

    $Path = $ParentPath + "/" + $Node.Name
    $ChildNodes = $Node.Group
    $Entries = $Node.Entry | Where-Object { $_.Times.Expires -eq "False" }

    if($Entries -and ($Node.Name -notcontains "Recycle Bin")) {
        foreach ($Entry in $Entries) {
            $Content = ""
            $Title = ""
            $Password = ""
            foreach ($Field in $Entry.String) {
                switch($Field.Key) {
                    "Title" { $Title = $Field.Value }
                    "Password" { $Password = $Field.Value.'#text' }
                    "Notes" { 
                        $Content += "$($Field.Key): $(($Field.Value -replace "\n","\n" ) -replace ":", "=")`n"
                        Write-Host $Content
                    }
                    default {
                        $Content += "$($Field.Key): $($Field.Value -replace "\n","\n" )`n"
                    }
                }
            }
            @{
                Path = ($Path + "/" + $Title) -replace " ", "_"
                Content = $Password + "`n" + $Content
            }
        }
    }

    if($ChildNodes) {
        foreach ($ChildNode in $ChildNodes ) {
            Traverse-Tree $ChildNode $Path
        }
    }
}

$Content.KeePassFile.Root.Group.Group | ForEach-Object {
    Traverse-Tree -Node $_ -ParentPath ""
} | ForEach-Object {
    Write-Host "Creating pass entry: $($_.Path)"
    Write-Host $_.Content
    $_.Content | & pass insert -m $_.Path
}
