# Check for executeable
if ((Get-Command "cmdkey.exe") -and (Get-Command "mstsc.exe"))  { }

# Execute with Powershell version 2 instead of version 3 and higher
if($Host.Version.Major -gt 2){
  powershell -Version 2 $MyInvocation.MyCommand.Definition
	exit
}

# only powershell 2 and higher
if($Host.Version.Major -lt 2){
    throw "Only compatible with Powershell version 2 and higher"
}else{
}

