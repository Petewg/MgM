/*
 * MINIGUI - Harbour Win32 GUI library Demo
*/

#include "MiniGUI.ch"

FUNCTION Main

   DEFINE WINDOW Form_1 AT 50, 50 WIDTH 500 HEIGHT 370 ;
      TITLE "DROP HERE" ;
      MAIN ;
      ON DROPFILES {| aFiles | ResolveDrop( "Form_1", { "GRID_1", "LISTBOX_1" }, aFiles ) }

      ON KEY ESCAPE ACTION ThisWindow.Release

      @ 10, 10 GRID GRID_1 WIDTH 470 HEIGHT 150  ;
         HEADERS { "FilePath", "FileSize (bytes)" } ;
         WIDTHS  { 350, 116 } ;
         JUSTIFY { GRID_JTFY_LEFT, GRID_JTFY_RIGHT } ;
         ITEMS {}

      @ 170, 10 LISTBOX LISTBOX_1 WIDTH 470 HEIGHT 150 ITEMS {}

   END WINDOW

   ACTIVATE WINDOW Form_1

RETURN NIL


FUNCTION ResolveDrop( cForm, aCtrl, aFiles )

   LOCAL mx, my, ni, tx, ty, bx, by, ct
   LOCAL aRect := { 0, 0, 0, 0 } /* tx, ty, bx, by */
   LOCAL aCtlPos := {}
   LOCAL cTarget, cFilePath, cFileSize

   my := GetCursorRow()  /* Mouse y position on desktop */
   mx := GetCursorCol()  /* Mouse x position on desktop */

   FOR ni = 1 TO Len( aCtrl )
      GetWindowRect( GetControlHandle( aCtrl[ ni ], cForm ), aRect )
      AAdd( aCtlPos, { aCtrl[ ni ], aRect[ 1 ], aRect[ 2 ], aRect[ 3 ], aRect[ 4 ] } )
   NEXT ni

   cTarget := ""
   ni      := 0
   DO WHILE ni < Len( aCtlPos ) .AND. Len( cTarget ) == 0
      ni += 1
      tx := aCtlPos[ ni, 2 ] /* Top-Left Corner x */
      ty := aCtlPos[ ni, 3 ] /* Top-Left Corner y */
      bx := aCtlPos[ ni, 4 ] /* Right-Bottom Corner x */
      by := aCtlPos[ ni, 5 ] /* Right-Bottom Corner y */
      IF mx >= tx .AND. mx <= bx .AND. my >= ty .AND. my <= by
         cTarget := aCtlPos[ ni, 1 ]
      ENDIF
   ENDDO

   IF Len( cTarget ) > 0
      ct := GetControlType( cTarget, cForm )
      DO CASE
      CASE ct == "GRID" .OR. ct == "MULTIGRID"
         FOR ni = 1 TO Len( aFiles )
            cFilePath := aFiles[ ni ]
            cFileSize := TRANS( FileSize( cFilePath ), "999,999,999,999,999" )
            AddNewItem( cForm, cTarget, { cFilePath, cFileSize }, .F. )
         NEXT ni
      CASE ct == "LIST"
         FOR ni = 1 TO Len( aFiles )
            AddNewItem( cForm, cTarget, aFiles[ ni ], .T. )
         NEXT ni
      ENDCASE
   ENDIF

RETURN NIL


STATIC FUNCTION AddNewItem( cForm, cControl, xValue, lList )

   LOCAL lExist, nItemCount, ni

   lExist     := .F.
   nItemCount := GetProperty( cForm, cControl, "ItemCount" )
   ni         := 0

   DO WHILE ni < nItemCount .AND. lExist = .F.
      ni      += 1
      IF lList
         lExist := ( GetProperty( cForm, cControl, "Item", ni ) == xValue )
      ELSE
         lExist := ( GetProperty( cForm, cControl, "Cell", ni, 1 ) == xValue[ 1 ] )
      ENDIF
   ENDDO

   IF ! lExist
      DoMethod( cForm, cControl, "AddItem", xValue )
   ENDIF

RETURN NIL
