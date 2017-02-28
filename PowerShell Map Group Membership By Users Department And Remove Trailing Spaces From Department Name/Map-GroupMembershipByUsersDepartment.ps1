Import-Module activedirectory

$Groups = @(

    @{
        Department = "Fahrdienst A"
        Group = "Fahrdienst A - Weickart Markus Gruppe"
        DistGroup = "Fahrdienst A - Weickart Markus"
    },

    @{
        Department = "Fahrdienst B"
        Group = "Fahrdienst B - Nietlispach Marco Gruppe"
        DistGroup = "Fahrdienst B - Nietlispach Marco"
    },
    
    @{
        Department = "Fahrdienst C"
        Group = "Fahrdienst C - Habegger Rolf Gruppe"
        DistGroup = "Fahrdienst C - Habegger Rolf"
    },
    
    @{
        Department = "Fahrdienst D"
        Group = "Fahrdienst D - Wechsler Josef Gruppe"
        DistGroup = "Fahrdienst D - Wechsler Josef"
    },
    
    @{
        Department = "Fahrdienst E"
        Group = "Fahrdienst E - Brunner Ronald Gruppe"
        DistGroup = "Fahrdienst E - Brunner Ronald"
    },
    
    @{
        Department = "Fahrdienst F"
        Group = "Fahrdienst F - Bieri René Gruppe"
        DistGroup = "Fahrdienst F - Bieri René"
    }
)

$Groups | %{

     Remove-ADGroupMember -Identity $_.Group -Members $(Get-ADGroupMember -Identity $_.Group) -Confirm:$false
     Remove-ADGroupMember -Identity $_.DistGroup -Members $(Get-ADGroupMember -Identity $_.DistGroup) -Confirm:$false
}

Get-ADUser -SearchScope OneLevel -SearchBase "OU=Fahrdienst,OU=Betrieb,OU=vblusers2,DC=vbl,DC=ch" -filter * -properties department, Enabled | sort department | where{$_.Enabled} | %{

    $User = $_
    
    $Result = $true

    $Groups | where{$_.Department -eq $User.Department -or (($User.Department).trimend(" ") -eq $_.Department)} | %{
    
        [char[]]$Department = $User.Department
        if($Department[($Department).Length -1] -eq " "){
            Set-ADUser -Identity $User -Department ($User.Department).trimend(" ")
        }
    
        $_.Department
    
        Add-ADGroupMember -Identity $_.Group -Members $User
        Add-ADGroupMember -Identity $_.DistGroup -Members $User 
        
        $Result  = $false
    }
    
    if($Result){throw "Problem with User: $($_.Name)"}
}