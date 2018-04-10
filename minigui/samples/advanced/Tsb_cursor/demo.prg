/*
 * MINIGUI - Harbour Win32 GUI library Demo
 *
 * Author: Igor Nazarov
 *
 * Revised by Grigory Filatov <gfilatov@inbox.ru>
*/

#include "minigui.ch"
#include "TSBrowse.ch"

MEMVAR aFont

PROCEDURE Main

   PUBLIC aFont := {}, aBmp[ 1 ]

   SET DATE  FORMAT 'DD.MM.YYYY'

   DEFINE FONT Font_1  FONTNAME "Times New Roman" SIZE 11
   DEFINE FONT Font_2  FONTNAME iif( _HMG_IsXP, "Comic Sans MS", "MV Boli" ) SIZE 14 BOLD

   AAdd( aFont, GetFontHandle( "Font_1" ) )
   AAdd( aFont, GetFontHandle( "Font_2" ) )

   DEFINE WINDOW Form_0 ;
      TITLE "TsBrowse Double Cursor Demo" ;
      MAIN ;
      NOMAXIMIZE NOSIZE ;
      ON RELEASE DeleteObject( aBmp[ 1 ] )

      DEFINE STATUSBAR
         STATUSITEM "Item 1" WIDTH 0    FONTCOLOR BLACK
         STATUSITEM "Item 2" WIDTH 230  FONTCOLOR BLACK
         STATUSITEM "Item 3" WIDTH 230  FONTCOLOR BLACK
         STATUSITEM "Item 4" WIDTH 230  FONTCOLOR BLACK
         DATE
         CLOCK
         KEYBOARD
      END STATUSBAR

      CreateBrowse()

   END WINDOW

   DoMethod( "Form_0", "Activate" )

RETURN


FUNCTION CreateBrowse()

   LOCAL oBrw
   LOCAL i
   LOCAL aDatos := {}

   FOR i := 1 TO 1000
      AAdd( aDatos, { i, RandStr( 30 ), Date() - i, if( i % 2 == 0, TRUE, FALSE ) } )
   NEXT

   aBmp[ 1 ] := LoadImage( "Calendar.BMP" )

   DEFINE TBROWSE oBrw AT 17, 0 ;
      OF Form_0 ;
      WIDTH Form_0.WIDTH - 2 * GetBorderWidth() ;
      HEIGHT Form_0.HEIGHT - GetTitleHeight() - GetTitleHeight() - ;
         GetProperty( "Form_0", "StatusBar", "Height" ) - 2 * GetBorderHeight() ;
      GRID ;
      SELECTOR TRUE;
      FONT "Arial" SIZE 12

   oBrw:SetArray( aDatos, .T. )
   oBrw:nWheelLines   := 1
   oBrw:nClrLine      := COLOR_GRID
   oBrw:lNoChangeOrd  := TRUE
   oBrw:lCellBrw      := TRUE
   oBrw:lNoVScroll    := TRUE
   oBrw:hBrush := CreateSolidBrush( 242, 245, 204 )

   // prepare for showing of Double cursor
   AEval( oBrw:aColumns, {| oCol| oCol:lFixLite := oCol:lEdit := TRUE } )

   // assignment of column's names
   oBrw:aColumns[ 1 ]:cName := "NUMBER"
   oBrw:aColumns[ 2 ]:cName := "TEXT"
   oBrw:aColumns[ 3 ]:cName := "DATE"
   oBrw:aColumns[ 4 ]:cName := "LOGIC"

   // the reference to columns by names
   oBrw:SetColSize( "NUMBER", 100 )
   oBrw:SetColSize( "TEXT", 500 )
   oBrw:SetColSize( "DATE", 200 )

   // Checking the method nColumn()
   oBrw:SetColSize( oBrw:nColumn( "LOGIC" ), 300 )

   // image with white backcolor looks similar to transparent
   oBrw:GetColumn( 'DATE' ):uBmpCell := {|| If( oBrw:lDrawSelect, aBmp[ 1 ], NIL ) }

   oBrw:GetColumn( 'NUMBER' ):nAlign := DT_CENTER
   oBrw:GetColumn( 'TEXT'   ):nAlign := DT_LEFT
   oBrw:GetColumn( 'DATE'   ):nAlign := DT_CENTER
   oBrw:GetColumn( 'LOGIC'  ):nAlign := DT_CENTER

   oBrw:nAdjColumn := 3

   oBrw:nHeightCell += 10
   oBrw:nHeightHead += 5

   oBrw:SetColor( { 1 }, { RGB( 0, 12, 120 ) } )
   oBrw:SetColor( { 2 }, { RGB( 242, 245, 204 ) } )
   oBrw:SetColor( { 5 }, { RGB( 0, 0, 0 ) } )
   oBrw:SetColor( { 6 }, { {|a, b, c| IF( c:nCell == b, { RGB( 66, 255, 236 ), RGB( 111, 183, 155 ) }, ;
      { RGB( 255, 255, 255 ), RGB( 200, 200, 200 ) } )  }   } )  // cursor backcolor

   oBrw:ChangeFont( {|| IF( oBrw:lDrawSelect, aFont[ 2 ], aFont[ 1 ] ) },,  )

   END TBROWSE

RETURN NIL


FUNCTION RandStr( nLen )

   LOCAL cSet  := "qwertyuiopasdfghjklzxcvbnmQWERTYUIOPASDFGHJKLZXCVBNM"
   LOCAL cPass := ""
   LOCAL i := 0

   FOR i := 1 TO nLen
      cPass += SubStr( cSet, Random( 52 ), 1 )
   NEXT

RETURN cPass
