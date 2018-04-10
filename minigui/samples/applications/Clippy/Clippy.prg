/*
 * MINIGUI - Harbour Win32 GUI library
 *
 * Copyright 2002-2007 Roberto Lopez <harbourminigui@gmail.com>
 *
 * Copyright 2005-2007 Grigory Filatov <gfilatov@inbox.ru>
*/

ANNOUNCE RDDSYS

#include "minigui.ch"

#define PROGRAM 'Clippy'
#define VERSION ' version 1.2'
#define COPYRIGHT ' 2005-2007 Grigory Filatov'

DECLARE WINDOW Form_1

Static nWinRow, nWinCol, aMessage := {}, nMsgLen := 0, nMsg := 0, ;
	nInterval := 60, lNoIcon := .F., RegionHandle
*--------------------------------------------------------*
Procedure Main( cParam1, cParam2 )
*--------------------------------------------------------*

	IF PCOUNT() == 1
		nInterval := VAL(cParam1)
		lNoIcon := LOWER(cParam1) == 'noicon'
	ELSEIF PCOUNT() == 2
		nInterval := VAL(cParam1)
		lNoIcon := LOWER(cParam2) == 'noicon'
		IF EMPTY(nInterval) .AND. !lNoIcon
			lNoIcon := LOWER(cParam1) == 'noicon'
			nInterval := VAL(cParam2)
		ENDIF
	ENDIF

	nInterval := IF(EMPTY(nInterval) .OR. nInterval < 10, 60, nInterval)

	SET MULTIPLE OFF

	DEFINE WINDOW Form_0 ;
		AT 0,0 ;
		WIDTH 0 HEIGHT 0 ;
		TITLE PROGRAM ;
		ICON 'MAIN' ;
		MAIN NOSHOW ;
		ON INIT CreateSkinedForm( 0, 0, .T. ) ;
		ON RELEASE DeleteObject( RegionHandle ) ;
		NOTIFYICON 'MAIN' ;
		NOTIFYTOOLTIP PROGRAM ;
		ON NOTIFYCLICK HideShow()

	END WINDOW

	IF lNoIcon
		ShowNotifyIcon( App.Handle, .F., NIL, NIL )
		IF !IsWinNT()
			ServiceProcess(1)
		ENDIF
	ENDIF

	ACTIVATE WINDOW Form_0

Return

*--------------------------------------------------------*
Static Procedure CreateSkinedForm( nTop, nLeft, lMinimized )
*--------------------------------------------------------*
Local aWinSize := BmpSize( "CLIPPY" )

	IF EMPTY(nTop) .AND. EMPTY(nLeft)
		nTop := GetDesktopHeight() - aWinSize[2]
		nLeft := GetDesktopWidth() - aWinSize[1]
		nWinRow := nTop
		nWinCol := nLeft
	ENDIF

	DEFINE WINDOW Form_1 ;
		AT nTop, nLeft ;
		WIDTH aWinSize[1] HEIGHT aWinSize[2] ;
		CHILD ;
		TOPMOST NOCAPTION ;
		NOMINIMIZE NOMAXIMIZE NOSIZE ;
		ON INIT ( ( SET REGION OF Form_1 BITMAP CLIPPY TRANSPARENT COLOR FUCHSIA TO RegionHandle ), ;
				( Form_1.TopMost := .F. ), IF(lMinimized, Form_1.Hide, ), r_menu() ) ;
		ON INTERACTIVECLOSE Form_1.Hide ;
		FONT "MS Sans Serif" SIZE 9

		@ 0,0 IMAGE Image_1 ;
			PICTURE "CLIPPY" ;
			WIDTH Form_1.Width HEIGHT Form_1.Height ;
			ACTION MoveActiveWindow()

		@ 13, 10 LABEL Label_1 VALUE GetRandomMessage(GetStartUpFolder() + "\clippy.txt") ;
			WIDTH 166 HEIGHT 56 TRANSPARENT

		DEFINE BUTTONEX Button_1
			ROW    38
			COL    12
			WIDTH  66
			HEIGHT 23
			CAPTION "YES"
			PICTURE "YES"
			ACTION ThisWindow.Hide
			BACKCOLOR WHITE
			NOHOTLIGHT .T.
			NOXPSTYLE .T.
			TABSTOP .T.
			VISIBLE .F.
		END BUTTONEX

		DEFINE BUTTONEX Button_2
			ROW    38
			COL    106
			WIDTH  66
			HEIGHT 23
			CAPTION "NO"
			PICTURE "NO"
			ACTION ThisWindow.Hide
			BACKCOLOR WHITE
			NOHOTLIGHT .T.
			NOXPSTYLE .T.
			TABSTOP .T.
			VISIBLE .F.
		END BUTTONEX

	END WINDOW

	SetHandCursor( GetControlHandle("Image_1", "Form_1"), LoadCursor( GetInstance(), "HAND" ) )

	DEFINE TIMER Timer_1 OF Form_1 INTERVAL nInterval * 1000 ACTION OnTimer()

	ACTIVATE WINDOW Form_1

Return

*--------------------------------------------------------*
Static Procedure r_menu()
*--------------------------------------------------------*

	DEFINE NOTIFY MENU OF Form_0
		ITEM IF( IsWindowVisible( GetFormHandle( "Form_1" ) ), '&Hide', '&Show' ) ;
					ACTION HideShow() NAME Show_Hide
		ITEM '&About...'	ACTION ShellAbout( "About " + PROGRAM + "#", ;
			PROGRAM + VERSION + CRLF + ;
			"Copyright " + Chr(169) + COPYRIGHT, LoadTrayIcon(GetInstance(), "MAIN", 32, 32) )
		SEPARATOR	
		ITEM '&Exit'		ACTION Form_0.Release
	END MENU

	Set Default MenuItem Show_Hide Of Form_0

Return

*--------------------------------------------------------*
Static Procedure OnTimer()
*--------------------------------------------------------*
Local cMsg

	Form_1.Timer_1.Enabled := .F.

	Form_1.Label_1.Value := GetRandomMessage(GetStartUpFolder() + "\clippy.txt")

	cMsg := Form_1.Label_1.Value
	IF "[date]" $ cMsg
		Form_1.Label_1.Value := StrTran(cMsg, "[date]", Today())
	ENDIF
	IF "?" $ cMsg
		Form_1.Label_1.Height := 28
		Form_1.Button_1.Visible := .T.
		Form_1.Button_2.Visible := .T.
		Form_1.Button_1.SetFocus
	ENDIF

	PLAY WAVE "WHOOSH" FROM RESOURCE

	HideShow()

	SysWait()

	IF "?" $ cMsg
		Form_1.Button_1.Visible := .F.
		Form_1.Button_2.Visible := .F.
		Form_1.Label_1.Height := 56
	ENDIF

	HideShow()

	Form_1.Timer_1.Enabled := .T.

Return

*--------------------------------------------------------*
Static Procedure HideShow()
*--------------------------------------------------------*

   IF IsWindowVisible( GetFormHandle( "Form_1" ) )

	Form_1.Hide

   ELSE

	Form_1.Row := nWinRow
	Form_1.Col := nWinCol

	Form_1.TopMost := .T.
	Form_1.Show
	Form_1.TopMost := .F.

   ENDIF

   r_menu()

Return

*--------------------------------------------------------*
Static Function Today()
*--------------------------------------------------------*
Local dDate := Date()
Return CDoW( dDate ) + ", " + CMonth( dDate ) + " " + StrZero( Day( dDate ), 2 ) + "," + Str( Year( dDate ) )

*--------------------------------------------------------*
Static Function GetRandomMessage(cFileName)
*--------------------------------------------------------*
Local cMsg, nNew, oFile, cLine

	IF FILE( cFileName )

		oFile := TFileRead():New( cFileName )
		oFile:Open()

		IF oFile:Error()
			MsgStop( oFile:ErrorMsg( "FileRead: " ), "Error" )
		ELSE
			IF EMPTY( nMsgLen )
				WHILE oFile:MoreToRead()
					cLine := oFile:ReadLine()
					IF SUBSTR(cLine, 1, 1) # "$" .AND. !EMPTY(SUBSTR(cLine, 1, 1)) .AND. AT(CHR(26), cLine) = 0
						nMsgLen++
						AADD( aMessage, cLine )
					ENDIF
				END WHILE
				oFile:Close()
			ENDIF

		ENDIF 
	ELSE
		IF EMPTY( nMsgLen )
			AADD( aMessage, "It appears you are connected to the Internet." )
			AADD( aMessage, "I see that you have been using your mouse." )
			AADD( aMessage, "Your computer seems to be turned on." )
			AADD( aMessage, "It looks like your keyboard is working correctly." )
			AADD( aMessage, "Your productivity has been decreasing lately. I hope everything is ok." )
			AADD( aMessage, "Sometimes I just popup for no particular reason, like now." )
			AADD( aMessage, "I have detected a mouse move, this was normal." )
			AADD( aMessage, "Your posture seems to be degrading, please reposition yourself now." )
			AADD( aMessage, "Your Windows Desktop icons are still there." )
			AADD( aMessage, "Your monitor is operational." )
			AADD( aMessage, "Power to your computer is constant, to protect from data loss you should install a power strip." )
			AADD( aMessage, "I have detected your F1 key (help) to be working correctly." )
			AADD( aMessage, "If you ever need any help, just ask me." )
			AADD( aMessage, "Background processing has rated your typing speed to be below normal." )
			AADD( aMessage, "Your mouse is dirty. Please clean it to restore optimal performance." )
			AADD( aMessage, "Unable to follow your instructions." )
			AADD( aMessage, "It is time to play a game, lets play hide-and-seek." )
			AADD( aMessage, "Would you like me to go away?" )
			AADD( aMessage, "I thought you should know that today is [date]." )
			AADD( aMessage, "I noticed you have Internet Explorer installed on your system. You can use that to find things on the Internet." )

			nMsgLen := LEN(aMessage)
		ENDIF
	ENDIF

	nNew := Max(1, Random(nMsgLen))
	WHILE nNew == nMsg
		nNew := Max(1, Random(nMsgLen))
	END WHILE
	nMsg := nNew

	cMsg := aMessage[nMsg]

RETURN cMsg

#define HTCAPTION          2
#define WM_NCLBUTTONDOWN   161
*--------------------------------------------------------*
Static Procedure MoveActiveWindow(hWnd)
*--------------------------------------------------------*

	DEFAULT hWnd := GetActiveWindow()

	PostMessage(hWnd, WM_NCLBUTTONDOWN, HTCAPTION, 0)

Return

*--------------------------------------------------------*
Static Procedure SysWait(nWait)
*--------------------------------------------------------*
Local iTime := Seconds()

	DEFAULT nWait := 7

	Do While Seconds() - iTime < nWait
		Inkey(.1)
		DO EVENTS
	EndDo

Return

*--------------------------------------------------------*
Procedure ServiceProcess( mode )
*--------------------------------------------------------*
Local nProcessId

	DEFAULT mode := 0

	nProcessId := GCP( )

	If Abs( nProcessId ) > 0
		RSProcess( nProcessId, mode )
	Endif

RETURN

*--------------------------------------------------------*
DECLARE DLL_TYPE_LONG RegisterServiceProcess( DLL_TYPE_LONG nProcessID, DLL_TYPE_LONG nMode ) ;
	IN KERNEL32.DLL ;
	ALIAS RSProcess

*--------------------------------------------------------*
DECLARE DLL_TYPE_LONG GetCurrentProcessId() ;
	IN KERNEL32.DLL ;
	ALIAS GCP

#ifdef __XHARBOUR__
  #include <fileread.prg>
#endif