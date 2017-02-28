Import-Module ActiveDirectory

Get-ADGroup -Filter * -SearchBase "OU=Intranet,OU=SharePoint,OU=Services,OU=vblusers2,DC=vbl,DC=ch" | ForEach-Object{

    if($_.Name.EndsWith("#Edit")){
    
        # rename
        $_ | Rename-ADObject -NewName ($_.Name -replace "#Edit", "#Contribute")  -Verbose
    
    }
}