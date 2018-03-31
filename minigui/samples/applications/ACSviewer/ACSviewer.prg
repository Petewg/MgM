/*
 * MINIGUI - Harbour Win32 GUI library
 * Copyright 2002-05 Roberto Lopez <harbourminigui@gmail.com>
 * http://harbourminigui.googlepages.com/
 *
 * Copyright 2005 Grigory Filatov <gfilatov@inbox.ru>
*/

#include "minigui.ch"
#Include "TMsAgent.Ch"

ANNOUNCE RDDSYS

#define PROGRAM		'ACS Viewer'
#define VERSION		' 1.1'
#define BUILD		' 12'
#define COPYRIGHT	' 2005 Grigory Filatov'

#define COLOR_WINDOW	5
#define CLR_BACK	{236, 233, 216}
#define CLR_BTNBACK	{244, 244, 240}

#define MsgInfo( c, t ) MsgInfo( c, t, , .f. )
#define MsgAlert( c ) MsgEXCLAMATION( c, "Error" , .f. )

#define OPT_SIZE  1
#define OPT_POS   2
#define OPT_ROW   3
#define OPT_COL   4
#define OPT_CLICK 5
#define OPT_MULTI 6
#define OPT_TOP   7

Static oAgent, aOptions := {}

DECLARE WINDOW Form_Options

*------------------------
Procedure main()
*------------------------
Local cPathAgent := ""
Local cFile, cTxtFile := ""
Local aAnimate := LoadAnimArray()
Local aAgents := GetAgentsAvailables()
Local mVar := GetSysColor( COLOR_WINDOW ), ;
	backcolor := { GetRed(mVar), GetGreen(mVar), GetBlue(mVar) }
Local cRegKey := "Software\Grigory Filatov\ACS Viewer\Preferences"

	Aadd( aOptions, {"AgentSize", 2} )
	Aadd( aOptions, {"SaveWindowPosition", 0} )
	Aadd( aOptions, {"Row", 0} )
	Aadd( aOptions, {"Col", 0} )
	Aadd( aOptions, {"PlayActionDoubleClickList", 1} )
	Aadd( aOptions, {"ManyCopies", 0} )
	Aadd( aOptions, {"TopMost", 0} )

	IF ExistRegVar(HKEY_CURRENT_USER, cRegKey, aOptions[OPT_SIZE][1])
		aOptions[OPT_POS][2] := Val( GetRegVar(HKEY_CURRENT_USER, cRegKey, aOptions[OPT_POS][1], "0") )
		aOptions[OPT_ROW][2] := Val( GetRegVar(HKEY_CURRENT_USER, cRegKey, aOptions[OPT_ROW][1], "0") )
		aOptions[OPT_COL][2] := Val( GetRegVar(HKEY_CURRENT_USER, cRegKey, aOptions[OPT_COL][1], "0") )
		aOptions[OPT_CLICK][2] := Val( GetRegVar(HKEY_CURRENT_USER, cRegKey, aOptions[OPT_CLICK][1], "1") )
		aOptions[OPT_MULTI][2] := Val( GetRegVar(HKEY_CURRENT_USER, cRegKey, aOptions[OPT_MULTI][1], "0") )
		aOptions[OPT_TOP][2] := Val( GetRegVar(HKEY_CURRENT_USER, cRegKey, aOptions[OPT_TOP][1], "0") )
	ELSE
		SaveOptions( cRegKey )
	ENDIF

	IF EMPTY(aOptions[OPT_MULTI][2])
		SET MULTIPLE OFF WARNING
	ENDIF

   IF Len(aAgents) > 0
	cPathAgent := cFilePath( aAgents[ 1 ] )
   ELSE
	MsgAlert( "Can not locate installed MsAgent!" )
   ENDIF

   SET PROGRAMMATICCHANGE OFF

   DEFINE WINDOW Form_1 AT 0,0 ;
	WIDTH 399 HEIGHT 373 - IF(IsXPThemeActive(), 0, 6) ;
	TITLE PROGRAM + VERSION ;
	ICON "MAIN" ;
	MAIN ;
	NOMAXIMIZE NOSIZE ;
	ON INIT InitViewer() ;
	ON RELEASE IF( oAgent == NIL, NIL, oAgent:End() ) ;
	ON GOTFOCUS OnPaintViewer() ;
	ON PAINT OnPaintViewer() ;
	FONT GetSysFont() SIZE 8

	DEFINE MAIN MENU

		POPUP "&File"
			ITEM '&Load' + Chr(9) + 'Ctrl+L' ;
				ACTION Form_1.Button_1.OnClick NAME MenuLoad
			ITEM '&Unload' + Chr(9) + 'Ctrl+U' ;
				ACTION Form_1.Button_2.OnClick NAME MenuUnload DISABLED
			SEPARATOR
			ITEM 'E&xit' + Chr(9) + 'Ctrl+X' ACTION Form_1.Release
		END POPUP

		POPUP "&View"
			ITEM '&TopMost Window' ACTION ( Form_1.MenuTopmost.Checked := !Form_1.MenuTopmost.Checked, ;
			SetWindowPos( _HMG_MainHandle, IF(Form_1.MenuTopmost.Checked, -1, -2), 0, 0, 0, 0, 3 ) ) NAME MenuTopmost
		END POPUP

		POPUP "&Action"
			ITEM '&Play' + Chr(9) + 'Ctrl+P' ACTION ( oAgent:Stop(), oAgent:Animate( Form_1.List_1.Item( Form_1.List_1.Value ) ) ) NAME MenuPlay DISABLED
			ITEM '&Stop' + Chr(9) + 'Ctrl+S' ACTION oAgent:Stop() NAME MenuStop DISABLED
			ITEM '&Reset' + Chr(9) + 'Ctrl+R' ACTION ( oAgent:Stop(), oAgent:Animate( "Idle1_1" ) ) NAME MenuReset DISABLED
			ITEM 'S&ay' + Chr(9) + 'Ctrl+K' ACTION IF( Empty(Form_1.Text_1.Value), , oAgent:Say( Form_1.Text_1.Value ) ) NAME MenuSay DISABLED
			ITEM 'R&ead' + Chr(9) + 'Ctrl+Q' ACTION IF(File(cTxtFile), oAgent:Say( MemoRead(cTxtFile) ), ) NAME MenuRead DISABLED
			ITEM '&Move' + Chr(9) + 'Ctrl+M' ACTION Form_1.Button_10.OnClick NAME MenuMove DISABLED
			SEPARATOR
			ITEM '&Description' + Chr(9) + 'Ctrl+D' ACTION Form_1.Button_6.OnClick NAME MenuIntro DISABLED
		END POPUP

		POPUP "&Service"
			ITEM '&Options' ACTION ( IF(IsXPThemeActive(), , mVar := Form_1.Tab_1.Value), ;
				SetOptions( cRegKey ), IF(IsXPThemeActive(), , ( Form_1.Tab_1.Value := IF(mVar > 1, mVar-1, 3), Form_1.Tab_1.Value := mVar )) )
		END POPUP

		POPUP "&?"
			ITEM '&License' ACTION ( IF(IsXPThemeActive(), , mVar := Form_1.Tab_1.Value), ;
				ShowLicense(), IF(IsXPThemeActive(), , ( Form_1.Tab_1.Value := IF(mVar > 1, mVar-1, 3), Form_1.Tab_1.Value := mVar )) )
			SEPARATOR
			ITEM 'A&bout' + Chr(9) + 'Ctrl+F1' ACTION AboutPrg()
		END POPUP

	END MENU

	DEFINE TAB Tab_1 AT 8, 8 WIDTH Form_1.Width - 23 HEIGHT Form_1.Height - 62 VALUE 1

        PAGE "Actions"

            DEFINE IMAGE Image_1
              ROW    42
              COL    10
              WIDTH  48
              HEIGHT 48
              PICTURE "CHAT"
              VISIBLE .T.
              STRETCH .F.
            END IMAGE

            DEFINE FRAME Frame_1
                ROW    34
                COL    68
                WIDTH  296
                HEIGHT 250
                CAPTION "Test of actions:"
                OPAQUE .F.
                BACKCOLOR IF(IsXPThemeActive(), backcolor, )
            END FRAME

            DEFINE LISTBOX List_1
                ROW    58
                COL    84
                WIDTH  160
                HEIGHT 211
                ITEMS aAnimate
                VALUE 0
                ONCHANGE Nil
                ONDBLCLICK IF(EMPTY(aOptions[OPT_CLICK][2]), NIL, ( oAgent:Stop(), oAgent:Animate( Form_1.List_1.Item( This.Value ) ) ))
            END LISTBOX

            DEFINE BUTTON Button_1
                ROW    58
                COL    260
                WIDTH  86
                HEIGHT 22
                CAPTION "Load"
                ACTION ( cFile := Getfile( { {"Microsoft Agents (*.acs)", "*.acs"} }, ;
				"Select an agent...", cPathAgent, .f., .t. ), ;
				IF( EMPTY(cFile), , LoadAgent( cFile ) ) )
            END BUTTON

            DEFINE BUTTON Button_2
                ROW    90
                COL    260
                WIDTH  86
                HEIGHT 22
                CAPTION "Unload"
                ACTION ( oAgent:End(), oAgent := NIL, ;
				Form_1.Text_3.Value := 0, Form_1.Text_4.Value := 0, ;
				Form_1.Button_1.Enabled := .T., InitViewer(), DisableMainMenu() )
            END BUTTON

            DEFINE BUTTON Button_3
                ROW    138
                COL    260
                WIDTH  86
                HEIGHT 22
                CAPTION "Play"
                ACTION ( oAgent:Stop(), oAgent:Animate( Form_1.List_1.Item( Form_1.List_1.Value ) ) )
            END BUTTON

            DEFINE BUTTON Button_4
                ROW    170
                COL    260
                WIDTH  86
                HEIGHT 22
                CAPTION "Stop"
                ACTION oAgent:Stop()
            END BUTTON

            DEFINE BUTTON Button_5
                ROW    202
                COL    260
                WIDTH  86
                HEIGHT 22
                CAPTION "Reset"
                ACTION ( oAgent:Stop(), oAgent:Animate( "Idle1_1" ) )
            END BUTTON

            DEFINE BUTTON Button_6
                ROW    242
                COL    260
                WIDTH  86
                HEIGHT 22
                CAPTION "Description"
                ACTION MsgInfo( oAgent:GetIntro(), "Description of " + oAgent:GetName() )
            END BUTTON

        END PAGE 

        PAGE "Speech"

            DEFINE IMAGE Image_2
              ROW    42
              COL    10
              WIDTH  48
	        HEIGHT 48
              PICTURE "SOUND"
              VISIBLE .T.
              STRETCH .F.
            END IMAGE

            DEFINE FRAME Frame_2
                ROW    34
                COL    68
                WIDTH  296
                HEIGHT 64
                CAPTION "Test of speech:"
                OPAQUE .F.
                BACKCOLOR IF(IsXPThemeActive(), backcolor, )
            END FRAME

            DEFINE TEXTBOX Text_1
                ROW    59
                COL    82
                WIDTH  160
                HEIGHT 20
                VALUE ""
            END TEXTBOX

            DEFINE BUTTON Button_7
                ROW    58
                COL    260
                WIDTH  86
                HEIGHT 22
                CAPTION "Say"
                ACTION IF( Empty(Form_1.Text_1.Value), MsgInfo( "Enter text of speech!", PROGRAM + VERSION ), oAgent:Say( Form_1.Text_1.Value ) )
            END BUTTON

            DEFINE FRAME Frame_3
                ROW    106
                COL    68
                WIDTH  296
                HEIGHT 114
                CAPTION "Reading:"
                OPAQUE .F.
                BACKCOLOR IF(IsXPThemeActive(), backcolor, )
            END FRAME

            DEFINE LABEL Label_1
                ROW    124
                COL    84
                WIDTH  140
                HEIGHT 16
                VALUE "Select a text file for reading:"
                TRANSPARENT .T.
            END LABEL

            DEFINE LABEL Label_2
                ROW    148
                COL    84
                WIDTH  28
                HEIGHT 16
                VALUE "Path:"
		TRANSPARENT .T.
            END LABEL

            DEFINE TEXTBOX Text_2
                ROW    146
                COL    114
                WIDTH  232
                HEIGHT 20
                VALUE ""
            END TEXTBOX

            DEFINE BUTTON Button_8
                ROW    178
                COL    156
                WIDTH  86
                HEIGHT 22
                CAPTION "Open"
                ACTION ( cFile := Getfile( { {"Text Files (*.txt)", "*.txt"} }, ;
				"Select a text file for reading...", NIL, .f., .t. ), ;
				IF( EMPTY(cFile), ( cTxtFile := "", Form_1.Text_2.Value := cTxtFile, Form_1.Button_9.Enabled := .F. ), ;
				( Form_1.Text_2.Value := cFile, Form_1.Button_9.Enabled := .T., ;
				cTxtFile := cFile ) ) )
            END BUTTON

            DEFINE BUTTON Button_9
                ROW    178
                COL    260
                WIDTH  86
                HEIGHT 22
                CAPTION "Read"
                ACTION IF(File(cTxtFile), oAgent:Say( MemoRead(cTxtFile) ), )
            END BUTTON

        END PAGE 

        PAGE "Moving"

            DEFINE IMAGE Image_3
              ROW    42
              COL    10
              WIDTH  48
	        HEIGHT 48
              PICTURE "MOVE"
              VISIBLE .T.
              STRETCH .F.
            END IMAGE

            DEFINE FRAME Frame_4
                ROW    34
                COL    68
                WIDTH  296
                HEIGHT 88
                CAPTION "Test of moving:"
                OPAQUE .F.
                BACKCOLOR IF(IsXPThemeActive(), backcolor, )
            END FRAME

            DEFINE LABEL Label_3
                ROW    58
                COL    84
                WIDTH  90
                HEIGHT 16
                VALUE "Coordinate at X:"
                TRANSPARENT .T.
            END LABEL

            DEFINE TEXTBOX Text_3
                ROW    56
                COL    178
                WIDTH  58
                HEIGHT 20
                NUMERIC .T.
                INPUTMASK "99999"
            END TEXTBOX

            DEFINE LABEL Label_4
                ROW    90
                COL    84
                WIDTH  90
                HEIGHT 16
                VALUE "Coordinate at Y:"
                TRANSPARENT .T.
            END LABEL

            DEFINE TEXTBOX Text_4
                ROW    88
                COL    178
                WIDTH  58
                HEIGHT 20
                NUMERIC .T.
                INPUTMASK "99999"
            END TEXTBOX

            DEFINE BUTTON Button_10
                ROW    70
                COL    252
                WIDTH  96
                HEIGHT 22
                CAPTION "Move"
                ACTION IF(Form_1.Text_3.Value = 0 .AND. Form_1.Text_4.Value = 0, , oAgent:Move(Form_1.Text_3.Value, Form_1.Text_4.Value))
            END BUTTON

        END PAGE 

    END TAB 

   ON KEY CONTROL+L ACTION IF( oAgent == NIL, Form_1.Button_1.OnClick, )
   ON KEY CONTROL+U ACTION IF( oAgent == NIL, , Form_1.Button_2.OnClick )
   ON KEY CONTROL+X ACTION Form_1.Release

   ON KEY CONTROL+P ACTION IF( oAgent == NIL, , ( oAgent:Stop(), oAgent:Animate( Form_1.List_1.Item( Form_1.List_1.Value ) ) ) )
   ON KEY CONTROL+S ACTION IF( oAgent == NIL, , oAgent:Stop() )
   ON KEY CONTROL+R ACTION IF( oAgent == NIL, , ( oAgent:Stop(), oAgent:Animate( "Idle1_1" ) ) )
   ON KEY CONTROL+K ACTION IF( oAgent == NIL, , IF( Empty(Form_1.Text_1.Value), , oAgent:Say( Form_1.Text_1.Value ) ) )
   ON KEY CONTROL+Q ACTION IF( oAgent == NIL, , IF(File(cTxtFile), oAgent:Say( MemoRead(cTxtFile) ), ) )
   ON KEY CONTROL+M ACTION IF( oAgent == NIL, , Form_1.Button_10.OnClick )

   ON KEY CONTROL+D ACTION IF( oAgent == NIL, , Form_1.Button_6.OnClick )

   ON KEY CONTROL+F1 ACTION AboutPrg()

   END WINDOW

   IF !EMPTY(aOptions[OPT_TOP][2])
	Form_1.MenuTopmost.Checked := .T.
	SetWindowPos( _HMG_MainHandle, -1, 0, 0, 0, 0, 3 )
   ENDIF

   IF EMPTY(aOptions[OPT_POS][2])
	Form_1.Center
   ELSE
	Form_1.Row := aOptions[OPT_ROW][2]
	Form_1.Col := aOptions[OPT_COL][2]
   ENDIF

   Form_1.Activate

Return

*------------------------
Procedure InitViewer()
*------------------------

	Form_1.List_1.Enabled := .F.

	Form_1.Button_2.Enabled := .F.
	Form_1.Button_3.Enabled := .F.
	Form_1.Button_4.Enabled := .F.
	Form_1.Button_5.Enabled := .F.
	Form_1.Button_6.Enabled := .F.
	Form_1.Button_7.Enabled := .F.
	Form_1.Button_8.Enabled := .F.
	Form_1.Button_9.Enabled := .F.
	Form_1.Button_10.Enabled := .F.

	Form_1.Text_1.Enabled := .F.
	Form_1.Text_2.Enabled := .F.
	Form_1.Text_3.Enabled := .F.
	Form_1.Text_4.Enabled := .F.

Return

*------------------------
Procedure AboutPrg()
*------------------------
Local mVar := Form_1.Tab_1.Value

	MsgAbout()
	IF !IsXPThemeActive()
		Form_1.Tab_1.Value := IF(mVar > 1, mVar-1, 3)
		Form_1.Tab_1.Value := mVar
	ENDIF

Return

*------------------------
Procedure EnableMainMenu()
*------------------------

	Form_1.MenuPlay.Enabled := .T.
	Form_1.MenuStop.Enabled := .T.
	Form_1.MenuReset.Enabled := .T.
	Form_1.MenuSay.Enabled := .T.
	Form_1.MenuRead.Enabled := .T.
	Form_1.MenuMove.Enabled := .T.

	Form_1.MenuIntro.Enabled := .T.

	Form_1.MenuUnload.Enabled := .T.
	Form_1.MenuLoad.Enabled := .F.

Return

*------------------------
Procedure DisableMainMenu()
*------------------------

	Form_1.MenuPlay.Enabled := .F.
	Form_1.MenuStop.Enabled := .F.
	Form_1.MenuReset.Enabled := .F.
	Form_1.MenuSay.Enabled := .F.
	Form_1.MenuRead.Enabled := .F.
	Form_1.MenuMove.Enabled := .F.

	Form_1.MenuIntro.Enabled := .F.

	Form_1.MenuLoad.Enabled := .T.
	Form_1.MenuUnload.Enabled := .F.

Return

*------------------------
Function LoadAnimArray()
*------------------------
Local aArr := {}

	Aadd( aArr, "Blink")
	Aadd( aArr, "Idle1_1")
	Aadd( aArr, "Idle1_2")
	Aadd( aArr, "Idle1_3")
	Aadd( aArr, "Idle1_4")
	Aadd( aArr, "Idle2_1")
	Aadd( aArr, "Idle2_2")
	Aadd( aArr, "Idle3_1")
	Aadd( aArr, "Idle3_2")
	Aadd( aArr, "Greet")
	Aadd( aArr, "GestureUp")
	Aadd( aArr, "GestureDown")
	Aadd( aArr, "GestureLeft")
	Aadd( aArr, "GestureRight")
	Aadd( aArr, "Show")
	Aadd( aArr, "Hide")
	Aadd( aArr, "Hearing_1")
	Aadd( aArr, "Hearing_2")
	Aadd( aArr, "Hearing_3")
	Aadd( aArr, "Hearing_4")
	Aadd( aArr, "Alert")
	Aadd( aArr, "Explain")
	Aadd( aArr, "Processing")
	Aadd( aArr, "Thinking")
	Aadd( aArr, "Searching")
	Aadd( aArr, "Acknowledge")
	Aadd( aArr, "Wave")
	Aadd( aArr, "DontRecognize")
	Aadd( aArr, "Uncertain")
	Aadd( aArr, "Decline")
	Aadd( aArr, "Sad")
	Aadd( aArr, "StopListening")
	Aadd( aArr, "GetAttention")
	Aadd( aArr, "GetAttentionReturn")
	Aadd( aArr, "Surprised")
	Aadd( aArr, "Announce")
	Aadd( aArr, "Reading")
	Aadd( aArr, "Read")
	Aadd( aArr, "ReadReturn")
	Aadd( aArr, "Writing")
	Aadd( aArr, "Write")
	Aadd( aArr, "WriteReturn")
	Aadd( aArr, "Congratulate")
	Aadd( aArr, "Congratulate_2")
	Aadd( aArr, "Confused")
	Aadd( aArr, "Suggest")
	Aadd( aArr, "MoveRight")
	Aadd( aArr, "MoveLeft")
	Aadd( aArr, "MoveUp")
	Aadd( aArr, "MoveDown")
	Aadd( aArr, "StartListening")
	Aadd( aArr, "ReadContinued")
	Aadd( aArr, "WriteContinued")
	Aadd( aArr, "GetAttentionContinued")
	Aadd( aArr, "DoMagic1")
	Aadd( aArr, "DoMagic2")
	Aadd( aArr, "LookDown")
	Aadd( aArr, "LookDownBlink")
	Aadd( aArr, "LookDownReturn")
	Aadd( aArr, "LookLeft")
	Aadd( aArr, "LookLeftBlink")
	Aadd( aArr, "LookLeftReturn")
	Aadd( aArr, "LookRight")
	Aadd( aArr, "LookRightBlink")
	Aadd( aArr, "LookRightReturn")
	Aadd( aArr, "LookUp")
	Aadd( aArr, "LookUpBlink")
	Aadd( aArr, "LookUpReturn")
	Aadd( aArr, "Pleased")
	Aadd( aArr, "Process")
	Aadd( aArr, "Search")
	Aadd( aArr, "Think")

Return Asort(aArr)

*------------------------
Procedure OnPaintViewer()
*------------------------
Local mVar

DRAW LINE IN WINDOW Form_1 ;
	AT 1,0 TO 1,399 ;
	PENCOLOR WHITE

DRAW LINE IN WINDOW Form_1 ;
	AT 2,0 TO 2,399 ;
	PENCOLOR GRAY

DRAW LINE IN WINDOW Form_1 ;
	AT 3,0 TO 3,399 ;
	PENCOLOR WHITE

IF !IsXPThemeActive()
	DRAW RECTANGLE IN WINDOW Form_1 ;
		AT 49,17 TO 99,67

	mVar := Form_1.Tab_1.Value
	IF mVar == 1
		Form_1.Image_1.Picture := "CHAT"
	ELSEIF mVar == 2
		Form_1.Image_2.Picture := "SOUND"
	ELSE
		Form_1.Image_3.Picture := "MOVE"
	ENDIF
ENDIF

Return

*------------------------
Procedure LoadAgent( cFileAgent )
*------------------------
Local cAgentName := Capital( cFileNoExt( cFileAgent ) )

	oAgent := TMsAgent():New( cAgentName, .T., cFileAgent, .T. , .T. )

	IF !oAgent:lOk
		MsgAlert( "Can not start " + cAgentName )
		Return
	EndIF

	IF oAgent:UsedByOtherApps()
		MsgInfo( cAgentName + " is used by other application!", PROGRAM + VERSION )
	EndIF

	EnableMainMenu()
	Form_1.Button_1.Enabled := .F.

	Form_1.List_1.Enabled := .T.
	Form_1.List_1.Value := 1

	Form_1.Button_2.Enabled := .T.
	Form_1.Button_3.Enabled := .T.
	Form_1.Button_4.Enabled := .T.
	Form_1.Button_5.Enabled := .T.
	Form_1.Button_6.Enabled := .T.
	Form_1.Button_7.Enabled := .T.
	Form_1.Button_8.Enabled := .T.
	Form_1.Button_10.Enabled := .T.

	Form_1.Text_1.Enabled := .T.
	Form_1.Text_2.Enabled := .T.
	Form_1.Text_3.Enabled := .T.
	Form_1.Text_4.Enabled := .T.
	Form_1.Text_3.Value := 0
	Form_1.Text_4.Value := 0

	Form_1.List_1.Setfocus

	oAgent:Show()

Return

*------------------------
Procedure ShowLicense()
*------------------------
Local cFile := GetStartupFolder() + "\" + "License.rtf"

IF FILE(cFile)

   DEFINE WINDOW Form_License AT 0,0 ;
	WIDTH 599 HEIGHT 369 - IF(IsXPThemeActive(), 0, 6) ;
	TITLE "License agreement" ;
	ICON "MAIN" ;
	MODAL ;
	NOSIZE ;
	ON PAINT OnPaintLicense() ;
	FONT GetSysFont() SIZE IF(IsXPThemeActive(), 9, 8) ;
	BACKCOLOR IF(IsXPThemeActive(), NIL, CLR_BACK)

	DEFINE IMAGE Image_1
        	ROW    8
		COL    8
        	WIDTH  48
		HEIGHT 48
        	PICTURE "EDIT"
		VISIBLE .T.
        	STRETCH .F.
	END IMAGE

	DEFINE BUTTONEX Button_1
		ROW    307
		COL    497
		WIDTH  87
		HEIGHT 23
		CAPTION "OK"
		BACKCOLOR IF(IsXPThemeActive(), NIL, CLR_BTNBACK)
		ACTION Form_License.Release
	END BUTTONEX

	@ 8,64 RICHEDITBOX Edit_1 ;
		WIDTH 522 ;
	 	HEIGHT 282 ;
		FILE cFile ;
		VALUE '' ;
		READONLY ;
		NOTABSTOP ;
		NOHSCROLL

   END WINDOW

   Form_License.Center
   Form_License.Activate

ELSE
   MsgAlert( "Can not locate a license!" )
ENDIF

Return

*------------------------
Procedure OnPaintLicense()
*------------------------

DRAW LINE IN WINDOW Form_License ;
	AT 297,0 TO 297,599 ;
	PENCOLOR GRAY

DRAW LINE IN WINDOW Form_License ;
	AT 298,0 TO 298,599 ;
	PENCOLOR WHITE

Return

*------------------------
Procedure MsgAbout()
*------------------------

   DEFINE WINDOW Form_About AT 0,0 ;
	WIDTH 431 HEIGHT 257 - IF(IsXPThemeActive(), 0, 6) ;
	TITLE "About" ;
	ICON "MAIN" ;
	MODAL ;
	NOSIZE ;
	ON PAINT OnPaintAbout() ;
	FONT GetSysFont() SIZE IF(IsXPThemeActive(), 9, 8) ;
	BACKCOLOR IF(IsXPThemeActive(), NIL, CLR_BACK)

	DEFINE IMAGE Image_1
        	ROW    16
		COL    8
        	WIDTH  64
		HEIGHT 64
        	PICTURE "ABOUT"
		VISIBLE .T.
        	STRETCH .F.
	END IMAGE

	DEFINE FRAME Frame_1
		ROW    14
		COL    82
		WIDTH  335
		HEIGHT 82
	END FRAME

	DEFINE LABEL Label_1
		ROW    24
		COL    96
		WIDTH  280
		HEIGHT 16
		VALUE "Version" + VERSION + " build" + BUILD + " for Microsoft Windows"
		TRANSPARENT .T.
	END LABEL

	DEFINE LABEL Label_2
		ROW    46
		COL    96
		WIDTH  300
		HEIGHT 16
		VALUE "Copyright " + CHR(169) + COPYRIGHT + ". All rights reserved"
		TRANSPARENT .T.
	END LABEL

	DEFINE LABEL Label_3
		ROW    70
		COL    96
		WIDTH  120
		HEIGHT 16
		VALUE "Send your comments to:"
		TRANSPARENT .T.
	END LABEL

	@ 70, 216 HYPERLINK Label_4				;
		VALUE "gfilatov@inbox.ru"			;
		ADDRESS "gfilatov@inbox.ru?cc=&bcc=" +	;
			"&subject=ACS%20Viewer%20Feedback:"	;
		WIDTH 96 HEIGHT 14				;
		TRANSPARENT HANDCURSOR

	DEFINE FRAME Frame_2
		ROW    108
		COL    82
		WIDTH  335
		HEIGHT 70
	END FRAME

	DEFINE LABEL Label_5
		ROW    118
		COL    96
		WIDTH  325
		HEIGHT 14
		VALUE "Thanks to these icon artists who gave us permission to use their"
		TRANSPARENT .T.
	END LABEL

	DEFINE LABEL Label_6
		ROW    132
		COL    96
		WIDTH  150
		HEIGHT 14
		VALUE "icons in the my program:"
		TRANSPARENT .T.
	END LABEL

	DEFINE LABEL Label_7
		ROW    154
		COL    96
		WIDTH  100
		HEIGHT 14
		VALUE "Icons by: Fast Icon"
		TRANSPARENT .T.
	END LABEL

	@ 154, 200 HYPERLINK Label_8			;
		VALUE "http://www.fasticon.com"		;
		ADDRESS "http://www.fasticon.com"	;
		WIDTH 120 HEIGHT 14			;
		TRANSPARENT HANDCURSOR

	DEFINE BUTTONEX Button_1
		ROW    195
		COL    160
		WIDTH  105
		HEIGHT 23
		CAPTION "OK"
		BACKCOLOR IF(IsXPThemeActive(), NIL, CLR_BTNBACK)
		ACTION Form_About.Release
	END BUTTONEX

   END WINDOW

   Form_About.Center
   Form_About.Activate

Return

*------------------------
Procedure OnPaintAbout()
*------------------------

DRAW LINE IN WINDOW Form_About ;
	AT 184,0 TO 184,431 ;
	PENCOLOR GRAY

DRAW LINE IN WINDOW Form_About ;
	AT 185,0 TO 185,431 ;
	PENCOLOR WHITE

Return

*------------------------
Procedure SetOptions( cKey )
*------------------------

   IF !Empty(aOptions[OPT_MULTI][2] := Val( GetRegVar(HKEY_CURRENT_USER, cKey, aOptions[OPT_MULTI][1], "0") ))
	aOptions[OPT_POS][2] := Val( GetRegVar(HKEY_CURRENT_USER, cKey, aOptions[OPT_POS][1], "0") )
	aOptions[OPT_ROW][2] := Val( GetRegVar(HKEY_CURRENT_USER, cKey, aOptions[OPT_ROW][1], "0") )
	aOptions[OPT_COL][2] := Val( GetRegVar(HKEY_CURRENT_USER, cKey, aOptions[OPT_COL][1], "0") )
	aOptions[OPT_CLICK][2] := Val( GetRegVar(HKEY_CURRENT_USER, cKey, aOptions[OPT_CLICK][1], "1") )
	aOptions[OPT_TOP][2] := Val( GetRegVar(HKEY_CURRENT_USER, cKey, aOptions[OPT_TOP][1], "0") )
   ENDIF

   DEFINE WINDOW Form_Options AT 0,0 ;
	WIDTH 367 HEIGHT 305 - IF(IsXPThemeActive(), 0, 6) ;
	TITLE "Options" ;
	ICON "MAIN" ;
	MODAL ;
	NOSIZE ;
	ON INIT ( Form_Options.Button_3.Enabled := .F. ) ;
	ON PAINT OnPaintOptions() ;
	FONT GetSysFont() SIZE IF(IsXPThemeActive(), 9, 8) ;
	BACKCOLOR IF(IsXPThemeActive(), NIL, CLR_BACK)

	DEFINE BUTTONEX Button_1
		ROW    243
		COL    75
		WIDTH  87
		HEIGHT 22
		CAPTION "OK"
		BACKCOLOR IF(IsXPThemeActive(), NIL, CLR_BTNBACK)
		ACTION ( ApplySaveOptions( cKey ), ThisWindow.Release )
	END BUTTONEX

	DEFINE BUTTONEX Button_2
		ROW    243
		COL    171
		WIDTH  87
		HEIGHT 22
		CAPTION "Cancel"
		BACKCOLOR IF(IsXPThemeActive(), NIL, CLR_BTNBACK)
		ACTION ThisWindow.Release
	END BUTTONEX

	DEFINE BUTTONEX Button_3
		ROW    243
		COL    267
		WIDTH  87
		HEIGHT 22
		CAPTION "Apply"
		BACKCOLOR IF(IsXPThemeActive(), NIL, CLR_BTNBACK)
		ACTION ( ApplySaveOptions( cKey ), Form_Options.Button_3.Enabled := .F. )
	END BUTTONEX

	DEFINE FRAME Frame_1
		ROW    10
		COL    10
		WIDTH  344
		HEIGHT 96
                CAPTION "General:"
                OPAQUE .F.
                BACKCOLOR IF(IsXPThemeActive(), NIL, CLR_BACK)
	END FRAME

	DEFINE CHECKBOX Check_1
		ROW	24
		COL	24
		WIDTH  120
		CAPTION "TopMost Window"
		VALUE !Empty(aOptions[OPT_TOP][2])
                BACKCOLOR IF(IsXPThemeActive(), NIL, CLR_BACK)
		ONCHANGE ( Form_Options.Button_3.Enabled := .T. )
	END CHECKBOX

	DEFINE CHECKBOX Check_2
		ROW	48
		COL	24
		WIDTH  220
		CAPTION "Allow multiple copies of program at a time"
		VALUE !Empty(aOptions[OPT_MULTI][2])
                BACKCOLOR IF(IsXPThemeActive(), NIL, CLR_BACK)
		ONCHANGE ( Form_Options.Button_3.Enabled := .T. )
	END CHECKBOX

	DEFINE CHECKBOX Check_3
		ROW	72
		COL	24
		WIDTH  150
		CAPTION "Save position of Window"
		VALUE !Empty(aOptions[OPT_POS][2])
                BACKCOLOR IF(IsXPThemeActive(), NIL, CLR_BACK)
		ONCHANGE ( Form_Options.Button_3.Enabled := .T. )
	END CHECKBOX

	DEFINE FRAME Frame_2
		ROW    116
		COL    10
		WIDTH  344
		HEIGHT 54
                CAPTION "Mouse event:"
                OPAQUE .F.
                BACKCOLOR IF(IsXPThemeActive(), NIL, CLR_BACK)
	END FRAME

	DEFINE CHECKBOX Check_4
		ROW    136
		COL	24
		WIDTH  260
		HEIGHT 24
		CAPTION "Play animation on mouse double click at action list"
		VALUE !Empty(aOptions[OPT_CLICK][2])
                BACKCOLOR IF(IsXPThemeActive(), NIL, CLR_BACK)
		ONCHANGE ( Form_Options.Button_3.Enabled := .T. )
	END CHECKBOX

	DEFINE FRAME Frame_3
		ROW    180
		COL    10
		WIDTH  344
		HEIGHT 44
                CAPTION "Size of agent:"
                OPAQUE .F.
                BACKCOLOR IF(IsXPThemeActive(), NIL, CLR_BACK)
	END FRAME

        @ 193,24 RADIOGROUP Radio_1 ;
		OPTIONS { 'Small', 'Normal', 'Large' } ;
		VALUE aOptions[OPT_SIZE][2] ;
		WIDTH 84 ;
		SPACING 24 ;
		BACKCOLOR IF(IsXPThemeActive(), NIL, CLR_BACK) ;
		HORIZONTAL

   END WINDOW

   Form_Options.Radio_1.Enabled( 1 ) := .F.
   Form_Options.Radio_1.Enabled( 3 ) := .F.

   Form_Options.Center
   Form_Options.Activate

Return

*------------------------
Procedure OnPaintOptions()
*------------------------

DRAW LINE IN WINDOW Form_Options ;
	AT 233,0 TO 233,367 ;
	PENCOLOR GRAY

DRAW LINE IN WINDOW Form_Options ;
	AT 234,0 TO 234,367 ;
	PENCOLOR WHITE

Return

*------------------------
Procedure ApplySaveOptions( cKey )
*------------------------

	aOptions[OPT_TOP][2] := IF( Form_Options.Check_1.Value, 1, 0 )
	Form_1.MenuTopmost.Checked := Form_Options.Check_1.Value
	SetWindowPos( _HMG_MainHandle, IF(Form_1.MenuTopmost.Checked, -1, -2), 0, 0, 0, 0, 3 )

	aOptions[OPT_MULTI][2] := IF( Form_Options.Check_2.Value, 1, 0 )

	aOptions[OPT_POS][2] := IF( Form_Options.Check_3.Value, 1, 0 )
	IF Form_Options.Check_3.Value
		aOptions[OPT_ROW][2] := Form_1.Row
		aOptions[OPT_COL][2] := Form_1.Col
	ENDIF

	aOptions[OPT_CLICK][2] := IF( Form_Options.Check_4.Value, 1, 0 )

	SaveOptions( cKey )

Return

*------------------------
Procedure SaveOptions( cKey )
*------------------------
Local i

	For i := 1 To Len(aOptions)
		SetRegVar( HKEY_CURRENT_USER, cKey, aOptions[i][1], Str( aOptions[i][2], 1 ) )
	Next

Return

*------------------------
Function GetSysFont()
*------------------------
return "MS Sans Serif"

*------------------------
Function Capital(cStr)
*------------------------
return Upper( SubStr(cStr, 1, 1) ) + Lower( SubStr(cStr, 2) )

*--------------------------------------------------------*
STATIC FUNCTION EXISTREGVAR(nKey, cRegKey, cSubKey, uValue)
*--------------------------------------------------------*
   LOCAL oReg, cValue, lExist

   nKey := IF(nKey == NIL, HKEY_CURRENT_USER, nKey)
   uValue := IF(uValue == NIL, "", uValue)
   oReg := TReg32():New(nKey, cRegKey, .f.)
   cValue := oReg:Get(cSubKey, uValue)
   lExist := Empty(oReg:nError) .AND. !Empty(cValue)
   oReg:Close()

RETURN lExist

*--------------------------------------------------------*
STATIC FUNCTION GETREGVAR(nKey, cRegKey, cSubKey, uValue)
*--------------------------------------------------------*
   LOCAL oReg, cValue

   nKey := IF(nKey == NIL, HKEY_CURRENT_USER, nKey)
   uValue := IF(uValue == NIL, "", uValue)
   oReg := TReg32():New(nKey, cRegKey, .f.)
   cValue := oReg:Get(cSubKey, uValue)
   oReg:Close()

RETURN cValue

*--------------------------------------------------------*
STATIC FUNCTION SETREGVAR(nKey, cRegKey, cSubKey, uValue)
*--------------------------------------------------------*
   LOCAL oReg, cValue

   nKey := IF(nKey == NIL, HKEY_CURRENT_USER, nKey)
   uValue := IF(uValue == NIL, "", uValue)
   oReg := TReg32():Create(nKey, cRegKey)
   cValue := oReg:Set(cSubKey, uValue)
   oReg:Close()

RETURN cValue

*--------------------------------------------------------*
function drawline(window,row,col,row1,col1,penrgb,penwidth)
*--------------------------------------------------------*
Local i := GetFormIndex ( Window )
Local FormHandle := _HMG_aFormHandles [i]

	if formhandle > 0

		if valtype(penrgb) == "U"
			penrgb = {0,0,0}
		endif
	
		if valtype(penwidth) == "U"
			penwidth = 1
		endif

		linedraw( formhandle,row,col,row1,col1,penrgb,penwidth )

		aadd ( _HMG_aFormGraphTasks [i], { || linedraw( formhandle,row,col,row1,col1,penrgb,penwidth) } )

	endif

return nil

*--------------------------------------------------------*
function drawrect(window,row,col,row1,col1,penrgb,penwidth,fillrgb)
*--------------------------------------------------------*
Local i := GetFormIndex ( Window )
Local FormHandle := _HMG_aFormHandles [i] , fill

if formhandle > 0

   if valtype(penrgb) == "U"
      penrgb = {0,0,0}
   endif

   if valtype(penwidth) == "U"
      penwidth = 1
   endif

   if valtype(fillrgb) == "U"
      fillrgb := {255,255,255}
      fill := .f.
   else
      fill := .t.   
   endif

   rectdraw( FormHandle,row,col,row1,col1,penrgb,penwidth,fillrgb,fill )

   aadd ( _HMG_aFormGraphTasks [i] , { || rectdraw( FormHandle,row,col,row1,col1,penrgb,penwidth,fillrgb,fill ) } )

endif
return nil


#pragma BEGINDUMP

#include <windows.h>
#include "hbapi.h"
#include "hbapiitm.h"

#ifdef __XHARBOUR__
#define HB_PARNI( n, x ) hb_parni( n, x )
#else
#define HB_PARNI( n, x ) hb_parvni( n, x )
#endif

HB_FUNC ( LINEDRAW )
{
   HWND hWnd1;
   HDC hdc1;
   HGDIOBJ hgdiobj1;
   HPEN hpen;
   hWnd1 = (HWND) hb_parnl(1);
   hdc1 = GetDC( (HWND) hWnd1 );
   hpen = CreatePen( (int) PS_SOLID, (int) hb_parni(7), (COLORREF) RGB( (int) HB_PARNI(6,1), (int) HB_PARNI(6,2), (int) HB_PARNI(6,3) ) );
   hgdiobj1 = SelectObject( (HDC) hdc1, hpen );
   MoveToEx( (HDC) hdc1, (int) hb_parni(3), (int) hb_parni(2), NULL );
   LineTo( (HDC) hdc1, (int) hb_parni(5), (int) hb_parni(4) );
   SelectObject( (HDC) hdc1, (HGDIOBJ) hgdiobj1 );
   DeleteObject( hpen );
   ReleaseDC( hWnd1, hdc1 );
}

HB_FUNC ( RECTDRAW )
{
   HWND hWnd1;
   HDC hdc1;
   HGDIOBJ hgdiobj1,hgdiobj2;
   HPEN hpen;
   HBRUSH hbrush;
   hWnd1 = (HWND) hb_parnl (1);
   hdc1 = GetDC((HWND) hWnd1);
   hpen = CreatePen( (int) PS_SOLID, (int) hb_parni(7), (COLORREF) RGB( (int) HB_PARNI(6,1), (int) HB_PARNI(6,2), (int) HB_PARNI(6,3) ) );

   hgdiobj1 = SelectObject((HDC) hdc1, hpen);
   if (hb_parl(9))
   {
      hbrush = CreateSolidBrush((COLORREF) RGB((int) HB_PARNI(8,1),(int) HB_PARNI(8,2),(int) HB_PARNI(8,3)));    
      hgdiobj2 = SelectObject((HDC) hdc1, hbrush);
   }   
   else
   {
      hbrush = GetSysColorBrush((int) COLOR_WINDOW);    
      hgdiobj2 = SelectObject((HDC) hdc1, hbrush);
   }      
   Rectangle((HDC) hdc1,(int) hb_parni(3),(int) hb_parni(2),(int) hb_parni(5),(int) hb_parni(4));
   SelectObject((HDC) hdc1,(HGDIOBJ) hgdiobj1);
   SelectObject((HDC) hdc1,(HGDIOBJ) hgdiobj2);
   DeleteObject( hpen );
   DeleteObject( hbrush );
   ReleaseDC( hWnd1, hdc1 );
}

#pragma ENDDUMP