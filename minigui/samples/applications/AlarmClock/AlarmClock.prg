/*
 * MINIGUI - Harbour Win32 GUI library Demo
 *
 * Copyright 2002-05 Roberto Lopez <harbourminigui@gmail.com>
 * http://harbourminigui.googlepages.com/
 * 
 * Copyright 2003-06 Grigory Filatov <gfilatov@inbox.ru>
*/

ANNOUNCE RDDSYS

#include "minigui.ch"

#define PROGRAM 'Alarm Clock'
#define VERSION ' version 1.3'
#define COPYRIGHT ' Grigory Filatov, 2003-06'

#define NTRIM( n ) LTrim( Str( n ) )
#define PINKLIGHT 16761024
#define IDI_WATCH 1001

Static lClock := .T., lStop := .F., lQuarter := .T., hWnd := 0, 	;
	aDay := {}, aDaily := {}, aMonthly := {}, aYearly := {}, 	;
	cHourWave := "Hour.wav", cQuarterWave := "Quarter.wav", 	;
	cAlarmWave := "Alarm.wav", cCfgFile := "AlarmClock.ini"

DECLARE WINDOW Form_1
DECLARE WINDOW Form_2
DECLARE WINDOW Form_3
DECLARE WINDOW Form_4

/*
*/
Function Main()
  LOCAL nInterval := 1, nInterval2 := 5, nInterval3 := 20, ;
	cPos := "", cFont := "", cSize := "", cColor := "",  ;
	cWave := "", cQuarter := "1", nTop := 0, nLeft := 0, ;
	nColor := 0, nBkColor := PINKLIGHT, cFontName := "System", nFontSize := 10, ;
	lBold := .f., lItalic := .f., lUnderline := .f., lStrikeout := .f.

  SET EPOCH TO ( YEAR(DATE())-50 )

  SET DATE GERMAN

  SET INTERACTIVECLOSE OFF

  IF !FILE(cCfgFile)
	DefAlarms()
  ENDIF

  BEGIN INI FILE cCfgFile
    GET cPos SECTION "Position" ENTRY "Top"
    IF EMPTY(cPos)
	SET SECTION "Position" ENTRY "Top" TO NTRIM(nTop)
    ELSE
	nTop := VAL(cPos)
    ENDIF
    GET cPos SECTION "Position" ENTRY "Left"
    IF EMPTY(cPos)
	SET SECTION "Position" ENTRY "Left" TO NTRIM(nLeft)
    ELSE
	nLeft := VAL(cPos)
    ENDIF
    GET cFont SECTION "Font" ENTRY "FontName" DEFAULT cFontName
    cFontName := cFont
    GET cSize SECTION "Font" ENTRY "FontSize"
    IF EMPTY(cSize)
	SET SECTION "Font" ENTRY "FontSize" TO NTRIM(nFontSize)
    ELSE
	nFontSize := VAL(cSize)
    ENDIF

    GET lBold SECTION "Font" ENTRY "FontBold" DEFAULT .f.
    GET lItalic SECTION "Font" ENTRY "FontItalic" DEFAULT .f.
    GET lUnderline SECTION "Font" ENTRY "FontUnderline" DEFAULT .f.
    GET lStrikeout SECTION "Font" ENTRY "FontStrikeout" DEFAULT .f.

    GET cColor SECTION "Color" ENTRY "Font"
    IF EMPTY(cColor)
	SET SECTION "Color" ENTRY "Font" TO NTRIM(nColor)
    ELSE
	nColor := VAL(cColor)
    ENDIF
    GET cColor SECTION "Color" ENTRY "Back"
    IF EMPTY(cColor)
	SET SECTION "Color" ENTRY "Back" TO NTRIM(nBkColor)
    ELSE
	nBkColor := VAL(cColor)
    ENDIF
    GET cWave SECTION "Sound" ENTRY "HourWave" DEFAULT cHourWave
    cHourWave := cWave
    GET cWave SECTION "Sound" ENTRY "QuarterWave" DEFAULT cQuarterWave
    cQuarterWave := cWave
    GET cQuarter SECTION "Sound" ENTRY "Quarter" DEFAULT "1"
    lQuarter := IF(cQuarter $ "1 YES TRUE", .T., .F.)
  END INI

  DEFINE WINDOW Form_0 			;
	AT 0,0 				;
	WIDTH 0 HEIGHT 0 			;
	TITLE PROGRAM 			;
	MAIN NOSHOW 			;
	ON INIT LaunchWatch() 		;
	ON RELEASE SavePos() 		;
	NOTIFYICON "CLOCK" 		;
	NOTIFYTOOLTIP PROGRAM 		;
	ON NOTIFYCLICK IF( IsWindowVisible(hWnd), Form_1.Hide, Form_1.Show )

	DEFINE TIMER Timer_2 ;
		INTERVAL nInterval2*1000 ;
		ACTION LaunchWatch()

	DEFINE TIMER Timer_3 ;
		INTERVAL nInterval3*1000 ;
		ACTION LaunchAlarm()

	DEFINE NOTIFY MENU
		BuildMenu()
	END MENU

  END WINDOW

  DEFINE WINDOW Form_1 		;
	AT nTop,nLeft 		;
	WIDTH 0 HEIGHT 0	;
	TITLE PROGRAM 		;
	CHILD NOCAPTION NOMINIMIZE NOMAXIMIZE NOSIZE ;
	TOPMOST ;
	ON INIT (hWnd := GetActiveWindow(), LaunchWatch(), LaunchAlarm())

	@ 0, 0 LABEL Label_1		;
		VALUE Time()	 	;
		WIDTH 58      		;
		HEIGHT 18     		;
		ACTION InterActiveMoveHandle(hWnd) ;
		FONT cFontName		;
		SIZE nFontSize		;
		TOOLTIP DtoC(Date())	;
		BACKCOLOR { GetRed(nBkColor),GetGreen(nBkColor),GetBlue(nBkColor) } ;
		FONTCOLOR { GetRed(nColor),GetGreen(nColor),GetBlue(nColor) }

	DEFINE TIMER Timer_1 ;
		INTERVAL nInterval*1000 ;
		ACTION ( Form_1.Label_1.Value := Time() )

	DEFINE CONTEXT MENU
		BuildMenu()
	END MENU

  END WINDOW

  Form_1.Label_1.FontBold := lBold
  Form_1.Label_1.FontItalic := lItalic
  Form_1.Label_1.FontUnderline := lUnderline
  Form_1.Label_1.FontStrikeout := lStrikeout
  Form_1.Width := Form_1.Label_1.Width
  Form_1.Height := Form_1.Label_1.Height

  IF LoadAlarms()
	Form_0.NotifyIcon := "ON"
  ENDIF

ACTIVATE WINDOW Form_1, Form_0

Return NIL

/*
*/
Function BuildMenu()

  ITEM 'Alarm &Scheduler'		ACTION Scheduler()
  ITEM '&Disable All Alarms'	ACTION (lStop := !lStop, ;
	Form_0.NotifyIcon := IF(lStop, "OFF", IF(MaxAlarmNumber() > 0, "ON", "CLOCK")), ;
	Form_0.Stop.Checked := lStop, Form_1.Stop.Checked := lStop) NAME Stop
  ITEM 'Disable &Quarter Sounds'	ACTION (lQuarter := !lQuarter, ;
	Form_0.Quarter.Checked := !lQuarter, Form_1.Quarter.Checked := !lQuarter) NAME Quarter

  SEPARATOR	

  ITEM 'Select &Time Font'		ACTION ChangeFont()
  ITEM 'Time &Font Color'		ACTION ChangeColor()
  ITEM 'Time &Back Color'		ACTION ChangeColor(.F.)

  SEPARATOR	

  ITEM '&About...'			ACTION ShellAbout( "", ;
	PROGRAM + VERSION + CRLF + "Copyright " + Chr(169) + COPYRIGHT, ;
	LoadTrayIcon(GetInstance(), "CLOCK", 32, 32) )

  SEPARATOR	

  ITEM 'E&xit'			ACTION {|| Form_1.Timer_1.Release, ;
	Form_0.Timer_2.Release, Form_0.Timer_3.Release, Form_0.Release }

Return Nil

/*
*/
Function ChangeFont()
  LOCAL aColor := Form_1.Label_1.FontColor, aBkColor := Form_1.Label_1.BackColor
  LOCAL aFnt := GetFont( Form_1.Label_1.FontName, Form_1.Label_1.FontSize, ;
	Form_1.Label_1.FontBold, Form_1.Label_1.FontItalic, aColor, ;
	Form_1.Label_1.FontUnderline, Form_1.Label_1.FontStrikeout )

  IF !EMPTY(aFnt[1])
	Form_1.Label_1.Release

	@ 0, 0 LABEL Label_1 OF Form_1 			;
		VALUE Time()	 			;
		WIDTH 58      				;
		HEIGHT 18     				;
		ACTION InterActiveMoveHandle(hWnd)	;
		FONT aFnt[1]				;
		SIZE aFnt[2]				;
		TOOLTIP DtoC(Date())			;
		BACKCOLOR aBkColor			;
		FONTCOLOR aColor

	Form_1.Label_1.FontBold := aFnt[3]
	Form_1.Label_1.FontItalic := aFnt[4]
	Form_1.Label_1.FontUnderline := aFnt[6]
	Form_1.Label_1.FontStrikeout := aFnt[7]

	Form_1.Label_1.SetFocus
	
	BEGIN INI FILE cCfgFile

		SET SECTION "Font" ENTRY "FontName" TO Form_1.Label_1.FontName
		SET SECTION "Font" ENTRY "FontSize" TO NTRIM(Form_1.Label_1.FontSize)
		SET SECTION "Font" ENTRY "FontBold" TO Form_1.Label_1.FontBold
		SET SECTION "Font" ENTRY "FontItalic" TO Form_1.Label_1.FontItalic
		SET SECTION "Font" ENTRY "FontUnderline" TO Form_1.Label_1.FontUnderline
		SET SECTION "Font" ENTRY "FontStrikeout" TO Form_1.Label_1.FontStrikeout

	END INI
  ENDIF

Return nil

/*
*/
Function ChangeColor(lFont)
  LOCAL nColor, aColor, ;
	lBold := .f., lItalic := .f., lUnderline := .f., lStrikeout := .f., ;
	cFontName := Form_1.Label_1.FontName, nFontSize := Form_1.Label_1.FontSize

  DEFAULT lFont TO .T.

  lBold := Form_1.Label_1.FontBold
  lItalic := Form_1.Label_1.FontItalic
  lUnderline := Form_1.Label_1.FontUnderline
  lStrikeout := Form_1.Label_1.FontStrikeout

  aColor := IF( lFont, Form_1.Label_1.FontColor, Form_1.Label_1.BackColor )

  nColor := ChooseColor( NIL, RGB(aColor[1],aColor[2],aColor[3]) )

  BEGIN INI FILE cCfgFile

	SET SECTION "Color" ENTRY IF(lFont, "Font", "Back") TO nColor

  END INI

  aColor := IF( lFont, Form_1.Label_1.BackColor, Form_1.Label_1.FontColor )

  Form_1.Label_1.Release

  IF lFont
	@ 0, 0 LABEL Label_1 OF Form_1 			;
		VALUE Time()	 			;
		WIDTH 58      				;
		HEIGHT 18     				;
		ACTION InterActiveMoveHandle(hWnd)	;
		FONT cFontName				;
		SIZE nFontSize				;
		TOOLTIP DtoC(Date())			;
		BACKCOLOR {aColor[1],aColor[2],aColor[3]}		;
		FONTCOLOR {GetRed(nColor),GetGreen(nColor),GetBlue(nColor)}
  ELSE
	@ 0, 0 LABEL Label_1 OF Form_1 			;
		VALUE Time()			 	;
		WIDTH 58      				;
		HEIGHT 18			     	;
		ACTION InterActiveMoveHandle(hWnd)	;
		FONT cFontName				;
		SIZE nFontSize				;
		TOOLTIP DtoC(Date())			;
		BACKCOLOR {GetRed(nColor),GetGreen(nColor),GetBlue(nColor)}	;
		FONTCOLOR {aColor[1],aColor[2],aColor[3]}
  ENDIF

  Form_1.Label_1.FontBold := lBold
  Form_1.Label_1.FontItalic := lItalic
  Form_1.Label_1.FontUnderline := lUnderline
  Form_1.Label_1.FontStrikeout := lStrikeout

  Form_1.Label_1.SetFocus
	
Return nil

/*
*/
Function DefAlarms()

  BEGIN INI FILE cCfgFile

	SET SECTION "Alarm 1/99" ENTRY "Frequency" TO "1"

	SET SECTION "Alarm 1/99" ENTRY "Date" TO DtoC(Date())
	SET SECTION "Alarm 1/99" ENTRY "Hour" TO "09"
	SET SECTION "Alarm 1/99" ENTRY "Minute" TO "00"
	SET SECTION "Alarm 1/99" ENTRY "Alarm" TO cAlarmWave
	SET SECTION "Alarm 1/99" ENTRY "Text" TO "Good morning!"
	SET SECTION "Alarm 1/99" ENTRY "Run" TO ""
	SET SECTION "Alarm 1/99" ENTRY "Param" TO ""

	SET SECTION "Alarm 2/99" ENTRY "Frequency" TO "1"

	SET SECTION "Alarm 2/99" ENTRY "Date" TO DtoC(Date())
	SET SECTION "Alarm 2/99" ENTRY "Hour" TO "13"
	SET SECTION "Alarm 2/99" ENTRY "Minute" TO "00"
	SET SECTION "Alarm 2/99" ENTRY "Alarm" TO cAlarmWave
	SET SECTION "Alarm 2/99" ENTRY "Text" TO "Good day!"
	SET SECTION "Alarm 2/99" ENTRY "Run" TO ""
	SET SECTION "Alarm 2/99" ENTRY "Param" TO ""

	SET SECTION "Alarm 3/99" ENTRY "Frequency" TO "1"

	SET SECTION "Alarm 3/99" ENTRY "Date" TO DtoC(Date())
	SET SECTION "Alarm 3/99" ENTRY "Hour" TO "17"
	SET SECTION "Alarm 3/99" ENTRY "Minute" TO "00"
	SET SECTION "Alarm 3/99" ENTRY "Alarm" TO cAlarmWave
	SET SECTION "Alarm 3/99" ENTRY "Text" TO "Good evening!"
	SET SECTION "Alarm 3/99" ENTRY "Run" TO ""
	SET SECTION "Alarm 3/99" ENTRY "Param" TO ""

  END INI

Return nil

/*
*/
Function LoadAlarms()
  LOCAL nI, nFrequency := 0, cFrequency := "", cDate := "", cHour := "", cMinute := "", ;
	cAlarm := "", cText := "", cRun := "", cParam := "", lActived := .F.

  BEGIN INI FILE cCfgFile

  For nI := 1 To 99

	GET cFrequency SECTION "Alarm "+NTRIM(nI)+"/99" ENTRY "Frequency"
	nFrequency := VAL(cFrequency)

	IF !Empty(nFrequency)
		GET cDate   SECTION "Alarm "+NTRIM(nI)+"/99" ENTRY "Date"
		GET cHour   SECTION "Alarm "+NTRIM(nI)+"/99" ENTRY "Hour"
		GET cMinute SECTION "Alarm "+NTRIM(nI)+"/99" ENTRY "Minute"
		GET cAlarm  SECTION "Alarm "+NTRIM(nI)+"/99" ENTRY "Alarm"
		GET cText   SECTION "Alarm "+NTRIM(nI)+"/99" ENTRY "Text"
		GET cRun    SECTION "Alarm "+NTRIM(nI)+"/99" ENTRY "Run"
		GET cParam  SECTION "Alarm "+NTRIM(nI)+"/99" ENTRY "Param"

		DO CASE
			CASE nFrequency = 1
				AADD(aDaily, { VAL(cHour), VAL(cMinute), cAlarm, cText, cRun, cParam, .T. })
				lActived := .T.

			CASE nFrequency = 2
				AADD(aMonthly, { CtoD(cDate), VAL(cHour), VAL(cMinute), cAlarm, cText, cRun, cParam, .T., nI })
				lActived := lActived .OR. (Day(ATAIL(aMonthly)[1]) = Day(Date()))

			CASE nFrequency = 3
				AADD(aYearly, { CtoD(cDate), VAL(cHour), VAL(cMinute), cAlarm, cText, cRun, cParam, .T., nI })
				lActived := lActived .OR. (Day(ATAIL(aYearly)[1]) = Day(Date()) .AND. Month(ATAIL(aYearly)[1]) = Month(Date()))

			OTHERWISE
				IF CtoD(cDate) > Date()-8
					AADD(aDay, { CtoD(cDate), VAL(cHour), VAL(cMinute), cAlarm, cText, cRun, cParam, .T., nI })
					lActived := lActived .OR. (ATAIL(aDay)[1] = Date())
				ENDIF
		ENDCASE
	ELSE
		Exit
	ENDIF

  Next

  END INI

Return lActived

/*
*/
Function LaunchWatch()
  LOCAL nMinute := Val(SubStr(Time(), 4, 2))

  IF EMPTY(nMinute)
	IF lClock
		PLAY WAVE (cHourWave)
		lClock := .F.
	ENDIF
  ELSEIF (nMinute = 15 .OR. nMinute = 30 .OR. nMinute = 45) .AND. lQuarter
	IF lClock
		PLAY WAVE (cQuarterWave)
		lClock := .F.
	ENDIF
  ELSE
	lClock := .T.
  ENDIF

Return Nil

/*
*/
Function LaunchAlarm()
  LOCAL nHour := Val(SubStr(Time(), 1, 2)), nMinute := Val(SubStr(Time(), 4, 2)), ;
	nI, cWave, cMsg, cRun, cPar

IF !lStop
  IF LEN(aDaily) > 0
	For nI := 1 To LEN(aDaily)
		IF aDaily[nI][7] = .T.
			IF aDaily[nI][1] = nHour .AND. aDaily[nI][2] = nMinute
				cWave := aDaily[nI][3]
				cMsg  := StrZero(aDaily[nI][1], 2) + ":" + StrZero(aDaily[nI][2], 2) + " - " + aDaily[nI][4]
				cRun  := aDaily[nI][5]
				cPar  := aDaily[nI][6]
				aDaily[nI][7] := .F.
				MsgAlarm("Daily Alarm", cWave, cMsg, cRun, cPar)
			ENDIF
		ENDIF
	Next
  ENDIF

  IF LEN(aMonthly) > 0
	For nI := 1 To LEN(aMonthly)
		IF aMonthly[nI][8] = .T.
			IF Day(aMonthly[nI][1]) = Day(Date())
				IF aMonthly[nI][2] = nHour .AND. aMonthly[nI][3] = nMinute
					cWave := aMonthly[nI][4]
					cMsg  := StrZero(aMonthly[nI][2], 2) + ":" + StrZero(aMonthly[nI][3], 2) + " - " + aMonthly[nI][5]
					cRun  := aMonthly[nI][6]
					cPar  := aMonthly[nI][7]
					aMonthly[nI][8] := .F.
					MsgAlarm("Monthly Alarm", cWave, cMsg, cRun, cPar)
				ENDIF
			ENDIF
		ENDIF
	Next
  ENDIF

  IF LEN(aYearly) > 0
	For nI := 1 To LEN(aYearly)
		IF aYearly[nI][8] = .T.
			IF Day(aYearly[nI][1]) = Day(Date()) .AND. Month(aYearly[nI][1]) = Month(Date())
				IF aYearly[nI][2] = nHour .AND. aYearly[nI][3] = nMinute
					cWave := aYearly[nI][4]
					cMsg  := StrZero(aYearly[nI][2], 2) + ":" + StrZero(aYearly[nI][3], 2) + " - " + aYearly[nI][5]
					cRun  := aYearly[nI][6]
					cPar  := aYearly[nI][7]
					aYearly[nI][8] := .F.
					MsgAlarm("Yearly Alarm", cWave, cMsg, cRun, cPar)
				ENDIF
			ENDIF
		ENDIF
	Next
  ENDIF

  IF LEN(aDay) > 0
	For nI := 1 To LEN(aDay)
		IF aDay[nI][8] = .T.
			IF aDay[nI][1] = Date()
				IF aDay[nI][2] = nHour .AND. aDay[nI][3] = nMinute
					cWave := aDay[nI][4]
					cMsg  := StrZero(aDay[nI][2], 2) + ":" + StrZero(aDay[nI][3], 2) + " - " + aDay[nI][5]
					cRun  := aDay[nI][6]
					cPar  := aDay[nI][7]
					aDay[nI][8] := .F.
					MsgAlarm("Alarm for " + DtoC(aDay[nI][1]), cWave, cMsg, cRun, cPar)
				ENDIF
			ENDIF
		ENDIF
	Next
  ENDIF
ENDIF

Return Nil

/*
*/
Function MsgAlarm(cInfo, cWaveFile, cAlarmMsg, cRunFile, cParam)

  IF !EMPTY(cWaveFile)
	PLAY WAVE (cWaveFile)
  ENDIF

  IF !EMPTY(cRunFile)
	EXECUTE FILE cRunFile PARAMETERS cParam
  ENDIF

  IF LEN(cAlarmMsg) > 8
	MsgInfo(cAlarmMsg, cInfo, IDI_WATCH, .F.)
  ENDIF

Return nil

/*
*/
Function Scheduler()

IF !IsWindowDefined(Form_2)

  DEFINE WINDOW Form_2 		;
	AT 0,0 			;
	WIDTH 380		;
	HEIGHT 300 + IF(IsXPThemeActive(), 6, 0) ;
	TITLE "Alarm Scheduler" ;
	ICON IDI_WATCH 		;
	MODAL 			;
	ON INIT Form_2.Button_1.SetFocus ;
	FONT "System"		;
	SIZE 10			;
	BACKCOLOR { GetRed(PINKLIGHT),GetGreen(PINKLIGHT),GetBlue(PINKLIGHT) }

      @ 15,10 MONTHCALENDAR Month_1 ;
         VALUE Date() ;
         FONT IF(IsWinNT(), "Tahoma", "Courier") SIZE 12 ;
         NOTODAYCIRCLE ;
         NOTABSTOP ;
         ON CHANGE AlarmSet(Form_2.Month_1.Value, Form_2.CheckButton_1.Value, ;
			Form_2.CheckButton_2.Value, Form_2.CheckButton_3.Value)

	@ 235,12 BUTTONEX Button_1 CAPTION "OK" ;
		ACTION AlarmSet(Form_2.Month_1.Value, Form_2.CheckButton_1.Value, ;
			Form_2.CheckButton_2.Value, Form_2.CheckButton_3.Value) ;
		WIDTH 100 HEIGHT 28
	@ 235,142 BUTTONEX Button_2 CAPTION "Cancel" ;
		ACTION Form_2.Release WIDTH 100 HEIGHT 28

	@ 15,260 CHECKBUTTON CheckButton_1 CAPTION "Daily" ;
		VALUE .F. ;
		ON CHANGE (IF(Form_2.CheckButton_1.Value = .T., ;
			( Form_2.CheckButton_2.Value := .F., Form_2.CheckButton_3.Value := .F.), )) ;
		WIDTH 100 HEIGHT 28
	@ 60,260 CHECKBUTTON CheckButton_2 CAPTION "Monthly" ;
		VALUE .F. ;
		ON CHANGE (IF(Form_2.CheckButton_2.Value = .T., ;
			( Form_2.CheckButton_1.Value := .F., Form_2.CheckButton_3.Value := .F.), )) ;
		WIDTH 100 HEIGHT 28
	@ 105,260 CHECKBUTTON CheckButton_3 CAPTION "Yearly" ;
		VALUE .F. ;
		ON CHANGE (IF(Form_2.CheckButton_3.Value = .T., ;
			( Form_2.CheckButton_1.Value := .F., Form_2.CheckButton_2.Value := .F.), )) ;
		WIDTH 100 HEIGHT 28

	@ 180,294 IMAGE Image_1 PICTURE "WATCH" WIDTH 32 HEIGHT 32

		ON KEY ESCAPE ACTION Form_2.Button_2.OnClick
  END WINDOW

  CENTER WINDOW Form_2

  ACTIVATE WINDOW Form_2

ENDIF

Return nil

/*
*/
Function AlarmSet(dDate, lDaily, lMonthly, lYearly)
  LOCAL aArray := {}, aId := {}
  LOCAL nFrequency := IF(lDaily, 1, IF(lMonthly, 2, IF(lYearly, 3, 4)))
  LOCAL cTitle := IF(lDaily, "Daily ", IF(lMonthly, "Monthly ", ;
		IF(lYearly, "Yearly ", ""))) + "Alarms" + ;
		IF(nFrequency = 2, " for " + NTRIM(Day(dDate)) + " day", ;
		IF(nFrequency = 3, " for " + NTRIM(Day(dDate)) + " " + cMonth(dDate), ;
		IF(nFrequency = 4, " for " + DtoC(dDate), "")))

  DO CASE
	CASE nFrequency = 1
		AEVAL(aDaily, {|e| AADD(aArray, {StrZero(e[1], 2)+":"+StrZero(e[2], 2), e[4]})} )

	CASE nFrequency = 2
		AEVAL(aMonthly, {|e| IF(Day(e[1])=Day(dDate), ;
			(AADD(aArray, {StrZero(e[2], 2)+":"+StrZero(e[3], 2), e[5]}), ;
			AADD(aId, e[9])), )} )

	CASE nFrequency = 3
		AEVAL(aYearly, {|e| IF(Day(e[1])=Day(dDate) .AND. Month(e[1])=Month(dDate), ;
			(AADD(aArray, {StrZero(e[2], 2)+":"+StrZero(e[3], 2), e[5]}), ;
			AADD(aId, e[9])), )} )

	OTHERWISE
		AEVAL(aDay, {|e| IF(e[1]=dDate, ;
			(AADD(aArray, {StrZero(e[2], 2)+":"+StrZero(e[3], 2), e[5]}), ;
			AADD(aId, e[9])), )} )
  ENDCASE

  DEFINE WINDOW Form_3 		;
	AT 0,0 			;
	WIDTH 380		;
	HEIGHT 300 + IF(IsXPThemeActive(), 6, 0) ;
	TITLE cTitle		;
	ICON IDI_WATCH 		;
	MODAL			 	;
	FONT "System"		;
	SIZE 10			;
	BACKCOLOR { GetRed(PINKLIGHT),GetGreen(PINKLIGHT),GetBlue(PINKLIGHT) }

	@ 235,12 BUTTONEX Button_1 CAPTION "OK" ;
		ACTION (SaveIni(), ;
		Form_0.NotifyIcon := IF(lStop, "OFF", IF(MaxAlarmNumber() > 0, "ON", "CLOCK")), ;
		Form_3.Release) WIDTH 100 HEIGHT 28 TOOLTIP "Exit with saving of changes"
	@ 235,142 BUTTONEX Button_2 CAPTION "Cancel" ;
		ACTION ;
		(Form_0.NotifyIcon := IF(lStop, "OFF", IF(MaxAlarmNumber() > 0, "ON", "CLOCK")), ;
		Form_3.Release) WIDTH 100 HEIGHT 28 TOOLTIP "Exit without saving of changes"

	@ 15,10 GRID Grid_1 ;
		WIDTH 234 + IF(IsXPThemeActive(), 2, 0)	;
		HEIGHT 205 ;
		HEADERS {"Time","Message"} ;
		WIDTHS {54, 160} ;
		ITEMS aArray ;
		VALUE 1 ;
		FONT "Tahoma" SIZE 12 ;
		ON DBLCLICK (EditAlarm(nFrequency, dDate, aId), Form_3.Grid_1.SetFocus) ;
		NOLINES

	@ 15,258 BUTTONEX Button_3 CAPTION "Add Alarm" ;
		ACTION (EditAlarm(nFrequency, dDate, aId, .T.), Form_3.Grid_1.SetFocus) ;
		WIDTH 104 HEIGHT 28
	@ 60,258 BUTTONEX Button_4 CAPTION "Edit Alarm" ;
		ACTION (EditAlarm(nFrequency, dDate, aId), Form_3.Grid_1.SetFocus) ;
		WIDTH 104 HEIGHT 28
	@ 105,258 BUTTONEX Button_5 CAPTION "Remove Alarm" ;
		ACTION (aId := RemoveAlarm(nFrequency, Form_3.Grid_1.Value, aId, dDate), Form_3.Grid_1.SetFocus) ;
		WIDTH 104 HEIGHT 28

	@ 180,294 IMAGE Image_1 PICTURE "WATCH" WIDTH 32 HEIGHT 32

		ON KEY ESCAPE ACTION Form_3.Button_2.OnClick
  END WINDOW

  CENTER WINDOW Form_3

  ACTIVATE WINDOW Form_3

Return nil

/*
*/
Function EditAlarm(nFrequency, dDate, aPos, lNew)
  LOCAL cWave := "", cText_1 := "", cText_2 := "", cEdit_1 := "", cText_4 := "", cText_5 := ""
  LOCAL nPos := Form_3.Grid_1.Value, aArray := {}, ;
		cTitle, cTime := Time(), nMinute := VAL(SUBSTR(cTime, 4, 2))
  LOCAL nNew := IF(nMinute >= 0 .AND. nMinute < 15, 15, ;
		IF(nMinute > 14 .AND. nMinute < 30, 30, ;
		IF(nMinute > 29 .AND. nMinute < 45, 45, ;
		IF(nMinute > 44 .AND. nMinute < 59, 0, 0 ))))

  DEFAULT lNew TO .F.

  cTitle := IF(lNew, "Add ", "Edit ")+ ;
		IF(nFrequency = 1, "Daily", IF(nFrequency = 2, "Monthly", ;
		IF(nFrequency = 3, "Yearly", ""))) + " Alarm"

  IF !lNew .AND. EMPTY(nPos)
	Return nil
  ELSEIF lNew
	IF MaxAlarmNumber() > 98
		MsgStop('There is MAX numbers of alarms!', 'Stop!')
		Return nil
	ENDIF
	IF EMPTY(nNew)
		cTime := StrZero(VAL(SUBSTR(cTime, 1, 2)) + 1, 2) + SUBSTR(cTime, 3)
	ENDIF
	nPos := Form_3.Grid_1.ItemCount + 1
  ENDIF

  IF nFrequency = 1
	cText_1 := IF(lNew, SUBSTR(cTime, 1, 2), StrZero(aDaily[nPos][1], 2))
	cText_2 := IF(lNew, StrZero(nNew, 2), StrZero(aDaily[nPos][2], 2))
	cWave := IF(lNew, cAlarmWave, aDaily[nPos][3])
	cEdit_1 := IF(lNew, cEdit_1, aDaily[nPos][4])
	cText_4 := IF(lNew, cText_4, aDaily[nPos][5])
	cText_5 := IF(lNew, cText_5, aDaily[nPos][6])
  ELSE
	IF lNew
		AADD(aPos, MaxAlarmNumber()+1)
	ENDIF
	DO CASE
	CASE nFrequency = 2
		AEVAL(aMonthly, {|e| IF(Day(e[1])=Day(dDate), ;
			AADD(aArray, {e[1], e[2], e[3], e[4], e[5], e[6], e[7], e[8]}), )} )

	CASE nFrequency = 3
		AEVAL(aYearly, {|e| IF(Day(e[1])=Day(dDate).AND.Month(e[1])=Month(dDate), ;
			AADD(aArray, {e[1], e[2], e[3], e[4], e[5], e[6], e[7], e[8]}), )} )

	OTHERWISE
		AEVAL(aDay, {|e| IF(e[1]=dDate, ;
			AADD(aArray, {e[1], e[2], e[3], e[4], e[5], e[6], e[7], e[8]}), )} )
	ENDCASE

	cText_1 := IF(lNew, SUBSTR(cTime, 1, 2), StrZero(aArray[nPos][2], 2))
	cText_2 := IF(lNew, StrZero(nNew, 2), StrZero(aArray[nPos][3], 2))
	cWave := IF(lNew, cAlarmWave, aArray[nPos][4])
	cEdit_1 := IF(lNew, cEdit_1, aArray[nPos][5])
	cText_4 := IF(lNew, cText_4, aArray[nPos][6])
	cText_5 := IF(lNew, cText_5, aArray[nPos][7])
  ENDIF

  DEFINE WINDOW Form_4 		;
	AT 0,0 			;
	WIDTH 380		;
	HEIGHT 300 + IF(IsXPThemeActive(), 6, 0) ;
	TITLE cTitle		;
	ICON IDI_WATCH 		;
	MODAL			 	;
	ON INIT Form_4.Text_1.SetFocus ;
	FONT "System"		;
	SIZE 10			;
	BACKCOLOR {GetRed(PINKLIGHT),GetGreen(PINKLIGHT),GetBlue(PINKLIGHT)}

	@ 6,6 FRAME Frame_1 WIDTH 360 HEIGHT 138

	@ 20,15 LABEL Label_1 VALUE "Time:" WIDTH 40 HEIGHT 22 ;
		BACKCOLOR {GetRed(PINKLIGHT),GetGreen(PINKLIGHT),GetBlue(PINKLIGHT)}

	@ 18,60 TEXTBOX Text_1 VALUE cText_1 HEIGHT 24 WIDTH 24 ;
		MAXLENGTH 2
	@ 18,90 LABEL Label_3 VALUE ":" WIDTH 10 HEIGHT 22 ;
		BACKCOLOR {GetRed(PINKLIGHT),GetGreen(PINKLIGHT),GetBlue(PINKLIGHT)}
	@ 18,101 TEXTBOX Text_2 VALUE cText_2 HEIGHT 24 WIDTH 24 ;
		MAXLENGTH 2

	@ 20,140 LABEL Label_4 VALUE "Sound:" WIDTH 50 HEIGHT 22 ;
		BACKCOLOR {GetRed(PINKLIGHT),GetGreen(PINKLIGHT),GetBlue(PINKLIGHT)}
	@ 18,190 TEXTBOX Text_3 VALUE cWave HEIGHT 24 WIDTH 96 ;
		MAXLENGTH 120

	@ 18,292 BUTTONEX PicButton_1 PICTURE "OPEN" ;
		ACTION (cWave := GetFile( {{"Audio files", "*.wav"}}, "Select a File" ), ;
			Form_4.Text_3.Value := cWave, Form_4.Text_3.SetFocus) ;
		WIDTH 24 HEIGHT 24
	@ 18,324 BUTTONEX PicButton_2 PICTURE "TEST" ;
		ACTION IF( EMPTY(Form_4.Text_3.Value), , playwave(Form_4.Text_3.Value,.F.,.F.,.F.,.F.,.F.) ) ;
		WIDTH 30 HEIGHT 24

	@ 54,15 LABEL Label_2 VALUE "Text:" WIDTH 40 HEIGHT 22 ;
		BACKCOLOR {GetRed(PINKLIGHT),GetGreen(PINKLIGHT),GetBlue(PINKLIGHT)}

	@ 54,60 EDITBOX Edit_1 VALUE cEdit_1 WIDTH 294 HEIGHT 77

	@ 150,6 FRAME Frame_2 WIDTH 360 HEIGHT 75

	@ 162,15 LABEL Label_5 VALUE "Run:" WIDTH 30 HEIGHT 22 ;
		BACKCOLOR {GetRed(PINKLIGHT),GetGreen(PINKLIGHT),GetBlue(PINKLIGHT)}
	@ 160,60 TEXTBOX Text_4 VALUE cText_4 HEIGHT 24 WIDTH 264 ;
		MAXLENGTH 120

	@ 160,330 BUTTONEX PicButton_3 PICTURE "OPEN" ;
		ACTION (cText_4 := GetFile( {{"Exe files", "*.exe"}, ;
			{"Bat files", "*.bat"}, {"All files", "*.*"}}, "Select a File" ), ;
			Form_4.Text_4.Value := cText_4, Form_4.Text_4.SetFocus) ;
		WIDTH 24 HEIGHT 24

	@ 192,15 LABEL Label_6 VALUE "Parameters:" WIDTH 82 HEIGHT 22 ;
		BACKCOLOR {GetRed(PINKLIGHT),GetGreen(PINKLIGHT),GetBlue(PINKLIGHT)}
	@ 190,104 TEXTBOX Text_5 VALUE cText_5 HEIGHT 24 WIDTH 250 ;
		MAXLENGTH 120

	@ 236,72 BUTTONEX Button_1 CAPTION "OK" ;
		ACTION (SaveAlarm(lNew, nFrequency, nPos, aPos, dDate, ;
			Form_4.Text_1.Value, Form_4.Text_2.Value, ;
			Form_4.Text_3.Value, Form_4.Edit_1.Value, ;
			Form_4.Text_4.Value, Form_4.Text_5.Value), Form_4.Release) ;
		WIDTH 100 HEIGHT 28
	@ 236,202 BUTTONEX Button_2 CAPTION "Cancel" ;
		ACTION Form_4.Release WIDTH 100 HEIGHT 28

		ON KEY ESCAPE ACTION Form_4.Button_2.OnClick
  END WINDOW

  CENTER WINDOW Form_4

  ACTIVATE WINDOW Form_4

Return nil

/*
*/
Function SaveIni()
  LOCAL nI, nLast, aColor := Form_1.Label_1.FontColor, aBkColor := Form_1.Label_1.BackColor

  IF FILE(cCfgFile)
	FERASE(cCfgFile)
  ENDIF

  SavePos()

  BEGIN INI FILE cCfgFile

	SET SECTION "Font" ENTRY "FontName" TO Form_1.Label_1.FontName
	SET SECTION "Font" ENTRY "FontSize" TO NTRIM(Form_1.Label_1.FontSize)
	SET SECTION "Color" ENTRY "Font" TO RGB(aColor[1],aColor[2],aColor[3])
	SET SECTION "Color" ENTRY "Back" TO RGB(aBkColor[1],aBkColor[2],aBkColor[3])

	For nI := 1 To LEN(aDaily)

		SET SECTION "Alarm "+NTRIM(nI)+"/99" ENTRY "Frequency" TO "1"
		SET SECTION "Alarm "+NTRIM(nI)+"/99" ENTRY "Date" TO DtoC(Date())
		SET SECTION "Alarm "+NTRIM(nI)+"/99" ENTRY "Hour" TO StrZero(aDaily[nI][1], 2)
		SET SECTION "Alarm "+NTRIM(nI)+"/99" ENTRY "Minute" TO StrZero(aDaily[nI][2], 2)
		SET SECTION "Alarm "+NTRIM(nI)+"/99" ENTRY "Alarm" TO aDaily[nI][3]
		SET SECTION "Alarm "+NTRIM(nI)+"/99" ENTRY "Text" TO aDaily[nI][4]
		SET SECTION "Alarm "+NTRIM(nI)+"/99" ENTRY "Run" TO aDaily[nI][5]
		SET SECTION "Alarm "+NTRIM(nI)+"/99" ENTRY "Param" TO aDaily[nI][6]

	Next

	nLast := nI

	For nI := 1 To LEN(aMonthly)

		SET SECTION "Alarm "+NTRIM(nLast)+"/99" ENTRY "Frequency" TO "2"
		SET SECTION "Alarm "+NTRIM(nLast)+"/99" ENTRY "Date" TO DtoC(aMonthly[nI][1])
		SET SECTION "Alarm "+NTRIM(nLast)+"/99" ENTRY "Hour" TO StrZero(aMonthly[nI][2], 2)
		SET SECTION "Alarm "+NTRIM(nLast)+"/99" ENTRY "Minute" TO StrZero(aMonthly[nI][3], 2)
		SET SECTION "Alarm "+NTRIM(nLast)+"/99" ENTRY "Alarm" TO aMonthly[nI][4]
		SET SECTION "Alarm "+NTRIM(nLast)+"/99" ENTRY "Text" TO aMonthly[nI][5]
		SET SECTION "Alarm "+NTRIM(nLast)+"/99" ENTRY "Run" TO aMonthly[nI][6]
		SET SECTION "Alarm "+NTRIM(nLast)+"/99" ENTRY "Param" TO aMonthly[nI][7]
		nLast++
	Next

	For nI := 1 To LEN(aYearly)

		SET SECTION "Alarm "+NTRIM(nLast)+"/99" ENTRY "Frequency" TO "3"
		SET SECTION "Alarm "+NTRIM(nLast)+"/99" ENTRY "Date" TO DtoC(aYearly[nI][1])
		SET SECTION "Alarm "+NTRIM(nLast)+"/99" ENTRY "Hour" TO StrZero(aYearly[nI][2], 2)
		SET SECTION "Alarm "+NTRIM(nLast)+"/99" ENTRY "Minute" TO StrZero(aYearly[nI][3], 2)
		SET SECTION "Alarm "+NTRIM(nLast)+"/99" ENTRY "Alarm" TO aYearly[nI][4]
		SET SECTION "Alarm "+NTRIM(nLast)+"/99" ENTRY "Text" TO aYearly[nI][5]
		SET SECTION "Alarm "+NTRIM(nLast)+"/99" ENTRY "Run" TO aYearly[nI][6]
		SET SECTION "Alarm "+NTRIM(nLast)+"/99" ENTRY "Param" TO aYearly[nI][7]
		nLast++
	Next

	For nI := 1 To LEN(aDay)

		SET SECTION "Alarm "+NTRIM(nLast)+"/99" ENTRY "Frequency" TO "4"
		SET SECTION "Alarm "+NTRIM(nLast)+"/99" ENTRY "Date" TO DtoC(aDay[nI][1])
		SET SECTION "Alarm "+NTRIM(nLast)+"/99" ENTRY "Hour" TO StrZero(aDay[nI][2], 2)
		SET SECTION "Alarm "+NTRIM(nLast)+"/99" ENTRY "Minute" TO StrZero(aDay[nI][3], 2)
		SET SECTION "Alarm "+NTRIM(nLast)+"/99" ENTRY "Alarm" TO aDay[nI][4]
		SET SECTION "Alarm "+NTRIM(nLast)+"/99" ENTRY "Text" TO aDay[nI][5]
		SET SECTION "Alarm "+NTRIM(nLast)+"/99" ENTRY "Run" TO aDay[nI][6]
		SET SECTION "Alarm "+NTRIM(nLast)+"/99" ENTRY "Param" TO aDay[nI][7]
		nLast++
	Next

  END INI

Return nil

/*
*/
Function SavePos()

  BEGIN INI FILE cCfgFile

	SET SECTION "Position" ENTRY "Top" TO NTRIM(GetWindowRow(hWnd))
	SET SECTION "Position" ENTRY "Left" TO NTRIM(GetWindowCol(hWnd))

	SET SECTION "Sound" ENTRY "Quarter" TO IF(lQuarter, "1", "0")
	SET SECTION "Sound" ENTRY "HourWave" TO cHourWave
	SET SECTION "Sound" ENTRY "QuarterWave" TO cQuarterWave

  END INI

Return nil

/*
*/
Function SaveAlarm(lNew, nFrequency, nPos, aId, dDate, cText_1, cText_2, cWave, cEdit_1, cText_4, cText_5)
  LOCAL aArray := {}, nI, nMax := MaxAlarmNumber()

  DO CASE
	CASE nFrequency = 1
		IF lNew
			AADD(aDaily, {VAL(cText_1), VAL(cText_2), cWave, cEdit_1, cText_4, cText_5, .T.})
		ELSE
			aDaily[nPos][1] := VAL(cText_1)
			aDaily[nPos][2] := VAL(cText_2)
			aDaily[nPos][3] := cWave
			aDaily[nPos][4] := cEdit_1
			aDaily[nPos][5] := cText_4
			aDaily[nPos][6] := cText_5
			aDaily[nPos][7] := .T.
		ENDIF
		AEVAL(aDaily, {|e| AADD(aArray, {StrZero(e[1], 2)+":"+StrZero(e[2], 2), e[4]})} )

	CASE nFrequency = 2
		IF lNew
			AADD(aMonthly, {dDate, VAL(cText_1), VAL(cText_2), cWave, cEdit_1, cText_4, cText_5, .T., nMax+1})
		ELSE
			For nI := 1 To LEN(aMonthly)
				IF Day(aMonthly[nI][1]) = Day(dDate) .AND. aMonthly[nI][9] = aId[nPos]
					aMonthly[nI][2] := VAL(cText_1)
					aMonthly[nI][3] := VAL(cText_2)
					aMonthly[nI][4] := cWave
					aMonthly[nI][5] := cEdit_1
					aMonthly[nI][6] := cText_4
					aMonthly[nI][7] := cText_5
					aMonthly[nI][8] := .T.
					EXIT
				ENDIF
			Next
		ENDIF
		AEVAL(aMonthly, {|e| IF(Day(e[1])=Day(dDate), ;
			AADD(aArray, {StrZero(e[2], 2)+":"+StrZero(e[3], 2), e[5]}), )} )

	CASE nFrequency = 3
		IF lNew
			AADD(aYearly, {dDate, VAL(cText_1), VAL(cText_2), cWave, cEdit_1, cText_4, cText_5, .T., nMax+1})
		ELSE
			For nI := 1 To LEN(aYearly)
				IF Day(aYearly[nI][1]) = Day(dDate) .AND. ;
					Month(aYearly[nI][1]) = Month(dDate) .AND. aYearly[nI][9] = aId[nPos]
					aYearly[nI][2] := VAL(cText_1)
					aYearly[nI][3] := VAL(cText_2)
					aYearly[nI][4] := cWave
					aYearly[nI][5] := cEdit_1
					aYearly[nI][6] := cText_4
					aYearly[nI][7] := cText_5
					aYearly[nI][8] := .T.
					EXIT
				ENDIF
			Next
		ENDIF
		AEVAL(aYearly, {|e| IF(Day(e[1])=Day(dDate) .AND. Month(e[1])=Month(dDate), ;
			AADD(aArray, {StrZero(e[2], 2)+":"+StrZero(e[3], 2), e[5]}), )} )

	OTHERWISE
		IF lNew
			AADD(aDay, {dDate, VAL(cText_1), VAL(cText_2), cWave, cEdit_1, cText_4, cText_5, .T., nMax+1})
		ELSE
			For nI := 1 To LEN(aDay)
				IF aDay[nI][1] = dDate .AND. aDay[nI][9] = aId[nPos]
					aDay[nI][2] := VAL(cText_1)
					aDay[nI][3] := VAL(cText_2)
					aDay[nI][4] := cWave
					aDay[nI][5] := cEdit_1
					aDay[nI][6] := cText_4
					aDay[nI][7] := cText_5
					aDay[nI][8] := .T.
					EXIT
				ENDIF
			Next
		ENDIF
		AEVAL(aDay, {|e| IF(e[1]=dDate, ;
			AADD(aArray, {StrZero(e[2], 2)+":"+StrZero(e[3], 2), e[5]}), )} )
  ENDCASE

  Form_3.Grid_1.DeleteAllItems

  AEVAL(aArray, {|e| Form_3.Grid_1.AddItem( e )})

  Form_3.Grid_1.Value := nPos

Return nil

/*
*/
Function RemoveAlarm(nFrequency, nPos, aPos, dDate)
  LOCAL aArray := {}, nI

  IF !EMPTY(nPos)
	IF nFrequency = 1
		aPos := {}
		ADEL(aDaily, nPos)
		ASIZE(aDaily, LEN(aDaily)-1)
		AEVAL(aDaily, {|e| AADD(aArray, {StrZero(e[1], 2)+":"+StrZero(e[2], 2), e[4]})} )
	  ELSE
		DO CASE
		CASE nFrequency = 2
			For nI := 1 To LEN(aMonthly)
				IF Day(aMonthly[nI][1]) = Day(dDate) .AND. aMonthly[nI][9] = aPos[nPos]
					ADEL(aMonthly, nI)
					ASIZE(aMonthly, LEN(aMonthly)-1)
					EXIT
				ENDIF
			Next
			aArray := {}
			aPos := {}
			AEVAL(aMonthly, {|e| IF(Day(e[1])=Day(dDate), ;
				(AADD(aArray, {StrZero(e[2], 2)+":"+StrZero(e[3], 2), e[5]}), ;
				AADD(aPos, e[9])), )} )

		CASE nFrequency = 3
			For nI := 1 To LEN(aYearly)
				IF Day(aYearly[nI][1]) = Day(dDate) .AND. ;
						Month(aYearly[nI][1]) = Month(dDate) .AND. aYearly[nI][9] = aPos[nPos]
					ADEL(aYearly, nI)
					ASIZE(aYearly, LEN(aYearly)-1)
					EXIT
				ENDIF
			Next
			aArray := {}
			aPos := {}
			AEVAL(aYearly, {|e| IF(Day(e[1])=Day(dDate) .AND. Month(e[1])=Month(dDate), ;
				(AADD(aArray, {StrZero(e[2], 2)+":"+StrZero(e[3], 2), e[5]}), ;
				AADD(aPos, e[9])), )} )

		OTHERWISE
			For nI := 1 To LEN(aDay)
				IF aDay[nI][1] = dDate .AND. aDay[nI][9] = aPos[nPos]
					ADEL(aDay, nI)
					ASIZE(aDay, LEN(aDay)-1)
					EXIT
				ENDIF
			Next
			aArray := {}
			aPos := {}
			AEVAL(aDay, {|e| IF(e[1] = dDate, ;
				(AADD(aArray, {StrZero(e[2], 2)+":"+StrZero(e[3], 2), e[5]}), ;
				AADD(aPos, e[9])), )} )

		ENDCASE
	ENDIF
  ENDIF

  Form_3.Grid_1.DeleteAllItems

  AEVAL(aArray, {|e| Form_3.Grid_1.AddItem( e )})

  Form_3.Grid_1.Value := IF(nPos > 1, nPos-1, 1)

Return aPos

/*
*/
Function MaxAlarmNumber()

Return LEN(aDay) + LEN(aDaily) + LEN(aMonthly) + LEN(aYearly)

/*
 * C-level
*/
#pragma BEGINDUMP

#include <windows.h>
#include "hbapi.h"

HB_FUNC ( INTERACTIVEMOVEHANDLE )
{

	keybd_event(
		VK_RIGHT,	// virtual-key code
		0,		// hardware scan code
		0,		// flags specifying various function options
		0		// additional data associated with keystroke
	);
	keybd_event(
		VK_LEFT,	// virtual-key code
		0,		// hardware scan code
		0,		// flags specifying various function options
		0		// additional data associated with keystroke
	);

	SendMessage( (HWND) hb_parnl(1) , WM_SYSCOMMAND , SC_MOVE ,10 );

}

#pragma ENDDUMP
