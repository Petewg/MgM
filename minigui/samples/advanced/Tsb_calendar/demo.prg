/*
 * MINIGUI - Harbour Win32 GUI library Demo
 *
 * Author: Igor Nazarov
 *
 * Revised by Grigory Filatov <gfilatov@inbox.ru>
*/

#include "minigui.ch"
#include "tsbrowse.ch"

MEMVAR oBrw

//-----------------------------------------------------------------//
FUNCTION Main( nBoW )
//-----------------------------------------------------------------//
   LOCAL i
   LOCAL aDay

   DEFAULT nBoW := 1

   SET DATE TO GERMAN
   FT_DATECNFG( , nBoW )

   IF nBoW == 2
      aDay := { "M", "T", "W", "Th", "F", "S", "Sn" }
   ELSE
      aDay := { "Sn", "M", "T", "W", "Th", "F", "S" }
   ENDIF

   DEFINE WINDOW Win_1 ;
      At 0, 0 ;
      WIDTH 200 ;
      HEIGHT 208 + GetTitleHeight() ;
      TITLE 'TsBrowse Calendar' ;
      ICON 'calendar.ico' ;
      MAIN ;
      NOMAXIMIZE ;
      NOMINIMIZE ;
      NOSIZE

   END WINDOW

   DEFINE COMBOBOX Combo_Month
     PARENT Win_1
     ROW    0
     COL    2
     WIDTH  95
     HEIGHT 204
     ITEMS  aMonths()
     VALUE  Month( Date() )
     ONCHANGE LoadToCalendar( CToD( '01.' + PadL( GetProperty( "Win_1", "Combo_Month", "Value" ), 2, "0" ) + "." + NTOC( GetProperty( "Win_1", "Spinner_Year", "Value" ) ) ) )
     FONTNAME 'Arial'
     FONTSIZE 10
     TABSTOP  .F.
   END COMBOBOX

   DEFINE SPINNER Spinner_Year
     PARENT Win_1
     ROW    0
     COL    97
     WIDTH  95
     HEIGHT 24
     RANGEMIN 2000
     RANGEMAX 2100
     VALUE    Year( Date() )
     FONTNAME 'Arial'
     FONTSIZE 10
     ONCHANGE LoadToCalendar( CToD( '01.' + PadL( GetProperty( "Win_1", "Combo_Month", "Value" ), 2, "0" ) + "." + NTOC( GetProperty( "Win_1", "Spinner_Year", "Value" ) ) ) )
     WRAP .T.
   END SPINNER


   DEFINE TBrowse oBrw ;
      AT     GetProperty( "Win_1", 'Row' ) + GetTitleHeight() + iif( _HMG_IsXP, -2, 2 ), GetProperty( "Win_1", 'Col' ) + 2 ;
      OF     Win_1 ;
      WIDTH  GetProperty( "Win_1", 'Width' ) - 10  ;
      HEIGHT GetProperty( "Win_1", 'Height' ) - 32 - GetTitleHeight() ;
      FONT   "Arial" ;
      SIZE   9 ;
      GRID

   END TBROWSE

   // Assign empty array to TBrowse object
   oBrw:SetArray( Array( 6, 7 ), TRUE )

   // Add user data to TBrowse object
   __objAddData( oBrw, 'aMark' )
   __objAddData( oBrw, 'aDate' )
   __objAddData( oBrw, 'dDate' )

   oBrw:aMark := Array( 6, 7 )
   oBrw:aDate := Array( 6, 7 )
   oBrw:dDate := Date()

   // Modify TBrowse settings
   oBrw:nHeightCell  := ( oBrw:nHeight / 7 )
   oBrw:nHeightHead  := ( oBrw:nHeight / 7 )
   oBrw:lNoHScroll   := .T.
   oBrw:nFreeze      := 7
   oBrw:lNoMoveCols  := TRUE
   oBrw:lLockFreeze  := FALSE
   oBrw:lNoChangeOrd := TRUE
   oBrw:nFireKey     := VK_SPACE

   // Define TBrowse colors
   oBrw:SetColor( { 3 }, { {|| RGB( 255, 242, 0 )  } },   )
   oBrw:SetColor( { 4 }, { {|| { RGB( 43, 189, 198 ), RGB( 3, 113, 160 ) } } },   )

   oBrw:SetColor( { 6 },  { -RGB( 220, 0, 0 ) },   )

   oBrw:SetColor( { 2 }, { {|| IF( IsMark( 1 ), RGB( 100, 255, 100 ), RGB( 240, 255, 240 ) ) } }, 1 )
   oBrw:SetColor( { 2 }, { {|| IF( IsMark( 2 ), RGB( 100, 255, 100 ), RGB( 240, 255, 240 ) ) } }, 2 )
   oBrw:SetColor( { 2 }, { {|| IF( IsMark( 3 ), RGB( 100, 255, 100 ), RGB( 240, 255, 240 ) ) } }, 3 )
   oBrw:SetColor( { 2 }, { {|| IF( IsMark( 4 ), RGB( 100, 255, 100 ), RGB( 240, 255, 240 ) ) } }, 4 )
   oBrw:SetColor( { 2 }, { {|| IF( IsMark( 5 ), RGB( 100, 255, 100 ), RGB( 240, 255, 240 ) ) } }, 5 )
   oBrw:SetColor( { 2 }, { {|| IF( IsMark( 6 ), RGB( 100, 255, 100 ), RGB( 240, 255, 240 ) ) } }, 6 )
   oBrw:SetColor( { 2 }, { {|| IF( IsMark( 7 ), RGB( 100, 255, 100 ), RGB( 240, 255, 240 ) ) } }, 7 )

   oBrw:SetColor( { 1 }, { {|| IF( Month( oBrw:aDate[ oBrw:nAt ][ 1 ] ) == Month( oBrw:dDate ), RGB( 0, 0, 0 ), RGB( 200, 200, 200 ) ) } }, 1 )
   oBrw:SetColor( { 1 }, { {|| IF( Month( oBrw:aDate[ oBrw:nAt ][ 2 ] ) == Month( oBrw:dDate ), RGB( 0, 0, 0 ), RGB( 200, 200, 200 ) ) } }, 2 )
   oBrw:SetColor( { 1 }, { {|| IF( Month( oBrw:aDate[ oBrw:nAt ][ 3 ] ) == Month( oBrw:dDate ), RGB( 0, 0, 0 ), RGB( 200, 200, 200 ) ) } }, 3 )
   oBrw:SetColor( { 1 }, { {|| IF( Month( oBrw:aDate[ oBrw:nAt ][ 4 ] ) == Month( oBrw:dDate ), RGB( 0, 0, 0 ), RGB( 200, 200, 200 ) ) } }, 4 )
   oBrw:SetColor( { 1 }, { {|| IF( Month( oBrw:aDate[ oBrw:nAt ][ 5 ] ) == Month( oBrw:dDate ), RGB( 0, 0, 0 ), RGB( 200, 200, 200 ) ) } }, 5 )
   oBrw:SetColor( { 1 }, { {|| IF( Month( oBrw:aDate[ oBrw:nAt ][ 6 ] ) == Month( oBrw:dDate ), RGB( 0, 0, 0 ), RGB( 200, 200, 200 ) ) } }, 6 )
   oBrw:SetColor( { 1 }, { {|| IF( Month( oBrw:aDate[ oBrw:nAt ][ 7 ] ) == Month( oBrw:dDate ), RGB( 0, 0, 0 ), RGB( 200, 200, 200 ) ) } }, 7 )

   oBrw:SetColor( { 5 }, { {|| IF( Month( oBrw:aDate[ oBrw:nAt ][ 1 ] ) == Month( oBrw:dDate ), RGB( 0, 0, 0 ), RGB( 200, 200, 200 ) ) } }, 1 )
   oBrw:SetColor( { 5 }, { {|| IF( Month( oBrw:aDate[ oBrw:nAt ][ 2 ] ) == Month( oBrw:dDate ), RGB( 0, 0, 0 ), RGB( 200, 200, 200 ) ) } }, 2 )
   oBrw:SetColor( { 5 }, { {|| IF( Month( oBrw:aDate[ oBrw:nAt ][ 3 ] ) == Month( oBrw:dDate ), RGB( 0, 0, 0 ), RGB( 200, 200, 200 ) ) } }, 3 )
   oBrw:SetColor( { 5 }, { {|| IF( Month( oBrw:aDate[ oBrw:nAt ][ 4 ] ) == Month( oBrw:dDate ), RGB( 0, 0, 0 ), RGB( 200, 200, 200 ) ) } }, 4 )
   oBrw:SetColor( { 5 }, { {|| IF( Month( oBrw:aDate[ oBrw:nAt ][ 5 ] ) == Month( oBrw:dDate ), RGB( 0, 0, 0 ), RGB( 200, 200, 200 ) ) } }, 5 )
   oBrw:SetColor( { 5 }, { {|| IF( Month( oBrw:aDate[ oBrw:nAt ][ 6 ] ) == Month( oBrw:dDate ), RGB( 0, 0, 0 ), RGB( 200, 200, 200 ) ) } }, 6 )
   oBrw:SetColor( { 5 }, { {|| IF( Month( oBrw:aDate[ oBrw:nAt ][ 7 ] ) == Month( oBrw:dDate ), RGB( 0, 0, 0 ), RGB( 200, 200, 200 ) ) } }, 7 )

   // Define TBrowse columns header and data
   FOR i := 1 TO 7
      oBrw:aColumns[ i ]:cHeading := aDay[ i ]

      oBrw:SetColSize( i, ( oBrw:nWidth / 7 ) )
      oBrw:aColumns[ i ]:bData := hb_macroBlock( "GetDate(" + NTOC( i ) + ")" )
      oBrw:aColumns[ i ]:nAlign := DT_CENTER
      oBrw:aColumns[ i ]:lEdit := TRUE
      oBrw:aColumns[ i ]:bPrevEdit := {|| Mark(), .F. }
   NEXT

   LoadToCalendar( Date() )

   CENTER WINDOW Win_1
   ACTIVATE WINDOW Win_1

RETURN Nil


//-----------------------------------------------------------------//
FUNCTION GetDate( nCol )
//-----------------------------------------------------------------//
RETURN Day( oBrw:aDate[ oBrw:nAt ][ nCol ] )


//-----------------------------------------------------------------//
FUNCTION Mark()
//-----------------------------------------------------------------//
   IF Month( oBrw:aDate[ oBrw:nAt ][ oBrw:nCell ] ) == Month( oBrw:dDate )
      oBrw:aMark[ oBrw:nAt ][ oBrw:nCell ] := .NOT. oBrw:aMark[ oBrw:nAt ][ oBrw:nCell ]
      oBrw:DrawSelect()
   ENDIF

RETURN NIL


//-----------------------------------------------------------------//
FUNCTION IsMark( n )
//-----------------------------------------------------------------//
RETURN oBrw:aMark[ oBrw:nAt ][ n ]


//-----------------------------------------------------------------//
FUNCTION LoadToCalendar( dDate )
//-----------------------------------------------------------------//
   LOCAL dFirst := FT_ACCTWEEK( BOM( dDate ) )[ 2 ]
   LOCAL i
   LOCAL j
   LOCAl n
   STATIC aPos := { , }

   IF __mvExist( "oBrw" )
      n := 0
      FOR i := 1 TO 6
         FOR j := 1 TO 7
            oBrw:aDate[ i ][ j ] := dFirst + n
            IF dDate == Date() .AND. Day( oBrw:aDate[ i ][ j ] ) == Day( dDate ) .AND. Month( oBrw:aDate[ i ][ j ] ) == Month( dDate )
               oBrw:aMark[ i ][ j ] := TRUE  // mark Today cell
               aPos[ 1 ] := i
               aPos[ 2 ] := j
            ELSE
               oBrw:aMark[ i ][ j ] := FALSE
            ENDIF
            n++
         NEXT
      NEXT

      oBrw:dDate := dDate

      oBrw:lInitGoTop := .F.
      oBrw:GoPos( aPos[ 1 ], aPos[ 2 ] )  // select Today cell

      oBrw:Refresh( TRUE )
      oBrw:SetFocus()
   ENDIF

RETURN NIL
