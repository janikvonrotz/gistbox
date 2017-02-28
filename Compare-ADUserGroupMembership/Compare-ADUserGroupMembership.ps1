Import-Module ActiveDirectory

$user1 = "userRef"
$user2 = "userDif"

$members1 = Get-ADPrincipalGroupMembership -Identity $user1 | Select-Object name
$members2 = Get-ADPrincipalGroupMembership -Identity $user2 | Select-Object name

$result = Compare-Object -ReferenceObject $members1 -DifferenceObject $members2 -Property name

Write-Host "`n$user1 is member of these groups in addition:" -ForegroundColor Black -BackgroundColor Yellow

$result | Where-Object{$_.SideIndicator -eq "<="} | ForEach-Object{$_.name}

Write-Host "`n$user2 is member of these goups in addition:" -ForegroundColor Black -BackgroundColor Yellow

$result | Where-Object{$_.SideIndicator -eq "=>"} | ForEach-Object{$_.name}