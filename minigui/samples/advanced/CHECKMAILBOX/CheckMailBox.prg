/*
 * MINIGUI - Harbour Win32 GUI library Demo
 *
 * Copyright 2002-07 Roberto Lopez <harbourminigui@gmail.com>
 *
 * Copyright 2002-07 Grigory Filatov <gfilatov@inbox.ru>
*/
ANNOUNCE RDDSYS

#include "minigui.ch"

#define PROGRAM "MailBox Checker"
#define VERSION ' version 1.4'
#define COPYRIGHT ' 2002-2007 Grigory Filatov'

#define NTRIM( n ) LTrim( Str( n ) )
#define MsgInfo( c ) MsgInfo( c, "Information", , .f. )
#define MsgAlert( c ) MsgEXCLAMATION( c, "Attention", , .f. )

STATIC oSocket, aAccounts := {}, lConnect := .f., cAudioFile := "sounds\mail1.wav", nInterval := 180, lSplash := .t.

DECLARE WINDOW Form_Start
DECLARE WINDOW Form_Pass

Memvar cCryptKey, cIniFile
*--------------------------------------------------------*
Procedure main
*--------------------------------------------------------*
   PUBLIC cCryptKey := REPL( "#$@%&", 2 )
   PUBLIC cIniFile := GetStartupFolder() + "\" + Lower( cFileNoExt( GetExeFileName() ) ) + ".ini"

   SET EPOCH TO ( YEAR(DATE())-50 )

   SET DATE GERMAN

   DEFINE WINDOW Form_1 ;
	AT 0,0 ;
	WIDTH 0 HEIGHT 0 ;
	TITLE PROGRAM ;
	ICON "ICON_1" ;
	MAIN NOSHOW ;
	NOTIFYICON "ICON_1" ;
	NOTIFYTOOLTIP PROGRAM + ": Left Click - Start/Stop, Right Click - Menu" ;
	ON NOTIFYCLICK IF( lConnect, oSocket:Close(), StartCheck() )

	if File(cIniFile)
		WriteIni( "Information", "Date", DTOC( Date() ), cIniFile )
		WriteIni( "Information", "Time", Time(), cIniFile )
	else
		Defaults(.t.)
	endif

	cAudioFile := GetIni( "Options", "Sound", cAudioFile, cIniFile )

	nInterval  := VAL( GetIni( "Options", "Interval", NTRIM( nInterval ), cIniFile ) )

	lSplash    := ( GetIni( "Options", "Splash", "ON", cIniFile ) == "ON" )

	RightMenu()

	DEFINE TIMER Timer_1 ;
		INTERVAL nInterval*1000 ;
		ACTION IF( lConnect, , StartCheck() )

   END WINDOW

IF lSplash

   DEFINE WINDOW Form_Start ;
	AT 0, 0 ;
	WIDTH 160 HEIGHT 210 ;
	TOPMOST NOCAPTION ;
	ON INIT ( SysWait(), IF(IsWindowDefined( Form_Start ), Form_Start.Release, ) )

	IF FILE('LOGO.GIF')
		@ -2, -2 IMAGE Image_1 ;
			PICTURE 'LOGO.GIF' ;
			WIDTH Form_Start.Width - 4 ;
			HEIGHT Form_Start.Height - 4 ;
			ACTION Form_Start.Release ;
			STRETCH WHITEBACKGROUND
	ELSE
		@ 30,20 LABEL Label_1 ;
			WIDTH 160 HEIGHT 40 ;
			VALUE 'Loading' ;
			FONT 'Arial' SIZE 24 
		@ 80,45 LABEL Label_2 ;
			WIDTH 160 HEIGHT 40 ;
			VALUE 'Mail' ;
			FONT 'Arial' SIZE 24 
		@ 130,20 LABEL Label_3 ;
			WIDTH 160 HEIGHT 40 ;
			VALUE 'Checker' ;
			FONT 'Arial' SIZE 24 
	ENDIF

   END WINDOW

   CENTER WINDOW Form_Start

   ACTIVATE WINDOW Form_Start, Form_1

ELSE

   ACTIVATE WINDOW Form_1

ENDIF

return

*--------------------------------------------------------*
Procedure RightMenu()
*--------------------------------------------------------*
   Local nItem, cItem

	aAccounts  := LoadAccounts()

	DEFINE NOTIFY MENU OF Form_1
		For nItem := 1 To Len(aAccounts)
			cItem := 'Item_' + NTRIM(nItem)
			ITEM aAccounts[nItem][1] ACTION ActToggle() NAME &cItem
			if aAccounts[nItem][5]
				Form_1.&(cItem).Checked := .t.
			endif
		Next
		SEPARATOR	
		ITEM '&Settings...'		ACTION Settings()
		SEPARATOR	
		ITEM 'Start &Check'		ACTION IF( !lConnect, StartCheck(), )
		ITEM '&About...'			ACTION ShellAbout( "", PROGRAM + VERSION + CRLF + ;
			"Copyright " + Chr(169) + COPYRIGHT, LoadMainIcon(GetInstance(), "ICON_1") )
		SEPARATOR	
		ITEM 'E&xit'			ACTION Form_1.Release
	END MENU

Return

*--------------------------------------------------------*
Procedure SysWait(nWait)
*--------------------------------------------------------*
Local iTime := Seconds()

	DEFAULT nWait TO 2

	Do While Seconds() - iTime < nWait
		DoEvents()
	EndDo

Return

*--------------------------------------------------------*
Function LoadAccounts()
*--------------------------------------------------------*
	LOCAL aArray := Array(16, 5), nI, cAccount, cServer, cLogin, cPass, lCheck

	For nI := 1 To 16

	   cAccount := GetIni( NTRIM(nI)+"/16", "Account", "", cIniFile )
	   cServer  := GetIni( NTRIM(nI)+"/16", "Server", "", cIniFile )
	   cLogin   := GetIni( NTRIM(nI)+"/16", "Login", "", cIniFile )
	   cPass    := CHARXOR( GetIni( NTRIM(nI)+"/16", "Password", "", cIniFile ), cCryptKey )
	   lCheck   := ( GetIni( NTRIM(nI)+"/16", "Check", "ON", cIniFile ) == "ON" )

	   if Empty(cAccount)
		Asize(aArray, nI - 1)
		Exit
	   else
		aArray[nI] := { cAccount, cServer, cLogin, cPass, lCheck }
		WriteIni( NTRIM(nI)+"/16", "MailBox", "0", cIniFile )
	   endif

	Next

Return(aArray)

*--------------------------------------------------------*
Function ActToggle()
*--------------------------------------------------------*
	Local cItem := This.Name
	Local nItem := val( SubStr( cItem, At("_", cItem) + 1 ) )

	aAccounts[nItem][5] := !aAccounts[nItem][5]
	WriteIni( NTRIM(nItem)+"/16", "Check", if(aAccounts[nItem][5], "ON", "OFF"), cIniFile )
	cItem := 'Item_' + NTRIM(nItem)
	Form_1.&(cItem).Checked := aAccounts[nItem][5]

Return NIL

*--------------------------------------------------------*
Function Defaults(lNew)
*--------------------------------------------------------*
	WriteIni( "Information", "Program", PROGRAM + VERSION, cIniFile )
	WriteIni( "Information", "Author", Chr(169) + COPYRIGHT, cIniFile )
	WriteIni( "Information", "Contact", "gfilatov@inbox.ru", cIniFile )
	WriteIni( "Information", "Date", DTOC( Date() ), cIniFile )
	WriteIni( "Information", "Time", Time(), cIniFile )

	WriteIni( "Options", "Sound", cAudioFile, cIniFile )
	WriteIni( "Options", "Interval", NTRIM( nInterval ), cIniFile )
	WriteIni( "Options", "Splash", if(lSplash, "ON", "OFF"), cIniFile )
   IF lNew
	WriteIni( "1/16", "Account", "AccountName", cIniFile )
	WriteIni( "1/16", "Server", "POP3Server", cIniFile )
	WriteIni( "1/16", "Login", "username@server.com", cIniFile )
	WriteIni( "1/16", "Password", CHARXOR( "UserPass", cCryptKey ), cIniFile )
	WriteIni( "1/16", "Check", "ON", cIniFile )
	WriteIni( "1/16", "MailBox", "0", cIniFile )
   ENDIF
Return NIL

*--------------------------------------------------------*
Function StartCheck()
*--------------------------------------------------------*
   LOCAL nI, cServer, cUser, cPass, aMsg := {}, nNewMail := 0, cTip := ""

   For nI := 1 To Len(aAccounts)

	DoEvents()

	IF aAccounts[nI][5]

		oSocket := TPop3():New()

		cServer  := aAccounts[nI][2]
		cUser    := aAccounts[nI][3]
		cPass    := aAccounts[nI][4]

		if oSocket:Connect( alltrim(cServer) )

			lConnect := .t.
			DoEvents()

			Form_1.NotifyTooltip := PROGRAM + ": Checking " + cServer + "..."
			Form_1.NotifyIcon := "ICON_1"

			if Empty(cPass)
				cPass := cGetPassWord( 15, "Enter password for " + cUser )
			endif

			if oSocket:Login( alltrim(cUser), alltrim(cPass) )

				aMsg := oSocket:List( .F. )

				if ( nNewMail := Len(aMsg) - Val( GetIni( NTRIM(nI)+"/16", "MailBox", "0", cIniFile ) ) ) > 0
					WriteIni( NTRIM(nI)+"/16", "MailBox", NTRIM( nNewMail ), cIniFile )
					cTip += IF( Empty(cTip), "", ", " ) + aAccounts[nI][1] + ": " + NTRIM( nNewMail )
				endif

			endif

		else
			lConnect := .f.
			Form_1.NotifyIcon := "ICON_3"
			Form_1.NotifyTooltip := PROGRAM + ": Cann't connect to " + alltrim(cServer)
			SysWait(1)
		endif

		oSocket:Close()

	ENDIF

   Next

   IF lConnect
	lConnect := .f.

	IF Empty(cTip)
		Form_1.NotifyTooltip := PROGRAM + ": No new mail"
	ELSE
		Form_1.NotifyTooltip := cTip

		IF !Empty(cAudioFile)
			PLAY WAVE (cAudioFile)
		ENDIF

		for nI := 1 to 5
			Form_1.NotifyIcon := "ICON_2"
			SysWait(.5)
			Form_1.NotifyIcon := "ICON_4"
			SysWait(.5)
		next

		Form_1.NotifyIcon := "ICON_2"
	ENDIF
   ENDIF

Return NIL

*--------------------------------------------------------*
Function Settings()
*--------------------------------------------------------*
   LOCAL aAcc := {}, aSrv := {}, aUsr := {}, aPwd := {}, aChk := {}, ;
	nAcc := 1, cAudio := cAudioFile

	AEVAL( aAccounts, {|e| AADD(aAcc, e[1]) } )
	AEVAL( aAccounts, {|e| AADD(aSrv, e[2]) } )
	AEVAL( aAccounts, {|e| AADD(aUsr, e[3]) } )
	AEVAL( aAccounts, {|e| AADD(aPwd, e[4]) } )
	AEVAL( aAccounts, {|e| AADD(aChk, e[5]) } )

	DEFINE WINDOW Form_2 AT 0,0 WIDTH 524 HEIGHT 296 TITLE "Settings" ;
		ICON "ICON_1" MODAL NOSIZE ;
		FONT GetSysFont() SIZE 11

		@ 5,7 FRAME Frame_1 CAPTION "Accounts" WIDTH 270 HEIGHT 210

		@ 27,25 TEXTBOX Text_4 HEIGHT 24 WIDTH 205 VALUE "New Account" ;
			ON ENTER Form_2.PicButton_1.SetFocus
		@ 26,238 BUTTON PicButton_1 PICTURE "ADD" ;
			ACTION {|| IF(!Empty( Form_2.Text_4.Value ), ;
			IF(LEN(aAcc) < 17, ;
			( Form_2.Combo_1.AddItem( Form_2.Text_4.Value ), ;
			AADD(aAcc, Form_2.Text_4.Value ), ;
			AADD(aSrv, ""), AADD(aUsr, ""), AADD(aPwd, ""), AADD(aChk, .t.), ;
			Form_2.Combo_1.Value := Len(aAcc), ;
			Form_2.Text_1.Value := ATAIL(aSrv), ;
			Form_2.Text_2.Value := ATAIL(aUsr), ;
			Form_2.Text_3.Value := ATAIL(aPwd) ), ;
			MsgAlert("Can not add more than 16 accounts!") ), ;
			MsgAlert("Name is empty!") ) } ;
			WIDTH 26 HEIGHT 26 TOOLTIP "Add New Account"

		@ 62,25 COMBOBOX Combo_1 WIDTH 205 HEIGHT 200 ITEMS aAcc VALUE nAcc ;
			ON CHANGE ( nAcc := Form_2.Combo_1.Value, ;
			Form_2.Text_1.Value := aSrv[nAcc], ;
			Form_2.Text_2.Value := aUsr[nAcc], ;
			Form_2.Text_3.Value := aPwd[nAcc], ;
			Form_2.Text_4.Value := aAcc[nAcc] )

		@ 61,238 BUTTON PicButton_2 PICTURE "DEL" ;
			ACTION {|| IF(LEN(aAcc) > 1, ;
			( nAcc := Form_2.Combo_1.Value, ;
			ADEL(aAcc, nAcc), ASIZE(aAcc, LEN(aAcc) - 1), ;
			ADEL(aSrv, nAcc), ASIZE(aSrv, LEN(aSrv) - 1), ;
			ADEL(aUsr, nAcc), ASIZE(aUsr, LEN(aUsr) - 1), ;
			ADEL(aPwd, nAcc), ASIZE(aPwd, LEN(aPwd) - 1), ;
			ADEL(aChk, nAcc), ASIZE(aChk, LEN(aChk) - 1), ;
			Form_2.Combo_1.DeleteItem( nAcc ), ;
			nAcc := IF(nAcc>1, nAcc - 1, 1), ;
			Form_2.Combo_1.Value := nAcc, ;
			Form_2.Text_1.Value := aSrv[nAcc], ;
			Form_2.Text_2.Value := aUsr[nAcc], ;
			Form_2.Text_3.Value := aPwd[nAcc], ;
			Form_2.Text_4.Value := aAcc[nAcc], ;
			Form_2.Combo_1.SetFocus ), ;
			MsgAlert("Can not delete ALL existing accounts!") ) } ;
			WIDTH 26 HEIGHT 26 TOOLTIP "Delete Current Account"

		@ 100,25 LABEL Label_1 VALUE "POP3 server:" WIDTH 100 HEIGHT 24
		@ 095,115 TEXTBOX Text_1 HEIGHT 24 WIDTH 150 VALUE aSrv[nAcc] ;
			ON LOSTFOCUS {|| nAcc := Form_2.Combo_1.Value, ;
			aSrv[nAcc] := Form_2.Text_1.Value } ;
			ON ENTER Form_2.Text_2.SetFocus

		@ 140,25 LABEL Label_2 VALUE "Username:" WIDTH 100 HEIGHT 24
		@ 135,115 TEXTBOX Text_2 HEIGHT 24 WIDTH 150 VALUE aUsr[nAcc] ;
			ON LOSTFOCUS {|| nAcc := Form_2.Combo_1.Value, ;
			aUsr[nAcc] := Form_2.Text_2.Value } ;
			ON ENTER Form_2.Text_3.SetFocus

		@ 180,25 LABEL Label_3 VALUE "Password:" WIDTH 100 HEIGHT 24
		@ 175,115 TEXTBOX Text_3 HEIGHT 24 WIDTH 150 VALUE aPwd[nAcc] PASSWORD ;
			ON LOSTFOCUS {|| nAcc := Form_2.Combo_1.Value, ;
			aPwd[nAcc] := Form_2.Text_3.Value } ;
			ON ENTER Form_2.Text_1.SetFocus

		@ 5,290 FRAME Frame_2 CAPTION "Sound" WIDTH 218 HEIGHT 100
		@ 31,305 LABEL Label_6 VALUE "Wave file:" WIDTH 100 HEIGHT 24
		@ 62,305 TEXTBOX Text_5 HEIGHT 24 WIDTH 156 VALUE cAudio ;
			ON CHANGE cAudio := Form_2.Text_5.Value ;
			ON ENTER Form_2.Button_4.SetFocus
		@ 61,470 BUTTON PicButton_3 PICTURE "OPEN" ;
			ACTION {|| cAudio := ;
			GetFile( {{"Audio files", "*.wav"}}, "Select a File" ), ;
			IF(Empty(cAudio), cAudio := cAudioFile, Form_2.Text_5.Value := cAudio), ;
			Form_2.Text_5.SetFocus } ;
			WIDTH 26 HEIGHT 26 TOOLTIP "Select Wave file"
		@ 26,415 BUTTON Button_4 CAPTION "&Play" ;
			ACTION Play_Click(Form_2.Text_5.Value) ;
			WIDTH 80 HEIGHT 26 TOOLTIP "Play Wave file"

		@ 110,290 FRAME Frame_3 CAPTION "Interval" WIDTH 218 HEIGHT 105
		@ 140,305 LABEL Label_4 VALUE "Check mailbox every" WIDTH 175 HEIGHT 24
		@ 175,305 SPINNER Spinner_1 RANGE 1,30 VALUE INT( nInterval / 60 ) ;
			WIDTH 40 HEIGHT 24
		@ 178,350 LABEL Label_5 VALUE "minutes" WIDTH 116 HEIGHT 24

		@ 230,25 CHECKBOX Check_1 ;
			CAPTION "Show Splash Screen at StartUp" WIDTH 217 HEIGHT 28 VALUE lSplash

		@ 230,290 BUTTON Button_5 CAPTION "&Save" ;
			ACTION {|| SaveConfig( aAcc, aSrv, aUsr, aPwd, aChk, cAudio, ;
			Form_2.Spinner_1.Value, Form_2.Check_1.Value ), ;
			Form_2.Release } WIDTH 100 HEIGHT 28 TOOLTIP "Save CURRENT settings"
		@ 230,407 BUTTON Button_6 CAPTION "&Cancel" ;
			ACTION Form_2.Release WIDTH 100 HEIGHT 28 TOOLTIP "Discard changes"
	END WINDOW

	CENTER WINDOW Form_2

	ACTIVATE WINDOW Form_2

Return Nil

*--------------------------------------------------------*
Function SaveConfig(aAcc, aSrv, aUsr, aPwd, aChk, cAudio, nInt, lShow)
*--------------------------------------------------------*
Local nItem

   cAudioFile := cAudio
   lSplash    := lShow
   nInterval  := INT( nInt * 60 )
   Form_1.Timer_1.Value := nInterval*1000

   if File(cIniFile)
	FERASE(cIniFile)
   endif

   Defaults(.f.)

   For nItem := 1 To Len(aAcc)

	WriteIni( NTRIM(nItem)+"/16", "Account", aAcc[nItem], cIniFile )
	WriteIni( NTRIM(nItem)+"/16", "Server", aSrv[nItem], cIniFile )
	WriteIni( NTRIM(nItem)+"/16", "Login", aUsr[nItem], cIniFile )
	WriteIni( NTRIM(nItem)+"/16", "Password", CHARXOR( aPwd[nItem], cCryptKey ), cIniFile )
	WriteIni( NTRIM(nItem)+"/16", "Check", IF(aChk[nItem], "ON", "OFF"), cIniFile )
	WriteIni( NTRIM(nItem)+"/16", "MailBox", "0", cIniFile )

   Next

   RightMenu()

Return Nil

*--------------------------------------------------------*
Procedure Play_Click(cAudio)
*--------------------------------------------------------*
IF !EMPTY(cAudio)
	PLAY WAVE (cAudio)
ENDIF
Return

*--------------------------------------------------------*
Function GetIni( cSection, cEntry, cDefault, cFile )
*--------------------------------------------------------*
RETURN GetPrivateProfileString(cSection, cEntry, cDefault, cFile )

*--------------------------------------------------------*
Function WriteIni( cSection, cEntry, cValue, cFile )
*--------------------------------------------------------*
RETURN( WritePrivateProfileString( cSection, cEntry, cValue, cFile ) )

*--------------------------------------------------------*
Function GetSysFont(cNewFont)
*--------------------------------------------------------*
   local cFont
   static cOldFont:=""
   if empty(cOldFont)
      cOldFont :=if(file( GetWindowsFolder()+"\fonts\tahoma.ttf" ), "Tahoma", "MS Sans Serif")
   endif
   if cNewFont != NIL
      cOldFont := cNewFont
   endif
   cFont := cOldFont
return cFont

*--------------------------------------------------------*
Function cGetPassWord( nMaxLen, cTitle, cBmp )
*--------------------------------------------------------*
Local nTries := 0, lGo := .f., cPassword := SPACE(nMaxLen)

	DEFAULT cBmp TO "KEY"

	DEFINE WINDOW Form_Pass ;
	AT 0,0 ;
	WIDTH 250 HEIGHT 145 ;
	TITLE cTitle ;
	MODAL ;
	NOSIZE NOSYSMENU ;
	ON PAINT Form_Pass.Text_1.SetFocus ;
	ON RELEASE {|| IF( lGo, cPassword := ALLTRIM( Form_Pass.Text_1.Value ), ) } ;
	FONT GetSysFont() SIZE 11

	@ 10,55 LABEL Label_1 ;
	VALUE "Enter password..." ;
	WIDTH 170 HEIGHT 24 FONT GetSysFont() SIZE 12

	@ 40,55 TEXTBOX Text_1 ;
	WIDTH 170 PASSWORD ;
	TOOLTIP "Enter Password" MAXLENGTH nMaxLen ;
	ON ENTER {|| nTries++, lGo := LEN(  Form_Pass.Text_1.Value ) > 0, ;
		If( nTries > 2 .OR. lGo, Form_Pass.Release , ;
		( MsgAlert("Empty password!"), Form_Pass.Text_1.SetFocus ) )}

	@ 40,10 IMAGE Image_1 ;
	PICTURE cBmp ;
	WIDTH 36 ;
	HEIGHT 38

	@ 80,50 BUTTON Button_1 ;
	CAPTION "Continue" ;
	ACTION {|| nTries++, lGo := LEN( Form_Pass.Text_1.Value ) > 0, ;
		If( nTries > 2 .OR. lGo, Form_Pass.Release , ;
		( MsgAlert("Empty password!"), Form_Pass.Text_1.SetFocus ) )} ;
	WIDTH 80 HEIGHT 28

	@ 80,145 BUTTON Button_2 ;
	CAPTION "Exit" ;
	ACTION Form_Pass.Release ;
	WIDTH 80 HEIGHT 28

	END WINDOW

	center window Form_Pass

	activate window Form_Pass

return cPassword


#pragma BEGINDUMP

#define HB_OS_WIN_USED
#include <windows.h>
#include "hbapi.h"
#include "hbapiitm.h"

/* HB_FUNC (LOADTRAYICON)
{

	HICON himage;
	HINSTANCE hInstance  = (HINSTANCE) hb_parnl(1);  // handle to application instance
	LPCTSTR   lpIconName = (LPCTSTR)   hb_parc(2);   // name string or resource identifier

	himage = (HICON) LoadImage( hInstance ,  lpIconName , IMAGE_ICON, 16, 16, LR_SHARED ) ;

	if (himage==NULL)
	{
		himage = (HICON) LoadImage( hInstance ,  lpIconName , IMAGE_ICON, 0, 0, LR_LOADFROMFILE + LR_DEFAULTSIZE ) ;
	}

	hb_retnl ( (LONG) himage );

}
 */
HB_FUNC (LOADMAINICON)
{

	HICON himage;
	HINSTANCE hInstance  = (HINSTANCE) hb_parnl(1);  // handle to application instance
	LPCTSTR   lpIconName = (LPCTSTR)   hb_parc(2);   // name string or resource identifier

	himage = (HICON) LoadImage( hInstance ,  lpIconName , IMAGE_ICON, 0, 0, LR_DEFAULTSIZE ) ;

	if (himage==NULL)
	{
		himage = (HICON) LoadImage( hInstance ,  lpIconName , IMAGE_ICON, 0, 0, LR_LOADFROMFILE + LR_DEFAULTSIZE ) ;
	}

	hb_retnl ( (LONG) himage );

}

#pragma ENDDUMP
