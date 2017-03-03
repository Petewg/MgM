/*
 * MINIGUI - Harbour Win32 GUI library Demo
 *
 * Copyright 2002-10 Roberto Lopez <harbourminigui@gmail.com>
 * http://harbourminigui.googlepages.com/
 *
 * Copyright 2003-2012 Grigory Filatov <gfilatov@inbox.ru>
*/

ANNOUNCE RDDSYS

#include "minigui.ch"
#include "fileio.ch"

#define PROGRAM 'File Manager'
#define VERSION ' 0.51'
#define COPYRIGHT ' 2003-2012 Grigory Filatov'

#define MsgAlert( c )   MsgExclamation( c, PROGRAM, , .f. )

#define WM_SYSCOMMAND 274       // &H112
#define SC_SCREENSAVE 61760     // &HF140

#ifdef __XHARBOUR__
   #define STR( n ) Str( n, 10 )
#endif

Static aDrives, aDirectory, aSubDirectory, aOldPos
Static aNivel := { 1, 1 }, aBack := { .t., .t. }, ;
	aGridWidth, nGridFocus := 2, bBlock, lBlock := .f.
Static cRunCommand := "", aWinVer, aSortCol := { 1, 1 }

*--------------------------------------------------------*
Function Main()
*--------------------------------------------------------*
LOCAL nScrWidth := GetDesktopWidth(), nScrHeight := GetDesktopHeight(), ;
	nWidth, nHeight, nGridHeight, nGridWidth
LOCAL lfirst := .t., i, cButton, cDrive, nWnd := 1
LOCAL aDriveBmps := { "FLOPPY", "REMOVE", "HARD", "REMOTE", "CDROM", "RAMDISK" }

   WHILE IsExeRunning( cFileNoPath( HB_ArgV( 0 ) ) + "_" + Ltrim(Str(nWnd)) )
	nWnd++
   END

   aWinVer := WindowsVersion()

   SET CENTURY ON
   SET DATE GERMAN

   SET PROGRAMMATICCHANGE OFF

   aDrives := GetDrives()
   aDirectory := ARRAY( 2 )
   aSubDirectory := ARRAY( 2, 64 )
   aOldPos := ARRAY( 2, 64 )

   aSubDirectory[1][1] := 'C:'
   aSubDirectory[2][1] := 'C:'

   nWidth := IF(nScrWidth >= 1024, 800, IF(nScrWidth >= 800, 700, 600))
   nHeight := IF(nScrHeight >= 768, 600, IF(nScrHeight >= 600, 540, 480))
   nGridHeight := IF(nHeight = 600, 360, IF(nHeight = 540, 299, 240))
   nGridWidth := IF(nWidth = 800, 380, IF(nWidth = 700, 330, 280))
   aGridWidth := IF(nHeight = 600, { 145, 80, 74, 60 }, ;
		IF(nHeight = 540, { 115, 80, 60, 54 }, { 85, 70, 60, 45 }))

   DEFINE WINDOW Form_Main ;
      AT 0,0 ;
      WIDTH nWidth + IF(IsXPThemeActive(), 8, 0) ;
	HEIGHT nHeight + IF(Len(aDrives) > 10, 28, 0) + IF(IsXPThemeActive(), 8, 0) ;
      TITLE IF(nWnd > 1, "[" + Ltrim(Str(nWnd)) + "] ", "") + PROGRAM + " v." + Ltrim(VERSION) ;
      ICON 'MAIN' ;
      MAIN ;
      NOMAXIMIZE NOSIZE ;
      ON INIT ( GetDirectory(aSubDirectory[1][1] + '\*.*', 1), ;
		GetDirectory(aSubDirectory[2][1] + '\*.*', 2), lfirst := .f. ) ;
      FONT 'MS Sans Serif' ;
      SIZE 8

	DEFINE MAIN MENU

		DEFINE POPUP "&File"
			MENUITEM "&Change Attributes..." ACTION ChangeFAttr()
			MENUITEM "&Properties..."+Chr(9)+"   Alt+Enter" ACTION ShowProperties()
			SEPARATOR
			MENUITEM "E&xit"+Chr(9)+"   Alt+F4" ACTION ReleaseAllWindows()
		END POPUP

		DEFINE POPUP "&Commands"
			MENUITEM "&Search..."+Chr(9)+"   Alt+F7" ACTION _dummy()
			MENUITEM "System &Information..." ACTION SysInfo()
		END POPUP

		DEFINE POPUP "&Show"
			MENUITEM "&Reread Folder"+Chr(9)+"   Ctrl+R" ;
				ACTION ReReadFolder()
		END POPUP

		DEFINE POPUP "&Help"
			MENUITEM "&Index"+Chr(9)+"   F1" ACTION _Execute( _HMG_MainHandle, "open", 'FileMan.hlp' )
			SEPARATOR
			MENUITEM "&About FileMan..." ACTION MsgAbout()
		END POPUP
	END MENU

	DEFINE SPLITBOX

	       DEFINE TOOLBAR ToolBar_1 BUTTONSIZE 32, 24 FLAT RIGHTTEXT

			BUTTON TB1_Button_0 ;
				CAPTION 'Reread Folder' ;
				PICTURE 'REREAD' ;
				ACTION ReReadFolder() SEPARATOR

			BUTTON TB1_Button_1  ;
				CAPTION 'NotePad' ;
				PICTURE 'NOTES' ;
				ACTION _Execute ( 0, , "Notepad", , , 5 )

			BUTTON TB1_Button_2 ;
				CAPTION 'WordPad' ;
				PICTURE 'WRITE' ;
				ACTION _Execute ( 0, , "Write", , , 5 )

			BUTTON TB1_Button_3 ;
				CAPTION 'Paint' ;
				PICTURE 'PAINT' ;
				ACTION _Execute ( 0, , "Pbrush", , , 5 )

			BUTTON TB1_Button_4 ;
				CAPTION 'Calculator' ;
				PICTURE 'CALC' ;
				ACTION _Execute ( 0, , "Calc", , , 5 ) SEPARATOR

			BUTTON TB1_Button_5 ;
				CAPTION 'Control Panel' ;
				PICTURE 'CPANEL' ;
				ACTION _Execute ( 0, , "rundll32.exe", "shell32.dll,Control_RunDLL", , 3 )

			BUTTON TB1_Button_6 ;
				CAPTION 'System Properties' ;
				PICTURE 'SYSTEM' ;
				ACTION _Execute ( 0, , "rundll32.exe", "shell32.dll,Control_RunDLL sysdm.cpl"+IF(IsVista().or.IsSeven(), "", ",,0"), , 5 )

			BUTTON TB1_Button_7 ;
				CAPTION IF(IsWinNT(), 'Task Manager', 'System Configuration') ;
				PICTURE 'TOOLS' ;
				ACTION _Execute ( 0, , IF(IsWinNT(), "TaskMgr", "MSConfig"), , , 5 )

			BUTTON TB1_Button_8 ;
				CAPTION 'Screen Saver' ;
				PICTURE 'SAVER' ;
				ACTION SendMessage( GetFormHandle("Form_Main"), WM_SYSCOMMAND, SC_SCREENSAVE, 0 ) ;
				SEPARATOR

      		END TOOLBAR

		IF nHeight > 480
			DEFINE TOOLBAR ToolBar_2 ;
				BUTTONSIZE if(len(aDrives) = 10, IF(nWidth = 800, 36, 30), ;
					if(len(aDrives) = 9, IF(nWidth = 800, 40, 38), if(len(aDrives) = 8, IF(nWidth = 800, 47, 38), ;
					if(len(aDrives) = 7, IF(nWidth = 800, 54, 47), if(len(aDrives) = 6, IF(nWidth = 800, 63, 54), ;
					if(len(aDrives) = 5, IF(nWidth = 800, 75, 63), 80)))))), 16 ;
				FLAT RIGHTTEXT BREAK BOLD
		ELSE
			DEFINE TOOLBAR ToolBar_2 ;
				BUTTONSIZE if(len(aDrives) = 10, 24, if(len(aDrives) = 9, 30, if(len(aDrives) = 8, 32, ;
					if(len(aDrives) = 7, 40, if(len(aDrives) = 6, 47, if(len(aDrives) = 5, 54, 61)))))), 16 ;
				FLAT RIGHTTEXT BREAK BOLD
		ENDIF

			for i := 1 to len(aDrives)
				cButton := "TB2_Button_"+ltrim(str(i))
				BUTTON &cButton  ;
					CAPTION Lower(aDrives[i][2]) ;
					PICTURE aDriveBmps[ aDrives[i][1] ] ;
					TOOLTIP aDrives[i][3] ;
					ACTION SelectDrive(1) ;
					AUTOSIZE CHECK GROUP
				if aDrives[i][2] $ aSubDirectory[1][1]
					Form_Main.&(cButton).Value := .t.
				endif
			next

      		END TOOLBAR

		IF nHeight > 480
			DEFINE TOOLBAR ToolBar_3 ;
				BUTTONSIZE if(len(aDrives) = 10, IF(nWidth = 800, 36, 30), ;
					if(len(aDrives) = 9, IF(nWidth = 800, 40, 38), if(len(aDrives) = 8, IF(nWidth = 800, 47, 38), ;
					if(len(aDrives) = 7, IF(nWidth = 800, 54, 47), if(len(aDrives) = 6, IF(nWidth = 800, 63, 54), ;
					if(len(aDrives) = 5, IF(nWidth = 800, 75, 63), 80)))))), 16 ;
				FLAT RIGHTTEXT BOLD
		ELSE
			DEFINE TOOLBAR ToolBar_3 ;
				BUTTONSIZE if(len(aDrives) = 10, 24, if(len(aDrives) = 9, 30, if(len(aDrives) = 8, 32, ;
					if(len(aDrives) = 7, 40, if(len(aDrives) = 6, 47, if(len(aDrives) = 5, 54, 61)))))), 16 ;
				FLAT RIGHTTEXT BOLD
		ENDIF

			for i := 1 to len(aDrives)
				cButton := "TB3_Button_"+ltrim(str(i))
				BUTTON &cButton  ;
					CAPTION Lower(aDrives[i][2]) ;
					PICTURE aDriveBmps[ aDrives[i][1] ] ;
					TOOLTIP aDrives[i][3] ;
					ACTION SelectDrive(2) ;
					AUTOSIZE CHECK GROUP
				if aDrives[i][2] $ aSubDirectory[2][1]
					Form_Main.&(cButton).Value := .t.
				endif
			next

      		END TOOLBAR

		DEFINE WINDOW SplitChild_0 ; 
			WIDTH nWidth - 2 ;
			HEIGHT 18 ;
			SPLITCHILD NOCAPTION

			DEFINE LABEL Label_1
				ROW	0
				COL	0
				VALUE	''
				WIDTH	nWidth / 2 - 10 
				HEIGHT 16
			END LABEL

			DEFINE LABEL Label_2
				ROW	0
				COL	nWidth / 2 - 2
				VALUE	'' 
				WIDTH	nWidth / 2 - 10 
				HEIGHT 16
			END LABEL

		END WINDOW 

		for i := 1 to len(aDrives)
			cButton := "TB2_Button_"+ltrim(str(i))
			if GetProperty( "Form_Main", cButton, "Value" )
				cDrive := aDrives[i][2] + ":"
				SplitChild_0.Label_1.Value	:= "[" + Lower(aDrives[i][3]) + "]  " + ;
					Ltrim(Str(Int(HB_DISKSPACE(cDrive, HB_DISK_FREE) / 1024))) + " kB of " + ;
					Ltrim(Str(Int(HB_DISKSPACE(cDrive, HB_DISK_TOTAL) / 1024))) + " kB free"
			endif

			cButton := "TB3_Button_"+ltrim(str(i))
			if GetProperty( "Form_Main", cButton, "Value" )
				cDrive := aDrives[i][2] + ":"
				SplitChild_0.Label_2.Value	:= "[" + Lower(aDrives[i][3]) + "]  " + ;
					Ltrim(Str(Int(HB_DISKSPACE(cDrive, HB_DISK_FREE) / 1024))) + " KB of " + ;
					Ltrim(Str(Int(HB_DISKSPACE(cDrive, HB_DISK_TOTAL) / 1024))) + " KB free"
			endif
		next

		DEFINE WINDOW SplitChild_1 ;
			WIDTH nWidth / 2 - IF(IsXPThemeActive(), 2, 4) ;
			HEIGHT nGridHeight + 20 ;
			TITLE aSubDirectory[1][1] ;
			SPLITCHILD BREAK FOCUSED ;
			ON GOTFOCUS nGridFocus := 1

			@ 00, 00 GRID Grid_1 ;
				WIDTH nGridWidth HEIGHT nGridHeight ;
				HEADERS {'[Name]','Size','Date','Time'} ;
				WIDTHS aGridWidth ;
				ITEMS	{{"","","",""}} ;
				VALUE	1 ;
				ON GOTFOCUS { || CurrentDirectory() } ;
				ON CHANGE { || if(lfirst, , CurrentDirectory()) } ;
				ON DBLCLICK Verify() ;
				ON HEADCLICK {  {|| Head_Click(1)},  {|| Head_Click(2)},  {|| Head_Click(3)},  {|| Head_Click(4)} } ;
				JUSTIFY { BROWSE_JTFY_LEFT,BROWSE_JTFY_RIGHT,BROWSE_JTFY_CENTER,BROWSE_JTFY_CENTER }

			SetHotKey()

			ON KEY TAB ACTION Domethod( "SplitChild_2", "Grid_2", "SetFocus" )

			ON KEY DELETE ACTION Delete_File()

		END WINDOW 

		DEFINE WINDOW SplitChild_2 ;
			WIDTH nWidth / 2 ;
			HEIGHT nGridHeight + 20 ;
			TITLE aSubDirectory[2][1] ;
			SPLITCHILD ;
			ON GOTFOCUS nGridFocus := 2

			@ 00, 00 GRID Grid_2 ;
				WIDTH nGridWidth HEIGHT nGridHeight ;
				HEADERS {'[Name]','Size','Date','Time'} ;
				WIDTHS aGridWidth ;
				ITEMS	{{"","","",""}} ;
				VALUE	1 ;
				ON GOTFOCUS { || CurrentDirectory() } ;
				ON CHANGE { || if(lfirst, , CurrentDirectory()) } ;
				ON DBLCLICK Verify() ;
				ON HEADCLICK {  {|| Head_Click(1)},  {|| Head_Click(2)},  {|| Head_Click(3)},  {|| Head_Click(4)} } ;
				JUSTIFY { BROWSE_JTFY_LEFT,BROWSE_JTFY_RIGHT,BROWSE_JTFY_CENTER,BROWSE_JTFY_CENTER }

			SetHotKey()

			ON KEY TAB ACTION SplitChild_1.Grid_1.SetFocus

			ON KEY DELETE ACTION Delete_File()

		END WINDOW 

		DEFINE WINDOW SplitChild_3 ; 
			WIDTH nWidth - 2 ;
			HEIGHT 18 ;
			SPLITCHILD NOCAPTION BREAK

			DEFINE LABEL Label_3
				ROW	0
				COL	0
				VALUE	aSubDirectory[1][1]
				WIDTH	nWidth / 2 - 10 
				HEIGHT	16
			END LABEL

			DEFINE LABEL Label_4
				ROW	0
				COL	nWidth / 2 - 2
				VALUE	aSubDirectory[2][1]
				WIDTH	nWidth / 2 - 10
				HEIGHT	16
			END LABEL

		END WINDOW 

		COMBOBOX Combo_1 ;
			WIDTH nWidth / 2 ;
			HEIGHT 60 ;
			ITEMS {} ;
			VALUE 1 ;
			VALUESOURCE cRunCommand ;
			DISPLAYEDIT ;
			BOLD ;
			ON CHANGE cRunCommand := Form_Main.Combo_1.Item(Form_Main.Combo_1.Value) ;
			ON DISPLAYCHANGE cRunCommand := Form_Main.Combo_1.DisplayValue ;
			GRIPPERTEXT "Run Command: " BREAK

	END SPLITBOX

	DEFINE TOOLBAR ToolBar_4 FLAT BUTTONSIZE if(nWidth = 800, 106 + IF(IsXPThemeActive(), 1, 0), if(nWidth = 700, 90, 74)), 11 BOLD BOTTOM

		BUTTON TB4_Button_1 ;
			CAPTION 'F&3 View' ;
			ACTION IF(EMPTY( IF( nGridFocus = 1, SplitChild_1.Grid_1.Value, ;
				SplitChild_2.Grid_2.Value ) ), , TextEdit(,,.T.) ) SEPARATOR

		BUTTON TB4_Button_2 ;
			CAPTION 'F&4 Edit' ;
			ACTION IF(EMPTY( IF( nGridFocus = 1, SplitChild_1.Grid_1.Value, ;
				SplitChild_2.Grid_2.Value ) ), , TextEdit() ) SEPARATOR

		BUTTON TB4_Button_3 ;
			CAPTION 'F&5 Copy' ;
			ACTION CopyOrMoveFile(.T.) SEPARATOR

		BUTTON TB4_Button_4 ;
			CAPTION 'F&6 Move' ;
			ACTION CopyOrMoveFile() SEPARATOR

		BUTTON TB4_Button_5 ;
			CAPTION 'F&7 NewFolder' ;
			ACTION NewFolder() SEPARATOR

		BUTTON TB4_Button_6 ;
			CAPTION 'F&8 Delete' ;
			ACTION Delete_File() SEPARATOR

		BUTTON TB4_Button_7 ;
			CAPTION 'Alt+F4 E&xit' ;
			ACTION Form_Main.Release

	END TOOLBAR

	SetHotKey()

	ON KEY TAB ACTION IF( nGridFocus = 1, SplitChild_1.Grid_1.SetFocus, SplitChild_2.Grid_2.SetFocus )

	ON KEY RETURN ACTION IF( Empty( cRunCommand ), , ;
		( _Execute ( 0, , Token( cRunCommand, " " ), ;
		Token( cRunCommand, " ", 2 ), GetFull(), 5 ), ;
		AddRunCommand( cRunCommand ), cRunCommand := "", ;
		Form_Main.Combo_1.DisplayValue := cRunCommand ) )

   END WINDOW

   CENTER WINDOW Form_Main

   ACTIVATE WINDOW Form_Main

Return Nil

*--------------------------------------------------------*
Static Function SetHotKey()
*--------------------------------------------------------*

	ON KEY CONTROL+RETURN ACTION ( Form_Main.Combo_1.DisplayValue := ;
		Ltrim(Alltrim(Form_Main.Combo_1.DisplayValue) + " " + GetName()), ;
		cRunCommand := Form_Main.Combo_1.DisplayValue, ;
		Form_Main.Combo_1.SetFocus )

	ON KEY ESCAPE ACTION ( cRunCommand := "", Form_Main.Combo_1.DisplayValue := cRunCommand )

	ON KEY ALT+F1 ACTION IF( lBlock, , HotKeySelectDrive( 1 ) )

	ON KEY ALT+F2 ACTION IF( lBlock, , HotKeySelectDrive( 2 ) )

	ON KEY ALT+F8 ACTION ( Form_Main.Combo_1.SetFocus, ;
		ComboboxShowList( _HMG_aControlHandles[ GetControlIndex( "Combo_1", "Form_Main" ) ] ) )

	ON KEY ALT+RETURN ACTION ShowProperties()

	ON KEY CONTROL+DOWN ACTION ( IF( Form_Main.Combo_1.ItemCount > 0, ;
		( cRunCommand := Form_Main.Combo_1.Item(Form_Main.Combo_1.ItemCount), ;
		Form_Main.Combo_1.DisplayValue := cRunCommand ), ), Form_Main.Combo_1.SetFocus, ;
		ComboboxShowList( _HMG_aControlHandles[ GetControlIndex( "Combo_1", "Form_Main" ) ] ) )

	ON KEY CONTROL+R ACTION ReReadFolder()

	ON KEY CONTROL+Y ACTION ( cRunCommand := "", Form_Main.Combo_1.DisplayValue := cRunCommand )

	ON KEY SHIFT+ESCAPE ACTION Form_Main.Minimize

	ON KEY F1 ACTION _Execute( _HMG_MainHandle, "open", 'FileMan.hlp' )

	ON KEY F2 ACTION ReReadFolder()

	ON KEY F3 ACTION IF(EMPTY( IF( nGridFocus = 1, SplitChild_1.Grid_1.Value, ;
		SplitChild_2.Grid_2.Value ) ), , TextEdit(,,.T.) )

	ON KEY F4 ACTION IF(EMPTY( IF( nGridFocus = 1, SplitChild_1.Grid_1.Value, ;
		SplitChild_2.Grid_2.Value ) ), , TextEdit() )

	ON KEY SHIFT+F4 ACTION TextCreate()

	ON KEY F5 ACTION CopyOrMoveFile(.T.)

	ON KEY F6 ACTION CopyOrMoveFile()

	ON KEY F7 ACTION NewFolder()

	ON KEY F8 ACTION Delete_File()

	ON KEY BACK ACTION StepBack()

Return Nil

*--------------------------------------------------------*
procedure Head_click( nCol )
*--------------------------------------------------------*
LOCAL nPos := IF( nGridFocus = 1, SplitChild_1.Grid_1.Value, SplitChild_2.Grid_2.Value ), ;
	nOldCol := aSortCol[nGridFocus]

	IF nCol = 1
		Asort(aDirectory[nGridFocus], , , {|a,b| if(valtype(a[2]) # "N" .AND. valtype(b[2]) # "N", ;
			SUBSTR(a[1],2) < SUBSTR(b[1],2), if(valtype(a[2]) # "N", SUBSTR(a[1],2) < CHR(254)+b[1], ;
			if(valtype(b[2]) # "N", CHR(254)+a[1] < SUBSTR(b[1],2), a[1] < b[1])))})
	ELSEIF nCol = 2
		Asort(aDirectory[nGridFocus], , , {|a,b| if(valtype(a[2]) # "N" .AND. valtype(b[2]) # "N", ;
			SUBSTR(a[1],2) < SUBSTR(b[1],2), if(valtype(a[2]) # "N", SUBSTR(a[1],2) < CHR(254)+b[1], ;
			if(valtype(b[2]) # "N", CHR(254)+a[1] < SUBSTR(b[1],2), a[2] < b[2])))})
	ELSEIF nCol = 3
		Asort(aDirectory[nGridFocus], , , {|a,b| if(valtype(a[2]) # "N" .AND. valtype(b[2]) # "N", ;
			SUBSTR(a[1],2) < SUBSTR(b[1],2), if(valtype(a[2]) # "N", SUBSTR(a[1],2) < CHR(254)+b[1], ;
			if(valtype(b[2]) # "N", CHR(254)+a[1] < SUBSTR(b[1],2), a[3] < b[3])))})
	ELSE
		Asort(aDirectory[nGridFocus], , , {|a,b| if(valtype(a[2]) # "N" .AND. valtype(b[2]) # "N", ;
			SUBSTR(a[1],2) < SUBSTR(b[1],2), if(valtype(a[2]) # "N", SUBSTR(a[1],2) < CHR(254)+b[1], ;
			if(valtype(b[2]) # "N", CHR(254)+a[1] < SUBSTR(b[1],2), a[4] < b[4])))})
	ENDIF

	IF nGridFocus = 1
		_SetGridCaption( "Grid_1", "SplitChild_1", nOldCol, ;
			Substr( SplitChild_1.Grid_1.Header(nOldCol), 2, Len(SplitChild_1.Grid_1.Header(nOldCol)) - 2 ), ;
			if(nOldCol=1, BROWSE_JTFY_LEFT, if(nOldCol=2, BROWSE_JTFY_RIGHT, BROWSE_JTFY_CENTER )))
	ELSE
		_SetGridCaption( "Grid_2", "SplitChild_2", nOldCol, ;
			Substr( SplitChild_2.Grid_2.Header(nOldCol), 2, Len(SplitChild_2.Grid_2.Header(nOldCol)) - 2 ), ;
			if(nOldCol=1, BROWSE_JTFY_LEFT, if(nOldCol=2, BROWSE_JTFY_RIGHT, BROWSE_JTFY_CENTER )))
	ENDIF

	aSortCol[nGridFocus] := nCol

	IF nGridFocus = 1
		SplitChild_1.Grid_1.DisableUpdate
		SplitChild_1.Grid_1.DeleteAllItems
		Aeval(aDirectory[nGridFocus], {|e| SplitChild_1.Grid_1.AddItem( { e[1], ;
			if(valtype(e[2])="N", STR(e[2]), e[2]), DTOC(e[3]), e[4] } )})
		_SetGridCaption( "Grid_1", "SplitChild_1", nCol, "[" + SplitChild_1.Grid_1.Header(nCol) + "]", ;
			if(nCol=1, BROWSE_JTFY_LEFT, if(nCol=2, BROWSE_JTFY_RIGHT, BROWSE_JTFY_CENTER )))
		SplitChild_1.Grid_1.Value := if(Empty(nPos), 1, nPos)
		SplitChild_1.Grid_1.EnableUpdate
	ELSE
		SplitChild_2.Grid_2.DisableUpdate
		SplitChild_2.Grid_2.DeleteAllItems
		Aeval(aDirectory[nGridFocus], {|e| SplitChild_2.Grid_2.AddItem( { e[1], ;
			if(valtype(e[2])="N", STR(e[2]), e[2]), DTOC(e[3]), e[4] } )})
		_SetGridCaption( "Grid_2", "SplitChild_2", nCol, "[" + SplitChild_2.Grid_2.Header(nCol) + "]", ;
			if(nCol=1, BROWSE_JTFY_LEFT, if(nCol=2, BROWSE_JTFY_RIGHT, BROWSE_JTFY_CENTER )))
		SplitChild_2.Grid_2.Value := if(Empty(nPos), 1, nPos)
		SplitChild_2.Grid_2.EnableUpdate
	ENDIF

Return

*--------------------------------------------------------*
Function ShowProperties()
*--------------------------------------------------------*
LOCAL cPath := GetFull(), cName := GetName()
LOCAL cFile := cPath +'\'+ cName
LOCAL nPos := IF( nGridFocus = 1, SplitChild_1.Grid_1.Value, SplitChild_2.Grid_2.Value )

	IF Empty( nPos ) .OR. cName = ".."
		MsgInfo( "No files selected!", PROGRAM )
	ELSE
		ShowFileProperties( cFile )
	ENDIF

Return Nil

*--------------------------------------------------------*
Function ChangeFAttr()
*--------------------------------------------------------*
LOCAL cPath := GetFull(), cName := GetName()
LOCAL cFile := cPath +'\'+ cName, cType, aDir, lChange := .f.
LOCAL lArchive, lRead, lHidden, lSystem, cDate, cTime
LOCAL nPos := IF( nGridFocus = 1, SplitChild_1.Grid_1.Value, SplitChild_2.Grid_2.Value )

	IF Empty( nPos ) .OR. cName = ".."
		MsgInfo( "No files selected!", PROGRAM )
	ELSE

		cType := Valtype( aDirectory[nGridFocus][ nPos ][ 2 ] )

		IF cType = "N"

			aDir := Directory(cFile)
			cDate := DTOC(aDir[1][3])
			cTime := aDir[1][4]
			lArchive := "A" $ aDir[1][5]
			lRead := "R" $ aDir[1][5]
			lHidden := "H" $ aDir[1][5]
			lSystem := "S" $ aDir[1][5]

			DEFINE WINDOW wFileAttr 				;
				AT 0,0 					;
				WIDTH 300 					;
				HEIGHT 260					;
				TITLE "File attributes for " +  cName	;
				ICON 'MAIN'					;
				MODAL 						;
				NOSIZE 					;
				FONT 'MS Sans Serif'				;
				SIZE 9

			@ 4, 5 FRAME FA_Frame_1 CAPTION "Change attributes" WIDTH 284 HEIGHT 118

			@ 26, 14 CHECKBOX FA_Check_1				;
				CAPTION '&Archive'					;
				WIDTH 200						;
				HEIGHT 16						;
				VALUE lArchive					;
				ON CHANGE lArchive := wFileAttr.FA_Check_1.Value

			@ 48, 14 CHECKBOX FA_Check_2				;
				CAPTION '&Read only'					;
				WIDTH 200						;
				HEIGHT 16						;
				VALUE lRead						;
				ON CHANGE lRead := wFileAttr.FA_Check_2.Value

			@ 70, 14 CHECKBOX FA_Check_3				;
				CAPTION '&Hidden'					;
				WIDTH 200						;
				HEIGHT 16						;
				VALUE lHidden						;
				ON CHANGE lHidden := wFileAttr.FA_Check_3.Value

			@ 92, 14 CHECKBOX FA_Check_4				;
				CAPTION '&System'					;
				WIDTH 200						;
				HEIGHT 16						;
				VALUE lSystem						;
				ON CHANGE lSystem := wFileAttr.FA_Check_4.Value

			@ 130, 5 FRAME Frame_2 WIDTH 284 HEIGHT 64

			@ 140, 14 CHECKBOX FA_Check_5				;
				CAPTION '&Change date/time'				;
				WIDTH 120						;
				HEIGHT 16						;
				VALUE lChange						;
				ON CHANGE lChange := wFileAttr.FA_Check_5.Value

			@ 138, 206 BUTTON FA_Button_3 ;
				CAPTION "C&urrent" ;
				ACTION ( wFileAttr.FA_Text_1.Value := DTOC(Date()), ;
					wFileAttr.FA_Text_2.Value := Time(), ;
					wFileAttr.FA_Check_5.Value := .t. ) ;
				WIDTH 74 HEIGHT 23

			@ 166, 14 LABEL FA_Label_1 VALUE "Date:" AUTOSIZE

			@ 166, 162 LABEL FA_Label_2 VALUE "Time:" AUTOSIZE

			@ 164, 56 TEXTBOX FA_Text_1					;
				VALUE cDate						;
				WIDTH 74        					;
				HEIGHT 20						;
				ON CHANGE ( cDate := wFileAttr.FA_Text_1.Value, wFileAttr.FA_Check_5.Value := .t. )

			@ 164, 206 TEXTBOX FA_Text_2				;
				VALUE cTime						;
				WIDTH 74        					;
				HEIGHT 20						;
				ON CHANGE ( cTime := wFileAttr.FA_Text_2.Value, wFileAttr.FA_Check_5.Value := .t. )

			@ 204, 122 BUTTON FA_Button_1 ;
				CAPTION "Ok" ;
				ACTION ( SetAttr(cFile, lArchive, lRead, lHidden, lSystem, lChange, cDate, cTime), wFileAttr.Release ) ;
				WIDTH 80 HEIGHT 23

			@ 204, 208 BUTTON FA_Button_2 ;
				CAPTION "Cancel" ;
				ACTION wFileAttr.Release ;
				WIDTH 80 HEIGHT 23

			END WINDOW

			CENTER WINDOW wFileAttr

			ACTIVATE WINDOW wFileAttr

		ENDIF
	ENDIF

Return Nil

#define FILE_ATTRIBUTE_READONLY  1   // 0x00000001
#define FILE_ATTRIBUTE_HIDDEN    2   // 0x00000002
#define FILE_ATTRIBUTE_SYSTEM    4   // 0x00000004
#define FILE_ATTRIBUTE_ARCHIVE  32   // 0x00000020

*--------------------------------------------------------*
Static Function SetAttr( cFileName, lArchive, lReadOnly, lHidden, lSystem, lChangeDT, cDate, cTime )
*--------------------------------------------------------*
Local nAttribute := 0, nError, dDate := CTOD(cDate)

	if lArchive
		nAttribute += FILE_ATTRIBUTE_ARCHIVE
	elseif lReadOnly
		nAttribute += FILE_ATTRIBUTE_READONLY
	elseif lHidden
		nAttribute += FILE_ATTRIBUTE_HIDDEN
	elseif lSystem
		nAttribute += FILE_ATTRIBUTE_SYSTEM
	endif

	if lChangeDT
		if !hb_FSetDateTime( cFileName, dDate, cTime )
			MsgAlert( "Invalid date/time for " + cFileName )
		endif

		ReReadFolder()
	endif

	nError := SetFAttr( cFileName, nAttribute )
	if nError = -5
		MsgAlert( "Access denied to file " + cFileName )
	endif

Return Nil

*--------------------------------------------------------*
Function SysInfo()
*--------------------------------------------------------*
Local aLabel := {}, cLabel, aText := {}, cText, ;
	aLabel2 := {}, aText2 := {}, n

	DEFINE WINDOW wSysInfo 				;
		AT 0,0 					;
		WIDTH 320 					;
		HEIGHT 350 + IF(IsXPThemeActive(), 8, 0)	;
		TITLE "System Information"			;
		ICON 'MAIN'					;
		MODAL 						;
		NOSIZE 					;
		ON INIT wSysInfo.SI_Button_1.SetFocus	;
		FONT 'MS Sans Serif'				;
		SIZE 9

		@ 298, 114 BUTTON SI_Button_1 ;
			CAPTION "Ok" ;
			ACTION wSysInfo.Release ;
			WIDTH 94 HEIGHT 23

		DEFINE TAB Tab_1				;
			AT 0,0 				;
			WIDTH 314 				;
			HEIGHT 292 				;
			VALUE 1

		PAGE "Hardware"

			Aadd(aLabel, "CPU type:")
			Aadd(aLabel, "BIOS version:")
			Aadd(aLabel, "Math coprocessor:")
			Aadd(aLabel, "Video card:")
			Aadd(aLabel, "Display resolution:")
			Aadd(aLabel, "Current printer:")
			Aadd(aLabel, "COM ports:")
			Aadd(aLabel, "Installed RAM:")

			Aadd(aText, CPUName())
			Aadd(aText, BiosName())
			Aadd(aText, "present")
			Aadd(aText, VideoName())
			Aadd(aText, ltrim(str(GetDesktopWidth())) + "x" + ltrim(str(GetDesktopHeight())) + "x" + ltrim(str(GetDisplayColors())) + "bit")
			cText := IF(IsWinNT(), GetDefaultPrinter(), ;
				GetRegVar( HKEY_CURRENT_CONFIG, "System\CurrentControlSet\Control\Print\Printers", "Default" ))
			Aadd(aText, IF(Empty(cText), "none", cText))
			Aadd(aText, ltrim(str(ComPortCount())))
			Aadd(aText, ltrim(transform(MemoryStatus(1),"999 999 999")) + " kB")

			@ 40, 14 FRAME SI_Frame_1 WIDTH 286 HEIGHT 234 //OPAQUE

			FOR n := 1 TO Len(aLabel)
				cLabel := "SI_Label_" + ltrim(str(n))
				@ (n-1)*28 + 52, 24 LABEL &cLabel ;
					VALUE aLabel[n] ;
					WIDTH 100 HEIGHT 21

				cText := "SI_Text_" + ltrim(str(n))
				@ (n-1)*28 + 52, 134 LABEL &cText ;
					VALUE aText[n] ;
					WIDTH 150 HEIGHT 26
			NEXT

		END PAGE

		PAGE "Software"

			Aadd(aLabel2, "DOS version:")
			Aadd(aLabel2, "Windows version:")
			Aadd(aLabel2, "Windows mode:")
			Aadd(aLabel2, "Swap file:")
			Aadd(aLabel2, "Free memory:")
			Aadd(aLabel2, "Free swap file:")
			Aadd(aLabel2, "Windows uptime:")
			Aadd(aLabel2, "Temporary folder:")

			Aadd(aText2, IF("95" $ aWinVer[1], "7.0", IF("98" $ aWinVer[1], "7.1", "-")))
			Aadd(aText2, alltrim(aWinVer[2]) + " (" +  aWinVer[3] + ")")
			Aadd(aText2, alltrim(aWinVer[1]))
			Aadd(aText2, "temp., " + ltrim(transform(MemoryStatus(3),"999 999 999")) + " kB max")
			Aadd(aText2, ltrim(transform(MemoryStatus(2),"999 999 999")) + " kB (" + ;
				ltrim(str( 100 - MemoryStatus(5) )) + " %)")
			Aadd(aText2, ltrim(transform(MemoryStatus(4),"999 999 999")) + " kB")
			Aadd(aText2, WinUpTime())
			Aadd(aText2, lower(GetTempFolder()))

			@ 40, 14 FRAME SI_Frame_2 WIDTH 286 HEIGHT 234 //OPAQUE

			FOR n := 1 TO Len(aLabel)
				cLabel := "S2_Label_" + ltrim(str(n))
				@ (n-1)*28 + 52, 24 LABEL &cLabel ;
					VALUE aLabel2[n] ;
					WIDTH 100 HEIGHT 21

				cText := "S2_Text_" + ltrim(str(n))
				@ (n-1)*28 + 52, 134 LABEL &cText ;
					VALUE aText2[n] ;
					WIDTH 150 HEIGHT 26
			NEXT

		END PAGE

		END TAB

	END WINDOW

	CENTER WINDOW wSysInfo

	ACTIVATE WINDOW wSysInfo

Return Nil

*--------------------------------------------------------*
Function SelectDrive( nFocus )
*--------------------------------------------------------*
Local i, cButton, cDrive := "C:", cVolume := ""

	nGridFocus := nFocus

	IF nFocus = 1
		for i := 1 to len(aDrives)
			cButton := "TB2_Button_"+ltrim(str(i))
			if GetProperty( "Form_Main", cButton, "Value" )
				cDrive := aDrives[i][2] + ':'
				cVolume := aDrives[i][3]
				exit
			endif
		next
		do while !lDriveReady(cDrive)
			if !MsgRetryCancel("Drive "+cDrive+" is not ready!", "Error")
				for i := 1 to len(aDrives)
					cButton := "TB2_Button_"+ltrim(str(i))
					if aDrives[i][2] $ aSubDirectory[1][1]
						Form_Main.&(cButton).Value := .t.
						cDrive := aDrives[i][2] + ':'
						cVolume := aDrives[i][3]
						exit
					endif
				next
				exit
			endif
		enddo
		aNivel[1] := 1
		aBack[1] := .t.
		SplitChild_0.Label_1.Value	:= "[" + Lower(cVolume) + "]  " + ;
			Ltrim(Str(Int(HB_DISKSPACE(cDrive, HB_DISK_FREE) / 1024))) + " KB of " + ;
			Ltrim(Str(Int(HB_DISKSPACE(cDrive, HB_DISK_TOTAL) / 1024))) + " KB free"
		SplitChild_1.Title := cDrive + '\*.*'
		aSubDirectory[1][1] := cDrive
		GetDirectory(aSubDirectory[1][1] + '\*.*', 1)
		SplitChild_1.Grid_1.Value := 1
		SplitChild_1.Grid_1.SetFocus
	ELSE
		for i := 1 to len(aDrives)
			cButton := "TB3_Button_"+ltrim(str(i))
			if GetProperty( "Form_Main", cButton, "Value" )
				cDrive := aDrives[i][2] + ':'
				cVolume := aDrives[i][3]
				exit
			endif
		next
		do while !lDriveReady(cDrive)
			if !MsgRetryCancel("Drive "+cDrive+" is not ready!", "Error")
				for i := 1 to len(aDrives)
					cButton := "TB3_Button_"+ltrim(str(i))
					if aDrives[i][2] $ aSubDirectory[2][1]
						Form_Main.&(cButton).Value := .t.
						cDrive := aDrives[i][2] + ':'
						cVolume := aDrives[i][3]
						exit
					endif
				next
				exit
			endif
		enddo
		aNivel[2] := 1
		aBack[2] := .t.
		SplitChild_0.Label_2.Value	:= "[" + Lower(cVolume) + "]  " + ;
			Ltrim(Str(Int(HB_DISKSPACE(cDrive, HB_DISK_FREE) / 1024))) + " KB of " + ;
			Ltrim(Str(Int(HB_DISKSPACE(cDrive, HB_DISK_TOTAL) / 1024))) + " KB free"
		SplitChild_2.Title := cDrive + '\*.*'
		aSubDirectory[2][1] := cDrive
		GetDirectory(aSubDirectory[2][1] + '\*.*', 2)
		SplitChild_2.Grid_2.Value := 1
		SplitChild_2.Grid_2.SetFocus
	ENDIF

Return Nil

*--------------------------------------------------------*
Function MsgAbout()
*--------------------------------------------------------*
return MsgInfo( PROGRAM + " version" + VERSION + " - FREEWARE" + CRLF + ;
	"Copyright " + Chr(169) + COPYRIGHT + CRLF + CRLF + ;
	padc("eMail: gfilatov@inbox.ru", 40) + CRLF + CRLF + ;
	padc("This program is Freeware!", 40) + CRLF + ;
	padc("Copying is allowed!", 44), "About " + PROGRAM )

*--------------------------------------------------------*
Function ReReadFolder()
*--------------------------------------------------------*
local nBackValue := IF( nGridFocus = 1, SplitChild_1.Grid_1.Value, SplitChild_2.Grid_2.Value )

	GetDirectory( GetFull() + '\*.*', nGridFocus )

	IF nGridFocus = 1
		SplitChild_1.Grid_1.Value := nBackValue
		SplitChild_1.Grid_1.SetFocus
	ELSE
		SplitChild_2.Grid_2.Value := nBackValue
		SplitChild_2.Grid_2.SetFocus
	ENDIF

Return Nil

*--------------------------------------------------------*
Function HotKeySelectDrive( nFocus )
*--------------------------------------------------------*
LOCAL aDisks := {}, nDisk, nCurDisk, i, cButton

	Aeval(aDrives, {|e| Aadd(aDisks, " [-" + Lower( e[2] ) + "-]")})

	IF nFocus = 1
		for i := 1 to len(aDrives)
			cButton := "TB2_Button_"+ltrim(str(i))
			if GetProperty( "Form_Main", cButton, "Value" )
				nDisk := i
				exit
			endif
		next

		nCurDisk := nDisk

		STORE KEY ESCAPE OF SplitChild_1 TO bBlock
		RELEASE KEY ESCAPE OF SplitChild_1

		ON KEY ESCAPE OF SplitChild_1 ACTION ReleaseDriveCombo("1")

		@ 0,0 COMBOBOX Combo_1 ;
			OF SplitChild_1 ;
			WIDTH 52 HEIGHT 250 ;
			ITEMS aDisks VALUE nDisk ;
			BOLD ;
			ON LISTDISPLAY (lBlock := .T.) ;
			ON LISTCLOSE ( IF( nCurDisk != ( nDisk := SplitChild_1.Combo_1.Value ), ;
				( cButton := "TB2_Button_"+ltrim(str(nDisk)), ;
				SetProperty( "Form_Main", cButton, "Value", .T. ), ;
				SelectDrive( nFocus ) ), ), ReleaseDriveCombo("1") ) ;
			ON GOTFOCUS ComboboxShowList( _HMG_aControlHandles[ GetControlIndex( "Combo_1", "SplitChild_1" ) ] )

		SplitChild_1.Combo_1.SetFocus
	ELSE
		for i := 1 to len(aDrives)
			cButton := "TB3_Button_"+ltrim(str(i))
			if GetProperty( "Form_Main", cButton, "Value" )
				nDisk := i
				exit
			endif
		next

		nCurDisk := nDisk

		STORE KEY ESCAPE OF SplitChild_2 TO bBlock
		RELEASE KEY ESCAPE OF SplitChild_2

		ON KEY ESCAPE OF SplitChild_2 ACTION ReleaseDriveCombo("2")

		@ 0,0 COMBOBOX Combo_2 ;
			OF SplitChild_2 ;
			WIDTH 52 HEIGHT 250 ;
			ITEMS aDisks VALUE nDisk ;
			BOLD ;
			ON LISTDISPLAY (lBlock := .T.) ;
			ON LISTCLOSE ( IF( nCurDisk != ( nDisk := SplitChild_2.Combo_2.Value ), ;
				( cButton := "TB3_Button_"+ltrim(str(nDisk)), ;
				SetProperty( "Form_Main", cButton, "Value", .T. ), ;
				SelectDrive( nFocus ) ), ), ReleaseDriveCombo("2") ) ;
			ON GOTFOCUS ComboboxShowList( _HMG_aControlHandles[ GetControlIndex( "Combo_2", "SplitChild_2" ) ] )

		SplitChild_2.Combo_2.SetFocus
	ENDIF

Return Nil

*--------------------------------------------------------*
Function ReleaseDriveCombo( cFocus )
*--------------------------------------------------------*

	Domethod( "SplitChild_"+cFocus, "Combo_"+cFocus, "Release" )

	_ReleaseHotKey( "SplitChild_"+cFocus, 0, VK_ESCAPE )

	_DefineHotKey ( "SplitChild_"+cFocus, 0, VK_ESCAPE, bBlock )

	Domethod( "SplitChild_"+cFocus, "Grid_"+cFocus, "SetFocus" )

	Domethod( "SplitChild_"+cFocus, "Grid_"+cFocus, "Refresh" )

	lBlock := .f.

Return Nil

*--------------------------------------------------------*
FUNCTION CopyOrMoveFile( lCopy )
*--------------------------------------------------------*
LOCAL cPath := GetFull(), cName := GetName()
LOCAL cOldName := cPath +'\'+ cName, cType, cMsg, cFileName, cNewPath
LOCAL nPos := IF( nGridFocus = 1, SplitChild_1.Grid_1.Value, SplitChild_2.Grid_2.Value )

	nGridFocus := IF( nGridFocus = 1, 2, 1 )
	cNewPath := GetFull() + "\"
	nGridFocus := IF( nGridFocus = 1, 2, 1 )

	DEFAULT lCopy := .f.

	IF Empty( nPos ) .OR. cName = ".."
		MsgInfo( "No files selected!", PROGRAM )
	ELSE
		cType := Valtype( aDirectory[nGridFocus][ nPos ][ 2 ] )
		IF cType = "N"
			cMsg := IF( lCopy, 'Copy "' + cName + '" to', 'Rename/Move "' + cName + '" to' )
			cFileName := Alltrim( InputBox2 ( cMsg, PROGRAM, cNewPath + cName, 120000, "" ) )
			IF !EMPTY(cFileName)
				IF EMPTY(cFilePath(cFileName))
					cFileName := cPath + "\" + cFileName
				ENDIF
				IF lCopy
					IF !FILE( cFileName )
						CopyFile( cOldName, cFileName)
						nGridFocus := IF( nGridFocus = 1, 2, 1 )
						ReReadFolder()
						nGridFocus := IF( nGridFocus = 1, 2, 1 )
						ReReadFolder()
					ELSEIF UPPER(cOldName) = UPPER(cFileName)
						MsgInfo( 'You cannot copy a file to itself!', PROGRAM )
					ELSE
						IF MsgYesNo( 'Overwrite: ' + cFileName + CRLF + CRLF + 'with file: '+ cOldName + '?', PROGRAM )
							CopyFile( cOldName, cFileName)
							nGridFocus := IF( nGridFocus = 1, 2, 1 )
							ReReadFolder()
							nGridFocus := IF( nGridFocus = 1, 2, 1 )
							ReReadFolder()
						ENDIF
					ENDIF
				ELSE
					IF !FILE( cFileName )
						CopyFile( cOldName, cFileName)
						IF FILE( cFileName )
							FERASE( cOldName )
						ENDIF
						nGridFocus := IF( nGridFocus = 1, 2, 1 )
						ReReadFolder()
						nGridFocus := IF( nGridFocus = 1, 2, 1 )
						ReReadFolder()
					ELSEIF UPPER(cOldName) = UPPER(cFileName)
						MsgInfo( 'You cannot move a file to itself!', PROGRAM )
					ELSE
						IF MsgYesNo( 'Overwrite: ' + cFileName + CRLF + CRLF + 'with file: '+ cOldName + '?', PROGRAM )
							CopyFile( cOldName, cFileName)
							IF FILE( cFileName )
								FERASE( cOldName )
							ENDIF
							nGridFocus := IF( nGridFocus = 1, 2, 1 )
							ReReadFolder()
							nGridFocus := IF( nGridFocus = 1, 2, 1 )
							ReReadFolder()
						ENDIF
					ENDIF
				ENDIF
			ENDIF
		ENDIF
	ENDIF

RETURN NIL

*--------------------------------------------------------*
FUNCTION NewFolder()
*--------------------------------------------------------*
LOCAL cPath := GetFull(), cName := ""

	cName := Alltrim( InputBox2 ( 'New directory', PROGRAM, cName, 120000, "" ) )

	IF !EMPTY(cName)
		CreateFolder( cPath +'\'+ cName )
		ReReadFolder()
	ENDIF

RETURN NIL

*--------------------------------------------------------*
FUNCTION Delete_File()
// renamed: DeleteFile() -> Delete_File() | DeleteFile() 
// confilcts with same funcname in hbct.lib
*--------------------------------------------------------*
LOCAL cPath := GetFull(), cName := GetName()
LOCAL cDelete := cPath +'\'+ cName, cType, cMsgConfirm, aDir, i
LOCAL nPos := IF( nGridFocus = 1, SplitChild_1.Grid_1.Value, SplitChild_2.Grid_2.Value )

	IF Empty( nPos ) .OR. cName = ".."
		MsgInfo( "No files selected!", PROGRAM )
	ELSE
		cType := Valtype( aDirectory[nGridFocus][ nPos ][ 2 ] )
		cMsgConfirm := IF( cType = "N", ;
			"Do you really want to delete the selected file " + cName + "?", ;
			"Do you really want to delete the selected directory " + cName + "?" )

		IF cName <> ".." .AND. MsgOkCancel( cMsgConfirm, PROGRAM )

			IF cType = "N"
				FERASE( cDelete )
				IF File( cDelete )
					MsgAlert( 'Error: ' + cDelete + ' cannot be deleted!' + CRLF + CRLF + ;
						'Please remove the write protection!' )
				ENDIF
			ELSE
				aDir := Directory( cDelete + "\*.*", 'D' )
				IF ( i := Ascan( aDir, {|e| Alltrim( e[1] ) = "."} ) ) > 0
					Adel( aDir, i )
					Asize( aDir, Len( aDir ) - 1 )
					IF ( i := Ascan( aDir, {|e| Alltrim( e[1] ) = ".."} ) ) > 0
						Adel( aDir, i )
						Asize( aDir, Len( aDir ) - 1 )
					ENDIF
				ENDIF
				IF Len( aDir ) > 0
					IF MsgOkCancel( padc("The directory " + cDelete + " is not empty!", 60) + CRLF + ;
						"Do you want to delete it with all its files and subdirectories?", PROGRAM )
						ZapDirectory( cDelete + Chr(0) )
					ENDIF
				ELSE
					ZapDirectory( cDelete + Chr(0) )
				ENDIF
			ENDIF
			ReReadFolder()
			IF nGridFocus = 1
				SplitChild_1.Grid_1.Value := IF(nPos > 1, nPos - 1, nPos)
			ELSE
				SplitChild_2.Grid_2.Value := IF(nPos > 1, nPos - 1, nPos)
			ENDIF

		ENDIF
	ENDIF

RETURN NIL

*--------------------------------------------------------*
FUNCTION GetDirectory( cVar, nFocus )
*--------------------------------------------------------*
LOCAL aDir, aAux, nSortCol
LOCAL cDir, i, j

	cDir := Alltrim( cVar )
	aDir := Directory( cDir, 'D' )

	IF ( i := Ascan( aDir, {|e| Alltrim( e[1] ) = "."} ) ) > 0
		Adel( aDir, i )
		Asize( aDir, Len( aDir ) - 1 )
	ENDIF
	IF Len( aDir ) = 0
		AADD( aDir,  { "..", 0, Date(), Time() }  )
	ENDIF

	aDirectory[nFocus] := aDir

	FOR i = 1 to Len( aDirectory[nFocus] )

		FOR j = 1 TO Len( aDirectory[nFocus] )

			IF Lower( aDirectory[nFocus][i][1] ) <= Lower( aDirectory[nFocus][j][1] )

				IF SubStr( aDirectory[nFocus][i][1], 2, 1) <> '.' .AND. SubStr( aDirectory[nFocus][j][1], 2, 1) <> '.'

					aAux			:= aDirectory[nFocus][i]
					aDirectory[nFocus][i]	:= aDirectory[nFocus][j]
					aDirectory[nFocus][j]	:= aAux

				ENDIF
			ENDIF

		NEXT
	NEXT

	Aeval(aDirectory[nFocus], {|e| if(e[2] = 0 .AND. AT(".SWP", e[1]) = 0, ;
		(e[1] := "[" + UPPER(e[1]) + "]", e[2] := "<DIR>"), e[1] := LOWER(e[1]))})

	nSortCol := aSortCol[nFocus]
	IF nSortCol = 1
		Asort(aDirectory[nFocus], , , {|a,b| if(valtype(a[2]) # "N" .AND. valtype(b[2]) # "N", ;
			SUBSTR(a[1],2) < SUBSTR(b[1],2), if(valtype(a[2]) # "N", SUBSTR(a[1],2) < CHR(254)+b[1], ;
			if(valtype(b[2]) # "N", CHR(254)+a[1] < SUBSTR(b[1],2), a[1] < b[1])))})
	ELSEIF nSortCol = 2
		Asort(aDirectory[nFocus], , , {|a,b| if(valtype(a[2]) # "N" .AND. valtype(b[2]) # "N", ;
			SUBSTR(a[1],2) < SUBSTR(b[1],2), if(valtype(a[2]) # "N", SUBSTR(a[1],2) < CHR(254)+b[1], ;
			if(valtype(b[2]) # "N", CHR(254)+a[1] < SUBSTR(b[1],2), a[2] < b[2])))})
	ELSEIF nSortCol = 3
		Asort(aDirectory[nFocus], , , {|a,b| if(valtype(a[2]) # "N" .AND. valtype(b[2]) # "N", ;
			SUBSTR(a[1],2) < SUBSTR(b[1],2), if(valtype(a[2]) # "N", SUBSTR(a[1],2) < CHR(254)+b[1], ;
			if(valtype(b[2]) # "N", CHR(254)+a[1] < SUBSTR(b[1],2), a[3] < b[3])))})
	ELSE
		Asort(aDirectory[nFocus], , , {|a,b| if(valtype(a[2]) # "N" .AND. valtype(b[2]) # "N", ;
			SUBSTR(a[1],2) < SUBSTR(b[1],2), if(valtype(a[2]) # "N", SUBSTR(a[1],2) < CHR(254)+b[1], ;
			if(valtype(b[2]) # "N", CHR(254)+a[1] < SUBSTR(b[1],2), a[4] < b[4])))})
	ENDIF

	IF nFocus = 1
		SplitChild_1.Grid_1.DisableUpdate
		SplitChild_1.Grid_1.DeleteAllItems
		Aeval(aDirectory[nFocus], {|e| SplitChild_1.Grid_1.AddItem( { e[1], ;
			if(valtype(e[2])="N", STR(e[2]), e[2]), DTOC(e[3]), e[4] } )})
		SplitChild_1.Grid_1.Value := if(aBack[nFocus], aOldPos[nFocus][aNivel[nFocus]], 1)
		SplitChild_1.Grid_1.EnableUpdate
	ELSE
		SplitChild_2.Grid_2.DisableUpdate
		SplitChild_2.Grid_2.DeleteAllItems
		Aeval(aDirectory[nFocus], {|e| SplitChild_2.Grid_2.AddItem( { e[1], ;
			if(valtype(e[2])="N", STR(e[2]), e[2]), DTOC(e[3]), e[4] } )})
		SplitChild_2.Grid_2.Value := if(aBack[nFocus], aOldPos[nFocus][aNivel[nFocus]], 1)
		SplitChild_2.Grid_2.EnableUpdate
	ENDIF

RETURN NIL

*--------------------------------------------------------*
FUNCTION StepBack()
*--------------------------------------------------------*
LOCAL cDirectory := aSubDirectory[nGridFocus][1], i

IF Len( aDirectory[nGridFocus] ) > 0 .AND. ALLTRIM(aDirectory[nGridFocus][ 1, 1 ] ) = '[..]'
	aSubDirectory[nGridFocus][ aNivel[nGridFocus] ] := "" 
	IF aNivel[nGridFocus] > 1
		aNivel[nGridFocus] --
	ENDIF
	FOR i = 2 TO aNivel[nGridFocus]
		cDirectory += Substr(aSubDirectory[nGridFocus][ i ], 1, Len(aSubDirectory[nGridFocus][ i ]) - 1)
	NEXT
	aBack[nGridFocus] := .t.
	GetDirectory( cDirectory + '\*.*', nGridFocus )
ENDIF

RETURN NIL

*--------------------------------------------------------*
FUNCTION Verify()
*--------------------------------------------------------*
LOCAL nPos := IF( nGridFocus = 1, SplitChild_1.Grid_1.Value, SplitChild_2.Grid_2.Value )
LOCAL cDirectory := aSubDirectory[nGridFocus][1], i, cPath, cFile, cExt, cExe

IF !Empty( nPos )
	IF Len( aDirectory[nGridFocus] ) > 0
		IF Alltrim(aDirectory[nGridFocus][ nPos, 1 ] ) <> '[..]' .AND. Valtype(aDirectory[nGridFocus][ nPos, 2 ]) # "N"
			aOldPos[nGridFocus][aNivel[nGridFocus]] := nPos
			aNivel[nGridFocus] ++
			aSubDirectory[nGridFocus][ aNivel[nGridFocus] ] := '\' + Substr(aDirectory[nGridFocus][ nPos, 1 ], 2, Len(aDirectory[nGridFocus][ nPos, 1 ]) - 1)

			FOR i = 2 TO aNivel[nGridFocus]
				cDirectory += Substr(aSubDirectory[nGridFocus][ i ], 1, Len(aSubDirectory[nGridFocus][ i ]) - 1)
			NEXT
			aBack[nGridFocus] := .f.
			GetDirectory( cDirectory + '\*.*', nGridFocus )

		ELSEIF ALLTRIM(aDirectory[nGridFocus][ nPos, 1 ] ) = '[..]'
			aSubDirectory[nGridFocus][ aNivel[nGridFocus] ] := "" 
			IF aNivel[nGridFocus] > 1
				aNivel[nGridFocus] --
			ENDIF
			FOR i = 2 TO aNivel[nGridFocus]
				cDirectory += Substr(aSubDirectory[nGridFocus][ i ], 1, Len(aSubDirectory[nGridFocus][ i ]) - 1)
			NEXT
			aBack[nGridFocus] := .t.
			GetDirectory( cDirectory + '\*.*', nGridFocus )
		ELSE
			cPath := GetFull()
			cFile := GetName()
			cExt := GetExt()
			IF cExt = 'EXE' .or. cExt = 'BAT' .or. cExt = 'COM'
				_Execute ( 0, , cFile, , cPath, 5 )
			ELSE
				cExe := GetOpenCommand(cExt)
				IF !Empty(cExe)
					cFile := cPath+'\'+cFile
					_Execute ( 0, , cExe, IF(At(" ", cFile) > 0, '"'+cFile+'"', cFile), cPath, 5 )
				ELSE
					IF cExt='JPG' .or. cExt='JPEG' .or. cExt='BMP' .or. cExt='GIF' .or. cExt='ICO'
						ShowImage()
					ELSEIF cExt='AVI' .or. cExt = 'MPG' .or. cExt = 'MPEG'
						PlayVideo()
					ELSEIF cExt = 'WAV' .or. cExt = 'MP3' 
						PlayMusic()
					ELSEIF cExt = 'TXT' .or. cExt = 'INI' .or. cExt = 'DIZ' .or. cExt = 'PRG' .or. cExt = 'CH' .or. empty(cExt)
						TextEdit()
					ELSE
						MsgAlert( 'Error executing program!' )
					ENDIF
				ENDIF
			ENDIF
		ENDIF
	ENDIF
ENDIF

RETURN NIL

*--------------------------------------------------------*
FUNCTION CurrentDirectory()
*--------------------------------------------------------*
LOCAL cPath := GetFull(), cName := GetName()
LOCAL cText := cPath + '\' + cName

	IF nGridFocus = 1
		SplitChild_1.Title := cPath + '\*.*'
		SplitChild_3.Label_3.Value := cText
	ELSE
		SplitChild_2.Title := cPath + '\*.*'
		SplitChild_3.Label_4.Value := cText
	ENDIF

RETURN NIL

*--------------------------------------------------------*
FUNCTION GetExt()
*--------------------------------------------------------*
LOCAL cExtension := "", cFile := GetName()
LOCAL nPosition  := Rat( '.', Alltrim(cFile) ) 

	IF nPosition > 0
		cExtension := SubStr( cFile, nPosition + 1, Len( Alltrim(cFile) ) )
	ENDIF

RETURN Upper(cExtension)

*--------------------------------------------------------*
FUNCTION GetName()
*--------------------------------------------------------*
LOCAL cText := "", nPos

	IF ( nPos := IF( nGridFocus = 1, SplitChild_1.Grid_1.Value, SplitChild_2.Grid_2.Value ) ) > 0
		cText:= IF( valtype(aDirectory[nGridFocus][ nPos, 2 ]) # "N", ;
			Substr(aDirectory[nGridFocus][ nPos, 1], 2, Len(aDirectory[nGridFocus][ nPos, 1 ]) - 2), ;
			aDirectory[nGridFocus][ nPos, 1] )
	ENDIF

RETURN ALLTRIM( cText )

*--------------------------------------------------------*
FUNCTION GetFull()
*--------------------------------------------------------*
LOCAL cText := aSubDirectory[nGridFocus][1], i

	FOR i = 2 TO aNivel[nGridFocus]
		cText += SubStr(aSubDirectory[nGridFocus][ i ], 1, Len(aSubDirectory[nGridFocus][ i ]) - 1)
	NEXT

RETURN cText

*--------------------------------------------------------*
FUNCTION TextCreate()
*--------------------------------------------------------*
LOCAL cPath := GetFull(), cName := GetName(), cFile

	cName := IF(cName # UPPER(cName), cName, "" )

	cFile := Alltrim( InputBox2 ( "Enter file name to edit:", PROGRAM, cName, 120000, "" ) )
	IF !EMPTY(cFile)
		cFile := cPath +'\'+ cFile
		If ! File( cFile )
			FClose( FCreate( cFile ) )
		EndIf
		TextEdit( cFile, Substr(cFile, Rat(".", cFile) + 1) )
		IF ( Directory(cFile)[1][2] = 0 )
			Ferase(cFile)
		ELSE
			ReReadFolder()
		ENDIF
	ENDIF

RETURN NIL

*--------------------------------------------------------*
FUNCTION TextEdit( cFile, cExt, lReadOnly )
*--------------------------------------------------------*
LOCAL cText

	DEFAULT cFile := GetFull()+'\'+GetName(), lReadOnly := .F., cExt := GetExt()

	IF cExt='JPG' .or. cExt='JPEG' .or. cExt='BMP' .or. cExt='GIF' .or. cExt='ICO'
		ShowImage()
	ELSEIF cExt='AVI' .or. cExt = 'MPG' .or. cExt = 'MPEG'
		PlayVideo()
	ELSEIF cExt = 'WAV' .or. cExt = 'MP3' 
		PlayMusic()
	ELSE
		cText := MEMOREAD( cFile )
		IF HB_ISOEM(cText)
			cText := HB_OEMTOANSI(cText)
		ENDIF

		DEFINE WINDOW wTextEdit ;
			AT 0, 0 WIDTH Form_Main.Width - 20 HEIGHT Form_Main.Height - 44 ;
			TITLE cFile ;
			ICON 'MAIN';
			MODAL ;
			ON INIT IF(lReadOnly, wTextEdit.Btn_1.SetFocus, wTextEdit.Edit1.SetFocus) ;
			ON PAINT ResizeText() ;
			ON RELEASE IF( nGridFocus = 1, SplitChild_1.Grid_1.SetFocus, SplitChild_2.Grid_2.SetFocus )

			DEFINE STATUSBAR 
				STATUSITEM cFile WIDTH wTextEdit.width
			END STATUSBAR

			@ 0,0 BUTTON Btn_1 ;
				CAPTION '&Cancel' ;
				ACTION wTextEdit.Release ;
				WIDTH 80 HEIGHT 20

			IF lReadOnly

				@ 21,0 EDITBOX Edit1 ;
					WIDTH 0 HEIGHT 0 ;
					VALUE cText ;
					FONT 'Arial' SIZE 9 ;
					MAXLENGTH 65535 READONLY NOTABSTOP
			ELSE
				@ 0,82 BUTTON Btn_2 ;
					CAPTION '&Save' ;
					ACTION { || Memowrit( cFile, wTextEdit.Edit1.Value ) } ;
					WIDTH 80 HEIGHT 20

				@ 21,0 EDITBOX Edit1 ;
					WIDTH 0 HEIGHT 0 ;
					VALUE cText ;
					FONT 'Arial' SIZE 9 ;
					MAXLENGTH 65535
			ENDIF

			ON KEY ESCAPE ACTION wTextEdit.Release

		END WINDOW

		wTextEdit.center
		wTextEdit.activate
	ENDIF

RETURN NIL

*--------------------------------------------------------*
FUNCTION ResizeText()
*--------------------------------------------------------*

	wTextEdit.Edit1.width  := wTextEdit.width - 6
	wTextEdit.Edit1.height := wTextEdit.height - 72

RETURN NIL

*--------------------------------------------------------*
FUNCTION ShowImage()
*--------------------------------------------------------*
LOCAL cFile := GetFull()+'\'+GetName(), cExt := GetExt()

	DEFINE WINDOW wImage ;
		AT 0, 0 WIDTH IF(cExt = "ICO", 200, 400) HEIGHT IF(cExt = "ICO", 200, 400) ;
		TITLE cFile ;
		ICON 'MAIN';
		CHILD NOMAXIMIZE NOMINIMIZE NOSIZE ;
		ON RELEASE IF( nGridFocus = 1, SplitChild_1.Grid_1.SetFocus, SplitChild_2.Grid_2.SetFocus )

		@ 0, 0 IMAGE Image_1 PICTURE cFile WIDTH 390 HEIGHT 360

		ON KEY ESCAPE ACTION wImage.Release

	END WINDOW

	wImage.Image_1.Width := IF(cExt = "ICO", 32, wImage.Width - 6)
	wImage.Image_1.Height:= IF(cExt = "ICO", 32, wImage.Height- 28)

	wImage.Center
	wImage.Activate

RETURN NIL

*--------------------------------------------------------*
FUNCTION PlayVideo()
*--------------------------------------------------------*
LOCAL cFile := GetFull()+'\'+GetName()

	DEFINE WINDOW wVideo ;
		AT 0, 0 WIDTH 400 HEIGHT 400 ;
		TITLE cFile ;
		ICON 'MAIN';
		CHILD NOMAXIMIZE NOMINIMIZE NOSIZE ;
		ON INIT wVideo.Ani_1.Play() ;
		ON RELEASE IF( nGridFocus = 1, SplitChild_1.Grid_1.SetFocus, SplitChild_2.Grid_2.SetFocus )

		@ 00, 0 BUTTON Btn1 CAPTION '&Play' ACTION wVideo.Ani_1.Play() WIDTH 80 HEIGHT 20
		@ 00,82 BUTTON Btn2 CAPTION '&Cancel' ACTION wVideo.Release WIDTH 80 HEIGHT 20

		@ 21, 0 ANIMATEBOX Ani_1 WIDTH 390 HEIGHT 360 FILE cFile

		ON KEY ESCAPE ACTION wVideo.Release

	END WINDOW

	wVideo.Ani_1.Width := wVideo.Width - 6
	wVideo.Ani_1.Height:= wVideo.Height- 46

	wVideo.Center
	wVideo.Activate

RETURN NIL

*--------------------------------------------------------*
FUNCTION PlayMusic()
*--------------------------------------------------------*
LOCAL cFile := GetFull()+'\'+GetName()

	DEFINE WINDOW wMusic ;
		AT 0, 0 WIDTH 400 HEIGHT 54 ;
		TITLE cFile ;
		ICON 'MAIN';
		CHILD NOMAXIMIZE NOMINIMIZE NOSIZE ;
		ON INIT wMusic.Play_1.Play() ;
		ON RELEASE IF( nGridFocus = 1, SplitChild_1.Grid_1.SetFocus, SplitChild_2.Grid_2.SetFocus )

		@ 0, 0 PLAYER Play_1 WIDTH 394 HEIGHT 28 FILE cFile NOOPEN //SHOWALL

	END WINDOW

	wMusic.center
	wMusic.Activate

RETURN NIL

*--------------------------------------------------------*
Static Function AddRunCommand( cCommand )
*--------------------------------------------------------*
local aItems := {}, i

	for i := 1 to Form_Main.Combo_1.ItemCount
		Aadd( aItems, Alltrim( Form_Main.Combo_1.Item( i ) ) )
	next

	if Ascan(aItems, {|e| Lower(e)=Lower(Alltrim(cCommand))}) = 0
		Form_Main.Combo_1.AddItem( cCommand )
	endif

Return Nil

*--------------------------------------------------------*
Static Function GetDrives()
*--------------------------------------------------------*
local n, cDrv, nDrv, cVolume := "", aDrive := {}

for n := 1 To 26

	cDrv := Chr( 64 + n )

	nDrv := GetDriveType( cDrv + ":\" + Chr(0) )

	if nDrv > 1

		if nDrv == 2 .and. Upper(cDrv) == "A"
			cVolume := [3 1/2"]
		else
			cVolume := ""
			GetVolumeInformation( cDrv + ":\", @cVolume )
		endif

		Aadd( aDrive, { if(n = 1, 1, nDrv), cDrv, IF(Empty(cVolume), "none", cVolume) } )

	endif

next

Return aDrive

*--------------------------------------------------------*
Static Function GetOpenCommand( cExt )
*--------------------------------------------------------*
Local oReg, cVar1, cVar2 := "", nPos

	If ! ValType( cExt ) == "C"
		Return ""
	Endif

	If ! Left( cExt, 1 ) == "."
		cExt := "." + cExt
	Endif

	oReg := TReg32():New( HKEY_CLASSES_ROOT, cExt, .f. )
	cVar1 := RTrim( StrTran( oReg:Get( Nil, "" ), Chr(0), " " ) ) // i.e look for (Default) key
	oReg:close()

	If ! Empty( cVar1 )
		oReg := TReg32():New( HKEY_CLASSES_ROOT, cVar1 + "\shell\open\command", .f. )
		cVar2 := RTrim( StrTran( oReg:Get( Nil, "" ), Chr(0), " " ) )  // i.e look for (Default) key
		oReg:close()

		If ( nPos := RAt( " %1", cVar2 ) ) > 0        // look for param placeholder without the quotes (ie notepad)
			cVar2 := SubStr( cVar2, 1, nPos )
		Elseif ( nPos := RAt( '"%', cVar2 ) ) > 0     // look for stuff like "%1", "%L", and so forth (ie, with quotes)
			cVar2 := SubStr( cVar2, 1, nPos - 1 )
		Elseif ( nPos := RAt( '%', cVar2 ) ) > 0      // look for stuff like "%1", "%L", and so forth (ie, without quotes)
			cVar2 := SubStr( cVar2, 1, nPos - 1 )
		Elseif ( nPos := RAt( ' /', cVar2 ) ) > 0     // look for stuff like "/"
			cVar2 := SubStr( cVar2, 1, nPos - 1 )
		Endif
	Endif

Return RTrim( cVar2 )

*--------------------------------------------------------*
Static Function lDriveReady( cDrv )
*--------------------------------------------------------*
   LOCAL cCurDir := CurDrive() + ":\" + CurDir()
   Local lcheck := .f., n

   FOR n := 1 TO 3
       lcheck := ( DirChange(cDrv) == 0 )
       INKEY(.02)
   NEXT

   IF lcheck
      DirChange( cCurDir )
   ENDIF

Return lcheck

*--------------------------------------------------------*
Static Function CPUName()
*--------------------------------------------------------*
Local cName := "", n

IF IsWinNT()
	cName := GetRegVar( HKEY_LOCAL_MACHINE, "HARDWARE\DESCRIPTION\System\CentralProcessor\0", "ProcessorNameString" )
	cName := IF(( n := At("processor", cName) ) > 0, Left(cName, n-1), cName)
	cName := IF(( n := At("CPU", cName) ) > 0, Left(cName, n-1), cName)
ENDIF

return lTrim(cName)

*--------------------------------------------------------*
Static Function BiosName()
*--------------------------------------------------------*
Local cName

IF IsWinNT()
	cName := Token( GetRegVar( HKEY_LOCAL_MACHINE, "HARDWARE\DESCRIPTION\System", "SystemBiosVersion" ), " " ) + ", " + ;
	GetRegVar( HKEY_LOCAL_MACHINE, "HARDWARE\DESCRIPTION\System", "SystemBiosDate" ) 
ELSE
	cName := Token( GetRegVar( HKEY_LOCAL_MACHINE, "Enum\Root\*PNP0C01\0000", "BIOSVersion" ), " " ) + ", " + ;
	GetRegVar( HKEY_LOCAL_MACHINE, "Enum\Root\*PNP0C01\0000", "BIOSDate" )
ENDIF

return cName

*--------------------------------------------------------*
Static Function VideoName()
*--------------------------------------------------------*
Local cName := "", oReg, cReg := "", oKey, nId := 0

IF IsWinNT()
	cName := GetRegVar( HKEY_LOCAL_MACHINE, "SYSTEM\CurrentControlSet\Control\Class\{4D36E968-E325-11CE-BFC1-08002BE10318}\0000", "DriverDesc" )
ELSE
	oReg := TReg32():New( HKEY_LOCAL_MACHINE, "System\CurrentControlSet\Services\Class\Display" )

	While RegEnumKey( oReg:nHandle, nId++, @cReg ) == 0

		oKey := TReg32():New( HKEY_LOCAL_MACHINE, "System\CurrentControlSet\Services\Class\Display\" + cReg )

		cName := oKey:Get( "DriverDesc" )

		oKey:Close()

	ENDDO

	oReg:Close()
ENDIF

return cName

*--------------------------------------------------------*
Static Function GetRegVar(nKey, cRegKey, cSubKey, uValue)
*--------------------------------------------------------*
Local oReg, cValue

   nKey := IF(nKey == NIL, HKEY_CURRENT_USER, nKey)
   uValue := IF(uValue == NIL, "", uValue)
   oReg := TReg32():Create(nKey, cRegKey)
   cValue := oReg:Get(cSubKey, uValue)
   oReg:Close()

RETURN cValue

*--------------------------------------------------------*
Static Function ComPortCount()
*--------------------------------------------------------*
Local nCount := 0, i

	for i = 1 to 9
		IF ComConnect('COM'+ltrim(str(i)), '4800,E,7,1')
			nCount++
			ComDisConnect()
		ELSE
			EXIT
		ENDIF
	next

Return nCount

*--------------------------------------------------------*
Static Function WinUpTime()
*--------------------------------------------------------*
   local t := Int( GetTickCount() / 10 )
   local nDAYS, nHRS, nMINS, nSECS

   nDAYS := Int( t / ( 360000 * 24 ) )
   nHRS  := int( ( t - nDAYS * 360000 * 24 ) / 360000 )
   nMINS := int( ( t - nDAYS * 360000 * 24 - nHRS * 360000 ) / 6000 )
   nSECS := int( ( t - nDAYS * 360000 * 24 - nHRS * 360000 - nMINS * 6000 ) / 100 )

Return IF(Empty(nDAYS), "", ltrim( str( nDAYS, 2 ) ) + "d ") + ltrim( str( nHRS, 2 ) ) + "h " + ;
	strzero( nMINS, 2 ) + "m " + strzero( nSECS, 2 ) + "s"

*--------------------------------------------------------*
Static Function cFilePath( cPathMask )
*--------------------------------------------------------*
LOCAL n := RAt( "\", cPathMask )

Return If( n > 0, Upper( Left( cPathMask, n - 1) ), ;
	If( At( ":", cPathMask ) == 2, ;
           Upper( Left( cPathMask, 2 ) ), "" ) )

*-----------------------------------------------------------------------------*
Function _SetGridCaption ( ControlName, ParentForm , Column , Value , nJustify )
*-----------------------------------------------------------------------------*
Local i , h , t

	i := GetControlIndex ( ControlName, ParentForm )

	h := _HMG_aControlhandles [i]

	t := GetControlType ( ControlName, ParentForm )

	_HMG_aControlCaption [i] [Column] := Value 

	If t == 'GRID'
		SETGRIDCOLUMNHEADER ( h , Column , Value , nJustify )
	EndIf

Return Nil

*--------------------------------------------------------*
Static Function Token( cStr, cDelim, nToken )
*--------------------------------------------------------*
   LOCAL nPos, cToken, nCounter := 1

   DEFAULT nToken := 1

   WHILE .T.

      IF ( nPos := At( cDelim, cStr ) ) == 0

         IF nCounter == nToken
            cToken := cStr
         ENDIF

         EXIT

      ENDIF

      IF ++ nCounter > nToken
         cToken := LEFT( cStr, nPos - 1 )
         EXIT
      ENDIF

      cStr := Substr( cStr, nPos + 1 )

   ENDDO

RETURN cToken

*-----------------------------------------------------------------------------*
Function InputBox2 ( cInputPrompt, cDialogCaption, cDefaultValue, nTimeout, cTimeoutValue )
*-----------------------------------------------------------------------------*
Local RetVal := ''

	DEFAULT cInputPrompt	:= "", cDialogCaption := "", cDefaultValue := ""

	DEFINE WINDOW _InputBox 		;
		AT 0,0 			;
		WIDTH 350 			;
		HEIGHT 124			;
		TITLE cDialogCaption		;
		ICON 'MAIN'			;
		MODAL 				;
		NOSIZE 			;
		FONT 'MS Sans Serif'		;
		SIZE 9

		ON KEY ESCAPE ACTION ( _HMG_DialogCancelled := .T., _InputBox.Release )

		@ 07,14 LABEL _Label		;
			VALUE cInputPrompt	;
			AUTOSIZE 

		@ 34,14 TEXTBOX _TextBox	;
			VALUE cDefaultValue	;
			HEIGHT 21		;
			WIDTH 314		;
			ON ENTER ( _HMG_DialogCancelled := .F., RetVal := _InputBox._TextBox.Value, _InputBox.Release )

		@ 67,138 BUTTON _Ok		;
			CAPTION 'OK'		;
			ACTION ( _HMG_DialogCancelled := .F., RetVal := _InputBox._TextBox.Value, _InputBox.Release ) ;
			WIDTH 92 ;
			HEIGHT 24

		@ 67,236 BUTTON _Cancel	;
			CAPTION 'Cancel'	;
			ACTION ( _HMG_DialogCancelled := .T., _InputBox.Release ) ;
			WIDTH 92 ;
			HEIGHT 24

			If ValType (nTimeout) != 'U'
				If ValType (cTimeoutValue) != 'U'
					DEFINE TIMER _InputBox ;
						INTERVAL nTimeout ;
						ACTION  ( RetVal := cTimeoutValue , _InputBox.Release ) 
				Else
					DEFINE TIMER _InputBox ;
						INTERVAL nTimeout ;
						ACTION _InputBox.Release
				EndIf
			EndIf

	END WINDOW

	_InputBox._TextBox.SetFocus 

	CENTER WINDOW _InputBox

	ACTIVATE WINDOW _InputBox	

Return ( RetVal )


#pragma BEGINDUMP

#include <windows.h>
#include "hbapi.h"
#include "hbapiitm.h"
#include "commctrl.h"

static HANDLE  ComNum;

HB_FUNC( COMCONNECT )
{
   static DCB BarDCB;

   static  long  retval;

   static  COMMTIMEOUTS  CtimeOut;

   static  char  Msg[2048];
   static  const char *ComNumber;
   static  const char *Comsettings;

   ComNumber = hb_parc(1);
   Comsettings = hb_parc(2);

   // Open the communications port for read/write (&HC0000000).
   // Must specify existing file (3).
   ComNum=CreateFile(ComNumber,GENERIC_READ|GENERIC_WRITE,0,NULL,OPEN_EXISTING,FILE_ATTRIBUTE_NORMAL,NULL);
   if(ComNum==INVALID_HANDLE_VALUE)
   {
//      strcat(Msg,"Com Port ");
//      strcat(Msg,ComNumber);
//      strcat(Msg," not available.");
//      MessageBox (GetActiveWindow(),Msg,"TestCom",MB_ICONWARNING);
      hb_retl(FALSE);
      return;
   }
   // Setup Time Outs for com port
   CtimeOut.ReadIntervalTimeout=10;
   CtimeOut.ReadTotalTimeoutConstant=1;
   CtimeOut.ReadTotalTimeoutMultiplier=1;
   CtimeOut.WriteTotalTimeoutConstant=10;
   CtimeOut.WriteTotalTimeoutMultiplier=1;
   retval=SetCommTimeouts(ComNum,&CtimeOut);
   if(retval==-1)
   {
      retval=GetLastError();
      strcat(Msg,"Unable to set timeouts for port ");
      strcat(Msg,ComNumber);
      strcat(Msg," Error: ");
      strcat(Msg,(char *)(retval));
      MessageBox (GetActiveWindow(),Msg,"TestCom",MB_ICONWARNING);
      CloseHandle(ComNum);
      hb_retl(FALSE);
   }
   retval=BuildCommDCB(Comsettings,&BarDCB);
   if(retval==-1)
   {
      retval=GetLastError();
      strcat(Msg,"Unable to build Comm DCB");
      strcat(Msg,Comsettings);
      strcat(Msg," Error: ");
      strcat(Msg,(char *)(retval));
      MessageBox (GetActiveWindow(),Msg,"TestCom",MB_ICONWARNING);
      CloseHandle(ComNum);
      hb_retl(FALSE);
   }
   retval=SetCommState(ComNum,&BarDCB);
   if(retval==-1)
   {
      retval=GetLastError();
      strcat(Msg,"Unable to set Comm DCB");
      strcat(Msg,Comsettings);
      strcat(Msg," Error: ");
      strcat(Msg,(char *)(retval));
      MessageBox (GetActiveWindow(),Msg,"TestCom",MB_ICONWARNING);
      CloseHandle(ComNum);
      hb_retl(FALSE);
   }
   hb_retl(TRUE);
}

HB_FUNC( COMDISCONNECT )
{
   CloseHandle(ComNum) ;
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

HB_FUNC(GETVOLUMEINFORMATION)
{
   char *VolumeNameBuffer     = (char *) hb_xgrab( MAX_PATH ) ;
   DWORD VolumeSerialNumber                                   ;
   DWORD MaximumComponentLength                               ;
   DWORD FileSystemFlags                                      ;
   char *FileSystemNameBuffer = (char *) hb_xgrab( MAX_PATH ) ;
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

HB_FUNC( GETDEFAULTPRINTER )
{
	char PrinterDefault[128] ;
	OSVERSIONINFO osvi;
	DWORD BuffSize = 256;
	char* p;

	osvi.dwOSVersionInfoSize = sizeof(OSVERSIONINFO);
	GetVersionEx(&osvi);

	if (osvi.dwPlatformId == VER_PLATFORM_WIN32_NT)
	{
			GetProfileString("windows","device","",PrinterDefault,BuffSize);
			p = PrinterDefault;
			while (*p != '0' && *p != ',')
				++p;
			*p = '0';
	}

	hb_retc(PrinterDefault);
}

HB_FUNC ( REGENUMKEY )
{
   char buffer[ 128 ];

   hb_retnl( RegEnumKey( ( HKEY ) hb_parnl( 1 ), hb_parnl( 2 ), buffer, 128 ) );
   hb_storc( buffer, 3 );
}

HB_FUNC( COPYFILE )
{
   hb_retnl( (LONG) CopyFile( (LPCSTR) hb_parc(1), (LPCSTR) hb_parc(2), ISNIL(3) ? FALSE : (BOOL) hb_parl(3) ) );
}

HB_FUNC ( COMBOBOXSHOWLIST )
{
   SendMessage( (HWND) hb_parnl( 1 ), CB_SHOWDROPDOWN, 1, 0 );
}

HB_FUNC( HB_ISOEM )
{
   LPBYTE pString = ( LPBYTE ) hb_parc( 1 );
   WORD  w = 0, wLen = hb_parclen( 1 );
   BOOL  bOem = FALSE;

   while( w < wLen && ! bOem )
   {
      bOem = pString[ w ] >= 128 && pString[ w ] <= 168;
      w++;
   }

   hb_retl( bOem );
}

HB_FUNC( CREATEDC )
{
   hb_retnl( ( LONG ) CreateDC( hb_parc( 1 ), hb_parc( 2 ), hb_parc( 3 ), 0 ) );
}

HB_FUNC( DELETEDC )
{
   hb_retl( DeleteDC( ( HDC ) hb_parnl( 1 ) ) );
}

HB_FUNC( GETDISPLAYCOLORS )
{
   DEVMODE  lpDevMode;

   if ( EnumDisplaySettings( NULL, ENUM_CURRENT_SETTINGS, &lpDevMode ) )
   {
	hb_retnl( lpDevMode.dmBitsPerPel );
   }
   else
   {
	hb_retnl( 0 );
   }
}

HB_FUNC( GETTICKCOUNT )
{
   hb_retnl( (LONG) GetTickCount() ) ;
}

HB_FUNC ( ZAPDIRECTORY )
{
	SHFILEOPSTRUCT sh;

	sh.hwnd              = GetActiveWindow();
	sh.wFunc             = FO_DELETE;
	sh.pFrom             = hb_parc(1);
	sh.pTo               = NULL;
	sh.fFlags            = FOF_NOCONFIRMATION | FOF_SILENT;
	sh.hNameMappings     = 0;
	sh.lpszProgressTitle = NULL;

	SHFileOperation (&sh);
}

HB_FUNC ( SHOWFILEPROPERTIES )
{
	SHELLEXECUTEINFO ShExecInfo;

	ShExecInfo.cbSize       = sizeof(SHELLEXECUTEINFO);
	ShExecInfo.fMask        = SEE_MASK_INVOKEIDLIST;
	ShExecInfo.hwnd         = GetActiveWindow();
	ShExecInfo.lpVerb       = "properties";
	ShExecInfo.lpFile       = hb_parc(1);
	ShExecInfo.lpParameters = ""; 
	ShExecInfo.lpDirectory  = NULL;
	ShExecInfo.nShow        = SW_SHOW;
	ShExecInfo.hInstApp     = NULL; 

	ShellExecuteEx(&ShExecInfo);
}
/*
HB_FUNC( MEMORYSTATUS )
{
      MEMORYSTATUS mst;
      long n = hb_parnl(1);

      mst.dwLength = sizeof( MEMORYSTATUS );
      GlobalMemoryStatus( &mst );

      switch( n )
      {
         case 1:  hb_retnl( mst.dwTotalPhys / 1024 ) ; break;
         case 2:  hb_retnl( mst.dwAvailPhys / 1024 ) ; break;
         case 3:  hb_retnl( mst.dwTotalPageFile / 1024 ) ; break;
         case 4:  hb_retnl( mst.dwAvailPageFile / 1024 ) ; break;
         case 5:  hb_retnl( mst.dwMemoryLoad ) ; break;
         default: hb_retnl( 0 ) ;
      }
}
*/
#pragma ENDDUMP
