*
* MINIGUI - HARBOUR - Win32
* 
* Author: Grigory Filatov <gfilatov@inbox.ru>
*
* Designed by GUIDES
*
ANNOUNCE RDDSYS

#define __SCRSAVERDATA__
#include "minigui.ch"

#define PROGRAM "ActiveSaver Screen Saver"
#define VERSION " v.1.2"
#define COPYRIGHT " 2003-06 by Grigory Filatov"

#define ICON_1 1001

#define MAX_FILES 99
#define NTRIM( n ) LTrim( Str( n ) )

#define EWX_LOGOFF   0
#define EWX_SHUTDOWN 1
#define EWX_REBOOT   2
#define EWX_FORCE    4
#define EWX_POWEROFF 8

STATIC lExit := FALSE, lWaitClose := FALSE, nChoice := 1, ;
	lAction := FALSE, lWarning := FALSE, nDelay := 30, ;
	lHideButton := FALSE, lAllUsers := FALSE, lRunFile := FALSE, ;
	aRunFile := {}, nRunFile := 1, aWarning := {}, lForce := FALSE, ;
	cUserName := "", cIniFile := "", cHlpFile := ""

MEMVAR cUser, aMessage
MEMVAR cTimeExit, nProgress
MEMVAR aResults, aResult
*--------------------------------------------------------*
Procedure Main( cParameters )
*--------------------------------------------------------*
PRIVATE cUser := GetUserName(), aMessage

	AADD(aWarning, "You will be logged off in ## seconds.")
	AADD(aWarning, "This computer will be restarted in ## seconds.")
	AADD(aWarning, "This computer will be shut down in ## seconds.")
	AADD(aWarning, "This computer will be powered off in ## seconds.")
	aMessage := ACLONE(aWarning)

	cIniFile := GetSystemFolder()+'\'+Lower(cFileNoExt(GetExeFileName()))+".ini"
	cHlpFile := GetSystemFolder()+'\'+cFileNoExt(cIniFile)+".pdf"

	IF FILE(cIniFile)
		LoadDefaults()
	ENDIF

	DEFINE SCREENSAVER 			;
		WINDOW Form_ActiveSaver	;
		MAIN 				;
		NOSHOW				;
		ON RELEASE lExit

	INSTALL SCREENSAVER TO FILE ActiveSaver.scr

	CONFIGURE SCREENSAVER ConfigureActiveSaver()

	IF cParameters # NIL .AND. !LOWER(cParameters) $ "-p/p" .AND. ;
		LOWER(cParameters) # "/a" .AND. LOWER(cParameters) # "-a" .AND. ;
		LOWER(cParameters) # "/c" .AND. LOWER(cParameters) # "-c"

		StartActiveSaver()
	ELSE
		IF FILE("ActiveSaver.pdf")
			COPY FILE ActiveSaver.pdf TO (cHlpFile)
		ENDIF
	ENDIF

	ACTIVATE SCREENSAVER			;
		WINDOW Form_ActiveSaver	;
		PARAMETERS cParameters

Return

*--------------------------------------------------------*
Procedure ConfigureActiveSaver()
*--------------------------------------------------------*

	DEFINE WINDOW Form_Config ;
        AT 0,0 ;
        WIDTH 456 ;
        HEIGHT IF(IsXPThemeActive(), 298, 292) ;
        TITLE 'ActiveSaver configuration' ;
        ICON ICON_1 ;
        CHILD ;
        NOMINIMIZE NOMAXIMIZE NOSIZE ;
        ON INIT ShowCursor(.T.) ;
        ON PAINT DoMethod('Form_Config', 'CONTROL_2', 'SetFocus') ;
        FONT 'MS Sans Serif' ;
        SIZE 9

        @ 6,10 FRAME CONTROL_1 ;
            CAPTION 'Screen saver actions:' ;
            WIDTH 358 ;
            HEIGHT 228

        @ 14,380 BUTTON CONTROL_2 ;
            CAPTION 'OK' ;
            ACTION ( SaveConfig(), lExit := TRUE, Form_ActiveSaver.Release ) ;
            WIDTH 60 ;
            HEIGHT 23

        @ 40,380 BUTTON CONTROL_3 ;
            CAPTION 'Cancel' ;
            ACTION ( lExit := TRUE, Form_ActiveSaver.Release ) ;
            WIDTH 60 ;
            HEIGHT 23

        @ 66,380 BUTTON CONTROL_4 ;
            CAPTION 'Help' ;
            ACTION RunHelp() ;
            WIDTH 60 ;
            HEIGHT 23

        @ 92,380 BUTTON CONTROL_5 ;
            CAPTION 'About' ;
            ACTION MsgAbout() ;
            WIDTH 60 ;
            HEIGHT 23

        @ 174,380 FRAME CONTROL_6 ;
            WIDTH 60 ;
            HEIGHT 60

        @ 188,394 IMAGE CONTROL_7 ;
            PICTURE 'LOGO' ;
            WIDTH 32 ;
            HEIGHT 32

        @ 20,20 CHECKBOX CONTROL_8 ; 
            CAPTION '&Run a program, or open a file, or Internet resource:' ; 
            WIDTH 300 ; 
            HEIGHT 23 ; 
            VALUE lRunFile ; 
            ON CHANGE (lRunFile := Form_Config.CONTROL_8.Value, ;
                       Form_Config.CONTROL_9.Enabled  := lRunFile, ;
                       Form_Config.CONTROL_10.Enabled := lRunFile, ;
                       Form_Config.CONTROL_11.Enabled := ( lRunFile .AND. lAction ))

        @ 46,35 COMBOBOX CONTROL_9 ; 
            ITEMS aRunFile ; 
            VALUE nRunFile ; 
            WIDTH 300 ; 
            HEIGHT 120 ; 
            ON CHANGE nRunFile := Form_Config.CONTROL_9.Value

        @ 46,336 BUTTON CONTROL_10 ; 
            CAPTION '...' ; 
            ACTION SelectFile() ; 
            WIDTH 20 ; 
            HEIGHT 20 ; 

        @ 70,35 CHECKBOX CONTROL_11 ; 
            CAPTION '&Wait for close' ; 
            WIDTH 120 ; 
            HEIGHT 23 ; 
            VALUE lWaitClose ; 
            ON CHANGE lWaitClose := Form_Config.CONTROL_11.Value

        @ 92,20 CHECKBOX CONTROL_12 ; 
            CAPTION '&Perform the action:' ; 
            WIDTH 124 ; 
            HEIGHT 23 ; 
            VALUE lAction ; 
            ON CHANGE (lAction := Form_Config.CONTROL_12.Value, ;
                       Form_Config.CONTROL_11.Enabled := ( lRunFile .AND. lAction ), ;
                       Form_Config.CONTROL_13.Enabled := lAction, ;
                       Form_Config.CONTROL_14.Enabled := lAction, ;
                       Form_Config.CONTROL_15.Enabled := lAction, ;
                       Form_Config.CONTROL_16.Enabled := ( lAction .AND. lWarning ), ;
                       Form_Config.CONTROL_17.Enabled := ( lAction .AND. lWarning ), ;
                       Form_Config.CONTROL_18.Enabled := ( lAction .AND. lWarning ), ;
                       Form_Config.CONTROL_19.Enabled := ( lAction .AND. lWarning ), ;
                       Form_Config.CONTROL_20.Enabled := ( lAction .AND. lWarning ))

        @ 112,35 RADIOGROUP CONTROL_13 ; 
            OPTIONS { "&Logoff", "&Restart", "&Shut down", "P&ower off" } ; 
            WIDTH 80 ; 
            SPACING 22 ;
            VALUE nChoice ;
            ON CHANGE (nChoice := Form_Config.CONTROL_13.Value, ;
                       Form_Config.CONTROL_18.Value := aWarning[nChoice])

        @ 205,20 CHECKBOX CONTROL_14 ; 
            CAPTION '&Force application termination' ; 
            WIDTH 180 ; 
            HEIGHT 23 ; 
            VALUE lForce ; 
            ON CHANGE lForce := Form_Config.CONTROL_14.Value

        @ 114,140 CHECKBOX CONTROL_15 ; 
            CAPTION '&Display warning for' ; 
            WIDTH 110 ; 
            HEIGHT 23 ; 
            VALUE lWarning ; 
            ON CHANGE (lWarning := Form_Config.CONTROL_15.Value, ;
                       Form_Config.CONTROL_16.Enabled := lWarning, ;
                       Form_Config.CONTROL_17.Enabled := lWarning, ;
                       Form_Config.CONTROL_18.Enabled := lWarning, ;
                       Form_Config.CONTROL_19.Enabled := lWarning, ;
                       Form_Config.CONTROL_20.Enabled := lWarning)

        @ 114,256 SPINNER CONTROL_16 ; 
            RANGE 10 , 900 ; 
            WIDTH 42 ; 
            HEIGHT 21 ; 
            VALUE nDelay ;
            ON CHANGE nDelay := Form_Config.CONTROL_16.Value

        @ 118,305 LABEL CONTROL_17 ; 
            VALUE 'seconds:' ; 
            WIDTH 42 ; 
            HEIGHT 23

        @ 150,140 TEXTBOX CONTROL_18 ; 
            VALUE aWarning[nChoice] ; 
            WIDTH 194 ; 
            HEIGHT 21 ; 
            READONLY

        @ 150,335 BUTTON CONTROL_19 ; 
            CAPTION '>' ; 
            ACTION EditWarnings() ; 
            WIDTH 20 ; 
            HEIGHT 20

        @ 180,140 CHECKBOX CONTROL_20 ; 
            CAPTION '&Hide OK button' ; 
            WIDTH 120 ; 
            HEIGHT 23 ; 
            VALUE lHideButton ; 
            ON CHANGE lHideButton := Form_Config.CONTROL_20.Value

        @ 238,20 CHECKBOX CONTROL_21 ; 
            CAPTION '&Use these settings for all users of this computer' ; 
            WIDTH 280 ; 
            HEIGHT 23 ; 
            VALUE lAllUsers ; 
            ON CHANGE lAllUsers := Form_Config.CONTROL_21.Value

END WINDOW

Form_Config.CONTROL_9.Enabled  := lRunFile
Form_Config.CONTROL_10.Enabled := lRunFile
Form_Config.CONTROL_11.Enabled := ( lRunFile .AND. lAction )
Form_Config.CONTROL_13.Enabled := lAction
Form_Config.CONTROL_14.Enabled := lAction
Form_Config.CONTROL_15.Enabled := lAction
Form_Config.CONTROL_16.Enabled := ( lAction .AND. lWarning )
Form_Config.CONTROL_17.Enabled := ( lAction .AND. lWarning )
Form_Config.CONTROL_18.Enabled := ( lAction .AND. lWarning )
Form_Config.CONTROL_19.Enabled := ( lAction .AND. lWarning )
Form_Config.CONTROL_20.Enabled := ( lAction .AND. lWarning )

CENTER WINDOW Form_Config

ACTIVATE WINDOW Form_Config, Form_ActiveSaver

Return

*--------------------------------------------------------*
Procedure StartActiveSaver()
*--------------------------------------------------------*
LOCAL cRunFile := IF(LEN(aRunFile) > 0, aRunFile[nRunFile], "")
PRIVATE cTimeExit := STRTRAN( aWarning[nChoice], "##", NTRIM(nDelay) ), nProgress := 0

IF lAllUsers .OR. EMPTY(cUserName) .OR. cUserName = cUser

	IF lRunFile

		IF !EMPTY(cRunFile)

			IF lWaitClose .AND. lAction

				EXECUTE FILE cRunFile WAIT

			ELSE

				EXECUTE FILE cRunFile

			ENDIF

		ENDIF

	ENDIF

	IF lAction

		IF lWarning

			DEFINE WINDOW Form_2 AT 0,0 ;
				WIDTH 372 HEIGHT IF(IsXPThemeActive(), 112, 106) ;
				TITLE "ActiveSaver" ;
				TOPMOST ;
				NOSIZE NOSYSMENU ;
				ON INIT ( DoMethod('Form_2', 'Button_2', 'SetFocus'), ;
					EVAL( {|| SetTimeExit()} ), DoMethod('Form_2', 'Release') ) ;
				FONT 'MS Sans Serif' ; 
				SIZE 9

				@ 15, 10 IMAGE Image_1		; 
					PICTURE 'LOGO'		;
					WIDTH 32			;
					HEIGHT 32

				@ 10, 54 LABEL TimeExit		;
					VALUE cTimeExit		;
					WIDTH  245        	;
					HEIGHT 18         	;

				@ 46, 54 PROGRESSBAR Progress_1 ; 
					RANGE 0, nDelay 		; 
					WIDTH 235 			; 
					HEIGHT 23 			; 
					SMOOTH

				IF !lHideButton
					@ 12, 300 BUTTON Button_1 CAPTION '&OK' ;
						ACTION nDelay := 0 ;
						WIDTH 55 HEIGHT 23
				ENDIF

				@ 46, 300 BUTTON Button_2 CAPTION '&Cancel' ;
					ACTION lAction := FALSE ;
					WIDTH 55 HEIGHT 23

				ON KEY RETURN ACTION DoMethod( 'Form_2', Form_2.FocusedControl, 'OnClick' )
				ON KEY ESCAPE ACTION Form_2.Button_2.OnClick

			END WINDOW

			CENTER WINDOW Form_2

			ACTIVATE WINDOW Form_2, Form_ActiveSaver

		ENDIF

	ELSE

			DEFINE TIMER Timer_1 ;
				OF Form_ActiveSaver ;
				INTERVAL 2000 ;
				ACTION ( lExit := TRUE, Form_ActiveSaver.Release )

		ACTIVATE WINDOW Form_ActiveSaver

	ENDIF

ELSE

		DEFINE TIMER Timer_1 ;
			OF Form_ActiveSaver ;
			INTERVAL 2000 ;
			ACTION ( lExit := TRUE, Form_ActiveSaver.Release )

	ACTIVATE WINDOW Form_ActiveSaver

ENDIF

Return

*--------------------------------------------------------*
Procedure SetTimeExit()
*--------------------------------------------------------*
LOCAL nAction := IF( nChoice = 1, EWX_LOGOFF, IF( nChoice = 2, EWX_REBOOT, ;
	IF( nChoice = 3, EWX_SHUTDOWN, EWX_POWEROFF ) ) ), nTime

	WHILE nDelay > 0 .AND. lAction

		nTime := Seconds()

		Do While Seconds() - nTime < 1
			DO EVENTS
		EndDo

		nDelay--
		cTimeExit := STRTRAN( aWarning[nChoice], "##", NTRIM(nDelay) )
		Form_2.TimeExit.Value := cTimeExit

		nProgress++
		Form_2.Progress_1.Value := nProgress

	ENDDO

	IF lAction

		IF lForce
			nAction += EWX_FORCE
		ENDIF

		ExitWindows( nAction )

	ELSE

		DEFINE TIMER Timer_1 ;
			OF Form_ActiveSaver ;
			INTERVAL 2000 ;
			ACTION ( lExit := TRUE, Form_ActiveSaver.Release )

	ENDIF

Return

*--------------------------------------------------------*
Procedure LoadDefaults()
*--------------------------------------------------------*
LOCAL cChoice := "", cName := "", nI

  aWarning := {}

  BEGIN INI FILE cIniFile
    GET cChoice SECTION "Run" ENTRY "Activated"
    IF EMPTY(cChoice)
	SET SECTION "Run" ENTRY "Activated" TO IF(lRunFile, "ON", "OFF")
    ELSE
	lRunFile := "ON" $ cChoice
    ENDIF
    GET cChoice SECTION "Run" ENTRY "Choice"
    IF EMPTY(cChoice)
	SET SECTION "Run" ENTRY "Choice" TO NTRIM(nRunFile)
    ELSE
	nRunFile := VAL(cChoice)
    ENDIF
    GET cChoice SECTION "Run" ENTRY "WaitClose"
    IF EMPTY(cChoice)
	SET SECTION "Run" ENTRY "WaitClose" TO IF(lWaitClose, "ON", "OFF")
    ELSE
	lWaitClose := "ON" $ cChoice
    ENDIF

    For nI := 1 To MAX_FILES

	GET cName SECTION "Run" ENTRY NTRIM(nI)

	IF !Empty(cName)
		AADD(aRunFile, cName)
	ELSE
		Exit
	ENDIF

    Next

    GET cChoice SECTION "Action" ENTRY "Activated"
    IF EMPTY(cChoice)
	SET SECTION "Action" ENTRY "Activated" TO IF(lAction, "ON", "OFF")
    ELSE
	lAction := "ON" $ cChoice
    ENDIF
    GET cChoice SECTION "Action" ENTRY "Choice"
    IF EMPTY(cChoice)
	SET SECTION "Action" ENTRY "Choice" TO NTRIM(nChoice)
    ELSE
	nChoice := VAL(cChoice)
    ENDIF
    GET cChoice SECTION "Action" ENTRY "Force"
    IF EMPTY(cChoice)
	SET SECTION "Action" ENTRY "Force" TO IF(lForce, "ON", "OFF")
    ELSE
	lForce := "ON" $ cChoice
    ENDIF
    GET cChoice SECTION "Action" ENTRY "AllUsers"
    IF EMPTY(cChoice)
	SET SECTION "Action" ENTRY "AllUsers" TO IF(lAllUsers, "ON", "OFF")
    ELSE
	lAllUsers := "ON" $ cChoice
    ENDIF
    GET cUserName SECTION "Action" ENTRY "UserName" DEFAULT cUser

    GET cChoice SECTION "Warning" ENTRY "Activated"
    IF EMPTY(cChoice)
	SET SECTION "Warning" ENTRY "Activated" TO IF(lWarning, "ON", "OFF")
    ELSE
	lWarning := "ON" $ cChoice
    ENDIF
    GET cChoice SECTION "Warning" ENTRY "Delay"
    IF EMPTY(cChoice)
	SET SECTION "Warning" ENTRY "Delay" TO NTRIM(nDelay)
    ELSE
	nDelay := VAL(cChoice)
    ENDIF
    GET cChoice SECTION "Warning" ENTRY "HideOK"
    IF EMPTY(cChoice)
	SET SECTION "Warning" ENTRY "HideOK" TO IF(lHideButton, "ON", "OFF")
    ELSE
	lHideButton := "ON" $ cChoice
    ENDIF

    For nI := 1 To 4

	GET cName SECTION "Warning" ENTRY NTRIM(nI)

	IF !Empty(cName)
		AADD(aWarning, cName)
	ELSE
		Exit
	ENDIF

    Next

  END INI

Return

*--------------------------------------------------------*
Procedure SaveConfig()
*--------------------------------------------------------*
LOCAL cActive, nI

  BEGIN INI FILE cIniFile
	SET SECTION "Run" ENTRY "Activated" TO IF(lRunFile, "ON", "OFF")
	SET SECTION "Run" ENTRY "Choice" TO NTRIM(nRunFile)
	SET SECTION "Run" ENTRY "WaitClose" TO IF(lWaitClose, "ON", "OFF")

    For nI := 1 To LEN(aRunFile)

	cActive := aRunFile[nI]
	SET SECTION "Run" ENTRY NTRIM(nI) TO cActive

    Next

	SET SECTION "Action" ENTRY "Activated" TO IF(lAction, "ON", "OFF")
	SET SECTION "Action" ENTRY "Choice" TO NTRIM(nChoice)
	SET SECTION "Action" ENTRY "Force" TO IF(lForce, "ON", "OFF")
	SET SECTION "Action" ENTRY "AllUsers" TO IF(lAllUsers, "ON", "OFF")
	SET SECTION "Action" ENTRY "UserName" TO cUser

	SET SECTION "Warning" ENTRY "Activated" TO IF(lWarning, "ON", "OFF")
	SET SECTION "Warning" ENTRY "Delay" TO NTRIM(nDelay)
	SET SECTION "Warning" ENTRY "HideOK" TO IF(lHideButton, "ON", "OFF")

    For nI := 1 To LEN(aWarning)

	cActive := aWarning[nI]
	SET SECTION "Warning" ENTRY NTRIM(nI) TO cActive

    Next

  END INI

Return

*--------------------------------------------------------*
Function MsgAbout()
*--------------------------------------------------------*
return MsgInfo( PROGRAM + VERSION + CRLF + ;
	"Copyright " + Chr(169) + COPYRIGHT + CRLF + CRLF + ;
	"eMail: gfilatov@inbox.ru" + CRLF + CRLF + ;
	"This Screen Saver is Freeware!" + CRLF + ;
	padc("Copying is allowed!", 34), "About", ICON_1, .F. )

*--------------------------------------------------------*
Procedure ExitWindows( nFlag )
*--------------------------------------------------------*

   if IsWinNT()
      EnablePermissions()
   endif

   ExitWindowsEx(nFlag, 0)

Return

*--------------------------------------------------------*
Procedure RunHelp()
*--------------------------------------------------------*

IF FILE(cHlpFile)
	Form_Config.Hide
	EXECUTE OPERATION "open" FILE cHlpFile
	INKEY(5)
	Form_Config.Show
ELSE
	MsgStop("Help file not found", "Warning")
ENDIF

Return

*--------------------------------------------------------*
Procedure SelectFile()
*--------------------------------------------------------*
LOCAL cFile := GetFile( { {"All Files", "*.*"} }, "Browse for file" )

   IF !EMPTY(cFile)
	AADD(aRunFile, cFile)
	Form_Config.CONTROL_9.AddItem(cFile)
	Form_Config.CONTROL_9.Value := Form_Config.CONTROL_9.ItemCount
	nRunFile := Form_Config.CONTROL_9.Value
   ENDIF

Return

*--------------------------------------------------------*
Procedure EditWarnings()
*--------------------------------------------------------*
LOCAL aLabels, aInitValues, aFormats, i

  aLabels	:= { '&Logoff:', '&Restart:','&Shut down:', 'P&ower off:' }
  aInitValues	:= aWarning
  aFormats	:= { 30, 30, 30, 30 }

  aResults 	:= MyInputWindow( "Custom Warning Messages", aLabels, aInitValues, aFormats )

  If aResults[1] # Nil

	For i := 1 to Len(aWarning)

		aWarning[i] := aResults[i]

	Next i

	Form_Config.CONTROL_18.Value := aWarning[nChoice]

  EndIf

Return

*--------------------------------------------------------*
Function MyInputWindow( Title, aLabels, aValues, aFormats )
*--------------------------------------------------------*
LOCAL i, l, ControlRow, LN, CN

	l := Len( aLabels )

	aResult := Array(l)

	DEFINE WINDOW _InputWindow ;
		AT 0,0 ;
		WIDTH 390 ;
		HEIGHT (l*30) + 85 ;
		TITLE Title ;
		ICON "ICON_1" ;
		MODAL ;
		NOSIZE ;
		FONT 'MS Sans Serif' ; 
		SIZE 9

		ControlRow := 10

		For i := 1 to l

			LN := 'Label_' + NTRIM(i)
			CN := 'Control_' + NTRIM(i)

			@ ControlRow, 12 LABEL &LN VALUE aLabels[i] AUTOSIZE

			do case

			case ValType ( aValues [i] ) == 'C'

				If ValType ( aFormats [i] ) == 'N'
					If  i == l
						@ ControlRow, 80 TEXTBOX &CN ;
						VALUE aValues[i] WIDTH 290 HEIGHT 21 ; 
						MAXLENGTH aFormats[i] ;
						ON ENTER _InputWindowOk()
						ControlRow := ControlRow + 25
					Else
						@ ControlRow, 80 TEXTBOX &CN ;
						VALUE aValues[i] WIDTH 290 HEIGHT 21 ;
						MAXLENGTH aFormats[i] ;
						ON ENTER SetCtrl()
						ControlRow := ControlRow + 30
					EndIf
				EndIf

			endcase

		Next i

		@ ControlRow, 80 LABEL Label_Tips OF _InputWindow ;
			VALUE "Use ## as placeholder for the number of seconds remaining." ;
			WIDTH 310 HEIGHT 16

		@ ControlRow + 22, 140 BUTTON Button_1 ;
		OF _InputWindow ;
		CAPTION '&OK' ;
		ACTION _InputWindowOk() ;
		WIDTH 70 ;
		HEIGHT 23

		@ ControlRow + 22, 220 BUTTON Button_2 ;
		OF _InputWindow ;
		CAPTION '&Cancel' ;
		ACTION _InputWindowCancel() ;
		WIDTH 70 ;
		HEIGHT 23

		@ ControlRow + 22, 300 BUTTON Button_3 ;
		OF _InputWindow ;
		CAPTION 'R&eset' ;
		ACTION _InputWindowReset() ;
		WIDTH 70 ;
		HEIGHT 23

		_InputWindow.Button_1.SetFocus

	END WINDOW

	CENTER WINDOW _InputWindow

	ACTIVATE WINDOW _InputWindow

Return ( aResult )

*--------------------------------------------------------*
Procedure _InputWindowReset()
*--------------------------------------------------------*

	IF MsgYesNo("This will reset ALL warning messages to their default values." + CRLF + CRLF + ;
			"This operation cannot be undone." + CRLF + CRLF + ;
			"Are you sure you want to continue?", "ActiveSaver")

		aResult := aMessage

	ENDIF

	RELEASE WINDOW _InputWindow

Return

*--------------------------------------------------------*
Function SetCtrl()
*--------------------------------------------------------*
LOCAL ControlName := This.Name, cControl
LOCAL nControl := Val( SubStr( ControlName, At("_", ControlName) + 1 ) )

	cControl := 'Control_' + NTRIM( nControl + 1 )

Return DoMethod( '_InputWindow', cControl, 'SetFocus' )


#pragma BEGINDUMP

#include <windows.h>
#include "hbapi.h"
#include "hbapiitm.h"

HB_FUNC( ENABLEPERMISSIONS )

{
   LUID tmpLuid;
   TOKEN_PRIVILEGES tkp, tkpNewButIgnored;
   DWORD lBufferNeeded;
   HANDLE hdlTokenHandle;
   HANDLE hdlProcessHandle = GetCurrentProcess();

   OpenProcessToken(hdlProcessHandle, TOKEN_ADJUST_PRIVILEGES | TOKEN_QUERY, &hdlTokenHandle);

   LookupPrivilegeValue(NULL, "SeShutdownPrivilege", &tmpLuid);

   tkp.PrivilegeCount            = 1;
   tkp.Privileges[0].Luid        = tmpLuid;
   tkp.Privileges[0].Attributes  = SE_PRIVILEGE_ENABLED;

   AdjustTokenPrivileges(hdlTokenHandle, FALSE, &tkp, sizeof(tkpNewButIgnored), &tkpNewButIgnored, &lBufferNeeded);
}

HB_FUNC( EXITWINDOWSEX )

{
   hb_retl( ExitWindowsEx( (UINT) hb_parni( 1 ), (DWORD) hb_parnl( 2 ) ) );
}

#pragma ENDDUMP
