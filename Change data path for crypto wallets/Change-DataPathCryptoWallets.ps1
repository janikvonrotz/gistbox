New-Hardlink -LiteralPath (Get-Path "%APPDATA%\Litecoin\wallet.dat") -TargetPath "H:\SkyDrive\Shared\Data\Litecoin\wallet.dat"

New-Hardlink -LiteralPath (Get-Path "%APPDATA%\PPcoin\wallet.dat") -TargetPath "H:\SkyDrive\Shared\Data\PPcoin\wallet.dat"

New-Hardlink -LiteralPath (Get-Path "%APPDATA%\Bitcoin\wallet.dat") -TargetPath "H:\SkyDrive\Shared\Data\Bitcoin\wallet.dat"

Remove-Item -Path (Get-Path "%APPDATA%\Dogecoin\wallet.dat")
New-Hardlink -LiteralPath (Get-Path "%APPDATA%\Dogecoin\wallet.dat") -TargetPath "C:\OneDrive\Shared\Data\Dogecoin Core\wallet.dat"