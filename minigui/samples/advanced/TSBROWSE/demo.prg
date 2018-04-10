/*
 * MINIGUI - Harbour Win32 GUI library Demo
 *
 * Copyright 2002 Roberto Lopez <harbourminigui@gmail.com>
 * http://harbourminigui.googlepages.com/
 *
 * Adaptation of TsBrowse for HMG 1.1 Experimental
 * (C)2005 Janusz Pora <januszpora@onet.eu>
*/

#include "minigui.ch"
#include "tsbrowse.ch"

MEMVAR cAlias1, cAlias2
MEMVAR oBrw1, oBrw2, oBrw3, oBrw4, oBrw5
MEMVAR aItems
MEMVAR bItems
MEMVAR cItems

FIELD FIRST, LAST, STATE, CODE

#define CLR_PINK   RGB( 255, 128, 128)
#define CLR_NBLUE  RGB( 128, 128, 192)
#define CLR_NBROWN  RGB( 130, 99, 53)

Set Procedure To TestXls.prg
Set Procedure To TestAdo.prg

Function Main
Local n

   Public cAlias1:="Test1", cAlias2:="Test2"
   Public oBrw1,oBrw2, oBrw3, oBrw4
   Public aItems := { "One", "Two", "Three" }
   Public bItems := {}
   Public cItems := {}

   for n:=1 to 130
        aadd(bItems, 'Item_'+alltrim(str(n,3)) )
        aadd(cItems, {'aItem_'+alltrim(str(n,3)) ,'bItem_'+alltrim(str(n,3)),'cItem_'+alltrim(str(n,3))})
   next

    SET CENTURY ON
    SET DELETED ON
    SET NAVIGATION EXTENDED
    SET AUTOADJUST ON

    DEFINE WINDOW Form_1 ;
        AT 0,0 ;
        WIDTH 900 HEIGHT 480 ;
        TITLE 'MiniGUI TsBrowse Demo - Adaptation TsBrowse 9.0' ;
        ICON "Demo.ico" ;
        MAIN NOMAXIMIZE ;
        ON INIT OpenTables() ;
        ON RELEASE CloseTables() ;
        FONT "Arial" SIZE 9 ;
        BACKCOLOR GRAY

        DEFINE MAIN MENU
            POPUP 'File'
                ITEM 'Browse - ListBox '    ACTION Brw_1()
                ITEM 'Browse - ListBox2'    ACTION Brw_2()
                ITEM 'Browse - Grid    '    ACTION Brw_3()
                ITEM 'Browse - DataBase'    ACTION Brw_4()
                ITEM 'Browse - DataBase2'   ACTION Brw_5()
                SEPARATOR
                ITEM 'Close Browse - ListBox '    ACTION ClrBrw_1()
                ITEM 'Close Browse - ListBox2'    ACTION clrBrw_2()
                ITEM 'Close Browse - Grid    '    ACTION ClrBrw_3()
                ITEM 'Close Browse - DataBase'    ACTION ClrBrw_4()
                ITEM 'Close Browse - DataBase2'   ACTION ClrBrw_5()
                SEPARATOR
                ITEM 'Exit'        ACTION Form_1.Release
             END POPUP
             POPUP "Samples on Windows"
                MENUITEM "Sample 1" ACTION fWindow( 1 )
                MENUITEM "Sample 2" ACTION fWindow( 2 )
                MENUITEM "Sample 3" ACTION fWindow( 3 )
                MENUITEM "Sample 4" ACTION fWindow( 4 )
                MENUITEM "Sample 5" ACTION fWindow( 5 )
                MENUITEM "Sample 6" ACTION fWindow( 6 )
                MENUITEM "Sample 7" ACTION fWindow( 7 )
                MENUITEM "Sample 8" ACTION fWindow( 8 )
            END POPUP
            POPUP "TSBrowse"
                ITEM 'SbAlign'            ACTION {|| SBAlign() }
                ITEM 'SbArray'            ACTION {|| SBArray() }
                MENUITEM "Super Columns"  ACTION fSuperCol()
                MENUITEM "BitMaps"        ACTION fSuperBit()
                MENUITEM "Report / Excel connectivity"  ACTION SBExcel()
                MENUITEM "Grid form"      ACTION TsGrid()
                MENUITEM "One To More"    ACTION OneToMore()
                MENUITEM "More To One"    ACTION OneToMore(.T.)
            END POPUP
            POPUP "TSBrowse 9.0"
                MENUITEM "Excel Test"    ACTION TestXLS()
                MENUITEM "Stop Browsing"    ACTION TestStop()
                MENUITEM "SBrowse"    ACTION SBrwTest()
                POPUP "Test ADO"
                   MENUITEM "All Fields" ACTION TestAdo(0)
                   MENUITEM "Selected Fields" ACTION TestAdo(1)
                   SEPARATOR
                   MENUITEM "All Fields - AUTOSEARCH " ACTION TestAdo(3)
                   MENUITEM "All Fields - AUTOFILTER " ACTION TestAdo(4)
                END POPUP
                MENUITEM "AutoCols"    ACTION AutoCols()
                MENUITEM "ListBox"    ACTION TestLbx()
                MENUITEM "Headers User Menu"  ACTION TestUserMenu()
             END POPUP
            POPUP 'Help'
                ITEM 'About'        ACTION MsgInfo ("MiniGUI TSBrowse Demo")
            END POPUP
        END MENU

        DEFINE STATUSBAR
            STATUSITEM '' DEFAULT
        END STATUSBAR

    END WINDOW

    ACTIVATE WINDOW Form_1

Return Nil

Procedure Brw_1()
   IF !_IsControlDefined ("oBrw1","Form_1")
      @ 10,10 TBROWSE oBrw1 ITEMS aItems OF Form_1 WIDTH 90 HEIGHT 60 FONT "MS Sans Serif" SIZE 10 BOLD;
      VALUE 1 AUTOCOLS;
      MESSAGE " Browse of type small ListBox "
   endif
Return

Procedure Brw_2()
   IF !_IsControlDefined ("oBrw2","Form_1")
      @ 80,10 TBROWSE oBrw2  ITEMS bItems OF Form_1 WIDTH 90 HEIGHT 310 FONT "Tahoma" SIZE 9 BOLD;
      MESSAGE " Browse of type Big ListBox "
   endif
Return

Procedure Brw_3()
   IF !_IsControlDefined ("oBrw3","Form_1")

      DEFINE TBROWSE oBrw3 AT 10,110 OF Form_1  ;
            WIDTH 250 HEIGHT 380  CELLED   FONT "Arial" SIZE 11 ITALIC ;
            COLORS {CLR_BLACK, CLR_NBLUE} ;
            MESSAGE " Browse Data Array "

      oBrw3:SetArray( cItems )

      oBrw3:SetColor( { 1, 3, 5, 6, 13, 15 }, ;
                          { CLR_BLACK, CLR_WHITE, CLR_BLACK, ;
                            { CLR_WHITE, CLR_BLACK }, ; // degraded cursor background color
                            CLR_WHITE, CLR_BLACK } )  // text colors

      oBrw3:SetColor( { 2, 4, 14 }, ;
                          { { CLR_WHITE, CLR_NBLUE }, ;  // degraded cells background color
                            { CLR_WHITE, CLR_BLACK }, ;  // degraded headers backgroud color
                            { CLR_HRED, CLR_BLACK } } )  // degraded order column background color

      oBrw3:nLineStyle := LINES_VERT

      ADD COLUMN TO TBROWSE oBrw3 DATA ARRAY ELEMENT 1;
         TITLE "Edit 1" SIZE 100 EDITABLE          // this column is editable
      ADD COLUMN TO TBROWSE oBrw3 DATA ARRAY ELEMENT 2;
         TITLE "Col 2" SIZE 70
      ADD COLUMN TO TBROWSE oBrw3 DATA ARRAY ELEMENT 3;
         TITLE "Col 3" SIZE 80

      END TBROWSE

   endif
Return

Procedure Brw_4()
   IF !_IsControlDefined ("oBrw4","Form_1")

      Select("Test")

      DEFINE TBROWSE oBrw4 AT 10,370 ALIAS "TEST";
         OF Form_1 WIDTH 250 HEIGHT 380;
         MESSAGE " Browse DataBase ";
         BACKCOLOR ORANGE ;
         TOOLTIP "TsBrowse - AutoLoadFields" ;
         AUTOCOLS

//        LoadFields("oBrw4","Form_1")
//        oBrw4:LoadFields(.f.)       //Alternative form
      oBrw4:aColumns[ 1 ]:cToolTip := "Column's ToolTip (Code)"
      oBrw4:aColumns[ 2 ]:cToolTip := "Column's ToolTip (First)"
      oBrw4:lNoResetPos := .F.

      ADD SUPER HEADER TO oBrw4 FROM COLUMN 1 TO COLUMN 2 ;
        TITLE "Col 1 and Col 2" 3DLOOK

      END TBROWSE

   endif
RETURN

Procedure Brw_5()
   IF !_IsControlDefined ("oBrw5","Form_1")
      Select("Test")

      @ 10,630 TBROWSE oBrw5 ;
         ALIAS "Test" ;
         OF Form_1 WIDTH 250 HEIGHT 380 ;
         CELLED ;
         HEADERS  "Code","First","Last","Birth","Bio" ;
         WIDTHS 50,150,150,100,200 ;
         FIELDS FieldWBlock( "Code", Select() ),Test->First,Test->Last,FieldWBlock( "Birth", Select() ),FieldWBlock( "Bio", Select() ) ;
         EDITABLE ;
         READONLY {.f.,.t.,.t.} ;
         BACKCOLOR YELLOW ;
         FONTCOLOR BLUE ;
         TOOLTIP "TsBrowse - Standard definition" ;
         MESSAGE " Browse DataBase 2 " ;
         AUTOSEARCH

      oBrw5:lNoResetPos := .F.
      oBrw5:lPickerMode := .F.
   endif
RETURN

Procedure ClrBrw_1()
    IF _IsControlDefined ("oBrw1","Form_1")
        _ReleaseControl ( "oBrw1","Form_1" )
    endif
Return

Procedure ClrBrw_2()
    IF _IsControlDefined ("oBrw2","Form_1")
        _ReleaseControl ( "oBrw2","Form_1" )
    endif
Return

Procedure ClrBrw_3()
    IF _IsControlDefined ("oBrw3","Form_1")
        _ReleaseControl ( "oBrw3","Form_1" )
    endif
    IF _IsControlDefined ("Get_1","Form_1")
        _ReleaseControl ( "Get_1","Form_1" )
    endif
Return

Procedure ClrBrw_4()
    IF _IsControlDefined ("oBrw4","Form_1")
        _ReleaseControl ( "oBrw4","Form_1" )
    endif
Return

Procedure ClrBrw_5()
    IF _IsControlDefined ("oBrw5","Form_1")
        _ReleaseControl ( "oBrw5","Form_1" )
    endif
Return

Function fWindow( nSample )
    TsBTest(nSample)
Return Nil

Procedure OpenTables()

   RddSetDefault( "DBFNTX" )    // Clipper-Harbour

   USE States ALIAS Sta SHARED NEW
   Index On State To States       // NTX

   USE SBALIGN ALIAS TEST2 SHARED NEW


   USE Employee SHARED NEW
   Index On First+Last To Name    // NTX
   Index On State To State        // NTX
   Set Index To Name, State       // NTX

   Use Test SHARED NEW
   Index On Code To Code

   Use Products Shared New
   Index On Code To Products

Return

Procedure CloseTables()
    DbCloseAll()
Return

//Demo files
#include "sbalign.prg"
#include "sbarray.prg"
#include "tsbtest.prg"
#include "sbsuperh.prg"
#include "sbexcel.prg"
#include "TestStop.prg"
#include "Sbrowse.prg"
#include "OneToMore.prg"
#include "AutoCols.prg"
