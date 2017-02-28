& KeePass (Get-Path "$($PSconfigs.Path)..\..\..\..\..\Data\keepass\KeepassData.kdbx") -preselect:((Mount-TrueCyptContainer -Name pc1).Drive + ":\KeePass\keepass_data.key")
Read-Host "`nPress any key to dismount the TrueCrypt drive"
Dismount-TrueCyptContainer -Name pc1