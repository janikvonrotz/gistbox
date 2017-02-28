# keep latest 3 files in each folder of an directory tree

Get-ChildItem $Path -Recurse | Where-Object{$_.PsIsContainer} | %{
    Get-ChildItem $_.FullName | Where-Object{-not $_.PsIsContainer} | Sort-Object CreationTime -Descending | Select-Object -Skip 3 | Remove-Item -Force
}

# delete all backups except for today, first day of week and first day of month

Get-ChildItem $Path | select *,@{L="CreationTimeDate";E={Get-Date $_.CreationTime -Format d}} | Group-Object CreationTimeDate | %{
    
    # only one backup per day
    if($_.Count -gt 1){
        
        $_.Group | Sort-Object CreationTime -Descending | Select-Object -Skip 1     
    }
            
    # keep only required backups
    $_.Group | Where-Object{$_.CreationTimeDate -ne $Today -or $_.CreationTimeDate -ne $FirstDateOfWeek -or $_.CreationTimeDate -ne $FirstDateOfMonth}
        
} | Remove-Item -Recurse -Force