Option Compare Database

    'Erstellt ein SQL Query anhand eines Suchbegriffs
   
'DataSearch (vSearchtabel: Zu durchsuchende Table, vSearchKey: Suchbegriff, vOrderby: Sortieren nach, vBlackList: Spalten ignorieren, vWhere: Where Condition, vFrom: From Condition
Public Sub DataSearch(vSearchtable As String, vSearchKey As String, vOrderby As String, vBlackList, vWhere As String, vFROM As String)

    'SQL Source Query
Dim strSQL As String

    'Select Part
Dim strSQLSelect As String

    'Where Part
Dim strSQLWhere As String

    'Sub vars
Dim First As Boolean
Dim Check As Integer

    'Initialisierung
First = False

    'Select Default Content
strSQLSelect = "SELECT "

    'Where Default Content, Man beachte die offene Klammer!
strSQLWhere = " WHERE ("

    'Code der die das SourceQuery zusammenstellt
Dim i As Integer
Dim rs As DAO.Recordset
Set rs = CurrentDb.OpenRecordset(vSearchtable, dbOpenSnapshot)
For i = 0 To rs.Fields.Count - 1
               
Check = InStr(1, vBlackList, rs.Fields(i).Name)
      
If Check = 0 Then

        'Erstes Feld wird speziell zusammengestellt
    If i = 0 Then
   
            'Erstellen der Where-condition
        strSQLWhere = strSQLWhere & "((" & rs.Fields(i).Name & ") LIKE  " & Chr(34) & "*" & vSearchKey & "*" & Chr(34) & ")"
   
             'Erstellen der Select-condition
             'Das Erste Select Element erhält kein Komma
        If First = False Then
            strSQLSelect = strSQLSelect & "(" & rs.Fields(i).Name & ")"
            First = True
        Else
            strSQLSelect = strSQLSelect & ", " & "(" & rs.Fields(i).Name & ")"
        End If
       
    ElseIf i < rs.Fields.Count Then
   
             'Erstellen der Where-condition
        strSQLWhere = strSQLWhere & " OR ((" & rs.Fields(i).Name & ") LIKE  " & Chr(34) & "*" & vSearchKey & "*" & Chr(34) & ")"
   
            'Erstellen der Select-condition
            'Das Erste Select Element erhält kein Komma
        If First = False Then
            strSQLSelect = strSQLSelect & "(" & rs.Fields(i).Name & ")"
            First = False
        Else
            strSQLSelect = strSQLSelect & ", " & "(" & rs.Fields(i).Name & ")"
        End If
       
    End If

End If
   
Next

    'Erstellten der From-condition
If vWhere = "" Then
    If vFROM = "" Then
        strSQL = strSQLSelect & " From " & vSearchtable & strSQLWhere & ")" & " ORDER BY " & vOrderby
    Else
        strSQL = strSQLSelect & vFROM & strSQLWhere & ")" & " ORDER BY " & vOrderby
    End If
Else
    If vFROM = "" Then
        strSQL = strSQLSelect & " From " & vSearchtable & strSQLWhere & ")" & vWhere & " ORDER BY " & vOrderby
    Else
        strSQL = strSQLSelect & vFROM & strSQLWhere & ")" & vWhere & " ORDER BY " & vOrderby
    End If
End If

    'Setze der SQL DataSource zur späteren Verwendung
Var.SetDataSource (strSQL)

    'Zur Kontrolle des SQL Queries
'Dim fs As Object
'Dim a As Object

'Set fs = CreateObject("Scripting.FileSystemObject")
'Set a = fs.CreateTextFile("C:\qry.txt", True)

'a.WriteLine strSQL
'a.Close
   
End Sub
'#--------------------------------------------------#
Private Sub DataSearch_Template()

'Config
Dim BlackList As String
BlackList = ""
Dim Searchtable As String
Searchtable = "tblAuskunftsperson"
Dim Orderby As String
Orderby = "id_Auskunftsperson"
Dim Where As String
Where = ""
Dim From As String
From = ""

If Not IsNull(Me.tb_SearchKey) Then

    DataSearch.DataSearch Searchtable, Me.tb_SearchKey, "id_Auskunftsperson", BlackList, Where, From

Else

    DataSearch.DataSearch Searchtable, "*", "frmAuskunftsperson", BlackList, Where, From

End If

End Sub
