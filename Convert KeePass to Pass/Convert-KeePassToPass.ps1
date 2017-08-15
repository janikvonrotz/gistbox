[xml]$Content = Get-Content -Path "KeepassData.xml"

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
                    default {
                        $Content += "$($Field.Key): `"$($Field.Value)`"`n"
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
    $_.Content | & pass insert -m $_.Path
}
