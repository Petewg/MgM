*
* MINIGUI - HARBOUR - Win32
* 
* Author: Grigory Filatov <gfilatov@inbox.ru>
*

ANNOUNCE RDDSYS

#include "minigui.ch"

#define PROGRAM "Shutdown Utility"
#define VERSION " v.2.2.2"
#define COPYRIGHT " 2002-2006 Grigory Filatov"

#define IDI_MAIN 1001

DECLARE WINDOW FORM_0
DECLARE WINDOW FORM_1
DECLARE WINDOW FORM_2

STATIC lFormExist := .t.

MEMVAR aLabel, aLang, nLang, cLanguage, ;
	nTimeHour, nTimeMinute, nTimeSecond, ;
	nTimeLeftHour, nTimeLeftMinute, nTimeLeftSecond, ;
	lPowerOff, lForceMode, lStayOnTop, ;
	nLastState, cPath, cIni, cTimeExit

*--------------------------------------------------------*
Procedure Main()
*--------------------------------------------------------*
   LOCAL cur_path := cFilePath( GetExeFileName() ) + "\"
   LOCAL cIniFile := cur_path + Lower( cFileNoExt( GetExeFileName() ) ) + ".ini"

   PUBLIC aLabel[23], aLang := {}, nLang := 1, cLanguage := "Russian", ;
		nTimeHour := 12, nTimeMinute := 0, nTimeSecond := 0, ;
		nTimeLeftHour := 1, nTimeLeftMinute := 0, nTimeLeftSecond := 0, ;
		lPowerOff := .t., lForceMode := .t., lStayOnTop := .f., ;
		nLastState := 0, cPath := cur_path, cIni := cIniFile

	Aadd(aLang, cLanguage)
	Aeval( Directory("*.lng"), {|el| Aadd( aLang, Proper( cFileNoExt(el[1]) ) )} )
	aLang := Asort( aLang )
	cLanguage := IF( Ascan(aLang, "English") > 0, "English", cLanguage )

	GetParam(cIniFile)
	GetLanguage(cur_path + cLanguage + ".lng")

	DEFINE WINDOW Form_0 ;
		AT 0,0 ;
		WIDTH 0 HEIGHT 0 ;
		TITLE PROGRAM ;
		ICON IDI_MAIN ;
		MAIN NOSHOW ;
		ON INIT Form_1(.f.) ;
		NOTIFYICON "SHUT" ;
		NOTIFYTOOLTIP PROGRAM ;
		ON NOTIFYCLICK IF( lFormExist, Form_1.Release, Form_1(.t.) )

		RightMenu()

	END WINDOW

	ACTIVATE WINDOW Form_0

Return

*--------------------------------------------------------*
Procedure RightMenu()
*--------------------------------------------------------*
	DEFINE NOTIFY MENU OF Form_0
		ITEM aLabel[16]	ACTION ShellAbout( "", PROGRAM + VERSION + CRLF + ;
			"Copyright " + Chr(169) + COPYRIGHT, LoadIconByName("AMAIN", 32, 32) )
		SEPARATOR
		ITEM aLabel[15]	ACTION Form_0.Release
	END MENU

Return

*--------------------------------------------------------*
Procedure Form_1( lSwitch )
*--------------------------------------------------------*
	Local aFlag := { {"Russian", "RU"}, {"English", "GB"}, {"Deutsch", "DE"}, ;
			{"French", "FR"}, {"Italian", "IT"}, {"Spanish", "ES"}, {"Bulgarian", "BG"} }
	Local nFlag := Ascan( aFlag, {|e| e[1] == cLanguage} )

	IF lStayOnTop
		DEFINE WINDOW Form_1 AT 0,0 WIDTH 512 HEIGHT 336 + IF(IsXPThemeActive(), 10, 0) ;
			TITLE PROGRAM + VERSION ;
			ICON IDI_MAIN ;
			CHILD ;
			TOPMOST ;
			NOMAXIMIZE NOSIZE ;
			ON INIT lFormExist := .T. ;
			ON RELEASE ( lFormExist := .F., SaveParam(cIni, .T.) ) ;
			ON PAINT ( Form_1.Button_1.SetFocus, IF( Empty( nFlag ), , ;
				DrawIcon( GetFormHandle("Form_1"), 342, 260, ;
				LoadTrayIcon(GetInstance(), aFlag[nFlag][2]) ) ) ) ;
			ON INTERACTIVECLOSE IF( lSwitch, Form_1.Button_2.OnClick, ) ;
			FONT "MS Sans Serif" SIZE 9
	ELSE
		DEFINE WINDOW Form_1 AT 0,0 WIDTH 512 HEIGHT 336 + IF(IsXPThemeActive(), 10, 0) ;
			TITLE PROGRAM + VERSION ;
			ICON IDI_MAIN ;
			CHILD ;
			NOMAXIMIZE NOSIZE ;
			ON INIT ( lFormExist := .T., IF( lSwitch, SwitchToThisWindow( GetFormHandle( "Form_1" ) ), ) ) ;
			ON RELEASE ( lFormExist := .F., SaveParam(cIni, .T.) ) ;
			ON PAINT ( Form_1.Button_1.SetFocus, IF( Empty( nFlag ), , ;
				DrawIcon( GetFormHandle("Form_1"), 342, 260, ;
				LoadTrayIcon(GetInstance(), aFlag[nFlag][2]) ) ) ) ;
			ON INTERACTIVECLOSE IF( lSwitch, Form_1.Button_2.OnClick, ) ;
			FONT "MS Sans Serif" SIZE 9
	ENDIF
		DEFINE STATUSBAR
			STATUSITEM "Copyright " + Chr(169) + COPYRIGHT
			CLOCK WIDTH 60
		END STATUSBAR

		ON KEY ALT+A ACTION MsgAbout()
		ON KEY ALT+X ACTION ReleaseAllWindows()

		@ 1,7 FRAME Frame_1 CAPTION "" WIDTH 258 HEIGHT 254

		@ 20,20 RADIOGROUP RadioGroup_1 OPTIONS {aLabel[1], aLabel[2]} ;
			VALUE IF(Empty(nLastState), 1, 2) WIDTH 230 SPACING 85 ;
			ON CHANGE ToggleGroup( Form_1.RadioGroup_1.Value  == 1)

		@ 55,20 TEXTBOX Text_1 VALUE StrZero(nTimeHour, 2) HEIGHT 40 WIDTH 40 ;
			FONT "Arial" SIZE 22 MAXLENGTH 2 ;
			ON ENTER Form_1.Text_2.SetFocus  ;
			ON LOSTFOCUS IF(IsValid("Hour",  Form_1.Text_1.Value  ), ;
			nTimeHour := VAL( Form_1.Text_1.Value  ), Form_1.Text_1.SetFocus  )
		@ 55,80 TEXTBOX Text_2 VALUE StrZero(nTimeMinute, 2) HEIGHT 40 WIDTH 40 ;
			FONT "Arial" SIZE 22 MAXLENGTH 2 ;
			ON ENTER Form_1.Text_3.SetFocus  ;
			ON LOSTFOCUS IF ( IsValid ("Minute", Form_1.Text_2.Value ), ;
			nTimeMinute := VAL( Form_1.Text_2.Value  ), Form_1.Text_2.SetFocus )

		@ 55,138 TEXTBOX Text_3 VALUE StrZero(nTimeSecond, 2) HEIGHT 40 WIDTH 40 ;
			FONT "Arial" SIZE 22 MAXLENGTH 2 ;
			ON ENTER Form_1.Button_1.SetFocus  ;
			ON LOSTFOCUS IF(IsValid("Second", Form_1.Text_3.Value ), ;
			nTimeSecond := VAL( Form_1.Text_3.Value  ), Form_1.Text_3.SetFocus )

		@ 56,65 LABEL Label_1 VALUE ":" WIDTH 6 HEIGHT 28 FONT "Arial" SIZE 22 BOLD
		@ 56,125 LABEL Label_2 VALUE ":" WIDTH 6 HEIGHT 28 FONT "Arial" SIZE 22 BOLD
		@ 58,190 LABEL Label_3 VALUE aLabel[5] WIDTH 50 HEIGHT 28 FONT "Arial" SIZE 22 BOLD

		@ 190,20 CHECKBOX CheckBox_1 CAPTION aLabel[3] ;
			WIDTH 230 HEIGHT 28 ON CHANGE SetExitWindow( Form_1.CheckBox_1.Value )

		@ 142,20 TEXTBOX Text_5 VALUE StrZero(nTimeLeftHour, 2) HEIGHT 40 WIDTH 40 ;
			FONT "Arial" SIZE 22 MAXLENGTH 2 ;
			ON ENTER Form_1.Text_6.SetFocus  ;
			ON LOSTFOCUS IF(IsValid("Hour", Form_1.Text_5.Value ), ;
			nTimeLeftHour := VAL( Form_1.Text_5.Value ), Form_1.Text_5.SetFocus )
		@ 142,94 TEXTBOX Text_6 VALUE StrZero(nTimeLeftMinute, 2) HEIGHT 40 WIDTH 40 ;
			FONT "Arial" SIZE 22 MAXLENGTH 2 ;
			ON ENTER Form_1.Text_7.SetFocus ;
			ON LOSTFOCUS IF(IsValid("Minute", Form_1.Text_6.Value ), ;
			nTimeLeftMinute := VAL( Form_1.Text_6.Value  ), Form_1.Text_6.SetFocus )
		@ 142,168 TEXTBOX Text_7 VALUE StrZero(nTimeLeftSecond, 2) HEIGHT 40 WIDTH 40 ;
			FONT "Arial" SIZE 22 MAXLENGTH 2 ;
			ON ENTER Form_1.Button_1.SetFocus  ;
			ON LOSTFOCUS IF(IsValid("Second", Form_1.Text_7.Value ), ;
			nTimeLeftSecond := VAL( Form_1.Text_7.Value ), Form_1.Text_7.SetFocus )

		@ 145,67 LABEL Label_4 VALUE "h" WIDTH 24 HEIGHT 28 FONT "Arial" SIZE 22 BOLD
		@ 145,138 LABEL Label_5 VALUE "m" WIDTH 24 HEIGHT 28 FONT "Arial" SIZE 22 BOLD
		@ 145,212 LABEL Label_6 VALUE "s" WIDTH 24 HEIGHT 28 FONT "Arial" SIZE 22 BOLD

		@ 222,20 LABEL Label_7 VALUE aLabel[4] WIDTH 70 HEIGHT 18
		@ 220,96 COMBOBOX Combo_1 WIDTH 150 HEIGHT 150

		@ 262,7 BUTTON Button_1 CAPTION aLabel[14] ;
			ACTION SetTimer() ;
			WIDTH 80 HEIGHT 24 ;
			FONT "MS Sans Serif" SIZE 10
		@ 262,96 BUTTON Button_2 CAPTION aLabel[15] ;
			ACTION ReleaseAllWindows() ;
			WIDTH 80 HEIGHT 24
		@ 262,185 BUTTON Button_3 CAPTION aLabel[16] ;
			ACTION MsgAbout() ;
			WIDTH 80 HEIGHT 24

		@ 1,273 FRAME Frame_2 CAPTION "" WIDTH 225 HEIGHT 254

		@ 25,305 LABEL Label_9 VALUE aLabel[6] WIDTH 190 HEIGHT 18
		@ 48,290 RADIOGROUP RadioGroup_3 OPTIONS {aLabel[7], aLabel[8], aLabel[9]} ;
			VALUE 1 WIDTH 200 SPACING 30 ;
			ON CHANGE IF( Form_1.RadioGroup_3.Value # 1, ;
			( ( Form_1.CheckBox_2.Value := .F.), ;
			( Form_1.CheckBox_2.Enabled := .F.) ), ;
			( ( Form_1.CheckBox_2.Value := lPowerOff), ;
			( Form_1.CheckBox_2.Enabled := .T.) ) )

		@ 150,290 CHECKBOX CheckBox_2 CAPTION aLabel[10] VALUE lPowerOff ;
			WIDTH 205 HEIGHT 24 ON CHANGE lPowerOff := !lPowerOff
		@ 185,290 CHECKBOX CheckBox_3 CAPTION aLabel[11] VALUE lForceMode ;
			WIDTH 205 HEIGHT 24 ON CHANGE lForceMode := !lForceMode
		@ 220,290 CHECKBOX CheckBox_4 CAPTION aLabel[12] VALUE lStayOnTop ;
			WIDTH 205 HEIGHT 24 ON CHANGE lStayOnTop := !lStayOnTop

		@ 266,286 LABEL Label_8 VALUE aLabel[13] WIDTH 50 HEIGHT 18 RIGHTALIGN

		@ 262,380 COMBOBOX Combo_2 ITEMS aLang VALUE nLang ;
			WIDTH 100 HEIGHT 150 ;
			ON CHANGE ( nLang := Form_1.Combo_2.Value , ;
				cLanguage := Form_1.Combo_2.Item( nLang ), ;
				SetLanguage(aFlag) )

	END WINDOW

	ToggleGroup(Empty(nLastState))

	Form_1.Label_7.Enabled := .F.
	Form_1.Combo_1.Enabled := .F.

	CENTER WINDOW Form_1

	ACTIVATE WINDOW Form_1

Return

*--------------------------------------------------------*
Procedure SetLanguage( aFlag )
*--------------------------------------------------------*
	Local nFlag := Ascan( aFlag, {|e| e[1] == cLanguage} )

	GetLanguage(cPath + cLanguage + ".lng")
	RightMenu()

	Form_1.RadioGroup_1.Caption(1) := aLabel[1]
	Form_1.RadioGroup_1.Caption(2) := aLabel[2]
	Form_1.CheckBox_1.Caption := aLabel[3]
	Form_1.Label_7.Value := aLabel[4]
	Form_1.Label_3.Value := aLabel[5]
	Form_1.Label_9.Value := aLabel[6]
	Form_1.RadioGroup_3.Caption(1) := aLabel[7]
	Form_1.RadioGroup_3.Caption(2) := aLabel[8]
	Form_1.RadioGroup_3.Caption(3) := aLabel[9]
	Form_1.CheckBox_2.Caption := aLabel[10]
	Form_1.CheckBox_3.Caption := aLabel[11]
	Form_1.CheckBox_4.Caption := aLabel[12]
	Form_1.Label_8.Value := aLabel[13]
	Form_1.Button_1.Caption := aLabel[14]
	Form_1.Button_2.Caption := aLabel[15]
	Form_1.Button_3.Caption := aLabel[16]
	IF !Empty( nFlag )
		DrawIcon( GetFormHandle("Form_1"), 342, 260, LoadTrayIcon(GetInstance(), aFlag[nFlag][2]) )
		_HMG_aFormPaintProcedure[ Ascan ( _HMG_aFormhandles , GetFormHandle("Form_1") ) ] := ;
				{|| DrawIcon( GetFormHandle("Form_1"), 342, 260, ;
				LoadTrayIcon(GetInstance(), aFlag[nFlag][2]) )}
	ENDIF

Return

*--------------------------------------------------------*
Procedure SetTimer()
*--------------------------------------------------------*
	Local cTime := Time(), lExit := .t., ;
		nItem, cWindow := "", cLabel, ;
		nMode := Form_1.RadioGroup_3.Value
	Local nTime1 := IF(Empty(nLastState), nTimeHour, nTimeLeftHour)
	Local nTime2 := IF(Empty(nLastState), nTimeMinute, nTimeLeftMinute)
	Local nTime3 := IF(Empty(nLastState), nTimeSecond, nTimeLeftSecond)

	PUBLIC cTimeExit := StrZero(nTime1,2)+':'+StrZero(nTime2,2)+':'+StrZero(nTime3,2)

	IF !TimeIsValid(cTimeExit)
		MsgStop("Wrong time!", aLabel[22])
		Return
	ENDIF

	IF Form_1.CheckBox_1.Value 
		IF !Empty( nItem := Form_1.Combo_1.Value ) 
			cWindow := Form_1.Combo_1.Item( nItem ) 
		ENDIF
	ENDIF

	Form_1.Hide

	IF Empty(nLastState)
		cTimeExit := TimeDiff(cTime, cTimeExit)
	ENDIF

	cLabel := IF(nMode == 1, aLabel[19], IF(nMode == 2, aLabel[20], aLabel[21]))

	Set InteractiveClose Off

	IF lStayOnTop
		DEFINE WINDOW Form_2 AT 0,0 WIDTH 250 HEIGHT IF(Empty(cWindow), 162, 206) ;
			TITLE aLabel[17] ;
			ICON "AMAIN" ;
			TOPMOST ;
			NOMINIMIZE NOMAXIMIZE NOSIZE ;
			ON RELEASE Form_2.Timer_1.Enabled := .f. ;
			ON PAINT Form_2.Button_1.SetFocus
	ELSE
		DEFINE WINDOW Form_2 AT 0,0 WIDTH 250 HEIGHT IF(Empty(cWindow), 162, 206) ;
			TITLE aLabel[17] ;
			ICON "AMAIN" ;
			NOMINIMIZE NOMAXIMIZE NOSIZE ;
			ON RELEASE Form_2.Timer_1.Enabled := .f. ;
			ON PAINT Form_2.Button_1.SetFocus
	ENDIF

		@ 10, 5 LABEL Label_1		;
			VALUE cLabel	 	;
			WIDTH  240        	;
			HEIGHT 22         	;
			FONT "Arial" SIZE 9 BOLD

		@ 35, 25 LABEL TimeExit		;
			VALUE cTimeExit		;
			WIDTH  200        	;
			HEIGHT 52         	;
			FONT "Arial" SIZE 36 BOLD

	IF !Empty(cWindow)
		@ 100, 5 LABEL Label_2		;
			VALUE aLabel[18]	 	;
			WIDTH  240        	;
			HEIGHT 22         	;
			FONT "Arial" SIZE 9 BOLD

		@ 115, 5 LABEL Label_3		;
			VALUE AllTrim(cWindow) 	;
			WIDTH  240        	;
			HEIGHT 22         	;
			FONT "Arial" SIZE 9	;
			FONTCOLOR RED BOLD
	ENDIF

		@ IF(Empty(cWindow), 100, 145), 75 BUTTON Button_1 CAPTION aLabel[23] ;
			ACTION ( lExit := .f., Form_2.release ) ;
			WIDTH 100 HEIGHT 24 FONT "MS Sans Serif" SIZE 9

		DEFINE TIMER Timer_1 ;
			INTERVAL 1000 ;
			ACTION SetTimeExit( cWindow )

	END WINDOW

	CENTER WINDOW Form_2

	ACTIVATE WINDOW Form_2

	IF lExit
		WinExit(nMode)
	ELSE
		RELEASE cTimeExit
		Set InteractiveClose On
		Form_1.Show
	ENDIF

Return

#define GW_HWNDFIRST	0
#define GW_HWNDNEXT	2
#define GW_OWNER		4
*--------------------------------------------------------*
Procedure SetTimeExit( cTitle )
*--------------------------------------------------------*
	LOCAL aWnd := {}, hWnd, cAppTitle

	cTimeExit := TimeAsString( TimeAsSeconds( cTimeExit ) - 1 )
	Form_2.TimeExit.Value := cTimeExit

	IF cTimeExit == "00:00:00"
		Form_2.Release
	ENDIF
	IF !Empty(cTitle)
		hWnd := GetWindow( _HMG_MainHandle, GW_HWNDFIRST )	// Get the first window
		WHILE hWnd != 0						// Loop through all the windows
			cAppTitle := GetWindowText( hWnd )
			IF GetWindow( hWnd, GW_OWNER ) = 0 .AND.;	// If it is an owner window
				IsWindowVisible( hWnd ) .AND.;		// If it is a visible window
				hWnd != _HMG_MainHandle .AND.;		// If it is not this app
				!EMPTY( cAppTitle ) .AND.;		// If the window has a title
				!( "DOS Session" $ cAppTitle ) .AND.;	// If it is not DOS session
				!( cAppTitle == "Program Manager" )	// If it is not the Program Manager

				Aadd( aWnd, ALLTRIM(cAppTitle) )
			ENDIF

			hWnd := GetWindow( hWnd, GW_HWNDNEXT )		// Get the next window
		ENDDO
		IF EMPTY( Ascan( aWnd, ALLTRIM(cTitle) ) )
			Form_2.Release
		ENDIF
	ENDIF

Return

#define EWX_LOGOFF   0
#define EWX_SHUTDOWN 1
#define EWX_REBOOT   2
#define EWX_FORCE    4
#define EWX_POWEROFF 8
*--------------------------------------------------------*
Procedure WinExit( nFlag )
*--------------------------------------------------------*

   if IsWinNT()
      EnablePermissions()
   endif

   do case
      case nFlag = 1
		nFlag := EWX_SHUTDOWN
		if lPowerOff
			nFlag += EWX_POWEROFF
		endif
      case nFlag = 2
		nFlag := EWX_REBOOT
      case nFlag = 3
		nFlag := EWX_LOGOFF
   endcase

   if lForceMode
	nFlag += EWX_FORCE
   endif

   if !ExitWindowsEx(nFlag, 0)
	ShowError()
   else
	ReleaseAllWindows()
   endif

Return

*--------------------------------------------------------*
FUNCTION TimeDiff( cStartTime, cEndTime )
*--------------------------------------------------------*
RETURN TimeAsString(IF(cEndTime < cStartTime, 86400, 0) + ;
	TimeAsSeconds(cEndTime) - TimeAsSeconds(cStartTime))

*--------------------------------------------------------*
FUNCTION TimeAsSeconds( cTime )
*--------------------------------------------------------*
RETURN VAL(cTime) * 3600 + VAL(SUBSTR(cTime, 4)) * 60 + ;
	VAL(SUBSTR(cTime, 7))

*--------------------------------------------------------*
FUNCTION TimeAsString( nSeconds )
*--------------------------------------------------------*
RETURN StrZero(INT(Mod(nSeconds / 3600, 24)), 2, 0) + ":" + ;
	StrZero(INT(Mod(nSeconds / 60, 60)), 2, 0) + ":" + ;
	StrZero(INT(Mod(nSeconds, 60)), 2, 0)

*--------------------------------------------------------*
FUNCTION TimeIsValid( cTime )
*--------------------------------------------------------*
RETURN VAL(cTime) < 24 .AND. VAL(SUBSTR(cTime, 4)) < 60 .AND. ;
	VAL(SUBSTR(cTime, 7)) < 60

*--------------------------------------------------------*
Procedure ToggleGroup( lFirst )
*--------------------------------------------------------*
	IF lFirst
		nLastState := 0
		Form_1.Text_1.Enabled := .T.
		Form_1.Text_2.Enabled := .T.
		Form_1.Text_3.Enabled := .T.
		Form_1.Text_5.Enabled := .F.
		Form_1.Text_6.Enabled := .F.
		Form_1.Text_7.Enabled := .F.
	ELSE
		nLastState := 1
		Form_1.Text_1.Enabled := .F.
		Form_1.Text_2.Enabled := .F.
		Form_1.Text_3.Enabled := .F.
		Form_1.Text_5.Enabled := .T.
		Form_1.Text_6.Enabled := .T.
		Form_1.Text_7.Enabled := .T.
	ENDIF

Return

*--------------------------------------------------------*
Function IsValid( cControl, cValue )
*--------------------------------------------------------*
	LOCAL lError := .f., nVal := VAL( cValue )

	IF cControl == "Hour"
		IF nVal < 0 .OR. nVal > 23
			lError := .t.
		ENDIF
	ELSE
		IF nVal < 0 .OR. nVal > 59
			lError := .t.
		ENDIF
	ENDIF

	IF lError
		MsgStop("Invalid time!", aLabel[22])
	ENDIF

Return .NOT. lError

*--------------------------------------------------------*
Procedure SetExitWindow( lActived )
*--------------------------------------------------------*
	LOCAL hWnd, cTitle, hOwnWnd := _HMG_MainHandle

	IF lActived
		Form_1.Label_7.Enabled := .T.
		Form_1.Combo_1.Enabled := .T.
		
		hWnd := GetWindow( hOwnWnd, GW_HWNDFIRST )      // Get the first window
		WHILE hWnd != 0                                 // Loop through all the windows
			cTitle := GetWindowText( hWnd )
			IF GetWindow( hWnd, GW_OWNER ) = 0 .AND.; // If it is an owner window
				IsWindowVisible( hWnd ) .AND.;      // If it is a visible window
				hWnd != hOwnWnd .AND.;              // If it is not this app
				!EMPTY( cTitle ) .AND.;             // If the window has a title
				!( "DOS Session" $ cTitle ) .AND.;  // If it is not DOS session
				!( cTitle == "Program Manager" )    // If it is not the Program Manager

				Form_1.Combo_1.AddItem( cTitle )
			ENDIF

			hWnd := GetWindow( hWnd, GW_HWNDNEXT )    // Get the next window
		ENDDO

	ELSE
		Form_1.Label_7.Enabled := .F.
		Form_1.Combo_1.Enabled := .F.
		DELETE ITEM ALL FROM Combo_1 OF Form_1
	ENDIF

Return

*--------------------------------------------------------*
Procedure GetParam( cIniFile )
*--------------------------------------------------------*

	cLanguage := GetIni( "Options", "Language", cLanguage, cIniFile )

	nTimeHour := Val( GetIni( "Parameters", "TimeHour", StrZero(nTimeHour, 2), cIniFile ) )
	nTimeMinute := Val( GetIni( "Parameters", "TimeMinute", StrZero(nTimeMinute, 2), cIniFile ) )
	nTimeSecond := Val( GetIni( "Parameters", "TimeSecond", StrZero(nTimeSecond, 2), cIniFile ) )

	nTimeLeftHour := Val( GetIni( "Parameters", "TimeLeftHour", StrZero(nTimeLeftHour, 2), cIniFile ) )
	nTimeLeftMinute := Val( GetIni( "Parameters", "TimeLeftMinute", StrZero(nTimeLeftMinute, 2), cIniFile ) )
	nTimeLeftSecond := Val( GetIni( "Parameters", "TimeLeftSecond", StrZero(nTimeLeftSecond, 2), cIniFile ) )

	lPowerOff := GetIni( "Parameters", "PowerOff", IF(lPowerOff, "1", "0"), cIniFile ) $ "1"
	lForceMode := GetIni( "Parameters", "ForceMode", IF(lForceMode, "1", "0"), cIniFile ) $ "1"
	lStayOnTop := GetIni( "Parameters", "StayOnTop", IF(lStayOnTop, "1", "0"), cIniFile ) $ "1"

	nLastState := Val( GetIni( "Parameters", "LastState", Str(nLastState, 1), cIniFile ) )

	SaveParam(cIniFile, .F.)

Return

*--------------------------------------------------------*
Procedure SaveParam( cIniFile, lForce )
*--------------------------------------------------------*
	IF !FILE(cIniFile) .OR. lForce
		WriteIni( "Options", "Language", cLanguage, cIniFile )

		WriteIni( "Parameters", "TimeHour", StrZero(nTimeHour, 2), cIniFile )
		WriteIni( "Parameters", "TimeMinute", StrZero(nTimeMinute, 2), cIniFile )
		WriteIni( "Parameters", "TimeSecond", StrZero(nTimeSecond, 2), cIniFile )

		WriteIni( "Parameters", "TimeLeftHour", StrZero(nTimeLeftHour, 2), cIniFile )
		WriteIni( "Parameters", "TimeLeftMinute", StrZero(nTimeLeftMinute, 2), cIniFile )
		WriteIni( "Parameters", "TimeLeftSecond", StrZero(nTimeLeftSecond, 2), cIniFile )

		WriteIni( "Parameters", "PowerOff", IF(lPowerOff, "1", "0"), cIniFile )
		WriteIni( "Parameters", "ForceMode", IF(lForceMode, "1", "0"), cIniFile )
		WriteIni( "Parameters", "StayOnTop", IF(lStayOnTop, "1", "0"), cIniFile )

		WriteIni( "Parameters", "LastState", Str(nLastState, 1), cIniFile )
	ENDIF

Return

*--------------------------------------------------------*
Procedure GetLanguage( cIniFile )
*--------------------------------------------------------*

   nLang := Ascan(aLang, cLanguage)
   Afill(aLabel, "")

   IF FILE(cIniFile)
	aLabel[1]  := GetIni( "Data", "RadioButtonTime", "", cIniFile )
	aLabel[2]  := GetIni( "Data", "RadioButtonTimeLeft", "", cIniFile )
	aLabel[3]  := GetIni( "Data", "CheckBoxWindow", "", cIniFile )
	aLabel[4]  := GetIni( "Data", "LabelWindowTitle", "", cIniFile )
	aLabel[5]  := GetIni( "Data", "LabelClock", "", cIniFile )
	aLabel[6]  := GetIni( "Data", "LabelProcess", "", cIniFile )
	aLabel[7]  := GetIni( "Data", "RadioButtonShutdown", "", cIniFile )
	aLabel[8]  := GetIni( "Data", "RadioButtonReboot", "", cIniFile )
	aLabel[9]  := GetIni( "Data", "RadioButtonLogOff", "", cIniFile )
	aLabel[10] := GetIni( "Data", "CheckBoxPowerOff", "", cIniFile )
	aLabel[11] := GetIni( "Data", "CheckBoxForceMode", "", cIniFile )
	aLabel[12] := GetIni( "Data", "CheckBoxStayOnTop", "", cIniFile )
	aLabel[13] := GetIni( "Data", "LabelLanguage", "", cIniFile )
	aLabel[14] := GetIni( "Data", "ButtonStart", "", cIniFile )
	aLabel[15] := GetIni( "Data", "ButtonExit", "", cIniFile )
	aLabel[16] := GetIni( "Data", "ButtonAbout", "", cIniFile )

	aLabel[17] := GetIni( "Data", "WaitTitle", "", cIniFile )
	aLabel[18] := GetIni( "Data", "LabelWindowInfo", "", cIniFile )
	aLabel[19] := GetIni( "Data", "LabelTopShutdown", "", cIniFile )
	aLabel[20] := GetIni( "Data", "LabelTopReboot", "", cIniFile )
	aLabel[21] := GetIni( "Data", "LabelTopLogOff", "", cIniFile )

	aLabel[22] := GetIni( "Data", "TitleWarning", "", cIniFile )
	aLabel[23] := GetIni( "Data", "ButtonCancel", "", cIniFile )
   ELSE
	aLabel[1]  := "Выключить комп-р в указанное время"
	aLabel[2]  := "Выключить после указанной задержки"
	aLabel[3]  := "или выключить, если закрыть это окно"
	aLabel[4]  := "Заголовок:"
	aLabel[5]  := ""
	aLabel[6]  := "Что я должен сделать ?"
	aLabel[7]  := "Выключить компьютер"
	aLabel[8]  := "Перезагрузить компьютер"
	aLabel[9]  := "Войти под другим именем"
	aLabel[10] := "Выключить питание компьютера"
	aLabel[11] := "Быстрое завершение программ"
	aLabel[12] := "Окно поверх других окон"
	aLabel[13] := "Язык:"
	aLabel[14] := "Старт!!!"
	aLabel[15] := "Выход"
	aLabel[16] := "О себе..."

	aLabel[17] := "Shutdown Utility активирована!"
	aLabel[18] := "или если закрыть следующее окно:"
	aLabel[19] := "Осталось до выключения компьютера:"
	aLabel[20] := "Осталось до перезагрузки компьютера:"
	aLabel[21] := "Осталось до входа под другим именем:"

	aLabel[22] := "Внимание"
	aLabel[23] := "Прервать"
   ENDIF

Return

#define MsgInfo( c, t ) MsgInfo( c, t, IDI_MAIN, .f. )
*--------------------------------------------------------*
Function MsgAbout()
*--------------------------------------------------------*
return MsgInfo( PROGRAM + VERSION + " - FREEWARE" + CRLF + ;
	"Copyright " + Chr(169) + COPYRIGHT + CRLF + CRLF + ;
	padc("eMail: gfilatov@inbox.ru", 40) + CRLF + CRLF + ;
	padc("This program is Freeware!", 40) + CRLF + ;
	padc("Copying is allowed!", 44), "About" )

*--------------------------------------------------------*
Function Proper( cStr )	// Capitalize First letter
*--------------------------------------------------------*
return SubStr(cStr, 1, 1) + Lower( SubStr(cStr, 2) )

*--------------------------------------------------------*
Function GetIni( cSection, cEntry, cDefault, cFile )
*--------------------------------------------------------*
RETURN GetPrivateProfileString(cSection, cEntry, cDefault, cFile )

*--------------------------------------------------------*
Function WriteIni( cSection, cEntry, cValue, cFile )
*--------------------------------------------------------*
RETURN( WritePrivateProfileString( cSection, cEntry, cValue, cFile ) )

*--------------------------------------------------------*
DECLARE DLL_TYPE_BOOL SwitchToThisWindow( DLL_TYPE_LONG hWnd, DLL_TYPE_BOOL lRestore ) ;
	IN USER32.DLL


#pragma BEGINDUMP

#include <mgdefs.h>

HB_FUNC( DRAWICON )
{
    HWND hwnd;
    HDC hdc;

    hwnd  = (HWND) hb_parnl( 1 ) ;
    hdc   = GetDC( hwnd ) ;
 
    hb_retl( DrawIcon( (HDC) hdc , hb_parni( 2 ) , hb_parni( 3 ) , (HICON) hb_parnl( 4 ) ) ) ;
    ReleaseDC( hwnd, hdc ) ;
}

HB_FUNC( SHOWERROR )
{
   LPVOID lpMsgBuf;
   DWORD dwError  = GetLastError();

   FormatMessage( 
      FORMAT_MESSAGE_ALLOCATE_BUFFER | FORMAT_MESSAGE_FROM_SYSTEM,
      NULL,
      dwError,
      MAKELANGID(LANG_NEUTRAL, SUBLANG_DEFAULT), // Default language
      (LPTSTR) &lpMsgBuf,
      0,
      NULL 
   );
   
   MessageBox(NULL, (LPCSTR)lpMsgBuf, "Shutdown", MB_OK | MB_ICONEXCLAMATION);
   // Free the buffer.
   LocalFree( lpMsgBuf );
}

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
