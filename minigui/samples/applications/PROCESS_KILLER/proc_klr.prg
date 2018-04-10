/*
 * MiniGUI Process Killer Demo
 *
 * Copyright 2004-2015 Grigory Filatov <gfilatov@inbox.ru>
*/

ANNOUNCE RDDSYS

#include "minigui.ch"

#define PROGRAM		'Process Killer'
#define VERSION		' version 2.2'
#define COPYRIGHT	' Grigory Filatov, 2004-2015'

#define RUN_TITLE_EN	"Run"
#define RUN_TITLE_SP	"Comience el programa"	// Spanish
#define RUN_TITLE_PT	"Comece o programa"	// Portuguese
#define RUN_TITLE_RU	"Запуск программы"	// Russian

#define IDI_MAIN 1001

Static aProcInfo := {}, lOnTop := .F., lToTray := .F., nTheme := 2, cMark := "R0"
Memvar cFileIni, cVers

Procedure Main

	PUBLIC cFileIni := Lower( ChangeFileExt( Application.ExeName, ".ini" ) )

	Load Window Main
	SetHotKeys()
	Center Window Main
	Activate Window Main

Return

*-----------------------------------------------------------------------------*
Static Procedure SetHotKeys()
*-----------------------------------------------------------------------------*

	ON KEY F5 OF Main ACTION ( Main.Grid_1.DeleteAllItems, aProcInfo := AddToGrid() )
	ON KEY F6 OF Main ACTION KillIt( Main.Grid_1.Value )
	ON KEY CONTROL+R OF Main ACTION RunCmd()
	ON KEY CONTROL+E OF Main ACTION RunShell( "explorer.exe", cFilePath( Main.Grid_1.Cell(Main.Grid_1.Value, 2) ) )
	ON KEY CTRL+SHIFT+C OF Main ACTION RunShell( GetE("COMSPEC"), NIL )

Return

*-----------------------------------------------------------------------------*
Static Procedure BuildMenu( nParam )
*-----------------------------------------------------------------------------*
Local aColors, i, cImageMark, cCheckMark

Default nParam := 0
nTheme := nParam

If nTheme > 0

	SET MENUSTYLE EXTENDED

	SET MENUCURSOR FULL

	SET MENUSEPARATOR SINGLE RIGHTALIGN

	SET MENUITEM BORDER 3D

	aColors := GetMenuColors()

	aColors[ MNUCLR_MENUBARBACKGROUND1 ] := GetSysColor(15)
	aColors[ MNUCLR_MENUBARBACKGROUND2 ] := GetSysColor(15)
	aColors[ MNUCLR_MENUBARSELECTEDITEM1 ] := GetSysColor(15)
	aColors[ MNUCLR_MENUBARSELECTEDITEM2 ] := GetSysColor(15)

	aColors[ MNUCLR_MENUITEMSELECTEDTEXT ] := RGB( 0, 0, 0 )
	aColors[ MNUCLR_MENUITEMBACKGROUND1 ] := IF( _HMG_IsXP, RGB( 255, 255, 255 ), RGB( 255, 248, 248 ) )
	aColors[ MNUCLR_MENUITEMBACKGROUND2 ] := IF( _HMG_IsXP, RGB( 255, 255, 255 ), RGB( 248, 248, 240 ) )

	aColors[ MNUCLR_SELECTEDITEMBORDER1 ] := RGB( 87, 98, 116 )
	aColors[ MNUCLR_SELECTEDITEMBORDER2 ] := RGB( 128, 128, 128 )
	aColors[ MNUCLR_SELECTEDITEMBORDER3 ] := RGB( 87, 98, 116 )
	aColors[ MNUCLR_SELECTEDITEMBORDER4 ] := RGB( 255, 255, 255 )

EndIf

Do Case
   Case nTheme == 1

	SET MENUCURSOR SHORT
	SET MENUSEPARATOR DOUBLE CENTERALIGN

	cImageMark := "MARK1"

	aColors[ MNUCLR_MENUITEMSELECTEDTEXT ] := RGB( 255, 255, 255 )
	aColors[ MNUCLR_SEPARATOR1 ] := RGB( 128, 128, 128 )

	aColors[ MNUCLR_MENUITEMBACKGROUND1 ] := IF( _HMG_IsXP, RGB( 255, 255, 255 ), GetSysColor(15) )
	aColors[ MNUCLR_MENUITEMBACKGROUND2 ] := IF( _HMG_IsXP, RGB( 255, 255, 255 ), GetSysColor(15) )

	aColors[ MNUCLR_IMAGEBACKGROUND1 ] := IF( _HMG_IsXP, RGB( 255, 255, 255 ), GetSysColor(15) )
	aColors[ MNUCLR_IMAGEBACKGROUND2 ] := IF( _HMG_IsXP, RGB( 255, 255, 255 ), GetSysColor(15) )

	aColors[ MNUCLR_MENUITEMSELECTEDBACKGROUND1 ] := IF( _HMG_IsXP, RGB( 49, 106, 197 ), RGB( 0, 36, 104 ) )
	aColors[ MNUCLR_MENUITEMSELECTEDBACKGROUND2 ] := IF( _HMG_IsXP, RGB( 49, 106, 197 ), RGB( 0, 36, 104 ) )

	aColors[ MNUCLR_SELECTEDITEMBORDER1 ] := IF( _HMG_IsXP, RGB( 49, 106, 197 ), RGB( 0, 36, 104 ) )
	aColors[ MNUCLR_SELECTEDITEMBORDER3 ] := IF( _HMG_IsXP, RGB( 49, 106, 197 ), RGB( 0, 36, 104 ) )

	aColors[ MNUCLR_CHECKMARKBACKGROUND ] := IF( _HMG_IsXP, RGB( 255, 255, 255 ), GetSysColor(15) )
	aColors[ MNUCLR_CHECKMARKSQUARE ] := RGB( 172, 168, 153 )

   Case nTheme == 2

	cImageMark := "MARK2"

	aColors[ MNUCLR_SEPARATOR1 ] := RGB( 128, 128, 128 )

	aColors[ MNUCLR_IMAGEBACKGROUND1 ] := RGB( 226, 234, 247 )
	aColors[ MNUCLR_IMAGEBACKGROUND2 ] := RGB( 226, 234, 247 )

	aColors[ MNUCLR_MENUITEMSELECTEDBACKGROUND1 ] := RGB( 194, 211, 239 )
	aColors[ MNUCLR_MENUITEMSELECTEDBACKGROUND2 ] := RGB( 194, 211, 239 )

   Case nTheme == 3

	cImageMark := "MARK3"

	aColors[ MNUCLR_SEPARATOR1 ] := RGB( 172, 168, 153 )

	aColors[ MNUCLR_IMAGEBACKGROUND1 ] := RGB( 230, 230, 230 )
	aColors[ MNUCLR_IMAGEBACKGROUND2 ] := RGB( 239, 239, 239 )

	aColors[ MNUCLR_MENUITEMBACKGROUND1 ] := RGB( 240, 240, 240 )
	aColors[ MNUCLR_MENUITEMBACKGROUND2 ] := RGB( 255, 255, 255 )

	aColors[ MNUCLR_MENUITEMSELECTEDBACKGROUND1 ] := RGB( 200, 212, 230 )
	aColors[ MNUCLR_MENUITEMSELECTEDBACKGROUND2 ] := RGB( 226, 234, 247 )

   OtherWise

	SET MENUSTYLE STANDARD

    DEFINE MAIN MENU OF Main
        DEFINE POPUP "&Process"
            MENUITEM "&Resresh List"+Chr(9)+"F5" ACTION ( Main.Grid_1.DeleteAllItems, aProcInfo := AddToGrid() )
            SEPARATOR
            MENUITEM "&Kill Process"+Chr(9)+"F6" ACTION KillIt( Main.Grid_1.Value )
            DEFINE POPUP "&Set Priority Class"
                MENUITEM "REALTIME_PRIORITY_CLASS" ACTION ( SetPriorityToProcess(aProcInfo[Main.Grid_1.Value][1], 6), SetMenuPriority( Main.Grid_1.Value ) ) NAME REALTIME
                MENUITEM "HIGH_PRIORITY_CLASS" ACTION ( SetPriorityToProcess(aProcInfo[Main.Grid_1.Value][1], 3), SetMenuPriority( Main.Grid_1.Value ) ) NAME HIGH
		If IsWinNT()
			MENUITEM "ABOVE_NORMAL_PRIORITY_CLASS" ACTION SetPriorityToProcess(aProcInfo[Main.Grid_1.Value][1], 1) NAME ABOVE_NORMAL
		EndIf
                MENUITEM "NORMAL_PRIORITY_CLASS" ACTION ( SetPriorityToProcess(aProcInfo[Main.Grid_1.Value][1], 5), SetMenuPriority( Main.Grid_1.Value ) ) NAME NORMAL
		If IsWinNT()
			MENUITEM "BELOW_NORMAL_PRIORITY_CLASS" ACTION SetPriorityToProcess(aProcInfo[Main.Grid_1.Value][1], 2) NAME BELOW_NORMAL
		EndIf
                MENUITEM "IDLE_PRIORITY_CLASS" ACTION ( SetPriorityToProcess(aProcInfo[Main.Grid_1.Value][1], 4), SetMenuPriority( Main.Grid_1.Value ) ) NAME IDLE
            END POPUP
            SEPARATOR
            MENUITEM "&Run"+Chr(9)+"Ctrl+R" ACTION RunCmd()
            MENUITEM "&Explorer"+Chr(9)+"Ctrl+E" ACTION RunShell( "explorer.exe", cFilePath( Main.Grid_1.Cell(Main.Grid_1.Value, 2) ) )
            MENUITEM "&Command Prompt"+Chr(9)+"Shift+Ctrl+C" ACTION RunShell( GetE("COMSPEC"), NIL )
            SEPARATOR
            MENUITEM "E&xit"+Chr(9)+"Alt+F4" ACTION ThisWIndow.Release
        END POPUP
        DEFINE POPUP "&View"
            MENUITEM "&Always On Top" ACTION ( lOnTop := !lOnTop, Main.OnTop.Checked := lOnTop, ;
			SetWindowPos( Application.Handle, IF(lOnTop, -1, -2), 0, 0, 0, 0, 3 ) ) NAME OnTop
            DEFINE POPUP "&Theme"
                MENUITEM "System" ACTION BuildMenu() NAME T0
                MENUITEM "Office 2k" ACTION BuildMenu(1) NAME T1
                MENUITEM "Office XP" ACTION BuildMenu(2) NAME T2
                MENUITEM "XNet" ACTION BuildMenu(3) NAME T3
            END POPUP
        END POPUP
        DEFINE POPUP "&Options"
            DEFINE POPUP "&Refresh rate"
                MENUITEM "Disabled" ACTION SetTimer() NAME R0
                MENUITEM " 5 sec" ACTION SetTimer(5) NAME R5
                MENUITEM "15 sec" ACTION SetTimer(15) NAME R15
                MENUITEM "30 sec" ACTION SetTimer(30) NAME R30
            END POPUP
            MENUITEM "&Minimize To Tray" ACTION ( lToTray := !lToTray, Main.Tray.Checked := lToTray ) NAME TRAY
        END POPUP
        DEFINE POPUP "&Help"
            MENUITEM "&About" ACTION MsgAbout()
        END POPUP
    END MENU

End Case

If nTheme > 0

    SetMenuColors( aColors )

    cCheckMark := If( nTheme == 3, "CHECK", If( nTheme == 2, "CHECK2", NIL ) )

    DEFINE MAIN MENU OF Main
        DEFINE POPUP "&Process"
            MENUITEM "&Resresh List"+Space(34)+"F5" ACTION ( Main.Grid_1.DeleteAllItems, aProcInfo := AddToGrid() ) IMAGE "REFRESH"
            SEPARATOR
            MENUITEM "&Kill Process"+Space(35)+"F6" ACTION KillIt( Main.Grid_1.Value ) IMAGE "KILL"
            DEFINE POPUP "&Set Priority Class"
                MENUITEM "REALTIME_PRIORITY_CLASS" ACTION ( SetPriorityToProcess(aProcInfo[Main.Grid_1.Value][1], 6), SetMenuPriority( Main.Grid_1.Value ) ) NAME REALTIME ;
			CHECKMARK cCheckMark
                MENUITEM "HIGH_PRIORITY_CLASS" ACTION ( SetPriorityToProcess(aProcInfo[Main.Grid_1.Value][1], 3), SetMenuPriority( Main.Grid_1.Value ) ) NAME HIGH ;
			CHECKMARK cCheckMark
		If IsWinNT()
			MENUITEM "ABOVE_NORMAL_PRIORITY_CLASS" ACTION SetPriorityToProcess(aProcInfo[Main.Grid_1.Value][1], 1) NAME ABOVE_NORMAL ;
				CHECKMARK cCheckMark
		EndIf
                MENUITEM "NORMAL_PRIORITY_CLASS" ACTION ( SetPriorityToProcess(aProcInfo[Main.Grid_1.Value][1], 5), SetMenuPriority( Main.Grid_1.Value ) ) NAME NORMAL ;
			CHECKMARK cCheckMark
		If IsWinNT()
			MENUITEM "BELOW_NORMAL_PRIORITY_CLASS" ACTION SetPriorityToProcess(aProcInfo[Main.Grid_1.Value][1], 2) NAME BELOW_NORMAL ;
				CHECKMARK cCheckMark
		EndIf
                MENUITEM "IDLE_PRIORITY_CLASS" ACTION ( SetPriorityToProcess(aProcInfo[Main.Grid_1.Value][1], 4), SetMenuPriority( Main.Grid_1.Value ) ) NAME IDLE ;
			CHECKMARK cCheckMark
            END POPUP
            SEPARATOR
            MENUITEM "&Run"+Space(41)+"Ctrl+R" ACTION RunCmd() IMAGE "RUN"
            MENUITEM "&Explorer"+Space(35)+"Ctrl+E" ACTION RunShell( "explorer.exe", cFilePath( Main.Grid_1.Cell(Main.Grid_1.Value, 2) ) ) IMAGE "OPEN"
            MENUITEM "&Command Prompt"+Space(11)+"Shift+Ctrl+C" ACTION RunShell( GetE("COMSPEC"), NIL ) IMAGE "CMD"
            SEPARATOR
            MENUITEM "E&xit"+Space(41)+"Alt+F4" ACTION ThisWIndow.Release IMAGE "EXIT"
        END POPUP
        DEFINE POPUP "&View"
            MENUITEM "&Always On Top" ACTION ( lOnTop := !lOnTop, Main.OnTop.Checked := lOnTop, ;
			SetWindowPos( Application.Handle, IF(lOnTop, -1, -2), 0, 0, 0, 0, 3 ) ) NAME OnTop ;
			CHECKMARK cCheckMark
            DEFINE POPUP "&Theme"
                MENUITEM "System" ACTION BuildMenu() NAME T0 CHECKMARK cImageMark
                MENUITEM "Office 2k" ACTION BuildMenu(1) NAME T1 CHECKMARK cImageMark
                MENUITEM "Office XP" ACTION BuildMenu(2) NAME T2 CHECKMARK cImageMark
                MENUITEM "XNet" ACTION BuildMenu(3) NAME T3 CHECKMARK cImageMark
            END POPUP
        END POPUP
        DEFINE POPUP "&Options"
            DEFINE POPUP "&Refresh rate"
                MENUITEM "Disabled" ACTION SetTimer() NAME R0 CHECKMARK cImageMark
                MENUITEM " 5 sec" ACTION SetTimer(5) NAME R5 CHECKMARK cImageMark
                MENUITEM "15 sec" ACTION SetTimer(15) NAME R15 CHECKMARK cImageMark
                MENUITEM "30 sec" ACTION SetTimer(30) NAME R30 CHECKMARK cImageMark
            END POPUP
            MENUITEM "&Minimize To Tray" ACTION ( lToTray := !lToTray, Main.Tray.Checked := lToTray ) NAME TRAY ;
			CHECKMARK cCheckMark
        END POPUP
        DEFINE POPUP "&Help"
            MENUITEM "&About" ACTION MsgAbout() IMAGE "INFO"
        END POPUP
    END MENU

EndIf

	DEFINE NOTIFY MENU OF Main
		ITEM '&Restore'		ACTION Notify_CLick()
		ITEM 'E&xit ' + PROGRAM	ACTION Main.Release
	END MENU

	IF Main.Grid_1.Value > 0
		SetMenuPriority( Main.Grid_1.Value )
	ENDIF

	For i := 0 To 3
		SetProperty( "Main" , "T"+ltrim(str(i)) , "Checked" , .F. )
	Next

	SetProperty( "Main" , "T"+ltrim(str(nTheme)) , "Checked" , .T. )
	SetProperty( "Main" , cMark , "Checked" , .T. )
	SetProperty( "Main" , "OnTop" , "Checked" , lOnTop )
	SetProperty( "Main" , "Tray" , "Checked" , lToTray )

Return

*-----------------------------------------------------------------------------*
Procedure KillIt( nValue )
*-----------------------------------------------------------------------------*

	PlayExclamation()

	IF MsgOkCancel( "Process #" + Main.Grid_1.Item( nValue )[1] + " will be terminated." + CRLF + ;
		"Continue?", "Confirm", IDI_MAIN, .f. )

		KillProcess( aProcInfo[nValue][1] )

		Adel( aProcInfo, nValue )
		Asize( aProcInfo, Len(aProcInfo) - 1 )

		RefreshGrid( IF(nValue > 1, nValue - 1, 1) )

	ENDIF

Return

*-----------------------------------------------------------------------------*
Procedure SetMenuPriority( nValue )
*-----------------------------------------------------------------------------*
Local nProcessPriority

	IF Len(aProcInfo) > 0

		nProcessPriority := GetProcessPriority( aProcInfo[nValue][1] )

		If IsWinNT()
			Main.BELOW_NORMAL.Checked := .F.
			Main.ABOVE_NORMAL.Checked := .F.
		EndIf
		Main.IDLE.Checked := .F.
		Main.NORMAL.Checked := .F.
		Main.HIGH.Checked := .F.
		Main.REALTIME.Checked := .F.

		SWITCH nProcessPriority
			CASE -3
				Main.BELOW_NORMAL.Checked := .T.
				EXIT
			CASE -2
				Main.ABOVE_NORMAL.Checked := .T.
				EXIT
			CASE -1
				Main.IDLE.Checked := .T.
				EXIT
			CASE 1
				Main.HIGH.Checked := .T.
				EXIT
			CASE 2
				Main.REALTIME.Checked := .T.
				EXIT
		#ifdef __XHARBOUR__
			DEFAULT
		#else
			OTHERWISE
		#endif
				Main.NORMAL.Checked := .T.
		END

	ENDIF

Return

*-----------------------------------------------------------------------------*
Static Function AddToGrid( nValue )
*-----------------------------------------------------------------------------*
Local aProc := {}, cExeName := "", nProcessID, i, cStrTran
Local aProcessInfo := IF(IsWinNT(), GetProcessesNT(), GetProcessesW9x())
Local aFileInfo, aInfo := { "FileDescription", "CompanyName", "LegalCopyright", "FileVersion" }

Default nValue := 1

	For i := 1 To Len(aProcessInfo) Step 2
		nProcessID := aProcessInfo[i]
		IF !Empty(nProcessID)
			cExeName := aProcessInfo[i+1]
			IF IsWinNT()
				IF At("\??\", cExeName) > 0
					cExeName := StrTran(cExeName, "\??\", "")
				ENDIF
				IF Left(cExeName, 1) == "\"
					cExeName := SubStr(cExeName, 2)
					cStrTran := Left(cExeName, At("\", cExeName) - 1)
					cExeName := StrTran(cExeName, cStrTran, GetE(cStrTran))
				ENDIF
			ENDIF
			IF aScan( aProc, {|e| e[2] == cExeName } ) == 0
				AADD( aProc, { nProcessID, cExeName, "", "", "", "" } )
				aFileInfo := FileVersInfo( aInfo, GetInstance(), cExeName )
				IF LEN(aFileInfo) > 0
					IF valtype(aFileInfo[1]) == "C"
						aTail(aProc)[3] := aFileInfo[1]
					ENDIF
					IF valtype(aFileInfo[2]) == "C"
						aTail(aProc)[4] := aFileInfo[2]
					ENDIF
					IF valtype(aFileInfo[3]) == "C"
						aTail(aProc)[5] := aFileInfo[3]
					ENDIF
					IF valtype(aFileInfo[4]) == "C"
						aTail(aProc)[6] := aFileInfo[4]
					ENDIF
				ENDIF
			ENDIF
		ENDIF
	Next

	IF LEN(aProc) > 0
		Main.Grid_1.DisableUpdate
		Aeval( aProc, { |e,i| Main.Grid_1.AddItem( { Ltrim(Str(i)), e[2], e[3], e[4], e[5], e[6] } ) } )

		Main.Grid_1.ColumnsAutoFit
		Main.Grid_1.EnableUpdate

		Main.Grid_1.Value := nValue
	ENDIF

	Main.Grid_1.Setfocus

Return aProc

*-----------------------------------------------------------------------------*
Static Procedure ResizeCtrls()
*-----------------------------------------------------------------------------*

	IF Main.Width < 640
		Main.Width := 640
	ENDIF
	IF Main.Height < 480
		Main.Height := 480
	ENDIF

	Main.Grid_1.Width := Main.Width - 106
	Main.Grid_1.Height := Main.Height - 55 - iif(IsSeven(), GetBorderHeight()/2, 0)

	Main.Button_1.Col := Main.Width - 94 - iif(IsSeven(), GetBorderWidth()/2, 0)
	Main.Button_2.Col := Main.Width - 94 - iif(IsSeven(), GetBorderWidth()/2, 0)

	RefreshGrid( Main.Grid_1.Value )

Return

*-----------------------------------------------------------------------------*
Static Procedure RefreshGrid( nValue )
*-----------------------------------------------------------------------------*

	Main.Grid_1.DisableUpdate

	Main.Grid_1.DeleteAllItems
	Aeval( aProcInfo, { |e,i| Main.Grid_1.AddItem( { Ltrim(Str(i)), e[2], e[3], e[4], e[5], e[6] } ) } )

	Main.Grid_1.ColumnsAutoFit
	Main.Grid_1.EnableUpdate

	Main.Grid_1.Value := nValue

Return

*-----------------------------------------------------------------------------*
Procedure Minimize_Click
*-----------------------------------------------------------------------------*
Local i := GetFormIndex("Main")

	ShowNotifyIcon( _HMG_aFormhandles[i], .T. , LoadTrayIcon( GetInstance(), ;
		_HMG_aFormNotifyIconName[i] ), _HMG_aFormNotifyIconToolTip[i] )

	Main.Hide

Return

*-----------------------------------------------------------------------------*
Procedure Notify_Click
*-----------------------------------------------------------------------------*
Local FormHandle := Application.Handle

	Main.Restore
	Main.Show
	SetForegroundWindow( FormHandle )

	ShowNotifyIcon( FormHandle, .F., NIL, NIL )

Return

*-----------------------------------------------------------------------------*
Procedure SetTimer( nValue )
*-----------------------------------------------------------------------------*
Default nValue := 0

	If IsControlDefined( Timer_1, Main )
		Main.Timer_1.Release
	EndIf

	If nValue > 0

		DEFINE TIMER Timer_1 OF Main ;
			INTERVAL nValue * 1000 ;
			ACTION ( nValue := Main.Grid_1.Value, Main.Grid_1.DeleteAllItems, aProcInfo := AddToGrid(nValue) )

	EndIf

	cMark := "R"+ltrim(str(nValue))
	SetProperty( "Main" , cMark , "Checked" , .T. )

	SWITCH nValue
	CASE 0
		SetProperty( "Main", "R5", "Checked" , .F. )		
		SetProperty( "Main", "R15", "Checked" , .F. )	
		SetProperty( "Main", "R30", "Checked" , .F. )	
		EXIT
	CASE 5
		SetProperty( "Main", "R0", "Checked" , .F. )		
		SetProperty( "Main", "R15", "Checked" , .F. )	
		SetProperty( "Main", "R30", "Checked" , .F. )	
		EXIT
	CASE 15
		SetProperty( "Main", "R0", "Checked" , .F. )		
		SetProperty( "Main", "R5", "Checked" , .F. )	
		SetProperty( "Main", "R30", "Checked" , .F. )	
		EXIT
	CASE 30
		SetProperty( "Main", "R0", "Checked" , .F. )		
		SetProperty( "Main", "R5", "Checked" , .F. )	
		SetProperty( "Main", "R15", "Checked" , .F. )	
	END

Return

*-----------------------------------------------------------------------------*
Procedure RunCmd()
*-----------------------------------------------------------------------------*
Local hWnd := 0, nCount := 999
Local oShell := CreateObject( "Shell.Application" )

	// Displays the Run dialog box
	oShell:FileRun()

	DO WHILE EMPTY(hWnd) .AND. nCount > 0
		DO EVENTS
		hWnd := FindWindow( RUN_TITLE_EN )
		nCount--
	ENDDO
	IF !EMPTY(hWnd)
		SetWindowPos( hWnd, -1, 0, 0, 0, 0, 3 )
       		MoveWindow( hWnd, Main.Col + GetBorderWidth(), ;
			Main.Row + GetTitleHeight() + GetBorderHeight() + GetMenuBarHeight(), ;
			GetWindowWidth(hWnd), GetWindowHeight(hWnd), .T. )
		DO EVENTS
	ENDIF

	oShell := NIL

RETURN

*-----------------------------------------------------------------------------*
Procedure RunShell( cFile, cParam )
*-----------------------------------------------------------------------------*

	ShellExecute( 0, "open", cFile, cParam, , 1 )

Return

*-----------------------------------------------------------------------------*
Procedure MsgAbout()
*-----------------------------------------------------------------------------*
Local lIsThemed := IsThemed(), ;
	cMsgAbout := "Watch running processes of your system." + CRLF + ;
		"Run programs or terminate running processes." + CRLF + CRLF + ;
		"Please report about any suggestions or bugs to" + CRLF + CRLF + ;
		space(20) + "gfilatov@inbox.ru", ;
        cVers := "v." + Right(VERSION, 3)

	DEFINE WINDOW Form_About ;
		AT 0,0 ;
		WIDTH 345 HEIGHT 238 + IF(lIsThemed, 7, 0) ;
		TITLE "About" ;
		ICON IDI_MAIN ;
		MODAL ;
		NOSIZE ;
		FONT 'MS Sans Serif' ;
		SIZE 9

		@ Form_About.Height - IF(lIsThemed, 64, 56), ;
			Form_About.Width - 91 BUTTONEX Btn_1 ; 
			CAPTION 'OK' ; 
			ACTION ThisWindow.Release() ; 
			WIDTH 74 ; 
			HEIGHT 23 FLAT DEFAULT

		DRAW RECTANGLE IN WINDOW Form_About ;
			AT -2,-2 TO 56,345 ;
			PENCOLOR GRAY ;
			FILLCOLOR WHITE

		DRAW LINE IN WINDOW Form_About ;
			AT 56,0 TO 56,343 ;
			PENCOLOR WHITE

		DRAW LINE IN WINDOW Form_About ;
			AT 169,0 TO 169,343 ;
			PENCOLOR GRAY

		DRAW LINE IN WINDOW Form_About ;
			AT 170,0 TO 170,343 ;
			PENCOLOR WHITE

		@ 3, 24 IMAGE Image_1				;
			PICTURE 'LOGO'				;
			WIDTH 48				;
			HEIGHT 48

		@ 10, Form_About.Width - 161 LABEL Label_1	;
			VALUE PROGRAM				;
			RIGHTALIGN				;
			BACKCOLOR WHITE

		@ 32, Form_About.Width - 66 LABEL Label_2	;
			VALUE cVers				;
			BACKCOLOR WHITE				;
			HEIGHT 16

		@ 70, 45 LABEL Label_3				;
			VALUE cMsgAbout				;
			WIDTH 300 HEIGHT 92

		@ Form_About.Height - IF(lIsThemed, 60, 52), 14 ;
			LABEL Label_4				;
			VALUE Chr(169) + COPYRIGHT		;
			AUTOSIZE

		ON KEY ESCAPE ACTION ThisWindow.Release()

	END WINDOW

	CENTER WINDOW Form_About
	ACTIVATE WINDOW Form_About

Return

*--------------------------------------------------------*
Static Procedure SaveConfig( FormName )
*--------------------------------------------------------*
LOCAL hWnd := Application.Handle, r, c, w, h

	r := iif(GetWindowRow(hWnd) > GetDesktopHeight(), -1, GetWindowRow(hWnd))
	c := iif(GetWindowCol(hWnd) > GetDesktopWidth(), -1, GetWindowCol(hWnd))
	w := iif(GetWindowWidth(hWnd) > GetDesktopWidth(), -1, GetWindowWidth(hWnd))
	h := iif(GetWindowHeight(hWnd) > GetDesktopHeight() - GetTaskBarHeight(), -1, GetWindowHeight(hWnd))

	BEGIN INI FILE cFileIni
		_SetIni(FormName, FormName+'.Row',	r)
		_SetIni(FormName, FormName+'.Col',	c)
		_SetIni(FormName, FormName+'.Width',	w)
		_SetIni(FormName, FormName+'.Height',	h)

		SET SECTION FormName ENTRY 'OnTop' TO lOnTop
		SET SECTION FormName ENTRY 'MinToTray' TO lToTray
		SET SECTION FormName ENTRY 'Theme' TO nTheme
	END INI

RETURN

*--------------------------------------------------------*
Static Procedure RestoreConfig( FormName )
*--------------------------------------------------------*
LOCAL iVar := 0, hWnd := Application.Handle

	BEGIN INI FILE cFileIni
		IF ( iVar := _GetIni(FormName,FormName+'.Row',-1,iVar) ) # -1
			SetProperty(FormName,'Row',iVar)
		ENDIF
		IF ( iVar := _GetIni(FormName,FormName+'.Col',-1,iVar) ) # -1
			SetProperty(FormName,'Col',iVar)
		ENDIF
		IF ( iVar := _GetIni(FormName,FormName+'.Width',-1,iVar) ) # -1
			SetProperty(FormName,'Width',iVar)
		ENDIF
		IF ( iVar := _GetIni(FormName,FormName+'.Height',-1,iVar) ) # -1
			SetProperty(FormName,'Height',iVar)
		ENDIF

		IF GetWindowRow(hWnd) < 0 .OR. GetWindowCol(hWnd) < 0
			Center Window &FormName
		ENDIF

		IF ( lOnTop := _GetIni(FormName,'OnTop',.F.,lOnTop) ) <> .F.
			SetWindowPos( hWnd, -1, 0, 0, 0, 0, 3 )
		ENDIF
		lToTray := _GetIni(FormName,'MinToTray',.F.,lToTray)
		nTheme := _GetIni(FormName,'Theme',2,nTheme)
	END INI

RETURN


#pragma BEGINDUMP

#include <windows.h>
#include "hbapi.h"
#include "hbapiitm.h"

#ifdef __XHARBOUR__
#define HB_PARC( n, x )     hb_parc( n, x )
#define HB_STORC( n, x, y ) hb_storc( n, x, y )
#else
#define HB_PARC( n, x )     hb_parvc( n, x )
#define HB_STORC( n, x, y ) hb_storvc( n, x, y )
#endif

HB_FUNC ( FINDWINDOW )
{
   hb_retnl( ( LONG ) FindWindow( 0, hb_parc( 1 ) ) );
}

HB_FUNC( FILEVERSINFO )
{
    int   iLen  = hb_itemSize( hb_param(1, -1) );
    char  szFullPath[256];
    DWORD dwVerHnd;
    DWORD dwVerInfoSize;
    HANDLE hHndl = (HANDLE) hb_parni(2);

    if ( hb_pcount() > 2 )
    {
      // Get version information from an application path + filename
      lstrcpy( szFullPath, hb_parc(3) );
    } else {
      // Get version information from the application
      GetModuleFileName( hHndl, szFullPath, sizeof(szFullPath) );
    }

    dwVerInfoSize = GetFileVersionInfoSize(szFullPath, &dwVerHnd);
    if (dwVerInfoSize)
    {
        // If we were able to get the information, process it:
        HANDLE  hMem;
        LPVOID  lpvMem;
        DWORD   * pdwLangChar;
        UINT    uSize;
        char    szGetName[256];
        int     cchRoot;
        int     i;

        hMem   = GlobalAlloc(GMEM_MOVEABLE, dwVerInfoSize);
        lpvMem = GlobalLock(hMem);
        GetFileVersionInfo(szFullPath, dwVerHnd, dwVerInfoSize, lpvMem);
        if (VerQueryValue(lpvMem, "\\VarFileInfo\\Translation", (void**)(&pdwLangChar), &uSize))
        {
           wsprintf(szGetName, "\\StringFileInfo\\%04X%04X\\", LOWORD(*pdwLangChar), HIWORD(*pdwLangChar));
        }
        else
        {
           lstrcpy(szGetName, "\\StringFileInfo\\040904E4\\");
        }

        cchRoot = lstrlen(szGetName);

        hb_reta( iLen );

        // Walk through the requested items:
        for (i = 1; i <= iLen; i++)
        {

           #pragma warn -sus
           BOOL  fRet;
           UINT  cchVer = 0;
           LPSTR lszVer = NULL;
           char  szResult[256];

           lstrcpy(&szGetName[cchRoot], HB_PARC( 1, i ) );

           fRet = VerQueryValue(lpvMem, szGetName, &lszVer, &cchVer);

           if (fRet && cchVer && lszVer)
           {
              lstrcpy(szResult, lszVer);
              HB_STORC( szResult, -1, i );
           }

        }

        GlobalUnlock(hMem);
        GlobalFree(hMem);
     }
     else
     {
        hb_reta( 0 );
     }
}

#pragma ENDDUMP
