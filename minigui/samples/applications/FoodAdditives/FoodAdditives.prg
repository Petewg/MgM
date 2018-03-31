/*
 * MINIGUI - Harbour Win32 GUI library Demo
 *
 * Copyright 2002-05 Roberto Lopez <harbourminigui@gmail.com>
 * http://harbourminigui.googlepages.com/
 *
 * Copyright 2005 Grigory Filatov <gfilatov@inbox.ru>
 */

#include "minigui.ch"
#include "Dbstruct.ch"

#define PROGRAM 'Food Additives'
#define VERSION ' version 1.0'
#define COPYRIGHT ' 2005 Grigory Filatov'

#define IDI_MAIN 1001
// #define COMBOBOXEX

MEMVAR cFileName
MEMVAR cGroupName
MEMVAR nDirect, aItems, lSearch

*--------------------------------------------------------*
PROCEDURE Main()
*--------------------------------------------------------*

   LOCAL cExePath := GetExeFileName()

   PRIVATE cFileName := cFilePath( cExePath ) + "\" + Lower( cFileNoExt( cExePath ) ) + ".dbf"
   PRIVATE cGroupName := cFilePath( cExePath ) + "\Group.dbf"
   PRIVATE nDirect := 1, aItems := {}, lSearch := .F.

   IF !File( cFileName )
      MsgStop( "DataBase is missing...", "Stop!" )
      RETURN
   ENDIF

   SET MULTIPLE OFF

   DEFINE WINDOW Form_1 ;
      AT 0, 0           ;
      WIDTH 410 HEIGHT IF( IsThemed(), 466, 460 ) ;
      TITLE PROGRAM     ;
      ICON IDI_MAIN     ;
      MAIN NOMAXIMIZE NOMINIMIZE NOSIZE      ;
      ON INIT ( OpenTables(), DoMethod( 'Form_1', 'Combo_1', 'Setfocus' ) )  ;
      ON RELEASE CloseTables()       ;
      FONT "MS Sans Serif" SIZE 8

#ifdef COMBOBOXEX
   @ 34, 10 COMBOBOXEX Combo_1 ;
      WIDTH Form_1.Width -52 HEIGHT 260 ;
      LISTWIDTH Form_1.Width -26 ;
      DISPLAYEDIT ;
      ON DISPLAYCHANGE ( lSearch := .T. ) ;
      ON ENTER SearchItem( GetProperty( 'Form_1', 'Combo_1', 'DisplayValue' ) ) ;
      ON CHANGE ( lSearch := .F., SeekValues( aItems[ GetProperty( 'Form_1', 'Combo_1', 'Value' ) ][ 1 ] ) )

   @ 34, Form_1.Width -37 BUTTON Button_3 ;
      ICON 'MAIN' ;
      ACTION SearchItem( GetProperty( 'Form_1', 'Combo_1', 'DisplayValue' ) ) ;
      WIDTH 21 ;
      HEIGHT 21 ;
      TOOLTIP "Search for item"
#else
   @ 34, 10 COMBOBOX Combo_1 ;
      WIDTH Form_1.Width -26 HEIGHT 260 ;
      DISPLAYEDIT ;
      ON DISPLAYCHANGE ( lSearch := .T. ) ;
      ON ENTER SearchItem( GetProperty( 'Form_1', 'Combo_1', 'DisplayValue' ) ) ;
      ON CHANGE ( lSearch := .F., SeekValues( aItems[ GetProperty( 'Form_1', 'Combo_1', 'Value' ) ][ 1 ] ) )
#endif
   @ 6, 70 RADIOGROUP Radio_1 ;
      OPTIONS { 'Exxx number', 'Additive name' } ;
      VALUE nDirect ;
      WIDTH 88 ;
      SPACING 4 ;
      ON CHANGE ( lSearch := .F., ;
         nDirect := Form_1.Radio_1.Value, ;
         SetComboItems(), ;
         SeekValues( Form_1.Combo_1.DisplayValue ) ) ;
      HORIZONTAL

   @ 12, 10 LABEL Label_1 VALUE "Show by:" ;
      WIDTH 48 HEIGHT 14

   @ 60, 10 LABEL Label_2 VALUE "Name:" ;
      WIDTH 48 HEIGHT 14

   @ 80, 10 LABEL Label_3 VALUE "Number:" ;
      WIDTH 48 HEIGHT 14

   @ 100, 10 LABEL Label_4 VALUE "Group:" ;
      WIDTH 48 HEIGHT 14

   @ 118, 10 LABEL Label_5 VALUE "Animal origin:" ;
      WIDTH 76 HEIGHT 14

   @ 138, 10 LABEL Label_6 VALUE "Warning:" ;
      WIDTH 64 HEIGHT 14

   @ 168, 10 LABEL Label_7 VALUE "Description:" ;
      WIDTH 76 HEIGHT 14

   @ 60, 80 LABEL Label_21 VALUE "" ;
      WIDTH 312 HEIGHT 14

   @ 80, 80 LABEL Label_31 VALUE "" ;
      WIDTH 160 HEIGHT 14

   @ 100, 80 LABEL Label_41 VALUE "" ;
      WIDTH 160 HEIGHT 14

   @ 118, 80 LABEL Label_51 VALUE "" ;
      WIDTH 80 HEIGHT 14

   @ 138, 80 LABEL Label_61 VALUE "" ;
      WIDTH 320 HEIGHT 42

   @ 186, 10 EDITBOX Edit_1 WIDTH Form_1.Width - 26 HEIGHT 204 VALUE "" READONLY NOVSCROLL NOHSCROLL

   @ Form_1.Height - IF( IsThemed(), 62, 58 ), Form_1.Width - 180 BUTTON Button_1 ;
      CAPTION 'About' ;
      ACTION MsgAbout() ;
      WIDTH 74 ;
      HEIGHT 23 ;
      TOOLTIP "About this program"

   @ Form_1.Height - IF( IsThemed(), 62, 58 ), Form_1.Width - 90 BUTTON Button_2 ;
      CAPTION 'E&xit' ;
      ACTION ReleaseAllWindows() ;
      WIDTH 74 ;
      HEIGHT 23 ;
      TOOLTIP "Exit from program"

   ON KEY ESCAPE ACTION Form_1.Release

   END WINDOW

   CENTER WINDOW Form_1

   ACTIVATE WINDOW Form_1

RETURN

*--------------------------------------------------------*
STATIC PROCEDURE SearchItem( cSearch )
*--------------------------------------------------------*


   IF lSearch
      cSearch := Upper( cSearch )

      IF nDirect == 1
         IF Left( cSearch, 1 ) # 'E'
            cSearch := "E" + cSearch
         ENDIF
      ENDIF

      SET SOFTSEEK ON
      BASE->( dbSeek( cSearch ) )
      SET SOFTSEEK OFF

      IF !Eof()
         Form_1.Combo_1.Value := AScan( aItems, {| e| BASE->( RecNo() ) == e[ 2 ] } )
         SeekValues( aItems[ Form_1.Combo_1.Value ][ 1 ] )
      ELSE
         PlayBeep()
      ENDIF

      lSearch := .F.
      Form_1.Combo_1.Setfocus
   ENDIF

RETURN

*--------------------------------------------------------*
STATIC PROCEDURE RefreshValues()
*--------------------------------------------------------*


   Form_1.Label_21.Value := BASE->Name
   Form_1.Label_31.Value := BASE->Number
   Form_1.Label_41.Value := GRP->Name
   Form_1.Label_51.Value := IF( BASE->Animal, "Yes", "No" )
   Form_1.Label_61.Value := BASE->Warning
   Form_1.Edit_1.Value := BASE->Descript

RETURN

*--------------------------------------------------------*
STATIC PROCEDURE SeekValues( cItem )
*--------------------------------------------------------*

   LOCAL n

   IF nDirect == 1
      IF ( n := At( " - ", cItem ) ) > 0
         cItem := SubStr( cItem, 1, n )
      ENDIF
   ELSE
      IF ( n := At( " (", cItem ) ) > 0
         cItem := SubStr( cItem, 1, n )
      ENDIF
   ENDIF

   BASE->( dbSeek( Upper( cItem ) ) )
   RefreshValues()

RETURN

*--------------------------------------------------------*
STATIC PROCEDURE SetComboItems()
*--------------------------------------------------------*


   aItems := {}
   Form_1.Combo_1.DeleteAllItems

   SET ORDER TO nDirect

   IF nDirect == 1
      BASE->( dbEval( {|| AAdd( aItems, { RTrim( BASE->Number ) + " - " + RTrim( BASE->Name ), BASE->( RecNo() ) } ) }, {|| !Empty( BASE->Number ) } ) )
   ELSE
      BASE->( dbEval( {|| AAdd( aItems, { RTrim( BASE->Name ) + IF( Empty( BASE->Number ), "", " (" + RTrim( BASE->Number ) + ")" ), BASE->( RecNo() ) } ) }, {|| !Empty( BASE->Name ) } ) )
   ENDIF

   AEval( aItems, {| e| Form_1.Combo_1.AddItem( e[ 1 ] ) } )

   Form_1.Combo_1.Value := 1
   BASE->( dbGoTop() )

RETURN

*--------------------------------------------------------*
STATIC FUNCTION MsgAbout()
*--------------------------------------------------------*


RETURN MsgInfo( PadC( PROGRAM + VERSION, 38 ) + CRLF + ;
      PadC( "Copyright " + Chr( 169 ) + COPYRIGHT, 38 ) + CRLF + CRLF + ;
      hb_Compiler() + CRLF + ;
      Version() + CRLF + ;
      SubStr( MiniGuiVersion(), 1, 38 ) + CRLF + CRLF + ;
      PadC( "This program is Freeware!", 38 ) + CRLF + ;
      PadC( "Copying is allowed!", 40 ), "About", IDI_MAIN, .F. )

*--------------------------------------------------------*
PROCEDURE FileDelete( cMask )
*--------------------------------------------------------*

   AEval( Directory( cMask ), {|file| FErase( file[ 1 ] ) } )

RETURN

*--------------------------------------------------------*
PROCEDURE OpenTables()
*--------------------------------------------------------*


   IF !File( cGroupName )
      CreateTable()
   ENDIF

   USE ( cGroupName ) ALIAS GRP NEW
   INDEX ON Field->Code TO Group
   GO TOP

   USE ( cFileName ) ALIAS BASE NEW
   SET RELATION TO Field->Code Into GRP
   INDEX ON Upper( SubStr( Field->Name, 1, 40 ) ) TO Base2
   INDEX ON Upper( Field->Number ) TO Base1
   SET INDEX TO Base1, Base2

   SetComboItems()
   SeekValues( Form_1.Combo_1.DisplayValue )

RETURN

*--------------------------------------------------------*
PROCEDURE CloseTables()
*--------------------------------------------------------*


   BASE->( dbCloseArea() )
   GRP->( dbCloseArea() )
   FileDelete( "*.ntx" )

RETURN

*--------------------------------------------------------*
PROCEDURE CreateTable
*--------------------------------------------------------*

   LOCAL aDbf[ 2 ][ 4 ], i, aName := ;
      { "Colors", "Preservatives", "Acids, Antioxidants, Mineral salts", ;
      "Emulsifiers - Stabilisers", "Mineral salts - Anti-caking agents", ;
      "Flavour enhancers", "Miscellaneous" }

   aDbf[ 1 ][ DBS_NAME ] := "Code"
   aDbf[ 1 ][ DBS_TYPE ] := "Numeric"
   aDbf[ 1 ][ DBS_LEN ]  := 1
   aDbf[ 1 ][ DBS_DEC ]  := 0
   //
   aDbf[ 2 ][ DBS_NAME ] := "Name"
   aDbf[ 2 ][ DBS_TYPE ] := "Character"
   aDbf[ 2 ][ DBS_LEN ]  := 80
   aDbf[ 2 ][ DBS_DEC ]  := 0

   dbCreate( cGroupName, aDbf )

   USE ( cGroupName )

   FOR i := 1 TO Len( aName )
      APPEND BLANK
      REPLACE CODE WITH i
      REPLACE NAME WITH aName[ i ]
   NEXT i

   USE

RETURN
/*
*--------------------------------------------------------*
Procedure CreateBase
*--------------------------------------------------------*
LOCAL aDbf[6][4]

        aDbf[1][ DBS_NAME ] := "Name"
        aDbf[1][ DBS_TYPE ] := "Character"
        aDbf[1][ DBS_LEN ]  := 90
        aDbf[1][ DBS_DEC ]  := 0
        //
        aDbf[2][ DBS_NAME ] := "Number"
        aDbf[2][ DBS_TYPE ] := "Character"
        aDbf[2][ DBS_LEN ]  := 7
        aDbf[2][ DBS_DEC ]  := 0
        //
        aDbf[3][ DBS_NAME ] := "Code"
        aDbf[3][ DBS_TYPE ] := "Numeric"
        aDbf[3][ DBS_LEN ]  := 1
        aDbf[3][ DBS_DEC ]  := 0

        aDbf[4][ DBS_NAME ] := "Animal"
        aDbf[4][ DBS_TYPE ] := "Logical"
        aDbf[4][ DBS_LEN ]  := 1
        aDbf[4][ DBS_DEC ]  := 0
        //
        aDbf[5][ DBS_NAME ] := "Warning"
        aDbf[5][ DBS_TYPE ] := "Character"
        aDbf[5][ DBS_LEN ]  := 190
        aDbf[5][ DBS_DEC ]  := 0
        //
        aDbf[6][ DBS_NAME ] := "Descript"
        aDbf[6][ DBS_TYPE ] := "Memo"
        aDbf[6][ DBS_LEN ]  := 10
        aDbf[6][ DBS_DEC ]  := 0

        DBCREATE(cFileName, aDbf)

 Use

Return
*/
