/*
 * MINIGUI - Harbour Win32 GUI library source code
 *
 * Copyright 2017-2020 Aleksandr Belov, Sergej Kiselev <bilance@bilance.lv>
 */

#include "minigui.ch"

#ifdef _OBJECT_
#include "i_winuser.ch"
#ifdef __XHARBOUR__
#include "hbcompat.ch"
#endif
#include "hbclass.ch"

#define _METHOD METHOD

STATIC o_AppDlu2Pixel

*-----------------------------------------------------------------------------*
FUNCTION oDlu4Font( nFontSize, lDlu2Pix )
*-----------------------------------------------------------------------------*
   LOCAL nPrcW, nPrcH, aDim
   LOCAL aScale := { {  8,  85,  75}, ; 
                     {  9,  90,  85}, ; 
                     { 10,  95,  85}, ; 
                     { 11, 100,  90}, ; 
                     { 12, 110,  95}, ; 
                     { 13, 115, 100}, ; 
                     { 14, 120, 110}, ; 
                     { 15, 130, 110}, ; 
                     { 16, 140, 120}, ; 
                     { 17, 145, 120}, ; 
                     { 18, 150, 130}, ; 
                     { 19, 160, 130}, ; 
                     { 20, 170, 145}, ; 
                     { 21, 175, 145}, ; 
                     { 22, 180, 150}, ; 
                     { 23, 190, 155}, ; 
                     { 24, 200, 160}, ; 
                     { 25, 205, 170}, ; 
                     { 26, 210, 180}  ; 
                   } 

   DEFAULT lDlu2Pix := .T., nFontSize := 11, nPrcW := 100, nPrcH := 100

   IF     nFontSize < aScale[ 1 ][ 1 ]     ; nFontSize := aScale[ 1 ][ 1 ]
   ELSEIF nFontSize > ATail( aScale )[ 1 ] ; nFontSize := ATail( aScale )[ 1 ]
   ENDIF

   FOR EACH aDim IN aScale
      IF nFontSize == aDim[ 1 ]
         nPrcW := aDim[ 2 ]
         nPrcH := aDim[ 3 ]
         EXIT
      ENDIF
   NEXT

   IF lDlu2Pix
      RETURN TDlu2Pix():New( nPrcW, nPrcH )
   ENDIF

RETURN { nPrcW, nPrcH }

*-----------------------------------------------------------------------------*
FUNCTION oDlu2Pixel( nPrcW, nPrcH, nFontSize )
*-----------------------------------------------------------------------------*

   LOCAL aPrcWH

   IF HB_ISNUMERIC( nFontSize )
      aPrcWH := oDlu4Font( nFontSize, .F. )
      nPrcW  := aPrcWH[ 1 ]
      nPrcH  := aPrcWH[ 2 ]
   ENDIF

   IF PCount() > 0

      IF HB_ISARRAY( nPrcW )
         ASize( nPrcW, 2 )
         nPrcH := nPrcW[ 2 ]
         nPrcW := nPrcW[ 1 ]
      ELSEIF HB_ISCHAR ( nPrcW )
         nPrcW := hb_ATokens( nPrcW, ',' )
         ASize( nPrcW, 2 )
         nPrcH := Val( nPrcW[ 2 ] )
         nPrcW := Val( nPrcW[ 1 ] )
      ENDIF

      nPrcH := iif( Empty( nPrcH ) .OR. nPrcH < 0, NIL, nPrcH )
      nPrcW := iif( Empty( nPrcW ) .OR. nPrcW < 0, NIL, nPrcW )

      IF o_AppDlu2Pixel != NIL
         hb_default( @nPrcW, o_AppDlu2Pixel:nScaleWidth )
         hb_default( @nPrcH, o_AppDlu2Pixel:nScaleHeight )
      ENDIF

   ENDIF

   hb_default( @nPrcW, 100 )
   hb_default( @nPrcH, 100 )

   IF o_AppDlu2Pixel == NIL

      o_AppDlu2Pixel := TDlu2Pix():New( nPrcW, nPrcH )

      If ! o_AppDlu2Pixel:IsError
         o_AppDlu2Pixel:Create()
      ENDIF

   ELSEIF PCount() > 0

      o_AppDlu2Pixel:UnitsToPixels( nPrcW, nPrcH )

   ENDIF

RETURN o_AppDlu2Pixel

*-----------------------------------------------------------------------------*
FUNCTION _App_Dlu2Pix_Events_( hWnd, nMsg, wParam, lParam )
*-----------------------------------------------------------------------------*

   LOCAL h, nRet := 0
   STATIC o_app

   IF HB_ISOBJECT( hWnd )
      MESSAGEONLY _App_Dlu2Pix_App_ EVENTS _App_Dlu2Pix_Events_ TO h
      o_app := hWnd
      o_app:Handle := h
      RETURN nRet
   ELSEIF ! HB_ISOBJECT( o_app )
      RETURN nRet
   ENDIF

   IF nMsg == o_app:Wm_nApp
      o_app:Event( wParam, lParam, o_app:oParam:Get( wParam ) )
      nRet := 1
   ENDIF

RETURN nRet

///////////////////////////////////////////////////////////////////////////////
CLASS TDlu2Pix
///////////////////////////////////////////////////////////////////////////////

   VAR Cargo
   VAR oCargo INIT oKeyData()
   VAR oProp INIT oKeyData()
   VAR oEvent INIT oKeyData()
   VAR oParam INIT oKeyData()

   VAR hWnd INIT 0
   VAR lError INIT .F.
   VAR lAction INIT .T.

   VAR nUnitWidth INIT 50 // width  controls GetBox, Button, ...
   VAR nUnitHeight INIT 14 // height controls GetBox, Button, ...
   VAR nUnitHeight2 INIT 24 // 2height controls GetBox, Button, ...
   VAR nUnitGapsWidth INIT 4 // width  space between controls
   VAR nUnitGapsHeight INIT 4 // height space between controls
   VAR nUnitMargWidth INIT 7 // Left, Right margin
   VAR nUnitMargHeight INIT 7 // Top, Bottom margin
   VAR nUnitWidthDT INIT 50 // for data
   VAR nUnitWidthDT1 INIT 60 // for data 50 * 1.2. MontCalendar
   VAR nUnitWidthDT2 INIT 75 // for data 50 * 1.3. MontCalendar + Week

   VAR nScaleWidth INIT 100 // % width
   VAR nScaleHeight INIT 100 // % height

   VAR nPixWidth INIT 0
   VAR nPixHeight INIT 0
   VAR nPixHeight2 INIT 0
   VAR nPixWidthDT INIT 0
   VAR nPixWidthDT1 INIT 0
   VAR nPixWidthDT2 INIT 0
   VAR nGapsWidth INIT 0
   VAR nGapsHeight INIT 0
   VAR nMargWidth INIT 0
   VAR nMargHeight INIT 0

   VAR nY INIT 0
   VAR nX INIT 0

   VAR nL INIT 0
   VAR nT INIT 0
   VAR nR INIT 0
   VAR nB INIT 0
  
   METHOD New( nPrcW, nPrcH ) INLINE ( ::nScaleWidth := hb_defaultValue( nPrcW, 100 ), ;
      ::nScaleHeight := hb_defaultValue( nPrcH, 100 ), ;
      ::UnitsToPixels(), Self ) CONSTRUCTOR
  _METHOD UnitsToPixels( nPrcW, nPrcH )
   METHOD DLU2PixH( nHeight, nPrc ) INLINE Round( ( UnitsToPixelsY( nHeight ) * 13 * nPrc ) / 1500, 0 )
   METHOD DLU2PixW( nWidth, nPrc ) INLINE Round( ( UnitsToPixelsX( nWidth ) * 13 * nPrc ) / 1500, 0 )
  _METHOD Kfc( nKfcW, nKfcH )
  _METHOD ToVal( nKfc, nVal )
  _METHOD GetGaps( aGaps, oWnd )
  _METHOD D ( nKfc )
   METHOD W ( nKfc ) INLINE ::ToVal( nKfc, ::nPixWidth )
   METHOD H ( nKfc ) INLINE ::ToVal( nKfc, ::nPixHeight )
   METHOD H_( nKfc ) INLINE ::ToVal( nKfc, ::nPixHeight2 )
   METHOD G ( nKfc, lW ) INLINE iif( Empty( lW ), ::GW( nKfc ), ::GH( nKfc ) )
   METHOD GW( nKfc ) INLINE ::ToVal( nKfc, ::nGapsWidth )
   METHOD GH( nKfc ) INLINE ::ToVal( nKfc, ::nGapsHeight )
   METHOD M ( nKfc, lW ) INLINE iif( Empty( lW ), ::MW( nKfc ), ::MH( nKfc ) )
   METHOD MW( nKfc ) INLINE ::ToVal( nKfc, ::nMargWidth )
   METHOD MH( nKfc ) INLINE ::ToVal( nKfc, ::nMargHeight )

   ASSIGN Handle( hWnd ) INLINE ( ::hWnd := hWnd, ::lError := Empty( hWnd ), ;
          iif( ::lError, MsgMiniGuiError( "Application events are not created !" ), ) )
   ACCESS IsError        INLINE ::lError
   ACCESS Wm_nApp        INLINE WM_APP_LAUNCH
   ACCESS IsMsg          INLINE ( ::lAction .AND. ! ::lError )

   ACCESS Action            INLINE ::lAction
   ASSIGN Action( lAction ) INLINE ::lAction := !( Empty( lAction ) )

   ACCESS GapsWidth INLINE ::GW()
   ACCESS GapsHeight INLINE ::GH()
   ACCESS Left   INLINE ::MW()
   ACCESS Top    INLINE ::MH()
   ACCESS Right  INLINE ::MW()
   ACCESS Bottom INLINE ::MH()
   
   ACCESS O      INLINE ::oCargo
   ACCESS P      INLINE ::oProp

   ACCESS Y      INLINE ::nY
   ASSIGN Y( y ) INLINE ::nY := y
   ACCESS X      INLINE ::nX   
   ASSIGN X( x ) INLINE ::nX := x

   ACCESS LTRB   INLINE { ::nL, ::nT, ::nR, ::nB }

   ACCESS L      INLINE ::nL
   ASSIGN L( n ) INLINE ::nL := n
   ACCESS T      INLINE ::nT
   ASSIGN T( n ) INLINE ::nT := n
   ACCESS R      INLINE ::nR
   ASSIGN R( n ) INLINE ::nR := n
   ACCESS B      INLINE ::nB
   ASSIGN B( n ) INLINE ::nB := n

   ACCESS W1     INLINE ::W ( 1 )
   ACCESS W2     INLINE ::W ( 2 )
   ACCESS W3     INLINE ::W ( 3 )
   ACCESS W4     INLINE ::W ( 4 )
   ACCESS W5     INLINE ::W ( 5 )

   ACCESS H1     INLINE ::H ()  
   ACCESS H2     INLINE ::H_()  
   ACCESS H3     INLINE ::H1 + ::H2
   ACCESS H4     INLINE ::H2 + ::H2
   ACCESS H5     INLINE ::H1 + ::H4

   ACCESS D1     INLINE ::D ( 1 )  
   ACCESS D2     INLINE ::D ( 2 )  
   ACCESS D3     INLINE ::D ( 3 )  

   METHOD Create() INLINE _App_Dlu2Pix_Events_( Self )

   METHOD Event( Key, p1, p2, p3 )  INLINE iif( HB_ISBLOCK( p1 ),   ;
                 ::oEvent:Set( Key, p1 ),                           ;
                 ( p2 := hb_defaultValue( p2, ::oParam:Get( Key) ), ;
                 ::oEvent:Do ( Key, p1, p2, p3 ) ) )

   METHOD Post ( nKey, nPar, xPar ) INLINE ::PostMsg( nKey, nPar, xPar )
   METHOD PostMsg( nKey, nPar, xPar ) INLINE ( nPar := hb_defaultValue( nPar, 0 ), ;
      iif( ::IsMsg, ( ::oParam:Set( nKey, xPar ), ;
      PostMessage( ::hWnd, ::Wm_nApp, nKey, nPar ) ), Nil ) )
   METHOD Send ( nKey, nPar, xPar ) INLINE ::SendMsg( nKey, nPar, xPar )
   METHOD SendMsg( nKey, nPar, xPar ) INLINE ( nPar := hb_defaultValue( nPar, 0 ), ;
      iif( ::IsMsg, ( ::oParam:Set( nKey, xPar ), ;
      SendMessage( ::hWnd, ::Wm_nApp, nKey, nPar ) ), Nil ) )

ENDCLASS

METHOD UnitsToPixels( nPrcW, nPrcH ) CLASS TDlu2Pix

   DEFAULT nPrcW := hb_defaultValue( nPrcW, ::nScaleWidth ), ;
           nPrcH := hb_defaultValue( nPrcH, ::nScaleHeight )

   ::nScaleWidth  := nPrcW
   ::nScaleHeight := nPrcH

   ::nPixWidth := ::DLU2PixW( ::nUnitWidth, nPrcW )
   ::nPixHeight := ::DLU2PixH( ::nUnitHeight, nPrcH )
   ::nPixHeight2 := ::DLU2PixH( ::nUnitHeight2, nPrcH )

   ::nGapsWidth := ::DLU2PixW( ::nUnitGapsWidth, nPrcW )
   ::nGapsHeight := ::DLU2PixH( ::nUnitGapsHeight, nPrcH )
   ::nMargWidth := ::DLU2PixW( ::nUnitMargWidth, nPrcW )
   ::nMargHeight := ::DLU2PixH( ::nUnitMargHeight, nPrcH )

   ::nPixWidthDT := ::DLU2PixW( ::nUnitWidthDT, nPrcW )
   ::nPixWidthDT1 := ::DLU2PixH( ::nUnitWidthDT1, nPrcH )
   ::nPixWidthDT2 := ::DLU2PixH( ::nUnitWidthDT2, nPrcH )

RETURN NIL

METHOD Kfc( nKfcW, nKfcH ) CLASS TDlu2Pix

   If ! Empty( nKfcW )
      ::nPixWidth += Int( ::nPixWidth * nKfcW )
      ::nPixWidthDT += Int( ::nPixWidthDT * nKfcW )
      ::nPixWidthDT1 += Int( ::nPixWidthDT1 * nKfcW )
      ::nPixWidthDT2 += Int( ::nPixWidthDT2 * nKfcW )
      ::nGapsWidth += Int( ::nGapsWidth * nKfcW )
      ::nMargWidth += Int( ::nMargWidth * nKfcW )
   ENDIF

   If ! Empty( nKfcH )
      ::nPixHeight += Int( ::nPixHeight * nKfcH )
      ::nPixHeight2 += Int( ::nPixHeight2 * nKfcH )
      ::nGapsHeight += Int( ::nGapsHeight * nKfcW )
      ::nMargHeight += Int( ::nMargHeight * nKfcW )
   ENDIF

RETURN NIL

METHOD ToVal( nKfc, nVal ) CLASS TDlu2Pix

   IF HB_ISNUMERIC( nKfc ) .AND. nKfc > 0
      nVal := Int( nKfc * nVal )
   ENDIF

RETURN nVal

METHOD GetGaps( aGaps, oWnd ) CLASS TDlu2Pix

   LOCAL oApp, nGapW, nGapH, n

   If HB_ISCHAR( oWnd ); oWnd := _WindowObj( oWnd )
   EndIf
   
   oApp  := iif( Empty( oWnd ), Self           , oWnd:App )
   nGapW := iif( Empty( oWnd ), oApp:GapsWidth , oWnd:GapsWidth  )
   nGapH := iif( Empty( oWnd ), oApp:GapsHeight, oWnd:GapsHeight )

   If HB_ISNUMERIC( aGaps )
      n     := aGaps
      aGaps := Array( 4 )
      AFill( aGaps, n )
   EndIf
   
   DEFAULT aGaps := { 0, 0, nGapW, nGapH }
   
   ::nL := 0
   ::nT := 0
   ::nR := 0
   ::nB := 0
   
   If Len(aGaps) == 2
      If ! HB_ISNUMERIC( aGaps[1] ); aGaps[1] := nGapW
      EndIf
      If ! HB_ISNUMERIC( aGaps[2] ); aGaps[2] := nGapH
      EndIf
      ::nL := aGaps[1]
      ::nR := aGaps[1]
      ::nT := aGaps[2]
      ::nB := aGaps[2]
   Else
      If Len( aGaps ) != 4; ASize( aGaps, 4 )
      EndIf
      If ! HB_ISNUMERIC( aGaps[1] ); aGaps[1] := nGapW
      EndIf
      If ! HB_ISNUMERIC( aGaps[2] ); aGaps[2] := nGapH
      EndIf
      If ! HB_ISNUMERIC( aGaps[3] ); aGaps[3] := nGapW
      EndIf
      If ! HB_ISNUMERIC( aGaps[4] ); aGaps[4] := nGapH
      EndIf
      ::nL := aGaps[1]
      ::nT := aGaps[2]
      ::nR := aGaps[3]
      ::nB := aGaps[4]
   EndIf
   
   If '.' $ hb_ntos( ::nL ); ::nL := oApp:GW( ::nL )
   EndIf

   If '.' $ hb_ntos( ::nT); ::nT := oApp:GH( ::nT )
   EndIf
   
   If '.' $ hb_ntos( ::nR ); ::nR := oApp:GW( ::nR )
   EndIf
   
   If '.' $ hb_ntos( ::nB ); ::nB := oApp:GH( ::nB )
   EndIf

RETURN ( ::LTRB )

METHOD D( nKfc ) CLASS TDlu2Pix

   LOCAL nVal := ::nPixWidthDT

   IF HB_ISNUMERIC( nKfc ) .AND. nKfc > 0
      IF nKfc == 1 ; nVal := ::nPixWidthDT
      ELSEIF nKfc == 2 ; nVal := ::nPixWidthDT2
      ELSEIF nKfc == 3 ; nVal := ::nPixWidthDT3
      ELSE ; nVal := Int( nKfc * nVal )
      ENDIF
   ENDIF

RETURN nVal

///////////////////////////////////////////////////////////////////////////////
CLASS TWndData
///////////////////////////////////////////////////////////////////////////////

   PROTECTED:
   VAR cVar INIT ''
   VAR cName INIT ''
   VAR cType INIT ''
   VAR nIndex INIT 0
   VAR nHandle INIT 0
   VAR nParent INIT 0
   VAR cChr INIT ','
   VAR lAction INIT .T.

   VAR oStatusBar AS OBJECT
   VAR oProp AS OBJECT
   VAR oName AS OBJECT
   VAR oHand AS OBJECT

   VAR nY INIT 0
   VAR nX INIT 0
   VAR nLeft INIT 0
   VAR nTop INIT 0
   VAR nRight INIT 0
   VAR nBottom INIT 0
   VAR nGapWidth INIT 0
   VAR nGapHeight INIT 0

   EXPORTED:
   VAR oApp AS OBJECT
   VAR oCargo AS OBJECT
   VAR oUserKeys AS OBJECT
   VAR oEvent AS OBJECT
   VAR oOnEventBlock AS OBJECT
   VAR oParam AS OBJECT

   METHOD New() INLINE ( ::oApp := oDlu2Pixel(), Self ) CONSTRUCTOR

   METHOD Def( nIndex, cName, nHandle, nParent, cType, cVar ) INLINE ( ;
      ::nIndex := nIndex, ::cName := cName, ::nHandle := nHandle, ;
      ::nParent := nParent, ::cType := cType, ::cVar := cVar, ;
      ::oCargo := oKeyData(), ::oOnEventBlock := oKeyData( Self, .T. ), ;
      ::oEvent := oKeyData( Self ), ::oUserKeys := oKeyData(), ;
      ::oName := oKeyData(), ::oHand := oKeyData(), ;
      ::oProp := oKeyData(), ::oParam := oKeyData(), ;
      hmg_SetWindowObject( ::nHandle, Self ), ;
      ::nLeft := ::oApp:Left, ::nRight := ::oApp:Right, ;
      ::nTop := ::oApp:Top, ::nBottom := ::oApp:Bottom, ;
      ::nGapWidth := ::oApp:GapsWidth, ;
      ::nGapHeight := ::oApp:GapsHeight, ;
      Self )

   ACCESS Left INLINE ::nLeft
   ASSIGN Left ( n ) INLINE ::nLeft := n
   ACCESS Top INLINE ::nTop
   ASSIGN Top ( n ) INLINE ::nTop := n
   ACCESS Right INLINE ::nRight
   ASSIGN Right ( n ) INLINE ::nRight := n
   ACCESS Bottom INLINE ::nBottom
   ASSIGN Bottom( n ) INLINE ::nBottom := n

   ACCESS GapsWidth INLINE ::nGapWidth
   ASSIGN GapsWidth ( n ) INLINE ::nGapWidth := n
   ACCESS GapsHeight INLINE ::nGapHeight
   ASSIGN GapsHeight( n ) INLINE ::nGapHeight := n

   ACCESS App        INLINE ::oApp

   ACCESS LTRB       INLINE ::oApp:LTRB

   ACCESS L          INLINE ::oApp:nL
   ASSIGN L( n )     INLINE ::oApp:nL := n
   ACCESS T          INLINE ::oApp:nT
   ASSIGN T( n )     INLINE ::oApp:nT := n
   ACCESS R          INLINE ::oApp:nR
   ASSIGN R( n )     INLINE ::oApp:nR := n
   ACCESS B          INLINE ::oApp:nB
   ASSIGN B( n )     INLINE ::oApp:nB := n
   
   ACCESS AO         INLINE ::oApp:oCargo
   ACCESS AP         INLINE ::oApp:oProp

   ACCESS O          INLINE ::oCargo
   ACCESS P          INLINE ::oProp

   ACCESS WO         INLINE ::oCargo
   ACCESS WP         INLINE ::oProp

   ACCESS Y          INLINE ::nY   
   ASSIGN Y( y )     INLINE ::nY := y
   ACCESS X          INLINE ::nX   
   ASSIGN X( x )     INLINE ::nX := x

   METHOD GetGaps( aGaps, oWnd ) INLINE ::oApp:GetGaps( aGaps, oWnd )

   METHOD W ( nKfc ) INLINE ::oApp:W ( nKfc )
   ACCESS W1         INLINE ::oApp:W1
   ACCESS W2         INLINE ::oApp:W2
   ACCESS W3         INLINE ::oApp:W3
   ACCESS W4         INLINE ::oApp:W4
   ACCESS W5         INLINE ::oApp:W5

   METHOD H ( nKfc ) INLINE ::oApp:H ( nKfc )
   ACCESS H1         INLINE ::oApp:H1    
   ACCESS H2         INLINE ::oApp:H2    
   ACCESS H3         INLINE ::oApp:H3  
   ACCESS H4         INLINE ::oApp:H4  
   ACCESS H5         INLINE ::oApp:H5  

   METHOD D ( nKfc ) INLINE ::oApp:D ( nKfc )
   ACCESS D1         INLINE ::oApp:D1  
   ACCESS D2         INLINE ::oApp:D2  
   ACCESS D3         INLINE ::oApp:D3  

   METHOD GW( nKfc ) INLINE ::oApp:GW( nKfc )
   METHOD GH( nKfc ) INLINE ::oApp:GH( nKfc )

   METHOD MW( nKfc ) INLINE ::oApp:MW( nKfc )
   METHOD MH( nKfc ) INLINE ::oApp:MH( nKfc )

   ACCESS Index           INLINE ::nIndex
   ACCESS Name            INLINE ::cName
   ACCESS Handle          INLINE ::nHandle
   ACCESS Parent          INLINE ::nParent
   ACCESS Type            INLINE ::cType
   ACCESS VarName         INLINE ::cVar
   ACCESS Row             INLINE GetWindowRow ( ::nHandle )
   ASSIGN Row ( nVal )    INLINE _SetWindowSizePos( ::cName, nVal, , , )
   ACCESS Col             INLINE GetWindowCol ( ::nHandle )
   ASSIGN Col ( nVal )    INLINE _SetWindowSizePos( ::cName, , nVal, , )
   ACCESS Width           INLINE GetWindowWidth ( ::nHandle )
   ASSIGN Width ( nVal )  INLINE _SetWindowSizePos( ::cName, , , nVal, )
   ACCESS Height          INLINE GetWindowHeight ( ::nHandle )
   ASSIGN Height( nVal )  INLINE _SetWindowSizePos( ::cName, , , , nVal )
   ACCESS ClientWidth     INLINE _GetClientRect ( ::nHandle )[ 3 ]
   ACCESS ClientHeight    INLINE _GetClientRect ( ::nHandle )[ 4 ]
   ACCESS Title           INLINE GetWindowText ( ::nHandle )
   ASSIGN Title( cVal )   INLINE SetWindowText ( ::nHandle, cVal )
   ACCESS Enabled         INLINE IsWindowEnabled ( ::nHandle )
   ASSIGN Enabled( xVal ) INLINE iif( Empty( xVal ), DisableWindow ( ::nHandle ), EnableWindow ( ::nHandle ) )

   ACCESS BackColor                       INLINE  GetProperty( ::cName, 'BACKCOLOR'      )
   ASSIGN BackColor( Val )                INLINE  SetProperty( ::cName, 'BACKCOLOR', Val )

   ACCESS Cargo INLINE _WindowCargo( Self )
   ASSIGN Cargo( xVal ) INLINE _WindowCargo( Self, xVal )

   ACCESS IsWindow INLINE .T.
   ACCESS IsControl INLINE .F.
   ACCESS Chr INLINE ::cChr
   ASSIGN Chr( cChr ) INLINE ::cChr := iif( HB_ISCHAR( cChr ), cChr, ::cChr )

   ACCESS Action INLINE ::lAction
   ASSIGN Action( lAction ) INLINE ::lAction := !( Empty( lAction ) )

   ACCESS StatusBar INLINE ::oStatusBar
   ACCESS HasStatusBar INLINE ! Empty( ::oStatusBar )
   ACCESS bOnEvent INLINE ::oOnEventBlock

   ACCESS WM_nMsgW INLINE WM_WND_LAUNCH
   ACCESS WM_nMsgC INLINE WM_CTL_LAUNCH

   METHOD SetProp( xKey, xVal ) INLINE ::oProp:Set( xKey, xVal )
   METHOD GetProp( xKey ) INLINE ::oProp:Get( xKey )
   METHOD DelProp( xKey ) INLINE ::oProp:Del( xKey )
   METHOD AllProp( lArray ) INLINE ::oProp:GetAll( lArray )

   METHOD UserKeys( Key, Block, p2, p3 ) INLINE iif( HB_ISBLOCK( Block ), ::oUserKeys:Set( Key, Block ), ;
      iif( ::lAction, ::oUserKeys:Do( Key, Block, p2, p3 ), Nil ) )

   METHOD Event ( Key, Block, p2, p3 ) INLINE iif( HB_ISBLOCK( Block ), ::oEvent:Set( Key, Block ), ;
      iif( ::lAction, ::oEvent:Do( Key, Block, p2, p3 ), Nil ) )

   METHOD Post ( nKey, nHandle, xPar ) INLINE ::PostMsg( nKey, nHandle, xPar )
   METHOD PostMsg( nKey, nHandle, xPar ) INLINE iif( ::lAction, ( ::oParam:Set( nKey, xPar ), ;
      PostMessage( ::nHandle, ::WM_nMsgW, nKey, hb_defaultValue( nHandle, 0 ) ) ), Nil )
   METHOD Send ( nKey, nHandle, xPar ) INLINE ::SendMsg( nKey, nHandle, xPar )
   METHOD SendMsg( nKey, nHandle, xPar ) INLINE iif( ::lAction, ( ::oParam:Set( nKey, xPar ), ;
      SendMessage( ::nHandle, ::WM_nMsgW, nKey, hb_defaultValue( nHandle, 0 ) ) ), Nil )

   METHOD Release() INLINE iif( ::IsWindow, ;
      iif( ::lAction, PostMessage( ::nHandle, WM_CLOSE, 0, 0 ), Nil ), Nil )

   METHOD Restore() INLINE ShowWindow( ::nHandle, SW_RESTORE )
   METHOD Show() INLINE _ShowWindow( ::cName )
   METHOD Hide() INLINE _HideWindow( ::cName )
   METHOD SetFocus( xName ) INLINE iif( Empty( xName ), SetFocus( ::nHandle ), ::GetObj( xName ):SetFocus() )
   METHOD SetSize( y, x, w, h ) INLINE _SetWindowSizePos( ::cName, y, x, w, h )

   _METHOD DoEvent( Key, nHandle )
   _METHOD GetListType()
   _METHOD GetObj4Type( cType, lEque )
   _METHOD GetObj4Name( cName )

   METHOD GetObj( xName ) INLINE iif( HB_ISCHAR( xName ), ::oName:Get( Upper( xName ) ), ;
      ::oHand:Get( xName ) )
   // Destructor
   METHOD Destroy() INLINE ( ;
      ::oCargo := iif( HB_ISOBJECT( ::oCargo ), ::oCargo:Destroy(), Nil ), ;
      ::oEvent := iif( HB_ISOBJECT( ::oEvent ), ::oEvent:Destroy(), Nil ), ;
      ::oOnEventBlock := iif( HB_ISOBJECT( ::oOnEventBlock ), ::oOnEventBlock:Destroy(), Nil ), ;
      ::oStatusBar := iif( HB_ISOBJECT( ::oStatusBar ), ::oStatusBar:Destroy(), Nil ), ;
      ::oName := iif( HB_ISOBJECT( ::oName ), ::oName:Destroy(), Nil ), ;
      ::oHand := iif( HB_ISOBJECT( ::oHand ), ::oHand:Destroy(), Nil ), ;
      ::oProp := iif( HB_ISOBJECT( ::oProp ), ::oProp:Destroy(), Nil ), ;
      ::oParam := iif( HB_ISOBJECT( ::oParam ), ::oParam:Destroy(), Nil ), ;
      ::oUserKeys := iif( HB_ISOBJECT( ::oUserKeys ), ::oUserKeys:Destroy(), Nil ), ;
      ::nIndex := ::nParent := ::cType := ::cName := ::cVar := ::cChr := NIL, ;
      hmg_DelWindowObject( ::nHandle ), ::nHandle := Nil )

#ifndef __XHARBOUR__
   DESTRUCTOR DestroyObject()
#endif

   ERROR HANDLER ControlAssign

ENDCLASS
///////////////////////////////////////////////////////////////////////////////

METHOD ControlAssign( xValue ) CLASS TWndData

   LOCAL cMessage, uRet, lError, o

   cMessage := __GetMessage()
   lError := .T.

   IF PCount() == 0
      o := ::GetObj( cMessage )
      IF HB_ISOBJECT( o )
         uRet := _GetValue( , , o:nIndex )
         lError := .F.
      ENDIF
   ELSEIF PCount() == 1
      o := ::GetObj( SubStr( cMessage, 2 ) )
      IF HB_ISOBJECT( o )
         _SetValue( , , xValue, o:nIndex )
         uRet := _GetValue( , , o:nIndex )
         lError := .F.
      ENDIF
   ENDIF

   IF lError
      uRet := NIL
      ::MsgNotFound( cMessage )
   ENDIF

RETURN uRet

METHOD GetListType() CLASS TWndData

   LOCAL oType := oKeyData()
   LOCAL aType

   ::oName:Eval( {| o | oType:Set( o:cType, o:cType ) } )
   aType := oType:Eval( .T. )
   oType:Destroy()
   oType := NIL

RETURN aType

METHOD GetObj4Type( cType, lEque ) CLASS TWndData

   LOCAL aObj := {}, aRet := {}, o

   IF ! Empty( cType )
      hb_default( @lEque, .T. )
      IF ::cChr $ cType ; lEque := .F.
      ENDIF
      FOR EACH cType IN hb_ATokens( Upper( cType ), ::cChr )
         ::oName:Eval( {| oc | iif( lEque, iif( cType == oc:cType, AAdd( aObj, oc ), ), ;
            iif( cType $ oc:cType, AAdd( aObj, oc ), ) ) } )
      NEXT
      FOR EACH o IN aObj
         IF _IsControlDefined( o:Name, o:Window:Name )
            aAdd( aRet, o )
         ENDIF
      NEXT
   ENDIF

RETURN aRet

METHOD GetObj4Name( cName ) CLASS TWndData

   LOCAL aObj := {}

   IF ! Empty( cName )
      FOR EACH cName IN hb_ATokens( Upper( cName ), ::cChr )
         ::oName:Eval( {| oc | iif( _IsControlDefined( oc:Name, oc:Window:Name ), ;
            iif( cName $ Upper( oc:cName ), AAdd( aObj, oc ), Nil ), Nil ) } )
      NEXT
   ENDIF

RETURN aObj

METHOD DoEvent ( Key, nHandle ) CLASS TWndData

   LOCAL o := Self
   LOCAL i := o:Index
   LOCAL w := o:IsWindow
   LOCAL p := o:oParam:Get( Key )

   IF ! Empty( nHandle )
      IF nHandle > 0 .AND. nHandle <= Len( _HMG_aControlHandles ) // control index
         IF hmg_IsWindowObject( _HMG_aControlHandles[ nHandle ] )
            o := hmg_GetWindowObject( _HMG_aControlHandles[ nHandle ] )
            i := o:Index
            w := o:IsWindow
         ELSE
            i := nHandle
            w := .F.
         ENDIF
      ELSEIF hmg_IsWindowObject( nHandle ) // control handle
         o := hmg_GetWindowObject( nHandle )
         i := o:Index
         w := o:IsWindow
      ENDIF
   ENDIF

   IF w
      RETURN Do_WindowEventProcedure ( ::oEvent:Get( Key ), i, o, Key, p )
   ENDIF

RETURN Do_ControlEventProcedure( ::oEvent:Get( Key ), i, o, Key, p )

#ifndef __XHARBOUR__
METHOD PROCEDURE DestroyObject() CLASS TWndData

   ::Destroy()

RETURN
#endif

///////////////////////////////////////////////////////////////////////////////
CLASS TCnlData INHERIT TWndData
///////////////////////////////////////////////////////////////////////////////

   PROTECTED:
   VAR oWin AS OBJECT

   EXPORTED:
   METHOD New( oWnd ) INLINE ( ::Super:New(), ::oWin := oWnd, Self ) CONSTRUCTOR

   METHOD Def( nIndex, cName, nHandle, nParent, cType, cVar ) INLINE ( ;
      ::Super:Def( nIndex, cName, nHandle, nParent, cType, cVar ), ;
      ::Set(), hmg_SetWindowObject( ::nHandle, Self ), ;
      Self )

   ACCESS Row INLINE _GetControlRow ( ::cName, ::oWin:Name )
   ASSIGN Row ( nVal ) INLINE _SetControlRow ( ::cName, ::oWin:Name, nVal )
   ACCESS Col INLINE _GetControlCol ( ::cName, ::oWin:Name )
   ASSIGN Col ( nVal ) INLINE _SetControlCol ( ::cName, ::oWin:Name, nVal )
   ACCESS Width INLINE _GetControlWidth ( ::cName, ::oWin:Name )
   ASSIGN Width ( nVal ) INLINE _SetControlWidth ( ::cName, ::oWin:Name, nVal )
   ACCESS Height INLINE _GetControlHeight( ::cName, ::oWin:Name )
   ASSIGN Height( nVal ) INLINE _SetControlHeight( ::cName, ::oWin:Name, nVal )

   ACCESS Align INLINE GetProperty( ::oWin:Name, ::cName, 'ALIGNMENT' )
   ASSIGN Align( cAlign ) INLINE SetProperty( ::oWin:Name, ::cName, 'ALIGNMENT', cAlign )

   ACCESS BackColor                       INLINE  GetProperty( ::oWin:cName, ::cName, 'BACKCOLOR'      )
   ASSIGN BackColor( Val )                INLINE  SetProperty( ::oWin:cName, ::cName, 'BACKCOLOR', Val )
   ACCESS FontColor                       INLINE  GetProperty( ::oWin:cName, ::cName, 'FONTCOLOR'      )
   ASSIGN FontColor( Val )                INLINE  SetProperty( ::oWin:cName, ::cName, 'FONTCOLOR', Val )

   ACCESS Title INLINE ::oWin:cTitle
   ACCESS Caption INLINE _GetCaption ( ::cName, ::oWin:cName )
   ACCESS Cargo INLINE _ControlCargo( Self )
   ASSIGN Cargo( xVal ) INLINE _ControlCargo( Self, , xVal )

   ACCESS WO INLINE ::oWin:oCargo
   ACCESS WP INLINE ::oWin:oProp

   ACCESS Window INLINE ::oWin
   ACCESS IsWindow INLINE .F.
   ACCESS IsControl INLINE .T.

   METHOD PostMsg( nKey, xPar ) INLINE iif( ::oWin:Action, ( ::oParam:Set( nKey, xPar ), ;
      PostMessage( ::oWin:nHandle, ::WM_nMsgC, nKey, ::nHandle ) ), Nil )
   METHOD Post ( nKey, xPar ) INLINE ::PostMsg( nKey, xPar )
   METHOD SendMsg( nKey, xPar ) INLINE iif( ::oWin:Action, ( ::oParam:Set( nKey, xPar ), ;
      SendMessage( ::oWin:nHandle, ::WM_nMsgC, nKey, ::nHandle ) ), Nil )
   METHOD Send ( nKey, xPar ) INLINE ::SendMsg( nKey, xPar )

   METHOD Set() INLINE ( iif( HB_ISOBJECT( ::oWin:oName ), ::oWin:oName:Set( Upper( ::cName ), Self ), ), ;
      iif( HB_ISOBJECT( ::oWin:oHand ), ::oWin:oHand:Set( ::nHandle, Self ), ) )
   METHOD Del() INLINE ( iif( HB_ISOBJECT( ::oWin:oName ), ::oWin:oName:Del( Upper( ::cName ) ), ), ;
      iif( HB_ISOBJECT( ::oWin:oHand ), ::oWin:oHand:Del( ::nHandle ), ) )

   METHOD Get( xName ) INLINE iif( HB_ISCHAR( xName ), ::oWin:oName:Get( Upper( xName ) ), ;
      ::oWin:oHand:Get( xName ) )

   METHOD GetListType() INLINE ::oWin:GetListType()
   METHOD GetObj4Type( cType, lEque ) INLINE ::oWin:GetObj4Type( cType, lEque )
   METHOD GetObj4Name( cName ) INLINE ::oWin:GetObj4Name( cName )
   METHOD SetProp( xKey, xVal ) INLINE ::oWin:oProp:Set( xKey, xVal )
   METHOD GetProp( xKey ) INLINE ::oWin:oProp:Get( xKey )
   METHOD DelProp( xKey ) INLINE ::oWin:oProp:Del( xKey )

   ACCESS Value INLINE _GetValue( , , ::nIndex )
   ASSIGN Value( xVal ) INLINE ( _SetValue( , , xVal, ::nIndex ), ;
      _GetValue( , , ::nIndex ) )

   METHOD SetFocus() INLINE _SetFocus ( ::cName, ::oWin:cName )
   METHOD Refresh() INLINE _Refresh ( ::nIndex )
   METHOD SetSize( y, x, w, h ) INLINE _SetControlSizePos( ::cName, ::oWin:cName, y, x, w, h )

   METHOD Disable( nPos ) INLINE _DisableControl( ::cName, ::oWin:cName, nPos )
   METHOD Enable ( nPos ) INLINE _EnableControl ( ::cName, ::oWin:cName, nPos )
   METHOD Enabled( nPos ) INLINE _IsControlEnabled ( ::cName, ::oWin:cName, nPos )

   METHOD Restore() INLINE ::Show()
   METHOD Show() INLINE _ShowControl ( ::cName, ::oWin:cName )
   METHOD Hide() INLINE _HideControl ( ::cName, ::oWin:cName )

   _METHOD DoEvent ( Key, nHandle )

   // Destructor
   METHOD Destroy() INLINE ( ::Del(), ;
      ::oCargo := iif( HB_ISOBJECT( ::oCargo ), ::oCargo:Destroy(), Nil ), ;
      ::oEvent := iif( HB_ISOBJECT( ::oEvent ), ::oEvent:Destroy(), Nil ), ;
      ::oOnEventBlock := iif( HB_ISOBJECT( ::oOnEventBlock ), ::oOnEventBlock:Destroy(), Nil ), ;
      ::oUserKeys := iif( HB_ISOBJECT( ::oUserKeys ), ::oUserKeys:Destroy(), Nil ), ;
      ::oName := iif( HB_ISOBJECT( ::oName ), ::oName:Destroy(), Nil ), ;
      ::oHand := iif( HB_ISOBJECT( ::oHand ), ::oHand:Destroy(), Nil ), ;
      ::nParent := ::nIndex := ::cName := ::cType := ::cVar := ::cChr := NIL, ;
      hmg_DelWindowObject( ::nHandle ), ::nHandle := Nil )

#ifndef __XHARBOUR__
   DESTRUCTOR DestroyObject()
#endif

ENDCLASS
///////////////////////////////////////////////////////////////////////////////

METHOD DoEvent ( Key, nHandle ) CLASS TCnlData

   LOCAL o := iif( hmg_IsWindowObject( nHandle ), hmg_GetWindowObject( nHandle ), Self )

RETURN Do_ControlEventProcedure( ::oEvent:Get( Key ), o:Index, o, Key, ::oParam:Get( Key ) )

#ifndef __XHARBOUR__
METHOD PROCEDURE DestroyObject() CLASS TCnlData

   ::Destroy()

RETURN
#endif
///////////////////////////////////////////////////////////////////////////////
CLASS TGetData INHERIT TCnlData
///////////////////////////////////////////////////////////////////////////////

   PROTECTED:
   VAR oGetBox AS OBJECT

   EXPORTED:
   METHOD New( oWnd, oGet ) INLINE ( ::Super:New( oWnd ), ::oGetBox := oGet, Self ) CONSTRUCTOR

   METHOD Def( nIndex, cName, nHandle, nParent, cType, cVar ) INLINE ( ;
      ::Super:Def( nIndex, cName, nHandle, nParent, cType, cVar ), ;
      ::Set(), hmg_SetWindowObject( ::nHandle, Self ), ;
      Self )

   ACCESS Caption INLINE ::oWin:cName + "." + ::cName
   ACCESS Get INLINE ::oGetBox

   ACCESS VarGet INLINE _GetValue( , , ::nIndex )
   ASSIGN VarPut( xVal ) INLINE ( _SetValue( , , xVal, ::nIndex ), ;
      _GetValue( , , ::nIndex ) )

   METHOD SetKeyEvent( nKey, bKey, lCtrl, lShift, lAlt ) INLINE ::Get:SetKeyEvent( nKey, bKey, lCtrl, lShift, lAlt )
   METHOD SetDoubleClick( bBlock )                       INLINE ::Get:SetKeyEvent( , bBlock )

   METHOD Destroy() INLINE ::oGetBox := ::Super:Destroy()

ENDCLASS

///////////////////////////////////////////////////////////////////////////////
CLASS TStbData INHERIT TCnlData
///////////////////////////////////////////////////////////////////////////////

   EXPORTED:
   METHOD New( oWnd ) INLINE ( ::Super:New( oWnd ), ::oWin:oStatusBar := iif( Empty( ::oWin:oStatusBar ), ;
      Self, ::oWin:oStatusBar ), Self ) CONSTRUCTOR

   METHOD Def( nIndex, cName, nHandle, nParent, cType, cVar ) INLINE ( ;
      ::Super:Def( nIndex, cName, nHandle, nParent, cType, cVar ), ;
      ::Set(), hmg_SetWindowObject( ::nHandle, Self ), ;
      Self )

   METHOD Say ( cText, nItem ) INLINE _SetItem( ::cName, ::oWin:cName, hb_defaultValue( nItem, 1 ), ;
      hb_defaultValue( cText, '' ) )

   METHOD Icon ( cIcon, nItem ) INLINE SetStatusItemIcon( ::nHandle, hb_defaultValue( nItem, 1 ), cIcon )

   METHOD Width ( nItem, nWidth ) INLINE iif( HB_ISNUMERIC( nWidth ) .AND. nWidth > 0, ;
      _SetStatusWidth ( ::oWin:cName, hb_defaultValue( nItem, 1 ), nWidth ), ;
      _GetStatusItemWidth( ::oWin:nHandle, hb_defaultValue( nItem, 1 ) ) )

   METHOD Action( nItem, bBlock ) INLINE _SetStatusItemAction( hb_defaultValue( nItem, 1 ), bBlock, ;
      ::oWin:nHandle )

ENDCLASS

///////////////////////////////////////////////////////////////////////////////
CLASS TTsbData INHERIT TCnlData
///////////////////////////////////////////////////////////////////////////////

   PROTECTED:
   VAR oTBrowse AS OBJECT

   EXPORTED:
   METHOD New( oWnd, oTsb ) INLINE ( ::Super:New( oWnd ), ::oTBrowse := oTsb, Self ) CONSTRUCTOR

   METHOD Def( nIndex, cName, nHandle, nParent, cType, cVar ) INLINE ( ;
      ::Super:Def( nIndex, cName, nHandle, nParent, cType, cVar ), ;
      ::Set(), hmg_SetWindowObject( ::nHandle, Self ), ;
      Self )

   ACCESS Caption INLINE ::oWin:cName + "." + ::cName
   ACCESS Tsb INLINE ::oTBrowse

   METHOD Enable () INLINE ::oTBrowse:lEnabled := .T.
   METHOD Disable() INLINE ::oTBrowse:lEnabled := .F.
   METHOD Enabled ( lEnab ) INLINE ::oTBrowse:Enabled( lEnab )
   METHOD Refresh( lPaint ) INLINE ::oTBrowse:Refresh( lPaint )
   METHOD Restore() INLINE ::oTBrowse:Show()
   METHOD Show() INLINE ::oTBrowse:Show()
   METHOD Hide() INLINE ::oTBrowse:Hide()
   METHOD SetFocus() INLINE ::oTBrowse:SetFocus()

   METHOD OnEvent( nMsg, wParam, lParam ) INLINE ::Tsb:HandleEvent( nMsg, wParam, lParam )
   METHOD Destroy() INLINE ::oTBrowse := ::Super:Destroy()

ENDCLASS

///////////////////////////////////////////////////////////////////////////////
CLASS TWmEData
///////////////////////////////////////////////////////////////////////////////

   PROTECTED:
   VAR oObj AS OBJECT
   VAR aMsg INIT hb_Hash()
   VAR lMsg INIT .F.

   EXPORTED:
   METHOD New( o ) INLINE ( ::oObj := o, Self ) CONSTRUCTOR

   ACCESS IsEvent INLINE ::lMsg
   METHOD Set( nMsg, Block ) INLINE ( hb_HSet ( ::aMsg, nMsg, Block ), ::lMsg := Len( ::aMsg ) > 0 )
   METHOD Get( nMsg, Def ) INLINE hb_HGetDef( ::aMsg, nMsg, Def )
   METHOD Del( nMsg ) INLINE ( hb_HDel ( ::aMsg, nMsg ), ::lMsg := Len( ::aMsg ) > 0 )

   _METHOD Do( nMsg, wParam, lParam )
   _METHOD Destroy()

ENDCLASS
///////////////////////////////////////////////////////////////////////////////

METHOD Do( nMsg, wParam, lParam ) CLASS TWmEData

   LOCAL o, r, b := ::Get( nMsg )

   IF HB_ISBLOCK( b )
      o := ::oObj
      IF o:IsWindow
         r := Do_WindowEventProcedure ( b, o:Index, o, nMsg, wParam, lParam ) // {|ow,nm,wp,lp| ... }
      ELSE
         r := Do_ControlEventProcedure( b, o:Index, o, nMsg, wParam, lParam ) // {|oc,nm,wp,lp| ... }
      ENDIF
   ENDIF

RETURN iif( Empty( r ), 0, 1 )

METHOD Destroy() CLASS TWmEData

   LOCAL i, k

   IF HB_ISHASH( ::aMsg )
      FOR i := 1 TO Len( ::aMsg )
         k := hb_HKeyAt( ::aMsg, i )
         hb_HSet( ::aMsg, k, Nil )
         hb_HDel( ::aMsg, k )
      NEXT
   ENDIF

   ::oObj := ::aMsg := NIL

RETURN NIL

///////////////////////////////////////////////////////////////////////////////
CLASS TKeyData
///////////////////////////////////////////////////////////////////////////////

   PROTECTED:
   VAR oObj AS OBJECT
   VAR aKey INIT hb_Hash()
   VAR lKey INIT .F.

   EXPORTED:
   VAR Cargo

   METHOD New() INLINE ( Self ) CONSTRUCTOR

   METHOD Def( o ) INLINE ( ::Obj := o, Self )

   METHOD Set( Key, Block ) INLINE ( iif( HB_ISHASH( Key ), ::aKey := Key, hb_HSet ( ::aKey, Key, Block ) ), ;
          ::lKey := ( ::Len > 0 ) )
   METHOD Get( Key, Def ) INLINE hb_HGetDef( ::aKey, Key, Def )
   METHOD Del( Key ) INLINE ( iif( ::Len > 0, hb_HDel ( ::aKey, Key ), ), ::lKey := Len( ::aKey ) > 0 )
   METHOD Pos( Key ) INLINE hb_HPos( ::aKey, Key )

   METHOD Do ( Key, p1, p2, p3 ) BLOCK {| Self, Key, p1, p2, p3, b | b := ::Get( Key ), ;
      iif( HB_ISBLOCK( b ), Eval( b, ::oObj, Key, p1, p2, p3 ), Nil ) }

   ACCESS Obj INLINE ::oObj
   ASSIGN Obj( o ) INLINE ::oObj := iif( HB_ISOBJECT( o ), o, Self )
   ACCESS Len INLINE Len( ::aKey )
   ACCESS IsEvent INLINE ::lKey
   ASSIGN KeyUpper( lUpper ) INLINE hb_HCaseMatch( ::aKey, ! Empty( lUpper ) )
   METHOD ISBLOCK( Key ) INLINE HB_ISBLOCK( ::Get( Key ) )
   METHOD Json( cJson )  INLINE iif( HB_ISCHAR( cJson ), ( cJson := SubStr( cJson, At( "{", cJson ) ), ;
                                                           cJson := Left( cJson, RAt( "}", cJson ) ), ;
                                                           ::aKey := hb_jsonDecode( cJson ), Self ), ;
                                                           hb_jsonEncode( ::aKey, !Empty( cJson ) ) )

   _METHOD GetAll( lAll )
   _METHOD Eval( Block )
   _METHOD Sum( Key, xSum )
   _METHOD Destroy()

   ERROR HANDLER ControlAssign

ENDCLASS
///////////////////////////////////////////////////////////////////////////////

METHOD GetAll( lAll ) CLASS TKeyData

   LOCAL aRet := {}

   IF HB_ISLOGICAL( lAll ) .AND. lAll
      ::Eval( {| val | AAdd( aRet, val ) } )
   ELSE
      ::Eval( {| val, Key | AAdd( aRet, { Key, val } ) } )
   ENDIF

RETURN aRet

METHOD Eval( Block ) CLASS TKeyData

   LOCAL i, b := HB_ISBLOCK( Block )
   LOCAL l := HB_ISLOGICAL( Block ) .AND. Block
   LOCAL a := iif( b, NIL, Array( 0 ) )

   FOR i := 1 TO ::Len
      IF b ; Eval( Block, hb_HValueAt( ::aKey, i ), hb_HKeyAt( ::aKey, i ), i )
      ELSEIF l ; AAdd( a, hb_HValueAt( ::aKey, i ) )
      ELSE ; AAdd( a, { hb_HValueAt( ::aKey, i ), hb_HKeyAt( ::aKey, i ), i } )
      ENDIF
   NEXT

RETURN a

METHOD Sum( Key, xSum ) CLASS TKeyData

   LOCAL Sum := ::Get( Key, 0 )

   IF HB_ISNUMERIC( xSum )
      IF HB_ISNUMERIC( sum ) ; Sum += xSum
      ELSE ; Sum := xSum
      ENDIF
      ::Set( Key, sum )
   ELSEIF HB_ISARRAY( xSum )
      IF HB_ISARRAY( sum ) .AND. Len( sum ) == Len( xSum )
         AEval( xSum, {| s, i | Sum[ i ] := iif( HB_ISNUMERIC( s ), Sum[ i ] + s, s ) } )
      ELSE
         Sum := xSum
      ENDIF
      ::Set( Key, sum )
   ENDIF

RETURN NIL

METHOD Destroy() CLASS TKeyData

   LOCAL i, k, o

   IF HB_ISHASH( ::aKey )
      FOR i := 1 TO Len( ::aKey )
         k := hb_HKeyAt( ::aKey, i )
         hb_HSet( ::aKey, k, Nil )
         hb_HDel( ::aKey, k )
      NEXT
   ENDIF

   IF HB_ISOBJECT( ::Cargo ) .AND. ::Cargo:ClassName == ::ClassName
      o := ::Cargo
      IF HB_ISHASH( o:aKey )
         FOR i := 1 TO Len( o:aKey )
            k := hb_HKeyAt( o:aKey, i )
            hb_HSet( o:aKey, k, Nil )
            hb_HDel( o:aKey, k )
         NEXT
      ENDIF
   ENDIF

   ::oObj := ::aKey := ::Cargo := NIL

RETURN NIL

METHOD ControlAssign( xValue ) CLASS TKeyData

   LOCAL cMessage, uRet, lError

   cMessage := __GetMessage()
   lError := .T.

   IF PCount() == 0
      uRet := ::Get( cMessage )
      lError := .F.
   ELSEIF PCount() == 1
      ::Set( SubStr( cMessage, 2 ), xValue )
      uRet := ::Get( cMessage )
      lError := .F.
   ENDIF

   IF lError
      uRet := NIL
      ::MsgNotFound( cMessage )
   ENDIF

RETURN uRet

///////////////////////////////////////////////////////////////////////////////
CLASS TThrData
///////////////////////////////////////////////////////////////////////////////

   PROTECTED:
   VAR oObj AS OBJECT
   VAR aKey INIT hb_Hash()
   VAR lMT INIT .F.

   SYNC METHOD SGD( n, k, v )

   EXPORTED:
   VAR Cargo

   METHOD New() INLINE ( Self ) CONSTRUCTOR

   METHOD Def( o, lVmMt ) INLINE ( ::Obj := o, ::MT := lVmMt, Self )

   METHOD Set( Key, Block ) INLINE iif( ::lMT, ::SGD( 1, Key, Block ), hb_HSet ( ::aKey, Key, Block ) )
   METHOD Get( Key, Def ) INLINE iif( ::lMT, ::SGD( 2, Key, Def ), hb_HGetDef( ::aKey, Key, Def ) )
   METHOD Del( Key ) INLINE iif( ::lMT, ::SGD( 3, Key ), ;
      iif( hb_HHasKey( ::aKey, Key ), hb_HDel ( ::aKey, Key ), Nil ) )

   METHOD Do ( Key, p1, p2, p3 ) BLOCK {| Self, Key, p1, p2, p3, b | b := ::Get( Key ), ;
      iif( HB_ISBLOCK( b ), Eval( b, ::oObj, Key, p1, p2, p3 ), Nil ) }
   ACCESS MT INLINE ::lMT
   ASSIGN MT( lVmMt ) INLINE ::lMT := iif( HB_ISLOGICAL( lVmMt ), lVmMt, .F. )
   ACCESS Obj INLINE ::oObj
   ASSIGN Obj( o ) INLINE ::oObj := iif( HB_ISOBJECT( o ), o, Self )
   ACCESS Len INLINE Len( ::aKey )
   METHOD ISBLOCK( Key ) INLINE HB_ISBLOCK( ::Get( Key ) )

   _METHOD GetAll( lAll )
   _METHOD Eval( Block )
   _METHOD Sum( Key, xSum )
   _METHOD Destroy()

ENDCLASS
///////////////////////////////////////////////////////////////////////////////

METHOD SGD( n, k, v ) CLASS TThrData

   SWITCH n

   CASE 1
      hb_HSet( ::aKey, k, v )
      EXIT
   CASE 2
      RETURN hb_HGetDef( ::aKey, k, v )
   CASE 3
      IF hb_HHasKey( ::aKey, k )
         hb_HDel ( ::aKey, k )
      ENDIF
      EXIT
   CASE 4
      RETURN { hb_HKeyAt( ::aKey, k ), hb_HValueAt( ::aKey, k ) }

   END SWITCH

RETURN NIL

METHOD GetAll( lAll ) CLASS TThrData

   LOCAL aRet := {}

   IF HB_ISLOGICAL( lAll ) .AND. lAll
      ::Eval( {| val | AAdd( aRet, val ) } )
   ELSE
      ::Eval( {| val, Key | AAdd( aRet, { Key, val } ) } )
   ENDIF

RETURN aRet

METHOD Eval( Block ) CLASS TThrData

   LOCAL m, i, b := HB_ISBLOCK( Block )
   LOCAL l := HB_ISLOGICAL( Block ) .AND. Block
   LOCAL a := iif( b, NIL, Array( 0 ) )

   FOR i := 1 TO ::Len
      IF ::lMT
         m := ::SGD( 4, i )
         IF b ; Eval( Block, m[ 2 ], m[ 1 ], i )
         ELSEIF l ; AAdd( a, m[ 2 ] )
         ELSE ; AAdd( a, { m[ 2 ], m[ 1 ], i } )
         ENDIF
      ELSE
         IF b ; Eval( Block, hb_HValueAt( ::aKey, i ), hb_HKeyAt( ::aKey, i ), i )
         ELSEIF l ; AAdd( a, hb_HValueAt( ::aKey, i ) )
         ELSE ; AAdd( a, { hb_HValueAt( ::aKey, i ), hb_HKeyAt( ::aKey, i ), i } )
         ENDIF
      ENDIF
   NEXT

RETURN a

METHOD Sum( Key, xSum ) CLASS TThrData

   LOCAL Sum := ::Get( Key, 0 )

   IF HB_ISNUMERIC( xSum )
      IF HB_ISNUMERIC( sum ) ; Sum += xSum
      ELSE ; Sum := xSum
      ENDIF
      ::Set( Key, sum )
   ELSEIF HB_ISARRAY( xSum )
      IF HB_ISARRAY( sum ) .AND. Len( sum ) == Len( xSum )
         AEval( xSum, {| s, i | Sum[ i ] := iif( HB_ISNUMERIC( s ), Sum[ i ] + s, s ) } )
      ELSE
         Sum := xSum
      ENDIF
      ::Set( Key, sum )
   ENDIF

RETURN NIL

METHOD Destroy() CLASS TThrData

   LOCAL i, k, o

   IF HB_ISHASH( ::aKey )
      FOR i := 1 TO Len( ::aKey )
         k := hb_HKeyAt( ::aKey, i )
         hb_HSet( ::aKey, k, Nil )
         hb_HDel( ::aKey, k )
      NEXT
   ENDIF

   IF HB_ISOBJECT( ::Cargo ) .AND. ::Cargo:ClassName == ::ClassName
      o := ::Cargo
      IF HB_ISHASH( o:aKey )
         FOR i := 1 TO Len( o:aKey )
            k := hb_HKeyAt( o:aKey, i )
            hb_HSet( o:aKey, k, Nil )
            hb_HDel( o:aKey, k )
         NEXT
      ENDIF
   ENDIF

   ::oObj := ::aKey := ::Cargo := ::lMT := NIL

RETURN NIL

*-----------------------------------------------------------------------------*
FUNCTION oWndData( nIndex, cName, nHandle, nParent, cType, cVar )
*-----------------------------------------------------------------------------*
   LOCAL o

   DEFAULT nIndex := 0, ;
      cName := '', ;
      nHandle := 0, ;
      nParent := 0, ;
      cType := '', ;
      cVar := ''

   IF Empty( nIndex ) .OR. Empty( nHandle ) .OR. Empty( cName )
      RETURN o
   ENDIF

   o := TWndData():New():Def( nIndex, cName, nHandle, nParent, cType, cVar )

RETURN o

*-----------------------------------------------------------------------------*
FUNCTION oCnlData( nIndex, cName, nHandle, nParent, cType, cVar, oWin )
*-----------------------------------------------------------------------------*
   LOCAL o, ob

   DEFAULT nIndex := 0, ;
      cName := '', ;
      nHandle := 0, ;
      nParent := 0, ;
      cType := '', ;
      cVar := ''

   IF Empty( nIndex ) .OR. Empty( nHandle ) .OR. Empty( nParent ) .OR. Empty( cName ) ; RETURN o
   ENDIF

   DEFAULT oWin := hmg_GetWindowObject( nParent )

   IF HB_ISOBJECT( oWin )

      IF cType == 'TBROWSE'
         ob := _HMG_aControlIds[ nIndex ]
         o := TTsbData():New( oWin, ob ):Def( nIndex, cName, nHandle, nParent, cType, cVar )
      ELSEIF cType == 'GETBOX'
         ob := _HMG_aControlHeadClick[ nIndex ]
         o := TGetData():New( oWin, ob ):Def( nIndex, cName, nHandle, nParent, cType, cVar )
      ELSEIF cType == 'STATUSBAR'
         o := TStbData():New( oWin ):Def( nIndex, cName, nHandle, nParent, cType, cVar )
      ELSE
         o := TCnlData():New( oWin ):Def( nIndex, cName, nHandle, nParent, cType, cVar )
      ENDIF

   ENDIF

RETURN o

*-----------------------------------------------------------------------------*
FUNCTION oKeyData( Obj, Event )
*-----------------------------------------------------------------------------*
   LOCAL o

   IF HB_ISNIL ( Event ) ; o := TKeyData():New():Def( Obj )
   ELSEIF HB_ISLOGICAL( Event ) .AND. Event ; o := TWmEData():New( Obj )
   ELSE ; o := TThrData():New():Def( Obj, hb_mtvm() )
   ENDIF

RETURN o

#ifdef __XHARBOUR__
*-----------------------------------------------------------------------------*
STATIC FUNCTION hb_HGetDef( hHash, xKey, xDef )
*-----------------------------------------------------------------------------*
   LOCAL nPos := HGetPos( hHash, xKey )

RETURN iif( nPos > 0, HGetValueAt( hHash, nPos ), xDef )

#endif

#endif
