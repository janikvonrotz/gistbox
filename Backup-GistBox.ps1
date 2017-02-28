$url = "https://api.github.com/users/janikvonrotz/gists?page="
$root = "/Users/janikvonrotz/LocalDrive/gistbox"
$Metadata = @()

(1..11) | %{

  $gistUrl = ($url + $_)
  $gists = Invoke-Restmethod -Uri $gistUrl

  $gists | %{

    $pullUrl = $_.git_pull_url
    $name = ($_.description).split("#")[0] -replace "`n","" -replace "`r","" -replace "`r`n","" -replace ":",""
    $tags = ($_.description).split("#")[1..100] | %{"#$_" -replace "`n","" -replace "`r","" -replace "`r`n",""}
    $localPath = Join-Path $root $name
    $gitFolder = Join-Path $localPath '.git'

    cd $root
    Write-Host "Cloning gist: $($name)"
    git clone $pullUrl "$localPath" --quiet
    
    if(($localPath -ne "") -and (Test-Path $gitFolder)) {
      Write-Host "Remove folder $($gitFolder)"
      Remove-Item $gitFolder  -Recurse -Force -Confirm:$false
    }

    $Metadata += @{name=$name;tags=$tags}
  }
}

$Metadata | ConvertTo-Json | Out-File Metadata.json -Encoding utf8
