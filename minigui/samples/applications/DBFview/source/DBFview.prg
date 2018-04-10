/*
 * MINIGUI - Harbour Win32 GUI library
 *
 * Copyright 2002-09 Roberto Lopez <harbourminigui@gmail.com>
 * http://harbourminigui.googlepages.com/
 *
 * Copyright 2004-09 Grigory Filatov <gfilatov@inbox.ru>
*/

#ifdef __XHARBOUR__
   REQUEST HB_CODEPAGE_RUWIN, HB_CODEPAGE_RU866
   #define RUWIN "RUWIN"
#else
   REQUEST HB_CODEPAGE_RU1251, HB_CODEPAGE_RU866
   #define RUWIN "RU1251"
#endif
REQUEST HB_CODEPAGE_PLWIN, HB_CODEPAGE_PL852, HB_CODEPAGE_PLMAZ, HB_CODEPAGE_PLISO
REQUEST DBFCDX, DBFFPT
REQUEST Descend
REQUEST Stuff, StrTran, RAt, Left, Right, Pad, PadC, PadR, PadL

#include "minigui.ch"
#include "dbstruct.ch"
#include "fileio.ch"
#include "error.ch"

#define PROGRAM 'DBFview'
#define VERSION ' 0.78'
#define COPYRIGHT ' 2004-2009 Grigory Filatov'

#define MsgAlert( c ) MsgEXCLAMATION( c, PROGRAM, , .f. )
#define MsgYesNo( c ) MsgYesNo( c, PROGRAM, , , .f. )
#define MAX_AREA 12

Static nSelect := 0, nFocus := 0, aArea := {}, ;
	nGoto := 1, nGoRow := 1, nGoRecord := 1, ;
	nChildTop, aChildWnd, aChildFont, aChildCP, ;
	aSearch := {}, aReplace := {}, nHArea, ;
	nSearch := 1, nReplace := 1, nColumns := 1, ;
	lMatchCase := .F., lMatchWhole := .F., ;
	nDirect := 3, cDateFormat := "DD.MM.YYYY", aBackClr := { 255, 255, 255 }

Memvar cBaseLang, aLangStrings
Memvar cFileIni, cFileLng
Memvar nLeft, nWidth, nHeight
Memvar aListFont, aSizeFont
Memvar cPath, lXPTheme, lIsVistaOrLater

Memvar cDBFile
Memvar lFirstFind, lFind, cFind, cFindStr, cField, cAlias, cReplStr, nCurRec

*--------------------------------------------------------*
#ifndef __XHARBOUR__
   Procedure Main( cDBF, ... )
#else
   Procedure Main( cDBF )
#endif
*--------------------------------------------------------*
   LOCAL hWnd := FindWindow( PROGRAM ), cChildForm, i, nStatusWidth, aDesk := GetDesktopArea()
   LOCAL cFont := "MS Sans Serif", nSize := 10, lBold := .F., lItalic := .F., aFntClr := {0,0,0}
   LOCAL nTop := aDesk[2], aPar, cDBF2Open := ""

	DEFAULT cDBF := ""

	IF PCOUNT() > 0

		aPar := HB_aParams()

		For i := 1 To Len(aPar)
			cDBF2Open += IF(valtype(aPar[i])=="C", aPar[i] + " ", "")
		Next
		cDBF := Trim(cDBF2Open)

	ENDIF

   IF hWnd > 0

      IF IsIconic( hWnd )

         _Restore( hWnd )

      ELSE

         SetActiveWindow( hWnd )
         _Minimize( hWnd )
         _Restore( hWnd )

      ENDIF

	cDBF2Open := IF(!EMPTY(cDBF), cDBF, "")
	IF(!EMPTY(cDBF2Open), MySendMsg(hWnd, cDBF2Open), )

   ELSE

	PRIVATE cBaseLang := "English", aLangStrings := {}, cFileIni, cFileLng
	PRIVATE nLeft := aDesk[1], nWidth := aDesk[3] - aDesk[1], nHeight := aDesk[4] - aDesk[2]
	PRIVATE aListFont := GetFonts(), aSizeFont := { '8','9','10','11','12','14','16','18','20' }
	PRIVATE cPath := GetStartUpFolder(), lXPTheme := IsThemed()
	PRIVATE lIsVistaOrLater := IsVistaOrLater()

	cFileIni := cPath + '\DBFview.ini'
	cFileLng := cPath + '\DBFview.lng'

	IF FILE(cFileIni)
		BEGIN INI FILE cFileIni
			GET cFont SECTION "Font" ENTRY "Name" DEFAULT cFont
			GET nSize SECTION "Font" ENTRY "Size" DEFAULT nSize
			GET lBold SECTION "Font" ENTRY "Bold" DEFAULT lBold
			GET lItalic SECTION "Font" ENTRY "Italic" DEFAULT lItalic
			GET aFntClr SECTION "Font" ENTRY "Color" DEFAULT aFntClr
			GET aBackClr SECTION "Interface" ENTRY "Color" DEFAULT aBackClr
			GET cBaseLang SECTION "Interface" ENTRY "Language" DEFAULT cBaseLang
			GET cDateFormat SECTION "Interface" ENTRY "Date" DEFAULT cDateFormat
		END INI
	ENDIF

	aLangStrings := GetLangArr()

	IF FILE(cFileLng)
		IF cBaseLang # "English"
			LoadLangArr()
		ENDIF
	ELSE
		BEGIN INI FILE cFileLng
			For i := 1 To Len(aLangStrings)
				SET SECTION cBaseLang ENTRY LTrim(Str(i)) TO aLangStrings[i]
			Next
		END INI	
	ENDIF

	aChildWnd  := Array(MAX_AREA)
	aChildCP   := Array(MAX_AREA)
	aFill(aChildCP, 1)
	aChildFont := Array(MAX_AREA, 5)
	Aeval(aChildFont, {|e| e[1] := cFont, e[2] := nSize, e[3] := lBold, e[4] := lItalic, e[5] := aFntClr})

	SET EPOCH TO ( Year(Date()) - 50 )
	SET DATE FORMAT cDateFormat
	SET TOOLTIP BALLOON ON

	IF cBaseLang = "Russian"
		hb_SetCodepage( RUWIN )
	ELSEIF cBaseLang = "Polish"
		hb_SetCodepage( "PLWIN" )
	ELSEIF cBaseLang = "Spanish"
		hb_SetCodepage( "ESWIN" )
	ELSEIF cBaseLang = "German"
		hb_SetCodepage( "DEWIN" )
	ENDIF

	SetBaseLang( cBaseLang )

	SET BROWSESYNC ON

	DEFINE WINDOW Form_Main ;
		AT nTop, nLeft ;
		WIDTH nWidth HEIGHT nHeight ;
		TITLE PROGRAM ;
		ICON 'AMAIN' ;
		MAIN ;
		NOMAXIMIZE NOSIZE ;
		ON INIT IF(UPPER(cDBF) # 'NOOPEN', OpenDBF(cDBF), ) ;
		ON RELEASE ( DBcloseAll(), SaveMRUFileList() ) ;
		FONT 'MS Sans Serif' ;
		SIZE 8

		BuildMainMenu()

		DEFINE SPLITBOX

		DEFINE TOOLBAR ToolBar_1 ;
			BUTTONSIZE IF(lXPTheme, 28, 25), 25 ;
			FLAT //RIGHTTEXT

			BUTTON TB1_Button_0 ;
				TOOLTIP aLangStrings[43] ;
				PICTURE 'OPEN' ;
				ACTION OpenDBF() SEPARATOR

			BUTTON TB1_Button_1  ;
				TOOLTIP aLangStrings[44] ;
				PICTURE 'SAVE' ;
				ACTION IF( Empty(nFocus), , (aArea[nFocus])->( dbCommit() ) ) ;
				SEPARATOR

			BUTTON TB1_Button_2 ;
				TOOLTIP aLangStrings[45] ;
				PICTURE 'DELETE' ;
				ACTION ToggleDelete(.T.) SEPARATOR

			BUTTON TB1_Button_3 ;
				TOOLTIP aLangStrings[46] ;
				PICTURE 'FIND' ;
				ACTION Search_Replace()

			BUTTON TB1_Button_4 ;
				TOOLTIP aLangStrings[47] ;
				PICTURE 'GOTO' ;
				ACTION SetGoto() SEPARATOR

			BUTTON TB1_Button_5 ;
				TOOLTIP aLangStrings[48] ;
				PICTURE 'CODEPAGE' ;
				ACTION SelectCodepage()

			BUTTON TB1_Button_6 ;
				TOOLTIP aLangStrings[49] ;
				PICTURE 'PROP' ;
				ACTION ShowProperties()

			BUTTON TB1_Button_7 ;
				TOOLTIP aLangStrings[50] ;
				PICTURE 'ADJUST' ;
				ACTION AdjustColumns() SEPARATOR

			BUTTON TB1_Button_8 ;
				TOOLTIP aLangStrings[51] ;
				PICTURE 'FILTER' ;
				ACTION DBQuery() ;
				SEPARATOR

			BUTTON TB1_Button_9 ;
				TOOLTIP aLangStrings[52] ;
				PICTURE 'REFRESH' ;
				ACTION IF( Empty(nFocus), , ;
					( DoMethod( "Form_" + Ltrim(Str(nFocus)), 'Setfocus' ), ;
					DoMethod( "Form_" + Ltrim(Str(nFocus)), "Browse_1", 'Refresh' ) ) ) ;
				SEPARATOR

			BUTTON TB1_Button_10 ;
				TOOLTIP aLangStrings[53] ;
				PICTURE 'ABOUT' ;
				ACTION MsgAbout()

      		END TOOLBAR

		COMBOBOX Combo_1 ;
			ITEMS aListFont ;
			VALUE Ascan(aListFont, cFont) ;
			WIDTH 180 ;
			HEIGHT 220 ;
			TOOLTIP aLangStrings[54] ;
			ON CHANGE SetBrwFont(1, aListFont[Form_Main.Combo_1.Value])

		COMBOBOX Combo_2 ;
			ITEMS aSizeFont ;
			VALUE Ascan(aSizeFont, Ltrim(Str(nSize, 2))) ;
			WIDTH 40 ;
			TOOLTIP aLangStrings[55] ;
			ON CHANGE SetBrwFont(2, VAL(aSizeFont[Form_Main.Combo_2.Value]))
 
		END SPLITBOX

		nStatusWidth := IF(nWidth < 1024, 64, 83)

		DEFINE STATUSBAR

		STATUSITEM "" WIDTH nStatusWidth ICON "CHILD" RAISED ACTION SetThisWindow(1)
		STATUSITEM "" WIDTH nStatusWidth ICON "CHILD" RAISED ACTION SetThisWindow(2)
		STATUSITEM "" WIDTH nStatusWidth ICON "CHILD" RAISED ACTION SetThisWindow(3)
		STATUSITEM "" WIDTH nStatusWidth ICON "CHILD" RAISED ACTION SetThisWindow(4)
		STATUSITEM "" WIDTH nStatusWidth ICON "CHILD" RAISED ACTION SetThisWindow(5)
		STATUSITEM "" WIDTH nStatusWidth ICON "CHILD" RAISED ACTION SetThisWindow(6)
		STATUSITEM "" WIDTH nStatusWidth ICON "CHILD" RAISED ACTION SetThisWindow(7)
		STATUSITEM "" WIDTH nStatusWidth ICON "CHILD" RAISED ACTION SetThisWindow(8)
		STATUSITEM "" WIDTH nStatusWidth ICON "CHILD" RAISED ACTION SetThisWindow(9)
		STATUSITEM "" WIDTH nStatusWidth ICON "CHILD" RAISED ACTION SetThisWindow(10)
		STATUSITEM "" WIDTH nStatusWidth ICON "CHILD" RAISED ACTION SetThisWindow(11)
		STATUSITEM "" WIDTH nStatusWidth ICON "CHILD" RAISED ACTION SetThisWindow(12)

		DATE WIDTH 71 ACTION _Execute(GetActiveWindow(),,"CONTROL","date/time",,5)
		CLOCK WIDTH 65 ACTION _Execute(GetActiveWindow(),,"CONTROL","date/time",,5)

		END STATUSBAR

		ON KEY ESCAPE ACTION ReleaseAllWindows()

		SetHotKey()

	END WINDOW

	nChildTop := nTop + GetTitleHeight() + GetBorderHeight() / iif(lIsVistaOrLater, 2, 1) + GetMenuBarHeight() + 38
	nHArea := nTop + nHeight - nChildTop - IF(lXPTheme .Or. lIsVistaOrLater, 26, 22)

	FOR i := 1 TO MAX_AREA

		cChildForm := "Form_" + Ltrim(Str(i))

		DEFINE WINDOW &cChildForm ;
			AT nChildTop, nLeft ;
			WIDTH nWidth HEIGHT nHArea ;
			TITLE "" ;
			ICON 'CHILD' ;
			CHILD ;
			ON SIZE ResizeBrowse() ;
			ON MAXIMIZE ( SetProperty( ThisWindow.Name, 'Row', nChildTop ), ;
				SetProperty( ThisWindow.Name, 'Col', nLeft ), SetProperty( ThisWindow.Name, 'Width', nWidth ), ;
				SetProperty( ThisWindow.Name, 'Height', nHArea ), ;
				SetProperty( This.Name, "Browse_1", 'Width', This.Width - 2 * GetBorderWidth() - 2 ), ;
				SetProperty( This.Name, "Browse_1", 'Height', This.Height - 2 * GetBorderHeight() - IF(lXPTheme, 48, 38) ) ) ;
			ON MINIMIZE ( ThisWindow.Hide, nFocus := 0 ) ;
			ON INTERACTIVECLOSE nFocus := 0 ;
			ON GOTFOCUS ( nFocus := Val( SubStr( This.Name, At("_", This.Name) + 1 ) ), ;
				This.Title := aLangStrings[56] + " " + LOWER(SUBSTR(aArea[nFocus], 1, RAT("_", aArea[nFocus]) - 1)) + " : " + Ltrim(str(nFocus)) ) ;
			FONT 'MS Sans Serif' ;
			SIZE 8

			SetProperty( ThisWindow.Name, 'Closable', .F. )

			DEFINE STATUSBAR
				STATUSITEM "" WIDTH 160
				STATUSITEM "" WIDTH 600
			END STATUSBAR

			DEFINE CONTEXT MENU 
				MENUITEM aLangStrings[11]+Chr(9)+"   Ctrl+F" ACTION Search_Replace()
				MENUITEM aLangStrings[12]+Chr(9)+"   Ctrl+R" ACTION Search_Replace(.T.)
				MENUITEM aLangStrings[13]+Chr(9)+"   Ctrl+G" ACTION SetGoto()
				SEPARATOR
				MENUITEM aLangStrings[20]+Chr(9)+"   Ctrl+T" ACTION ToggleDelete()
				MENUITEM aLangStrings[21] ACTION DeleteAll()
				MENUITEM aLangStrings[22] ACTION UnDeleteAll()
				SEPARATOR
				MENUITEM aLangStrings[57]+Chr(9)+"   Ctrl+N" ACTION IF( Empty(nFocus), , ;
					( DoMethod( "Form_" + Ltrim(Str(nFocus)), 'Setfocus' ), Insert_Ctrl_N() ) )
				MENUITEM aLangStrings[58]+Chr(9)+"   Ctrl+Shift+N" ACTION AppendCopy()
				SEPARATOR
				MENUITEM aLangStrings[32] ACTION SelectCodepage()
				MENUITEM aLangStrings[33] ACTION DBQuery()
				SEPARATOR
				MENUITEM aLangStrings[34] ACTION ShowProperties()
			END MENU

			ON KEY ESCAPE ACTION ( ThisWindow.Hide, nFocus := 0 )

			SetHotKey()

		END WINDOW

	NEXT

	ACTIVATE WINDOW ALL

   ENDIF

Return

*--------------------------------------------------------*
Static Procedure BuildMainMenu()
*--------------------------------------------------------*
   Local cChildForm

   DEFINE MAIN MENU OF Form_Main

	DEFINE POPUP aLangStrings[1]
		MENUITEM aLangStrings[2]+Chr(9)+"   Ctrl+O" ACTION OpenDBF()
		MENUITEM aLangStrings[3] + " "+cPath ACTION OpenDBF( NIL, .T. )
		MENUITEM aLangStrings[4] ACTION ( IF( Empty(nFocus), , ( (aArea[nFocus])->( DBcloseArea() ), aArea[nFocus] := "X", ;
					aChildCP[nFocus] := 1, cChildForm := "Form_" + Ltrim(Str(nFocus)), ;
					_ReleaseControl( 'Browse_1', cChildForm ), DoMethod( cChildForm, 'Hide' ), ;
					Form_Main.StatusBar.Item(nFocus) := "", nFocus := 0 ) ) )
		MENUITEM aLangStrings[5] ACTION IF( Empty(nFocus), , dbCommitAll() )
		MENUITEM aLangStrings[6]+Chr(9)+"   Ctrl+S" ACTION ExportData()
		SEPARATOR
		DEFINE POPUP aLangStrings[7]
			MRUITEM " ("+aLangStrings[8]+") "   ACTION OpenDBF(cDBF) ;
				INI (cFileIni) SECTION "Recent File List" SIZE 12
		END POPUP 
		SEPARATOR 
		MENUITEM aLangStrings[9]+Chr(9)+"   Alt+F4" ACTION ReleaseAllWindows()
	END POPUP

	DEFINE POPUP aLangStrings[10]
		MENUITEM aLangStrings[11]+Chr(9)+"   Ctrl+F" ACTION Search_Replace()
		MENUITEM aLangStrings[12]+Chr(9)+"   Ctrl+R" ACTION Search_Replace(.t.)
		MENUITEM aLangStrings[13]+Chr(9)+"   Ctrl+G" ACTION SetGoto()
		SEPARATOR
		DEFINE POPUP aLangStrings[14]
			MENUITEM aLangStrings[15]+Chr(9)+"   Ctrl+N" ACTION IF( Empty(nFocus), , ;
					( DoMethod( "Form_" + Ltrim(Str(nFocus)), 'Setfocus' ), Insert_Ctrl_N() ) )
			MENUITEM aLangStrings[16]+Chr(9)+"   Ctrl+Shift+N" ACTION AppendCopy()
		END POPUP
		DEFINE POPUP aLangStrings[17]
			MENUITEM aLangStrings[18] ACTION IF( Empty(nFocus), , ;
					( DoMethod( "Form_" + Ltrim(Str(nFocus)), 'Setfocus' ), Keybd_Del() ) )
			MENUITEM aLangStrings[19] ACTION IF( Empty(nFocus), , ;
					( IF(Rlock(), ( (aArea[nFocus])->( DBRecall() ), DBunlock() ), ), ;
					DoMethod( "Form_" + Ltrim(Str(nFocus)), 'Setfocus' ), ;
					DoMethod( "Form_" + Ltrim(Str(nFocus)), "Browse_1", 'Refresh' ) ) )
			MENUITEM aLangStrings[20]+Chr(9)+"   Ctrl+T" ACTION ToggleDelete()
			SEPARATOR
			MENUITEM aLangStrings[21] ACTION DeleteAll()
			MENUITEM aLangStrings[22] ACTION UnDeleteAll()
		END POPUP
		MENUITEM aLangStrings[23]+Chr(9)+"   Ctrl+P" ACTION DBpack()
		MENUITEM aLangStrings[24]+Chr(9)+"   Ctrl+Z" ACTION DBzap()
	END POPUP

	DEFINE POPUP aLangStrings[25]
		MENUITEM aLangStrings[26] ACTION AdjustColumns()
		MENUITEM aLangStrings[27]+Chr(9)+"   F5" ACTION IF( Empty(nFocus), , ;
				( DoMethod( "Form_" + Ltrim(Str(nFocus)), 'Setfocus' ), ;
				DoMethod( "Form_" + Ltrim(Str(nFocus)), "Browse_1", 'Refresh' ) ) )
		SEPARATOR
		MENUITEM aLangStrings[28] ACTION IF( Empty(nFocus), , ;
				( aBackClr := GetBackColor(), ;
				SaveParameter("Interface", "Color", aBackClr), AdjustColumns() ) ) 
		MENUITEM aLangStrings[29] ACTION SetBrowseFont()
		MENUITEM aLangStrings[30] ACTION SelectLanguage()
	END POPUP

	DEFINE POPUP aLangStrings[31]
		MENUITEM aLangStrings[32] ACTION SelectCodepage()
		MENUITEM aLangStrings[33] ACTION DBQuery()
		SEPARATOR
		MENUITEM aLangStrings[34] ACTION ShowProperties()
	END POPUP

	DEFINE POPUP aLangStrings[35]
		MENUITEM aLangStrings[36] ACTION CascadeWnd()
		MENUITEM aLangStrings[37] ACTION TileWnd()
		SEPARATOR
		MENUITEM aLangStrings[38] ;
			ACTION Aeval(aChildWnd, {|e,i| cChildForm := "Form_" + Ltrim(Str(i)), ;
					IF( _IsControlDefined( "Browse_1", cChildForm ), DoMethod( cChildForm, 'Hide' ), )})
		MENUITEM aLangStrings[39] ;
			ACTION Aeval(aChildWnd, {|e,i| cChildForm := "Form_" + Ltrim(Str(i)), ;
					IF( _IsControlDefined( "Browse_1", cChildForm ), DoMethod( cChildForm, 'Show' ), )})
	END POPUP

	DEFINE POPUP aLangStrings[40]
		MENUITEM aLangStrings[41]+Chr(9)+"   F1" ACTION _Execute( _HMG_MainHandle, "open", cPath + '\' + PROGRAM + '.CHM' )
		SEPARATOR
		MENUITEM aLangStrings[42]+" "+PROGRAM+"..." ACTION MsgAbout()
	END POPUP

   END MENU

Return

*--------------------------------------------------------*
Static Procedure SetHotKey()
*--------------------------------------------------------*
	ON KEY CONTROL+O ACTION OpenDBF()
	ON KEY CONTROL+S ACTION ExportData()
	ON KEY CONTROL+F ACTION Search_Replace()
	ON KEY CONTROL+R ACTION Search_Replace(.t.)
	ON KEY CONTROL+G ACTION SetGoto()
	ON KEY CTRL+SHIFT+N ACTION AppendCopy()
	ON KEY CONTROL+T ACTION ToggleDelete()
	ON KEY CONTROL+P ACTION DBpack()
	ON KEY CONTROL+Z ACTION DBzap()
	ON KEY F1 ACTION _Execute( _HMG_MainHandle, "open", cPath + '\' + PROGRAM + '.CHM')
	ON KEY F5 ACTION IF( Empty(nFocus), , ;
		( DoMethod( "Form_" + Ltrim(Str(nFocus)), 'Setfocus' ), ;
		DoMethod( "Form_" + Ltrim(Str(nFocus)), "Browse_1", 'Refresh' ) ) )

Return

*--------------------------------------------------------*
Static Procedure DBQuery()
*--------------------------------------------------------*
   Local cField, cComp, cType := ""
   Local cChar := "", nNum := 0, dDate := ctod(""), nLog := 1
   Local cExpr := ""
   Local aQuery_ := {"", "", ""}
   Local aUndo_ := {}
   Local aFlds_ := {}
   Local aComp_ := { aLangStrings[110], ;
                     aLangStrings[111], ;
                     aLangStrings[112], ;
                     aLangStrings[113], ;
                     aLangStrings[114], ;
                     aLangStrings[115], ;
                     aLangStrings[116], ;
                     aLangStrings[117], ;
                     aLangStrings[118] }

   Private cAlias, cDBFile

   IF !Empty(nFocus)
	cDBFile := cFileNoPath(aChildWnd[nFocus])
	cAlias := aArea[nFocus]
	IF !Empty((cAlias)->( DbFilter() ))
		(cAlias)->( DbClearFilter() )
	ENDIF
	aEval((cAlias)->( DBStruct() ), {|e| aAdd(aFlds_, e[DBS_NAME]) } )
	aAdd(aFlds_, aLangStrings[119]) // Add this as if it were a logical field!

	cField := aFlds_[1]
	cComp := aComp_[1]

	DEFINE WINDOW Form_Query ;
		AT 0, 0 WIDTH 568 + IF(lIsVistaOrLater, GetBorderWidth(), 0) HEIGHT 307 + IF(lXPTheme, 8, 0) ;
		TITLE aLangStrings[107] ;
		ICON 'CHILD' ;
		MODAL ;
		ON INIT ( Form_Query.List_1.Setfocus, cType := GetType(cField, aFlds_, @cChar), ;
			Form_Query.Text_1.Enabled := ( cType == "C" ), ;
			Form_Query.Text_2.Enabled := ( cType == "N" ), ;
			Form_Query.Date_1.Enabled := ( cType == "D" ), ;
			Form_Query.Combo_1.Enabled := ( cType == "L" ) ) ;
		FONT "MS Sans Serif" ;
		SIZE 8

	    DEFINE FRAME Frame_1
            ROW    10
            COL    260
            WIDTH  290
            HEIGHT 135
            CAPTION aLangStrings[120]
            OPAQUE .T.
	    END FRAME

	    DEFINE LABEL Label_1
            ROW    30
            COL    270
            WIDTH  60
            HEIGHT 20
            VALUE aLangStrings[121]+":"
            VISIBLE .T.
	    END LABEL

	    DEFINE LABEL Label_2
            ROW    60
            COL    270
            WIDTH  60
            HEIGHT 20
            VALUE aLangStrings[122]+":"
            VISIBLE .T.
	    END LABEL

	    DEFINE LABEL Label_3
            ROW    90
            COL    270
            WIDTH  60
            HEIGHT 20
            VALUE aLangStrings[123]+":"
            VISIBLE .T.
	    END LABEL

	    DEFINE LABEL Label_4
            ROW    120
            COL    270
            WIDTH  60
            HEIGHT 20
            VALUE aLangStrings[124]+":"
            VISIBLE .T.
	    END LABEL

	    DEFINE LABEL Label_5
            ROW    6
            COL    12
            WIDTH  80
            HEIGHT 16
            VALUE aLangStrings[108]
            VISIBLE .T.
	    END LABEL

	    DEFINE LABEL Label_6
            ROW    6
            COL    134
            WIDTH  120
            HEIGHT 16
            VALUE aLangStrings[109]
            VISIBLE .T.
	    END LABEL

	    DEFINE LISTBOX List_1
            ROW    20
            COL    10
            WIDTH  114
            HEIGHT 130
            ITEMS aFlds_
            VALUE 1
            ONCHANGE ( cField := aFlds_[This.Value], cType := GetType(cField, aFlds_, @cChar), ;
			Form_Query.Text_1.Enabled := ( cType == "C" ), ;
			Form_Query.Text_2.Enabled := ( cType == "N" ), ;
			Form_Query.Date_1.Enabled := ( cType == "D" ), ;
			Form_Query.Combo_1.Enabled := ( cType == "L" ) )
            ONDBLCLICK Form_Query.Button_1.OnClick
            TABSTOP .T.
            VISIBLE .T.
            SORT .F.
            MULTISELECT .F.
	    END LISTBOX

	    DEFINE LISTBOX List_2
            ROW    20
            COL    132
            WIDTH  118
            HEIGHT 130
            ITEMS aComp_
            VALUE 1
            ONCHANGE cComp := aComp_[This.Value]
            ONLOSTFOCUS IF( CheckComp(cType, cComp), , Form_Query.List_2.Setfocus )
            ONDBLCLICK Form_Query.Button_1.OnClick
            TABSTOP .T.
            VISIBLE .T.
            SORT .F.
            MULTISELECT .F.
	    END LISTBOX

	    DEFINE EDITBOX Edit_1
            ROW    170
            COL    10
            WIDTH  240
            HEIGHT 100
            VALUE ""
            ONCHANGE ( cExpr := This.Value, ;
		Form_Query.Button_2.Enabled := ( !empty(cExpr) ), ;
		Form_Query.Button_8.Enabled := ( !empty(cExpr) ), ;
		Form_Query.Button_10.Enabled := ( !empty(cExpr) ) )
            ONGOTFOCUS Nil
            ONLOSTFOCUS Nil
            FONTBOLD .T.
            TABSTOP .T.
            VISIBLE .T.
	    END EDITBOX

	    DEFINE LABEL Label_7
            ROW    154
            COL    12
            WIDTH  100
            HEIGHT 16
            VALUE aLangStrings[125]+":"
            VISIBLE .T.
	    END LABEL

	    DEFINE TEXTBOX Text_1
            ROW    26
            COL    340
            WIDTH  200
            HEIGHT 24
            ONCHANGE cChar := This.Value
            ONGOTFOCUS Form_Query.Text_1.Enabled := ( cType == "C" )
            ONENTER ( Form_Query.Button_1.OnClick, Form_Query.Button_8.Setfocus )
            FONTBOLD .T.
            TABSTOP .T.
            VISIBLE .T.
            VALUE cChar
	    END TEXTBOX

	    DEFINE TEXTBOX Text_2
		ROW    56
		COL    340
	        WIDTH  200
		HEIGHT 24
	        NUMERIC .T.
		INPUTMASK "9999999.99"
	        RIGHTALIGN .T.
		MAXLENGTH 10
	        ONCHANGE nNum := This.Value
		ONGOTFOCUS Form_Query.Text_2.Enabled := ( cType == "N" )
	        ONENTER ( Form_Query.Button_1.OnClick, Form_Query.Button_8.Setfocus )
		FONTBOLD .T.
	        TABSTOP .T.
		VISIBLE .T.
	        VALUE nNum
	    END TEXTBOX

            DEFINE DATEPICKER Date_1
	        ROW    86
		COL    340
	        WIDTH  110
		HEIGHT 24
	        VALUE dDate
		SHOWNONE .T.
	        UPDOWN .T.
		ONCHANGE dDate := This.Value
	        ONGOTFOCUS Form_Query.Date_1.Enabled := ( cType == "D" )
		FONTBOLD .T.
	        TABSTOP .T.
		VISIBLE .T.
            END DATEPICKER

	    DEFINE COMBOBOX Combo_1
	        ROW    116
		COL    340
	        WIDTH  110
		HEIGHT 60
	        ITEMS {"True (.T.)", "False (.F.)"}
		VALUE nLog
	        ONCHANGE nLog := This.Value
		ONGOTFOCUS Form_Query.Combo_1.Enabled := ( cType == "L" )
	        ONENTER ( Form_Query.Button_1.OnClick, Form_Query.Button_8.Setfocus )
		FONTBOLD .T.
	        TABSTOP .T.
		VISIBLE .T.
	    END COMBOBOX

	    DEFINE BUTTON Button_1
	        ROW    156
		COL    260
	        WIDTH  136
		HEIGHT 24
	        CAPTION aLangStrings[126]
		ACTION IF( CheckComp(cType, cComp), ( AddExpr(@cExpr, aUndo_, cField, cComp, ;
			iif(cType == "C", cChar, iif(cType == "N", nNum, ;
			iif(cType == "D", dDate, (nLog == 1))))), ;
			Form_Query.Button_2.Enabled := ( Len(aUndo_) > 0 ), ;
			Form_Query.Button_8.Enabled := ( !empty(cExpr) ), ;
			Form_Query.Button_10.Enabled := ( !empty(cExpr) ) ), Form_Query.List_2.Setfocus )
	        ONLOSTFOCUS Form_Query.Button_2.Enabled := ( Len(aUndo_) > 0 )
		TABSTOP .T.
	        VISIBLE .T.
	    END BUTTON

	    DEFINE BUTTON Button_2
	        ROW    156
		COL    414
	        WIDTH  136
		HEIGHT 24
	        CAPTION aLangStrings[127]
		ACTION ( Undo(@cExpr, aUndo_), ;
			Form_Query.Button_2.Enabled := ( Len(aUndo_) > 0 ), ;
			Form_Query.Button_8.Enabled := ( !empty(cExpr) ), ;
			Form_Query.Button_10.Enabled := ( !empty(cExpr) ) )
	        ONLOSTFOCUS Form_Query.Button_2.Enabled := ( Len(aUndo_) > 0 )
		TABSTOP .T.
	        VISIBLE .T.
	    END BUTTON

	    DEFINE BUTTON Button_3
		ROW    196
	        COL    260
		WIDTH  44
	        HEIGHT 24
		CAPTION aLangStrings[128]
	        ACTION AddText(@cExpr, aUndo_, ".and. ")
		TABSTOP .T.
	        VISIBLE .T.
	    END BUTTON

	    DEFINE BUTTON Button_4
	        ROW    196
		COL    321
	        WIDTH  44
		HEIGHT 24
	        CAPTION aLangStrings[129]
		ACTION AddText(@cExpr, aUndo_, ".or. ")
	        TABSTOP .T.
		VISIBLE .T.
	    END BUTTON

	    DEFINE BUTTON Button_5
	        ROW    196
		COL    383
	        WIDTH  44
		HEIGHT 24
	        CAPTION aLangStrings[130]
		ACTION AddText(@cExpr, aUndo_, ".not. ")
	        TABSTOP .T.
		VISIBLE .T.
	    END BUTTON

	    DEFINE BUTTON Button_6
	        ROW    196
		COL    444
	        WIDTH  44
		HEIGHT 24
	        CAPTION "("
		ACTION AddText(@cExpr, aUndo_, "( ")
	        TABSTOP .T.
		VISIBLE .T.
	    END BUTTON

	    DEFINE BUTTON Button_7
	        ROW    196
		COL    505
	        WIDTH  44
		HEIGHT 24
	        CAPTION ")"
		ACTION AddText(@cExpr, aUndo_, " ) ")
	        TABSTOP .T.
		VISIBLE .T.
	    END BUTTON

	    DEFINE BUTTON Button_8
	        ROW    236
		COL    260
	        WIDTH  62
		HEIGHT 24
	        CAPTION aLangStrings[131]
		ACTION IF( RunQuery(cExpr), Form_Query.Button_9.OnClick, )
	        ONLOSTFOCUS Form_Query.Button_8.Enabled := ( !empty(cExpr) )
		TABSTOP .T.
	        VISIBLE .T.
	    END BUTTON

	    DEFINE BUTTON Button_9
	        ROW    236
		COL    336
	        WIDTH  62
		HEIGHT 24
	        CAPTION aLangStrings[4]
		ACTION ( SetProperty( "Form_" + Ltrim(Str(nFocus)), "Browse_1", "Value", (cAlias)->( RecNo() ) ), ;
			DoMethod( "Form_" + Ltrim(Str(nFocus)), "Browse_1", 'Refresh' ), ;
			Form_Query.Release, DoMethod( "Form_" + Ltrim(Str(nFocus)), 'Setfocus' ) )
	        TABSTOP .T.
		VISIBLE .T.
	    END BUTTON

	    DEFINE BUTTON Button_10
	        ROW    236
		COL    412
	        WIDTH  62
		HEIGHT 24
	        CAPTION aLangStrings[5]
		ACTION SaveQuery(cExpr, aQuery_)
	        ONLOSTFOCUS Form_Query.Button_10.Enabled := ( !empty(cExpr) )
		TABSTOP .T.
	        VISIBLE .T.
	    END BUTTON

	    DEFINE BUTTON Button_11
	        ROW    236
		COL    488
	        WIDTH  62
		HEIGHT 24
	        CAPTION aLangStrings[132]
		ACTION iif( LoadQuery(@cExpr, aQuery_), ( aUndo_ := {}, ;
			Form_Query.Button_8.Enabled := ( !empty(cExpr) ), ;
			Form_Query.Button_10.Enabled := ( !empty(cExpr) ) ), )
	        TABSTOP .T.
		VISIBLE .T.
	    END BUTTON

            ON KEY ESCAPE ACTION IF( CheckComp(cType, cComp), Form_Query.Button_9.OnClick, Form_Query.List_2.Setfocus )

	END WINDOW

	Form_Query.Text_1.Enabled := .F.
	Form_Query.Text_2.Enabled := .F.
	Form_Query.Date_1.Enabled := .F.
	Form_Query.Combo_1.Enabled := .F.
	Form_Query.Button_2.Enabled := .F.
	Form_Query.Button_8.Enabled := .F.
	Form_Query.Button_10.Enabled := .F.

	CENTER WINDOW Form_Query

	ACTIVATE WINDOW Form_Query
   ENDIF

RETURN

*--------------------------------------------------------*
Static Procedure ResizeBrowse()
*--------------------------------------------------------*

	IF This.Row < nChildTop
		This.Row := nChildTop
	ENDIF
	IF This.Col < nLeft
		This.Col := nLeft
	ENDIF
	IF This.Width > nWidth
		This.Width := nWidth
	ENDIF
	IF This.Height > nHArea
		This.Height := nHArea
	ENDIF

	IF _IsControlDefined( "Browse_1", This.Name )
		SetProperty( This.Name, "Browse_1", 'Width', This.Width - 2 * GetBorderWidth() - 2 )
		SetProperty( This.Name, "Browse_1", 'Height', This.Height - 2 * GetBorderHeight() - IF(lXPTheme, 48, 38) )
	ENDIF

RETURN

*--------------------------------------------------------*
Static Procedure SetBrowseFont()
*--------------------------------------------------------*
   Local aFont

   IF !Empty(nFocus)

	aFont := GetFont( aChildFont[nFocus][1] , aChildFont[nFocus][2] , aChildFont[nFocus][3] , aChildFont[nFocus][4] , aChildFont[nFocus][5] , .f. , .f. , 0 )

	IF !Empty( aFont[1] )
		aChildFont[nFocus][1] := aFont[1]
		aChildFont[nFocus][2] := aFont[2]
		aChildFont[nFocus][3] := aFont[3]
		aChildFont[nFocus][4] := aFont[4]
		aChildFont[nFocus][5] := { aFont[5][1] , aFont[5][2] , aFont[5][3] }
		SaveParameter("Font", "Name", aFont[1])
		SaveParameter("Font", "Size", aFont[2])
		SaveParameter("Font", "Bold", aFont[3])
		SaveParameter("Font", "Italic", aFont[4])
		SaveParameter("Font", "Color", aChildFont[nFocus][5])
		Form_Main.Combo_1.Value := Ascan(aListFont, aFont[1])
		Form_Main.Combo_2.Value := Ascan(aSizeFont, Ltrim(Str(aFont[2], 2)))
		AdjustColumns()
	ENDIF

   ENDIF

RETURN

*--------------------------------------------------------*
Static Procedure SetBrwFont( nItem, xFont )
*--------------------------------------------------------*

   IF !Empty(nFocus)
	aChildFont[nFocus][nItem] := xFont
	SaveParameter("Font", IF(nItem < 2, "Name", "Size"), aChildFont[nFocus][nItem])
	AdjustColumns()
   ENDIF

RETURN

*--------------------------------------------------------*
Procedure OpenDBF( cDBFName, lPath )
*--------------------------------------------------------*
   Local nField, nScan, cAlias

   DEFAULT cDBFName := "", lPath := .f.

   IF EMPTY( cDBFName )
	cDBFName := GetFile( { {"DBF files (*.dbf)", "*.dbf"}, ;
				{"All files (*.*)", "*.*"} }, , IF(lPath, cPath, NIL) )
	IF Empty(cDBFName)
		RETURN
	ENDIF
   ELSEIF AT( "\", cDBFName ) == 0
	cDBFName := cPath + "\" + cDBFName
   ENDIF

   cDBFName := StrTran(cDBFName, '"', "")

   IF !File(cDBFName)
	MsgStop( cDBFName + CRLF + aLangStrings[106] + "." )
	RETURN
   ENDIF
   IF EMPTY( Adir( cFilePath( cDBFName ) + "\*.FPT" ) )
	RDDSETDEFAULT('DBFNTX')
   ELSE
	RDDSETDEFAULT('DBFCDX')
   ENDIF

   IF Empty( ( nScan := Ascan( aArea, {|e| e=="X"}) ) )
	nField := ++nSelect
   ELSE
	nField := nScan
   ENDIF

   IF nSelect > MAX_AREA .AND. Empty( nScan )
	MsgAlert( aLangStrings[63] )
	RETURN
   ENDIF

   cAlias := StrTran(cFileNoExt(cDBFName), ' ', "_") + "_" + Ltrim(Str(nField))
   IF IsDigit( Left( cAlias, 1 ) )
      cAlias := "_" + cAlias
   ENDIF

   If !OpenDataBaseFile( cDBFName, cAlias, .F., .F., RddSetDefault() )
	IF Empty( nScan )
		nSelect--
	ENDIF
	RETURN
   EndIf

   IF Empty( nScan )
	Aadd( aArea, Alias() )
   ELSE
	aArea[nScan] := Alias()
   ENDIF

   AddMRUItem( cDBFName, "OpenDBF(cDBF)" )

   aChildWnd[nField] := cDBFName
   SetBrowse( nField )

RETURN

*--------------------------------------------------------*
Static Procedure SetBrowse( nField )
*--------------------------------------------------------*
   Local i, size, size1, cForm, cAlias := aArea[nField]
   Local astruct, anames := {"if(deleted(), 'X', ' ')"}, ;
	aheaders := {"X"}, asizes := {20+IF(lXPTheme, 4, 0)}, ajustify := {0}, areadonly := {.t.}

	astruct := (cAlias)->( DBstruct(cAlias) )

	for i := 1 to len(astruct)
		aadd(anames, astruct[i, 1])
		aadd(aheaders, astruct[i, 1])
		size := len(trim(astruct[i, 1])) * 15
		size1 := astruct[i, 3] * if(i < 2 .and. astruct[i, 2] == 'N', 15, 10)
		aadd(asizes, if(size < size1, size1, size))
		aadd(ajustify, LtoN(astruct[i, 2] == 'N'))
		aadd(areadonly, .f.)
	next

	cForm := "Form_" + Ltrim(Str(nField))

	SetProperty( cForm, 'Row', nChildTop )
	SetProperty( cForm, 'Col', nLeft )
	IF GetProperty( cForm, 'Width' ) # nWidth
		SetProperty( cForm, 'Width', nWidth )
	ENDIF
	IF GetProperty( cForm, 'Height' ) # nHArea
		SetProperty( cForm, 'Height', nHArea )
	ENDIF

	DEFINE BROWSE Browse_1
		ROW 0
		COL 0
		WIDTH GetProperty( cForm, 'Width' ) - 2 * GetBorderWidth() - 2
		HEIGHT GetProperty( cForm, 'Height' ) - 2 * GetBorderHeight() - IF(lXPTheme, 48, 38)
		PARENT &cForm
		HEADERS aheaders
		WIDTHS asizes
		FIELDS anames
		JUSTIFY ajustify
		WORKAREA &cAlias
		VALUE (cAlias)->( Recno() )
		VSCROLLBAR (cAlias)->( Lastrec() ) > 0
		ALLOWEDIT .T.
		INPLACEEDIT .T.
		READONLYFIELDS areadonly
		ALLOWAPPEND .T.
		ALLOWDELETE .T.
		LOCK .T.
		ON CHANGE SetProperty( ThisWindow.Name, "StatusBar", "Item", 1, ;
			aLangStrings[59] + " " + Ltrim( Str( (cAlias)->( Recno() ) ) ) + " " + aLangStrings[60] + " " + Ltrim( Str( (cAlias)->( Lastrec() ) ) ) )
		FONTNAME aChildFont[nField][1]
		FONTSIZE aChildFont[nField][2]
		FONTBOLD aChildFont[nField][3]
		FONTITALIC aChildFont[nField][4]
		FONTCOLOR aChildFont[nField][5]
		BACKCOLOR aBackClr
	END BROWSE

	Form_Main.StatusBar.Item(nField) := IF(nWidth < 1024, "# ", aLangStrings[56]+" : ") + Ltrim(str(nField))
	SetProperty( cForm, "StatusBar", "Item", 1, ;
		aLangStrings[59] + " " + IF( Empty( (cAlias)->( Lastrec() ) ), "0", Ltrim( Str( (cAlias)->( Recno() ) ) ) ) + " " + aLangStrings[60] + " " + ;
		Ltrim( Str( (cAlias)->( Lastrec() ) ) ) )
	SetProperty( cForm, "StatusBar", "Item", 2, aChildWnd[nField] )
	DoMethod( cForm, "Browse_1", 'Refresh' )
	DoMethod( cForm, "Browse_1", 'SetFocus' )
	IF !IsWindowVisible( GetFormHandle( cForm ) )
		DoMethod( cForm, 'Show' )
	ENDIF

Return

*--------------------------------------------------------*
FUNCTION OpenDataBaseFile( cDataBaseFileName, cAlias, lExclusive, lReadOnly, cDriverName, lNew )
*--------------------------------------------------------*
   Local _bLastHandler := ErrorBlock( {|o| Break(o)} ), _lGood := .T. /*, oError*/

   If PCount() < 6 .or. ValType(lNew) <> "L"
	lNew := .T.
   EndIf

   BEGIN SEQUENCE

	dbUseArea( lNew, cDriverName, cDataBaseFileName, cAlias, !lExclusive, lReadOnly )

   RECOVER //USING oError

	_lGood := .F.
	MsgAlert( "Unable to open file:" + CRLF + cDataBaseFileName )

   END

   ErrorBlock( _bLastHandler )

Return( _lGood )

*--------------------------------------------------------*
Static Procedure ExportData()
*--------------------------------------------------------*
   Local cExt, cSaveFile, nIndex := 1, cAlias, nRecno

   IF !Empty(nFocus)
	cSaveFile := PutFile( { {"DBF files (*.dbf)", "*.dbf"}, {"Text files (*.txt)", "*.txt"}, ;
		{"Data files (*.dat)", "*.dat"}, {"Excel files (*.xls)", "*.xls"}, ;
		{"Clipper, Foxpro files (*.prg)", "*.prg"}, {"All files (*.*)", "*.*"} }, , , , , @nIndex )

	IF !Empty( cSaveFile )
		IF nIndex == 2
			cExt := "txt"
		ELSEIF nIndex == 3
			cExt := "dat"
		ELSEIF nIndex == 4
			cExt := "xls"
		ELSEIF nIndex == 5
			cExt := "prg"
		ELSE
			cExt := "dbf"
		ENDIF

		cSaveFile := IF( AT( ".", cSaveFile ) > 0, cSaveFile, cSaveFile + "." + cExt )

		IF File( cSaveFile )
			IF !MsgYesNo( cSaveFile + " already exists." + CRLF + ;
				"Overwrite existing file?" )
				Return
			ENDIF
 		ENDIF
		cAlias := aArea[nFocus]
		nRecno := (cAlias)->( Recno() )
		(cAlias)->( DBGoTop() )
		IF nIndex = 2 .OR. nIndex = 3
			(cAlias)->( __dbSDF(.T.,(cSaveFile),{ },,,,,.F. ) )
		ELSEIF nIndex = 4
			SaveToXls( cAlias, cSaveFile )
		ELSEIF nIndex = 5
			SaveToPrg( cAlias, cSaveFile )
		ELSE
			(cAlias)->( __dbCopy((cSaveFile),{ },,,,,.F.,) )
			OpenDBF( cSaveFile )
		ENDIF
		(cAlias)->( DBGoto(nRecno) )
	ENDIF
   ENDIF

Return

*--------------------------------------------------------*
Static Procedure SaveToXls( cAlias, cFile )
*--------------------------------------------------------*
   Local oExcel,  oSheet, oBook, aColumns, nCell := 1

	oExcel := TOleAuto():New( "Excel.Application" )
	if Ole2TxtError() != 'S_OK'
	    MsgStop('Excel is not available!', PROGRAM )
	    RETURN
	endif
	oExcel:Visible := .F.
	oExcel:WorkBooks:Add()
	oSheet := oExcel:Get( "ActiveSheet" )

	Aeval( (cAlias)->( DBstruct(cAlias) ), { |e,i| oSheet:Cells( nCell, i ):Value := e[DBS_NAME] } )
	do while !(cAlias)->( EoF() )
		nCell++
		aColumns := (cAlias)->( Scatter() )
		aEval( aColumns, { |e,i| oSheet:Cells( nCell, i ):Value := e } )
		(cAlias)->( DBskip() )
	enddo

	oBook := oExcel:Get("ActiveWorkBook")
	oBook:Title   := cAlias
	oBook:Subject := cAlias
	oBook:SaveAs(cFile)
	oExcel:Quit()

Return

#xtranslate fWriteLn( <xHandle>, <cString> ) ;
=> ;
            fWrite( <xHandle>, <cString> + CRLF )
*--------------------------------------------------------*
Static Procedure SaveToPrg( cAlias, cFile )
*--------------------------------------------------------*
   Local handle := fCreate(cFile, FC_NORMAL), nLen := Len( (cAlias)->( DBstruct(cAlias) ) )

	fWriteLn(handle, "*-------------------------------------------------*")
	fWriteLn(handle, " PROCEDURE MAKE_DataBase()")
	fWriteLn(handle, "*-------------------------------------------------*")

	fWriteLn(handle, ' DBCREATE ("' + SubStr(cAlias, 1, RAT("_", cAlias) - 1) + '", {;')

	Aeval( (cAlias)->( DBstruct(cAlias) ), { |e,i| fWriteLn( handle, ;
		Chr(9) + '{ ' + padr('"' + e[DBS_NAME] + '",', 14) + '"' + Trim(e[DBS_TYPE]) + '",' + Str(e[DBS_LEN], 4) + ',' + Str(e[DBS_DEC], 3) + ;
		if(i < nLen, ' },;', ' }}, "'+( cAlias )->( RDDNAME() ) +'")') ) } )

	fWriteLn(handle, " RETURN")
	fClose(handle)

Return

*--------------------------------------------------------*
Static Procedure AdjustColumns()
*--------------------------------------------------------*
   Local nRecno, cAlias

   IF !Empty(nFocus)
	cAlias := aArea[nFocus]
	nRecno := (cAlias)->( Recno() )
	_ReleaseControl( 'Browse_1', "Form_" + Ltrim(Str(nFocus)) )
	DO EVENTS
	(cAlias)->( DBGoTo(nRecno) )
	SetBrowse( nFocus )
   ENDIF

Return

*------------------------------------------------------------------------------*
Static Procedure Search_Replace( lReplace )
*------------------------------------------------------------------------------*
   Local aColumns := { aLangStrings[64] }

   DEFAULT lReplace := .f.

   IF !Empty(nFocus)
	Private lFirstFind := .T., lFind := .T., cFind := "", cFindStr, cField, cAlias := aArea[nFocus], cReplStr, nCurRec

	Aeval( (cAlias)->( DBstruct(cAlias) ), {|e| Aadd(aColumns, e[1])})

	DEFINE WINDOW Form_Find ;
		AT 0, 0 WIDTH 449 + IF(lIsVistaOrLater, GetBorderWidth(), 0) HEIGHT 222 + IF(lXPTheme, 8, 0) ;
		TITLE IF(lReplace, aLangStrings[65], aLangStrings[66]) ;
		ICON 'CHILD' ;
		MODAL ;
		ON INIT ( Form_Find.Combo_1.DisplayValue := "", Form_Find.Combo_2.DisplayValue := "", Form_Find.Combo_1.Setfocus ) ;
		FONT "MS Sans Serif" ;
		SIZE 8

		DEFINE LABEL Label_1
	        ROW    10
		COL    12
	        WIDTH  60
		HEIGHT 21
	        VALUE aLangStrings[56]+":"
		VISIBLE .T.
	        AUTOSIZE .F.
		END LABEL

		DEFINE LABEL Label_11
	        ROW    10
		COL    95
	        WIDTH  240
		HEIGHT 21
	        VALUE LOWER(SUBSTR(cAlias, 1, RAT("_", cAlias) - 1))
		VISIBLE .T.
	        AUTOSIZE .F.
		END LABEL

		DEFINE LABEL Label_2
	        ROW    36
		COL    12
	        WIDTH  60
		HEIGHT 21
	        VALUE aLangStrings[67]+":"
		VISIBLE .T.
	        AUTOSIZE .F.
		END LABEL

		DEFINE COMBOBOX Combo_1
			ROW	32
			COL	95
			ITEMS aSearch
			VALUE nSearch
			WIDTH 240
			DISPLAYEDIT .T.
			ON DISPLAYCHANGE ( lFirstFind := .T., Form_Find.Button_1.Enabled := !Empty(Form_Find.Combo_1.DisplayValue) )
			ON CHANGE ( lFirstFind := .T., Form_Find.Button_1.Enabled := .t. )
			VISIBLE .T.
		END COMBOBOX

		DEFINE LABEL Label_3
	        ROW    62
		COL    12
	        WIDTH  80
		HEIGHT 18
	        VALUE aLangStrings[68]+":"
		VISIBLE lReplace
	        AUTOSIZE .F.
		END LABEL

		DEFINE COMBOBOX Combo_2
			ROW	60
			COL	95
			ITEMS aReplace
			VALUE nReplace
			WIDTH 240
			DISPLAYEDIT .T.
			ON DISPLAYCHANGE ( Form_Find.Button_3.Enabled := !Empty(Form_Find.Combo_1.DisplayValue) .AND. !Empty(Form_Find.Combo_2.DisplayValue), ;
				Form_Find.Button_4.Enabled := !Empty(Form_Find.Combo_1.DisplayValue) .AND. !Empty(Form_Find.Combo_2.DisplayValue) )
			ON CHANGE ( Form_Find.Button_3.Enabled := .t., Form_Find.Button_4.Enabled := .t. )
			VISIBLE lReplace
		END COMBOBOX

		DEFINE FRAME Frame_1
	        ROW    92
		COL    12
	        WIDTH  98
		HEIGHT 92
		CAPTION aLangStrings[69]
	        OPAQUE .T.
		END FRAME

		DEFINE RADIOGROUP Radio_1
			ROW	104
			COL	22
			OPTIONS { aLangStrings[70] , aLangStrings[71] , aLangStrings[72] } 
			VALUE nDirect
			WIDTH 82
			ONCHANGE ( nDirect := This.Value, lFirstFind := .T. )
			TABSTOP .T.
		END RADIOGROUP

		DEFINE LABEL Label_4
	        ROW    100
		COL    120
	        WIDTH  100
		HEIGHT 18
	        VALUE aLangStrings[73]+":"
		VISIBLE .T.
	        AUTOSIZE .F.
		END LABEL

		DEFINE COMBOBOX Combo_3
			ROW	96
			COL	215
			ITEMS aColumns
			VALUE nColumns
			WIDTH 120
			ON CHANGE lFirstFind := .T.
		END COMBOBOX

		DEFINE CHECKBOX Check_1
			ROW	130
			COL	120
			WIDTH  260
			CAPTION aLangStrings[74]
			VALUE lMatchCase
			ON CHANGE lFirstFind := .T.
		END CHECKBOX

		DEFINE CHECKBOX Check_2
			ROW	154
			COL	120
			WIDTH  260
			CAPTION aLangStrings[75]
			VALUE lMatchWhole
			ON CHANGE lFirstFind := .T.
		END CHECKBOX

		DEFINE BUTTON Button_1
	        ROW    10
		COL    350
	        WIDTH  80
		HEIGHT 24
	        CAPTION aLangStrings[76]
		ACTION FindNext(Form_Find.Combo_1.DisplayValue, Form_Find.Combo_3.Value, ;
			Form_Find.Check_1.Value, Form_Find.Check_2.Value)
	        TABSTOP .T.
		VISIBLE .T.
		END BUTTON

		DEFINE BUTTON Button_2
	        ROW    40
	        COL    350
		WIDTH  80
	        HEIGHT 24
		CAPTION aLangStrings[4]
	        ACTION ( ThisWindow.Release, DoMethod( "Form_" + Ltrim(Str(nFocus)), 'Setfocus' ) )
		TABSTOP .T.
	        VISIBLE .T.
		END BUTTON

		DEFINE BUTTON Button_3
	        ROW    70
		COL    350
	        WIDTH  80
		HEIGHT 24
	        CAPTION IF(lReplace, "&"+aLangStrings[65], aLangStrings[12])
		ACTION IF(lReplace, DoReplace(Form_Find.Combo_1.DisplayValue, Form_Find.Combo_2.DisplayValue, ;
			Form_Find.Combo_3.Value, Form_Find.Check_1.Value, Form_Find.Check_2.Value), ;
			( Form_Find.Button_3.Caption := "&"+aLangStrings[65], Form_Find.Button_3.Enabled := .f., ;
			Form_Find.Button_4.Visible := .t., Form_Find.Button_4.Enabled := .f., Form_Find.Label_3.Visible := .t., ;
			Form_Find.Combo_2.Visible := .t., ThisWindow.Title := aLangStrings[65], Form_Find.Combo_1.Setfocus, lReplace := .t. ))
	        TABSTOP .T.
		VISIBLE .T.
		END BUTTON

		DEFINE BUTTON Button_4
	        ROW    100
		COL    350
	        WIDTH  80
		HEIGHT 24
	        CAPTION aLangStrings[77]
		ACTION DoReplace(Form_Find.Combo_1.DisplayValue, Form_Find.Combo_2.DisplayValue, ;
			Form_Find.Combo_3.Value, Form_Find.Check_1.Value, Form_Find.Check_2.Value, .t.)
	        TABSTOP .T.
		VISIBLE lReplace
		END BUTTON

		ON KEY RETURN ACTION IF(lReplace, Form_Find.Button_3.OnClick, Form_Find.Button_1.OnClick )
		ON KEY ESCAPE ACTION Form_Find.Button_2.OnClick

	END WINDOW

	Form_Find.Button_1.Enabled := .f.
	Form_Find.Button_3.Enabled := !lReplace
	Form_Find.Button_4.Enabled := !lReplace

	CENTER WINDOW Form_Find

	ACTIVATE WINDOW Form_Find

   ENDIF

Return

*------------------------------------------------------------------------------*
Static Procedure FindNext( cString, nField, lCase, lWhole )
*------------------------------------------------------------------------------*
   Local aColumns := (cAlias)->( DBstruct(cAlias) )
   Local nRecno := (cAlias)->( RecNo() ), cType

	IF EMPTY(cString)
		Return
	ELSEIF ASCAN(aSearch, cString) == 0
		AADD(aSearch, cString)
		Form_Find.Combo_1.AddItem(cString)
	ENDIF
	IF !EMPTY(nField)
		nColumns := nField
	ENDIF
	lMatchCase := lCase
	lMatchWhole := lWhole

	lFind := .T.
	IF nField == 1
		cFind := ""
		IF lFirstFind
			lFirstFind := .F.
			IF nDirect == 3
				(cAlias)->( DbGotop() )
				DO WHILE !(cAlias)->( EoF() )
					cFindStr := IF(lCase, ALLTRIM(cString), UPPER(ALLTRIM(cString)))
					aColumns := (cAlias)->( Scatter() )
					Aeval(aColumns, {|x| cFind += XtoC(x) + " "})
					IF lCase
						IF cFindStr $ cFind
							EXIT
						ENDIF
					ELSE
						IF cFindStr $ UPPER(cFind)
							EXIT
						ENDIF
					ENDIF
					(cAlias)->( DbSkip() )
				ENDDO
				IF (cAlias)->( EoF() )
					lFind := .F.
					(cAlias)->( DbGoto(nRecno) )
					MsgAlert( aLangStrings[78]+' "'+cString+'"' )
				ENDIF
			ELSEIF nDirect == 2
				(cAlias)->( DbSkip(-1) )
				DO WHILE !(cAlias)->( BoF() )
					cFindStr := IF(lCase, ALLTRIM(cString), UPPER(ALLTRIM(cString)))
					aColumns := (cAlias)->( Scatter() )
					Aeval(aColumns, {|x| cFind += XtoC(x) + " "})
					IF lCase
						IF cFindStr $ cFind
							EXIT
						ENDIF
					ELSE
						IF cFindStr $ UPPER(cFind)
							EXIT
						ENDIF
					ENDIF
					(cAlias)->( DbSkip(-1) )
				ENDDO
				IF (cAlias)->( BoF() )
					lFind := .F.
					(cAlias)->( DbGoto(nRecno) )
					MsgAlert( aLangStrings[78]+' "'+cString+'"' )
				ENDIF
			ELSEIF nDirect == 1
				(cAlias)->( DbSkip() )
				DO WHILE !(cAlias)->( EoF() )
					cFindStr := IF(lCase, ALLTRIM(cString), UPPER(ALLTRIM(cString)))
					aColumns := (cAlias)->( Scatter() )
					Aeval(aColumns, {|x| cFind += XtoC(x) + " "})
					IF lCase
						IF cFindStr $ cFind
							EXIT
						ENDIF
					ELSE
						IF cFindStr $ UPPER(cFind)
							EXIT
						ENDIF
					ENDIF
					(cAlias)->( DbSkip() )
				ENDDO
				IF (cAlias)->( EoF() )
					lFind := .F.
					(cAlias)->( DbGoto(nRecno) )
					MsgAlert( aLangStrings[78]+' "'+cString+'"' )
				ENDIF
			ENDIF
		ELSEIF lFind
			IF nDirect == 2
				(cAlias)->( DbSkip(-1) )
			ELSE
				(cAlias)->( DbSkip() )
			ENDIF
			DO WHILE !IF(nDirect = 2, (cAlias)->( BoF() ), (cAlias)->( EoF() ))
				cFindStr := IF(lCase, ALLTRIM(cString), UPPER(ALLTRIM(cString)))
				aColumns := (cAlias)->( Scatter() )
				Aeval(aColumns, {|x| cFind += XtoC(x) + " "})
				IF lCase
					IF cFindStr $ cFind
						EXIT
					ENDIF
				ELSE
					IF cFindStr $ UPPER(cFind)
						EXIT
					ENDIF
				ENDIF
				IF nDirect == 2
					(cAlias)->( DbSkip(-1) )
				ELSE
					(cAlias)->( DbSkip() )
				ENDIF
			ENDDO
			IF (cAlias)->( EoF() ) .OR. (cAlias)->( BoF() )
				lFind := .F.
				(cAlias)->( DbGoto(nRecno) )
				MsgAlert( aLangStrings[79] )
			ENDIF
		ENDIF
	ELSE
		cField := aColumns[nField-1][1]
		cType := aColumns[nField-1][2]
		IF cType $ "CND"
			IF cType == "C"
				IF lWhole
					cFindStr := cString
					cFind := "ALLTRIM((cAlias)->((&cField)))==M->cFindStr"
				ELSE
					cFindStr := IF(lCase, ALLTRIM(cString), UPPER(ALLTRIM(cString)))
					IF lCase
						cFind := "M->cFindStr $ (cAlias)->((&cField))"
					ELSE
						cFind := "M->cFindStr $ UPPER((cAlias)->((&cField)))"
					ENDIF
				ENDIF
			ELSEIF cType == "N"
				cFindStr := VAL(cString)
				cFind := "(cAlias)->((&cField))=M->cFindStr"
				cFind := "(cAlias)->((&cField))=M->cFindStr"
			ELSEIF cType == "D"
				cFindStr := CTOD(cString)
				cFind := "(cAlias)->((&cField))=M->cFindStr"
			ENDIF
			IF lFirstFind
				lFirstFind := .F.
				IF nDirect == 3
					(cAlias)->( __dbLocate({||(&cFind)},,,,.F.) )
					IF (cAlias)->( EoF() )
						lFind := .F.
						(cAlias)->( DbGoto(nRecno) )
						MsgAlert( aLangStrings[78]+' "'+cString+'"' )
					ENDIF
				ELSEIF nDirect == 2
					(cAlias)->( DbSkip(-1) )
					DO WHILE !(cAlias)->( BoF() )
						IF &cFind
							EXIT
						ENDIF
						(cAlias)->( DbSkip(-1) )
					ENDDO
					IF (cAlias)->( BoF() )
						lFind := .F.
						(cAlias)->( DbGoto(nRecno) )
						MsgAlert( aLangStrings[78]+' "'+cString+'"' )
					ENDIF
				ELSEIF nDirect == 1
					(cAlias)->( DbSkip() )
					(cAlias)->( __dbLocate({||(&cFind)},,,,.T.) )
					IF (cAlias)->( EoF() )
						lFind := .F.
						(cAlias)->( DbGoto(nRecno) )
						MsgAlert( aLangStrings[78]+' "'+cString+'"' )
					ENDIF
				ENDIF
			ELSEIF lFind
				IF nDirect == 2
					(cAlias)->( DbSkip(-1) )
					DO WHILE !(cAlias)->( BoF() )
						IF &cFind
							EXIT
						ENDIF
						(cAlias)->( DbSkip(-1) )
					ENDDO
				ELSE
					(cAlias)->( __dbContinue() )
				ENDIF
				IF (cAlias)->( EoF() ) .OR. (cAlias)->( BoF() )
					lFind := .F.
					(cAlias)->( DbGoto(nRecno) )
					MsgAlert( aLangStrings[79] )
				ENDIF
			ENDIF
		ENDIF
	ENDIF
	SetProperty( "Form_" + Ltrim(Str(nFocus)), "Browse_1", "Value", (cAlias)->( RecNo() ) )
	DoMethod( "Form_" + Ltrim(Str(nFocus)), "Browse_1", 'Refresh' )

Return

*------------------------------------------------------------------------------*
Static Procedure DoReplace(cString, cReplace, nField, lCase, lWhole, lAll)
*------------------------------------------------------------------------------*
   Local aColumns := (cAlias)->( DBstruct(cAlias) ), cType, cFld, i, lReplace
   Local nRecno := (cAlias)->( RecNo() )

   DEFAULT lAll := .f.

	IF EMPTY(cString) .OR. EMPTY(cReplace)
		Return
	ELSEIF ASCAN(aReplace, cReplace) == 0
		AADD(aReplace, cReplace)
		Form_Find.Combo_2.AddItem(cString)
	ENDIF
	IF lAll
		IF ASCAN(aSearch, cString) == 0
			AADD(aSearch, cString)
			Form_Find.Combo_1.AddItem(cString)
		ENDIF
		IF nField == 1
			IF nDirect == 3
				(cAlias)->( DbGotop() )
				DO WHILE !(cAlias)->( EoF() )
					aColumns := (cAlias)->( Scatter() )
					For i := 1 To Len(aColumns)
						cFld := aColumns[i]
						IF cType == "N"
							lReplace := ( cFld = VAL(cString) )
							IF lReplace
								(cAlias)->&cField := VAL(cReplace)
							ENDIF
						ELSEIF cType == "D"
							lReplace := ( cFld = CTOD(cString) )
							IF lReplace
								(cAlias)->&cField := CTOD(cReplace)
							ENDIF
						ELSEIF Valtype( cFld ) == "C"
							IF lWhole
								lReplace := ( cFld == cString )
							ELSE
								IF lCase
									lReplace := cString $ cFld
								ELSE
									lReplace := UPPER(cString) $ UPPER(cFld)
								ENDIF
							ENDIF
							IF lReplace
								IF (cAlias)->( Rlock() )
									cField := (cAlias)->( Field(i) )
									(cAlias)->&cField := STRTRAN(cFld, cString, cReplace)
								ENDIF
								(cAlias)->( DBunlock() )
							ENDIF
						ENDIF
					Next
					(cAlias)->( DbSkip() )
				ENDDO
				(cAlias)->( DbGoto(nRecno) )
			ELSEIF nDirect == 2
				(cAlias)->( DbSkip(-1) )
				DO WHILE !(cAlias)->( BoF() )
					aColumns := (cAlias)->( Scatter() )
					For i := 1 To Len(aColumns)
						cFld := aColumns[i]
						IF cType == "N"
							lReplace := ( cFld = VAL(cString) )
							IF lReplace
								(cAlias)->&cField := VAL(cReplace)
							ENDIF
						ELSEIF cType == "D"
							lReplace := ( cFld = CTOD(cString) )
							IF lReplace
								(cAlias)->&cField := CTOD(cReplace)
							ENDIF
						ELSEIF Valtype( cFld ) == "C"
							IF lWhole
								lReplace := ( cFld == cString )
							ELSE
								IF lCase
									lReplace := cString $ cFld
								ELSE
									lReplace := UPPER(cString) $ UPPER(cFld)
								ENDIF
							ENDIF
							IF lReplace
								IF (cAlias)->( Rlock() )
									cField := (cAlias)->( Field(i) )
									(cAlias)->&cField := STRTRAN(cFld, cString, cReplace)
								ENDIF
								(cAlias)->( DBunlock() )
							ENDIF
						ENDIF
					Next
					(cAlias)->( DbSkip(-1) )
				ENDDO
				(cAlias)->( DbGoto(nRecno) )
			ELSEIF nDirect == 1
				(cAlias)->( DbSkip() )
				DO WHILE !(cAlias)->( EoF() )
					aColumns := (cAlias)->( Scatter() )
					For i := 1 To Len(aColumns)
						cFld := aColumns[i]
						IF cType == "N"
							lReplace := ( cFld = VAL(cString) )
							IF lReplace
								(cAlias)->&cField := VAL(cReplace)
							ENDIF
						ELSEIF cType == "D"
							lReplace := ( cFld = CTOD(cString) )
							IF lReplace
								(cAlias)->&cField := CTOD(cReplace)
							ENDIF
						ELSEIF Valtype( cFld ) == "C"
							IF lWhole
								lReplace := ( cFld == cString )
							ELSE
								IF lCase
									lReplace := cString $ cFld
								ELSE
									lReplace := UPPER(cString) $ UPPER(cFld)
								ENDIF
							ENDIF
							IF lReplace
								IF (cAlias)->( Rlock() )
									cField := (cAlias)->( Field(i) )
									(cAlias)->&cField := STRTRAN(cFld, cString, cReplace)
								ENDIF
								(cAlias)->( DBunlock() )
							ENDIF
						ENDIF
					Next
					(cAlias)->( DbSkip() )
				ENDDO
				(cAlias)->( DbGoto(nRecno) )
			ENDIF
		ELSE
			cField := aColumns[nField-1][1]
			cType := aColumns[nField-1][2]
			IF nDirect == 3
				(cAlias)->( DbGotop() )
				IF (cAlias)->( Flock() )
					cReplStr := cReplace
					cFindStr := ALLTRIM(cString)
					IF cType == "N"
						(cAlias)->( DBEval({||(cAlias)->&(cField) := VAL(cReplStr)},{||(cAlias)->&(cField)=VAL(cFindStr)},,,,.F.) )
					ELSEIF cType == "D"
						(cAlias)->( DBEval({||(cAlias)->&(cField) := CTOD(cReplStr)},{||(cAlias)->&(cField)=CTOD(cFindStr)},,,,.F.) )
					ELSE
						IF lWhole
							(cAlias)->( DBEval({||(cAlias)->&(cField) := STRTRAN((cAlias)->&(cField), cFindStr, cReplStr)},{||(cAlias)->&(cField) == M->cFindStr},,,,.F.) )
						ELSE
							IF lCase
								(cAlias)->( DBEval({||(cAlias)->&(cField) := STRTRAN((cAlias)->&(cField), cFindStr, cReplStr)},{||M->cFindStr $ (cAlias)->&(cField)},,,,.F.) )
							ELSE
								(cAlias)->( DBEval({||(cAlias)->&(cField) := STRTRAN((cAlias)->&(cField), cFindStr, cReplStr)},{||UPPER(M->cFindStr) $ UPPER((cAlias)->&(cField))},,,,.F.) )
							ENDIF
						ENDIF
					ENDIF
				ENDIF
			ELSEIF nDirect == 2
				(cAlias)->( DbGotop() )
				IF (cAlias)->( Flock() )
					nCurRec := nRecno
					cReplStr := cReplace
					cFindStr := ALLTRIM(cString)
					IF cType == "N"
						(cAlias)->( DBEval({||(cAlias)->&(cField) := VAL(cReplStr)},{||(cAlias)->&(cField)=VAL(cFindStr)},{||(cAlias)->( Recno() )<nCurRec},,,.F.) )
					ELSEIF cType == "D"
						(cAlias)->( DBEval({||(cAlias)->&(cField) := CTOD(cReplStr)},{||(cAlias)->&(cField)=CTOD(cFindStr)},{||(cAlias)->( Recno() )<nCurRec},,,.F.) )
					ELSE
						IF lWhole
							(cAlias)->( DBEval({||(cAlias)->&(cField) := STRTRAN((cAlias)->&(cField), cFindStr, cReplStr)},{||(cAlias)->&(cField) == M->cFindStr},{||(cAlias)->( Recno() )<nCurRec},,,.F.) )
						ELSE
							IF lCase
								(cAlias)->( DBEval({||(cAlias)->&(cField) := STRTRAN((cAlias)->&(cField), cFindStr, cReplStr)},{||M->cFindStr $ (cAlias)->&(cField)},{||(cAlias)->( Recno() )<nCurRec},,,.F.) )
							ELSE
								(cAlias)->( DBEval({||(cAlias)->&(cField) := STRTRAN((cAlias)->&(cField), cFindStr, cReplStr)},{||UPPER(M->cFindStr) $ UPPER((cAlias)->&(cField))},{||(cAlias)->( Recno() )<nCurRec},,,.F.) )
							ENDIF
						ENDIF
					ENDIF
				ENDIF
			ELSEIF nDirect == 1
				IF (cAlias)->( Flock() )
					cReplStr := cReplace
					cFindStr := ALLTRIM(cString)
					IF cType == "N"
						(cAlias)->( DBEval({||(cAlias)->&(cField) := VAL(cReplStr)},{||(cAlias)->&(cField)=VAL(cFindStr)},,,,.T.) )
					ELSEIF cType == "D"
						(cAlias)->( DBEval({||(cAlias)->&(cField) := CTOD(cReplStr)},{||(cAlias)->&(cField)=CTOD(cFindStr)},,,,.T.) )
					ELSE
						IF lWhole
							(cAlias)->( DBEval({||(cAlias)->&(cField) := STRTRAN((cAlias)->&(cField), cFindStr, cReplStr)},{||(cAlias)->&(cField) == M->cFindStr},,,,.T.) )
						ELSE
							IF lCase
								(cAlias)->( DBEval({||(cAlias)->&(cField) := STRTRAN((cAlias)->&(cField), cFindStr, cReplStr)},{||M->cFindStr $ (cAlias)->(&(cField))},,,,.T.) )
							ELSE
								(cAlias)->( DBEval({||(cAlias)->&(cField) := STRTRAN((cAlias)->&(cField), cFindStr, cReplStr)},{||UPPER(M->cFindStr) $ UPPER((cAlias)->&(cField))},,,,.T.) )
							ENDIF
						ENDIF
					ENDIF
				ENDIF
			ENDIF
			(cAlias)->( DBunlock() )
			(cAlias)->( DbGoto(nRecno) )
		ENDIF
	ELSE
		lFind := .T.
		FindNext( cString, nField, lCase, lWhole )
		IF nField == 1
			IF lFind
				aColumns := (cAlias)->( Scatter() )
				For i := 1 To Len(aColumns)
					cFld := aColumns[i]
					IF Valtype( cFld ) == "C"
						IF lCase
							lReplace := cString $ cFld
						ELSE
							lReplace := UPPER(cString) $ UPPER(cFld)
						ENDIF
						IF lReplace
							IF (cAlias)->( Rlock() )
								cField := (cAlias)->( Field(i) )
								(cAlias)->&cField := STRTRAN(cFld, cString, cReplace)
							ENDIF
							(cAlias)->( DBunlock() )
						ENDIF
					ENDIF
				Next
			ENDIF
		ELSE
			cField := aColumns[nField-1][1]
			cType := aColumns[nField-1][2]
			IF lFind .AND. cType $ "CND"
				IF (cAlias)->( Rlock() )
					IF cType == "N"
						(cAlias)->&cField := VAL(cReplace)
					ELSEIF cType == "D"
						(cAlias)->&cField := CTOD(cReplace)
					ELSE
						(cAlias)->&cField := cReplace
					ENDIF
				ENDIF
			ENDIF
			(cAlias)->( DBunlock() )
		ENDIF
	ENDIF
	SetProperty( "Form_" + Ltrim(Str(nFocus)), "Browse_1", "Value", (cAlias)->( RecNo() ) )
	DoMethod( "Form_" + Ltrim(Str(nFocus)), "Browse_1", 'Refresh' )

Return

*------------------------------------------------------------------------------*
Static Procedure AppendCopy()
*------------------------------------------------------------------------------*
   Local aCurrent

   IF !Empty(nFocus)
	aCurrent := (aArea[nFocus])->( Scatter() )

	IF (aArea[nFocus])->( Rlock() )
		(aArea[nFocus])->( DBappend() )
		(aArea[nFocus])->( Gather(aCurrent) )
	ENDIF
	(aArea[nFocus])->( DBunlock() )
	SetProperty( "Form_" + Ltrim(Str(nFocus)), "Browse_1", "Value", (aArea[nFocus])->( RecNo() ) )
	DoMethod( "Form_" + Ltrim(Str(nFocus)), "Browse_1", 'Refresh' )
	DoMethod( "Form_" + Ltrim(Str(nFocus)), 'Setfocus' )

   ENDIF

Return

*--------------------------------------------------------*
Static Function Scatter()
*--------------------------------------------------------*
   Local aRecord[fcount()]

Return aEval( aRecord, {|x,n| aRecord[n] := FieldGet( n ) } )

*--------------------------------------------------------*
Static Function Gather( paRecord )
*--------------------------------------------------------*
Return aEval( paRecord, {|x,n| FieldPut( n, x ) } )

*-----------------------------------------------------------------------------*
Static Function GetBackColor()
*-----------------------------------------------------------------------------*
   Local aRetVal[3], nColor, nInitColor := RGB(aBackClr[1], aBackClr[2], aBackClr[3]), ;
	aCustomColors := { RGB(255,255,0), RGB(0,255,0), RGB(0,255,255), ;
		RGB(0,128,255), RGB(255,128,255), RGB(240,240,240), RGB(192,192,192), RGB(255,128,0), ;
		RGB(225,225,0), RGB(0,225,0), RGB(0,225,225), ;
		RGB(0,128,225), RGB(225,128,225), RGB(140,140,140), RGB(216,216,216), RGB(225,128,0) }

	nColor := ChooseColor( NIL, nInitColor, aCustomColors )

	If nColor == -1
		aRetVal[1] := GetRed(nInitColor)
		aRetVal[2] := GetGreen(nInitColor)
		aRetVal[3] := GetBlue(nInitColor)
	Else
		aRetVal[1] := GetRed(nColor)
		aRetVal[2] := GetGreen(nColor)
		aRetVal[3] := GetBlue(nColor)
	EndIf

Return aRetVal

*--------------------------------------------------------*
Static Procedure SetGoto()
*--------------------------------------------------------*

   IF !Empty(nFocus)

	DEFINE WINDOW Form_Goto ;
		AT 0, 0 WIDTH 324 + IF(lIsVistaOrLater, GetBorderWidth(), 0) HEIGHT 164 + IF(lXPTheme, 8, 0) ;
		TITLE aLangStrings[80] ;
		ICON 'CHILD' ;
		MODAL ;
		ON INIT Form_Goto.Button_1.Setfocus ;
		FONT "MS Sans Serif" ;
		SIZE 8

		DEFINE LABEL Label_1
	        ROW    10
		COL    10
	        WIDTH  60
		HEIGHT 18
	        VALUE aLangStrings[80]
		VISIBLE .T.
	        AUTOSIZE .F.
		END LABEL

		DEFINE RADIOGROUP Radio_1
			ROW	25
			COL	10
			OPTIONS { aLangStrings[81], aLangStrings[82], aLangStrings[83], aLangStrings[84] } 
			VALUE nGoto
			WIDTH 100 
			ONCHANGE ( nGoto := This.Value, ;
				Form_Goto.Spinner_1.Enabled := (nGoto == 3), ;
				Form_Goto.Spinner_2.Enabled := (nGoto == 4) )
			TABSTOP .T.
		END RADIOGROUP

		DEFINE SPINNER Spinner_1
			ROW	74
			COL	114
			RANGEMIN 1
			RANGEMAX (aArea[nFocus])->( LastRec() )
			VALUE nGoRow
			WIDTH 80 
			ONCHANGE nGoRow := This.Value
		END SPINNER

		DEFINE SPINNER Spinner_2
			ROW	104
			COL	114
			RANGEMIN 1
			RANGEMAX (aArea[nFocus])->( LastRec() )
			VALUE nGoRecord
			WIDTH 80 
			ONCHANGE nGoRecord := This.Value
		END SPINNER

		DEFINE BUTTON Button_1
	        ROW    10
		COL    224
	        WIDTH  80
		HEIGHT 24
	        CAPTION aLangStrings[85]
		ACTION ( IF( nGoto == 1, ( SetProperty( "Form_" + Ltrim(Str(nFocus)), "Browse_1", "Value", 1 ), ;
			DoMethod( "Form_" + Ltrim(Str(nFocus)), "Setfocus" ) ), ;
			IF( nGoto == 2, ( (aArea[nFocus])->( dbGoBottom() ), ;
			SetProperty( "Form_" + Ltrim(Str(nFocus)), "Browse_1", "Value", (aArea[nFocus])->( RecNo() ) ), ;
			DoMethod( "Form_" + Ltrim(Str(nFocus)), "Setfocus" ) ), ;
			IF( nGoto == 3, IF(Empty(DbFilter()), SetProperty( "Form_" + Ltrim(Str(nFocus)), "Browse_1", "Value", nGoRow ), ;
			( (aArea[nFocus])->( dbGoTop() ), (aArea[nFocus])->( dbSkip(nGoRow - 1) ), ;
			IF((aArea[nFocus])->( EoF() ), (aArea[nFocus])->( dbGoBottom() ), ), ;
			SetProperty( "Form_" + Ltrim(Str(nFocus)), "Browse_1", "Value", (aArea[nFocus])->( RecNo() ) ) )), ;
			( (aArea[nFocus])->( dbGoto(nGoRecord) ), ;
			SetProperty( "Form_" + Ltrim(Str(nFocus)), "Browse_1", "Value", (aArea[nFocus])->( RecNo() ) ) ) ))), ;
			ThisWindow.Release, ;
			DoMethod( "Form_" + Ltrim(Str(nFocus)), "Browse_1", "Refresh" ), ;
			DoMethod( "Form_" + Ltrim(Str(nFocus)), "Setfocus" ) )
	        TABSTOP .T.
		VISIBLE .T.
		END BUTTON

		DEFINE BUTTON Button_2
	        ROW    40
	        COL    224
		WIDTH  80
	        HEIGHT 24
		CAPTION aLangStrings[86]
	        ACTION ( ThisWindow.Release, DoMethod( "Form_" + Ltrim(Str(nFocus)), 'Setfocus' ) )
		TABSTOP .T.
	        VISIBLE .T.
		END BUTTON

		ON KEY RETURN ACTION Form_Goto.Button_1.OnClick
		ON KEY ESCAPE ACTION Form_Goto.Button_2.OnClick

	END WINDOW

	Form_Goto.Spinner_1.Enabled := (nGoto == 3)
	Form_Goto.Spinner_2.Enabled := (nGoto == 4)

	CENTER WINDOW Form_Goto

	ACTIVATE WINDOW Form_Goto

   ENDIF

Return

*--------------------------------------------------------*
Static Procedure SelectLanguage()
*--------------------------------------------------------*
   Local aLang := _GetIniSections(), cForm
   Local nLang := aScan( aLang, cBaseLang )
   Local aNames := { "YYYYMMDD", "MM/DD/YY", "MM/DD/YYYY", "DD.MM.YY", "DD.MM.YYYY" }
   Local nValue := aScan( aNames, Set( _SET_DATEFORMAT ) )

   IF !Empty(nFocus)

	DEFINE WINDOW Form_Language ;
		AT 0, 0 WIDTH 307 + IF(lIsVistaOrLater, GetBorderWidth(), 0) HEIGHT 200 + IF(lXPTheme, 8, 0) ;
		TITLE aLangStrings[87] ;
		ICON 'CHILD' ;
		MODAL ;
		ON INIT Form_Language.Button_1.Setfocus ;
		FONT "MS Sans Serif" ;
		SIZE 8

		DEFINE LISTBOX List_1
	        ROW    10
		COL    10
	        WIDTH  180
		HEIGHT 120
	        ITEMS aLang
		VALUE nLang
	        ONDBLCLICK Form_Language.Button_1.OnClick
		END LISTBOX

		DEFINE LABEL Label_1
	        ROW    144
		COL    10
	        WIDTH  70
		HEIGHT 21
	        VALUE aLangStrings[88]+":"
		VISIBLE .T.
	        AUTOSIZE .F.
		END LABEL

		DEFINE COMBOBOX Combo_1
			ROW	140
			COL	80
			WIDTH  110
			HEIGHT 100
			ITEMS aNames 
			VALUE nValue
			ON ENTER Form_Language.Button_1.OnClick
		END COMBOBOX

		DEFINE BUTTON Button_1
	        ROW    10
		COL    210
	        WIDTH  80
		HEIGHT 24
	        CAPTION aLangStrings[85]
		ACTION ( nValue := Form_Language.Combo_1.Value, Set( _SET_DATEFORMAT, aNames[nValue] ), ;
			cBaseLang := aLang[Form_Language.List_1.Value], SetBaseLang( cBaseLang ), ;
			LoadLangArr(), SaveMRUFileList(), BuildMainMenu(), ;
			Aeval(aChildWnd, {|e,i| cForm := "Form_" + Ltrim(Str(i)), ;
			IF( _IsControlDefined( "Browse_1", cForm ), ;
			Form_Main.StatusBar.Item(i) := IF(nWidth < 1024, "# ", aLangStrings[56]+" : ") + Ltrim(str(i)), )}), ;
			SaveParameter("Interface", "Language", cBaseLang), ;
			SaveParameter("Interface", "Date", Set( _SET_DATEFORMAT )), ;
			ThisWindow.Release, ;
			DoMethod( "Form_" + Ltrim(Str(nFocus)), "Browse_1", 'Refresh' ), ;
			DoMethod( "Form_" + Ltrim(Str(nFocus)), 'Setfocus' ) )
	        TABSTOP .T.
		VISIBLE .T.
		END BUTTON

		DEFINE BUTTON Button_2
	        ROW    40
	        COL    210
		WIDTH  80
	        HEIGHT 24
		CAPTION aLangStrings[86]
	        ACTION ( ThisWindow.Release, DoMethod( "Form_" + Ltrim(Str(nFocus)), 'Setfocus' ) )
		TABSTOP .T.
	        VISIBLE .T.
		END BUTTON

		ON KEY ESCAPE ACTION Form_Language.Button_2.OnClick

	END WINDOW

	CENTER WINDOW Form_Language

	ACTIVATE WINDOW Form_Language

   ENDIF

Return

*--------------------------------------------------------*
Static Procedure SelectCodepage()
*--------------------------------------------------------*
   Local aNames := { aLangStrings[89] }

   IF !Empty(nFocus)

	IF cBaseLang = "Russian"
		Aadd(aNames, "Русский DOS (866)")
		Aadd(aNames, "Русский Windows (1251)")
	ELSEIF cBaseLang = "Polish"
		Aadd(aNames, "Polski Latin2 (PL852)")
		Aadd(aNames, "Polski Windows (PLWIN)")
		Aadd(aNames, "Polski Mazowia (PLMAZ)")
		Aadd(aNames, "Polski ISO 8859-2 (PLISO)")
	ELSEIF cBaseLang = "Spanish"
		Aadd(aNames, "Spanish DOS (ES)")
		Aadd(aNames, "Spanish Windows (ESWIN)")
	ELSEIF cBaseLang = "German"
		Aadd(aNames, "German DOS (DE)")
		Aadd(aNames, "German Windows (DEWIN)")
	ENDIF

	DEFINE WINDOW Form_Codepage ;
		AT 0, 0 WIDTH 208 + IF(lIsVistaOrLater, GetBorderWidth(), 0) HEIGHT 200 + IF(lXPTheme, 8, 0) ;
		TITLE aLangStrings[90] ;
		ICON 'CHILD' ;
		MODAL ;
		ON INIT Form_Codepage.List_1.Setfocus ;
		FONT "MS Sans Serif" ;
		SIZE 8

		DEFINE LABEL Label_1
	        ROW    8
		COL    10
	        WIDTH  180
		HEIGHT 21
	        VALUE aLangStrings[91]+":"
		VISIBLE .T.
	        AUTOSIZE .F.
		END LABEL

		DEFINE LISTBOX List_1
	        ROW    32
		COL    10
	        WIDTH  180
		HEIGHT 100
	        ITEMS aNames
		VALUE aChildCP[nFocus]
	        ONDBLCLICK Form_Codepage.Button_1.OnClick
		END LISTBOX

		DEFINE BUTTON Button_1
	        ROW    140
		COL    10
	        WIDTH  80
		HEIGHT 24
	        CAPTION aLangStrings[85]
		ACTION ( aChildCP[nFocus] := Form_Codepage.List_1.Value, SetCodepage(), ThisWindow.Release, ;
			DoMethod( "Form_" + Ltrim(Str(nFocus)), 'Setfocus' ) )
	        TABSTOP .T.
		VISIBLE .T.
		END BUTTON

		DEFINE BUTTON Button_2
	        ROW    140
	        COL    110
		WIDTH  80
	        HEIGHT 24
		CAPTION aLangStrings[86]
	        ACTION ( ThisWindow.Release, DoMethod( "Form_" + Ltrim(Str(nFocus)), 'Setfocus' ) )
		TABSTOP .T.
	        VISIBLE .T.
		END BUTTON

		ON KEY ESCAPE ACTION Form_Codepage.Button_2.OnClick

	END WINDOW

	CENTER WINDOW Form_Codepage

	ACTIVATE WINDOW Form_Codepage

   ENDIF

Return

*--------------------------------------------------------*
Static Procedure SetCodepage()
*--------------------------------------------------------*
   Local nRecNo := (aArea[nFocus])->( RecNo() )
   Local nCP := aChildCP[nFocus]

	(aArea[nFocus])->( DBcloseArea() )
	IF nCP = 1
		USE ( aChildWnd[nFocus] ) ALIAS ( aArea[nFocus] ) SHARED NEW
	ELSEIF nCP = 2
		IF cBaseLang = "Russian"
			USE ( aChildWnd[nFocus] ) ALIAS ( aArea[nFocus] ) CODEPAGE "RU866" SHARED NEW
		ELSEIF cBaseLang = "Polish"
			USE ( aChildWnd[nFocus] ) ALIAS ( aArea[nFocus] ) CODEPAGE "PL852" SHARED NEW
		ELSEIF cBaseLang = "Spanish"
			USE ( aChildWnd[nFocus] ) ALIAS ( aArea[nFocus] ) CODEPAGE "ES" SHARED NEW
		ELSEIF cBaseLang = "German"
			USE ( aChildWnd[nFocus] ) ALIAS ( aArea[nFocus] ) CODEPAGE "DE" SHARED NEW
		ENDIF
	ELSEIF nCP = 3
		IF cBaseLang = "Russian"
			USE ( aChildWnd[nFocus] ) ALIAS ( aArea[nFocus] ) CODEPAGE RUWIN SHARED NEW
		ELSEIF cBaseLang = "Polish"
			USE ( aChildWnd[nFocus] ) ALIAS ( aArea[nFocus] ) CODEPAGE "PLWIN" SHARED NEW
		ELSEIF cBaseLang = "Spanish"
			USE ( aChildWnd[nFocus] ) ALIAS ( aArea[nFocus] ) CODEPAGE "ESWIN" SHARED NEW
		ELSEIF cBaseLang = "German"
			USE ( aChildWnd[nFocus] ) ALIAS ( aArea[nFocus] ) CODEPAGE "DEWIN" SHARED NEW
		ENDIF
	ELSEIF nCP = 4
		IF cBaseLang = "Polish"
			USE ( aChildWnd[nFocus] ) ALIAS ( aArea[nFocus] ) CODEPAGE "PLMAZ" SHARED NEW
		ENDIF
	ELSEIF nCP = 5
		IF cBaseLang = "Polish"
			USE ( aChildWnd[nFocus] ) ALIAS ( aArea[nFocus] ) CODEPAGE "PLISO" SHARED NEW
		ENDIF
	ENDIF
	SetProperty( "Form_" + Ltrim(Str(nFocus)), "Browse_1", "Value", nRecNo )
	DoMethod( "Form_" + Ltrim(Str(nFocus)), "Browse_1", 'Refresh' )
	DoMethod( "Form_" + Ltrim(Str(nFocus)), 'Setfocus' )

Return

*--------------------------------------------------------*
Static Procedure ShowProperties()
*--------------------------------------------------------*
   Local aNames := {}, data_type := { "Character", "Numeric", "Date", "Logical", "Memo" }

   IF !Empty(nFocus)

	Aeval( (aArea[nFocus])->( DBstruct(aArea[nFocus]) ), ;
		{|e,i| aadd(aNames, { Str(i, 4), e[1], data_type[ AT(e[2], "CNDLM") ], Ltrim(Str(e[3])), Ltrim(Str(e[4])) })} )

	DEFINE WINDOW Form_Prop ;
		AT 0, 0 WIDTH 356 + IF(lIsVistaOrLater, GetBorderWidth(), 0) HEIGHT 402 + IF(lXPTheme, 8, 0) ;
		TITLE aLangStrings[92] ;
		ICON 'CHILD' ;
		MODAL ;
		FONT "MS Sans Serif" ;
		SIZE 8

    DEFINE FRAME Frame_1
        ROW    10
        COL    10
        WIDTH  330
        HEIGHT 100
        OPAQUE .T.
    END FRAME

    DEFINE LABEL Label_1
        ROW    18
        COL    20
        WIDTH  120
        HEIGHT 21
        VALUE aLangStrings[93]+":"
        AUTOSIZE .F.
    END LABEL

    DEFINE LABEL Label_11
        ROW    18
        COL    60
        WIDTH  268
        HEIGHT 42
        VALUE _GetCompactPath(aChildWnd[nFocus], 45)
        AUTOSIZE .F.
    END LABEL

    DEFINE LABEL Label_2
        ROW    46
        COL    20
        WIDTH  120
        HEIGHT 21
        VALUE aLangStrings[94]
        AUTOSIZE .F.
    END LABEL

    DEFINE LABEL Label_22
        ROW    46
        COL    100
        WIDTH  120
        HEIGHT 21
        VALUE Ltrim(Str(FileSize(aChildWnd[nFocus]))) + " " + aLangStrings[95]
        AUTOSIZE .F.
    END LABEL

    DEFINE LABEL Label_3
        ROW    66
        COL    20
        WIDTH  120
        HEIGHT 21
        VALUE aLangStrings[96]+":"
        AUTOSIZE .F.
    END LABEL

    DEFINE LABEL Label_33
        ROW    66
        COL    100
        WIDTH  120
        HEIGHT 21
        VALUE DtoC( (aArea[nFocus])->( LupDate() ) )
        AUTOSIZE .F.
    END LABEL

    DEFINE LABEL Label_4
        ROW    86
        COL    20
        WIDTH  120
        HEIGHT 21
        VALUE aLangStrings[97]+":"
        AUTOSIZE .F.
    END LABEL

    DEFINE LABEL Label_44
        ROW    86
        COL    100
        WIDTH  120
        HEIGHT 21
        VALUE DtoC(FileDate(aChildWnd[nFocus])) + "  " + FileTime(aChildWnd[nFocus])
        AUTOSIZE .F.
    END LABEL

    DEFINE FRAME Frame_2
        ROW    116
        COL    10
        WIDTH  330
        HEIGHT 90
        OPAQUE .T.
    END FRAME

    DEFINE LABEL Label_5
        ROW    122
        COL    20
        WIDTH  120
        HEIGHT 21
        VALUE aLangStrings[98]+":"
        AUTOSIZE .F.
    END LABEL

    DEFINE LABEL Label_55
        ROW    122
        COL    160
        WIDTH  120
        HEIGHT 21
        VALUE Ltrim(Str((aArea[nFocus])->( LastRec() )))
        AUTOSIZE .F.
    END LABEL

    DEFINE LABEL Label_6
        ROW    142
        COL    20
        WIDTH  120
        HEIGHT 21
        VALUE aLangStrings[99]+":"
        AUTOSIZE .F.
    END LABEL

    DEFINE LABEL Label_66
        ROW    142
        COL    160
        WIDTH  120
        HEIGHT 21
        VALUE Ltrim(Str((aArea[nFocus])->( Header() )))
        AUTOSIZE .F.
    END LABEL

    DEFINE LABEL Label_7
        ROW    162
        COL    20
        WIDTH  120
        HEIGHT 21
        VALUE aLangStrings[100]+":"
        AUTOSIZE .F.
    END LABEL

    DEFINE LABEL Label_77
        ROW    162
        COL    160
        WIDTH  120
        HEIGHT 21
        VALUE Ltrim(Str((aArea[nFocus])->( RecSize() )))
        AUTOSIZE .F.
    END LABEL

    DEFINE LABEL Label_8
        ROW    182
        COL    20
        WIDTH  120
        HEIGHT 21
        VALUE aLangStrings[101]+":"
        AUTOSIZE .F.
    END LABEL

    DEFINE LABEL Label_88
        ROW    182
        COL    160
        WIDTH  120
        HEIGHT 21
        VALUE Ltrim(Str((aArea[nFocus])->( Fcount() )))
        AUTOSIZE .F.
    END LABEL

    DEFINE GRID Grid_1
        ROW    212
        COL    10
        WIDTH  330
        HEIGHT 120
        ITEMS aNames
        VALUE 0
        WIDTHS { 27, 120, 72, 50, 40 }
        HEADERS {' #', ' Name', 'Type', ' Len', ' Dec'}
        NOLINES .T.
        JUSTIFY { BROWSE_JTFY_LEFT, BROWSE_JTFY_LEFT, BROWSE_JTFY_LEFT, BROWSE_JTFY_RIGHT, BROWSE_JTFY_RIGHT }
        TABSTOP .F.
    END GRID

    DEFINE BUTTON Button_1
        ROW    342
        COL    260
        WIDTH  80
        HEIGHT 24
        CAPTION aLangStrings[4]
        ACTION ( ThisWindow.Release, DoMethod( "Form_" + Ltrim(Str(nFocus)), 'Setfocus' ) )
        TABSTOP .T.
        DEFAULT .T.
    END BUTTON

		ON KEY ESCAPE ACTION Form_Prop.Button_1.OnClick

	END WINDOW

	CENTER WINDOW Form_Prop

	ACTIVATE WINDOW Form_Prop

   ENDIF

Return

*--------------------------------------------------------*
Static Procedure DBpack()
*--------------------------------------------------------*

   IF !Empty(nFocus)
	IF MsgYesNo( aLangStrings[102] + "." + CRLF + CRLF + ;
			aLangStrings[103] + " " + SUBSTR(aArea[nFocus], 1, RAT("_", aArea[nFocus]) - 1) + " ?" )

		(aArea[nFocus])->( DBcloseArea() )
		IF OpenDataBaseFile( aChildWnd[nFocus], aArea[nFocus], .T., .F., RddSetDefault() )

			(aArea[nFocus])->( __DBPack() )

			(aArea[nFocus])->( DBcloseArea() )
			OpenDataBaseFile( aChildWnd[nFocus], aArea[nFocus], .F., .F., RddSetDefault() )
			SetProperty( "Form_" + Ltrim(Str(nFocus)), "Browse_1", "Value", 1 )
			DoMethod( "Form_" + Ltrim(Str(nFocus)), "Browse_1", 'Refresh' )
			DoMethod( "Form_" + Ltrim(Str(nFocus)), 'Setfocus' )
		ENDIF
	ENDIF
   ENDIF

Return

*--------------------------------------------------------*
Static Procedure DBzap()
*--------------------------------------------------------*

   IF !Empty(nFocus)
	IF MsgYesNo( aLangStrings[104] + "." + CRLF + CRLF + ;
			aLangStrings[105] + " " + SUBSTR(aArea[nFocus], 1, RAT("_", aArea[nFocus]) - 1) + " ?" )

		(aArea[nFocus])->( DBcloseArea() )
		IF OpenDataBaseFile( aChildWnd[nFocus], aArea[nFocus], .T., .F., RddSetDefault() )

			(aArea[nFocus])->( __DBzap() )

			(aArea[nFocus])->( DBcloseArea() )
			OpenDataBaseFile( aChildWnd[nFocus], aArea[nFocus], .F., .F., RddSetDefault() )
			SetProperty( "Form_" + Ltrim(Str(nFocus)), "StatusBar", "Item", 1, ;
				aLangStrings[59] + " " + IF( Empty( (aArea[nFocus])->( Lastrec() ) ), "0", ;
				Ltrim( Str( (aArea[nFocus])->( Recno() ) ) ) ) + " " + aLangStrings[60] + " " + ;
				Ltrim( Str( (aArea[nFocus])->( Lastrec() ) ) ) )

			DoMethod( "Form_" + Ltrim(Str(nFocus)), "Browse_1", 'Refresh' )
			DoMethod( "Form_" + Ltrim(Str(nFocus)), 'Setfocus' )
		ENDIF
	ENDIF
   ENDIF

Return

*--------------------------------------------------------*
Static Procedure DeleteAll()
*--------------------------------------------------------*
   Local nRecNo

   IF !Empty(nFocus)
	nRecNo := (aArea[nFocus])->( RecNo() )
	(aArea[nFocus])->( dbGoTop() )
	DO WHILE !(aArea[nFocus])->( Eof() )
		IF (aArea[nFocus])->( Rlock() )
			(aArea[nFocus])->( DBDelete() )
		ENDIF
		(aArea[nFocus])->( DBskip() )
	ENDDO
	(aArea[nFocus])->( DBunlock() )
	SetProperty( "Form_" + Ltrim(Str(nFocus)), "Browse_1", "Value", nRecNo )
	DoMethod( "Form_" + Ltrim(Str(nFocus)), "Browse_1", 'Refresh' )
	DoMethod( "Form_" + Ltrim(Str(nFocus)), 'Setfocus' )
   ENDIF

Return

*--------------------------------------------------------*
Static Procedure UnDeleteAll()
*--------------------------------------------------------*
   Local nRecNo

   IF !Empty(nFocus)
	nRecNo := (aArea[nFocus])->( RecNo() )
	(aArea[nFocus])->( dbGoTop() )
	DO WHILE !(aArea[nFocus])->( Eof() )
		IF (aArea[nFocus])->( Rlock() )
			(aArea[nFocus])->( DBRecall() )
		ENDIF
		(aArea[nFocus])->( DBskip() )
	ENDDO
	(aArea[nFocus])->( DBunlock() )
	SetProperty( "Form_" + Ltrim(Str(nFocus)), "Browse_1", "Value", nRecNo )
	DoMethod( "Form_" + Ltrim(Str(nFocus)), "Browse_1", 'Refresh' )
	DoMethod( "Form_" + Ltrim(Str(nFocus)), 'Setfocus' )
   ENDIF

Return

*--------------------------------------------------------*
Static Procedure ToggleDelete( lMove )
*--------------------------------------------------------*
   IF !Empty(nFocus)
	DEFAULT lMove := .F.
	IF (aArea[nFocus])->( Deleted() )
		IF (aArea[nFocus])->( Rlock() )
			(aArea[nFocus])->( DBRecall() )
		ENDIF
	ELSE
		IF (aArea[nFocus])->( Rlock() )
			(aArea[nFocus])->( DBDelete() )
		ENDIF
	ENDIF
	(aArea[nFocus])->( DBunlock() )
	IF lMove
		(aArea[nFocus])->( dbSkip() )
		if (aArea[nFocus])->( EoF() )
			(aArea[nFocus])->( dbGoBottom() )
		EndIf
		SetProperty( "Form_" + Ltrim(Str(nFocus)), "Browse_1", "Value", (aArea[nFocus])->( RecNo() ) )
	ENDIF
	DoMethod( "Form_" + Ltrim(Str(nFocus)), "Browse_1", 'Refresh' )
	DoMethod( "Form_" + Ltrim(Str(nFocus)), 'Setfocus' )
   ENDIF

Return

*--------------------------------------------------------*
Static Procedure CascadeWnd()
*--------------------------------------------------------*
   Local i, nRow := nChildTop, nCol := nLeft, nAdd := GetTitleHeight() + IF(lXPTheme, 0, 2)
   Local cForm, aForms := {}, nW := 0.81 * nWidth - 2, nH := IF(nWidth = 1024, 0.61, 0.58) * nHeight

   Aeval(aChildWnd, {|e,i| cForm := "Form_" + Ltrim(Str(i)), IF( _IsControlDefined( "Browse_1", cForm ), Aadd(aForms, cForm), )})

   FOR i := 1 TO Len(aForms)

	SetProperty( aForms[i], 'Row', nRow )
	SetProperty( aForms[i], 'Col', nCol )
	SetProperty( aForms[i], 'Width', nW )
	SetProperty( aForms[i], 'Height', nH )

	nRow += nAdd
	nCol += nAdd + 1

	IF nCol + nW > nWidth + 2
		nRow := nChildTop
		nCol := 0
	ENDIF
	DO EVENTS

   NEXT

   IF !Empty( Len(aForms) )
	Aeval(aForms, {|e,i| IF(!IsWindowVisible( GetFormHandle( e ) ), DoMethod( e, 'Show' ), )})
	DO EVENTS
	SwitchToThisWindow( GetFormHandle( Atail(aForms) ) )
   ENDIF

Return

*--------------------------------------------------------*
Static Procedure TileWnd()
*--------------------------------------------------------*
   Local nRow := nChildTop, nCol := nLeft
   Local cForm, aForms := {}, nWndOpened, nW := nWidth / 2, nW3 := nWidth / 3
   Local nH2 := nHArea / 2, nH3 := nHArea / 3, nH4 := nHArea / 4

   Aeval(aChildWnd, {|e,i| cForm := "Form_" + Ltrim(Str(i)), IF( _IsControlDefined( "Browse_1", cForm ), ;
		( DoMethod( cForm, 'Show' ), Aadd(aForms, cForm) ), )})

   nWndOpened := Len(aForms)

   DO CASE
	CASE nWndOpened = 1
		SetProperty( Atail(aForms), 'Row', nRow )
		SetProperty( Atail(aForms), 'Col', nCol )
		SetProperty( Atail(aForms), 'Width', nWidth )
		SetProperty( Atail(aForms), 'Height', nHArea )

	CASE nWndOpened = 2
		SetProperty( aForms[1], 'Row', nRow )
		SetProperty( aForms[1], 'Col', nCol )
		SetProperty( aForms[1], 'Width', nWidth )
		SetProperty( aForms[1], 'Height', nH2 )

		SetProperty( aForms[2], 'Row', nRow + nH2 )
		SetProperty( aForms[2], 'Col', nCol )
		SetProperty( aForms[2], 'Width', nWidth )
		SetProperty( aForms[2], 'Height', nH2 )

	CASE nWndOpened = 3
		SetProperty( aForms[1], 'Row', nRow )
		SetProperty( aForms[1], 'Col', nCol )
		SetProperty( aForms[1], 'Width', nWidth )
		SetProperty( aForms[1], 'Height', nH3 )

		SetProperty( aForms[2], 'Row', nRow + nH3 )
		SetProperty( aForms[2], 'Col', nCol )
		SetProperty( aForms[2], 'Width', nWidth )
		SetProperty( aForms[2], 'Height', nH3 )

		SetProperty( aForms[3], 'Row', nRow + 2*nH3 )
		SetProperty( aForms[3], 'Col', nCol )
		SetProperty( aForms[3], 'Width', nWidth )
		SetProperty( aForms[3], 'Height', nH3 )

	CASE nWndOpened = 4
		SetProperty( aForms[1], 'Row', nRow )
		SetProperty( aForms[1], 'Col', nCol )
		SetProperty( aForms[1], 'Width', nW )
		SetProperty( aForms[1], 'Height', nH2 )

		SetProperty( aForms[2], 'Row', nRow + nH2 )
		SetProperty( aForms[2], 'Col', nCol )
		SetProperty( aForms[2], 'Width', nW )
		SetProperty( aForms[2], 'Height', nH2 )

		SetProperty( aForms[3], 'Row', nRow )
		SetProperty( aForms[3], 'Col', nCol + nW )
		SetProperty( aForms[3], 'Width', nW )
		SetProperty( aForms[3], 'Height', nH2 )

		SetProperty( aForms[4], 'Row', nRow + nH2 )
		SetProperty( aForms[4], 'Col', nCol + nW )
		SetProperty( aForms[4], 'Width', nW )
		SetProperty( aForms[4], 'Height', nH2 )

	CASE nWndOpened = 5
		SetProperty( aForms[1], 'Row', nRow )
		SetProperty( aForms[1], 'Col', nCol )
		SetProperty( aForms[1], 'Width', nW )
		SetProperty( aForms[1], 'Height', nH2 )

		SetProperty( aForms[2], 'Row', nRow + nH2 )
		SetProperty( aForms[2], 'Col', nCol )
		SetProperty( aForms[2], 'Width', nW )
		SetProperty( aForms[2], 'Height', nH2 )

		SetProperty( aForms[3], 'Row', nRow )
		SetProperty( aForms[3], 'Col', nCol + nW )
		SetProperty( aForms[3], 'Width', nW )
		SetProperty( aForms[3], 'Height', nH3 )

		SetProperty( aForms[4], 'Row', nRow + nH3 )
		SetProperty( aForms[4], 'Col', nCol + nW )
		SetProperty( aForms[4], 'Width', nW )
		SetProperty( aForms[4], 'Height', nH3 )

		SetProperty( aForms[5], 'Row', nRow + 2*nH3 )
		SetProperty( aForms[5], 'Col', nCol + nW )
		SetProperty( aForms[5], 'Width', nWidth )
		SetProperty( aForms[5], 'Height', nH3 )

	CASE nWndOpened = 6
		SetProperty( aForms[1], 'Row', nRow )
		SetProperty( aForms[1], 'Col', nCol )
		SetProperty( aForms[1], 'Width', nW )
		SetProperty( aForms[1], 'Height', nH3 )

		SetProperty( aForms[2], 'Row', nRow + nH3 )
		SetProperty( aForms[2], 'Col', nCol )
		SetProperty( aForms[2], 'Width', nW )
		SetProperty( aForms[2], 'Height', nH3 )

		SetProperty( aForms[3], 'Row', nRow + 2*nH3 )
		SetProperty( aForms[3], 'Col', nCol )
		SetProperty( aForms[3], 'Width', nW )
		SetProperty( aForms[3], 'Height', nH3 )

		SetProperty( aForms[4], 'Row', nRow )
		SetProperty( aForms[4], 'Col', nCol + nW )
		SetProperty( aForms[4], 'Width', nW )
		SetProperty( aForms[4], 'Height', nH3 )

		SetProperty( aForms[5], 'Row', nRow + nH3 )
		SetProperty( aForms[5], 'Col', nCol + nW )
		SetProperty( aForms[5], 'Width', nW )
		SetProperty( aForms[5], 'Height', nH3 )

		SetProperty( aForms[6], 'Row', nRow + 2*nH3 )
		SetProperty( aForms[6], 'Col', nCol + nW )
		SetProperty( aForms[6], 'Width', nW )
		SetProperty( aForms[6], 'Height', nH3 )

	CASE nWndOpened = 7
		SetProperty( aForms[1], 'Row', nRow )
		SetProperty( aForms[1], 'Col', nCol )
		SetProperty( aForms[1], 'Width', nW )
		SetProperty( aForms[1], 'Height', nH3 )

		SetProperty( aForms[2], 'Row', nRow + nH3 )
		SetProperty( aForms[2], 'Col', nCol )
		SetProperty( aForms[2], 'Width', nW )
		SetProperty( aForms[2], 'Height', nH3 )

		SetProperty( aForms[3], 'Row', nRow + 2*nH3 )
		SetProperty( aForms[3], 'Col', nCol )
		SetProperty( aForms[3], 'Width', nW )
		SetProperty( aForms[3], 'Height', nH3 )

		SetProperty( aForms[4], 'Row', nRow )
		SetProperty( aForms[4], 'Col', nCol + nW )
		SetProperty( aForms[4], 'Width', nW )
		SetProperty( aForms[4], 'Height', nH4 )

		SetProperty( aForms[5], 'Row', nRow + nH4 )
		SetProperty( aForms[5], 'Col', nCol + nW )
		SetProperty( aForms[5], 'Width', nW )
		SetProperty( aForms[5], 'Height', nH4 )

		SetProperty( aForms[6], 'Row', nRow + 2*nH4 )
		SetProperty( aForms[6], 'Col', nCol + nW )
		SetProperty( aForms[6], 'Width', nW )
		SetProperty( aForms[6], 'Height', nH4 )

		SetProperty( aForms[7], 'Row', nRow + 3*nH4 )
		SetProperty( aForms[7], 'Col', nCol + nW )
		SetProperty( aForms[7], 'Width', nW )
		SetProperty( aForms[7], 'Height', nH4 )

	CASE nWndOpened = 8
		SetProperty( aForms[1], 'Row', nRow )
		SetProperty( aForms[1], 'Col', nCol )
		SetProperty( aForms[1], 'Width', nW )
		SetProperty( aForms[1], 'Height', nH4 )

		SetProperty( aForms[2], 'Row', nRow + nH4 )
		SetProperty( aForms[2], 'Col', nCol )
		SetProperty( aForms[2], 'Width', nW )
		SetProperty( aForms[2], 'Height', nH4 )

		SetProperty( aForms[3], 'Row', nRow + 2*nH4 )
		SetProperty( aForms[3], 'Col', nCol )
		SetProperty( aForms[3], 'Width', nW )
		SetProperty( aForms[3], 'Height', nH4 )

		SetProperty( aForms[4], 'Row', nRow + 3*nH4 )
		SetProperty( aForms[4], 'Col', nCol )
		SetProperty( aForms[4], 'Width', nW )
		SetProperty( aForms[4], 'Height', nH4 )

		SetProperty( aForms[5], 'Row', nRow )
		SetProperty( aForms[5], 'Col', nCol + nW )
		SetProperty( aForms[5], 'Width', nW )
		SetProperty( aForms[5], 'Height', nH4 )

		SetProperty( aForms[6], 'Row', nRow + nH4 )
		SetProperty( aForms[6], 'Col', nCol + nW )
		SetProperty( aForms[6], 'Width', nW )
		SetProperty( aForms[6], 'Height', nH4 )

		SetProperty( aForms[7], 'Row', nRow + 2*nH4 )
		SetProperty( aForms[7], 'Col', nCol + nW )
		SetProperty( aForms[7], 'Width', nW )
		SetProperty( aForms[7], 'Height', nH4 )

		SetProperty( aForms[8], 'Row', nRow + 3*nH4 )
		SetProperty( aForms[8], 'Col', nCol + nW )
		SetProperty( aForms[8], 'Width', nW )
		SetProperty( aForms[8], 'Height', nH4 )

	CASE nWndOpened = 9
		SetProperty( aForms[1], 'Row', nRow )
		SetProperty( aForms[1], 'Col', nCol )
		SetProperty( aForms[1], 'Width', nW3 )
		SetProperty( aForms[1], 'Height', nH3 )

		SetProperty( aForms[2], 'Row', nRow + nH3 )
		SetProperty( aForms[2], 'Col', nCol )
		SetProperty( aForms[2], 'Width', nW3 )
		SetProperty( aForms[2], 'Height', nH3 )

		SetProperty( aForms[3], 'Row', nRow + 2*nH3 )
		SetProperty( aForms[3], 'Col', nCol )
		SetProperty( aForms[3], 'Width', nW3 )
		SetProperty( aForms[3], 'Height', nH3 )

		SetProperty( aForms[4], 'Row', nRow )
		SetProperty( aForms[4], 'Col', nCol + nW3 )
		SetProperty( aForms[4], 'Width', nW3 )
		SetProperty( aForms[4], 'Height', nH3 )

		SetProperty( aForms[5], 'Row', nRow + nH3 )
		SetProperty( aForms[5], 'Col', nCol + nW3 )
		SetProperty( aForms[5], 'Width', nW3 )
		SetProperty( aForms[5], 'Height', nH3 )

		SetProperty( aForms[6], 'Row', nRow + 2*nH3 )
		SetProperty( aForms[6], 'Col', nCol + nW3 )
		SetProperty( aForms[6], 'Width', nW3 )
		SetProperty( aForms[6], 'Height', nH3 )

		SetProperty( aForms[7], 'Row', nRow )
		SetProperty( aForms[7], 'Col', nCol + 2*nW3 )
		SetProperty( aForms[7], 'Width', nW3 )
		SetProperty( aForms[7], 'Height', nH3 )

		SetProperty( aForms[8], 'Row', nRow + nH3 )
		SetProperty( aForms[8], 'Col', nCol + 2*nW3 )
		SetProperty( aForms[8], 'Width', nW3 )
		SetProperty( aForms[8], 'Height', nH3 )

		SetProperty( aForms[9], 'Row', nRow + 2*nH3 )
		SetProperty( aForms[9], 'Col', nCol + 2*nW3 )
		SetProperty( aForms[9], 'Width', nW3 )
		SetProperty( aForms[9], 'Height', nH3 )

	CASE nWndOpened = 10
		SetProperty( aForms[1], 'Row', nRow )
		SetProperty( aForms[1], 'Col', nCol )
		SetProperty( aForms[1], 'Width', nW3 )
		SetProperty( aForms[1], 'Height', nH3 )

		SetProperty( aForms[2], 'Row', nRow + nH3 )
		SetProperty( aForms[2], 'Col', nCol )
		SetProperty( aForms[2], 'Width', nW3 )
		SetProperty( aForms[2], 'Height', nH3 )

		SetProperty( aForms[3], 'Row', nRow + 2*nH3 )
		SetProperty( aForms[3], 'Col', nCol )
		SetProperty( aForms[3], 'Width', nW3 )
		SetProperty( aForms[3], 'Height', nH3 )

		SetProperty( aForms[4], 'Row', nRow )
		SetProperty( aForms[4], 'Col', nCol + nW3 )
		SetProperty( aForms[4], 'Width', nW3 )
		SetProperty( aForms[4], 'Height', nH3 )

		SetProperty( aForms[5], 'Row', nRow + nH3 )
		SetProperty( aForms[5], 'Col', nCol + nW3 )
		SetProperty( aForms[5], 'Width', nW3 )
		SetProperty( aForms[5], 'Height', nH3 )

		SetProperty( aForms[6], 'Row', nRow + 2*nH3 )
		SetProperty( aForms[6], 'Col', nCol + nW3 )
		SetProperty( aForms[6], 'Width', nW3 )
		SetProperty( aForms[6], 'Height', nH3 )

		SetProperty( aForms[7], 'Row', nRow )
		SetProperty( aForms[7], 'Col', nCol + 2*nW3 )
		SetProperty( aForms[7], 'Width', nW3 )
		SetProperty( aForms[7], 'Height', nH4 )

		SetProperty( aForms[8], 'Row', nRow + nH4 )
		SetProperty( aForms[8], 'Col', nCol + 2*nW3 )
		SetProperty( aForms[8], 'Width', nW3 )
		SetProperty( aForms[8], 'Height', nH4 )

		SetProperty( aForms[9], 'Row', nRow + 2*nH4 )
		SetProperty( aForms[9], 'Col', nCol + 2*nW3 )
		SetProperty( aForms[9], 'Width', nW3 )
		SetProperty( aForms[9], 'Height', nH4 )

		SetProperty( aForms[10], 'Row', nRow + 3*nH4 )
		SetProperty( aForms[10], 'Col', nCol + 2*nW3 )
		SetProperty( aForms[10], 'Width', nW3 )
		SetProperty( aForms[10], 'Height', nH4 )

	CASE nWndOpened = 11
		SetProperty( aForms[1], 'Row', nRow )
		SetProperty( aForms[1], 'Col', nCol )
		SetProperty( aForms[1], 'Width', nW3 )
		SetProperty( aForms[1], 'Height', nH3 )

		SetProperty( aForms[2], 'Row', nRow + nH3 )
		SetProperty( aForms[2], 'Col', nCol )
		SetProperty( aForms[2], 'Width', nW3 )
		SetProperty( aForms[2], 'Height', nH3 )

		SetProperty( aForms[3], 'Row', nRow + 2*nH3 )
		SetProperty( aForms[3], 'Col', nCol )
		SetProperty( aForms[3], 'Width', nW3 )
		SetProperty( aForms[3], 'Height', nH3 )

		SetProperty( aForms[4], 'Row', nRow )
		SetProperty( aForms[4], 'Col', nCol + nW3 )
		SetProperty( aForms[4], 'Width', nW3 )
		SetProperty( aForms[4], 'Height', nH4 )

		SetProperty( aForms[5], 'Row', nRow + nH4 )
		SetProperty( aForms[5], 'Col', nCol + nW3 )
		SetProperty( aForms[5], 'Width', nW3 )
		SetProperty( aForms[5], 'Height', nH4 )

		SetProperty( aForms[6], 'Row', nRow + 2*nH4 )
		SetProperty( aForms[6], 'Col', nCol + nW3 )
		SetProperty( aForms[6], 'Width', nW3 )
		SetProperty( aForms[6], 'Height', nH4 )

		SetProperty( aForms[7], 'Row', nRow + 3*nH4 )
		SetProperty( aForms[7], 'Col', nCol + nW3 )
		SetProperty( aForms[7], 'Width', nW3 )
		SetProperty( aForms[7], 'Height', nH4 )

		SetProperty( aForms[8], 'Row', nRow )
		SetProperty( aForms[8], 'Col', nCol + 2*nW3 )
		SetProperty( aForms[8], 'Width', nW3 )
		SetProperty( aForms[8], 'Height', nH4 )

		SetProperty( aForms[9], 'Row', nRow + nH4 )
		SetProperty( aForms[9], 'Col', nCol + 2*nW3 )
		SetProperty( aForms[9], 'Width', nW3 )
		SetProperty( aForms[9], 'Height', nH4 )

		SetProperty( aForms[10], 'Row', nRow + 2*nH4 )
		SetProperty( aForms[10], 'Col', nCol + 2*nW3 )
		SetProperty( aForms[10], 'Width', nW3 )
		SetProperty( aForms[10], 'Height', nH4 )

		SetProperty( aForms[11], 'Row', nRow + 3*nH4 )
		SetProperty( aForms[11], 'Col', nCol + 2*nW3 )
		SetProperty( aForms[11], 'Width', nW3 )
		SetProperty( aForms[11], 'Height', nH4 )

	CASE nWndOpened = 12
		SetProperty( aForms[1], 'Row', nRow )
		SetProperty( aForms[1], 'Col', nCol )
		SetProperty( aForms[1], 'Width', nW3 )
		SetProperty( aForms[1], 'Height', nH4 )

		SetProperty( aForms[2], 'Row', nRow + nH4 )
		SetProperty( aForms[2], 'Col', nCol )
		SetProperty( aForms[2], 'Width', nW3 )
		SetProperty( aForms[2], 'Height', nH4 )

		SetProperty( aForms[3], 'Row', nRow + 2*nH4 )
		SetProperty( aForms[3], 'Col', nCol )
		SetProperty( aForms[3], 'Width', nW3 )
		SetProperty( aForms[3], 'Height', nH4 )

		SetProperty( aForms[4], 'Row', nRow + 3*nH4 )
		SetProperty( aForms[4], 'Col', nCol )
		SetProperty( aForms[4], 'Width', nW3 )
		SetProperty( aForms[4], 'Height', nH4 )

		SetProperty( aForms[5], 'Row', nRow )
		SetProperty( aForms[5], 'Col', nCol + nW3 )
		SetProperty( aForms[5], 'Width', nW3 )
		SetProperty( aForms[5], 'Height', nH4 )

		SetProperty( aForms[6], 'Row', nRow + nH4 )
		SetProperty( aForms[6], 'Col', nCol + nW3 )
		SetProperty( aForms[6], 'Width', nW3 )
		SetProperty( aForms[6], 'Height', nH4 )

		SetProperty( aForms[7], 'Row', nRow + 2*nH4 )
		SetProperty( aForms[7], 'Col', nCol + nW3 )
		SetProperty( aForms[7], 'Width', nW3 )
		SetProperty( aForms[7], 'Height', nH4 )

		SetProperty( aForms[8], 'Row', nRow + 3*nH4 )
		SetProperty( aForms[8], 'Col', nCol + nW3 )
		SetProperty( aForms[8], 'Width', nW3 )
		SetProperty( aForms[8], 'Height', nH4 )

		SetProperty( aForms[9], 'Row', nRow )
		SetProperty( aForms[9], 'Col', nCol + 2*nW3 )
		SetProperty( aForms[9], 'Width', nW3 )
		SetProperty( aForms[9], 'Height', nH4 )

		SetProperty( aForms[10], 'Row', nRow + nH4 )
		SetProperty( aForms[10], 'Col', nCol + 2*nW3 )
		SetProperty( aForms[10], 'Width', nW3 )
		SetProperty( aForms[10], 'Height', nH4 )

		SetProperty( aForms[11], 'Row', nRow + 2*nH4 )
		SetProperty( aForms[11], 'Col', nCol + 2*nW3 )
		SetProperty( aForms[11], 'Width', nW3 )
		SetProperty( aForms[11], 'Height', nH4 )

		SetProperty( aForms[12], 'Row', nRow + 3*nH4 )
		SetProperty( aForms[12], 'Col', nCol + 2*nW3 )
		SetProperty( aForms[12], 'Width', nW3 )
		SetProperty( aForms[12], 'Height', nH4 )
   ENDCASE

   DO EVENTS
   IF !Empty( nWndOpened )
	SwitchToThisWindow( GetFormHandle( Atail(aForms) ) )
   ENDIF

Return

*--------------------------------------------------------*
Static Procedure SetThisWindow( nActiveWnd )
*--------------------------------------------------------*
   Local cForm := "Form_" + Ltrim(Str(nActiveWnd))
   Local hWnd := GetFormHandle( cForm )

   IF _IsControlDefined( "Browse_1", cForm )
	IF !IsWindowVisible( hWnd )
		DoMethod( cForm, 'Show' )
	ENDIF
	IF IsIconic( hWnd )
		_Restore( hWnd )
	ENDIF
	SwitchToThisWindow( hWnd, .T. )
   ENDIF

Return

*--------------------------------------------------------*
Function MsgAbout()
*--------------------------------------------------------*
Return MsgInfo( PROGRAM + " version" + VERSION + " - FREEWARE" + CRLF + ;
	"Copyright " + Chr(169) + COPYRIGHT + CRLF + CRLF + ;
	padc("eMail: gfilatov@inbox.ru", 38) + CRLF + CRLF + ;
	padc("This program is Freeware!", 38) + CRLF + ;
	padc("Copying is allowed!", 40), "About " + PROGRAM )

#include "dbquery.prg"
