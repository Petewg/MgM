/*
 * MINIGUI - Harbour Win32 GUI library Demo
*/

#include "minigui.ch"
#include "Dbstruct.ch"

Memvar aRows, a_hdr_image
Memvar nSortColBrowse, nSortColGrid, cSearchText, cPressedKeys
//------------------------------------------------------------------------------
Function Main
//------------------------------------------------------------------------------
   Private aRows [20] [3]
   Private nSortColBrowse := 1, nSortColGrid := 1, cSearchText := "", cPressedKeys := ""

   Declare a_hdr_image[2]
   a_hdr_image[1] = 'UP.BMP'
   a_hdr_image[2] = 'DN.BMP'

   REQUEST DBFCDX
   SET CENTURY ON
   SET DELETED ON
   //
   SET CODEPAGE TO RUSSIAN // Important for localize UPPER
   SET EVENTS FUNCTION TO MYEVENTS
   //

   DEFINE WINDOW Form_1;
      AT 0,0;
      WIDTH 640 HEIGHT 480;
      TITLE "MiniGUI Browse/Grid Incremental Search Demo";
      MAIN;
      NOMAXIMIZE NOSIZE;
      ON INIT OpenTables();
      ON RELEASE CloseTables()

      DEFINE MAIN MENU
         POPUP 'File'
            ITEM 'Exit'  ACTION Form_1.Release
         END POPUP
         POPUP 'Help'
            ITEM 'About' ACTION MsgInfo ("MiniGUI Browse/Grid Incremental Search Demo", "About")
         END POPUP
      END MENU

      DEFINE STATUSBAR
      STATUSITEM 'HMG Power Ready'
      END STATUSBAR


      @ 10,10 BROWSE Browse_1;
         WIDTH 610;
         HEIGHT 200;
         HEADERS { 'Code' , 'First Name' , 'Last Name', 'Birth Date', 'Married' , 'Biography' };
         WIDTHS { 100 , 150 , 150 , 150 , 150 };
         WORKAREA Test;
         FIELDS { 'Test->Code' , 'Test->First' , 'Test->Last' , 'Test->Birth' , 'Test->Married' };
         VALUE 1;
         JUSTIFY { BROWSE_JTFY_RIGHT, BROWSE_JTFY_CENTER, BROWSE_JTFY_CENTER,;
         BROWSE_JTFY_CENTER, BROWSE_JTFY_CENTER };
         HEADERIMAGE a_hdr_image;
         ON HEADCLICK { {|| BrowseHeadClick(1)}, {|| BrowseHeadClick(2)}, , , };
         ON GOTFOCUS {|| BrowseHeadClick( nSortColBrowse ) }

      aRows [1]  := {'Simpson','Homer','555-5555'}
      aRows [2]	 := {'Mulder','Fox','324-6432'}
      aRows [3]  := {'Smart','Max','432-5892'}
      aRows [4]	 := {'Grillo','Pepe','894-2332'}
      aRows [5]	 := {'Kirk','James','346-9873'}
      aRows [6]	 := {'Barriga','Carlos','394-9654'}
      aRows [7]  := {'Flanders','Ned','435-3211'}
      aRows [8]	 := {'Smith','John','123-1234'}
      aRows [9]  := {'Pedemonti','Flavio','000-0000'}
      aRows [10] := {'Gomez','Juan','583-4832'}
      aRows [11] := {'Fernandez','Raul','321-4332'}
      aRows [12] := {'Borges','Javier','326-9430'}
      aRows [13] := {'Alvarez','Alberto','543-7898'}
      aRows [14] := {'Gonzalez','Ambo','437-8473'}
      aRows [15] := {'Batistuta','Gol','485-2843'}
      aRows [16] := {'Vinazzi','Amigo','394-5983'}
      aRows [17] := {'Pedemonti','Flavio','534-7984'}
      aRows [18] := {'Samarbide','Armando','854-7873'}
      aRows [19] := {'Pradon','Alejandra','???-????'}
      aRows [20] := {'Reyes','Monica','432-5836'}

      @ 220,10 GRID Grid_1;
         WIDTH 610;
         HEIGHT 170;
         HEADERS {'Column 1','Column 2','Column 3'};
         WIDTHS {140,140,140};
         ITEMS aRows;
         HEADERIMAGE a_hdr_image;
         ON HEADCLICK { {|| GridHeadClick(1)}, {|| GridHeadClick(2)}, };
         ON GOTFOCUS {|| GridHeadClick( nSortColGrid ) }

   END WINDOW

   CENTER WINDOW Form_1
   ACTIVATE WINDOW Form_1

Return Nil

//------------------------------------------------------------------------------
Function BrowseHeadClick( nCol )
//------------------------------------------------------------------------------

   cSearchText := "Sort&Search by < " +;
      GetProperty( "Form_1", "Browse_1", "Header", nCol ) + " >: "
   nSortColBrowse := nCol
   cPressedKeys := ""

   if nCol = 1
      set order to tag "Code"
      Form_1.Browse_1.HeaderImage( 1 ) := 1
      Form_1.Browse_1.HeaderImage( 2 ) := 0

   elseif nCol = 2
      set order to tag "First"
      Form_1.Browse_1.HeaderImage( 1 ) := 0
      Form_1.Browse_1.HeaderImage( 2 ) := 1
   endif

   DoMethod( "Form_1", "Browse_1", "Refresh" )
   SetProperty( "Form_1", "StatusBar", "Caption", cSearchText )

Return Nil

//------------------------------------------------------------------------------
Function GridHeadClick( nCol )
//------------------------------------------------------------------------------
   Local i

   cSearchText := "Sort&Search by < " +;
      GetProperty( "Form_1", "Grid_1", "Header", nCol ) + " >: "
   nSortColGrid := nCol
   cPressedKeys := ""

   if nCol = 1
      aRows := asort( aRows,,, { |x, y| x[1] < y[1] } )
      for i = 1 to len( aRows )
         Form_1.Grid_1.Item( i ) := aRows[ i ]
      next
      Form_1.Grid_1.HeaderImage( 1 ) := 1
      Form_1.Grid_1.HeaderImage( 2 ) := 0

   elseif nCol = 2
      aRows := asort( aRows,,, { |x, y| x[2] < y[2] } )
      for i = 1 to len( aRows )
         Form_1.Grid_1.Item( i ) := aRows[ i ]
      next
      Form_1.Grid_1.HeaderImage( 1 ) := 0
      Form_1.Grid_1.HeaderImage( 2 ) := 1
   endif

   i := Form_1.Grid_1.Value
   Form_1.Grid_1.Value := if( i = 0, 1, i )
   Form_1.StatusBar.Item(1) := cSearchText

Return Nil

//------------------------------------------------------------------------------
Procedure OpenTables()
//------------------------------------------------------------------------------

   if !file("test.dbf")
      CreateTable()
   endif

   Use Test index Test Via "DBFCDX"
   set order to tag "Code"
   Go Top

   Form_1.Browse_1.Value := RecNo()
   BrowseHeadClick( 1 )

Return

//------------------------------------------------------------------------------
Procedure CloseTables()
//------------------------------------------------------------------------------
   Use
Return

//------------------------------------------------------------------------------
Procedure CreateTable
//------------------------------------------------------------------------------
   LOCAL aDbf[5][4], i
   FIELD Code, First

   aDbf[1][ DBS_NAME ] := "Code"
   aDbf[1][ DBS_TYPE ] := "Numeric"
   aDbf[1][ DBS_LEN ] := 10
   aDbf[1][ DBS_DEC ] := 0
   //
   aDbf[2][ DBS_NAME ] := "First"
   aDbf[2][ DBS_TYPE ] := "Character"
   aDbf[2][ DBS_LEN ] := 25
   aDbf[2][ DBS_DEC ] := 0
   //
   aDbf[3][ DBS_NAME ] := "Last"
   aDbf[3][ DBS_TYPE ] := "Character"
   aDbf[3][ DBS_LEN ] := 25
   aDbf[3][ DBS_DEC ] := 0
   //
   aDbf[4][ DBS_NAME ] := "Married"
   aDbf[4][ DBS_TYPE ] := "Logical"
   aDbf[4][ DBS_LEN ] := 1
   aDbf[4][ DBS_DEC ] := 0
   //
   aDbf[5][ DBS_NAME ] := "Birth"
   aDbf[5][ DBS_TYPE ] := "Date"
   aDbf[5][ DBS_LEN ] := 8
   aDbf[5][ DBS_DEC ] := 0
   //

   DBCREATE("Test", aDbf, "DBFCDX")

   Use test Via "DBFCDX"
   zap

   For i:= 1 To 100
      append blank
      Replace code with i
      Replace First With aRows[Random(20)][1]
      Replace Last With 'Last Name '+ Str(i)
      Replace Married With .t.
      replace birth with date()+i-10000
   Next i

   Index on str(Code,10) Tag "Code" To "Test"
   Index on upper(First) Tag "First" To "Test"

   Use

Return

//------------------------------------------------------------------------------
Function Form1Event1( i, nVirtKey, cKey )
//------------------------------------------------------------------------------
   LOCAL nLastRec := 1

   Do Case
   Case nVirtKey == 46 // DEL
      If MsgYesNo( _HMG_BRWLangMessage [1] , _HMG_BRWLangMessage [2] ) == .t.
         _BrowseDelete('','',i)
      EndIf

   Case nVirtKey == 36 // HOME
      _BrowseHome('','',i)
      cPressedKeys := ""
      Form_1.StatusBar.Item(1) := cSearchText
      Return 1

   Case nVirtKey == 35 // END
      _BrowseEnd('','',i)
      cPressedKeys := ""
      Form_1.StatusBar.Item(1) := cSearchText
      Return 1

   Case nVirtKey == 33 // PGUP
      _BrowsePrior('','',i)
      cPressedKeys := ""
      Form_1.StatusBar.Item(1) := cSearchText
      Return 1

   Case nVirtKey == 34 // PGDN
      _BrowseNext('','',i)
      cPressedKeys := ""
      Form_1.StatusBar.Item(1) := cSearchText
      Return 1

   Case nVirtKey == 38 // UP
      _BrowseUp('','',i)
      cPressedKeys := ""
      Form_1.StatusBar.Item(1) := cSearchText
      Return 1

   Case nVirtKey == 40 // DOWN
      _BrowseDown('','',i)
      cPressedKeys := ""
      Form_1.StatusBar.Item(1) := cSearchText
      Return 1

   Case len( cKey ) > 0 .or. nVirtKey = 8

      if nVirtKey = 8 // BackSpace
         cPressedKeys := left( cPressedKeys, len(cPressedKeys)-1 )
      elseif len( cKey ) > 0
         cPressedKeys := cPressedKeys + cKey
      endif
      Form_1.StatusBar.Item(1) := cSearchText + cPressedKeys

      nLastRec := recno()
      if nSortColBrowse = 1
         if ! dbseek( str(val(cPressedKeys), 10) )
            go nLastRec
         endif
      elseif nSortColBrowse = 2
         if ! dbseek( cPressedKeys )
            go nLastRec
         endif
      endif
      Form_1.Browse_1.Value := recno()
      Return 1

   EndCase

RETURN 0

//------------------------------------------------------------------------------
Function Form1Event2( i, nVirtKey, cKey )
//------------------------------------------------------------------------------
   LOCAL nLastRec := 1, nFindElem := 0

   Do Case
   Case nVirtKey == 36 // HOME
      _GridHome('','',i)
      cPressedKeys := ""
      Form_1.StatusBar.Item(1) := cSearchText
      Return 1

   Case nVirtKey == 35 // END
      _GridEnd('','',i)
      cPressedKeys := ""
      Form_1.StatusBar.Item(1) := cSearchText
      Return 1

   Case nVirtKey == 33 // PGUP
      _GridPgUp('','',i)
      cPressedKeys := ""
      Form_1.StatusBar.Item(1) := cSearchText
      Return 1

   Case nVirtKey == 34 // PGDN
      _GridPgDn('','',i)
      cPressedKeys := ""
      Form_1.StatusBar.Item(1) := cSearchText
      Return 1

   Case nVirtKey == 38 // UP
      _GridPrior('','',i)
      cPressedKeys := ""
      Form_1.StatusBar.Item(1) := cSearchText
      Return 1

   Case nVirtKey == 40 // DOWN
      _GridNext('','',i)
      cPressedKeys := ""
      Form_1.StatusBar.Item(1) := cSearchText
      Return 1

   Case len( cKey ) > 0 .or. nVirtKey = 8

      if nVirtKey = 8 // BackSpace
         cPressedKeys := left( cPressedKeys, len(cPressedKeys)-1 )
      elseif len( cKey ) > 0
         cPressedKeys := cPressedKeys + cKey
      endif
      Form_1.StatusBar.Item(1) := cSearchText + cPressedKeys

      nLastRec := Form_1.Grid_1.Value
      nFindElem := ascan( aRows, { | x | left( upper( x[nSortColGrid] ), len(cPressedKeys) ) == cPressedKeys } )
      if nFindElem > 0
         Form_1.Grid_1.Value := nFindElem
      else
         Form_1.Grid_1.Value := nLastRec
      endif
      Return 1 // Must be 1 to disable standard search procedure

   EndCase

RETURN 0

//------------------------------------------------------------------------------
#include "MyEvents.prg"
//------------------------------------------------------------------------------
