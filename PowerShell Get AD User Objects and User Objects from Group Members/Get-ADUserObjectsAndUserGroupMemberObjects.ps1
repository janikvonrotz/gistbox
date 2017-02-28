"ADGroup", "User1" | %{

    Get-ADObject -Filter {Name -eq $_} | %{
        
        if($_.ObjectClass -eq "user"){
            
            Get-ADUser $_.DistinguishedName
            
        }elseif($_.ObjectClass -eq "group"){
        
            Get-ADGroupMember $_.DistinguishedName -Recursive | Get-ADUser 
        }
    }
}
