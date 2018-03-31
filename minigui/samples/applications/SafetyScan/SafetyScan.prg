/*
 * MINIGUI - Harbour Win32 GUI library Demo
 *
 * Copyright 2002-08 Roberto Lopez <harbourminigui@gmail.com>
 * http://harbourminigui.googlepages.com/
 * 
 * Copyright 2003-08 Grigory Filatov <gfilatov@inbox.ru>
*/

ANNOUNCE RDDSYS

#include "minigui.ch"

#define SCHEDULE

#define PROGRAM 'Safety Scan'
#ifndef SCHEDULE
	#define VERSION ' version 1.1.0'
#else
	#define VERSION ' version 1.3.7'
#endif
#define COPYRIGHT ' 2003-2008 by Grigory Filatov'
#define CLR_BACK	{ 244, 243, 238 }

Memvar cPath, cFileName, cPathCleaned, aDrv_clone, aMsk_clone, nTotal

Static nPageNumber := 1, lTemp := .f., nState := 1, aCleanFiles := {}, ;
	cStatusMsg := "Designed and developed in" + COPYRIGHT

#ifdef SCHEDULE
Static lSchedule := .f., lAutoScan := .t., lAutoClean := .f., lOnlyScan := .f., ;
	nMinSpace := 100, nEvery := 1, nMinutes := 30, nHours := 1, nMinutes2 := 30, ;
	nDays := 1, nHour := 12, nMinute := 0, nWeeks := 1, nDay := 2, nMonths := 1, ;
	nDayMonths := 1, cStartTime, dNextScanDate, cNextScanTime := ""
#endif

DECLARE WINDOW Form_2

Procedure Main( lStartUp )
	LOCAL lWinRun := .F.

	PUBLIC cPath := cFilePath( GetExeFileName() ) + "\"
	PUBLIC cFileName := cPath + cFileNoExt( GetExeFileName() ), ;
		cPathCleaned := Lower(cPath) + "Cleaned"

	PUBLIC aDrv_clone, aMsk_clone

	SET MULTIPLE OFF

	If !Empty(lStartUp) .AND. Upper(Substr(lStartUp, 2)) == "STARTUP" .OR. ;
		!Empty(GETREGVAR( NIL, "Software\Microsoft\Windows\CurrentVersion\Run", "SafetyScan" ))
		lWinRun := .T.
	EndIf

	SET CENTURY ON
	SET DATE GERMAN

	SET HELPFILE TO 'safetyscan.chm'

	DEFINE WINDOW Form_1 				;
		AT 0,0 					;
		WIDTH 0 HEIGHT 0 			;
		TITLE PROGRAM 				;
		MAIN NOSHOW 				;
		ON INIT IF( lWinRun, , MainForm() )	;
		NOTIFYICON 'SYSTEM' 			;
		NOTIFYTOOLTIP PROGRAM 			;
		ON NOTIFYCLICK MainForm()

		DEFINE NOTIFY MENU 
			ITEM '&Open' 	ACTION {|| IF(IsWindowDefined( Form_2 ),	;
				(nPageNumber := Form_2.Tab_1.Value, Form_2.Release),	;
				MainForm()) } DEFAULT
			SEPARATOR	
			ITEM 'Auto&Run'	ACTION {|| lWinRun := !lWinRun, 		;
				Form_1.Auto_Run.Checked := lWinRun, WinRun(lWinRun) }	;
				NAME Auto_Run
			SEPARATOR	
			ITEM 'A&bout...'	ACTION ShellAbout( "", PROGRAM + VERSION + CRLF + ;
				"Copyright " + Chr(169) + COPYRIGHT, LoadIconByName("SYSTEM", 32, 32) )
			ITEM 'E&xit'	ACTION Form_1.Release
		END MENU

		Form_1.Auto_Run.Checked := lWinRun

#ifdef SCHEDULE
		DEFINE TIMER Timer_1 INTERVAL 60000 ACTION AutoScan()

		cStartTime := SubStr( Time(), 1, 6 ) + "00"
		dNextScanDate := CTOD("")
#endif

	END WINDOW

	ACTIVATE WINDOW Form_1

Return

*--------------------------------------------------------*
Static Procedure MainForm()
*--------------------------------------------------------*
LOCAL aMask := { {1, "*.~*"}, {1, "~*.*"}, {1, "*.??~"}, {1, "*.---"}, ;
		{1, "*.old"}, {1, "*.tmp"}, {1, "*.bak"}, {1, "*.gid"}, ;
		{1, "*.mp"}, {1, "*.chk"}, {1, "mscreate.dir"} }, aDrives
LOCAL aLabel := {"Permanently Delete Them", "Move Them To The Recycle Bin", "Move Them To This Folder:"}
LOCAL aImage := {"uncheck", "check"}, aTrashImage := {"trash", "trash"}
LOCAL aTmpDrv := {}, cTmpFld, nItem, nCleaned := 0, cMask := ""
LOCAL nBtnPos := iif(IsXPThemeActive(), 340, 342)

   if !IsWindowDefined( Form_2 )

	aDrives := GetDrives()

	IF !FILE(cFileName + '.ini')
		BEGIN INI FILE Lower(cFileName) + '.ini'
			SET SECTION "Options" ENTRY "Drives" TO aDrives
			SET SECTION "Options" ENTRY "Delete" TO nState
			SET SECTION "Options" ENTRY "Path" TO cPathCleaned
			SET SECTION "Scan" ENTRY "Masks" TO aMask
			SET SECTION "Scan" ENTRY "Temp" TO lTemp
#ifdef SCHEDULE
			SET SECTION "Schedule" ENTRY "AutoScan" TO lAutoScan
			SET SECTION "Schedule" ENTRY "AutoClean" TO lAutoClean
			SET SECTION "Schedule" ENTRY "OnlyScan" TO lOnlyScan
			SET SECTION "Schedule" ENTRY "MinSpace" TO nMinSpace
			SET SECTION "Schedule" ENTRY "Every" TO nEvery
			SET SECTION "Schedule" ENTRY "EveryMinutes" TO nMinutes
			SET SECTION "Schedule" ENTRY "EveryHours" TO nHours
			SET SECTION "Schedule" ENTRY "EveryHoursMinutes" TO nMinutes2
			SET SECTION "Schedule" ENTRY "EveryDays" TO nDays
			SET SECTION "Schedule" ENTRY "EveryDaysHour" TO nHour
			SET SECTION "Schedule" ENTRY "EveryDaysMinute" TO nMinute
			SET SECTION "Schedule" ENTRY "EveryWeeks" TO nWeeks
			SET SECTION "Schedule" ENTRY "EveryWeeksDay" TO nDay
			SET SECTION "Schedule" ENTRY "EveryMonths" TO nMonths
			SET SECTION "Schedule" ENTRY "EveryMonthsDay" TO nDayMonths
			SetNextScan()
#endif
		END INI
	ELSE
		BEGIN INI FILE Lower(cFileName) + '.ini'
			GET aTmpDrv SECTION "Options" ENTRY "Drives"
			GET nState SECTION "Options" ENTRY "Delete"
			GET cPathCleaned SECTION "Options" ENTRY "Path"
			GET aMask SECTION "Scan" ENTRY "Masks"
			GET lTemp SECTION "Scan" ENTRY "Temp"
#ifdef SCHEDULE
			GET lAutoScan SECTION "Schedule" ENTRY "AutoScan"
			GET lAutoClean SECTION "Schedule" ENTRY "AutoClean"
			GET lOnlyScan SECTION "Schedule" ENTRY "OnlyScan"
			GET nMinSpace SECTION "Schedule" ENTRY "MinSpace"
			GET nEvery SECTION "Schedule" ENTRY "Every"
			GET nMinutes SECTION "Schedule" ENTRY "EveryMinutes"
			GET nHours SECTION "Schedule" ENTRY "EveryHours"
			GET nMinutes2 SECTION "Schedule" ENTRY "EveryHoursMinutes"
			GET nDays SECTION "Schedule" ENTRY "EveryDays"
			GET nHour SECTION "Schedule" ENTRY "EveryDaysHour"
			GET nMinute SECTION "Schedule" ENTRY "EveryDaysMinute"
			GET nWeeks SECTION "Schedule" ENTRY "EveryWeeks"
			GET nDay SECTION "Schedule" ENTRY "EveryWeeksDay"
			GET nMonths SECTION "Schedule" ENTRY "EveryMonths"
			GET nDayMonths SECTION "Schedule" ENTRY "EveryMonthsDay"
			GET dNextScanDate SECTION "Schedule" ENTRY "NextScanDate"
			GET cNextScanTime SECTION "Schedule" ENTRY "NextScanTime"
#endif
		END INI

		if Len(aDrives) >= Len(aTmpDrv)
			Aeval(aTmpDrv, {|e,i| aDrives[i][1] := e[1]})
		else
			Aeval(aDrives, {|e,i| e[1] := aTmpDrv[i][1]})
		endif
	ENDIF

	IF DirChange( cPathCleaned ) > 0
		CreateFolder( cPathCleaned )
	ELSE
		DirChange( cPath )
	ENDIF

	aDrv_clone := ACLONE(aDrives)
	aMsk_clone := ACLONE(aMask)

	DEFINE WINDOW Form_2								;
		AT 0,0									;
		WIDTH 370								;
		HEIGHT IF(IsXPThemeActive(), 426, 416)					;
		TITLE PROGRAM								;
		ICON 'SYSTEM'								;
		NOMAXIMIZE NOSIZE							;
		TOPMOST									;
		ON RELEASE nPageNumber := GetProperty( "Form_2", "Tab_1", "Value" )	;
		FONT 'MS Sans Serif'							;
		SIZE 9

        ON KEY F1 ACTION DISPLAY HELP MAIN

        DEFINE STATUSBAR
		STATUSITEM cStatusMsg ACTION MsgAbout()
		CLOCK WIDTH 60 ACTION _Execute( GetActiveWindow(),,"CONTROL","date/time",,5 )
        END STATUSBAR

        DEFINE TAB Tab_1 	;
		AT 7,7 		;
		WIDTH 350 	;
		HEIGHT 326 	;
		VALUE 1		;
		ON CHANGE IF(Form_2.Tab_1.Value < 5, ( SetArrowCursor(GetControlHandle("Label_1", "Form_2")), ;
			IF(Form_2.Tab_1.Value < 4, DoMethod('Form_2', 'Grid_' + ltrim(str(Form_2.Tab_1.Value)), 'SetFocus'), ) ), ;
			SetHandCursor(GetControlHandle("Image_1", "Form_2")))

		PAGE '&Main'

			@ 32, 35 LABEL Label_1						;
				VALUE "&File(s) To Clean"				;
				WIDTH 100        					;
				HEIGHT 16						;
				TRANSPARENT						;
				FONT 'Arial'						;
				SIZE 10 BOLD

			@ 60, 15 GRID Grid_1 						;
				WIDTH 320 						;
				HEIGHT 250 						;
				HEADERS { '','Filename','Path','Size' }			;
				WIDTHS { 0, 100, 128, 53 }				;
				NOLINES 						;
				IMAGE aTrashImage					;
				MULTISELECT

		END PAGE

		IF LEN(aCleanFiles) > 0
			Form_2.Grid_1.DisableUpdate
			Aeval( aCleanFiles, { |e| Form_2.Grid_1.AddItem( { e[1], e[2], e[3], e[4] } ) } )
			Form_2.Grid_1.EnableUpdate
			Form_2.Grid_1.Value := {1}
		ENDIF

		PAGE '&Options'

			@ 32, 35 LABEL Label_2						;
				VALUE "&Drive(s) To Scan"				;
				WIDTH 105        					;
				HEIGHT 16						;
				TRANSPARENT						;
				FONT 'Arial'						;
				SIZE 10 BOLD

			@ 60, 15 GRID Grid_2 						;
				WIDTH 320 						;
				HEIGHT 158 						;
				HEADERS { '','Drive','Volume' } 			;
				WIDTHS { 0, 53, 220 } 					;
				ITEMS aDrives VALUE 1 					;
				TOOLTIP 'Double click for toggle of activate' 		;
				NOLINES 						;
				IMAGE aImage 						;
				ON DBLCLICK ToggleRefresh(2)

			Form_2.Grid_2.ColumnAutoFit(1)

			@ 225, 20 LABEL Label_21					;
				VALUE "&What do you want to do with found files?"	;
				WIDTH 300        					;
				HEIGHT 16						;
				TRANSPARENT						;
				FONT 'MS Sans Serif'					;
				SIZE 9 BOLD

			@ 244, 20 RADIOGROUP RadioGroup_1				;
				OPTIONS {aLabel[1], aLabel[2], aLabel[3]}		;
				VALUE nState WIDTH 180 SPACING 24			;
		                BACKCOLOR iif(IsXPThemeActive(), CLR_BACK, NIL)		;
				ON CHANGE ( nState := This.Value,			;
					SaveParameter("Options", "Delete", nState) )	;
				NOTABSTOP AUTOSIZE

			@ 292, 172 TEXTBOX Textbox_1					;
				VALUE cPathCleaned					;
				WIDTH 136     						;
				HEIGHT 22						;
				READONLY						;
				ON GOTFOCUS This.CaretPos := 1				;
				NOTABSTOP

			@ 292, 314 BUTTONEX ImageButton_1				;
				PICTURE 'Search'					;
				ADJUST							;
				ACTION IF( nState > 2,					;
					( iif(Empty(cTmpFld := GetFolder("Choose a folder below:", cPathCleaned)), , ;
					( cPathCleaned := cTmpFld + "\Cleaned",		;
					Form_2.Textbox_1.Value := cPathCleaned,	;
					SaveParameter("Options", "Path", cPathCleaned) ) ) ), PlayBeep() ) ;
				WIDTH 22 HEIGHT 22 NOTABSTOP

		END PAGE

		PAGE 'Scan &For...'

			@ 32, 35 LABEL Label_3						;
				VALUE "&Files To Scan For"				;
				WIDTH 115        					;
				HEIGHT 16						;
				TRANSPARENT						;
				FONT 'Arial'						;
				SIZE 10 BOLD

			@ 60, 15 GRID Grid_3 						;
				WIDTH 192 						; 
				HEIGHT 212 						; 
				HEADERS { '','Mask' } 					; 
				WIDTHS { 0, 145 } 					;
				ITEMS aMask VALUE 1 					;
				TOOLTIP 'Double click for toggle of activate' 		;
				NOLINES 						;
				IMAGE aImage 						;
				ON DBLCLICK ToggleRefresh(3)

			Form_2.Grid_3.ColumnAutoFit(1)

			@ 288, 20 CHECKBOX Checkbox_1					;
				CAPTION 'Empty &Windows "Temp" Folder'			;
				WIDTH 180        					;
				HEIGHT 16						;
		                BACKCOLOR IF(IsXPThemeActive(), CLR_BACK, NIL)		;
				TOOLTIP "To Clean Windows Temp Folder"			;
				ON CHANGE ( lTemp := !lTemp, SaveParameter("Scan", "Temp", lTemp) )

			@ 60, 227 BUTTONEX Button_5					;
				CAPTION '&Add New Extension'				;
				ACTION if(empty(cMask), PlayBeep(), ;
					(Form_2.Grid_3.AddItem( { 1, Lower(cMask) } ),	;
					aadd( aMsk_clone, { 1, Lower(cMask) } ),	;
					Form_2.Grid_3.Value := Len(aMsk_clone),		;
					Form_2.Grid_3.SetFocus,				;
					SaveParameter("Scan", "Masks", aMsk_clone)))	;
				WIDTH 107						;
				HEIGHT 24						;
				FLAT

			@ 92, 230 TEXTBOX Textbox_2					;
				VALUE cMask						;
				WIDTH 100     						;
				HEIGHT 22						;
				MAXLENGTH 30						;
				ON CHANGE ( cMask := Form_2.Textbox_2.Value ) 		;
				ON ENTER if(empty(cMask), PlayBeep(), 			;
					(Form_2.Grid_3.AddItem( { 1, Lower(cMask) } ),	;
					aadd( aMsk_clone, { 1, Lower(cMask) } ),	;
					Form_2.Grid_3.Value := Len(aMsk_clone),		;
					Form_2.Grid_3.SetFocus,				;
					SaveParameter("Scan", "Masks", aMsk_clone)))

			@ 140, 227 BUTTONEX Button_6					;
				CAPTION '&Remove Selected'				;
				ACTION if (empty(nItem := Form_2.Grid_3.Value), PlayBeep(), ;
					(Form_2.Grid_3.DeleteItem( nItem ),		;
					Form_2.Grid_3.Value := if(nItem > 1, nItem - 1, 1), ;
					Form_2.Grid_3.SetFocus,				;
					adel(aMsk_clone, nItem), asize(aMsk_clone, len(aMsk_clone)-1), ;
					SaveParameter("Scan", "Masks", aMsk_clone)))	;
				WIDTH 107 ; 
				HEIGHT 24 ;
				FLAT

		END PAGE

		Form_2.Checkbox_1.Value := lTemp

#ifdef SCHEDULE

		PAGE '&Schedule'

			IF IsXPThemeActive()
				@ 28, 10 FRAME TabFrame_4 WIDTH 330 HEIGHT 85 //OPAQUE
			ENDIF

			@ 38,20 CHECKBOX Checkbox_2 ; 
				CAPTION '&Have SafetyScan scan your drives automatically...' ; 
				WIDTH 260 ; 
				HEIGHT 16 ; 
				VALUE lAutoScan ;
				ON CHANGE ( lAutoScan := Form_2.Checkbox_2.Value, ;
					SaveParameter("Schedule", "AutoScan", lAutoScan), ;
					IF(lAutoScan, SetNextScan(), Form_2.StatusBar.Item(1) := cStatusMsg) )

			@ 63,20 CHECKBOX Checkbox_3 ; 
				CAPTION '&Automatically clean all found files after each timed scan' ; 
				WIDTH 280 ; 
				HEIGHT 16 ; 
				VALUE lAutoClean ;
				ON CHANGE ( lAutoClean := Form_2.Checkbox_3.Value, ;
					SaveParameter("Schedule", "AutoClean", lAutoClean) )

			@ 88,35 CHECKBOX Checkbox_4 ; 
				CAPTION '&Only scan if drive space is less than' ; 
				WIDTH 190 ; 
				HEIGHT 16 ; 
				VALUE lOnlyScan ;
				ON CHANGE ( lOnlyScan := Form_2.Checkbox_4.Value, ;
					SaveParameter("Schedule", "OnlyScan", lOnlyScan) )

			@ 85,227 SPINNER Spinner_1 ;
				RANGE 1, 999 ;
				VALUE nMinSpace ;
				WIDTH 48 ;
				HEIGHT 21 ;
				INCREMENT 10 ;
				ON CHANGE (nMinSpace := Form_2.Spinner_1.Value, ;
					SaveParameter("Schedule", "MinSpace", nMinSpace) )

			@ 89,280 LABEL Label_4 ;
				VALUE 'MBytes' ;
				WIDTH 40 ;
				HEIGHT 16

			@ 118,10 FRAME TabFrame_5 ;
				CAPTION 'Select a schedule' ;
				WIDTH 330 ;
				HEIGHT 200 //OPAQUE

			@ 140,20 RADIOGROUP RadioGroup_2 ;
				OPTIONS { "Every...", "Every...", "Every...", "Every...", "Every..." } ;
				VALUE nEvery ;
				WIDTH 60 ;
				SPACING 35 ;
				ON CHANGE ( nEvery := Form_2.RadioGroup_2.Value, ;
					SaveParameter("Schedule", "Every", nEvery), ;
					IF(lAutoScan, SetNextScan(), ) )

			@ 144,80 SPINNER Spinner_2 ;
				RANGE 1, 59 ;
				VALUE nMinutes ;
				WIDTH 36 ;
				HEIGHT 21 ;
				ON CHANGE ( nMinutes := Form_2.Spinner_2.Value, ;
					SaveParameter("Schedule", "EveryMinutes", nMinutes), ;
					IF(lAutoScan .AND. nEvery=1, SetNextScan(), ) )

			@ 148,123 LABEL Label_41 ;
				VALUE 'Minutes' ;
				WIDTH 60 ;
				HEIGHT 16

			@ 178,80 SPINNER Spinner_3 ;
				RANGE 1, 23 ;
				VALUE nHours ;
				WIDTH 36 ;
				HEIGHT 21 ;
				ON CHANGE ( nHours := Form_2.Spinner_3.Value, ;
					SaveParameter("Schedule", "EveryHours", nHours),;
					IF(lAutoScan .AND. nEvery=2, SetNextScan(), ) )

			@ 182,123 LABEL Label_42 ;
				VALUE 'Hours at' ;
				WIDTH 42 ;
				HEIGHT 16

			@ 178,172 SPINNER Spinner_4 ;
				RANGE 1, 59 ;
				VALUE nMinutes2 ;
				WIDTH 36 ;
				HEIGHT 21 ;
				INCREMENT 5 ;
				ON CHANGE ( nMinutes2 := Form_2.Spinner_4.Value, ;
					SaveParameter("Schedule", "EveryHoursMinutes", nMinutes2), ;
					IF(lAutoScan .AND. nEvery=2, SetNextScan(), ) )

			@ 182,214 LABEL Label_43 ;
				VALUE 'minutes after the hour' ;
				WIDTH 110 ;
				HEIGHT 16

			@ 212,80 SPINNER Spinner_5 ; 
				RANGE 1, 23 ; 
				VALUE nDays ; 
				WIDTH 36 ; 
				HEIGHT 21 ; 
				ON CHANGE ( nDays := Form_2.Spinner_5.Value, ;
					SaveParameter("Schedule", "EveryDays", nDays), ;
					IF(lAutoScan .AND. nEvery=3, SetNextScan(), ) )

			@ 216,123 LABEL Label_44 ;
				VALUE 'Days at the following time:' ;
				WIDTH 125 ;
				HEIGHT 16

			@ 212,250 TIMEPICKER Time_1 ;
				WIDTH 82 ;
				HEIGHT 21 ;
				TIMEFORMAT "HH:mm:ss" ;
				VALUE StrZero(nHour, 2)+":"+StrZero(nMinute, 2)+":00" ; 
				ON CHANGE ( nHour := Val(Left(Form_2.Time_1.Value, 2)), ;
					SaveParameter("Schedule", "EveryDaysHour", nHour), ;
					nMinute := Val(SubStr(Form_2.Time_1.Value, 4, 2)), ;
					SaveParameter("Schedule", "EveryDaysMinute", nMinute), ;
					IF(lAutoScan .AND. nEvery>2, SetNextScan(), ) )

			@ 247,80 SPINNER Spinner_6 ;
				RANGE 1, 55 ;
				VALUE nWeeks ;
				WIDTH 36 ;
				HEIGHT 21 ;
				ON CHANGE ( nWeeks := Form_2.Spinner_6.Value, ;
					SaveParameter("Schedule", "EveryWeeks", nWeeks), ;
					IF(lAutoScan .AND. nEvery=4, SetNextScan(), ) )

			@ 251,123 LABEL Label_45 ;
				VALUE 'Weeks starting on' ;
				WIDTH 90 ;
				HEIGHT 16

			@ 247,216 COMBOBOX ComboBox_1 ;
				ITEMS aDays() ;
				VALUE nDay ;
				WIDTH 116 ;
				HEIGHT 120 ;
				ON CHANGE ( nDay := Form_2.ComboBox_1.Value, ;
					SaveParameter("Schedule", "EveryWeeksDay", nDay), ;
					IF(lAutoScan .AND. nEvery=4, SetNextScan(), ) )

			@ 282,80 SPINNER Spinner_7 ;
				RANGE 1, 12 ; 
				VALUE nMonths ; 
				WIDTH 36 ; 
				HEIGHT 21 ; 
				ON CHANGE ( nMonths := Form_2.Spinner_7.Value, ;
					SaveParameter("Schedule", "EveryMonths", nMonths), ;
					IF(lAutoScan .AND. nEvery=5, SetNextScan(), ) )

			@ 286,123 LABEL Label_46 ;
				VALUE 'Months starting on day' ;
				WIDTH 110 ;
				HEIGHT 16

			@ 282,234 SPINNER Spinner_8 ;
				RANGE 1, 31 ;
				VALUE nDayMonths ;
				WIDTH 36 ;
				HEIGHT 21 ;
				ON CHANGE ( nDayMonths := Form_2.Spinner_8.Value, ;
					SaveParameter("Schedule", "EveryMonthsDay", nDayMonths), ;
					IF(lAutoScan .AND. nEvery=5, SetNextScan(), ) )

			@ 286,273 LABEL Label_47 ;
				VALUE 'of the month' ;
				WIDTH 60 ;
				HEIGHT 16

		END PAGE
#endif

		PAGE 'A&bout'

		IF !IsXPThemeActive()
			@ 33, 56 LABEL Label_5b				;
				VALUE PROGRAM + Right(VERSION, 6)	;
				WIDTH 250	        		;
				HEIGHT 36				;
				FONT 'Arial' SIZE 22 			;
				BOLD					;
				FONTCOLOR WHITE				;
				TRANSPARENT				;
				ACTION MsgAbout()
		ENDIF

			@ 32, 55 LABEL Label_5				;
				VALUE PROGRAM + Right(VERSION, 6)	;
				WIDTH 250	        		;
				HEIGHT 36				;
				FONT 'Arial' SIZE 22 			;
				BOLD					;
				TRANSPARENT

		IF !IsXPThemeActive()
			@ 73, 21 LABEL Label_6b				;
				VALUE "Copyright " +Chr(169)+ COPYRIGHT ;
				WIDTH 310        			;
				HEIGHT 16 CENTERALIGN			;
				FONTCOLOR WHITE				;
				TRANSPARENT				;
				ACTION MsgAbout()
		ENDIF

			@ 72, 20 LABEL Label_6				;
				VALUE "Copyright " +Chr(169)+ COPYRIGHT ;
				WIDTH 310        			;
				HEIGHT 16 CENTERALIGN			;
				TRANSPARENT

			@ 96, 15 FRAME TabFrame_7 WIDTH 320 HEIGHT 80 //OPAQUE

			@ 106, 30 LABEL Label_15				;
				VALUE "Author:   Grigory Filatov (Ukraine)"	;
				ACTION MsgAbout()				;
				AUTOSIZE

			@ 128, 33 LABEL Label_16				;
				VALUE "E-mail:"					;
				WIDTH 36        				;
				HEIGHT 16

			@ 127, 73 HYPERLINK Label_17				;
				VALUE "gfilatov@inbox.ru"			;
				ADDRESS "gfilatov@inbox.ru?cc=&bcc=" +	;
					"&subject=Safety%20Scan%20Feedback:" 	;
				WIDTH 100        				;
				HEIGHT 16					;
				TOOLTIP "E-mail me if you have any comments or suggestions"

			@ 150, 37 LABEL Label_18				;
				VALUE "Bugs:" 					;
				WIDTH 36        				;
				HEIGHT 16

			@ 149, 73 HYPERLINK Label_19				;
				VALUE "report" 					;
				ADDRESS "gfilatov@inbox.ru?cc=&bcc=" + 	;
					"&subject=Safety%20Scan%20Bug:" + 	;
					"&body="+GetReport()			;
				WIDTH 100        				;
				HEIGHT 16					;
				TOOLTIP "Send me a bug-report if you experience any problems"

			@ 120, 250 IMAGE Image_1 PICTURE IF(IsXPThemeActive(), "SYSTEMXP", IF(IsWinNT(), "SYSTEMNT", "SYSTEM")) ;
				WIDTH 32 HEIGHT 32 ;
				ACTION MsgAbout()

#ifndef __XHARBOUR__
			@ 190, 15 IMAGE Image_2 PICTURE "HARBOUR" WIDTH 320 HEIGHT 120 ;
				ACTION ShellExecute(0, "open", "https://harbour.github.io/")
#else
			@ 190, 15 IMAGE Image_2 PICTURE "XHARBOUR" WIDTH 320 HEIGHT 120 ;
				ACTION ShellExecute(0, "open", "http://www.xharbour.org/")
#endif
		END PAGE

        END TAB

        Form_2.StatusBar.Item(1) := cStatusMsg
        Form_2.Tab_1.Value := nPageNumber

        @ nBtnPos, 7 BUTTONEX Button_1 ; 
            CAPTION 'Clean &All' ; 
            ACTION ( Aeval( aCleanFiles, {|e| FileDelete(e[2], e[3]), nCleaned += e[5]} ), ;
			cStatusMsg := "Space Cleaned: " + ltrim(str(round(nCleaned / 1024, 0)))+"k", ;
			aCleanFiles := {}, nCleaned := 0, Form_2.StatusBar.Item(1) := cStatusMsg, ;
			Form_2.Grid_1.DeleteAllItems ) ; 
            WIDTH 74 ; 
            HEIGHT 24 ; 
            FLAT

        @ nBtnPos, 88 BUTTONEX Button_2 ; 
            CAPTION 'Clean &Selected' ; 
            ACTION FileSelectDelete() ;
            WIDTH 107 ; 
            HEIGHT 24 ;
            FLAT

        @ nBtnPos, 202 BUTTONEX Button_3 ; 
            CAPTION 'Scan &Now' ; 
            ACTION ScanNow() ; 
            WIDTH 74 ; 
            HEIGHT 24 ; 
            FLAT

        @ nBtnPos, 283 BUTTONEX Button_4 ; 
            CAPTION '&Hide' ; 
            ACTION Form_2.Release ; 
            WIDTH 74 ; 
            HEIGHT 24 ;
            FLAT

	END WINDOW

	CENTER WINDOW Form_2

	ACTIVATE WINDOW Form_2

   Else

	Form_2.Release

   EndIf

Return

*--------------------------------------------------------*
Static Function GetReport()
*--------------------------------------------------------*
Local cRet := "***%20Safety%20Scan%20BugReport%20***%0A%0A"

	cRet += "OPERATING%20SYSTEM%3A" + space( 3 ) + OS() + "%0A%0A"
	cRet += "AMOUNT OF RAM (MB)%3A" + space( 3 ) + Ltrim( Str( MemoryStatus(1) + 1 ) ) + "%0A%0A"
	cRet += "SWAP-FILE SIZE (MB)%3A" + space( 3 ) + Ltrim( Str( MemoryStatus(3) ) ) + "%0A%0A"
	cRet += "PROBLEM DESCRIPTION%3A"

Return cRet

*--------------------------------------------------------*
Static Procedure ToggleRefresh( nPage )
*--------------------------------------------------------*
	LOCAL nItem, nActItem

	nActItem := GetProperty( "Form_2", "Grid_" + Ltrim(Str(nPage)), "Value" )

	DO CASE

		CASE nPage = 2

			nItem := aDrv_clone[nActItem][1]
			aDrv_clone[nActItem][1] := IF(nItem = 1, 0, 1)

			SaveParameter("Options", "Drives", aDrv_clone)

			Form_2.Grid_2.DisableUpdate
			DELETE ITEM ALL FROM Grid_2 OF Form_2
			Aeval( aDrv_clone, { |e| ( Form_2.Grid_2.AddItem( { e[1], e[2], e[3] } ) ) } )
			Form_2.Grid_2.EnableUpdate

			Form_2.Grid_2.Value := nActItem

		CASE nPage = 3

			nItem := aMsk_clone[nActItem][1]
			aMsk_clone[nActItem][1] := IF(nItem = 1, 0, 1)

			SaveParameter("Scan", "Masks", aMsk_clone)

			Form_2.Grid_3.DisableUpdate
			DELETE ITEM ALL FROM Grid_3 OF Form_2
			Aeval( aMsk_clone, { |e| ( Form_2.Grid_3.AddItem( { e[1], e[2] } ) ) } )
			Form_2.Grid_3.EnableUpdate

			Form_2.Grid_3.Value := nActItem

	ENDCASE

Return

#ifdef SCHEDULE
*--------------------------------------------------------*
Static Procedure AutoScan()
*--------------------------------------------------------*

IF lAutoScan

	lSchedule := .T.

	IF Date() = dNextScanDate .AND. Substr(Time(), 1, 5) == Substr(cNextScanTime, 1, 5)

		cStartTime := SubStr( Time(), 1, 6 ) + "00"

		ScanNow()

		SetNextScan()

	ELSEIF dNextScanDate < Date() .OR. ( dNextScanDate <= Date() .AND. cNextScanTime < Time() )

		cStartTime := SubStr( Time(), 1, 6 ) + "00"

		SetNextScan()

	ENDIF

	lSchedule := .F.

ENDIF

Return

*--------------------------------------------------------*
Static Procedure SetNextScan()
*--------------------------------------------------------*
LOCAL nSeconds, dDate

	DO CASE
		CASE nEvery = 1
			nSeconds := TimeAsSeconds( cStartTime ) + 60 * nMinutes
			cNextScanTime := SubStr(TimeAsString( nSeconds ), 1, 6) + "00"
			dNextScanDate := Date() + SecondsAsDays( nSeconds )

		CASE nEvery = 2
			nSeconds := TimeAsSeconds( cStartTime ) + 3600 * nHours
			cNextScanTime := SubStr(TimeAsString( nSeconds ), 1, 3) + StrZero(nMinutes2, 2) + ":00"
			dNextScanDate := Date() + SecondsAsDays( nSeconds )

		CASE nEvery = 3
			cNextScanTime := TimeAsString( 3600 * nHour + 60 * nMinute )
			dNextScanDate := Date() + IF( cNextScanTime > Time(), 0, nDays )

		CASE nEvery = 4
			cNextScanTime := TimeAsString( 3600 * nHour + 60 * nMinute )
			dNextScanDate := Date() - ( DOW(Date()) - nDay ) + 7 * nWeeks

		CASE nEvery = 5
			cNextScanTime := TimeAsString( 3600 * nHour + 60 * nMinute )
			dDate := Date() + 30 * nMonths
			dNextScanDate := CTOD( ltrim(str(nDayMonths)) + "." + ;
				ltrim(str(Month(dDate))) + "." + ltrim(str(Year(dDate))) )

	ENDCASE

	IF IsWindowDefined( Form_2 )
		Form_2.StatusBar.Item(1) := "Next Scan: " + DTOC(dNextScanDate) + " " + cNextScanTime
	ENDIF

	SaveParameter("Schedule", "NextScanDate", dNextScanDate)
	SaveParameter("Schedule", "NextScanTime", cNextScanTime)

Return
#endif

*--------------------------------------------------------*
Static Procedure ScanNow()
*--------------------------------------------------------*
   local cDrive, cFindMask, aTempFiles := {}, aFind := {}
   local i, j, x2, x3
   private nTotal := 0

   aCleanFiles := {}

#ifdef SCHEDULE
   if IsWindowDefined( Form_2 )
#endif
      Form_2.Grid_1.DeleteAllItems
      DO EVENTS
#ifdef SCHEDULE
   endif
#endif

   for i := 1 to Len( aDrv_clone )

      if !EMPTY( aDrv_clone[ i ] [ 1 ] )

         cDrive := aDrv_clone[ i ] [ 2 ]

#ifdef SCHEDULE
         if !lSchedule .OR. !lOnlyScan .OR. ( lOnlyScan .AND. ;
            int( DISKSPACE(ASC(cDrive) - 64) / 1024 / 1024 ) < nMinSpace )
#endif
            for j := 1 to Len( aMsk_clone )

               if !EMPTY( aMsk_clone[ j ] [ 1 ] )

                  cFindMask := aMsk_clone[ j ] [ 2 ]
#ifdef SCHEDULE
               if IsWindowDefined( Form_2 )
#endif
                  Form_2.StatusBar.Item( 1 ) := "Scanning: " + cFindMask
                  INKEY(.4)
                  DO EVENTS
#ifdef SCHEDULE
            endif
#endif
                  Aeval( FindFiles( cFindMask, cDrive, NIL ), { |e| Aadd(aFind, {0, e[1], e[2], e[3], e[4]} ) } )
                  Aeval( aFind, { |e| x2 := e[2], x3 := e[3], ;
			if( Empty(Ascan(aCleanFiles, {|x| x[2] == x2 .and. x[3] == x3})), ;
			Aadd(aCleanFiles, {e[1], e[2], e[3], e[4], e[5]} ), ) } )

               endif
            next
#ifdef SCHEDULE
         endif
#endif
      endif

   next

   if lTemp
      Aeval( FindFiles( "*.*", GetE( "TEMP" ), NIL ), { |e| Aadd(aTempFiles, {0, e[1], e[2], e[3], e[4]} ) } )
      Aeval( aTempFiles, { |e| x2 := e[2], x3 := e[3], ;
		if( Empty(Ascan(aCleanFiles, {|x| x[2] == x2 .and. x[3] == x3})), ;
		Aadd(aCleanFiles, {e[1], e[2], e[3], e[4], e[5]} ), ) } )
   endif

   cStatusMsg := "Total Files: " + ltrim(str(round(nTotal / 1024, 0)))+"k"
#ifdef SCHEDULE
   if lSchedule .AND. lAutoClean
      Aeval( aCleanFiles, {|e| FileDelete(e[2], e[3])} )
      cStatusMsg := "Space Cleaned: " + ltrim(str(round(nTotal / 1024, 0)))+"k"
      aCleanFiles := {}
      if IsWindowDefined( Form_2 )
         Form_2.Grid_1.DeleteAllItems
      endif
   endif
   if IsWindowDefined( Form_2 )
#endif
      Form_2.StatusBar.Item(1) := cStatusMsg
      Form_2.Tab_1.Value := 1
      Form_2.Grid_1.Value := {1}
      Form_2.Grid_1.Setfocus
#ifdef SCHEDULE
   endif
#endif

Return

*--------------------------------------------------------*
Static Function FindFiles(cFileMask, cPath, aResult)
*--------------------------------------------------------*
   local aFiles := Directory( cPath + "\*.*", "D" )
   local aFindMask := Directory( cPath + "\" + cFileMask, "H" )
   local n

   if ProcName( 5 ) == "FINDFILES"
      return {}
   endif

   if aResult == NIL
      aResult := {}
   endif

#ifdef SCHEDULE
   if IsWindowDefined( Form_2 )
#endif
      Form_2.StatusBar.Item(1) := cPath + "\"
#ifdef SCHEDULE
   endif
#endif

   if Len( aFindMask ) > 0

      Aeval( aFindMask, { |e| Aadd( aResult, {e[1], cPath + "\", ltrim(str(round(e[2] / 1024, 0)))+"k", e[2]} ), nTotal += e[2] } )

#ifdef SCHEDULE
      if IsWindowDefined( Form_2 )
#endif
         Aeval( aFindMask, { |e| n := e[1], if( Empty(Ascan(aCleanFiles, {|t| t[2] == n .and. t[3] == cPath + "\"})), ;
		Form_2.Grid_1.AddItem( {0, e[1], cPath + "\", ltrim(str(round(e[2] / 1024, 0)))+"k"} ), nTotal -= e[2] ) } )
#ifdef SCHEDULE
      endif
#endif

   endif

   for n := 1 to Len( aFiles )

      if "D" $ aFiles[ n ][ 5 ] .and. ! ( aFiles[ n ][ 1 ] $ ".." )

         FindFiles( cFileMask, cPath + "\" + aFiles[ n ][ 1 ], aResult )

      endif

   next

Return aResult

*--------------------------------------------------------*
Static Function GetDrives()
*--------------------------------------------------------*
Local n, cDrv, cVolume := "", aDrive := {}

   For n := 1 To 26

	cDrv := Chr( 64 + n ) + ":"

	if GetDriveType( cDrv + "\" + Chr(0) ) > 1

		if n > 2
			cVolume := ""
			GetVolumeInformation( cDrv + "\", @cVolume )
		endif

		Aadd( aDrive, { if(n > 2, 1, 0), cDrv, "[" + cVolume + "]" } )

	endif

   Next

Return aDrive

*--------------------------------------------------------*
Static Procedure SaveParameter( cSection, cEntry, uValue )
*--------------------------------------------------------*

	BEGIN INI FILE Lower(cFileName) + '.ini'
		SET SECTION cSection ENTRY cEntry TO uValue
	END INI

return

*--------------------------------------------------------*
Static Procedure FileSelectDelete()
*--------------------------------------------------------*
LOCAL aSelect := GetProperty( "Form_2", "Grid_1", "Value" ), nTotal := 0

	if Len(aSelect) > 0

		Aeval( aSelect, {|e| FileDelete(aCleanFiles[e][2], aCleanFiles[e][3]), nTotal += aCleanFiles[e][5]} )
		cStatusMsg := "Space Cleaned: " + ltrim(str(round(nTotal / 1024, 0)))+"k"
		Form_2.StatusBar.Item(1) := cStatusMsg

		Aeval( aSelect, {|e, i| Adel(aCleanFiles, e - i + 1)} )
		Asize( aCleanFiles, Len(aCleanFiles) - Len(aSelect) )

		Form_2.Grid_1.DisableUpdate
		Form_2.Grid_1.DeleteAllItems
		Aeval( aCleanFiles, { |e| ( Form_2.Grid_1.AddItem( { e[1], e[2], e[3], e[4] } ) ) } )
		Form_2.Grid_1.EnableUpdate
		Form_2.Grid_1.Value := { IF(aSelect[1] > 1, aSelect[1] - 1, 1) }
		Form_2.Grid_1.Setfocus

	endif

return

*--------------------------------------------------------*
Static Procedure FileDelete( cFile, cPath )
*--------------------------------------------------------*

   IF GetFileAttributes(cPath + cFile) # 32
	SetFileAttributes(cPath + cFile, 32)
   ENDIF

   IF nState = 3 .AND. File(cPath + cFile) .AND. Lower(cPath + cFile) # Lower(cPathCleaned + "\" + cFile)

	COPY FILE (cPath + cFile) TO (cPathCleaned + "\" + cFile)
	Ferase( cPath + cFile )

   ELSEIF nState = 2 .AND. File(cPath + cFile)

	SendToRecycleBin( cPath + cFile + Chr(0) + Chr(0) )

   ELSEIF nState = 1 .OR. Lower(cPath + cFile) # Lower(cPathCleaned + "\" + cFile)

	Ferase( cPath + cFile )

   ENDIF

return

*--------------------------------------------------------*
Static Function MsgAbout()
*--------------------------------------------------------*
return MsgInfo( padc(PROGRAM + VERSION, 42) + CRLF + ;
	"Copyright " + Chr(169) + COPYRIGHT + CRLF + CRLF + ;
	padc(hb_compiler(), 40) + CRLF + padc(version(), 40) + CRLF + ;
	Left(MiniGuiVersion(), 38) + CRLF + CRLF + ;
	padc("This program is Freeware!", 38) + CRLF + ;
	padc("Copying is allowed!", 42), "About", , .F. )

*--------------------------------------------------------*
Static Procedure WinRun( lMode )
*--------------------------------------------------------*
   Local cRunName := Upper( GetModuleFileName( GetInstance() ) ) + " /STARTUP", ;
         cRunKey  := "Software\Microsoft\Windows\CurrentVersion\Run", ;
         cRegKey  := GETREGVAR( NIL, cRunKey, "SafetyScan" )

   if IsWinNT()
      EnablePermissions()
   endif

   IF lMode
      IF Empty(cRegKey) .OR. cRegKey # cRunName
         SETREGVAR( NIL, cRunKey, "SafetyScan", cRunName )
      ENDIF
   ELSE
      DELREGVAR( NIL, cRunKey, "SafetyScan" )
   ENDIF

return

*--------------------------------------------------------*
STATIC FUNCTION GETREGVAR(nKey, cRegKey, cSubKey, uValue)
*--------------------------------------------------------*
   LOCAL oReg, cValue

   nKey := IF(nKey == NIL, HKEY_CURRENT_USER, nKey)
   uValue := IF(uValue == NIL, "", uValue)
   oReg := TReg32():Create(nKey, cRegKey)
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
STATIC FUNCTION DELREGVAR(nKey, cRegKey, cSubKey)
*--------------------------------------------------------*
   LOCAL oReg, nValue

   nKey := IF(nKey == NIL, HKEY_CURRENT_USER, nKey)
   oReg := TReg32():New(nKey, cRegKey)
   nValue := oReg:Delete(cSubKey)
   oReg:Close()

RETURN nValue

*--------------------------------------------------------*
Function SecondsAsDays( nSeconds )
*--------------------------------------------------------*
Return INT(nSeconds / 86400)

*--------------------------------------------------------*
Function TimeAsSeconds( cTime )
*--------------------------------------------------------*
Return VAL(cTime) * 3600 + VAL(SUBSTR(cTime, 4)) * 60 + VAL(SUBSTR(cTime, 7))

*--------------------------------------------------------*
Function TimeAsString( nSeconds )
*--------------------------------------------------------*
Return StrZero(INT(Mod(nSeconds / 3600, 24)), 2, 0) + ":" + ;
	  StrZero(INT(Mod(nSeconds / 60, 60)), 2, 0) + ":" + ;
	  StrZero(INT(Mod(nSeconds, 60)), 2, 0)


#pragma BEGINDUMP

#include <windows.h>
#include "hbapi.h"

HB_FUNC( ENABLEPERMISSIONS )

{
   LUID tmpLuid;
   TOKEN_PRIVILEGES tkp, tkpNewButIgnored;
   DWORD lBufferNeeded;
   HANDLE hdlTokenHandle;
   HANDLE hdlProcessHandle = GetCurrentProcess();

   OpenProcessToken(hdlProcessHandle, TOKEN_ADJUST_PRIVILEGES | TOKEN_QUERY, &hdlTokenHandle);

   LookupPrivilegeValue(NULL, "SeSystemEnvironmentPrivilege", &tmpLuid);

   tkp.PrivilegeCount            = 1;
   tkp.Privileges[0].Luid        = tmpLuid;
   tkp.Privileges[0].Attributes  = SE_PRIVILEGE_ENABLED;

   AdjustTokenPrivileges(hdlTokenHandle, FALSE, &tkp, sizeof(tkpNewButIgnored), &tkpNewButIgnored, &lBufferNeeded);
}

/* Returns one of these:
#define DRIVE_UNKNOWN     0
#define DRIVE_NO_ROOT_DIR 1
#define DRIVE_REMOVABLE   2
#define DRIVE_FIXED       3
#define DRIVE_REMOTE      4
#define DRIVE_CDROM       5
#define DRIVE_RAMDISK     6
*/

HB_FUNC( GETDRIVETYPE )
{
   hb_retni( GetDriveType( (LPCSTR) hb_parc( 1 ) ) ) ;
}

#ifndef __XHARBOUR__
   #define ISBYREF( n )          HB_ISBYREF( n )
   #define ISNIL( n )            HB_ISNIL( n )
#endif

HB_FUNC( GETVOLUMEINFORMATION )
{
  char *VolumeNameBuffer     = (char *) hb_xgrab( MAX_PATH ) ;
  DWORD VolumeSerialNumber                              ;
  DWORD MaximumComponentLength                          ;
  DWORD FileSystemFlags                                 ;
  char *FileSystemNameBuffer = (char *) hb_xgrab( MAX_PATH )  ;
  BOOL bRet;

  bRet = GetVolumeInformation( ISNIL(1) ? NULL : (LPCTSTR) hb_parc(1) ,
                                  (LPTSTR) VolumeNameBuffer              ,
                                  MAX_PATH                               ,
                                  &VolumeSerialNumber                    ,
                                  &MaximumComponentLength                ,
                                  &FileSystemFlags                       ,
                                  (LPTSTR)FileSystemNameBuffer           ,
                                  MAX_PATH ) ;
  if ( bRet  )
  {
     if ( ISBYREF( 2 ) )  hb_storc ((char *) VolumeNameBuffer, 2 ) ;
     if ( ISBYREF( 3 ) )  hb_stornl( (LONG)  VolumeSerialNumber, 3 ) ;
     if ( ISBYREF( 4 ) )  hb_stornl( (LONG)  MaximumComponentLength, 4 ) ;
     if ( ISBYREF( 5 ) )  hb_stornl( (LONG)  FileSystemFlags, 5 );
     if ( ISBYREF( 6 ) )  hb_storc ((char *) FileSystemNameBuffer, 6 );
  }

  hb_retl(bRet);
  hb_xfree( VolumeNameBuffer );
  hb_xfree( FileSystemNameBuffer );
}

HB_FUNC( SETFILEATTRIBUTES )
{
   hb_retl( SetFileAttributes( (LPCSTR) hb_parc( 1 ), (DWORD) hb_parnl( 2 ) ) ) ;
}

HB_FUNC( GETFILEATTRIBUTES )
{
   hb_retnl( (LONG) GetFileAttributes( (LPCSTR) hb_parc( 1 ) ) ) ;
}

HB_FUNC( SENDTORECYCLEBIN )
{
	SHFILEOPSTRUCT sh;

	sh.hwnd   = GetActiveWindow();
	sh.wFunc  = FO_DELETE;
	sh.pFrom  = hb_parc(1);
	sh.pTo    = NULL;
	sh.fFlags = FOF_ALLOWUNDO | FOF_NOCONFIRMATION | FOF_SILENT | FOF_NOERRORUI;

	sh.fAnyOperationsAborted = FALSE;
	sh.hNameMappings         = NULL;
	sh.lpszProgressTitle     = NULL;
 
	SHFileOperation (&sh);
}

#ifdef __XHARBOUR__
/*
 * Harbour Project source code:
 * Additional date functions
 *
 * Copyright 1999 Jose Lalin <dezac@corevia.com>
 * www - https://harbour.github.io
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2, or (at your option)
 * any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this software; see the file COPYING.  If not, write to
 * the Free Software Foundation, Inc., 59 Temple Place, Suite 330,
 * Boston, MA 02111-1307 USA (or visit the web site http://www.gnu.org/).
 *
 * As a special exception, the Harbour Project gives permission for
 * additional uses of the text contained in its release of Harbour.
 *
 * The exception is that, if you link the Harbour libraries with other
 * files to produce an executable, this does not by itself cause the
 * resulting executable to be covered by the GNU General Public License.
 * Your use of that executable is in no way restricted on account of
 * linking the Harbour library code into it.
 *
 * This exception does not however invalidate any other reasons why
 * the executable file might be covered by the GNU General Public License.
 *
 * This exception applies only to the code released by the Harbour
 * Project under the name Harbour.  If you copy code from other
 * Harbour Project or Free Software Foundation releases into a copy of
 * Harbour, as the General Public License permits, the exception does
 * not apply to the code that you add in this way.  To avoid misleading
 * anyone as to the status of such modified files, you must delete
 * this exception notice from them.
 *
 * If you write modifications of your own for Harbour, it is your choice
 * whether to permit this exception to apply to your modifications.
 * If you do not wish that, delete this exception notice.
 *
 */

#include <ctype.h>
#include <time.h>

#include "hbapi.h"
#include "hbapiitm.h"
#include "hbapilng.h"
#include "hbdate.h"

HB_FUNC( ADAYS )
{
   HB_ITEM Return, Tmp;
   int i;

   Tmp.type = HB_IT_NIL;
   Return.type = HB_IT_NIL;

   hb_arrayNew( &Return, 0 );

   for( i = 0; i < 7; i++ )
   {
      hb_arrayAddForward( &Return, hb_itemPutC( &Tmp, ( char * ) hb_langDGetItem( HB_LANG_ITEM_BASE_DAY + i ) ));
   }

   hb_itemReturn( &Return );
}
#endif

#pragma ENDDUMP
