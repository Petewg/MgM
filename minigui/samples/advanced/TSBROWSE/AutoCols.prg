#include "MiniGui.ch"
#include "TSBrowse.ch"

REQUEST DBFCDX

//----------------------------------------------------------------------------//

FUNCTION AutoCols()

   Local oBrw, aArr, nEle, ;
         aLine := AFill( Array( 40 ), Space( 10 ) )

   aArr := {}

   For nEle := 1 To 40
      AAdd( aArr, AClone( aLine ) )
   Next

   DEFINE WINDOW Form_14 At 40,60 ;
         WIDTH 600 HEIGHT 600 ;
         TITLE "Array AutoColums" ;
         ICON "Demo.ico";
         CHILD

      @  30, 50 TBROWSE oBrw ARRAY aArr WIDTH 500 HEIGHT 500 CELLED AUTOCOLS SELECTOR .T. EDITABLE ;
            COLORS CLR_BLACK, CLR_WHITE, CLR_BLUE, { CLR_WHITE, GetSysColor( COLOR_GRADIENTINACTIVECAPTION ) }

      oBrw:nClrLine := GetSysColor( COLOR_GRADIENTINACTIVECAPTION )

   END WINDOW
   ACTIVATE WINDOW Form_14

Return Nil


Function TestLbx()

   Local oBrw, ;
         aItems := { Padr("One", 12), Padr("Two", 12), Padr("Three", 12) }

   DEFINE WINDOW Form_15 At 140,160 ;
         WIDTH 300 HEIGHT 250 ;
         TITLE "TSBrowse Like a ListBox" ;
         ICON "Demo.ico";
         CHILD

      @ 20, 50 TBROWSE oBrw ITEMS aItems  WIDTH 100 HEIGHT 100 COLOR CLR_BLACK, CLR_HGRAY EDITABLE

      oBrw:aEditCellAdjust[3] := -2  // correction of cell width
      oBrw:lNoVScroll := .T.

      oBrw:bKeyDown := { |nKey| If( nKey == VK_DELETE, oBrw:Del(), If( nKey == VK_INSERT, oBrw:Insert( Padr("New", 12) ), Nil )) }

   END WINDOW
   ACTIVATE WINDOW Form_15

Return Nil
