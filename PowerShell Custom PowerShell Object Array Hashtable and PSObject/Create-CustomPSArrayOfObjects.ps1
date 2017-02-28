
$Objects = @{
    Name = "Objekt1"
    Value = "value1","value2"
},
@{
    Name = "Objekt2"
    Value = "value1","value2"
    
} | %{New-Object PSObject -Property $_}



$Objects = @{
    Name = "Objekt3"
    Value = "value1","value2"
},
@{
    Name = "Objekt4"
    Value = "value1","value2"
}