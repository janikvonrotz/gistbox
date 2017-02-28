function Get-FolderSize{

    Begin{
     
        $fso = New-Object -comobject Scripting.FileSystemObject
    }

    Process{

        $Path =  $input.Fullname
        $Folder = $Fso.GetFolder($Path)
        $Size = $Folder.Size
        [PSCustomObject]@{Name = $Path;Size = (Format-FileSize $Size)}
    }
}

Get-ChildItem -Directory -Recurse -ErrorAction Ignore | Get-FolderSize | sort size -Descending