/*
 * MINIGUI - Harbour Win32 GUI library
 * Copyright 2002-2007 Roberto Lopez <harbourminigui@gmail.com>
 *
 * Copyright 2004-2007 Grigory Filatov <gfilatov@inbox.ru>
*/

ANNOUNCE RDDSYS

#include <minigui.ch>

#define IDI_MAIN 1001

Static cIni := "Accounts.ini", aData := {}

*--------------------------------------------------------*
Procedure Main
*--------------------------------------------------------*

	LOAD WINDOW Main
	CENTER WINDOW Main
	ACTIVATE WINDOW Main

Return

*--------------------------------------------------------*
Procedure LoadAcc
*--------------------------------------------------------*
	Local nI
	Local cAcc := "", cServ := "", cName := "", cPass := ""

	BEGIN INI FILE cIni

	For nI := 1 To 99

		GET cAcc SECTION Ltrim(Str(nI, 2)) ENTRY "Account" default ""

		GET cServ SECTION Ltrim(Str(nI, 2)) ENTRY "Server" default ""

		GET cName SECTION Ltrim(Str(nI, 2)) ENTRY "Login" default ""

		GET cPass SECTION Ltrim(Str(nI, 2)) ENTRY "Password" default ""

		IF !Empty(cAcc)
			Aadd(aData, {cAcc, cServ, cName, crypt(cPass)})
		ELSE
			Exit
		ENDIF
	Next

	END INI

	Main.Combo_1.DeleteAllItems
	IF LEN(aData) > 0
		For nI := 1 To Len(aData)
			Main.Combo_1.AddItem(aData[nI][1])
		Next
		Main.Combo_1.Value := 1
		ComboChange()
	ELSE
		Main.Edit_1.Value := "pop.mail.com"
		Main.Edit_2.Value := "user@mail.com"
		Main.Edit_3.Value := "mypassword"
	ENDIF
Return

*--------------------------------------------------------*
Procedure ComboChange
*--------------------------------------------------------*
	Local nAcc := Main.Combo_1.Value

	IF !EMPTY(nAcc)
		Main.Edit_1.Value := aData[nAcc][2]
		Main.Edit_2.Value := aData[nAcc][3]
		Main.Edit_3.Value := aData[nAcc][4]
	ENDIF
Return

*--------------------------------------------------------*
Function crypt(cPass)
*--------------------------------------------------------*
Return CHARXOR( cPass, repl("@#$%&", 4) )

*--------------------------------------------------------*
Procedure AddAcc
*--------------------------------------------------------*
	Local nAcc := Len(aData)
	Local cName := Alltrim( InputBox( 'Enter name of account:', 'Add Account', "Spamed Mailbox", 30000, "" ) )

	IF !EMPTY(cName)
		nAcc++
		Main.Combo_1.AddItem(cName)
		Main.Combo_1.Value := nAcc
		IF !Main.Button_5.Enabled
			Main.Button_5.Enabled := .t.
		ENDIF

		BEGIN INI FILE cIni

			SET SECTION Ltrim(Str(nAcc, 2)) ENTRY "Account" TO cName

			SET SECTION Ltrim(Str(nAcc, 2)) ENTRY "Server" TO Main.Edit_1.Value

			SET SECTION Ltrim(Str(nAcc, 2)) ENTRY "Login" TO Main.Edit_2.Value

			SET SECTION Ltrim(Str(nAcc, 2)) ENTRY "Password" TO crypt(Main.Edit_3.Value)

		END INI

		Aadd(aData, {cName, Main.Edit_1.Value, Main.Edit_2.Value, Main.Edit_3.Value})
	ENDIF
	Main.Combo_1.Setfocus
Return

*--------------------------------------------------------*
Procedure DelAcc
*--------------------------------------------------------*
	Local nAcc := Main.Combo_1.Value

	Main.Combo_1.DeleteItem(nAcc)
	Main.Combo_1.Value := IF(nAcc > 2, nAcc - 1, 1)
	Adel(aData, nAcc)
	Asize(aData, Len(aData) - 1)
	IF LEN(aData) > 0
		ComboChange()
	ELSE
		Main.Edit_1.Value := ""
		Main.Edit_2.Value := ""
		Main.Edit_3.Value := ""
		Main.Button_5.Enabled := .f.
	ENDIF
	SaveAcc(.t.)
Return

*--------------------------------------------------------*
Procedure SaveAcc(lAll)
*--------------------------------------------------------*
	Local nI, nAcc := Main.Combo_1.Value

	DEFAULT lAll := .f.
	IF lAll
		Ferase(cIni)
		For nI := 1 To Len(aData)
			BEGIN INI FILE cIni

				SET SECTION Ltrim(Str(nI, 2)) ENTRY "Account" TO aData[nI][1]

				SET SECTION Ltrim(Str(nI, 2)) ENTRY "Server" TO aData[nI][2]

				SET SECTION Ltrim(Str(nI, 2)) ENTRY "Login" TO aData[nI][3]

				SET SECTION Ltrim(Str(nI, 2)) ENTRY "Password" TO crypt(aData[nI][4])

			END INI
		Next
	ELSE
		IF !EMPTY(nAcc)
			aData[nAcc][2] := Main.Edit_1.Value
			aData[nAcc][3] := Main.Edit_2.Value
			aData[nAcc][4] := Main.Edit_3.Value

			BEGIN INI FILE cIni

				SET SECTION Ltrim(Str(nAcc, 2)) ENTRY "Server" TO aData[nAcc][2]

				SET SECTION Ltrim(Str(nAcc, 2)) ENTRY "Login" TO aData[nAcc][3]

				SET SECTION Ltrim(Str(nAcc, 2)) ENTRY "Password" TO crypt(aData[nAcc][4])

			END INI
		ENDIF
	ENDIF
	Main.Combo_1.Setfocus
Return

*--------------------------------------------------------*
Function MsgAbout
*--------------------------------------------------------*
	Main.Combo_1.Setfocus
Return MsgInfo(padc("Delete Email version 1.02 - Freeware", 40) + CRLF + ;
	"Copyright (c) 2004-2007 Grigory Filatov" + CRLF + CRLF + ;
	padc("Email: gfilatov@inbox.ru", 40) + CRLF + CRLF + ;
	hb_compiler() + CRLF + ;
	version() + CRLF + ;
	substr(MiniGuiVersion(), 1, 38), "About", IDI_MAIN, .f.)

*--------------------------------------------------------*
Procedure DeleteMails
*--------------------------------------------------------*
	Local cServer, cUser, cPass, oSocket, aMessages, nMsgs
	Local nAcc := Main.Combo_1.Value

	IF MsgYesNo( "Are you sure you want to delete the All messages?", "Confirm", , , .f. )
		oSocket := TPop3():New()

		cServer  := Main.Edit_1.Value
		cUser    := Main.Edit_2.Value
		cPass    := Main.Edit_3.Value

		Main.StatusBar.Item(1) := "Connecting"
		IF oSocket:Connect( alltrim(cServer) )

			Main.StatusBar.Item(1) := "Connected"
			inkey(.4)

			IF EMPTY(cPass)
				cPass := InputBox( "Enter password for " + cUser )
			ENDIF

			Main.StatusBar.Item(1) := "Login"
			IF oSocket:Login( alltrim(cUser), alltrim(cPass) )
				aMessages := oSocket:List(.F.)
				nMsgs := Len(aMessages)
				For nAcc := 1 to nMsgs
					oSocket:DeleteMessage( aMessages[nAcc][1] )
					Main.ProgressBar_1.Value := nAcc / nMsgs * 100
					Main.StatusBar.Item(1) := "Deleting " + ltrim(str(nAcc)) + " from " + ltrim(str(nMsgs))
				Next
			ENDIF

		ELSE
			Main.StatusBar.Item(1) := "Bad connect to " + alltrim(cServer)
			inkey(1.6)
		ENDIF

		oSocket:Close()

		inkey(.4)
		Main.ProgressBar_1.Value := 0
		Main.StatusBar.Item(1) := "Waiting..."
	ENDIF
Return


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
