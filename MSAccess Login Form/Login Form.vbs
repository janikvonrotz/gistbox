Option Explicit
Option Compare Database
Private intLogonAttempts As Integer

Private Sub Form_Current()
     'On open set focus to combo box
    Me.bt_Login.SetFocus
    intLogonAttempts = 0
End Sub


Private Sub dd_UserAuswahl_AfterUpdate()
     'After selecting user name set focus to password field
    Me.tb_Password.SetFocus
End Sub

Public Sub bt_Login_Click()
    
     'Check to see if data is entered into the UserName combo box
    
    If IsNull(Me.dd_AuswahlUser) Then
        MsgBox "User Name is a required field.", vbOKOnly, "Required Data"
        Me.dd_AuswahlUser.SetFocus
        Exit Sub
    End If
    
     'Check to see if data is entered into the password box
    
    If IsNull(Me.tb_Password) Then
        MsgBox "Password is a required field.", vbOKOnly, "Required Data"
        Me.tb_Password.SetFocus
        Exit Sub
    End If
    
     'Check value of password in tblEmployees to see if this matches value chosen in combo box
    
    If MD5.MD5_string(Me.tb_Password.value) = DLookup("Password", "tbladmUser", "[id_User]=" & Me.dd_AuswahlUser.value) Then
        
        GlobalVar.UserID = Me.dd_AuswahlUser.value
       
        'Zurücksetzen der MandatenauswahlID, falls am gleichen Computereingeloogt wird.
        GlobalVar.MandantenAuswahlID = 0
        
        'Close logon form and open splash screen (could be Switchboard or another form instead)
        
        DoCmd.Close acForm, "frmLogon", acSaveNo 'substitute correct name if using
         'form other than frmLogon in the example.
        
        DoCmd.OpenForm "frmRegister" 'substitute correct name if using switch
         'board or other form.
        
    Else
        MsgBox "Password Invalid.  Please Try Again", vbOKOnly, "Invalid Entry!"
        Me.tb_Password.SetFocus
    End If
    
     'If User Enters incorrect password 3 times database will shutdown
    
    intLogonAttempts = intLogonAttempts + 1
    If intLogonAttempts = 3 Then
        MsgBox "You do not have access to this database.  Please contact your system administrator.", vbCritical, "Access to Access is Restricted!"
        Application.Quit
    End If
    
End Sub
