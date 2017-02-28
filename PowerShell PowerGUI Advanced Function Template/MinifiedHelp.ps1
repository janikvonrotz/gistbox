<#
.SYNOPSIS
  Sends a default error Report based on the PowerShell Profile configurations.

.DESCRIPTION
  Sends a default error Report based on the PowerShell Profile configurations.

.PARAMETER  FileName
	The description of the ParameterA parameter.

.PARAMETER  ScriptName
	The description of the ParameterB parameter.

.EXAMPLE
	PS C:\> Send-PPErrorReport -FileName "Office365.mail.config.xml" -ScriptName $MyInvocation.InvocationName

.NOTES
	The name of the configuration in the config file has to be "ErrorReport"
#>