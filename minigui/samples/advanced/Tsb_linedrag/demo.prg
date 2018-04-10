/*
 * MINIGUI - Harbour Win32 GUI library Demo
 *
 * Author: Igor Nazarov
 *
 * Revised by Grigory Filatov <gfilatov@inbox.ru>
*/

#include "minigui.ch"
#include "TSBrowse.ch"

REQUEST DBFCDX

PROCEDURE Main

   LOCAL aStr := {}
   LOCAL cDbf := "TEST.DBF"
   LOCAL n := 0

   SET DATE FORMAT 'DD.MM.YYYY'
   rddSetDefault( 'DBFCDX' )

   IF ! File( cDbf )
      AAdd( aStr, { 'F1', 'D',  8, 0 } )
      AAdd( aStr, { 'F2', 'C', 60, 0 } )
      AAdd( aStr, { 'F3', 'N', 10, 2 } )
      AAdd( aStr, { 'F4', 'L',  1, 0 } )

      dbCreate( cDbf, aStr )

   ENDIF

   USE ( cDbf ) ALIAS "TEST" NEW

   WHILE TEST->( RecCount() ) < 100
      TEST->( dbAppend() )
      TEST->F1 := Date() + n++
      TEST->F2 := Str( n )
      TEST->F3 := n
      TEST->F4 := ( n % 2 ) == 0
   END

   DEFINE WINDOW Form_0 ;
      At 0, 0 ;
      WIDTH 600 ;
      HEIGHT 400 ;
      TITLE "TsBrowse Save/Restore Settings Demo" ;
      MAIN ;
      NOMAXIMIZE NOSIZE ;
      ON RELEASE dbCloseArea( "TEST" )

   DEFINE STATUSBAR
      STATUSITEM "Item 1" WIDTH 0
      STATUSITEM "TsBrowse Power Ready" WIDTH 230 FONTCOLOR BLUE
      DATE
      CLOCK
      KEYBOARD
   END STATUSBAR

   CreateBrowse()

   END WINDOW

   DoMethod( "Form_0", "Center" )
   DoMethod( "Form_0", "Activate" )

RETURN


FUNCTION CreateBrowse()

   LOCAL oBrw

   DEFINE TBROWSE oBrw ;
      AT 5, 5 ;
      ALIAS "TEST" ;
      OF Form_0 ;
      WIDTH Form_0.Width - 2 * GetBorderWidth() ;
      HEIGHT Form_0.Height - GetTitleHeight() - ;
         GetProperty( "Form_0", "StatusBar", "Height" ) - 2 * GetBorderHeight() ;
      GRID ;
      COLORS { CLR_BLACK, CLR_BLUE } ;
      FONT "MS Sans Serif" ;
      SIZE 8

      :SetAppendMode( .F. )
      :SetDeleteMode( .F. )

      :lNoHScroll  := .T.
      :lCellBrw    := .F.
      :lInsertMode := .T.

   END TBROWSE

   // Restoring settings from INI
   ReadSettings( oBrw )

   oBrw:nWheelLines  := 1
   oBrw:nClrLine     := COLOR_GRID
   oBrw:lNoChangeOrd := TRUE
   oBrw:lCellBrw     := TRUE
   oBrw:lNoVScroll   := TRUE
   oBrw:hBrush       := CreateSolidBrush( 242, 245, 204 )

   // prepare for showing of Double cursor
   AEval( oBrw:aColumns, {| oCol | oCol:lFixLite := oCol:lEdit := TRUE } )

   oBrw:nHeightCell += 10
   oBrw:nHeightHead += 5

   oBrw:SetColor( { 1 }, { RGB( 0, 12, 120 ) } )
   oBrw:SetColor( { 2 }, { RGB( 242, 245, 204 ) } )
   oBrw:SetColor( { 5 }, { RGB( 0, 0, 0 ) } )
   oBrw:SetColor( { 6 }, { { | a, b, oBr | IF( oBr:nCell == b, { RGB( 66, 255, 236 ), RGB( 111, 183, 155 ) }, ;
      { RGB( 255, 255, 255 ), RGB( 200, 200, 200 ) } ) } } )  // cursor backcolor

   oBrw:bLineDrag    := { | a, b, oBr | SaveSettings( a, b, oBr, "Width" ) }
   oBrw:bColDrag     := { | a, b, oBr | SaveSettings( a, b, oBr, "Position" ) }

RETURN NIL


STATIC FUNCTION SaveSettings( a, b, oBr, cKey )

   LOCAL hIni     := hb_Hash()
   LOCAL cIniFile := ChangeFileExt( Application.ExeName, '.ini' )
   LOCAL n

   HB_SYMBOL_UNUSED( a )
   HB_SYMBOL_UNUSED( b )

   FOR n := 1 TO oBr:nColCount()
      hIni[ oBr:GetColumn( n ):cName ] := hb_Hash()
      hIni[ oBr:GetColumn( n ):cName ][ "Position" ] := hb_ntos( n )
      hIni[ oBr:GetColumn( n ):cName ][ "Width" ]    := hb_ntos( oBr:GetColumn( n ):nWidth )
      hIni[ oBr:GetColumn( n ):cName ][ "Heading" ]  := oBr:GetColumn( n ):cHeading
   NEXT

   hb_iniWrite( cIniFile, hIni )

   MsgInfo( iif( Upper( cKey ) == "WIDTH", "Width changed and stored in INI", "Position changed and stored in INI" ) )

RETURN NIL


STATIC FUNCTION ReadSettings( oBrw )

   LOCAL hIni     := hb_Hash()
   LOCAL cIniFile := ChangeFileExt( Application.ExeName, '.ini' )
   LOCAL n
   LOCAL aArray := {}, aField := {}

   IF ! File( cIniFile )

      // initial column order
      aField := { "F2", "F1", "F3", "F4" }

      FOR n := 1 TO TEST->( FCount() )
         hIni[ aField[ n ] ] := hb_Hash()
         hIni[ aField[ n ] ][ "Position" ] := hb_ntos( n )
         hIni[ aField[ n ] ][ "Width" ]    := hb_ntos( 100 )
         hIni[ aField[ n ] ][ "Heading" ]  := aField[ n ]
      NEXT

      hb_iniWrite( cIniFile, hIni )

   ELSE

      hIni := hb_iniRead( cIniFile )
      FOR n := 1 TO TEST->( FCount() )
         AAdd( aArray, { TEST->( Field( n ) ), CTON( hIni[ TEST->( Field( n ) ) ][ "Position" ] ) } )
      NEXT
      // Sorting column
      ASort( aArray,,, { | a, b | a[ 2 ] < b[ 2 ] } )
      // Fill field array
      AEval( aArray, { | e | AAdd( aField, e[ 1 ] ) } )

   ENDIF

   LoadFields( "oBrw", "Form_0", .F., aField )

   // Set columns width
   oBrw:SetColSize( oBrw:nColumn( "F1" ), CTON( hIni[ "F1" ][ "Width" ] ) )
   oBrw:SetColSize( oBrw:nColumn( "F2" ), CTON( hIni[ "F2" ][ "Width" ] ) )
   oBrw:SetColSize( oBrw:nColumn( "F3" ), CTON( hIni[ "F3" ][ "Width" ] ) )
   oBrw:SetColSize( oBrw:nColumn( "F4" ), CTON( hIni[ "F4" ][ "Width" ] ) )

   // Set columns header
   oBrw:GetColumn( "F1" ):cHeading := hIni[ "F1" ][ "Heading" ] 
   oBrw:GetColumn( "F2" ):cHeading := hIni[ "F2" ][ "Heading" ] 
   oBrw:GetColumn( "F3" ):cHeading := hIni[ "F3" ][ "Heading" ] 
   oBrw:GetColumn( "F4" ):cHeading := hIni[ "F4" ][ "Heading" ] 

RETURN NIL
