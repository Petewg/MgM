#include <hmg.ch>

STATIC aCorners, nIncrement
STATIC nCursRow, nCursCol

DECLARE WINDOW frmMousDrag

PROCEDURE Main()

   aCorners := { { 20, 300 }, { 300, 20 }, { 300, 580 } }

   nIncrement := 10
   nCursRow   := GetCursorRow()
   nCursCol   := GetCursorCol()

   DefWindow()

   ON KEY ESCAPE OF frmMousDrag ACTION ThisWindow.Release

   frmMousDrag.Center
   frmMousDrag.Activate

RETURN  // Main()

*-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.

PROCEDURE DefWindow()                     // Define Window

   DEFINE WINDOW frmMousDrag ;
      AT 0, 0 ;
      WIDTH 620 HEIGHT 400 ;
      TITLE "Mouse Drag Demo" ;
      MAIN ;
      ON INIT DrawShape() ;
      ON MAXIMIZE DrawShape() ;
      ON SIZE DrawShape() ;
      ON MOUSEMOVE UpdaSBar() ;
      ON MOUSEDRAG ReFormShape()

      DEFINE STATUSBAR FONT 'Verdana' SIZE 8
         STATUSITEM "Drag corners for reformating of shape"
         STATUSITEM "" FONTCOLOR BLACK RIGHTALIGN
         STATUSITEM "" FONTCOLOR BLACK RIGHTALIGN
      END STATUSBAR

END WINDOW

RETURN // DefWindow()

*-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.

PROCEDURE UpdaSBar() 

   nCursRow := GetCursorRow() - frmMousDrag.Row - GetTitleHeight() - GetBorderHeight()
   nCursCol := GetCursorCol() - frmMousDrag.Col - GetBorderWidth()

   frmMousDrag.StatusBar.Item( 2 ) := hb_ntos( nCursRow )
   frmMousDrag.StatusBar.Item( 3 ) := hb_ntos( nCursCol )

RETURN // UpdaSBar() 

*-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.

PROCEDURE DrawShape()

   LOCAL nCorner,;
         a1Corner,;
         a2Corner,;
         nCorner1Y,;
         nCorner1X,;
         nCorner2Y,;
         nCorner2X

   ERASE WINDOW frmMousDrag

   FOR nCorner := 1 TO LEN( aCorners )

      a1Corner := aCorners[ nCorner ]
      a2Corner := aCorners[ iif( nCorner < 3, nCorner + 1, 1 ) ]
      nCorner1Y := a1Corner[ 1 ]
      nCorner1X := a1Corner[ 2 ]
      nCorner2Y := a2Corner[ 1 ]
      nCorner2X := a2Corner[ 2 ]

      DRAW LINE IN WINDOW frmMousDrag ;
            AT nCorner1Y, nCorner1X ;
            TO nCorner2Y, nCorner2X

      DRAW ELLIPSE IN WINDOW frmMousDrag ;
            AT nCorner1Y - 5, nCorner1X - 5 ;
            TO nCorner1Y + 5, nCorner1X + 5

   NEXT nCorner

RETURN // DrawShape()

*-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.

PROCEDURE ReFormShape()

   LOCAL nCursRowC := GetCursorRow() - frmMousDrag.Row - GetTitleHeight() - GetBorderHeight(), ;
         nCursColC := GetCursorCol() - frmMousDrag.Col - GetBorderWidth()

   LOCAL nCorner := ASCAN( aCorners, { | a1 | ABS( nCursRowC - a1[ 1 ] ) < nIncrement .AND. ;
         ABS( nCursColC - a1[ 2 ] ) < nIncrement } )

   IF nCorner > 0
      aCorners[ nCorner, 1 ] := nCursRowC
      aCorners[ nCorner, 2 ] := nCursColC
      DrawShape()
      UpdaSBar()
   ENDIF

RETURN // ReFormShape()

*-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.
