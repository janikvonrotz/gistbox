Public Function TabellenUmbenennen()

' Diese Funktion benennt alle Tabelle um und
' schneidet den vorgestellten Text "dbo_" ab.

Dim tdfLoop
Dim NewName As String

    For Each tdfLoop In CurrentDb().TableDefs
        If Left(tdfLoop.Name, 4) = "dbo_" Then
        NewName = Mid(tdfLoop.Name, 5, 50)
       
            DoCmd.Rename NewName, acTable, tdfLoop.Name
            TabellenUmbenennen = TabellenUmbenennen + 1
        End If
    Next tdfLoop

End Function
