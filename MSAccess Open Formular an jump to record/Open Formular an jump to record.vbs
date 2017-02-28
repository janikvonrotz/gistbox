    'Öffnet ein Formular und springt zu Datensatz mit einer bestimmten ID
'OpenForm(vForm: zu öffnendes Formular, vIDControl: Steuerlement mit ID, vIDColumn: Legt Spalte mit ID in Zielformular fest
Public Sub OpenForm(vForm As String, vIDControl As Control, vIDColumn As String)

If Not IsNull(vIDControl) Then

        'Formular wird geöffnet
    If vForm <> "frmPumpe" Then
        DoCmd.OpenForm vForm, acFormDS
    End If
   
        'Zum bestimmten Datensatz springen
    Select Case (vForm)
    Case "frmAnrede"
        Forms!frmAnrede.Recordset.FindFirst vIDColumn & " = " & Nz(vIDControl, 0)
    Case "frmArchitekt"
        Forms!frmArchitekt.Recordset.FindFirst vIDColumn & " = " & Nz(vIDControl, 0)
    Case "frmArtGebühr"
        Forms!frmArtGebühr.Recordset.FindFirst vIDColumn & " = " & Nz(vIDControl, 0)
    Case "frmBewilligungsart"
        Forms!frmBewilligungsart.Recordset.FindFirst vIDColumn & " = " & Nz(vIDControl, 0)
    Case "frmBohrfirma"
        Forms!frmBohrfirma.Recordset.FindFirst vIDColumn & " = " & Nz(vIDControl, 0)
    Case "frmGemeinde"
        Forms!frmGemeinde.Recordset.FindFirst vIDColumn & " = " & Nz(vIDControl, 0)
    Case "frmGeologe"
        Forms!frmGeologe.Recordset.FindFirst vIDColumn & " = " & Nz(vIDControl, 0)
    Case "frmInstallateur"
        Forms!frmInstallateur.Recordset.FindFirst vIDColumn & " = " & Nz(vIDControl, 0)
    Case "frmOrt"
        Forms!frmOrt.Recordset.FindFirst vIDColumn & " = " & Nz(vIDControl, 0)
    Case "frmProjektingenieure"
        Forms!frmProjektingenieure.Recordset.FindFirst vIDColumn & " = " & Nz(vIDControl, 0)
    Case "frmPumpe"
        Forms!frmPumpe.Recordset.FindFirst vIDColumn & " = " & Nz(vIDControl, 0)
        DoCmd.OpenForm vForm, acNormal


    End Select
   
    Exit Sub

Else

        'Wenn ohne ID neuen Datensatz erstellen
    DoCmd.OpenForm vForm, acFormDS
    DoCmd.GoToRecord , vForm, acNewRec

End If


End Sub

Private Sub bt_mandanten_edit_Click()

OpenForm "frmMandant", Me.dd_Mandantenauswahl, "id_Mandant"

End Sub
