/*
 * MINIGUI - Harbour Win32 GUI library
 *
 * Copyright 2002-2011 Roberto Lopez <harbourminigui@gmail.com>
 * http://harbourminigui.googlepages.com/
 *
 * Copyright 2003-2011 Grigory Filatov <gfilatov@inbox.ru>
*/

ANNOUNCE RDDSYS

#include "minigui.ch"

#ifdef PRO
	#define PROGRAM 'Free Memory Pro'
#else
	#define PROGRAM 'Free Memory Lite'
#endif
#define VERSION		' version 1.0.9.5'
#define COPYRIGHT	' 2003-2011 Grigory Filatov'

#define NTRIM( n )	LTrim( Str( n ) )
#define DARKGREEN	{ 0 , 128 , 0 }
#define EWX_REBOOT	2

#ifdef PRO
	Set Proc To makefile.prg
#endif

Static oReg, nTotalMem, nPageNumber := 1, lMinimized := .f., lAuto := .t., lRecStart := .t., ;
	lHighCPUUsage := .f., cWaveFile := "sounds\optimize.wav", lSound := .t.
Static aIntCheck := {32, 16, 8, 4, 1}, nIntCheck := 3, nMinAmount, nMemAmount := 1, nRecAmount, ;
	nTabStyle := 1, lBusy := .f., cRunFile := 'MEMORY.EXE'
Static nMinCache := 0, nMaxCache := 0, nChunkSize := 0, lConservativeSwap, nConservative := 0, ;
	nLimitRAM, lLimit := .f., lWinRun := .F.
Static aRecLabel := {"Automatic", "User defined"}, aInterval := {"Lazy", "Slow", "Medium", "Fast", "Turbo"}, ;
	aProfile := {"Standard System", "Low Memory", "CD Writer", "Power User", "Multimedia", ;
		"Games", "Current Settings"}, aTab := {"Tabs", "Buttons", "Flat Buttons"}

Memvar aWinVer, cIniFileName, cSysFileIni
*--------------------------------------------------------*
Procedure Main( lStartUp )
*--------------------------------------------------------*
	Local aMenuBmps := {IF(lWinRun, "CHECK", "UNCHECK"), "", "REC", ;
		IF(lAuto, "UNCHECK", "CHECK"), "FREE",  "INFO", "", "EXIT"}
	Local cPath := cFilePath( GetExeFileName() )

	PUBLIC aWinVer := WindowsVersion()
	PUBLIC cIniFileName := Lower( cPath + "\" + cFileNoExt( GetExeFileName() ) ) + '.ini'
	PUBLIC cSysFileIni := GetWindowsFolder() + "\" + "SYSTEM.INI"

	cWaveFile := cPath + "\" + cWaveFile

	If !Empty(lStartUp) .AND. Upper(Substr(lStartUp, 2)) == "STARTUP" .OR. ;
		!Empty(GETREGVAR( NIL, "Software\Microsoft\Windows\CurrentVersion\Run", "FreeMemory" ))
		lWinRun := .T.
	EndIf

	SET MULTIPLE OFF

	nTotalMem := MemoryStatus(1) + 1
	nLimitRAM := nTotalMem

	nMinAmount := INT( nTotalMem / 8 )
	nRecAmount := INT( nTotalMem / 16 )

	IF FILE(cIniFileName)
		BEGIN INI FILE cIniFileName
			GET lMinimized SECTION "Options" ENTRY "Minimized"
			GET nIntCheck SECTION "Options" ENTRY "IntervalIndex"
			GET nMemAmount SECTION "Options" ENTRY "AmountIndex"
			GET nMinAmount SECTION "Options" ENTRY "MinMemory"
			GET nRecAmount SECTION "Options" ENTRY "RecoverAmount"
			GET lRecStart SECTION "Options" ENTRY "RecoverStartup"
			GET lAuto SECTION "Options" ENTRY "RecoverAuto"
			GET lHighCPUUsage SECTION "Options" ENTRY "RecoverHighCPUUsage"
			GET lSound SECTION "Options" ENTRY "RecoverSound"
			GET cWaveFile SECTION "Options" ENTRY "Sound"
			GET nTabStyle SECTION "Options" ENTRY "TabStyle"
		END INI
	ELSE
		BEGIN INI FILE cIniFileName
			SET SECTION "Options" ENTRY "Minimized" TO lMinimized
			SET SECTION "Options" ENTRY "IntervalIndex" TO nIntCheck
			SET SECTION "Options" ENTRY "AmountIndex" TO nMemAmount
			SET SECTION "Options" ENTRY "MinMemory" TO nMinAmount
			SET SECTION "Options" ENTRY "RecoverAmount" TO nRecAmount
			SET SECTION "Options" ENTRY "RecoverStartup" TO lRecStart
			SET SECTION "Options" ENTRY "RecoverAuto" TO lAuto
			SET SECTION "Options" ENTRY "RecoverHighCPUUsage" TO lHighCPUUsage
			SET SECTION "Options" ENTRY "RecoverSound" TO lSound
			SET SECTION "Options" ENTRY "Sound" TO cWaveFile
			SET SECTION "Options" ENTRY "TabStyle" TO nTabStyle
		END INI
	ENDIF

	oReg := InitCpu()

	DEFINE WINDOW Form_1 								;
		AT 0,0 									;
		WIDTH 0 HEIGHT 0 							;
		TITLE PROGRAM 								;
		MAIN NOSHOW 								;
		ON INIT ( SetMenuPicture( _HMG_xContextMenuHandle, aMenuBmps ),		;
			IF(lRecStart, AutoCheck(), ), IF(lMinimized, , MainForm()) )	;
		ON RELEASE OnClosePrg()							;
		NOTIFYICON 'ICON_1' 							;
		NOTIFYTOOLTIP PROGRAM 							;
		ON NOTIFYCLICK MainForm()

		DEFINE NOTIFY MENU 
			ITEM 'Auto&Run' ACTION ( lWinRun := !lWinRun, aMenuBmps[1] := IF(lWinRun, "CHECK", "UNCHECK"), ;
				SetMenuPicture( _HMG_xContextMenuHandle, aMenuBmps ), WinRun(lWinRun) )
			SEPARATOR	
			ITEM 'Recover Memory &Now'		ACTION MemRecovery( cRunFile + " -quiet " + ;
				NTRIM( IF(nMemAmount == 1, ROUND( ( nTotalMem / 2 - MemoryStatus(2) ) / 2, 0 ), INT( nRecAmount / 2 ) ) ) )
			ITEM '&Disable Auto Recover'		ACTION ( lAuto := !lAuto, aMenuBmps[4] := IF(lAuto, "UNCHECK", "CHECK"), ;
				SetMenuPicture( _HMG_xContextMenuHandle, aMenuBmps ) )
			ITEM '&Free Windows Clipboard memory'	ACTION ( OpenClipboard(Application.Handle), ;
				EmptyClipboard(), CloseClipboard() )
			ITEM 'A&bout...'			ACTION ShellAbout( "", PROGRAM + VERSION + CRLF + ;
				Chr(169) + COPYRIGHT, LoadTrayIcon(GetInstance(), "ICON_1", 32, 32) )
			SEPARATOR	
			ITEM 'E&xit' ACTION Form_1.Release
		END MENU

		DEFINE TIMER Timer_1 ;
			INTERVAL 1000 * aIntCheck[nIntCheck] ;
			ACTION AutoCheck()

	END WINDOW

	ACTIVATE WINDOW Form_1

Return

*--------------------------------------------------------*
Static Procedure OnClosePrg()
*--------------------------------------------------------*

#ifdef PRO
	Ferase(cRunFile)
#endif
	EndCpu()

Return

*--------------------------------------------------------*
Static Procedure MainForm()
*--------------------------------------------------------*
   Local nTop := 0, nLeft := 0, i, cFile := "", aCache := {}, ;
	lInitCache1 := .t., lInitCache2 := .t., lInitCache3 := .t., ;
	lMinCache, lMaxCache, lChunkSize, ;
	lDisable8dot3, lDisableLastAccessUpdate, lDisablePaging, lLargeCache, ;
	nFreeMem := MemoryStatus(2), nTotalPage := MemoryStatus(3), ;
	nFreePage := MemoryStatus(4), nMemLoad := MemoryStatus(5), ;
	nDiv1 := IF(nTotalMem > 512, 32, IF(nTotalMem > 256, 16, 8)), ;
	nDiv2 := IF(nTotalMem > 512, 16, IF(nTotalMem > 256, 8, 4)), ;
	nDiv3 := IF(nTotalMem > 512, 8, IF(nTotalMem > 256, 4, 2)), ;
	bClearClipboard := {|| OpenClipboard(Application.Handle), EmptyClipboard(), CloseClipboard() }

   if !IsWindowDefined( Form_2 )

	IF IsWinNT()
		lDisable8dot3 := !Empty(GETREGVAR( HKEY_LOCAL_MACHINE, ;
			"SYSTEM\CurrentControlSet\Control\FileSystem", ;
			"NtfsDisable8dot3NameCreation", 0 ))
		lDisableLastAccessUpdate := !Empty(GETREGVAR( HKEY_LOCAL_MACHINE, ;
			"SYSTEM\CurrentControlSet\Control\FileSystem", ;
			"NtfsDisableLastAccessUpdate", 0 ))
		lDisablePaging := !Empty(GETREGVAR( HKEY_LOCAL_MACHINE, ;
			"SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management", ;
			"DisablePagingExecutive", 0 ))
		lLargeCache := !Empty(GETREGVAR( HKEY_LOCAL_MACHINE, ;
			"SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management", ;
			"LargeSystemCache", 0 ))
	ELSE
		BEGIN INI FILE cSysFileIni
			GET nMinCache SECTION "vcache" ENTRY "MinFileCache" DEFAULT 0
			GET nMaxCache SECTION "vcache" ENTRY "MaxFileCache" DEFAULT 0
			GET nChunkSize SECTION "vcache" ENTRY "ChunkSize" DEFAULT 0
			GET nConservative SECTION "386Enh" ENTRY "ConservativeSwapfileUsage" DEFAULT 0
			lConservativeSwap := ! Empty(nConservative)
		END INI

		IF lConservativeSwap
			aCache := {{NTRIM( 0 ), NTRIM( INT( .75 * nTotalMem * 1024 ) ), "512"}, ;
				{NTRIM( 0 ), NTRIM( INT( nTotalMem / 2 * 1024 ) ), "256"}, ;
				{NTRIM( INT( nTotalMem / 2 * 1024 ) ), NTRIM( INT( nTotalMem / 2 * 1024 ) ), "256"}, ;
				{NTRIM( 0 ), NTRIM( INT( .9 * nTotalMem * 1024 ) ), "512"}, ;
				{NTRIM( INT( nTotalMem / 8 * 1024 ) ), NTRIM( INT( nTotalMem / 4 * 1024 ) ), "1024"}, ;
				{NTRIM( 0 ), NTRIM( INT( nTotalMem / 4 * 1024 ) ), "256"}}
		ELSE
			aCache := {{NTRIM( INT( nTotalMem / 64 * 1024 ) ), NTRIM( INT( nTotalMem / 4 * 1024 ) ), "512"}, ;
				{NTRIM( INT( nTotalMem / 64 * 1024 ) ), NTRIM( INT( nTotalMem / 8 * 1024 ) ), "256"}, ;
				{NTRIM( INT( nTotalMem / 8 * 1024 ) ), NTRIM( INT( nTotalMem / 8 * 1024 ) ), "256"}, ;
				{NTRIM( INT( nTotalMem / 8 * 1024 ) ), NTRIM( INT( nTotalMem / 4 * 1024 ) ), "512"}, ;
				{NTRIM( INT( nTotalMem / 32 * 1024 ) ), NTRIM( INT( nTotalMem / 10 * 1024 ) ), "1024"}, ;
				{NTRIM( INT( nTotalMem / 64 * 1024 ) ), NTRIM( INT( nTotalMem / 10 * 1024 ) ), "256"}}
		ENDIF

		Aadd( aCache, {NTRIM( nMinCache ), NTRIM( nMaxCache ), NTRIM( nChunkSize )} )
		lMinCache := !Empty(nMinCache)
		lMaxCache := !Empty(nMaxCache)
		lChunkSize := !Empty(nChunkSize)
	ENDIF

	BEGIN INI FILE cIniFileName
		GET nTop SECTION "Position" ENTRY "Top" DEFAULT 0
		GET nLeft SECTION "Position" ENTRY "Left" DEFAULT 0
	END INI

	DEFINE WINDOW Form_2					;
		AT nTop, nLeft					;
		WIDTH 370					;
		HEIGHT IF(IsXPThemeActive(), 412, 404)		;
		TITLE PROGRAM					;
		ICON 'ICON_1'					;
		NOMAXIMIZE NOSIZE				;
		TOPMOST						;
		ON RELEASE ( nPageNumber := GetProperty( "Form_2", "Tab_1", "Value" ), SaveIni(.T.) ) ;
		FONT 'MS Sans Serif'				;
		SIZE 9

		DEFINE MAIN MENU

		POPUP "&File"
			ITEM '&Recover RAM' + Chr(9) + 'Alt+R' ACTION MemRecovery( cRunFile + " -quiet " + ;
				NTRIM( IF(nMemAmount == 1, ROUND( ( nTotalMem / 2 - MemoryStatus(2) ) / 2, 0 ), INT( nRecAmount / 2 ) ) ) )
			ITEM '&Free Windows Clipboard memory' + Chr(9) + 'Alt+F' ACTION Eval( bClearClipboard )
			SEPARATOR
			ITEM '&Save Settings' + Chr(9) + 'Alt+S' ACTION SaveIni()
			SEPARATOR
			ITEM 'E&xit' + Chr(9) + 'Alt+X' ACTION ReleaseAllWindows()

		END POPUP

		POPUP "&View"
			ITEM '&Main' ACTION Form_2.Tab_1.Value := 1
			ITEM '&Options' ACTION Form_2.Tab_1.Value := 2
			ITEM '&Cache' ACTION Form_2.Tab_1.Value := 3
			ITEM '&Limit RAM' ACTION Form_2.Tab_1.Value := 4
		END POPUP

		POPUP "&Help"
			ITEM "A&bout" ACTION Form_2.Tab_1.Value := 5
		END POPUP

		END MENU

		ON KEY ALT+R ACTION MemRecovery( cRunFile + " -quiet " + ;
			NTRIM( IF(nMemAmount == 1, ROUND( ( nTotalMem / 2 - MemoryStatus(2) ) / 2, 0 ), INT( nRecAmount / 2 ) ) ) )
		ON KEY ALT+F ACTION Eval( bClearClipboard )
		ON KEY ALT+S ACTION SaveIni()
		ON KEY ALT+X ACTION ReleaseAllWindows()

		DEFINE TOOLBAR ToolBar_1 BUTTONSIZE 138, 18 FLAT BOTTOM RIGHTTEXT

			BUTTON Button_01  			;
				CAPTION PROGRAM			;
				PICTURE 'Dummy'			;
				ACTION _dummy()

			BUTTON Button_02			;
				CAPTION padc('&Hide', 12)	;
				PICTURE 'HIDE'			;
				ACTION Form_2.Release AUTOSIZE

			BUTTON Button_03			;
				CAPTION padc('&Exit', 12)	;
				PICTURE 'EXIT1'			;
				ACTION ReleaseAllWindows() AUTOSIZE

			BUTTON Button_04			;
				CAPTION '&Recover'		;
				PICTURE 'CLEAN'			;
				ACTION MemRecovery( cRunFile + " -quiet " + ;
					NTRIM( IF(nMemAmount == 1, ROUND( ( nTotalMem / 2 - MemoryStatus(2) ) / 2, 0 ), INT( nRecAmount / 2 ) ) ) ) ;
				AUTOSIZE

		END TOOLBAR

		Form_2.Button_01.Enabled := .f.

		IF nTabStyle == 2

			DEFINE TAB Tab_1					;
				AT 0,7 						;
				WIDTH 350 					;
				HEIGHT 326 					;
				VALUE 1 BUTTONS HOTTRACK NOTABSTOP		;
				ON CHANGE AutoCheck()

		ELSEIF nTabStyle == 3

			DEFINE TAB Tab_1					;
				AT 0,7 						;
				WIDTH 350 					;
				HEIGHT 326 					;
				VALUE 1 BUTTONS FLAT HOTTRACK NOTABSTOP		;
				ON CHANGE AutoCheck()
		ELSE

			DEFINE TAB Tab_1					;
				AT 0,7 						;
				WIDTH 350 					;
				HEIGHT 326 					;
				VALUE 1 HOTTRACK NOTABSTOP			;
				ON CHANGE AutoCheck()
		ENDIF

		PAGE '&Main'

			@ 30, 12 FRAME Frame_11 CAPTION "Free Memory" WIDTH 326 HEIGHT 136

			@ 50, 22 LABEL Label_11						;
				VALUE 'Free RAM: ' + NTRIM( nFreeMem ) +		;
				' MB (' + NTRIM( ROUND(100 * nFreeMem / nTotalMem, 0) ) + ' %)' ;
				AUTOSIZE						;
				FONT "Arial"						;
				SIZE 10							;
				BOLD UNDERLINE

			@ 76, 21 PROGRESSBAR Bar_11 					;
				RANGE 1, 100 						;
				VALUE ROUND(100 * nFreeMem / nTotalMem, 0) ;
				WIDTH 308 						;
				HEIGHT 20 						;
				BACKCOLOR BLACK						;
				FORECOLOR DARKGREEN

			@ 106, 22 LABEL Label_12					;
				VALUE 'Free Page File: ' + NTRIM( nFreePage ) + ;
				' MB (' + NTRIM( ROUND(100 * nFreePage / nTotalPage, 0) ) + ' %)' ;
				AUTOSIZE						;
				FONT "Arial"						;
				SIZE 10							;
				BOLD UNDERLINE

			@ 132, 21 PROGRESSBAR Bar_12 					;
				RANGE 1, 100 						;
				VALUE ROUND(100 * nFreePage / nTotalPage, 0)		;
				WIDTH 308 						;
				HEIGHT 20 						;
				BACKCOLOR BLACK						;
				FORECOLOR DARKGREEN
				
			@ 170, 12 FRAME Frame_12 CAPTION "Try to recover" WIDTH 326 HEIGHT 70

			@ 190, 22 LABEL Label_13					;
				VALUE "If free memory is below"				;
				AUTOSIZE

			DEFINE SLIDER Slider_1
				ROW 204
				COL 22
				RANGEMIN 1
				RANGEMAX nTotalMem / nDiv1
				VALUE nMinAmount / nDiv2
				WIDTH 240
				HEIGHT 28
				ONCHANGE ( nMinAmount := Form_2.Slider_1.Value * nDiv2, ;
					Form_2.Text_11.Value := NTRIM( nMinAmount ), SaveIni() )
				NOTICKS nTotalMem > 1024
			END SLIDER

			@ 208, 268 TEXTBOX Text_11					;
				VALUE NTRIM( nMinAmount )				;
				WIDTH 36        					;
				HEIGHT 18						;
				MAXLENGTH 6						;
				ON CHANGE ( nMinAmount := Val(Form_2.Text_11.Value), ;
					 Form_2.Slider_1.Value := nMinAmount / nDiv2 ) ;
				RIGHTALIGN

			@ 210, 310 LABEL Label_14					;
				VALUE "MB"						;
				AUTOSIZE

			@ 244, 12 FRAME Frame_13 CAPTION "Recover memory amount" WIDTH 326 HEIGHT 70

			@ 260, 19 RADIOGROUP RadioGroup_1				;
				OPTIONS aRecLabel					;
				VALUE nMemAmount WIDTH 80				;
				SPACING 23						;
				ON CHANGE ( nMemAmount := Form_2.RadioGroup_1.Value, SaveIni(), ;
					 Form_2.Slider_2.Enabled := nMemAmount > 1, ;
					 Form_2.Text_12.Enabled := nMemAmount > 1, ;
					 Form_2.Label_15.Enabled := nMemAmount > 1 )

			DEFINE SLIDER Slider_2
				ROW 270
				COL 102
				RANGEMIN 1
				RANGEMAX nTotalMem / nDiv1
				VALUE nRecAmount / nDiv3
				WIDTH 160
				HEIGHT 28
				ONCHANGE ( nRecAmount := Form_2.Slider_2.Value * nDiv3, ;
					Form_2.Text_12.Value := NTRIM( nRecAmount ), SaveIni() )
				NOTICKS nTotalMem > 1024
			END SLIDER

			@ 274, 268 TEXTBOX Text_12					;
				VALUE NTRIM( nRecAmount )				;
				WIDTH 36        					;
				HEIGHT 18						;
				MAXLENGTH 6						;
				ON CHANGE ( nRecAmount := Val(Form_2.Text_12.Value), ;
					 Form_2.Slider_2.Value := INT( nRecAmount / nDiv3 ) ) ;
				RIGHTALIGN

			@ 276, 310 LABEL Label_15					;
				VALUE "MB"						;
				AUTOSIZE

		END PAGE

		Form_2.Slider_2.Enabled := nMemAmount > 1
		Form_2.Text_12.Enabled := nMemAmount > 1
		Form_2.Label_15.Enabled := nMemAmount > 1

		PAGE '&Options'

			@ 30, 12 FRAME Frame_21 CAPTION "General" WIDTH 326 HEIGHT 186

			@ 52, 20 CHECKBOX Check_21					;
				CAPTION '&Start ' + PROGRAM + ' automatically at Windows Startup' ;
				WIDTH 312						;
				HEIGHT 16						;
				VALUE lWinRun						;
				ON CHANGE ( lWinRun := !lWinRun, WinRun(lWinRun) )

			@ 74, 20 CHECKBOX Check_22					;
				CAPTION 'Start ' + PROGRAM + ' &Minimized to the system tray' ;
				WIDTH 312						;
				HEIGHT 16						;
				VALUE lMinimized					;
				ON CHANGE ( lMinimized := !lMinimized, SaveIni() )

			@ 96, 20 CHECKBOX Check_23					;
				CAPTION '&Recover memory on startup of the program'	;
				WIDTH 312						;
				HEIGHT 16						;
				VALUE lRecStart						;
				ON CHANGE ( lRecStart := !lRecStart, SaveIni() )

			@ 118, 20 CHECKBOX Check_24					;
				CAPTION 'Recover memory &automatically when alarm level is reached' ;
				WIDTH 312						;
				HEIGHT 16						;
				VALUE lAuto						;
				ON CHANGE ( lAuto := !lAuto, SaveIni() )

			@ 140, 20 CHECKBOX Check_25					;
				CAPTION "Don't auto-recover on high CPU &usage"		;
				WIDTH 260						;
				HEIGHT 16						;
				VALUE !lHighCPUUsage					;
				ON CHANGE ( lHighCPUUsage := !lHighCPUUsage, SaveIni() )

			@ 162, 20 CHECKBOX Check_26					;
				CAPTION 'Use the memory recover &sound effect'		;
				WIDTH 260						;
				HEIGHT 16						;
				VALUE lSound						;
				ON CHANGE ( lSound := !lSound, SaveIni(),		;
					 Form_2.Text_21.Enabled := lSound,		;
					 Form_2.Button_21.Enabled := lSound )

			@ 184, 20 TEXTBOX Text_21					;
				VALUE cWaveFile						;
				WIDTH 284        					;
				HEIGHT 18						;
				ON CHANGE ( cWaveFile := Form_2.Text_21.Value, SaveIni() )

			@ 184, 310 BUTTON Button_21 ;
				CAPTION "..." ;
				ACTION ( cFile := Getfile( { {"Windows Audio Files", "*.wav"} }, ;
					"Select a Sound File", cFilePath(cWaveFile), .f., .t. ), ;
					IF(!EMPTY(cFile), Form_2.Text_21.Value := cFile, ) ) ;
				WIDTH 18 HEIGHT 20

			@ 220, 12 FRAME Frame_22 CAPTION "Checking" WIDTH 160 HEIGHT 64

			@ 250, 22 LABEL Label_21					;
				VALUE "Interval:"					;
				AUTOSIZE

			@ 245, 70 COMBOBOX Combo_21					;
				WIDTH 90						;
				HEIGHT 160						;
				ITEMS aInterval						;
				VALUE nIntCheck						;
				ON CHANGE ( nIntCheck := Form_2.Combo_21.Value, SaveIni(), ;
					Form_1.Timer_1.Release, _DefineTimer( "Timer_1", "Form_1", ;
					1000 * aIntCheck[nIntCheck], {||AutoCheck()} ) )

			@ 220, 178 FRAME Frame_23 CAPTION "Style" WIDTH 160 HEIGHT 64

			@ 250, 188 LABEL Label_22					;
				VALUE "Tab:"						;
				AUTOSIZE

			@ 245, 236 COMBOBOX Combo_22					;
				WIDTH 90						;
				HEIGHT 160						;
				ITEMS aTab						;
				VALUE nTabStyle						;
				ON CHANGE ( nTabStyle := Form_2.Combo_22.Value,		;
					SaveIni(), Form_2.Release, ProcessMessages(), MainForm() )

		END PAGE

		PAGE '&Cache'

			@ 30, 12 FRAME Frame_31 CAPTION "Windows 9x/ME Cache" WIDTH 326 HEIGHT 164

			@ 54, 20 LABEL Label_31						;
				VALUE "Cache &Profile:"					;
				AUTOSIZE

			@ 49, 150 COMBOBOX Combo_31					;
				WIDTH 148						;
				HEIGHT 160						;
				ITEMS aProfile						;
				VALUE 7							;
				ON CHANGE ( Form_2.Text_31.Value := aCache[Form_2.Combo_31.Value][1], ;
					Form_2.Text_32.Value := aCache[Form_2.Combo_31.Value][2], ;
					Form_2.Text_33.Value := aCache[Form_2.Combo_31.Value][3], ;
					SetCacheSize( 0 ) )

			@ 82, 20 LABEL Label_32						;
				VALUE "Mi&nimum Disk Cache:"				;
				AUTOSIZE

			@ 79, 150 TEXTBOX Text_31					;
				VALUE NTRIM( nMinCache )				;
				WIDTH 50        					;
				HEIGHT 18						;
				MAXLENGTH 6						;
				ON CHANGE IF(lInitCache1, lInitCache1 := .F.,		;
					SetCacheSize( 1, Form_2.Check_31.Value ) )	;
				RIGHTALIGN

			@ 82, 206 LABEL Label_35					;
				VALUE "KB"						;
				AUTOSIZE

			@ 82, 238 CHECKBOX Check_31					;
				CAPTION 'Enabled'					;
				WIDTH 60						;
				HEIGHT 16						;
				VALUE lMinCache						;
				ON CHANGE SetCacheSize( 1, Form_2.Check_31.Value )

			@ 110, 20 LABEL Label_33					;
				VALUE "Ma&ximum Disk Cache:"				;
				AUTOSIZE

			@ 107, 150 TEXTBOX Text_32					;
				VALUE NTRIM( nMaxCache )				;
				WIDTH 50        					;
				HEIGHT 18						;
				MAXLENGTH 6						;
				ON CHANGE IF(lInitCache2, lInitCache2 := .F.,		;
					SetCacheSize( 2, Form_2.Check_32.Value ) )	;
				RIGHTALIGN

			@ 110, 206 LABEL Label_36					;
				VALUE "KB"						;
				AUTOSIZE

			@ 110, 238 CHECKBOX Check_32					;
				CAPTION 'Enabled'					;
				WIDTH 60						;
				HEIGHT 16						;
				VALUE lMaxCache						;
				ON CHANGE SetCacheSize( 2, Form_2.Check_32.Value )

			@ 138, 20 LABEL Label_34					;
				VALUE "C&hunk Size:"					;
				AUTOSIZE

			@ 135, 150 TEXTBOX Text_33					;
				VALUE NTRIM( nChunkSize )				;
				WIDTH 50			        		;
				HEIGHT 18						;
				MAXLENGTH 4						;
				ON CHANGE IF(lInitCache3, lInitCache3 := .F.,		;
					SetCacheSize( 3, Form_2.Check_33.Value ) )	;
				RIGHTALIGN

			@ 138, 206 LABEL Label_37					;
				VALUE "B"						;
				AUTOSIZE

			@ 138, 238 CHECKBOX Check_33					;
				CAPTION 'Enabled'					;
				WIDTH 60						;
				HEIGHT 16						;
				VALUE lChunkSize					;
				ON CHANGE SetCacheSize( 3, Form_2.Check_33.Value )

			@ 166, 20 CHECKBOX Check_34					;
				CAPTION '&Conservative Swapfile Usage (Win98/ME with RAM 128MB+)' ;
				WIDTH 312						;
				HEIGHT 16						;
				VALUE lConservativeSwap					;
				ON CHANGE SetConservativeSwap( Form_2.Check_34.Value )

			@ 198, 12 FRAME Frame_32 CAPTION "Windows NT/2000/XP Cache" WIDTH 326 HEIGHT 116

			@ 214, 20 LABEL Label_38					;
				VALUE "Administrator Priviledges Required for these settings to be enabled" ;
				AUTOSIZE

			@ 238, 20 CHECKBOX Check_35					;
				CAPTION "Don't allow the NTFS to generate MS-DOS 8.3 file names" ;
				WIDTH 312						;
				HEIGHT 14						;
				VALUE lDisable8dot3					;
				ON CHANGE IF( Form_2.Check_35.Value,			;
					SETREGVAR( HKEY_LOCAL_MACHINE, "SYSTEM\CurrentControlSet\Control\FileSystem", ;
					"NtfsDisable8dot3NameCreation", 1 ),		;
					SETREGVAR( HKEY_LOCAL_MACHINE, "SYSTEM\CurrentControlSet\Control\FileSystem", ;
					"NtfsDisable8dot3NameCreation", 0 ) )

			@ 256, 20 CHECKBOX Check_36					;
				CAPTION "Don't allow the NTFS to update the Last Access Time Stamp" ;
				WIDTH 312						;
				HEIGHT 14						;
				VALUE lDisableLastAccessUpdate				;
				ON CHANGE IF( Form_2.Check_36.Value,			;
					SETREGVAR( HKEY_LOCAL_MACHINE, "SYSTEM\CurrentControlSet\Control\FileSystem", ;
					"NtfsDisableLastAccessUpdate", 1 ),		;
					SETREGVAR( HKEY_LOCAL_MACHINE, "SYSTEM\CurrentControlSet\Control\FileSystem", ;
					"NtfsDisableLastAccessUpdate", 0 ) )

			@ 274, 20 CHECKBOX Check_37					;
				CAPTION 'Keep the Windows NT core system in memory'	;
				WIDTH 312						;
				HEIGHT 14						;
				VALUE lDisablePaging					;
				ON CHANGE IF( Form_2.Check_37.Value,			;
					SETREGVAR( HKEY_LOCAL_MACHINE,			;
					"SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management", ;
					"DisablePagingExecutive", 1 ),			;
					SETREGVAR( HKEY_LOCAL_MACHINE,			;
					"SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management", ;
					"DisablePagingExecutive", 0 ) )

			@ 292, 20 CHECKBOX Check_38					;
				CAPTION 'Enable Large System Cache'			;
				WIDTH 312						;
				HEIGHT 14						;
				VALUE lLargeCache					;
				ON CHANGE IF( Form_2.Check_38.Value,			;
					SETREGVAR( HKEY_LOCAL_MACHINE,			;
					"SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management", ;
					"LargeSystemCache", 1 ),			;
					SETREGVAR( HKEY_LOCAL_MACHINE,			;
					"SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management", ;
					"LargeSystemCache", 0 ) )

		END PAGE

		PAGE '&Limit RAM'

			@ 40, 12 IMAGE Image_1 PICTURE IF(IsWinXPorLater(), IF(nTabStyle#1, "ALERT", "ALERT2"), "ALERT") ;
				WIDTH 32 HEIGHT 32 TRANSPARENT

			@ 32, 54 LABEL Label_41						;
				VALUE "You can use this tab to test applications by reducing " + ;
					"available physical memory. Reducing available RAM will " + ;
					"impact your system performance if reduced by an extreme amount!" ;
				WIDTH 290        					;
				HEIGHT 54

			IF ! IsXPThemeActive()
				@ 92, 12 FRAME Frame_41 WIDTH 326 HEIGHT 2

				@ 94, 12 LABEL Dummy_41 VALUE " "			;
					WIDTH 330        				;
					HEIGHT 7
			ENDIF

			@ 103, 12 CHECKBOX Check_41					;
				CAPTION '&Limit memory to'				;
				WIDTH 100						;
				HEIGHT 21						;
				VALUE lLimit						;
				ON CHANGE ( SetLimitRAM( Form_2.Check_41.Value ),	;
				Form_2.Spinner_41.Enabled := Form_2.Check_41.Value )

			@ 102, 112 SPINNER Spinner_41					;
				RANGE 32, 512						;
				VALUE nLimitRAM						;
				WIDTH 46						;
				HEIGHT 21						;
				INCREMENT 32						;
				ON CHANGE SetLimitRAM( NIL, Form_2.Spinner_41.Value )
 
			@ 106, 164 LABEL Label_42					;
				VALUE "MB"						;
				AUTOSIZE

			@ 134, 12 FRAME Frame_42 CAPTION "Memory Statistics" WIDTH 326 HEIGHT 140

			@ 154, 22 LABEL Label_43					;
				VALUE 'Free RAM: ' + NTRIM( nFreeMem ) +		;
				' MB (' + NTRIM( ROUND(100 * nFreeMem / nTotalMem, 0) ) + ' %)' ;
				AUTOSIZE						;
				FONT "Arial"						;
				SIZE 10							;
				BOLD UNDERLINE

			@ 182, 21 PROGRESSBAR Bar_41 					;
				RANGE 1, 100 						;
				VALUE ROUND(100 * nFreeMem / nTotalMem, 0)		;
				WIDTH 308 						;
				HEIGHT 20 						;
				BACKCOLOR BLACK						;
				FORECOLOR DARKGREEN

			@ 212, 22 LABEL Label_44					;
				VALUE 'Memory Load: ' + NTRIM( nMemLoad ) + ' %' 	;
				AUTOSIZE						;
				FONT "Arial"						;
				SIZE 10							;
				BOLD UNDERLINE

			@ 240, 21 PROGRESSBAR Bar_42 					;
				RANGE 1, 100 						;
				VALUE nMemLoad						;
				WIDTH 308 						;
				HEIGHT 20 						;
				BACKCOLOR BLACK						;
				FORECOLOR DARKGREEN

		END PAGE

		IF IsWinNT()
			Form_2.Label_41.Enabled := .f.
			Form_2.Check_41.Enabled := .f.
			Form_2.Label_42.Enabled := .f.
		ENDIF
		Form_2.Spinner_41.Enabled := Form_2.Check_41.Value

		PAGE 'A&bout'

			@ 32, 12 LABEL Label_51						;
				VALUE PROGRAM						;
				AUTOSIZE						;
				FONT 'Arial' SIZE 18 					;
				BOLD

			@ 32, 230 IMAGE Image_2 PICTURE IF(IsWinXPorLater(), IF(nTabStyle#1, "SYSTEM", "SYSTEM2"), "SYSTEM") ;
				WIDTH 32 HEIGHT 32 TRANSPARENT ;
				ACTION MsgAbout() ;
				ON MOUSEHOVER createbtnborder("Form_2", this.row-5, this.col+2, this.row+this.height+2, this.col+this.width+10) ;
				ON MOUSELEAVE erasewindow("Form_2")

			@ 64, 12 LABEL Label_52						;
				VALUE "Copyright " + Chr(169) + COPYRIGHT		;
				AUTOSIZE

			@ 90, 12 LABEL Label_53						;
				VALUE "Version:"					;
				AUTOSIZE

			@ 90, 70 LABEL Label_54						;
				VALUE right(VERSION, 7)					;
				AUTOSIZE

			@ 106, 12 LABEL Label_55					;
				VALUE "E-mail:"						;
				AUTOSIZE

			@ 106, 70 HYPERLINK Label_56					;
				VALUE "gfilatov@inbox.ru"				;
				ADDRESS "gfilatov@inbox.ru?cc=&bcc=" +			;
					"&subject=Free%20Memory%20Feedback:" 		;
				WIDTH 100        					;
				HEIGHT 16						;
				TOOLTIP "E-mail me if you have any comments or suggestions" ;
				HANDCURSOR

			@ 122, 12 LABEL Label_57					;
				VALUE "Bugs:" 						;
				AUTOSIZE

			@ 122, 70 HYPERLINK Label_58					;
				VALUE "report" 						;
				ADDRESS "gfilatov@inbox.ru?cc=&bcc=" +			;
					"&subject=Free%20Memory%20Bug:" +		;
					"&body=***%20Free%20Memory%20BUGREPORT%20***%0A%0A" + ;
					"OPERATING%20SYSTEM%3A%0A%0AAMOUNT OF RAM (MB)%3A%0A%0A" + ;
					"SWAP-FILE SIZE (MB)%3A%0A%0APROBLEM DESCRIPTION%3A" ;
				WIDTH 100        					;
				HEIGHT 16						;
				TOOLTIP "Send me a bug-report if you experience any problems" ;
				HANDCURSOR

			@ 144, 12 LABEL Label_59					;
				VALUE "Time since last reboot:"				;
				WIDTH 108        					;
				HEIGHT 16

			@ 144, 120 LABEL Label_60					;
				VALUE GetUpTime()					;
				WIDTH 180        					;
				HEIGHT 16

			IF !IsXPThemeActive()
				@ 165, 12 FRAME Frame_51 WIDTH 326 HEIGHT 2
			ENDIF

			@ 174, 12 LABEL Label_61					;
				VALUE "System Info"					;
				AUTOSIZE

			@ 198, 12 LABEL Label_62					;
				VALUE "Total Physical RAM:"				;
				AUTOSIZE

			@ 198, 130 LABEL Label_63					;
				VALUE NTRIM(nTotalMem) + " MB"				;
				AUTOSIZE

			@ 214, 12 LABEL Label_64					;
				VALUE "Total Page File:"				;
				AUTOSIZE

			@ 214, 130 LABEL Label_65					;
				VALUE NTRIM(MemoryStatus(3)) + " MB"			;
				AUTOSIZE

			@ 230, 12 LABEL Label_66					;
				VALUE "Used Page File:"					;
				AUTOSIZE

			@ 230, 130 LABEL Label_67					;
				VALUE NTRIM(Round(100 - MemoryStatus(4) *100 / MemoryStatus(3), 0)) + " %" ;
				AUTOSIZE

			@ 254, 12 LABEL Label_68					;
				VALUE "Operating System:"				;
				AUTOSIZE

			@ 254, 130 LABEL Label_69					;
				VALUE ALLTRIM( aWinVer[1] )				;
				AUTOSIZE

			@ 270, 12 LABEL Label_70					;
				VALUE "Addition:"					;
				AUTOSIZE

			@ 270, 130 LABEL Label_71					;
				VALUE ALLTRIM( aWinVer[2] )				;
				AUTOSIZE

			@ 286, 12 LABEL Label_72					;
				VALUE "Version:"					;
				AUTOSIZE

			@ 286, 130 LABEL Label_73					;
				VALUE aWinVer[3]					;
				AUTOSIZE

		END PAGE

		Form_2.Label_51.Enabled := .f.
		Form_2.Label_52.Enabled := .f.

		END TAB

		IF IsWinNT()
			Form_2.Frame_31.Enabled := .f.
			Form_2.Combo_31.Enabled := .f.
			For i := 31 To 37
				SetProperty( "Form_2", "Label_"+NTRIM(i), "Enabled", .f. )
			Next
			For i := 31 To 33
				SetProperty( "Form_2", "Text_"+NTRIM(i), "Enabled", .f. )
			Next
			For i := 31 To 34
				SetProperty( "Form_2", "Check_"+NTRIM(i), "Enabled", .f. )
			Next
		ELSE
			Form_2.Frame_32.Enabled := .f.
			Form_2.Label_38.Enabled := .f.
			For i := 35 To 38
				SetProperty( "Form_2", "Check_"+NTRIM(i), "Enabled", .f. )
			Next
		ENDIF

		Form_2.Tab_1.Value := nPageNumber

	END WINDOW

	IF EMPTY(nTop) .AND. EMPTY(nLeft) .OR. ( nTop < 0 .OR. nLeft < 0 )
		CENTER WINDOW Form_2
	ENDIF

	ACTIVATE WINDOW Form_2

   Else

	Form_2.Release

   EndIf

Return

*--------------------------------------------------------*
Static Procedure AutoCheck()
*--------------------------------------------------------*
  Local nFreeMem := MemoryStatus(2), ;
	nTotalPage := MemoryStatus(3), nFreePage := MemoryStatus(4), ;
	nMemLoad := MemoryStatus(5), cRun := " -quiet "

	Form_1.NotifyTooltip := SubStr(PROGRAM, 1, 11) + ": " + NTRIM( nFreeMem ) + ;
		" MB  Load: " + NTRIM( nMemLoad ) + "%"

	IF nFreeMem <= nMinAmount .AND. IF( lHighCPUUsage, .T., ( CpuUsage() < 75 ) )

		cRun += NTRIM( IF(nMemAmount == 1, ROUND( ( nTotalMem / 2 - nFreeMem ) / 2, 0 ), INT( nRecAmount / 2 ) ) )

		MemRecovery( cRunFile + cRun )

	ENDIF

	IF IsWindowDefined( Form_2 )
		nPageNumber := GetProperty( "Form_2", "Tab_1", "Value" )
		IF nPageNumber == 1

			Form_2.Label_11.Value := 'Free RAM: ' + NTRIM( nFreeMem ) + ;
				' MB (' + NTRIM( ROUND(100 * nFreeMem / nTotalMem, 0) ) + ' %)'
			Form_2.Bar_11.Value := ROUND(100 * nFreeMem / nTotalMem, 0)
			Form_2.Label_12.Value := 'Free Page File: ' + NTRIM( nFreePage ) + ;
				' MB (' + NTRIM( ROUND(100 * nFreePage / nTotalPage, 0) ) + ' %)'
			Form_2.Bar_12.Value := ROUND(100 * nFreePage / nTotalPage, 0)

		ELSEIF nPageNumber == 4

			Form_2.Label_43.Value := 'Free RAM: ' + NTRIM( nFreeMem ) + ;
				' MB (' + NTRIM( ROUND(100 * nFreeMem / nTotalMem, 0) ) + ' %)'
			Form_2.Bar_41.Value := ROUND(100 * nFreeMem / nTotalMem, 0)
			Form_2.Label_44.Value := 'Memory Load: ' + NTRIM( nMemLoad ) + ' %'
			Form_2.Bar_42.Value := nMemLoad

		ELSEIF nPageNumber == 5

			Form_2.Label_60.Value := GetUpTime()
			Form_2.Label_67.Value := NTRIM(Round(100 - nFreePage * 100 / nTotalPage, 0)) + " %"

		ENDIF
	ENDIF

Return

*--------------------------------------------------------*
Static Procedure MemRecovery( cCommand )
*--------------------------------------------------------*
  IF !lBusy
	lBusy := .t.

	Form_1.NotifyIcon := 'ICON_2'

	IF FILE( cWaveFile ) .AND. lSound
		PLAY WAVE ( cWaveFile )
	ENDIF

	If !FILE( cRunFile )
#ifdef PRO
		MkFile( cRunFile )
#else
		MsgStop( cRunFile + ' is not found', 'Stop!', , .F. )
#endif
	EndIf

	If FILE( cRunFile )
#ifdef PRO
		EXECUTE FILE cCommand WAIT HIDE
#else
		EXECUTE FILE cCommand WAIT MINIMIZE
#endif
		DO EVENTS
	EndIf

	Form_1.NotifyTooltip := SubStr(PROGRAM, 1, 11) + ": " + NTRIM( MemoryStatus(2) ) + ;
		" MB  Mem Load: " + NTRIM( MemoryStatus(5) ) + "%"

	Form_1.NotifyIcon := 'ICON_1'

	lBusy := .f.
  ENDIF

Return

*--------------------------------------------------------*
Static Procedure SaveIni( lPosition )
*--------------------------------------------------------*

	DEFAULT lPosition := .F.

	BEGIN INI FILE cIniFileName
		IF lPosition
			SET SECTION "Position" ENTRY "Top" TO Form_2.Row
			SET SECTION "Position" ENTRY "Left" TO Form_2.Col
		ELSE
			SET SECTION "Options" ENTRY "Minimized" TO lMinimized
			SET SECTION "Options" ENTRY "IntervalIndex" TO nIntCheck
			SET SECTION "Options" ENTRY "AmountIndex" TO nMemAmount
			SET SECTION "Options" ENTRY "MinMemory" TO nMinAmount
			SET SECTION "Options" ENTRY "RecoverAmount" TO nRecAmount
			SET SECTION "Options" ENTRY "RecoverStartup" TO lRecStart
			SET SECTION "Options" ENTRY "RecoverAuto" TO lAuto
			SET SECTION "Options" ENTRY "RecoverHighCPUUsage" TO lHighCPUUsage
			SET SECTION "Options" ENTRY "RecoverSound" TO lSound
			SET SECTION "Options" ENTRY "Sound" TO cWaveFile
			SET SECTION "Options" ENTRY "TabStyle" TO nTabStyle
		ENDIF
	END INI

Return

*--------------------------------------------------------*
Static Procedure SetCacheSize( nCache, lEnabled )
*--------------------------------------------------------*

  IF nCache == 1

	BEGIN INI FILE cSysFileIni
		IF lEnabled
			SET SECTION "vcache" ENTRY "MinFileCache" TO Form_2.Text_31.Value
		ELSE
			DEL SECTION "vcache" ENTRY "MinFileCache"
		ENDIF
	END INI

  ELSEIF nCache == 2

	BEGIN INI FILE cSysFileIni
		IF lEnabled
			SET SECTION "vcache" ENTRY "MaxFileCache" TO Form_2.Text_32.Value
		ELSE
			DEL SECTION "vcache" ENTRY "MaxFileCache"
		ENDIF
	END INI

  ELSEIF nCache == 3

	BEGIN INI FILE cSysFileIni
		IF lEnabled
			SET SECTION "vcache" ENTRY "ChunkSize" TO Form_2.Text_33.Value
		ELSE
			DEL SECTION "vcache" ENTRY "ChunkSize"
		ENDIF
	END INI

  ELSE

	BEGIN INI FILE cSysFileIni
		SET SECTION "vcache" ENTRY "MinFileCache" TO Form_2.Text_31.Value
		SET SECTION "vcache" ENTRY "MaxFileCache" TO Form_2.Text_32.Value
		SET SECTION "vcache" ENTRY "ChunkSize" TO Form_2.Text_33.Value
	END INI

  ENDIF

  IF EMPTY(nCache)

	IF MsgYesNo( "Reboot your computer for the changes to the cache settings to take place?", PROGRAM )
		ExitWindows( EWX_REBOOT )
	ENDIF

  ENDIF

Return

*--------------------------------------------------------*
Static Procedure SetConservativeSwap( lEnabled )
*--------------------------------------------------------*

  lConservativeSwap := lEnabled

  IF lEnabled

	BEGIN INI FILE cSysFileIni
		SET SECTION "386Enh" ENTRY "ConservativeSwapfileUsage" TO 1
	END INI

  ELSE

	BEGIN INI FILE cSysFileIni
		DEL SECTION "386Enh" ENTRY "ConservativeSwapfileUsage"
	END INI

  ENDIF

Return

*--------------------------------------------------------*
Static Procedure SetLimitRAM( lEnabled, nLimit )
*--------------------------------------------------------*

  IF Valtype(lEnabled) == "L"
	lLimit := lEnabled
	IF !lLimit
		BEGIN INI FILE cSysFileIni
			DEL SECTION "386Enh" ENTRY "MaxPhysPage"
		END INI
	ENDIF
  ELSEIF nLimit < nTotalMem
	nLimitRAM := nLimit
	BEGIN INI FILE cSysFileIni
		SET SECTION "386Enh" ENTRY "MaxPhysPage" TO nToBinary(nLimit)
	END INI
  ENDIF

Return

*--------------------------------------------------------*
Static Function nToBinary( nValue )
*--------------------------------------------------------*
  Local cRet := ""

	DO CASE
		CASE nValue = 32  ; cRet := "1"
		CASE nValue = 64  ; cRet := "3"
		CASE nValue = 96  ; cRet := "5"
		CASE nValue = 128 ; cRet := "7"
		CASE nValue = 160 ; cRet := "9"
		CASE nValue = 192 ; cRet := "B"
		CASE nValue = 224 ; cRet := "D"
		CASE nValue = 256 ; cRet := "F"
		CASE nValue = 288 ; cRet := "11"
		CASE nValue = 320 ; cRet := "13"
		CASE nValue = 352 ; cRet := "15"
		CASE nValue = 384 ; cRet := "17"
		CASE nValue = 416 ; cRet := "19"
		CASE nValue = 448 ; cRet := "1B"
		CASE nValue = 480 ; cRet := "1D"
		CASE nValue = 512 ; cRet := "1F"
	ENDCASE

Return cRet + "FFF"

*--------------------------------------------------------*
Static Function MsgAbout()
*--------------------------------------------------------*

return MsgInfo( padc(PROGRAM + VERSION, 42) + CRLF + ;
	"Copyright " + Chr(169) + COPYRIGHT + CRLF + CRLF + ;
	hb_compiler() + CRLF + ;
	version() + CRLF + ;
	SubStr(MiniGuiVersion(), 1, 38) + CRLF + CRLF + ;
	padc("This program is Freeware!", 32) + CRLF + ;
	padc("Copying is allowed!", 36), "About", , .F. )

*--------------------------------------------------------*
Static Function GetUpTime()
*--------------------------------------------------------*
   Local t := Int( GetStartTime() / 1000 )
   Local nDAYS, nHRS, nMINS, nSECS

   nDAYS := Int( t / ( 3600 * 24 ) )
   nHRS  := int( ( t - nDAYS * 3600 * 24 ) / 3600 )
   nMINS := int( ( t - nDAYS * 3600 * 24 - nHRS * 3600) / 60 )
   nSECS := t - nDAYS * 3600 * 24 - nHRS * 3600 - nMINS * 60

Return strzero( nDAYS, 2 ) + "d, " + strzero( nHRS, 2 ) + ":" + ;
	strzero( nMINS, 2 ) + ":" + strzero( nSECS, 2 ) + "  (Days, hrs:mins:secs)"

*--------------------------------------------------------*
Procedure SetMenuPicture( hMenu, aItemBmps )
*--------------------------------------------------------*
   Local hImage

   Aeval( aItemBmps, { |e, i| hImage := LoadItemPicture(e), ;
	SetMenuItemBitmaps( hMenu, GetMenuItemId( hMenu, i-1 ), 0, hImage, hImage ) } )
Return

*--------------------------------------------------------*
Procedure CreateBtnBorder( cWin,t,l,b,r )
*--------------------------------------------------------*
   CursorHand()

   DRAW PANEL		;
	IN WINDOW &cWin	;
	AT t,l		;
	TO b,r

Return

*--------------------------------------------------------*
Procedure ExitWindows( nFlag )
*--------------------------------------------------------*

   if IsWinNT()
      EnablePermissions()
   endif

   if ExitWindowsEx(nFlag, 0)
	Form_1.Release
   endif

Return

*--------------------------------------------------------*
Static Function InitCpu()
*--------------------------------------------------------*
   Local oReg, uVar

   If !IsWinNT()
      oReg := TReg32():New(HKEY_DYN_DATA,"PerfStats\StartStat")
      uVar := oReg:Get("KERNEL\CPUUsage","")
      oReg:Close()
      oReg := TReg32():New(HKEY_DYN_DATA,"PerfStats\StatData")
   Endif

Return oReg

*--------------------------------------------------------*
Static Procedure EndCpu()
*--------------------------------------------------------*
   Local uVar

   If !IsWinNT()
      oReg:Close()
      oReg := TReg32():New(HKEY_DYN_DATA,"PerfStats\StopStat")
      uVar := oReg:Get("KERNEL\CPUUsage","")
      oReg:Close()
   Endif

Return

*--------------------------------------------------------*
Static Function CpuUsage()
*--------------------------------------------------------*
   Local uVar := chr(0)
   Local uuVar := chr(0)

   If _HMG_IsXPorLater
      uVar := GetCPUUsage()
      Return uVar
   ElseIf !IsWinNT()
      uVar := oReg:Get("KERNEL\CPUUsage","00")
   Else
      oReg := TReg32():New(HKEY_LOCAL_MACHINE,;
            "Software\Microsoft\Windows NT\CurrentVersion\Perflib\009")
      uuVar := oReg:Get("Counters","")
      uVar := Str(oReg:Get("% Processor Time",0))
      oReg:Close()
   Endif

Return Asc(uVar)

*--------------------------------------------------------*
Static Procedure WinRun( lMode )
*--------------------------------------------------------*
   Local cRunName := Upper( GetModuleFileName( GetInstance() ) ) + " /STARTUP", ;
         cRunKey  := "Software\Microsoft\Windows\CurrentVersion\Run", ;
         cRegKey  := GETREGVAR( NIL, cRunKey, "FreeMemory" )

   if IsWinNT()
      EnablePermissions()
   endif

   IF lMode
      IF Empty(cRegKey) .OR. cRegKey # cRunName
         SETREGVAR( NIL, cRunKey, "FreeMemory", cRunName )
      ENDIF
   ELSE
      DELREGVAR( NIL, cRunKey, "FreeMemory" )
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


#pragma BEGINDUMP

#include <windows.h>
#include "hbapi.h"
#include "hbapiitm.h"

#define INITIAL_BUFFER_SIZE			1024
#define INCREMENT_BUFFER_SIZE			1024

#define PROCESSOR_OBJECT_INDEX			238
#define PROCESSOR_TIME_COUNTER_INDEX		6
#define PROCESS_OBJECT_INDEX			230
#define PROCESS_ID_COUNTER_INDEX		784

const WCHAR	wcNameOfInstanceTotal[] = L"_Total";

typedef struct
{
	LARGE_INTEGER Value;
	LARGE_INTEGER Timer;
}_VALUE;

void GetCPUCounterValue(_VALUE* value)
{
	char*	pPerfBuffer;
	char	Key[16];
	DWORD	BufferSize = INITIAL_BUFFER_SIZE;
	PPERF_OBJECT_TYPE pObject;
	PPERF_INSTANCE_DEFINITION	pInstance;
	PPERF_COUNTER_BLOCK		pCounterBlock;
	WCHAR* wcInstanceName;
	PPERF_COUNTER_DEFINITION pCounter;
	LARGE_INTEGER liValue;
	UINT i;
	int ii;

	sprintf(Key,"%d",PROCESSOR_OBJECT_INDEX);

	pPerfBuffer = (char*)malloc(BufferSize);
	memset(pPerfBuffer, 0, BufferSize);
	
	while( RegQueryValueEx( HKEY_PERFORMANCE_DATA,
							Key,
							NULL,
							NULL,
							(LPBYTE)pPerfBuffer,
							&BufferSize ) == ERROR_MORE_DATA)
	{
		BufferSize += INCREMENT_BUFFER_SIZE;
		pPerfBuffer = (char*)realloc(pPerfBuffer, BufferSize);
		memset(pPerfBuffer, 0, BufferSize);
	}

	pObject = (PPERF_OBJECT_TYPE)(pPerfBuffer + ((PPERF_DATA_BLOCK)pPerfBuffer)->HeaderLength);
	for(i=0; i<(((PPERF_DATA_BLOCK)pPerfBuffer)->NumObjectTypes); i++)
	{
		if (pObject->ObjectNameTitleIndex == PROCESSOR_OBJECT_INDEX)
			break;
		pObject = (PPERF_OBJECT_TYPE)((char*)pObject + pObject->TotalByteLength);
	}

	pInstance = (PPERF_INSTANCE_DEFINITION)((char*)pObject + pObject->DefinitionLength);
	for(ii = 0; ii<pObject->NumInstances; ii++)
	{
		pCounterBlock = (PPERF_COUNTER_BLOCK)((char*)pInstance + pInstance->ByteLength);

		wcInstanceName = (wchar_t*)((char*)pInstance+pInstance->NameOffset);
		if(!wcscmp(wcInstanceName, wcNameOfInstanceTotal))
			break;

		pInstance = (PPERF_INSTANCE_DEFINITION)((char*)pCounterBlock + pCounterBlock->ByteLength);
	}
		
	pCounter = (PPERF_COUNTER_DEFINITION)((char*)pObject + pObject->HeaderLength);
	for(i = 0; i<pObject->NumCounters; i++)
	{
		if(pCounter->CounterNameTitleIndex == PROCESSOR_TIME_COUNTER_INDEX)
			break;
		pCounter = (PPERF_COUNTER_DEFINITION)((char*)pCounter + pCounter->ByteLength);
	}

	memcpy(&liValue, ((char*)pCounterBlock + pCounter->CounterOffset), sizeof(LARGE_INTEGER));

	value->Timer = ((PPERF_DATA_BLOCK)pPerfBuffer)->PerfTime100nSec;
	value->Value = liValue;
	
	free(pPerfBuffer);
}

HB_FUNC( GETCPUUSAGE )
{
	static _VALUE oldValue = {0,0};
	static _VALUE newValue = {0,0};

	double DeltaTimer;
	double DeltaValue;
	double Value;

	GetCPUCounterValue(&newValue);

	DeltaTimer = (double)newValue.Timer.QuadPart - (double)oldValue.Timer.QuadPart;
	DeltaValue = (double)newValue.Value.QuadPart - (double)oldValue.Value.QuadPart;

	oldValue = newValue;

	Value = (1.0 - DeltaValue/DeltaTimer)*100;
	if(Value<0)
		Value = 0;

	hb_retni( (int)(Value+0.5) );
}

HB_FUNC ( SETMENUITEMBITMAPS )
{
  hb_retl( SetMenuItemBitmaps( (HMENU) hb_parnl(1), hb_parni(2), hb_parni(3), (HBITMAP) hb_parnl(4), (HBITMAP) hb_parnl(5) ) );
}

HB_FUNC ( GETMENUITEMID )
{
  hb_retni( GetMenuItemID( (HMENU) hb_parnl(1), hb_parni(2) ) );
}

HB_FUNC( LOADITEMPICTURE )
{
  HWND himage;

  himage = (HWND) LoadImage( 0, hb_parc(1), IMAGE_BITMAP, 0, 0, LR_LOADFROMFILE | LR_LOADMAP3DCOLORS | LR_LOADTRANSPARENT );

  if (himage==NULL)
    {
      himage = (HWND) LoadImage( GetModuleHandle(NULL), hb_parc(1), IMAGE_BITMAP, 0, 0, LR_LOADMAP3DCOLORS | LR_LOADTRANSPARENT );
    }

  hb_retnl( (LONG) himage );
}

HB_FUNC( MEMORYSTATUS )
{
      MEMORYSTATUS mst;
      long n = hb_parnl(1);

      mst.dwLength = sizeof( MEMORYSTATUS );
      GlobalMemoryStatus( &mst );

      switch( n )
      {
         case 1:  hb_retnl( mst.dwTotalPhys / 1024 / 1024 ) ; break;
         case 2:  hb_retnl( mst.dwAvailPhys / 1024 / 1024 ) ; break;
         case 3:  hb_retnl( mst.dwTotalPageFile / (1024*1024) ) ; break;
         case 4:  hb_retnl( mst.dwAvailPageFile / (1024*1024) ) ; break;
         case 5:  hb_retnl( mst.dwMemoryLoad ) ; break;
         default: hb_retnl( 0 ) ;
      }
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

HB_FUNC ( OPENCLIPBOARD )
{
   hb_retl( OpenClipboard( ( HWND ) hb_parnl( 1 ) ) );
}

HB_FUNC ( CLOSECLIPBOARD )
{
   hb_retl( CloseClipboard() );
}

HB_FUNC ( EMPTYCLIPBOARD )
{
   hb_retl( EmptyClipboard() );
}

HB_FUNC( GETSTARTTIME )
{
   hb_retnl( (LONG) timeGetTime() ) ;
}

#pragma ENDDUMP
