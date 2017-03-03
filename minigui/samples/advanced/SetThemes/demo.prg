/*
 * Author: P.Chornyj <myorg63@mail.ru>
 *
 * Updated: Grigory Filatov, 2007-03-15
 *          Józef Rudnicki, 2007-10-18
*/

#include "minigui.ch"

#define BM_WIDTH        1
#define BM_HEIGHT       2
#define	BM_BITSPIXEL    3

#define OBJ_PEN         1
#define OBJ_BRUSH       2
#define OBJ_DC          3
#define OBJ_METADC	4
#define OBJ_PAL		5
#define OBJ_FONT	6
#define OBJ_BITMAP	7  
#define OBJ_REGION      8
#define OBJ_METAFILE    9
#define OBJ_MEMDC       10
#define OBJ_EXTPEN      11
#define OBJ_ENHMETADC   12
#define OBJ_ENHMETAFILE 13
#define OBJ_COLORSPACE  14

#define WM_PAINT        15

#define CLR_OFFICE2003_BLUE   1
#define CLR_OFFICE2003_GREEN  2
#define CLR_OFFICE2003_ORANGE 3
#define CLR_OFFICE2003_SILVER 4
#define CLR_AZURE             5
#define CLR_DARKBLUE          6
#define CLR_LIGHTGREEN        7

MEMVAR aColors
*--------------------------
PROCEDURE main()
*--------------------------
  PUBLIC aColors

  SET DATE GERMAN

  SetThemes( CLR_OFFICE2003_BLUE, FALSE )

  SET EVENTS FUNCTION TO MYEVENTS

  DEFINE WINDOW Form_Main ;
		AT 0,0 ;
		WIDTH 320 HEIGHT 440 ;
		TITLE 'Set Themes sample by P.Chornyj <myorg63@mail.ru>' ;
		ICON "demo.ico" ;
		MAIN ;
		MINWIDTH 320 ;
		MINHEIGHT 220 ;
		ON INIT SetColorMenu( aColors, IF( IsWinNT(), FALSE, TRUE ) ) ;
		ON RELEASE ExitGradientFunc()

		DEFINE MAIN MENU
			DEFINE POPUP "&File" 
				MENUITEM "E&xit" ACTION Form_Main.Release
			END POPUP

			DEFINE POPUP "&Themes" 
				MENUITEM "OFFICE_2003 BLUE"   ACTION SetThemes( CLR_OFFICE2003_BLUE )
				MENUITEM "OFFICE_2003 GREEN"  ACTION SetThemes( CLR_OFFICE2003_GREEN )
				MENUITEM "OFFICE_2003 ORANGE" ACTION SetThemes( CLR_OFFICE2003_ORANGE )
				MENUITEM "OFFICE_2003 SILVER" ACTION SetThemes( CLR_OFFICE2003_SILVER )
				SEPARATOR
				MENUITEM "AZURE"         ACTION SetThemes( CLR_AZURE )
				MENUITEM "DARK BLUE"     ACTION SetThemes( CLR_DARKBLUE )
				MENUITEM "LIGHT GREEN"   ACTION SetThemes( CLR_LIGHTGREEN )
			END POPUP
		END MENU
// JR
                DEFINE STATUSBAR FONT "Tahoma" SIZE 10
                   STATUSITEM "Click here to change colors" ACTION SbAction() BACKCOLOR nRGB2Arr( aColors[1] )
                   STATUSDATE BACKCOLOR nRGB2Arr( aColors[1] )
                   CLOCK BACKCOLOR nRGB2Arr( aColors[1] )
                END STATUSBAR
// -----------
	END WINDOW
 
	CENTER WINDOW   Form_Main
	ACTIVATE WINDOW Form_Main

RETURN 

PROCEDURE SetColorMenu( aColors, lSubMenu )
*******************************************
  Local aColor := { GetRed( aColors[1] ),;
                    GetGreen( aColors[1] ),;
                    GetBlue( aColors[1] ) }

  _ColorMenu( _HMG_MainHandle, aColor, lSubMenu )

RETURN

FUNCTION MyEvents ( hWnd, nMsg, wParam, lParam )
************************************************
  LOCAL result := 0
  LOCAL dc, ps

  DO CASE
  CASE nMsg=WM_PAINT
    dc := BeginPaint( hWnd, @ps )
    OnDraw( dc )
    EndPaint( hWnd, ps )

  OTHERWISE
    result := Events( hWnd, nMsg, wParam, lParam )

  ENDCASE

RETURN result

// JR
FUNCTION MyGetControlHandle( cControlName )
*******************************************
  Local lp

  lp := AScan( _HMG_aControlNames, cControlName )
  IF lp > 0
    lp := _HMG_aControlHandles [lp]
  ENDIF

RETURN lp

// JR
FUNCTION SetButtonColor( aColors, cButton )
*******************************************
  Local lp

  IF cButton == NIL
    lp := AScan( _HMG_aControlType, 'OBUTTON' )
  ELSE
    lp := AScan( _HMG_aControlNames, cButton )
  ENDIF
  IF lp>0
    _HMG_aControlBkColor [lp] := nRGB2Arr( aColors[1] )
  ENDIF

RETURN Nil

PROCEDURE OnDraw( param )	// modified
*************************
  LOCAL dc := iif( GetObjectType( param ) == OBJ_DC, param, GetDC( param ) )

// names of resources
  LOCAL aPictures := {"DB_ADD","DB_REMOVE","SORT_BY_DATE","SORT_BY_NAME","STATISTICS"}
  LOCAL brush, wndBrush
  LOCAL aSize := BmpSize( "DB_ADD" ), aRect := { 0, 0, 0, 0 }
  LOCAL dx, dy, i, cTekst

  IF ( GetObjectType( param ) <> OBJ_DC )
    GetClientRect( param, @aRect )
  ELSE
    GetClientRect( GetWindowFromDC( param ), @aRect )
  ENDIF

  dx := aRect[3] - aRect[1]
  dy := aRect[4] - aRect[2]

  wndBrush := CreateSolidBrush( GetRed( aColors[1] ), GetGreen( aColors[1] ), GetBlue( aColors[1] ) )
  brush := CreateGradientBrush( NIL, aSize[BM_WIDTH]+10, aSize[BM_HEIGHT]+10, aColors[2], aColors[3], TRUE )

  FillRect( dc, 0, 0, dx, aSize[BM_HEIGHT]+10, brush )      // menu
  FillRect( dc, 0, aSize[BM_HEIGHT]+10, dx, dy, wndBrush )  // window

  DeleteObject( wndBrush ) 
  DeleteObject( brush )

  FOR i := 1 TO Len( aPictures )
    cTekst:='Button_'+alltrim(str(i))
    if ! IsControlDefined(&cTekst, Form_Main)
      @ 0, 5 + ( aSize[BM_WIDTH] + 15)*(i-1) ;
        BUTTONEX &cTekst PARENT Form_Main ;
        WIDTH aSize[BM_WIDTH]+10 HEIGHT aSize[BM_HEIGHT]+10 ;
        PICTURE (aPictures[i]) TOOLTIP StrTran(aPictures[i],'_',' ') ;
        ACTION MsgInfo( StrTran(This.Name,'_',' ')+' is clicked!', 'Pressed!' )
    endif
    SetButtonColor( aColors, cTekst )
  NEXT

  IF ( GetObjectType( param ) <> OBJ_DC )
    ReleaseDC( dc )
  ENDIF

RETURN

FUNCTION SetThemes( theme, bInvalidate )	// modified
****************************************
  LOCAL aColors_Office2003Blue   := { RGB(159, 191, 236), RGB(159, 191, 236), RGB(54, 102, 187) }
  LOCAL aColors_Office2003Green  := { RGB(234, 240, 207), RGB(234, 240, 207), RGB(178, 193, 140) }
  LOCAL aColors_Office2003Orange := { RGB(251, 230, 148), RGB(251, 230, 148), RGB(239, 150, 21) }
  LOCAL aColors_Office2003Silver := { RGB(225, 226, 236), RGB(225, 226, 236), RGB(150, 148, 178) }
  LOCAL aColors_Azure      := { RGB(222, 218, 202), RGB(222, 218, 202), RGB(192, 185, 154) }
  LOCAL aColors_DarkBlue   := { RGB(89, 135, 214), RGB(89, 135, 214), RGB(4, 57, 148) }, h
  LOCAL aColors_LightGreen := { RGB(235, 245, 214), RGB(235, 245, 214), RGB(195, 224, 133) }
  LOCAL aColorsTable := { ;
                          aColors_Office2003Blue,;
                          aColors_Office2003Green,;
                          aColors_Office2003Orange,;
                          aColors_Office2003Silver,;
                          aColors_Azure,;
                          aColors_DarkBlue,;
                          aColors_LightGreen;
                        }  
  DEFAULT bInvalidate TO TRUE

  IF ValType( theme ) == "N"
    IF ( theme >= 1 .AND. theme <= Len( aColorsTable ) )
      aColors := aColorsTable[ theme ]
      SetColorMenu( aColors, IF( IsWinNT(), FALSE, TRUE ) )
// JR
      SetButtonColor( aColors )
    IF ( h := MyGetControlHandle( 'StatusBar' ) ) > 0
      SetSbBkColor( h, nRGB2Arr( aColors[1] ) )
    ENDIF
// --------
    ENDIF

    IF ( bInvalidate )
      InvalidateRect( _HMG_MainHandle, 0 )
    ENDIF
  ENDIF

RETURN theme

FUNCTION SetSbBkColor( ParentHandle, aColor )
*********************************************
  LOCAL h, i

  FOR EACH h In _HMG_aControlContainerHandle
#ifndef __XHARBOUR__
    i := h:__enumIndex()
#else
    i := hb_enumindex()
#endif
    IF _HMG_aControlType [i] == "ITEMMESSAGE" .AND. h == ParentHandle
      _HMG_aControlBkColor [i] := aColor
    ENDIF
  NEXT

RETURN Nil

// JR
FUNCTION SbAction()
*******************
  STATIC nActiveTheme := 1

  IF ++nActiveTheme > CLR_LIGHTGREEN
    nActiveTheme := 1
  ENDIF

  SetThemes( nActiveTheme )

RETURN Nil

// from \SAMPLES\BASIC\BUTTONEX\demo4.prg

#define PBS_NORMAL 1
#define PBS_HOT 2
#define PBS_PRESSED 3
#define PBS_DISABLED 4
#define PBS_DEFAULTED 5

#define ODT_BUTTON 4
#define ODS_SELECTED 1
#define ODS_GRAYED 2
#define ODS_DISABLED 4
#define ODS_CHECKED 8
#define ODS_FOCUS 16
#define ODS_DEFAULT 32
#define ODS_COMBOBOXEDIT 4096
#define ODS_HOTLIGHT 64
#define ODS_INACTIVE 128
#define DFCS_BUTTONPUSH 16
#define DFCS_INACTIVE 256

#define COLOR_HIGHLIGHTTEXT 14
#define COLOR_BTNFACE 15
#define COLOR_BTNSHADOW 16
#define COLOR_GRAYTEXT 17
#define COLOR_BTNTEXT 18
#define COLOR_INACTIVECAPTIONTEXT 19
#define COLOR_BTNHIGHLIGHT 20
#define COLOR_3DDKSHADOW 21
#define COLOR_3DLIGHT 22
#define COLOR_INFOTEXT 23
#define COLOR_INFOBK 24
#define COLOR_HOTLIGHT 26
#define COLOR_GRADIENTACTIVECAPTION 27
#define COLOR_GRADIENTINACTIVECAPTION 28
#define COLOR_DESKTOP COLOR_BACKGROUND
#define COLOR_3DFACE COLOR_BTNFACE
#define COLOR_3DSHADOW COLOR_BTNSHADOW
#define COLOR_3DHIGHLIGHT COLOR_BTNHIGHLIGHT
#define COLOR_3DHILIGHT COLOR_BTNHIGHLIGHT
#define COLOR_BTNHILIGHT COLOR_BTNHIGHLIGHT

#define DT_TOP 0
#define DT_LEFT 0
#define DT_CENTER 1
#define DT_RIGHT 2
#define DT_VCENTER 4
#define DT_BOTTOM 8
#define DT_SINGLELINE 32

#define DFCS_PUSHED 512
#define DFCS_CHECKED 1024
#define DFCS_TRANSPARENT 2048
#define DFCS_HOT 4096
#define DFCS_ADJUSTRECT 8192
#define DFCS_FLAT 16384
#define DFCS_MONO 32768
#define TRANSPARENT   1

#define DST_COMPLEX          0
#define DST_TEXT             1
#define DST_PREFIXTEXT       2
#define DST_ICON             3
#define DST_BITMAP           4
// State type
#define DSS_NORMAL           0
#define DSS_UNION           16  // Gray string appearance
#define DSS_DISABLED        32
#define DSS_MONO           128
#define DSS_HIDEPREFIX     512
#define DSS_PREFIXONLY    1024
#define DSS_RIGHT        32768
/*
 * Owner draw actions
 */
#define ODA_DRAWENTIRE    1
#define ODA_SELECT        2
#define ODA_FOCUS         4
#define WM_COMMAND      0x0111
#define WM_SETFOCUS       7
#define WM_DRAWITEM      43
#define WM_LBUTTONDOWN  513
#define WM_MOUSELEAVE   675
#define WM_MOUSEMOVE    512

/* Ascpects for owner butons */

#define OBT_HORIZONTAL    0
#define OBT_VERTICAL      1
#define OBT_LEFTTEXT      2
#define OBT_UPTEXT        4
#define OBT_HOTLIGHT      8
#define OBT_FLAT          16
#define OBT_NOTRANSPARENT 32
#define OBT_NOXPSTYLE     64
#define OBT_ADJUST       128

#define BS_NOTIFY           0x00004000
#define BS_PUSHBUTTON       0x00000000
#define BS_FLAT             0x00008000
#define BS_BITMAP           0x00000080
#define WS_TABSTOP          0x00010000
#define WS_VISIBLE          0x10000000
#define WS_CHILD            0x40000000

* HMG 1.0 Experimental Build 9a (JK)
* (C) 2005 Jacek Kubica <kubica@wssk.wroc.pl>
/*
FUNCTION OwnButtonPaint(  pdis )	// modified
********************************
Local hDC, itemState, itemAction, i, rgbTrans, hWnd, lFlat, lNotrans
Local oldBkMode, oldTextColor , hOldFont, hBrush,nFreeSpace:=0
Local x1:=0, y1:=0, x2:=0, y2:=0, xp1:=0, yp1:=0, xp2:=0, yp2:=0
Local aBmp:={},aMetr:={},aBtnRc:={}
LOCAL lDisabled, lSelected, lFocus, lDrawEntire, loFocus, loSelect
LOCAL hTheme, nStyle, lnoxpstyle:=.f.
LOCAL pozYpic:=0, pozYtext:=0, xPoz:=0, dState:=0
Local nCRLF, lXPThemeActive := .f.

   hDC := GETOWNBTNDC( pdis )

   if empty( hDC ) .or. hDC == 0
      return ( 1 )
   endif

   IF GETOWNBTNCTLTYPE( pdis ) <> ODT_BUTTON
      return ( 1 )
   endif

   itemAction := GETOWNBTNITEMACTION ( pdis )
   lDrawEntire := AND( itemAction, ODA_DRAWENTIRE ) == ODA_DRAWENTIRE
   loFocus := AND( itemAction, ODA_FOCUS ) == ODA_FOCUS
   loSelect := AND( itemAction, ODA_SELECT ) == ODA_SELECT

   if ! lDrawEntire  .and. ! loFocus .and. ! loSelect
      return ( 1 )
   endif

   hWnd := GETOWNBTNHANDLE( pdis )
   aBtnRc := GETOWNBTNRECT( pdis )
   itemState := GETOWNBTNSTATE( pdis )

   i := ascan ( _HMG_aControlHandles , hWnd )
   if ( i <= 0 .or. _HMG_aControlType[ i ] <> "OBUTTON" )
      return ( 1 )
   endif

   nCRLF := CountIt( _HMG_aControlCaption[ i ] ) + 1
   lDisabled := AND( itemState, ODS_DISABLED ) == ODS_DISABLED
   lSelected := AND( itemState, ODS_SELECTED ) == ODS_SELECTED
   lFocus := AND( itemState, ODS_FOCUS ) == ODS_FOCUS
   lFlat := AND( _HMG_aControlSpacing [ i ], OBT_FLAT ) == OBT_FLAT
   lNotrans := AND( _HMG_aControlSpacing [ i ], OBT_NOTRANSPARENT ) == OBT_NOTRANSPARENT
   lnoxpstyle := AND( _HMG_aControlSpacing [ i ], OBT_NOXPSTYLE ) == OBT_NOXPSTYLE

   if ! lNotrans
      rgbTrans := NIL
   else

      if ! EMPTY( _HMG_aControlBkColor [ i ] ) .and. ! lXPThemeActive
         rgbTrans := RGB( _HMG_aControlBkColor [ i, 1 ], _HMG_aControlBkColor [ i, 2 ], _HMG_aControlBkColor [ i, 3 ] )
      else
         rgbTrans := GetSysColor ( COLOR_BTNFACE )
      endif

   endif

   hOldFont := SelectObject( hDC, _HMG_aControlFontHandle [ i ] )
   aMetr := GetTextMetric( hDC )
   oldBkMode := SetBkMode( hDC, TRANSPARENT )
   oldTextColor := SetTextColor( hDC, GetRed ( GetSysColor ( COLOR_BTNTEXT ) ) , GetGreen ( GetSysColor ( COLOR_BTNTEXT ) ) , GetBlue ( GetSysColor ( COLOR_BTNTEXT ) ) )

   if ! lDisabled

      if EMPTY( _HMG_aControlFontColor [ i ] )
         SetTextColor( hDC, GetRed ( GetSysColor ( COLOR_BTNTEXT ) ) , GetGreen ( GetSysColor ( COLOR_BTNTEXT ) ) , GetBlue ( GetSysColor ( COLOR_BTNTEXT ) ) )
      else
         SetTextColor( hDC, _HMG_aControlFontColor [ i, 1 ], _HMG_aControlFontColor [ i, 2 ], _HMG_aControlFontColor [ i, 3 ] )
      endif

      if ! EMPTY( _HMG_aControlBkColor [ i ] ) .and. ! lXPThemeActive

         // paint button background
         if lSelected 
           FillGradient( hDC, aBtnRc[ 2 ], aBtnRc[ 1 ], aBtnRc[ 3 ], aBtnRc[ 3 ], .T.,;
                         aColors[3],aColors[2])
         elseif ! ( _HMG_aControlRangeMax [ i ] == 1 )
           FillGradient( hDC, aBtnRc[ 2 ], aBtnRc[ 1 ], aBtnRc[ 4 ], aBtnRc[ 3 ], .T.,;
                         aColors[2],aColors[3])
         else
           FillGradient( hDC, aBtnRc[ 2 ], aBtnRc[ 1 ], aBtnRc[ 4 ], aBtnRc[ 3 ], .T.,;
                         aColors[3],aColors[2])
         endif

      endif

   endif

   if _HMG_aControlMiscData1 [ i ] == 0  .and. ! EMPTY( _HMG_aControlBrushHandle [ i ] )
      aBmp := GetBitmapSize( _HMG_aControlBrushHandle [ i ] )
   elseif  _HMG_aControlMiscData1 [ i ] == 1  .and. ! EMPTY( _HMG_aControlBrushHandle [ i ] )
      aBmp := GetIconSize( _HMG_aControlBrushHandle [ i ] )
   endif

   if AND( _HMG_aControlSpacing [ i ], OBT_VERTICAL ) == OBT_VERTICAL

      // vertical text/picture aspect

      x1 := aBtnRc[ 1 ] + 2
      y2 := aMetr[ 1 ]*nCRLF
      y1 := Round( ( aBtnRc[ 4 ] - aBtnRc[ 2 ] - aMetr[ 1 ] ) / 2, 0 )
      x2 := aBtnRc[ 3 ] - 2

      yp1 := Round( y1 / 2, 0 )
      xp2 := IIF( ! EMPTY( aBmp ), aBmp[ 1 ], 0 ) // picture width
      yp2 := IIF( ! EMPTY( aBmp ), aBmp[ 2 ], 0 ) // picture height
      xp1 := ROUND( ( aBtnRc[ 3 ] / 2 ) - ( xp2 / 2 ), 0 )


      If AT( CRLF, _HMG_aControlCaption[ i ] ) <= 0
         nFreeSpace := ROUND( ( aBtnRc[ 4 ] - 4 - ( aMetr[ 4 ] + yp2 ) ) / 3, 0 )
         nCRLF:=1
      else
         y1 := max( ( ( aBtnRc[ 4 ] ) / 2 ) - ( nCRLF * aMetr[ 1 ] ) / 2, 1 )
         nFreeSpace := ROUND( ( aBtnRc[ 4 ] - 4 - ( y2 + yp2 ) ) / 3, 0 )
      endif

      if !EMPTY( _HMG_aControlCaption[ i ] )  // button has caption

        If !EMPTY( _HMG_aControlBrushHandle [ i ] )
           if !( AND( _HMG_aControlSpacing [ i ], OBT_UPTEXT ) == OBT_UPTEXT ) // upper text aspect not set
              pozYpic := max( aBtnRc[ 2 ] + nFreeSpace, 5 )
              pozYtext := aBtnRc[ 2 ] + IIF( ! EMPTY( aBmp ), nFreeSpace, 0 ) + yp2 + IIF( ! EMPTY( aBmp ), nFreeSpace, 0 ) //+ nFreeSpace+2 // +ROUND(aMetr[1]/2,0)
           else
              pozYtext := max( aBtnRc[ 2 ] + nFreeSpace, 5 )
              aBtnRc[ 4 ] := nFreeSpace + ( ( aMetr[ 1 ] ) * nCRLF )   + nFreeSpace
              pozYpic := aBtnRc[ 4 ]
           endif
        else
           pozYpic := 0
           pozYtext := ROUND((aBtnRc[ 4 ] - y2) / 2,0)
        endif

     else  // button without caption

        if ! ( AND( _HMG_aControlSpacing [ i ], OBT_ADJUST ) == OBT_ADJUST )
           pozYpic := Round( ( ( aBtnRc[ 4 ] / 2 ) - ( yp2 / 2 ) ), 0 )
           pozYtext := 0
        else  // strech image
           pozYpic := 1
        endif

     endif

      if ! lDisabled

         if lSelected // vertical selected

            If ! lXPThemeActive
               xp1 ++
               xPoz := 2
               pozYtext ++
               pozYpic ++
            else
               xPoz := 0
            endif

            if ! ( AND( _HMG_aControlSpacing [ i ], OBT_ADJUST ) == OBT_ADJUST )
               DrawGlyph( hDC, xp1, pozYpic , xp2, yp2 , _HMG_aControlBrushHandle [ i ] , rgbTrans , .f., .f. )
               DrawText( hDC, _HMG_aControlCaption[ i ], xPoz , pozYtext-1 , x2,  aBtnRc[ 4 ] , DT_CENTER )
            else
               DrawGlyph( hDC, aBtnRc[ 1 ] + 4, aBtnRc[ 2 ] + 4 , aBtnRc[ 3 ] - 6, aBtnRc[ 4 ] - 6 , _HMG_aControlBrushHandle [ i ] , rgbTrans , .f., .t. )
            endif

         else  // vertical non selected

            if ! ( AND( _HMG_aControlSpacing [ i ], OBT_ADJUST ) == OBT_ADJUST )
               DrawGlyph( hDC, xp1, pozYpic, xp2, yp2 , _HMG_aControlBrushHandle [ i ] , rgbTrans , .f., .f. )
               DrawText( hDC, _HMG_aControlCaption[ i ],  0 , pozYtext-1 , x2,  aBtnRc[ 4 ], DT_CENTER )
            else
               DrawGlyph( hDC, aBtnRc[ 1 ] + 3, aBtnRc[ 2 ] + 3 , aBtnRc[ 3 ] - 6, aBtnRc[ 4 ] - 6 , _HMG_aControlBrushHandle [ i ] , rgbTrans , .f., .t. )
            endif

         endif

      else // vertical disabled

         if ! ( AND( _HMG_aControlSpacing [ i ], OBT_ADJUST ) == OBT_ADJUST )
               DrawGlyph( hDC, xp1, pozYpic, xp2, yp2 , _HMG_aControlBrushHandle [ i ] , , .t., .f. )
            // disabled  vertical
               SetTextColor( hDC, GetRed ( GetSysColor ( COLOR_3DHILIGHT ) ) , GetGreen ( GetSysColor ( COLOR_3DHILIGHT ) ) , GetBlue ( GetSysColor ( COLOR_3DHILIGHT ) ) )
               DrawText( hDC, _HMG_aControlCaption[ i ], 2, pozYtext + 1 , x2, aBtnRc[ 4 ] + 1,  DT_CENTER )
               SetTextColor( hDC, GetRed ( GetSysColor ( COLOR_3DSHADOW ) ) , GetGreen ( GetSysColor ( COLOR_3DSHADOW ) ) , GetBlue ( GetSysColor ( COLOR_3DSHADOW ) ) )
               DrawText( hDC, _HMG_aControlCaption[ i ], 0, pozYtext, x2, aBtnRc[ 4 ],    DT_CENTER )
         else
               DrawGlyph( hDC, aBtnRc[ 1 ] + 4, aBtnRc[ 2 ] + 4 , aBtnRc[ 3 ] - 6, aBtnRc[ 4 ] - 6 , _HMG_aControlBrushHandle [ i ] , , .t., .t. )
         endif

      endif

   else

      if ! EMPTY( _HMG_aControlBrushHandle [ i ] ) // horizontal

         if ! EMPTY( _HMG_aControlCaption[ i ] )

            if ! ( AND( _HMG_aControlSpacing [ i ], OBT_LEFTTEXT ) == OBT_LEFTTEXT )

               xp1 := 5
               xp2 := IIF( ! EMPTY( aBmp ), aBmp[ 1 ], 0 )
               yp2 := IIF( ! EMPTY( aBmp ), aBmp[ 2 ], 0 )
               yp1 := Round( ( ( aBtnRc[ 4 ] / 2 ) - ( yp2 / 2 ) ), 0 )

               x1 := aBtnRc[ 1 ] + xp1 + xp2
               y1 := Round( aBtnRc[ 4 ] / 2, 0 ) - ( aMetr[ 1 ] - 10 )
               x2 := aBtnRc[ 3 ] - 2
               y2 := y1 + aMetr[ 1 ]

            else

               xp1 := aBtnRc[ 3 ] - IIF( ! EMPTY( aBmp ), aBmp[ 1 ], 0 ) - 5
               xp2 := IIF( ! EMPTY( aBmp ), aBmp[ 1 ], 0 )
               yp2 := IIF( ! EMPTY( aBmp ), aBmp[ 2 ], 0 )
               yp1 := Round( ( ( aBtnRc[ 4 ] / 2 ) - ( yp2 / 2 ) ), 0 )


               x1 := 3
               y1 := Round( aBtnRc[ 4 ] / 2, 0 ) - ( aMetr[ 1 ] - 10 )
               x2 := aBtnRc[ 3 ] - xp2
               y2 := y1 + aMetr[ 1 ]

            endif

         else
            x1 := aBtnRc[ 1 ] + xp1 + xp2
            y1 := Round( aBtnRc[ 4 ] / 2, 0 ) - ( aMetr[ 1 ] - 10 )
            x2 := aBtnRc[ 3 ] - 2
            y2 := y1 + aMetr[ 1 ]

            xp2 := IIF( ! EMPTY( aBmp ), aBmp[ 1 ], 0 ) // picture width
            yp2 := IIF( ! EMPTY( aBmp ), aBmp[ 2 ], 0 ) // picture height
            xp1 := ROUND( ( aBtnRc[ 3 ] / 2 ) - ( xp2 / 2 ), 0 )
            yp1 := Round( ( ( aBtnRc[ 4 ] / 2 ) - ( yp2 / 2 ) ), 0 )
         endif

      else

         xp1 := 2
         xp2 := 0
         yp1 := 0
         yp2 := 0

         x1 := aBtnRc[ 1 ] + xp1 + xp2
         y1 := Round( aBtnRc[ 4 ] / 2, 0 ) - ( aMetr[ 1 ] - 10 )
         x2 := aBtnRc[ 3 ] - 2
         y2 := y1 + aMetr[ 1 ]

      endif

      if ! ( AND( _HMG_aControlSpacing [ i ], OBT_ADJUST ) == OBT_ADJUST )
         y1 := max(( ( ( aBtnRc[ 4 ] ) / 2 ) - ( nCRLF * aMetr[ 1 ] ) / 2)-1, 1 )
         y2 := ( aMetr[ 1 ] + aMetr[ 5 ] ) * nCRLF
      else
         pozYpic := 1
      endif

      if ! lDisabled

         if lSelected

            If ! lXPThemeActive
               x1 := x1 + 2
            //   y1 := 3
               xp1 ++
               yp1 ++
            else
            //   y1 := 1
               xPoz := 0
            endif

            if ! ( AND( _HMG_aControlSpacing [ i ], OBT_ADJUST ) == OBT_ADJUST )
               DrawGlyph( hDC, xp1, yp1, xp2, yp2 , _HMG_aControlBrushHandle [ i ] , rgbTrans, .f., .f. )
               DrawText( hDC, _HMG_aControlCaption[ i ], x1, y1 + 1, x2, y1 + y2 , DT_CENTER )
            else
              DrawGlyph( hDC, aBtnRc[ 1 ] + 4, aBtnRc[ 2 ] + 4 , aBtnRc[ 3 ] - 6, aBtnRc[ 4 ] - 6 , _HMG_aControlBrushHandle [ i ] , rgbTrans , .f., .t. )
            endif

         else
            if ! ( AND( _HMG_aControlSpacing [ i ], OBT_ADJUST ) == OBT_ADJUST )
               DrawGlyph( hDC, xp1, yp1, xp2, yp2 , _HMG_aControlBrushHandle [ i ] , rgbTrans , .f., .f. )
               DrawText( hDC, _HMG_aControlCaption[ i ], x1, y1, x2, y1 + y2, DT_CENTER )
            else
              DrawGlyph( hDC, aBtnRc[ 1 ] + 3, aBtnRc[ 2 ] + 3 , aBtnRc[ 3 ] - 6, aBtnRc[ 4 ] - 6 , _HMG_aControlBrushHandle [ i ] , rgbTrans , .f., .t. )
            endif
         endif

      else
         // disabled horizontal
          if ! ( AND( _HMG_aControlSpacing [ i ], OBT_ADJUST ) == OBT_ADJUST )
            DrawGlyph( hDC, xp1, yp1, xp2, yp2 , _HMG_aControlBrushHandle [ i ] , , .t., .f. )
            SetTextColor( hDC, GetRed ( GetSysColor ( COLOR_3DHILIGHT ) ) , GetGreen ( GetSysColor ( COLOR_3DHILIGHT ) ) , GetBlue ( GetSysColor ( COLOR_3DHILIGHT ) ) )
            DrawText( hDC, _HMG_aControlCaption[ i ], x1 + 1, y1 + 1, x2 + 1, y1 + y2 + 1,  DT_CENTER )
            SetTextColor( hDC, GetRed ( GetSysColor ( COLOR_3DSHADOW ) ) , GetGreen ( GetSysColor ( COLOR_3DSHADOW ) ) , GetBlue ( GetSysColor ( COLOR_3DSHADOW ) ) )
            DrawText( hDC, _HMG_aControlCaption[ i ], x1, y1, x2, y1 + y2 ,  DT_CENTER )
         else
            DrawGlyph( hDC, aBtnRc[ 1 ] + 3, aBtnRc[ 2 ] + 3 , aBtnRc[ 3 ] - 6, aBtnRc[ 4 ] - 6 , _HMG_aControlBrushHandle [ i ] , , .t., .t. )
         endif
      endif
   endif

   if ( lSelected .or. lFocus ) .and. ! lDisabled .and. ! lXPThemeActive
      SetTextColor( hDC, GetRed ( GetSysColor ( COLOR_BTNTEXT ) ) , GetGreen ( GetSysColor ( COLOR_BTNTEXT ) ) , GetBlue ( GetSysColor ( COLOR_BTNTEXT ) ) )
      DrawFocusRect( pdis )
   endif

   SelectObject( hDC, hOldFont )
   SetBkMode( hDC, oldBkMode )
   SetTextColor( hDC, oldTextColor )

Return ( 1 )
*/
Static Function CountIt(cText)
******************************
  Local nPoz := 1, nCount := 0

  IF At(CRLF, cText) > 0
    DO WHILE .T.
      nPoz := At(CRLF, cText)
      IF nPoz > 0
        nCount++
        cText := Substr(cText, nPoz+2)
      ELSE
        EXIT
      ENDIF
    ENDDO
  ENDIF

Return nCount


#pragma BEGINDUMP

#include <windows.h>
#include "hbapi.h"

#include "commctrl.h"

/*
 Functions BeginPaint(), EndPaint() from WHAT32.lib
*/

// HDC BeginPaint( HWND hwnd, LPPAINTSTRUCT lpPaint );
// Syntax:
// Local cPS
// BeginPaint( hWnd, @cPS) -> hDC

HB_FUNC( BEGINPAINT )
{
   PAINTSTRUCT pps ;

   hb_retnl( (LONG) BeginPaint( (HWND) hb_parnl( 1 ), &pps ) ) ;
   hb_storclen( (char *) &pps, sizeof(PAINTSTRUCT), 2 );
}

// BOOL EndPaint(  HWND hWnd, CONST PAINTSTRUCT *lpPaint );
// Syntax:
// EndPaint( hWnd, cPS ) -> lSuccess

HB_FUNC( ENDPAINT )
{
   hb_retl( EndPaint( (HWND) hb_parnl( 1 ), (PAINTSTRUCT*) hb_parcx( 2 ) ) );
}

#ifdef __XHARBOUR__
#define HB_PARNI( n, x ) hb_parni( n, x )
#else
#define HB_PARNI( n, x ) hb_parvni( n, x )
#endif

HB_FUNC ( _COLORMENU )
{
	HMENU      iMenu;
	MENUINFO   iMenuInfo ;

	INT   nRed   = HB_PARNI(2,1);
	INT   nGreen = HB_PARNI(2,2);
	INT   nBlue  = HB_PARNI(2,3);
	BOOL  lSubMenu = hb_parl(3);

	iMenu              = GetMenu( (HWND) hb_parnl(1) );
	GetMenuInfo(iMenu, &iMenuInfo);
	iMenuInfo.cbSize   = sizeof(MENUINFO);
	if (lSubMenu)
	{
		iMenuInfo.fMask    = MIM_BACKGROUND | MIM_APPLYTOSUBMENUS;
	}
	else
	{
		iMenuInfo.fMask    = MIM_BACKGROUND;
	}

	iMenuInfo.hbrBack = CreateSolidBrush( RGB(nRed, nGreen, nBlue) );
	SetMenuInfo(iMenu, &iMenuInfo);
	DrawMenuBar((HWND) hb_parnl(1));
}

#pragma ENDDUMP
