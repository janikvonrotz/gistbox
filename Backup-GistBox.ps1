$url = "https://api.github.com/users/janikvonrotz/gists?page="
$root = "./"

(1..10) | %{
   $gistPageUrl = $url + $_
   $gists = Invoke-Restmethod -Uri $gistPageUrl
   $gists | %{
       $pullUrl = $_.git_pull_url
       $name = ($_.description).split("#")[0] -replace "`n","" -replace "`r","" -replace "`r`n",""

       $localPath = (Join-Path $root $name) -replace ":",""

       if(Test-Path $localPath){

           cd ($localPath)
           Write-Host "Update GitHubGist $($name)"
           # git pull
           cd ..

       }else{

           Write-Host "Cloning GitHubGist $($name)"
           #git clone ($pullUrl) $localPath
       }
   }
}
