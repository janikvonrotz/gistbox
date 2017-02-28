$computername = "hostname"

Invoke-Command -ComputerName $computername -ScriptBlock { 
    $computer = $env:COMPUTERNAME
    $domain = "domain"
    $user = "username"
    $group = [ADSI]"WinNT://$computer/Remote Desktop Users,group"
    $group.psbase.Invoke("add",([ADSI]"WinNT://$domain/$user").Path) 
}
