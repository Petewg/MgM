/*
 * MINIGUI - Harbour Win32 GUI library
 * Copyright 2002-2007 Roberto Lopez <harbourminigui@gmail.com>
 *
 * Copyright 2007 Grigory Filatov <gfilatov@inbox.ru>
*/

ANNOUNCE RDDSYS

#include <minigui.ch>

Static cIni, aData := {}, aAddress := {}, aSubject := {}
Static lStop := .f.

*--------------------------------------------------------*
Procedure Main
*--------------------------------------------------------*
	SET CENTERWINDOW RELATIVE PARENT

	cIni := GetStartupFolder()+"\config.ini"

	LOAD WINDOW Main

	Main.PROGRESSBAR_1.Enabled := .f.
	Main.PROGRESSBAR_2.Enabled := .f.
	Main.BUTTONEX_1.Enabled := .f.

	IF !File(cIni)
		CENTER WINDOW Main
	ENDIF

	ACTIVATE WINDOW Main

Return

*--------------------------------------------------------*
Procedure Config
*--------------------------------------------------------*

	LOAD WINDOW Config

	Config.TEXTBOX_1.Value := aData[1][1]
	Config.TEXTBOX_2.Value := aData[1][2]
	Config.TEXTBOX_3.Value := aData[1][3]
	Config.TEXTBOX_4.Value := aData[1][4]

	Config.CHECKBOX_1.Value := aData[2][1]
	Config.CHECKBOX_2.Value := aData[2][2]
	Config.CHECKBOX_3.Value := aData[2][3]
	Config.CHECKBOX_4.Value := aData[2][4]
	Config.CHECKBOX_5.Value := aData[2][5]
	IF aData[2][4] == .T.
		Main.TopMost := .F.
	ENDIF
	Config.TAB_1.SetFocus

	CENTER WINDOW Config
	ACTIVATE WINDOW Config

Return

*--------------------------------------------------------*
Procedure LoadData
*--------------------------------------------------------*
	Local nI, cInput := ""
	Local cHost := "", cPort := "", cEmail := "", cPass := ""
	Local lSave := .t., lPosition := .t., lSize := .t., lOnTop := .f., lSort := .t.
	Local nLeft := 0, nTop := 0, nWidth := 0, nHeight := 0

	BEGIN INI FILE cIni

		GET cHost SECTION "Config" ENTRY "Host" default "mail"

		GET cPort SECTION "Config" ENTRY "Port" default "25"

		GET cEmail SECTION "Config" ENTRY "Email" default ""

		GET cPass SECTION "Config" ENTRY "Password" default ""

		GET lOnTop SECTION "Config" ENTRY "OnTop" default lOnTop

		GET lSave SECTION "Config" ENTRY "SaveOnExit" default lSave

		GET lPosition SECTION "Config" ENTRY "Position" default lPosition

		GET lSize SECTION "Config" ENTRY "Size" default lSize

		GET lSort SECTION "Config" ENTRY "Sort" default lSort

		GET nLeft SECTION "Config" ENTRY "Left" default nLeft

		GET nTop SECTION "Config" ENTRY "Top" default nTop

		GET nWidth SECTION "Config" ENTRY "Width" default nWidth

		GET nHeight SECTION "Config" ENTRY "Height" default nHeight

		Aadd(aData, {cHost, cPort, cEmail, crypt(cPass)})
		Aadd(aData, {lSave, lPosition, lSize, lOnTop, lSort})

		For nI := 1 To 99
			GET cInput SECTION "Address History" ENTRY Ltrim(Str(nI, 2)) default ""
			IF !Empty(cInput)
				Aadd(aAddress, cInput)
			ELSE
				Exit
			ENDIF
		Next

		For nI := 1 To 99
			GET cInput SECTION "Subject History" ENTRY Ltrim(Str(nI, 2)) default ""
			IF !Empty(cInput)
				Aadd(aSubject, cInput)
			ELSE
				Exit
			ENDIF
		Next

	END INI

	IF lPosition
		IF !Empty(nLeft)
			Main.Col := nLeft
		ENDIF
		IF !Empty(nTop)
			Main.Row := nTop
		ENDIF
	ENDIF

	Main.MinWidth := 400
	Main.MinHeight := 300+IF(IsXPThemeActive(), 8, 0)
	IF lSize
		IF !Empty(nWidth)
			Main.Width := nWidth
		ENDIF

		IF !Empty(nHeight)
			Main.Height := nHeight
		ENDIF
	ENDIF

	Main.ComboBox_1.DeleteAllItems
	IF LEN(aAddress) > 0
		For nI := 1 To Len(aAddress)
			Main.ComboBox_1.AddItem(aAddress[nI])
		Next
		Main.ComboBox_1.Value := Main.ComboBox_1.ItemCount
	ENDIF

	Main.ComboBox_2.DeleteAllItems
	IF LEN(aSubject) > 0
		For nI := 1 To Len(aSubject)
			Main.ComboBox_2.AddItem(aSubject[nI])
		Next
		Main.ComboBox_2.Value := Main.ComboBox_2.ItemCount
	ENDIF

	OnTopMain()
	UpdateToolBtns()

Return

*--------------------------------------------------------*
Procedure OnTopMain()
*--------------------------------------------------------*
	IF aData[2][4] == .T.
		Main.TopMost := .T.
	ENDIF
Return

*--------------------------------------------------------*
Procedure GetItems
*--------------------------------------------------------*
	Local aFiles := {}, i
	Local cFile := GetFile( , , , .t. )

	IF !Empty(cFile)
		IF Valtype(cFile) # "A"
			Aadd(aFiles, cFile)
		ELSE
			aFiles := cFile
		ENDIF

        	For i=1 To Len(aFiles)
			DoMethod ( "Main" , "Grid_1" , 'AddItem' , { aFiles[i], Transform( FileSize(aFiles[i]), "999 999 999 999" ) } )
		Next

		UpdateToolBtns()
		UpdateStatus()
		Main.Tab_1.Value := 2

	ENDIF

Return

*--------------------------------------------------------*
Procedure DeleteItem
*--------------------------------------------------------*
	Local aItem := Main.GRID_1.Value

	IF !Empty(aItem)
		repeat
			Main.Grid_1.DeleteItem( aItem[1] )
			aItem := Main.GRID_1.Value
		until !Empty(aItem)
		UpdateToolBtns()
		UpdateStatus()
	ENDIF

Return

*--------------------------------------------------------*
Procedure DeleteAll
*--------------------------------------------------------*
	IF MsgYesNo( "Are you sure you want to delete the all items?", "Confirm", , , .f. )
		Main.Grid_1.DeleteAllItems
		UpdateToolBtns()
		UpdateStatus()
	ENDIF

Return

*--------------------------------------------------------*
Procedure UpdateToolBtns
*--------------------------------------------------------*
	Local cCombo := Main.COMBOBOX_1.DisplayValue
	Local nItems := Main.GRID_1.ItemCount
	Local aItem := Main.GRID_1.Value

	Main.MnuSend.Enabled := !Empty(cCombo) .And. !Empty(nItems)
	Main.MnuDelete.Enabled := !Empty(aItem)
	Main.MnuDeleteAll.Enabled := !Empty(nItems)

	Main.btnSend.Enabled := !Empty(cCombo) .And. !Empty(nItems)
	Main.btnDelete.Enabled := !Empty(aItem)
	Main.btnDeleteAll.Enabled := !Empty(nItems)

Return

*--------------------------------------------------------*
Procedure UpdateStatus
*--------------------------------------------------------*
	Local nFiles := Main.Grid_1.ItemCount, aFiles := {}
	Local cFiles := "Files: " + Ltrim(Str(nFiles))
	Local nSize := 0, cSize := "Size: ", i

	For i := 1 To nFiles
		nSize += FileSize(Main.Grid_1.Cell(i, 1))
	Next
	cSize += Ltrim( Transform( nSize, "999 999 999 999" ) ) + " b"

	Main.StatusBar.Width(2) := Len(cSize) * 8
	Main.StatusBar.Width(3) := Main.Width - 90 - Len(cSize) * 8
	Main.StatusBar.Item (1) := cFiles
	Main.StatusBar.Item (2) := cSize

	If aData[2][5] == .t.
		For i := 1 To nFiles
			Aadd(aFiles, {Main.Grid_1.Cell(i, 1), Main.Grid_1.Cell(i, 2)})
		Next

		ASORT(aFiles, , , {|a,b| UPPER(a[1]) < UPPER(b[1])})

		Main.Grid_1.DeleteAllItems
		If nFiles > 9
			Main.Grid_1.DeleteColumn( 2 )
			Main.Grid_1.DeleteColumn( 1 )
			Main.Grid_1.AddColumn( 1 , "File" , Main.Grid_1.Width - 104 , 0 )
			Main.Grid_1.AddColumn( 2 , "Size" , 82 , 1 )
		EndIf
		Main.Grid_1.DisableUpdate
	       	For i=1 To nFiles
			DoMethod ( "Main" , "Grid_1" , 'AddItem' , { aFiles[i][1], aFiles[i][2] } )
		Next
		Main.Grid_1.EnableUpdate
	EndIf

Return

*--------------------------------------------------------*
Procedure OnSize
*--------------------------------------------------------*
	Local nFiles := Main.Grid_1.ItemCount, aFiles := {}, i

	Main.PROGRESSBAR_1.Width := Main.Width - 210
	Main.PROGRESSBAR_2.Width := Main.Width - 210
	Main.BUTTONEX_1.Col := Main.Width - 90
	Main.Tab_1.Width := Main.Width - 8
	Main.Tab_1.Height := Main.Height - 120 - IF(IsXPThemeActive(), 8, 0)
	Main.ComboBox_1.Width := Main.Width - 80
	Main.ComboBox_2.Width := Main.Width - 80
	Main.EDITBOX_1.Width := Main.Width - 16
	Main.EDITBOX_1.Height := Main.Height - 215 - IF(IsXPThemeActive(), 8, 0)
	Main.Grid_1.Width := Main.Width - 16
	Main.Grid_1.Height := Main.Height - 150 - IF(IsXPThemeActive(), 8, 0)
	For i := 1 To nFiles
		Aadd(aFiles, {Main.Grid_1.Cell(i, 1), Main.Grid_1.Cell(i, 2)})
	Next

	Main.Grid_1.DeleteAllItems
	Main.Grid_1.DeleteColumn( 2 )
	Main.Grid_1.DeleteColumn( 1 )
	Main.Grid_1.AddColumn( 1 , "File" , Main.Grid_1.Width - 104 , 0 )
	Main.Grid_1.AddColumn( 2 , "Size" , 82 , 1 )
	Main.Grid_1.DisableUpdate
       	For i=1 To nFiles
		DoMethod ( "Main" , "Grid_1" , 'AddItem' , { aFiles[i][1], aFiles[i][2] } )
	Next
	Main.Grid_1.EnableUpdate
	Main.StatusBar.Width(3) := Main.Width - 90 - ( Main.StatusBar.Width(2) )
Return

*--------------------------------------------------------*
Procedure SaveData()
*--------------------------------------------------------*
	Local nI

	IF aData[2][1] == .t.
		BEGIN INI FILE cIni

			SET SECTION "Config" ENTRY "Host" TO aData[1][1]

			SET SECTION "Config" ENTRY "Port" TO aData[1][2]

			SET SECTION "Config" ENTRY "Email" TO aData[1][3]

			SET SECTION "Config" ENTRY "Password" TO crypt(aData[1][4])

			SET SECTION "Config" ENTRY "SaveOnExit" TO aData[2][1]

			SET SECTION "Config" ENTRY "Position" TO aData[2][2]

			SET SECTION "Config" ENTRY "Size" TO aData[2][3]

			SET SECTION "Config" ENTRY "OnTop" TO aData[2][4]

			SET SECTION "Config" ENTRY "Sort" TO aData[2][5]

		IF aData[2][2] == .t.
			SET SECTION "Config" ENTRY "Left" TO Main.Col
			SET SECTION "Config" ENTRY "Top" TO Main.Row
		ENDIF

		IF aData[2][3] == .t.
			SET SECTION "Config" ENTRY "Width" TO Main.Width
			SET SECTION "Config" ENTRY "Height" TO Main.Height
		ENDIF

		For nI := 1 To Len(aAddress)
			SET SECTION "Address History" ENTRY Ltrim(Str(nI, 2)) TO aAddress[nI]
		Next
		For nI := 1 To Len(aSubject)
			SET SECTION "Subject History" ENTRY Ltrim(Str(nI, 2)) TO aSubject[nI]
		Next

		END INI
	ELSEIF FileSize(cIni) == 0
		Ferase(cIni)
	ENDIF

Return

*--------------------------------------------------------*
Procedure SaveConfig()
*--------------------------------------------------------*
	aData[1][1] := Config.TEXTBOX_1.Value
	aData[1][2] := Config.TEXTBOX_2.Value
	aData[1][3] := Config.TEXTBOX_3.Value
	aData[1][4] := Config.TEXTBOX_4.Value

	aData[2][1] := Config.CHECKBOX_1.Value
	aData[2][2] := Config.CHECKBOX_2.Value
	aData[2][3] := Config.CHECKBOX_3.Value
	aData[2][4] := Config.CHECKBOX_4.Value
	aData[2][5] := Config.CHECKBOX_5.Value
Return

*--------------------------------------------------------*
Function MsgAbout
*--------------------------------------------------------*
Return MsgInfo("Multiple Mail version 1.0 - Freeware" + CRLF + ;
	"Copyright (c) 2007 Grigory Filatov" + CRLF + CRLF + ;
	padc("Email: gfilatov@inbox.ru", 36) + CRLF + CRLF + ;
	hb_compiler() + CRLF + ;
	version() + CRLF + ;
	substr(MiniGuiVersion(), 1, 38), "About")

*--------------------------------------------------------*
Procedure SendMails
*--------------------------------------------------------*
Local cSMTP, nPort, cUser := "", cFrom, cPassWord, ;
	cTo, cSubject, cMsgBody, oSocket, ;
	i, nMsgs := Main.Grid_1.ItemCount

   cSMTP       := aData[1][1]
   nPort       := Val(aData[1][2])
   cFrom       := aData[1][3]
   cPassWord   := aData[1][4]
   cTo         := Alltrim(Main.COMBOBOX_1.DisplayValue)
   cSubject    := Alltrim(Main.COMBOBOX_2.DisplayValue)
   cMsgBody    := Alltrim(Main.EDITBOX_1.Value)

   IF Ascan( aAddress, cTo ) == 0
	Aadd(aAddress, cTo)
   ENDIF

   IF Ascan( aSubject, cSubject ) == 0
	Aadd(aSubject, cSubject)
   ENDIF

   oSocket := TSMTP():New()

   IF oSocket:Connect( cSMTP, nPort )

      i := At( "<", cFrom )
      IF i > 0
         cUser := Chr(34) + Alltrim(Left(cFrom, i-1)) + Chr(34) 
         cFrom := Substr(cFrom, i+1, Len(cFrom)-i-1) 
      ENDIF
      i := At( "<", cTo )
      IF i > 0
         cTo := Substr(cTo, i+1, Len(cTo)-i-1)
      ENDIF

      IF ! oSocket:Login( cFrom, cPassWord )
         MsgStop( oSocket:GetLastError(), "While trying to login got an error messages from server" )
         oSocket:Close()
         RETURN
      ENDIF

      Main.PROGRESSBAR_1.Enabled := .t.
      Main.PROGRESSBAR_2.Enabled := .t.
      Main.PROGRESSBAR_2.RangeMax := nMsgs
      Main.BUTTONEX_1.Enabled := .t.

      FOR i := 1 TO nMsgs

         IF lStop
            EXIT
         ENDIF

         oSocket:ClearData()
         oSocket:SetFrom( cUser, cFrom )

         oSocket:AddTo( cUser, cTo )

         oSocket:SetSubject( "(" + Ltrim(Str(i)) + ") " + cSubject )

         oSocket:AddAttach( Main.Grid_1.Cell(i, 1) )
         oSocket:SetData( cMsgBody, .F. )

         Main.PROGRESSBAR_1.Value := 5

         IF ! oSocket:Send(.T.)
            MsgStop( oSocket:GetLastError(), "While trying to send data got an error messages from server" )
            oSocket:Close()
            RETURN
         ENDIF

         Main.PROGRESSBAR_1.Value := 10
         Main.PROGRESSBAR_2.Value := i
         DO EVENTS

      NEXT i

      oSocket:Close()

      Main.PROGRESSBAR_1.Value := 0
      Main.PROGRESSBAR_2.Value := 0
      Main.PROGRESSBAR_1.Enabled := .f.
      Main.PROGRESSBAR_2.Enabled := .f.
      Main.BUTTONEX_1.Enabled := .f.
      IF lStop
         FOR nPort := 1 TO i-1
             Main.Grid_1.DeleteItem( nPort )
         NEXT nPort
         lStop := .F.
      ELSE
         Main.Grid_1.DeleteAllItems
      ENDIF
      UpdateToolBtns()
      UpdateStatus()

   ELSE

      MsgStop( "Can't connect to SMTP server: " + cSMTP, "Error while trying to connect to SMTP server" )

   ENDIF

Return

*--------------------------------------------------------*
Static Function TakeDrop( aFiles )
*--------------------------------------------------------*
	Local i

        For i=1 To Len( aFiles )
		DoMethod ( "Main" , "Grid_1" , 'AddItem' , { aFiles[i], Transform( FileSize(aFiles[i]), "999 999 999 999" ) } )
	Next

	UpdateToolBtns()
	UpdateStatus()
	Main.Tab_1.Value := 2

return nil

*--------------------------------------------------------*
Function crypt(cPass)
*--------------------------------------------------------*
Return CHARXOR( cPass, REPL("@#$%&", 4) )


#pragma BEGINDUMP

#include <windows.h>
#include "hbapi.h"
#include "hbapiitm.h"

HB_FUNC ( INITIMAGE )
{
	HWND  h;
	HBITMAP hBitmap;
	HWND hwnd;

	hwnd = (HWND) hb_parnl(1);

	h = CreateWindowEx(0,"static",NULL, WS_CHILD | WS_VISIBLE | SS_BITMAP | SS_NOTIFY,
		hb_parni(3), hb_parni(4), 0, 0, hwnd, (HMENU)hb_parni(2), GetModuleHandle(NULL), NULL );

	hBitmap = (HBITMAP) LoadImage(0,hb_parc(5),IMAGE_BITMAP,hb_parni(6),hb_parni(7),LR_LOADFROMFILE|LR_CREATEDIBSECTION);
	if (hBitmap==NULL)
	{
		hBitmap = (HBITMAP) LoadImage(GetModuleHandle(NULL), hb_parc(5), IMAGE_BITMAP, hb_parni(6), hb_parni(7), LR_CREATEDIBSECTION);
	}

	SendMessage( h, (UINT)STM_SETIMAGE, (WPARAM)IMAGE_BITMAP, (LPARAM)hBitmap );

	hb_retnl( (LONG) h );
}

HB_FUNC (C_SETPICTURE)
{
	HBITMAP hBitmap;

	hBitmap = (HBITMAP) LoadImage(0,hb_parc(2),IMAGE_BITMAP,hb_parni(3),hb_parni(4),LR_LOADFROMFILE|LR_CREATEDIBSECTION);
	if (hBitmap==NULL)
	{
		hBitmap = (HBITMAP) LoadImage(GetModuleHandle(NULL),hb_parc(2),IMAGE_BITMAP,hb_parni(3),hb_parni(4),LR_CREATEDIBSECTION);
	}

	SendMessage((HWND) hb_parnl (1),(UINT)STM_SETIMAGE,(WPARAM)IMAGE_BITMAP,(LPARAM)hBitmap);

	hb_retnl ( (LONG) hBitmap );
}

#pragma ENDDUMP
