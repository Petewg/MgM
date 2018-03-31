/*
 * MINIGUI - Harbour Win32 GUI library
 *
 * Copyright 2002-08 Roberto Lopez <harbourminigui@gmail.com>
 * http://harbourminigui.googlepages.com/
 *
 * Copyright 2002-09 Grigory Filatov <gfilatov@inbox.ru>
*/

ANNOUNCE RDDSYS

#include "minigui.ch"

#define PROGRAM 'Floppy Checker'
#define VERSION ' version 2.3'
#define COPYRIGHT ' 2002-2009 Grigory Filatov'

#define SEM_FAILCRITICALERRORS  1

DECLARE WINDOW Form_2

Static lActive := .F., lDispErr := .t., nCheck := 1, ;
       cMsgErr := "Error reading floppy drive.", ;
       nDisk := 1, nInterval := 45, lShowIcon := .T.

Procedure Main(cConfig)
   Local oReg, dData := CtoD("")
   Local aDisk := {"A:","B:"}

   DEFAULT cConfig TO ""

   OPEN REGISTRY oReg KEY HKEY_CURRENT_USER ;
        SECTION "SOFTWARE\Floppy Checker\Options"

   GET VALUE dData NAME "Date" OF oReg

   IF UPPER(cConfig) # "CONFIG" .AND. !EMPTY(dData)

      GET VALUE nDisk NAME "Drive" OF oReg
      GET VALUE nCheck NAME "Check" OF oReg
      GET VALUE nInterval NAME "Interval" OF oReg
      GET VALUE lDispErr NAME "Display Error" OF oReg
      GET VALUE cMsgErr NAME "Message" OF oReg

   ELSE

      SET VALUE "Date" OF oReg TO Date()
      SET VALUE "Drive" OF oReg TO nDisk
      SET VALUE "Check" OF oReg TO nCheck
      SET VALUE "Interval" OF oReg  TO nInterval
      SET VALUE "Display Error" OF oReg TO lDispErr
      SET VALUE "Message" OF oReg TO cMsgErr

   ENDIF

   CLOSE REGISTRY oReg

   DEFINE WINDOW Form_1 ;
	AT 0,0 ;
	WIDTH 0 HEIGHT 0 ;
	TITLE PROGRAM ;
	MAIN NOSHOW ;
	ON INIT IF(UPPER(cConfig) # "CONFIG", , Config()) ;
	NOTIFYICON 'ICON_1' ;
	NOTIFYTOOLTIP PROGRAM ;
	ON NOTIFYCLICK CheckDrive(aDisk[nDisk])

	DEFINE NOTIFY MENU 
		ITEM 'Hide icon'	ACTION {|| lShowIcon := .F., SetTimer2(), ;
			ShowNotifyIcon( GetFormHandle("Form_1"), .F., NIL, NIL ) }
		SEPARATOR	
		ITEM 'Settings...'	ACTION Config()
		SEPARATOR	
		ITEM 'About...'	ACTION ShellAbout( "", ;
			PROGRAM + VERSION + CRLF + "Copyright " + Chr(169) + COPYRIGHT, ;
			LoadTrayIcon(GetInstance(), "ICON_1", 32, 32) )
		SEPARATOR	
		ITEM 'Exit'		ACTION Form_1.Release
	END MENU

	DEFINE TIMER Timer_1 ;
		INTERVAL nInterval * 1000 ;
		ACTION CheckDrive(aDisk[nDisk])

   END WINDOW

   ACTIVATE WINDOW Form_1

Return

/*
*/
Procedure CheckTopLeftCorner()
   Local aPos := GetCursorPos(), i

   IF aPos[1] = 0 .AND. aPos[2] = 0
      i := GetFormIndex("Form_1")
      IF ShowNotifyIcon( _HMG_aFormHandles[i], .T. , LoadTrayIcon( GetInstance(), ;
		_HMG_aFormNotifyIconName[i] ), _HMG_aFormNotifyIconToolTip[i] )
	Form_1.Timer_2.Release
	lShowIcon := .T.
      ENDIF
   ENDIF

Return

/*
*/
Procedure SetTimer2()

	DEFINE TIMER Timer_2 OF Form_1 ;
		INTERVAL 1000 ;
		ACTION CheckTopLeftCorner()

Return

/*
*/
Procedure CheckDrive(cDrive)
   Local nOldErrorMode

   If !lActive
      lActive := .T.

      nOldErrorMode := SetErrorMode( SEM_FAILCRITICALERRORS )

      IF lShowIcon
	Form_1.NotifyIcon := "ICON_2"
      ENDIF

      IF !Is_Ready(cDrive)
         IF lDispErr
            MsgStop(cMsgErr, "Error")
         ENDIF
      ENDIF

      SetErrorMode( nOldErrorMode )
      lActive := .F.

      IF lShowIcon
	Form_1.NotifyIcon := "ICON_1"
      ENDIF

   Endif

Return

/*
*/
FUNCTION Is_Ready(cDrive)
   Local lReady := lCheck(cDrive + "\."), n

   IF lReady
      RETURN .T.
   ELSE

      FOR n := 1 TO INT( 9 / nCheck )
          lReady := lCheck( cDrive + "\." )
          INKEY(.02)
      NEXT

      IF lReady
         RETURN .T.
      ENDIF

   ENDIF

RETURN .F.

/*
*/
Function lCheck(cPath)
   Local cCurDir := CurDrive() + ":\" + Curdir()
   Local lcheck := .f., n

   FOR n := 1 TO nCheck
       lcheck := ( DIRCHANGE(cPath) == 0 )
       INKEY(.02)
   NEXT

   IF lcheck
      DIRCHANGE( cCurDir )
   ENDIF

Return lcheck

/*
*/
Procedure Config()
   Local aDisk := {" A:"," B:"}

	DEFINE WINDOW Form_2 ;
		AT 0,0 WIDTH 490 HEIGHT 350 ;
		TITLE "Settings" ;
		ICON 'ICON_1' MODAL ;
		ON INIT Form_2.Button_1.SetFocus ;
		FONT "MS Sans Serif" SIZE 11

		@ 14,385 BUTTON Button_1 CAPTION "Save" ;
			ACTION ( SaveConfig(), Form_2.Release ) ;
			WIDTH 85 HEIGHT 26

		@ 50,385 BUTTON Button_2 CAPTION "Close" ACTION Form_2.Release ;
			WIDTH 85 HEIGHT 26

		@ 07,10 FRAME Frame_1 CAPTION "Floppy Drive" ;
			WIDTH 175 HEIGHT 52 OPAQUE
		@ 30,25 LABEL Label_1 VALUE "Which floppy:" ;
			WIDTH 94 HEIGHT 24
		@ 25,120 COMBOBOX Combo_1 ;
			WIDTH 45 HEIGHT 100 ;
			ITEMS aDisk VALUE nDisk

		@ 7,195 FRAME Frame_2 CAPTION "Check Drive" ;
			WIDTH 175 HEIGHT 52 OPAQUE
		@ 30,208 LABEL Label_2 VALUE "For" ;
			WIDTH 45 HEIGHT 24
		@ 26,245 SPINNER Spinner_1 RANGE 1,18 VALUE nCheck ;
			WIDTH 45 HEIGHT 24
		@ 30,305 LABEL Label_3 VALUE "second" ;
			WIDTH 50 HEIGHT 24

		@ 66,10 FRAME Frame_3 CAPTION "Interval" ;
			WIDTH 260 HEIGHT 52 OPAQUE
		@ 88,25 LABEL Label_4 VALUE "Check drive every" ;
			WIDTH 142 HEIGHT 24
		@ 85,145 SPINNER Spinner_2 RANGE 5,900 VALUE nInterval ;
			WIDTH 48 HEIGHT 24 INCREMENT 5
		@ 88,205 LABEL Label_6 VALUE "seconds" ;
			WIDTH 55 HEIGHT 24

		@ 126,10 FRAME Frame_4 CAPTION "Error Message" ;
			WIDTH 360 HEIGHT 188 OPAQUE

		@ 146,25 CHECKBOX Check_1 ;
		CAPTION "Display this message after checking the floppy:" ;
			WIDTH 320 HEIGHT 28 ;
			VALUE lDispErr
		@ 174,22 EDITBOX Edit_1 WIDTH 336 HEIGHT 128 VALUE cMsgErr

		@ 180,395 FRAME Frame_5 WIDTH 65 HEIGHT 65
		@ 190,405 FRAME Frame_6 WIDTH 45 HEIGHT 45
		@ 200,415 FRAME Frame_7 WIDTH 25 HEIGHT 25

	END WINDOW

	CENTER WINDOW Form_2
	ACTIVATE WINDOW Form_2

Return

/*
*/
Procedure SaveConfig()
   Local oReg

   nDisk     := Form_2.Combo_1.Value
   nCheck    := Form_2.Spinner_1.Value
   nInterval := Form_2.Spinner_2.Value
   lDispErr  := Form_2.Check_1.Value
   cMsgErr   := ALLTRIM(Form_2.Edit_1.Value)

   OPEN REGISTRY oReg KEY HKEY_CURRENT_USER ;
        SECTION "SOFTWARE\Floppy Checker\Options"

   SET VALUE "Date" OF oReg TO Date()
   SET VALUE "Drive" OF oReg TO nDisk
   SET VALUE "Check" OF oReg TO nCheck
   SET VALUE "Interval" OF oReg TO nInterval
   SET VALUE "Display Error" OF oReg TO lDispErr
   SET VALUE "Message" OF oReg TO cMsgErr

   CLOSE REGISTRY oReg

   Form_1.Timer_1.Value := nInterval * 1000

Return

*--------------------------------------------------------*
DECLARE DLL_TYPE_LONG SetErrorMode( DLL_TYPE_LONG nMode ) ;
	IN KERNEL32.DLL
