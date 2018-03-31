/*
 * MINIGUI - Harbour Win32 GUI library Demo
 *
 */

#include "minigui.ch"
#include "hbclass.ch"

////////////////////////////////////////////////////////////////////////////////
FUNCTION Main()

   LOCAL cTxt, aTxt, oLbl
   LOCAL h := 0, w := 0, s := 10
   LOCAL BColor := { 220, 220, 220 }
   LOCAL a, c, y, x
   LOCAL cFile := "test.txt"

   SET FONT TO "Arial", 12

   IF ! File( cFile )
      Create_txt( cFile )
   ENDIF

   cTxt := hb_MemoRead( cFile )
   c    := iif( CRLF $ cTxt, CRLF, Chr( 10 ) )
   aTxt := hb_ATokens( cTxt, c )

   DEFINE WINDOW _T ;
      AT 0, 0 WIDTH 100 HEIGHT 100 ;
      TITLE 'Colored Label Demo' ;
      MAIN ;
      BACKCOLOR BColor

   oLbl := cLbl():New( BColor )

   oLbl:Add( 'Harbour', BLUE )
   oLbl:Add( 'Project', GREEN, .T., .F., .T. )
   oLbl:Add( 'Free', BLUE )
   oLbl:Add( 'Software', GREEN, .T., .T., .T., 'Tooltip' )
   oLbl:Add( 'General', BLUE )
   oLbl:Add( 'Public', YELLOW, .T., .F., .T., 'Click me', .T., ;
      {|o| MsgInfo( 'Value: ' + _GetValue( _HMG_ThisControlName, _HMG_ThisFormName ), 'Class: ' + o:ClassName ) } )
   oLbl:Add( 'License', BLUE )
   oLbl:Add( 'exception', RED  )

   y := x := s

   FOR EACH cTxt IN aTxt
      IF ! Empty( cTxt )
         oLbl:Def( cTxt )
         a := oLbl:Out( y, x )
         y += a[ 1 ] + s
         h += a[ 1 ] + s
         w := Max( w, a[ 2 ] )
      ENDIF
   NEXT

   h += s * 2
   w += s * 2

   This.Width  := w + GetBorderWidth () * 2
   This.Height := h + GetBorderHeight() * 2 + GetTitleHeight()

   END WINDOW

   CENTER   WINDOW _T
   ACTIVATE WINDOW _T

RETURN NIL

////////////////////////////////////////////////////////////////////////////////

CLASS cLbl
   VAR cForm
   VAR cFont
   VAR nSize
   VAR aSub
   VAR aTxt
   VAR cTxt
   VAR BColor
   VAR FColor
   VAR lBold    INIT .F.
   VAR lItalic  INIT .F.
   VAR lUnderl  INIT .F.
   VAR nLbl     INIT  0
   VAR cLbl     INIT '_Out_'
   VAR cSpace   INIT ' '

   METHOD New( BColor, cFont, nSize )
   METHOD Out( nRow, nCol )
   METHOD Def( cTxt, cChr )
   METHOD Add( cSub, FColor, lBold, lItalic, lUnderl, cTool, lHand, bAct ) INLINE ;
      ( hb_HSet( ::aSub, Lower( cSub ), { FColor, lBold, lItalic, lUnderl, cTool, lHand, bAct } ) )
   METHOD Block()

ENDCLASS


METHOD New( BColor, cFont, nSize ) CLASS cLbl

   ::cForm := _HMG_ThisFormName
   ::cFont := _HMG_DefaultFontName
   ::nSize := _HMG_DefaultFontSize
   ::aSub  :=  hb_Hash()

   IF BColor != Nil; ::BColor := BColor
   ENDIF
   IF cFont  != Nil; ::cFont  := cFont
   ENDIF
   IF nSize  != Nil; ::nSize  := nSize
   ENDIF

RETURN Self


METHOD Def( cTxt, cChr ) CLASS cLbl

   DEFAULT cChr := ' '

   IF HB_ISCHAR( cTxt )
      ::cTxt := AllTrim( cTxt )
      ::aTxt := hb_ATokens( ::cTxt, cChr )
   ELSEIF HB_ISARRAY( cTxt )
      ::cTxt := ''
      ::aTxt := cTxt
   ENDIF

RETURN Self


METHOD Out( nRow, nCol ) CLASS cLbl

   LOCAL a, c, i, j, l, w := 0, h := 0
   LOCAL FC, lB, lI, lU, cT
   LOCAL cWnd := ::cForm
   LOCAL lH := .F.
   LOCAL y  := nRow
   LOCAL x  := nCol
   LOCAL cF := ::cFont
   LOCAL nS := ::nSize
   LOCAL BC := ::BColor
   LOCAL cS := ::cSpace
   LOCAL o  := Self

   DO WHILE _IsControlDefined( ::cLbl + hb_ntos( ::nLbl ), cWnd )
      ::nLbl += 1
   ENDDO

   FOR i := 1 TO Len( ::aTxt )
      c := ::cLbl + hb_ntos( ::nLbl )
      j := ::aTxt[ i ]
      a := hb_HGetDef( ::aSub, Lower( j ), NIL )

      IF ! Empty( a )
         FC :=         a[ 1 ]
         lB := !Empty( a[ 2 ] )
         lI := !Empty( a[ 3 ] )
         lU := !Empty( a[ 4 ] )
         cT :=         a[ 5 ]
         lH := !Empty( a[ 6 ] )
      ELSE
         FC := ::FColor
         lB := ::lBold
         lI := ::lItalic
         lU := ::lUnderl
         cT := Nil
      ENDIF

      ::nLbl += 1

      DEFINE LABEL    &c
        ROW           y
        COL           x
        VALUE         j + cS
        FONTNAME      cF
        FONTSIZE      nS
        FONTBOLD      lB
        FONTITALIC    lI
        FONTUNDERLINE lU
        BACKCOLOR     BC
        FONTCOLOR     FC
        TOOLTIP       cT
        VCENTERALIGN  .T.
        AUTOSIZE      .T.
        ACTION        o:Block()
        IF lH
           ON MOUSEHOVER CursorHand()
        ENDIF
      END LABEL

      l := This.&(c).Width
      x += l
      w += l
      h := Max( h, This.&(c).Height )
   NEXT

RETURN { h, w }


METHOD Block() CLASS cLbl

   LOCAL v := Trim( _GetValue( _HMG_ThisControlName, ::cForm ) )
   LOCAL a := hb_HGetDef( ::aSub, Lower( v ), NIL )

   IF HB_ISARRAY( a ) .AND. HB_ISBLOCK( a[ 7 ] )
      Eval( a[ 7 ], Self )
   ENDIF

RETURN NIL


STATIC FUNCTION Create_txt( cFile )

   LOCAL t

   t := 'This exception applies only to the code released by the Harbour'     + CRLF
   t += 'Project under the name Harbour.  If you copy code from other'        + CRLF
   t += 'Harbour Project or Free Software Foundation releases into a copy of' + CRLF
   t += 'Harbour, as the General Public License permits, the exception does'  + CRLF
   t += 'not apply to the code that you add in this way.  To avoid misleading' + CRLF
   t += 'anyone as to the status of such modified files, you must delete'     + CRLF
   t += 'this exception notice from them.'                                    + CRLF

   hb_MemoWrit( cFile, t )

RETURN NIL
