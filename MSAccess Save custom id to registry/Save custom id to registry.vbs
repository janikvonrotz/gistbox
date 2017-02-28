Private Sub Form_Load()

    'Identifikatoren zur eindeutigen Speicherung in der Registry
Dim PumpeLoadID As Integer
Dim NameOption As String

    'Erstellen des eindeutigen Schlüssels
NameOption = "tblpumpe.idPumpe" & Environ("USERNAME")

    'Lädt die Einstellung
PumpeLoadID = CInt(GetSetting("WPDB", "Optionen", NameOption, 0))

If Not PumpeLoadID = 0 Then
       
    Forms!frmPumpe.Recordset.FindFirst Me.idPumpe.Name & " = " & Nz(PumpeLoadID, 0)
   
End If

End Sub

Private Sub Form_Unload(Cancel As Integer)

    'Identifikatoren zur eindeutigen Speicherung in der Registry
Dim NameOption As String

    'Erstellen des eindeutigen Schlüssels
NameOption = "tblpumpe.idPumpe" & Environ("USERNAME")

'Speichert Einstellung in Registry
If Not Me.idPumpe = 0 Then

    SaveSetting "WPDB", "Optionen", NameOption, Str(Me.idPumpe)
   
End If

End Sub
