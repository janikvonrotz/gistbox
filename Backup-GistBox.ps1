$url = "https://api.github.com/users/janikvonrotz/gists?page="
$root = "/Users/janikvonrotz/LocalDrive/GistBox"
$Metadata = @()

(1..11) | %{

  $gistUrl = ($url + $_)
  #Write-Host "Fetch gists from: $gistUrl"

  $gists = Invoke-Restmethod -Uri $gistUrl
  $gists | %{

    #$_.git_pull_url
    #($_.description).split("#")[0] -replace "`n","" -replace "`r","" -replace "`r`n","" -replace ":",""

    $pullUrl = $_.git_pull_url
    $name = ($_.description).split("#")[0] -replace "`n","" -replace "`r","" -replace "`r`n","" -replace ":",""
    $tags = ($_.description).split("#")[1..100] | %{"#$_" -replace "`n","" -replace "`r","" -replace "`r`n",""}
    $localPath = Join-Path $root $name

    if(Test-Path $localPath){

     cd ($localPath)
     Write-Host "Update gist: $($name)"
     git pull
     cd $root

    }else{

     cd $root
     Write-Host "Cloning gist: $($name)"
     git clone $pullUrl "$localPath" --quiet

    }

    $Metadata += @{name=$name;tags=$tags}
  }
}

$Metadata | ConvertTo-Json | Out-File Metadata.json -Encoding utf8
