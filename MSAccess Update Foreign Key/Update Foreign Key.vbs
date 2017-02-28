Public Sub ListVerweisAktualisieren(ListControl As Control, TableName As String, TableLinkName As String, Values As Variant, IDDataSet As String, IDDataSetName As String, LinkDataSetName As String)

    Dim db As DAO.Database
    Set db = CurrentDb
   
    Dim AnzahlItems As Integer
    AnzahlItems = ListControl.ListCount
   
    Dim ValueIndex As Integer
    ValueIndex = 0
   
    'Delete of all Register data in link table
    db.Execute "DELETE * FROM " & TableLinkName & " WHERE " & IDDataSetName & " = " & IDDataSet, dbFailOnError
   
    For x = 0 To AnzahlItems - 1
        If ListControl.Selected(x) = True Then
             
            'Link the Register to the selected value
            db.Execute "INSERT INTO " & TableLinkName & " (" & IDDataSetName & "," & LinkDataSetName & " ) VALUES(" & IDDataSet & ", " & Values(ValueIndex) & ")"
           
            ValueIndex = ValueIndex + 1
           
        End If
    Next x

End Sub
