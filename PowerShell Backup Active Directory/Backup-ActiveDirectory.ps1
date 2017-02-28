<#
$Metadata = @{
	Title = "Backup ActiveDirecotry"
	Filename = "Backup-ActiveDirectory.ps1"
	Description = ""
	Tags = "backup, active, directory, ntsutil"
	Project = ""
	Author = "Janik von Rotz"
	AuthorContact = "http://janikvonrotz.ch"
	CreateDate = "2014-04-15"
	LastEditDate = "2014-04-15"
	Url = ""
	Version = "0.0.0"
	License = @'
This work is licensed under the Creative Commons Attribution-ShareAlike 3.0 Switzerland License.
To view a copy of this license, visit http://creativecommons.org/licenses/by-sa/3.0/ch/ or 
send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
'@
}
#>

try{

    <#
    #--------------------------------------------------#
	# about
	#--------------------------------------------------#
    
    The restore and backup process is described here: http://technet.microsoft.com/en-us/library/dd581644(WS.10).aspx
    
    #>
    
    #--------------------------------------------------#
	# settings
	#--------------------------------------------------#

    $Path = "C:\backup\ActiveDirectory"

	#--------------------------------------------------#
	# main
	#--------------------------------------------------#

    # create backup file name
    $Filename = "ADBackupFull" + "#" + $((Get-Date -Format s) -replace ":","-") + ".bak"
    $Filepath = Join-Path $Path $Filename

    # backup active directory
    Invoke-Expression 'ntdsutil "activate instance ntds" ifm "create full $Filepath" quit quit'
    
    # get dates for backup retention exclusion
    $Today = Get-Date -Format d
    $FirstDateOfWeek = Get-Date (Get-Date).AddDays(-[int](Get-Date).Dayofweek) -Format d
    $FirstDateOfMonth = Get-Date -Day 1 -Format d

    # delete all backups except for today, first day of week and first day of month
    Get-ChildItem $Path | select *,@{L="CreationTimeDate";E={Get-Date $_.CreationTime -Format d}} | Group-Object CreationTimeDate | %{
        
        # only one backup per day
        if($_.Count -gt 1){
            
            $_.Group | Sort-Object CreationTime -Descending | Select-Object -Skip 1     
        }
                
        # keep only required backups
        $_.Group | Where-Object{$_.CreationTimeDate -ne $Today -and $_.CreationTimeDate -ne $FirstDateOfWeek -and $_.CreationTimeDate -ne $FirstDateOfMonth}
            
    } | Remove-Item -Recurse -Force
    
}catch{

    Write-PPErrorEventLog -Source "Backup ActiveDirectory" -ClearErrorVariable
}