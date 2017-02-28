Get-SPsite -Limit all | %{
    $_ |  Get-SPWeb -Limit all | %{
        $_.Lists | %{
            $_    
        }
    }
}
