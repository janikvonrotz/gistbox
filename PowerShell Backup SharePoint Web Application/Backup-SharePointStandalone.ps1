try{
  
    #--------------------------------------------------#
    # settings
    #--------------------------------------------------#
    $SQLBackupFolder = "E:\SQLExpress\MSSQL10_50.SQLEXPRESS\MSSQL\Backup"
    $SharePointBackupFolder = "E:\SharePoint\Backup"
    
    #--------------------------------------------------#
    # sql backup
    #--------------------------------------------------#
    Backup-AllSQLDBs -Path $SQLBackupFolder -Instance SQLExpress
    
    # delete old backups
    gci $SQLBackupFolder -Recurse | where{$_.PsIsContainer} | %{
        gci $_.FullName | where{-not $_.PsIsContainer} | sort CreationTime -Descending | select -Skip 1 | Remove-Item -Force
    }
    
    Write-PPEventLog -Message "Finished SQL Backup" -WriteMessage -Source "SharePoint and SQL Backup" 
    
    #--------------------------------------------------#
    # sharepoint backup
    #--------------------------------------------------#
    # backup lists
    Backup-AllSPLists -Path $SharePointBackupFolder
    
    # backup sites
    Backup-AllSPWebs -Path $SharePointBackupFolder
    
    # backup site collections
    Backup-AllSPSites -Path (Join-Path -Path $SharePointBackupFolder -ChildPath "Full")
    
    # delete old backups
    gci $SharePointBackupFolder -Recurse | where{$_.PsIsContainer} | %{
        gci $_.FullName | where{-not $_.PsIsContainer} | sort CreationTime -Descending | select -Skip 1 | Remove-Item -Force
    }
    
}catch{
  
    Write-PPEventLog -Message "Finished SharePoint Backup" -WriteMessage -Source "SharePoint and SQL Backup" 
    Write-PPErrorEventLog -Source "SharePoint and SQL Backup" -ClearErrorVariable
}