Private Sub btAuswerten_Click()

'Folgende Auswertungen sind möglich:

'Datenblatt Anlage
'Auswertung Wasserzinsen
'Auswertung Kontrollrapport
'GIS-Erdsonden
'GIS-Grundwasser
'GIS-Erdregister & Erdpfähle

    'Ausgewählter Report
Dim ChoosedReport As String
    'Typ Ausgabe: Report oder Query
Dim OutputType As String

Select Case (Me.ddReportChoice)
   
    Case "Datenblatt Anlage"
        ChoosedReport = "repPumpe"
        OutputType = "Report"
       
    Case "Auswertung Wasserzinsen"
        ChoosedReport = "qryWasserzins"
        OutputType = "Query"
       
    Case "Auswertung Kontrollrapport"
        ChoosedReport = "qryKontrollrapport"
        OutputType = "Query"
       
    Case "GIS-Erdsonden"
        ChoosedReport = "qryGISErdsonden"
        OutputType = "Query"
       
    Case "GIS-Grundwasser"
        ChoosedReport = "qryGISGrundwasser"
        OutputType = "Query"
       
    Case "GIS-Erdregister & Erdpfähle"
        ChoosedReport = "qryGISErdregisterErdpfähle"
        OutputType = "Query"
       
     End Select
  
    'Schliessen des Wizards
DoCmd.Close acForm, Me.Name
  
    'Öffnen des Formulars
If OutputType = "Report" Then
    
     DoCmd.Close acReport, ChoosedReport, acSaveNo
     DoCmd.OpenReport ChoosedReport, acViewReport
    
ElseIf OutputType = "Query" Then

    DoCmd.Close acQuery, ChoosedReport, acSaveNo
    DoCmd.OpenQuery ChoosedReport, acViewNormal
   
End If

End Sub
