
#include "minigui.ch"

#define BP_PUSHBUTTON 1

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


* HMG 1.0 Experimental Build 9a ( JK )
* ( C ) 2005 Jacek Kubica < kubica@wssk .wroc. pl >
//-------------------------------------------------------------\\
FUNCTION OwnButtonPaint( pdis )
//-------------------------------------------------------------\\
   LOCAL hDC, itemState, itemAction, i, rgbTrans, hWnd, lFlat, lNotrans
   LOCAL oldBkMode, hOldFont, nFreeSpace
   LOCAL x1, y1, x2, y2, xp1, yp1, xp2, yp2
   LOCAL aBmp := {}, aMetr, aBtnRc
   LOCAL lDisabled, lSelected, lFocus, lDrawEntire, loFocus, loSelect
   LOCAL nStyle
   LOCAL pozYpic, pozYtext := 0, xPoz
   LOCAL nCRLF, lXPThemeActive := .F.

   LOCAL iObClr, nnnn, aFill1, aFill2

   MEMVAR aButMisc, aOBClr

   hDC := GETOWNBTNDC( pdis )

   IF Empty( hDC )
      RETURN ( 1 )
   ENDIF

   IF GETOWNBTNCTLTYPE( pdis ) <> ODT_BUTTON
      RETURN ( 1 )
   ENDIF

   itemAction := GETOWNBTNITEMACTION ( pdis )
   lDrawEntire := ( AND( itemAction, ODA_DRAWENTIRE ) == ODA_DRAWENTIRE )
   loFocus := ( AND( itemAction, ODA_FOCUS ) == ODA_FOCUS )
   loSelect := ( AND( itemAction, ODA_SELECT ) == ODA_SELECT )

   IF ! lDrawEntire  .AND. ! loFocus .AND. ! loSelect
      RETURN ( 1 )
   ENDIF

   hWnd := GETOWNBTNHANDLE( pdis )
   aBtnRc := GETOWNBTNRECT( pdis )
   itemState := GETOWNBTNSTATE( pdis )

   i := AScan ( _HMG_aControlHandles, hWnd )

   IF ( i <= 0 .OR. _HMG_aControlType[ i ] <> "OBUTTON" )
      RETURN ( 1 )
   ENDIF


   nCRLF := CountIt( _HMG_aControlCaption[ i ] ) + 1
   lDisabled := AND( itemState, ODS_DISABLED ) == ODS_DISABLED
   lSelected := AND( itemState, ODS_SELECTED ) == ODS_SELECTED
   lFocus := AND( itemState, ODS_FOCUS ) == ODS_FOCUS
   lFlat := AND( _HMG_aControlSpacing[ i ], OBT_FLAT ) == OBT_FLAT
   lNotrans := AND( _HMG_aControlSpacing[ i ], OBT_NOTRANSPARENT ) == OBT_NOTRANSPARENT
   //   lnoxpstyle := AND( _HMG_aControlSpacing [ i ], OBT_NOXPSTYLE ) == OBT_NOXPSTYLE


   IF ! lNotrans
      rgbTrans := NIL
   ELSE

      IF ! Empty( _HMG_aControlBkColor[ i ] ) .AND. ! lXPThemeActive
         rgbTrans := RGB( _HMG_aControlBkColor[ i, 1 ], _HMG_aControlBkColor[ i, 2 ], _HMG_aControlBkColor[ i, 3 ] )
      ELSE
         rgbTrans := GetSysColor ( COLOR_BTNFACE )
      ENDIF

   ENDIF


   hOldFont := SelectObject( hDC, _HMG_aControlFontHandle[ i ] )
   aMetr := GetTextMetric( hDC )
   oldBkMode := SetBkMode( hDC, TRANSPARENT )

   iObClr := 1
   aButMisc := { 1, '' }
   IF !Empty( _HMG_aControlMiscData2[ i ] )
      aButMisc := { Val ( Token( _HMG_aControlMiscData2[ i ], ',', 1 ) ), AllTrim( Token( _HMG_aControlMiscData2[ i ], ',', 2 ) ) }
      iObClr := AScan( aOBClr, {| ax| ax[ 1 ] = aButMisc[ 1 ] } )
   ENDIF

   IF lSelected                               // click


   ELSEIF ! ( _HMG_aControlRangeMax[ i ] == 1 )      //normal
      aFill1 := aOBClr[ iObClr, 3 ]
      aFill2 := aOBClr[ iObClr, 4 ]

      IF aOBClr[ iObClr, 2 ] = 1         // Type fill grag vert 1
         FillGradient( hDC, aBtnRc[ 2 ], aBtnRc[ 1 ], aBtnRc[ 4 ], aBtnRc[ 3 ], .T., RGB( aFill1[ 1 ], aFill1[ 2 ], aFill1[ 3 ] ), RGB( aFill2[ 1 ], aFill2[ 2 ], aFill2[ 3 ] ) )
      ELSEIF aOBClr[ iObClr, 2 ] = 2         // Type fill grag vert 2
         FillGradient( hDC, aBtnRc[ 2 ], aBtnRc[ 1 ], aBtnRc[ 4 ] / 2, aBtnRc[ 3 ], .T., RGB( aFill1[ 1 ], aFill1[ 2 ], aFill1[ 3 ] ), RGB( aFill2[ 1 ], aFill2[ 2 ], aFill2[ 3 ] )  )
         FillGradient( hDC, aBtnRc[ 4 ] / 2, aBtnRc[ 1 ], aBtnRc[ 4 ], aBtnRc[ 3 ], .T., RGB( aFill2[ 1 ], aFill2[ 2 ], aFill2[ 3 ] ), RGB( aFill1[ 1 ], aFill1[ 2 ], aFill1[ 3 ] )  )
      ELSEIF aOBClr[ iObClr, 2 ] = 3         // Type fill grag horiz 1
         FillGradient( hDC, aBtnRc[ 2 ], aBtnRc[ 1 ], aBtnRc[ 4 ], aBtnRc[ 3 ], .F., RGB( aFill1[ 1 ], aFill1[ 2 ], aFill1[ 3 ] ), RGB( aFill2[ 1 ], aFill2[ 2 ], aFill2[ 3 ] ) )
      ELSEIF aOBClr[ iObClr, 2 ] = 4         // Type fill grag horiz 2
         FillGradient( hDC, aBtnRc[ 2 ], aBtnRc[ 1 ], aBtnRc[ 4 ], aBtnRc[ 3 ] / 2, .F., RGB( aFill1[ 1 ], aFill1[ 2 ], aFill1[ 3 ] ), RGB( aFill2[ 1 ], aFill2[ 2 ], aFill2[ 3 ] )  )
         FillGradient( hDC, aBtnRc[ 2 ], aBtnRc[ 3 ] / 2, aBtnRc[ 4 ], aBtnRc[ 3 ], .F., RGB( aFill2[ 1 ], aFill2[ 2 ], aFill2[ 3 ] ), RGB( aFill1[ 1 ], aFill1[ 2 ], aFill1[ 3 ] )  )
      ENDIF

      _HMG_aControlFontColor[ i ] := aOBClr[ iObClr, 7 ]

      IF !Empty( aButMisc[ 2 ] )     //Picture box

         DeleteObject ( _hmg_aControlBrushhandle[ i ] )
         nnnn := _SetBtnPicture (  hDC, _HMG_aControlPicture[ i ] )
         _hmg_aControlBrushHandle[ i ] := nnnn

      ENDIF

      IF aOBClr[ iObClr, 9 ] = 1
         rectdraw( hWnd, aBtnRc[ 1 ] -1, aBtnRc[ 2 ] -1, aBtnRc[ 4 ] + 1, aBtnRc[ 3 ] + 1, aOBClr[ iObClr, 10 ], 1, WHITE, .F. )
      ELSEIF aOBClr[ iObClr, 9 ] = 2
         roundrectdraw( hWnd, aBtnRc[ 1 ] -1, aBtnRc[ 2 ] -1, aBtnRc[ 4 ] + 1, aBtnRc[ 3 ] + 1, 8, 8, aOBClr[ iObClr, 10 ], 1, WHITE, .F. )
      ENDIF

   ELSE                                //over
      aFill1 := aOBClr[ iObClr, 5 ]
      aFill2 := aOBClr[ iObClr, 6 ]

      IF aOBClr[ iObClr, 2 ] = 1         // Type fill grag vert 1
         FillGradient( hDC, aBtnRc[ 2 ], aBtnRc[ 1 ], aBtnRc[ 4 ], aBtnRc[ 3 ], .T., RGB( aFill1[ 1 ], aFill1[ 2 ], aFill1[ 3 ] ), RGB( aFill2[ 1 ], aFill2[ 2 ], aFill2[ 3 ] ) )
      ELSEIF aOBClr[ iObClr, 2 ] = 2         // Type fill grag vert 2
         FillGradient( hDC, aBtnRc[ 2 ], aBtnRc[ 1 ], aBtnRc[ 4 ] / 2, aBtnRc[ 3 ], .T., RGB( aFill1[ 1 ], aFill1[ 2 ], aFill1[ 3 ] ), RGB( aFill2[ 1 ], aFill2[ 2 ], aFill2[ 3 ] )  )
         FillGradient( hDC, aBtnRc[ 4 ] / 2, aBtnRc[ 1 ], aBtnRc[ 4 ], aBtnRc[ 3 ], .T., RGB( aFill2[ 1 ], aFill2[ 2 ], aFill2[ 3 ] ), RGB( aFill1[ 1 ], aFill1[ 2 ], aFill1[ 3 ] )  )
      ELSEIF aOBClr[ iObClr, 2 ] = 3         // Type fill grag horiz 1
         FillGradient( hDC, aBtnRc[ 2 ], aBtnRc[ 1 ], aBtnRc[ 4 ], aBtnRc[ 3 ], .F., RGB( aFill1[ 1 ], aFill1[ 2 ], aFill1[ 3 ] ), RGB( aFill2[ 1 ], aFill2[ 2 ], aFill2[ 3 ] ) )
      ELSEIF aOBClr[ iObClr, 2 ] = 4         // Type fill grag horiz 2
         FillGradient( hDC, aBtnRc[ 2 ], aBtnRc[ 1 ], aBtnRc[ 4 ], aBtnRc[ 3 ] / 2, .F., RGB( aFill1[ 1 ], aFill1[ 2 ], aFill1[ 3 ] ), RGB( aFill2[ 1 ], aFill2[ 2 ], aFill2[ 3 ] )  )
         FillGradient( hDC, aBtnRc[ 2 ], aBtnRc[ 3 ] / 2, aBtnRc[ 4 ], aBtnRc[ 3 ], .F., RGB( aFill2[ 1 ], aFill2[ 2 ], aFill2[ 3 ] ), RGB( aFill1[ 1 ], aFill1[ 2 ], aFill1[ 3 ] )  )
      ENDIF

      _HMG_aControlFontColor[ i ] := aOBClr[ iObClr, 8 ]

      IF !Empty( aButMisc[ 2 ] )
         DeleteObject ( _hmg_aControlBrushhandle[ i ] )
         nnnn := _SetBtnPicture (  hDC, aButMisc[ 2 ] )
         _hmg_aControlBrushHandle[ i ] := nnnn
      ENDIF
      IF aOBClr[ iObClr, 9 ] = 1
         rectdraw( hWnd, aBtnRc[ 1 ] -1, aBtnRc[ 2 ] -1, aBtnRc[ 4 ] + 1, aBtnRc[ 3 ] + 1, aOBClr[ iObClr, 11 ], 1, WHITE, .F. )
      ELSEIF aOBClr[ iObClr, 9 ] = 2
         roundrectdraw( hWnd, aBtnRc[ 1 ] -1, aBtnRc[ 2 ] -1, aBtnRc[ 4 ] + 1, aBtnRc[ 3 ] + 1, 8, 8, aOBClr[ iObClr, 11 ], 1, WHITE, .F. )
      ENDIF

   ENDIF

   SetTextColor( hDC, _HMG_aControlFontColor[ i, 1 ], _HMG_aControlFontColor[ i, 2 ], _HMG_aControlFontColor[ i, 3 ] )



   ////////////////////////////////////////////////////////////////////////////////////////



   IF ! Empty( _HMG_aControlBrushHandle[ i ] )
      IF _HMG_aControlMiscData1[ i ] == 0
         aBmp := GetBitmapSize( _HMG_aControlBrushHandle[ i ] )
      ELSEIF _HMG_aControlMiscData1[ i ] == 1
         aBmp := GetIconSize( _HMG_aControlBrushHandle[ i ] )
      ENDIF
   ENDIF

   IF AND( _HMG_aControlSpacing[ i ], OBT_VERTICAL ) == OBT_VERTICAL  // vertical text/picture aspect

      y2 := aMetr[ 1 ] * nCRLF
      x2 := aBtnRc[ 3 ] - 2

      xp2 := iif( ! Empty( aBmp ), aBmp[ 1 ], 0 ) // picture width
      yp2 := iif( ! Empty( aBmp ), aBmp[ 2 ], 0 ) // picture height
      xp1 := Round( ( aBtnRc[ 3 ] / 2 ) - ( xp2 / 2 ), 0 )

      IF At( CRLF, _HMG_aControlCaption[ i ] ) <= 0
         nFreeSpace := Round( ( aBtnRc[ 4 ] - 4 - ( aMetr[ 4 ] + yp2 ) ) / 3, 0 )
         nCRLF := 1
      ELSE
         nFreeSpace := Round( ( aBtnRc[ 4 ] - 4 - ( y2 + yp2 ) ) / 3, 0 )
      ENDIF

      IF !Empty( _HMG_aControlCaption[ i ] )  // button has caption

         IF !Empty( _HMG_aControlBrushHandle[ i ] )
            IF !( AND( _HMG_aControlSpacing[ i ], OBT_UPTEXT ) == OBT_UPTEXT )  // upper text aspect not set
               pozYpic := Max( aBtnRc[ 2 ] + nFreeSpace, 5 )
               pozYtext := aBtnRc[ 2 ] + iif( !Empty( aBmp ), nFreeSpace, 0 ) + yp2 + iif( !Empty( aBmp ), nFreeSpace, 0 )
            ELSE
               pozYtext := Max( aBtnRc[ 2 ] + nFreeSpace, 5 )
               aBtnRc[ 4 ] := nFreeSpace + ( ( aMetr[ 1 ] ) * nCRLF ) + nFreeSpace
               pozYpic := aBtnRc[ 4 ]
            ENDIF
         ELSE
            pozYpic := 0
            pozYtext := Round( ( aBtnRc[ 4 ] - y2 ) / 2, 0 )
         ENDIF

      ELSE  // button without caption

         IF ! ( AND( _HMG_aControlSpacing[ i ], OBT_ADJUST ) == OBT_ADJUST )
            pozYpic := Round( ( ( aBtnRc[ 4 ] / 2 ) - ( yp2 / 2 ) ), 0 )
            pozYtext := 0
         ELSE  // strech image
            pozYpic := 1
         ENDIF

      ENDIF

      IF ! lDisabled

         IF lSelected  // vertical selected

            IF ! lXPThemeActive
               xp1 ++
               xPoz := 2
               pozYtext ++
               pozYpic ++
            ELSE
               xPoz := 0
            ENDIF

            IF ! ( AND( _HMG_aControlSpacing[ i ], OBT_ADJUST ) == OBT_ADJUST )
               DrawGlyph( hDC, xp1, pozYpic, xp2, yp2, _HMG_aControlBrushHandle[ i ], rgbTrans, .F., .F. )
               DrawText( hDC, _HMG_aControlCaption[ i ], xPoz, pozYtext - 2, x2,  aBtnRc[ 4 ], DT_CENTER )
               //             DrawText( hDC, _HMG_aControlCaption[ i ], xPoz , pozYtext-1 , x2,  aBtnRc[ 4 ] , DT_CENTER )
            ELSE
               DrawGlyph( hDC, aBtnRc[ 1 ] + 4, aBtnRc[ 2 ] + 4, aBtnRc[ 3 ] - 6, aBtnRc[ 4 ] - 6, _HMG_aControlBrushHandle[ i ], rgbTrans, .F., .T. )
            ENDIF

         ELSE  // vertical non selected

            IF ! ( AND( _HMG_aControlSpacing[ i ], OBT_ADJUST ) == OBT_ADJUST )
               DrawGlyph( hDC, xp1, pozYpic, xp2, yp2, _HMG_aControlBrushHandle[ i ], rgbTrans, .F., .F. )
               DrawText( hDC, _HMG_aControlCaption[ i ],  0, pozYtext - 1, x2,  aBtnRc[ 4 ], DT_CENTER )
            ELSE
               DrawGlyph( hDC, aBtnRc[ 1 ] + 3, aBtnRc[ 2 ] + 3, aBtnRc[ 3 ] - 6, aBtnRc[ 4 ] - 6, _HMG_aControlBrushHandle[ i ], rgbTrans, .F., .T. )
            ENDIF

         ENDIF

      ELSE  // vertical disabled

         IF ! ( AND( _HMG_aControlSpacing[ i ], OBT_ADJUST ) == OBT_ADJUST )
            DrawGlyph( hDC, xp1, pozYpic, xp2, yp2, _HMG_aControlBrushHandle[ i ], , .T., .F. )
            SetTextColor( hDC, GetRed ( GetSysColor ( COLOR_3DHILIGHT ) ), GetGreen ( GetSysColor ( COLOR_3DHILIGHT ) ), GetBlue ( GetSysColor ( COLOR_3DHILIGHT ) ) )
            DrawText( hDC, _HMG_aControlCaption[ i ], 2, pozYtext + 1, x2, aBtnRc[ 4 ] + 1, DT_CENTER )
            SetTextColor( hDC, GetRed ( GetSysColor ( COLOR_3DSHADOW ) ), GetGreen ( GetSysColor ( COLOR_3DSHADOW ) ), GetBlue ( GetSysColor ( COLOR_3DSHADOW ) ) )
            DrawText( hDC, _HMG_aControlCaption[ i ], 0, pozYtext, x2, aBtnRc[ 4 ], DT_CENTER )
         ELSE
            DrawGlyph( hDC, aBtnRc[ 1 ] + 4, aBtnRc[ 2 ] + 4, aBtnRc[ 3 ] - 6, aBtnRc[ 4 ] - 6, _HMG_aControlBrushHandle[ i ], , .T., .T. )
         ENDIF

      ENDIF

   ELSE

      y1 := Round( aBtnRc[ 4 ] / 2, 0 ) - ( aMetr[ 1 ] - 10 )
      y2 := y1 + aMetr[ 1 ]
      x2 := aBtnRc[ 3 ] - 2

      IF ! Empty( _HMG_aControlBrushHandle[ i ] ) // horizontal

         xp2 := iif( ! Empty( aBmp ), aBmp[ 1 ], 0 ) // picture width
         yp2 := iif( ! Empty( aBmp ), aBmp[ 2 ], 0 ) // picture height
         yp1 := Round( aBtnRc[ 4 ] / 2 - yp2 / 2, 0 )

         IF ! Empty( _HMG_aControlCaption[ i ] )

            lDrawEntire := ( aBtnRc[ 3 ] > 109 ) .AND. ( aBtnRc[ 4 ] - yp2 > 16 )
            nStyle := xp2 / 2 - iif( xp2 > 24, 8, 0 )

            IF ! ( AND( _HMG_aControlSpacing[ i ], OBT_LEFTTEXT ) == OBT_LEFTTEXT )

               xp1 := 5 + iif( lDrawEntire, nStyle, 0 )
               x1 := aBtnRc[ 1 ] + xp1 + xp2

            ELSE

               xp1 := aBtnRc[ 3 ] - xp2 - 5 - iif( lDrawEntire, nStyle, 0 )
               x1 := 3
               x2 := aBtnRc[ 3 ] - xp2 - iif( lDrawEntire, xp2 / 2 + 5, 0 )

            ENDIF

         ELSE

            xp1 := Round( aBtnRc[ 3 ] / 2 - xp2 / 2, 0 )
            x1 := aBtnRc[ 1 ]

         ENDIF

      ELSE

         xp1 := 2
         xp2 := 0
         yp1 := 0
         yp2 := 0

         x1 := aBtnRc[ 1 ] + xp1

      ENDIF

      IF ! ( AND( _HMG_aControlSpacing[ i ], OBT_ADJUST ) == OBT_ADJUST )
         y1 := Max( ( ( aBtnRc[ 4 ] / 2 ) - ( nCRLF * aMetr[ 1 ] ) / 2 ) - 1, 1 )
         y2 := ( aMetr[ 1 ] + aMetr[ 5 ] ) * nCRLF
      ENDIF

      IF ! lDisabled

         IF lSelected

            IF ! lXPThemeActive
               x1 += 2
               xp1 ++
               yp1 ++
            ENDIF

            IF ! ( AND( _HMG_aControlSpacing[ i ], OBT_ADJUST ) == OBT_ADJUST )
               DrawGlyph( hDC, xp1, yp1, xp2, yp2, _HMG_aControlBrushHandle[ i ], rgbTrans, .F., .F. )
               DrawText( hDC, _HMG_aControlCaption[ i ], x1, y1 + 1, x2, y1 + y2, DT_CENTER )
            ELSE
               DrawGlyph( hDC, aBtnRc[ 1 ] + 4, aBtnRc[ 2 ] + 4, aBtnRc[ 3 ] - 6, aBtnRc[ 4 ] - 6, _HMG_aControlBrushHandle[ i ], rgbTrans, .F., .T. )
            ENDIF

         ELSE
            IF ! ( AND( _HMG_aControlSpacing[ i ], OBT_ADJUST ) == OBT_ADJUST )
               DrawGlyph( hDC, xp1, yp1, xp2, yp2, _HMG_aControlBrushHandle[ i ], rgbTrans, .F., .F. )
               DrawText( hDC, _HMG_aControlCaption[ i ], x1, y1, x2, y1 + y2, DT_CENTER )
            ELSE
               DrawGlyph( hDC, aBtnRc[ 1 ] + 3, aBtnRc[ 2 ] + 3, aBtnRc[ 3 ] - 6, aBtnRc[ 4 ] - 6, _HMG_aControlBrushHandle[ i ], rgbTrans, .F., .T. )
            ENDIF
         ENDIF

      ELSE
         // disabled horizontal
         IF ! ( AND( _HMG_aControlSpacing[ i ], OBT_ADJUST ) == OBT_ADJUST )
            DrawGlyph( hDC, xp1, yp1, xp2, yp2, _HMG_aControlBrushHandle[ i ], , .T., .F. )
            SetTextColor( hDC, GetRed ( GetSysColor ( COLOR_3DHILIGHT ) ), GetGreen ( GetSysColor ( COLOR_3DHILIGHT ) ), GetBlue ( GetSysColor ( COLOR_3DHILIGHT ) ) )
            DrawText( hDC, _HMG_aControlCaption[ i ], x1 + 1, y1 + 1, x2 + 1, y1 + y2 + 1,  DT_CENTER )
            SetTextColor( hDC, GetRed ( GetSysColor ( COLOR_3DSHADOW ) ), GetGreen ( GetSysColor ( COLOR_3DSHADOW ) ), GetBlue ( GetSysColor ( COLOR_3DSHADOW ) ) )
            DrawText( hDC, _HMG_aControlCaption[ i ], x1, y1, x2, y1 + y2,  DT_CENTER )
         ELSE
            DrawGlyph( hDC, aBtnRc[ 1 ] + 3, aBtnRc[ 2 ] + 3, aBtnRc[ 3 ] - 6, aBtnRc[ 4 ] - 6, _HMG_aControlBrushHandle[ i ], , .T., .T. )
         ENDIF
      ENDIF
   ENDIF

RETURN ( 1 )

//-------------------------------------------------------------\\
STATIC FUNCTION CountIt( cText )
//-------------------------------------------------------------\\
   LOCAL nPoz, nCount := 0

   IF At( CRLF, cText ) > 0
      DO WHILE ( nPoz := At( CRLF, cText ) ) > 0
         nCount++
         cText := SubStr( cText, nPoz + 2 )
      ENDDO
   ENDIF

RETURN nCount
