  $Usernames = @()

	While(1){
		$Username = Read-Host "`nEnter a username (or . to finish)"
		if($Username -eq "."){
			break
		}else{
		$Usernames += $Username	
		}
	}
