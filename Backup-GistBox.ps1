[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

# declar variables
$url = "https://api.github.com/users/janikvonrotz/gists?page="
$root = $PSScriptRoot
$metadata = @()


(1..12) | ForEach-Object {

	$gistUrl = ($url + $_)
	$gists = Invoke-Restmethod -Uri $gistUrl

	$gists | ForEach-Object {

		# get metadata
		$name = ($_.description).split("#")[0] -replace "`n","" -replace "`r","" -replace "`r`n","" -replace ":",""
		$tags = ($_.description).split("#")[1..100] | %{"#$_" -replace "`n","" -replace "`r","" -replace "`r`n",""}
		$metadata += @{name=$name;tags=$tags}

		# create git directory if it does not exist
		$localPath = Join-Path $root $name
		if(!(Test-Path -Path $localPath)){
			New-Item -ItemType directory -Path $localPath
		}

		# get pull url, clone repo or if it exists pull master
		$pullUrl = $_.git_pull_url
		if(Test-Path -Path $(Join-Path $localPath ".git")){
			cd $localPath
			Write-Host "Pull gist: $($name)"
			git pull
		} else {
			cd $root
			Write-Host "Cloning gist: $($name)"
			git clone $pullUrl "$localPath" --quiet
		}
	}
}

$metadata | ConvertTo-Json | Out-File metadata.json -Encoding utf8
