function Get-RandomHexString {
    param($count)
    $hex = '012345679ABCDEF'.ToCharArray()
    $array = foreach($number in 1..$count ){ $hex | Get-Random}
    return (($array) -join "").ToString().ToLower()

}

function Get-WikiType{
    param($file)
    return $(if($file.psiscontainer){"folder"}else{if(@(".gif",".png",".jpg") -contains $file.Extension){"image"}else{"article"}})
}

function Add-Tabstops{
    param($Count)
    $tabs = ""
    for($i=0; $i -lt $Count; $i++){$tabs += "  "}
    return $tabs
}

function Output-JsonChildren{
    param($Path, $Level = 1)
    return $(Get-ChildItem -Path $Path | Where-Object{$_} | ForEach-Object{
        (Add-Tabstops $Level) +
        "{`n" +
        (Add-Tabstops ($Level+1)) +
        "`"_id`"`: `"$(Get-RandomHexString -Count 24)`"," +
        "`n" +
        (Add-Tabstops ($Level+1)) +
        "`"type`"`: `"$(Get-WikiType -file $_)`"," +
        "`n" +
        (Add-Tabstops ($Level+1)) +
        "`"name`"`: `"$($_.Name)`"," +
        "`n" +
        (Add-Tabstops ($Level+1)) +
        "`"children`": ["+
        $(if($_.psiscontainer){"`n" + (Output-JsonChildren -Path $_.FullName -Level ($Level+2)) + "`n" + (Add-Tabstops ($Level+1))}) +
        "]`n" +
        (Add-Tabstops ($Level)) +
        "}"
    }) -join ",`n"
}

function Output-ObjectTree{
    param($Path, $Level = 1)
    
    $nodes = $(Get-ChildItem -Path $Path | Where-Object{$_ -and ($_.Name -ne "WinAuftrag")} | ForEach-Object{

        $id = $(Get-RandomHexString -Count 24)
        $nodes = @()

        $(if($_.psiscontainer){
            $nodes = (Output-ObjectTree -Path $_.FullName -Level $Level)
            $children = ($nodes | %{"`"$($_.id)`""}) -join ","
        })

        $content = ((Add-Tabstops $Level) +
        "{`n" +
        (Add-Tabstops ($Level+1)) +
        "`"_id`"`: `"$id`"," +
        "`n" +
        (Add-Tabstops ($Level+1)) +
        "`"type`"`: `"$(Get-WikiType -file $_)`"," +
        "`n" +
        (Add-Tabstops ($Level+1)) +
        "`"name`"`: `"$($_.Name)`"," +
        "`n" +
        (Add-Tabstops ($Level+1)) +
        "`"children`": ["+
        $(if($_.psiscontainer){$children}) +
        "]`n" +
        (Add-Tabstops ($Level)) +
        "}")

        $node = New-Object PSObject -Property @{
            id = $id
            content = $content
            children = $nodes
        }

        return $node

    })
    return $nodes
}

function Get-FlatObjectTree{
    param($objectree)

    return ($objectree | ForEach-Object{
        
        $items =  @()
        $items += $_ | select content

        if($_.children -ne $null){
            $items += Get-FlatObjectTree $_.children
        }

        return $items
    })
}

$filepath = "H:\900 ILZ\000 Betrieb, Portfolio\37.20 Servicedesk\KB\data.json"
$filepath2 = "H:\900 ILZ\000 Betrieb, Portfolio\37.20 Servicedesk\KB\flatdata.json"

$items = Output-ObjectTree -Path "H:\900 ILZ\000 Betrieb, Portfolio\37.20 Servicedesk\KB\content\"
("[" + ((Get-FlatObjectTree $items | ForEach-Object{$_.content}) -join ",") + "]") | Set-Content -Path $filepath2 -Encoding UTF8


("[" + (Output-JsonChildren -Path "H:\900 ILZ\000 Betrieb, Portfolio\37.20 Servicedesk\KB\content\") + "]") | Set-Content -Path $filepath -Encoding UTF8
