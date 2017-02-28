Public Sub VerweisErstellen(TableVerw As String, IDSource As String, IDSourceValue As Integer, IDDest As String, IDDestValue As Integer)

Dim db As DAO.Database
Set db = CurrentDb

    'Delete of all Register data in link table
    db.Execute "DELETE * FROM " & TableVerw & " WHERE " & IDSource & " = " & IDSourceValue, dbFailOnError
   
    'Link the Register to the selected value
    db.Execute "INSERT INTO " & TableVerw & " (" & IDSource & "," & IDDest & " ) VALUES(" & IDSourceValue & ", " & IDDestValue & ")"

End Sub
