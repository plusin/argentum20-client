VERSION 5.00
Begin VB.Form frmComerciar 
   BackColor       =   &H00000000&
   BorderStyle     =   0  'None
   Caption         =   "Comerciando con el NPC"
   ClientHeight    =   7110
   ClientLeft      =   0
   ClientTop       =   0
   ClientWidth     =   8130
   LinkTopic       =   "Form1"
   MaxButton       =   0   'False
   MinButton       =   0   'False
   ScaleHeight     =   474
   ScaleMode       =   3  'Pixel
   ScaleWidth      =   542
   ShowInTaskbar   =   0   'False
   StartUpPosition =   1  'CenterOwner
   Begin VB.PictureBox interface 
      Appearance      =   0  'Flat
      AutoRedraw      =   -1  'True
      BackColor       =   &H00000000&
      BorderStyle     =   0  'None
      CausesValidation=   0   'False
      ClipControls    =   0   'False
      BeginProperty Font 
         Name            =   "MS Sans Serif"
         Size            =   8.25
         Charset         =   0
         Weight          =   700
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      ForeColor       =   &H80000008&
      Height          =   4650
      Left            =   240
      MousePointer    =   99  'Custom
      ScaleHeight     =   310
      ScaleMode       =   3  'Pixel
      ScaleWidth      =   507
      TabIndex        =   1
      Top             =   1680
      Width           =   7605
   End
   Begin VB.TextBox cantidad 
      Alignment       =   2  'Center
      Appearance      =   0  'Flat
      BackColor       =   &H00000000&
      BorderStyle     =   0  'None
      BeginProperty Font 
         Name            =   "Arial"
         Size            =   8.25
         Charset         =   0
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      ForeColor       =   &H00FFFFFF&
      Height          =   210
      Left            =   3615
      TabIndex        =   0
      Text            =   "1"
      Top             =   6645
      Width           =   825
   End
   Begin VB.Image Image1 
      Height          =   495
      Index           =   1
      Left            =   5250
      Tag             =   "0"
      Top             =   6495
      Width           =   1815
   End
   Begin VB.Image Image1 
      Height          =   495
      Index           =   0
      Left            =   960
      Tag             =   "0"
      Top             =   6510
      Width           =   2235
   End
End
Attribute VB_Name = "frmComerciar"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False


Option Explicit
Const WM_SYSCOMMAND As Long = &H112&
Const MOUSE_MOVE As Long = &HF012&

Private Declare Function ReleaseCapture Lib "user32" () As Long
Private Declare Function SendMessage Lib "user32" Alias "SendMessageA" _
        (ByVal hwnd As Long, ByVal wMsg As Long, _
        ByVal wParam As Long, lParam As Long) As Long
Public LastIndex1 As Integer

Public LasActionBuy As Boolean

' Declaro los inventarios ac� para poder manejar los eventos de drop
Public WithEvents InvComUsu As clsGrapchicalInventory ' Inventario del usuario visible en el comercio
Attribute InvComUsu.VB_VarHelpID = -1
Public WithEvents InvComNpc As clsGrapchicalInventory ' Inventario con los items que ofrece el npc
Attribute InvComNpc.VB_VarHelpID = -1

Private Sub moverForm()
    Dim res As Long
    ReleaseCapture
    res = SendMessage(Me.hwnd, WM_SYSCOMMAND, MOUSE_MOVE, 0)
End Sub
Private Sub cantidad_KeyPress(KeyAscii As Integer)
If (KeyAscii = 27) Then
    Unload Me
End If
If (KeyAscii <> 8) Then
    If (KeyAscii <> 6) And (KeyAscii < 48 Or KeyAscii > 57) Then
        KeyAscii = 0
    End If
End If
End Sub

Private Sub Form_KeyPress(KeyAscii As Integer)
If (KeyAscii = 27) Then
    Unload Me
End If
End Sub
Private Sub Image1_Click(Index As Integer)
    Call Sound.Sound_Play(SND_CLICK)
    
    If Not IsNumeric(cantidad.Text) Or cantidad.Text = 0 Then Exit Sub

    Select Case Index
        Case 0
            If InvComNpc.SelectedItem <= 0 Then Exit Sub
 
            LasActionBuy = True

            If UserGLD >= InvComNpc.Valor(InvComNpc.SelectedItem) * Val(cantidad) Then
                Call WriteCommerceBuy(InvComNpc.SelectedItem, cantidad.Text)
            Else
                AddtoRichTextBox frmmain.RecTxt, "No ten�s suficiente oro.", 2, 51, 223, 1, 1
            End If
       
       Case 1
            If InvComUsu.SelectedItem <= 0 Then Exit Sub
            
            LasActionBuy = False
            
            Call WriteCommerceSell(InvComUsu.SelectedItem, max(Val(cantidad.Text), InvComUsu.Amount(InvComUsu.SelectedItem)))
    End Select
    
End Sub
Private Sub Form_Load()
Call FormParser.Parse_Form(Me)
End Sub

Private Sub Form_MouseMove(Button As Integer, Shift As Integer, x As Single, y As Single)
moverForm
If Image1(0).Tag = "1" Then
   Image1(0).Picture = Nothing
   Image1(0).Tag = "0"
End If
If Image1(1).Tag = "1" Then
    Image1(1).Picture = Nothing
    Image1(1).Tag = "0"
End If
End Sub
Private Sub addRemove_Click(Index As Integer)
Call Sound.Sound_Play(SND_CLICK)
Select Case Index
    Case 0
        cantidad = cantidad - 1
    Case 1
        cantidad = cantidad + 1
    End Select
End Sub
Private Sub cantidad_Change()
    If Val(cantidad.Text) < 1 Then
        cantidad.Text = 1
    End If
    If Val(cantidad.Text) > MAX_INVENTORY_OBJS Then
        cantidad.Text = MAX_INVENTORY_OBJS
        cantidad.SelStart = Len(cantidad.Text)
    End If
End Sub

Private Sub Form_Unload(Cancel As Integer)
    Call WriteCommerceEnd
End Sub

Private Sub Image1_MouseDown(Index As Integer, Button As Integer, Shift As Integer, x As Single, y As Single)
If Index = 0 Then
        Image1(0).Picture = LoadInterface("comprarwidepress.bmp")
        Image1(0).Tag = "0"
Else
        Image1(1).Picture = LoadInterface("venderwidepress.bmp")
        Image1(1).Tag = "0"
End If
End Sub
Private Sub Image1_MouseMove(Index As Integer, Button As Integer, Shift As Integer, x As Single, y As Single)
If Index = 0 Then
    If Image1(0).Tag = "0" Then
        Image1(0).Picture = LoadInterface("comprarwidehover.bmp")
        Image1(0).Tag = "1"
    End If
Else
    
    If Image1(1).Tag = "0" Then
        Image1(1).Picture = LoadInterface("venderwidehover.bmp")
        Image1(1).Tag = "1"
    End If
End If
End Sub

Private Sub interface_Click()
    
    If InvComNpc.ClickedInside Then
        ' Clique� en la tienda, deselecciono el inventario
        Call InvComUsu.SeleccionarItem(0)
        
    ElseIf InvComUsu.ClickedInside Then
        ' Clique� en el inventario, deselecciono la tienda
        Call InvComNpc.SeleccionarItem(0)
    End If

End Sub

Private Sub interface_DblClick()

    If InvComNpc.ClickedInside Then
    
        LasActionBuy = True

        If UserGLD >= InvComNpc.Valor(InvComNpc.SelectedItem) * Val(cantidad) Then
            Call WriteCommerceBuy(InvComNpc.SelectedItem, cantidad.Text)
        Else
            AddtoRichTextBox frmmain.RecTxt, "No ten�s suficiente oro.", 2, 51, 223, 1, 1
        End If
        
    ElseIf InvComUsu.ClickedInside Then
    
        ' Hacemos acci�n del doble clic correspondiente
        Dim ObjType As Byte
        ObjType = ObjData(InvComUsu.OBJIndex(InvComUsu.SelectedItem)).ObjType
        
        If Not IntervaloPermiteUsar Then Exit Sub
        
        Select Case ObjType
            Case eObjType.otArmadura, eObjType.otESCUDO, eObjType.OtHerramientas, eObjType.otmagicos, eObjType.otFlechas, eObjType.otCASCO, eObjType.otNudillos
                Call EquiparItem
                
            Case eObjType.otWeapon
                If ObjData(InvComUsu.OBJIndex(InvComUsu.SelectedItem)).proyectil = 1 And InvComUsu.Equipped(InvComUsu.SelectedItem) Then
                    Call UsarItem
                ElseIf Not InvComUsu.Equipped(InvComUsu.SelectedItem) Then
                    Call EquiparItem
                End If
                 
            Case Else
                Call UsarItem
        End Select
    End If

End Sub


Private Sub interface_KeyDown(KeyCode As Integer, Shift As Integer)

    ' Referencia temporal al inventario que corresponda
    Dim CurrentInventory As clsGrapchicalInventory

    If InvComNpc.ClickedInside Then
        Set CurrentInventory = InvComNpc
    ElseIf InvComUsu.ClickedInside Then
        Set CurrentInventory = InvComUsu
    Else
        Exit Sub
    End If

    ' Procesamos las teclas para moverse por el inventario
    Select Case KeyCode
    
        Case vbKeyRight
            If CurrentInventory.SelectedItem < CurrentInventory.MaxSlots Then
                Call CurrentInventory.SeleccionarItem(CurrentInventory.SelectedItem + 1)
            End If
            
        Case vbKeyLeft
            If CurrentInventory.SelectedItem > 1 Then
                Call CurrentInventory.SeleccionarItem(CurrentInventory.SelectedItem - 1)
            End If
            
        Case vbKeyUp
            If CurrentInventory.SelectedItem > CurrentInventory.Columns Then
                Call CurrentInventory.SeleccionarItem(CurrentInventory.SelectedItem - CurrentInventory.Columns)
            End If
            
        Case vbKeyDown
            If CurrentInventory.SelectedItem < CurrentInventory.MaxSlots - CurrentInventory.Columns Then
                Call CurrentInventory.SeleccionarItem(CurrentInventory.SelectedItem + CurrentInventory.Columns)
            End If
    
    End Select
    
    ' Limpiamos
    Set CurrentInventory = Nothing

End Sub

Private Sub InvComUsu_ItemDropped(ByVal Drag As Integer, ByVal Drop As Integer, ByVal x As Integer, ByVal y As Integer)

    ' Si solt� dentro del mismo inventario
    If Drop > 0 Then
        ' Movemos el item dentro del inventario
        Call WriteItemMove(Drag, Drop)
    Else
        ' Si lo solt� dentro de la tienda
        If InvComNpc.GetSlot(x, y) > 0 Then
            ' Vendemos el item
            LasActionBuy = False
            Call WriteCommerceSell(Drag, max(Val(cantidad.Text), InvComUsu.Amount(InvComUsu.SelectedItem)))
        End If
    End If

End Sub

Private Sub InvComNpc_ItemDropped(ByVal Drag As Integer, ByVal Drop As Integer, ByVal x As Integer, ByVal y As Integer)

    ' Si lo solt� dentro del inventario
    If InvComUsu.GetSlot(x, y) > 0 Then
        ' Compramos el item
        LasActionBuy = True
        ' Si tiene suficiente oro
        If UserGLD >= InvComNpc.Valor(Drag) * Val(cantidad.Text) Then
            Call WriteCommerceBuy(Drag, Val(cantidad.Text))
        Else
            AddtoRichTextBox frmmain.RecTxt, "No ten�s suficiente oro.", 2, 51, 223, 1, 1
        End If
    End If

End Sub