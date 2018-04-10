/*
 * MINIGUI - Harbour Win32 GUI library
 * Copyright 2002-2009 Roberto Lopez <harbourminigui@gmail.com>
 * http://harbourminigui.googlepages.com/
 *
 * Example to view DBF files using standard Browse control
 * Copyright 2009 MigSoft <mig2soft/at/yahoo.com>
 *
 * Enhanced by Grigory Filatov <gfilatov@inbox.ru>
 * Last Revised 11/10/2017
 */

#include "minigui.ch"

STATIC cExpress := ''

// ---------------------------------------------------------------------------- //

FUNCTION Main()

   LOCAL cBaseFolder, aTypes, aNewFiles, cAlias
   LOCAL nCamp, aEst, aNomb, aJust, aLong, aFtype, i

   // Set default language to English
   hb_langSelect( "EN" )

   // Set default language to Portuguese
   // SET LANGUAGE TO PORTUGUESE

   SET CENTURY ON
   SET EPOCH TO Year( Date() ) - 20
   SET DATE TO BRITISH

   cBaseFolder := GetStartupFolder()

   aTypes    := { { 'Database files (*.dbf)', '*.dbf' } }
   aNewFiles := GetFile( aTypes, 'Select database files', cBaseFolder, TRUE )

   IF !Empty( aNewFiles )

      USE ( aNewFiles[ 1 ] ) Shared New

      nCamp  := FCount()
      aEst   := dbStruct()
      cAlias := Alias()

      aNomb := { 'iif(deleted(),0,1)' } ; aJust := { 0 } ; aLong := { 0 } ; aFtype := {}

      FOR i := 1 TO nCamp
         AAdd( aNomb, aEst[ i, 1 ] )
         AAdd( aFtype, aEst[ i, 2 ] )
         AAdd( aJust, LtoN( aEst[ i, 2 ] == 'N' ) )
         AAdd( aLong, Max( 100, Min( 160, aEst[ i, 3 ] * 14 ) ) )
      NEXT

      CreaBrowse( cAlias, aNomb, aLong, aJust, aFtype )

   ENDIF

RETURN NIL

// ----------------------------------------------------------------------------//

FUNCTION CreaBrowse( cBase, aNomb, aLong, aJust, aFtype )

   LOCAL nAltoPantalla  := GetDesktopHeight() + GetTitleHeight() + GetBorderHeight()
   LOCAL nAnchoPantalla := GetDesktopWidth()
   LOCAL nRow           := nAltoPantalla  * 0.10
   LOCAL nCol           := nAnchoPantalla * 0.10
   LOCAL nWidth         := nAnchoPantalla * 0.95
   LOCAL nHeight        := nAltoPantalla  * 0.85
   LOCAL aHdr           := AClone( aNomb )
   LOCAL aCabImg        := AClone( VerHeadIcon( aFtype ) )
   LOCAL aSort          := AClone( aNomb )

   aHdr[ 1 ] := Nil
   aSort[ 1 ] := .F.

   SET DEFAULT ICON TO "MAIN"

   DEFINE WINDOW oWndBase AT nRow, nCol ;
      WIDTH nWidth HEIGHT nHeight ;
      TITLE "(c)2009 MigSoft - View DBF files" ;
      MAIN ;
      ON SIZE Adjust() ;
      ON MAXIMIZE Adjust()

   DEFINE TOOLBAR ToolBar_1 BUTTONSIZE 90, 32 FONT "Arial" SIZE 9 FLAT RIGHTTEXT
      BUTTON Cerrar    CAPTION _HMG_aABMLangButton[ 1 ]  PICTURE "MINIGUI_EDIT_CLOSE"  ACTION oWndBase.RELEASE               AUTOSIZE
      BUTTON Nuevo     CAPTION _HMG_aABMLangButton[ 2 ]  PICTURE "MINIGUI_EDIT_NEW"    ACTION Append()                       AUTOSIZE
      BUTTON Modificar CAPTION _HMG_aABMLangButton[ 3 ]  PICTURE "MINIGUI_EDIT_EDIT"   ACTION Edit()                         AUTOSIZE
      BUTTON Eliminar  CAPTION _HMG_aABMLangButton[ 4 ]  PICTURE "MINIGUI_EDIT_DELETE" ACTION DeleteOrRecall()               AUTOSIZE
      BUTTON Buscar    CAPTION _HMG_aABMLangButton[ 5 ]  PICTURE "MINIGUI_EDIT_FIND"   ACTION MyFind()                       AUTOSIZE
      BUTTON Imprimir  CAPTION _HMG_aABMLangButton[ 16 ] PICTURE "MINIGUI_EDIT_PRINT"  ACTION printlist( cBase, aNomb, aLong ) AUTOSIZE
   END TOOLBAR

   DEFINE BROWSE Browse_1
      ROW    45
      COL    20
      WIDTH  oWndBase.width  - 40
      HEIGHT oWndBase.height - 95
      VALUE 0
      WIDTHS aLong
      HEADERS aHdr
      HEADERIMAGE aCabImg
      WORKAREA &cBase
      FIELDS aNomb
      JUSTIFY aJust
      IMAGE { "br_no", "br_ok" }
      FONTNAME "Arial"
      FONTSIZE 9
      TOOLTIP ""
      ONCHANGE NIL
      LOCK .T.
      ALLOWEDIT .T.
      INPLACEEDIT .T.
      ALLOWDELETE .T.
      ALLOWAPPEND .T.
      COLUMNSORT aSort
   END BROWSE

   END WINDOW

   AEval( aHdr, {|x, i| oWndBase.Browse_1.HeaderImage( i ) := { i, ( aJust[ i ] == 1 ) } } )

   oWndBase.Browse_1.ColumnWidth( 1 ) := 21

   oWndBase.Center
   oWndBase.Activate

RETURN NIL

// ---------------------------------------------------------------------------- //

FUNCTION VerHeadIcon( aType )

   LOCAL aFtype, cType, n
   LOCAL aHeadIcon := { "hdel" }
   aFtype := AClone( aType )

   FOR n := 1 TO FCount()
      cType := aFtype[ n ]
      Switch cType
      CASE 'L'
         AAdd( aHeadIcon, "hlogic" )
         EXIT
      CASE 'D'
         AAdd( aHeadIcon, "hfech" )
         EXIT
      CASE 'N'
         AAdd( aHeadIcon, "hnum" )
         EXIT
      CASE 'C'
         AAdd( aHeadIcon, "hchar" )
         EXIT
      CASE 'M'
         AAdd( aHeadIcon, "hmemo" )
      END
   NEXT

Return( aHeadIcon )

// ---------------------------------------------------------------------------- //

PROCEDURE Adjust()
   oWndBase.Browse_1.Width  := oWndBase.Width  - 40
   oWndBase.Browse_1.Height := oWndBase.Height - 95

RETURN

// ---------------------------------------------------------------------------- //

PROCEDURE Append()

   LOCAL i := GetControlIndex ( "Browse_1", "oWndBase" )

   ( Alias() )->( dbAppend() )

   IF !NetErr()

      oWndBase.Browse_1.Value := ( Alias() )->( RecNo() )

      ProcessInPlaceKbdEdit( i )

   ENDIF

   oWndBase.Browse_1.SetFocus

RETURN

// ---------------------------------------------------------------------------- //

PROCEDURE Edit()

   LOCAL i := GetControlIndex ( "Browse_1", "oWndBase" )

   ( Alias() )->( dbGoto( oWndBase.Browse_1.Value ) )

   ProcessInPlaceKbdEdit( i )

   oWndBase.Browse_1.SetFocus

RETURN

// ---------------------------------------------------------------------------- //

PROCEDURE DeleteOrRecall()

   ( Alias() )->( dbGoto( oWndBase.Browse_1.Value ) )

   IF ( Alias() )->( RLock() )
      iif( ( Alias() )->( Deleted() ), ( Alias() )->( dbRecall() ), ( Alias() )->( dbDelete() ) )
   ENDIF
   ( Alias() )->( dbUnlock() )

   oWndBase.Browse_1.Refresh
   oWndBase.Browse_1.SetFocus

RETURN

// ---------------------------------------------------------------------------- //

PROCEDURE printlist( cBase, aNomb, aLong )

   LOCAL aHdr := AClone( aNomb )
   LOCAL aLen := AClone( aLong )
   LOCAL aHdr1
   LOCAL aTot
   LOCAL aFmt

   AEval( aLen, {| e, i| aLen[ i ] := e / 9 } )
   ADel( aLen, 1 )
   ASize( aLen, Len( aLen ) -1 )
   ADel( aHdr, 1 )
   ASize( aHdr, Len( aHdr ) -1 )
   ADel( aHdr, Len( aHdr ) )
   ASize( aHdr, Len( aHdr ) -1 )
   aHdr1 := Array( Len( aHdr ) )
   aTot := Array( Len( aHdr ) )
   aFmt := Array( Len( aHdr ) )
   AFill( aHdr1, '' )
   AFill( aTot, .F. )
   AFill( aFmt, '' )
// aFmt[9]  := '999'
// aFmt[10] := '@E 999,999'

   SET DELETED ON

   ( cBase )->( dbGoTop() )

   DO REPORT                          ;
      TITLE  cBase + ' Database List' ;
      HEADERS  aHdr1, aHdr            ;
      FIELDS   aHdr                   ;
      WIDTHS   aLen                   ;
      TOTALS   aTot                   ;
      NFORMATS aFmt                   ;
      WORKAREA &cBase                 ;
      LMARGIN  3                      ;
      TMARGIN  3                      ;
      PAPERSIZE DMPAPER_A4            ;
      PREVIEW

   SET DELETED OFF

RETURN

// ---------------------------------------------------------------------------- //

PROCEDURE MyFind()

   LOCAL cExpErr, nCurRec

   cExpress := InputBox( "Enter a Search Expression :", "Find", cExpress )

   IF ! Empty( cExpress )

      cExpErr := Exp1Check( cExpress )

      IF Empty( cExpErr ) .AND. .NOT. "U" $ Type( cExpress )

         ( Alias() )->( dbGoto( oWndBase.Browse_1.Value ) )
         nCurRec := ( Alias() )->( RecNo() )

         LOCATE FOR &cExpress REST

         IF ( Alias() )->( Eof() )
            ( Alias() )->( dbGoto( nCurRec ) )
         ENDIF

         oWndBase.Browse_1.Value := ( Alias() )->( RecNo() )
         oWndBase.Browse_1.Refresh

      ELSE

         MsgStop( "Invalid expression : " + cExpErr, "Warning" )

      ENDIF

   ENDIF

   oWndBase.Browse_1.SetFocus

RETURN

// ---------------------------------------------------------------------------- //

/*
   f.Exp1Check( <cSingleExpression> ) => <cResult>

   Copyright 2008-2010 © Bicahi Esgici <esgici@gmail.com>
*/
FUNCTION Exp1Check( ;                // Syntax Checking on a single expression
      c1Exprsn )

   LOCAL cRVal := '', ;
      c1Char, ;
      c1Atom  := '', ;
      nPnter  := 0, ;
      cBPrnts := "([{'" + '"', ;  // Parenthesis Begin
      cEPrnts := ")]}'" + '"', ;  // Parenthesis End
      cOprtrs := "+-/*,@$&!<>=#", ;
      cVoidEs := '"(' + "'", ;
      c1stChr := '', ;
      aLogics := { "AND", "OR", "NOT"  }, ;
      aBrackts := { 0, 0, 0, 0, 0 }, ;
      nBracket

   LOCAL cTermtors := cBPrnts + cEPrnts + cOprtrs + ". ", ;
      c1ExpSav := c1Exprsn

   c1Exprsn := StrTran( c1Exprsn, ' ', '' )  // Is this NoP ?

   WHILE nPnter < Len( c1Exprsn )

      c1Char := SUBS( c1Exprsn, ++nPnter, 1 )

      IF IsAlpha( c1Char ) .OR. ( !Empty( c1Atom ) .AND. c1Char == "_" )
         IF Empty( c1Atom ) .AND. nPnter > 1
            c1stChr := SUBS( c1Exprsn, nPnter - 1, 1 )
         ENDIF
         c1Atom += c1Char
      ELSE
         IF IsDigit( c1Char )
            c1Atom += IF( Empty( c1Atom ), '', c1Char )
         ELSE
            IF c1Char $ cTermtors
               IF c1Char == "." .AND. c1stChr == "."
                  IF ( AScan( aLogics, UPPE( SubStrng2( c1Exprsn, nPnter - 3, nPnter - 1 ) ) ) > 0 .OR. ;
                        AScan( aLogics, UPPE( SubStrng2( c1Exprsn, nPnter - 2, nPnter - 1 ) ) ) > 0 )
                     c1Atom := ''
                  ENDIF AScan( ...
               ENDIF c1Char == "."
               IF !Empty( c1Atom ) .AND. !c1Char $ cVoidEs
                  IF "U" $ Type( c1Atom  )
                     cRVal := c1Atom
                     EXIT
                  ENDIF
               ENDIF
               c1Atom  := ''
               c1stChr := ''
               IF c1Char $ cBPrnts .OR. c1Char $ cEPrnts
                  IF c1Char $ cBPrnts
                     nBracket := At( c1Char, cBPrnts )
                     IF nBracket > 3
                        IF aBrackts[ nBracket ] > 0
                           --aBrackts[ nBracket ]
                        ELSE
                           ++aBrackts[ nBracket ]
                        ENDIF
                     ELSE
                        ++aBrackts[ nBracket ]
                     ENDIF nBracket > 3
                  ELSE // c1Char $ cEPrnts
                     nBracket := At( c1Char, cEPrnts )
                     IF nBracket > 3
                        IF aBrackts[ nBracket ] > 0
                           --aBrackts[ nBracket ]
                        ELSE
                           ++aBrackts[ nBracket ]
                        ENDIF
                     ELSE
                        --aBrackts[ nBracket ]
                     ENDIF nBracket > 3
                  ENDIF c1Char $ cBPrnts
               ENDIF c1Char $ cBPrnts .OR. c1Char $ cEPrnts
            ENDIF c1Char $ cTermtors
         ENDIF IsDigit( c1Char )
      ENDIF IsAlpha( c1Char )
   ENDDO  nPnter < Len( c1Exprsn )

   IF AScan( aBrackts, {| n1 | n1 # 0 } ) > 0
      cRVal := c1ExpSav
   ENDIF

   IF !Empty( c1Atom ) .AND. Empty( cRVal )
      IF "U" $ Type( c1Atom )
         cRVal := c1Atom
      ENDIF
   ENDIF

RETURN cRVal // Exp1Check()

// ---------------------------------------------------------------------------- //

FUNCTION SubStrng2( ;             // Sub String defined two position
      cString, ;
      nBegPos, ;
      nEndPos )

   LOCAL cRVal

   cRVal := SubStr( cString,  nBegPos, nEndPos - nBegPos + 1 )

RETURN cRVal // SubStrng2()
