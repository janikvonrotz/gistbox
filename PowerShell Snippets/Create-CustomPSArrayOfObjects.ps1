$Objects = @(

    $(New-Object PSObject -Property @{
        Name = "Objekt1"
        Value = "value1","value2"
    }),
    $(New-Object PSObject -Property @{
        Name = "Objekt2"
        Value = "value1","value2"
    })

)

$Objects2 = @(

     @{
        Name = "Objekt3"
        Value = "value1","value2"
    },
     @{
        Name = "Objekt4"
        Value = "value1","value2"
    }

)