$X | Get-Member -MemberType Property | Select-Object -ExpandProperty Name | %{

    Compare-Object $X $Y -Property "$_" | Format-Table -AutoSize
}