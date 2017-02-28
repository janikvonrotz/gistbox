$Metadata = @{
	Title = "Backup To External Drive"
	Filename = "BackpTo-ExternalDrive.ps1"
	Description = ""
	Tags = ""
	Project = ""
	Author = "Janik von Rotz"
	AuthorContact = "http://janikvonrotz.ch"
	CreateDate = "2013-01-20"
	LastEditDate = "2014-09-25"
	Version = "2.0.0"
	License = @'
This work is licensed under the Creative Commons Attribution-NonCommercial-NoDerivs 3.0 Unported License.
To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-nd/3.0/ or
send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
'@

}

$FilterFolder = "lwc"
$SourcePath = @("C:\OneDrive","C:\Local")
$SourceDrive = "C:\\"

get-PSDrive | %{
	if(Test-Path ($_.Root + $FilterFolder)){
		$DestPath = $(Join-Path $_.Root $FilterFolder)
	}
}

$Null = Read-Host "Copy from $SourcePath to $DestPath"

$SourcePath | %{
	$Destination = Join-Path $DestPath ($_ -replace $SourceDrive, "")	
	Write-host "Copy from $_ to $Destination"	
	& Robocopy $_ $Destination /MIR /R:1 /W:0
}