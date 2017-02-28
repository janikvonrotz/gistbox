# import all mdoules
Get-Module -ListAvailable | Import-Module

# show module commands
Get-Command –Module grouppolicy

#--------------------------------------------------#
# SharePoint
#--------------------------------------------------#
if(-not (Get-PSSnapin "Microsoft.SharePoint.PowerShell" -ErrorAction SilentlyContinue)){Add-PSSnapin "Microsoft.SharePoint.PowerShell"}

#--------------------------------------------------#
# SqlServer
#--------------------------------------------------#
if((Get-PSSnapin SqlServerCmdletSnapin100 -ErrorAction SilentlyContinue) -eq $Null){Add-PSSnapin SqlServerCmdletSnapin100}
if((Get-PSSnapin SqlServerProviderSnapin100 -ErrorAction SilentlyContinue) -eq $Null){Add-PSSnapin SqlServerProviderSnapin100}

#--------------------------------------------------#
# Quest ActiveDirectory
#--------------------------------------------------#
Import-Module Quest.ActiveRoles.ArsPowerShellSnapIn

#--------------------------------------------------#
# ActiveDirectory
#--------------------------------------------------#
Import-Module ActiveDirectory

#--------------------------------------------------#
# Windows Server Manager
#--------------------------------------------------#
Import-Module ServerManager

#--------------------------------------------------#
# Windows Server GroupPolicy
#--------------------------------------------------#
Import-Module GroupPolicy 

#--------------------------------------------------#
# VMware vSphere PowerCLI
#--------------------------------------------------#
if((Get-PSSnapin VMware.VimAutomation.Core -ErrorAction SilentlyContinue) -eq $Null){Add-PSSnapin VMware.VimAutomation.Core}
if((Get-PSSnapin VMware.VimAutomation.Vds -ErrorAction SilentlyContinue) -eq $Null){Add-PSSnapin VMware.VimAutomation.Vds}