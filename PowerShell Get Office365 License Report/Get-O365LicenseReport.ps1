#--------------------------------------------------#
# modules
#--------------------------------------------------#

Import-Module MSOnline
Import-Module MSOnlineExtended
Import-Module ActiveDirectory

#--------------------------------------------------#
# main
#--------------------------------------------------#

# declaration
$Licenses = @()

# import credentials
$Credential = Import-PSCredential $(Get-ChildItem -Path $PSconfigs.Path -Filter "Office365.credentials.config.xml" -Recurse).FullName

# SID is SPO_365Users
Write-Host "Get allowed ActiveDirectory users"
$AllowADUsers = Get-ADGroupMember "S-1-5-21-1744926098-708661255-2033415169-36655" -Recursive | Get-ADUser | where {$_.enabled -eq $true} | select userprincipalname # SPO_365Users

# connect to office365
Connect-MsolService -Credential $Credential

Write-Host "Get Office365 users"
$MSOUsers = Get-MsolUser -All

Write-Host "Get ExchangeOnline mailboxes"
# import session
$s = New-PSSession -ConfigurationName Microsoft.Exchange `
    -ConnectionUri https://ps.outlook.com/powershell `
    -Credential $(Get-Credential -Credential $Credential) `
    -Authentication Basic `
    -AllowRedirection
Import-PSSession $s

# get upn of every mailbox
$MSOMailboxes = Get-Mailbox | select UserPrincipalName

$MSOUsers | foreach{

    Write-Progress -Activity "Report licenses" -status $_.UserPrincipalName -percentComplete ([int]([array]::IndexOf(([array]$MSOUsers), $_)/([array]$MSOUsers).count*100))

    $UserPrincipleName = $_.UserPrincipalName

    $License = $_ | Select-Object -Property UserPrincipalName,         
    @{ Name = "Package";
        Expression = {
            $_.Licenses | ForEach-Object{$_.AccountSkuId}
        }
    },
    @{ Name = "Licenses";
        Expression = {
            $_.Licenses | ForEach-Object{
                $_.ServiceStatus | Where-Object{$_.ProvisioningStatus -ne "Disabled"}
            } | ForEach-Object{
                $_.ServicePlan.ServiceName
            }
        }
    },
    @{ Name = "IsAllowedOffice365User";
        Expression = {
            if($AllowADUsers -match $UserPrincipleName){$true}else{$false}
        }
    },
    @{ Name = "HasMailboxInCloud";
        Expression = {
            if($MSOMailboxes -match $UserPrincipleName){$true}else{$false}
        }
    }
        
    $Licenses += $License
} 

$Licenses | Out-GridView

if($error){

    Send-PPErrorReport -FileName "DirSync.mail.config.xml" -ScriptName $MyInvocation.InvocationName

}