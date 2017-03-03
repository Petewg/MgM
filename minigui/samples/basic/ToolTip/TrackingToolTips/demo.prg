/*
 * MINIGUI - Harbour Win32 GUI library Demo
 *
 * Based on the original work "Picture_Coords" of Verchenko Andrey <verchenkoag@gmail.com>
 *
 * Last Revised By P.Chornyj <myorg63@mail.ru> 10.24.2016
*/

#include "minigui.ch"
#include "i_winuser.ch"

#define _X_                1
#define _Y_                2
#define SM_MOUSEPRESENT    19
#define SM_CMOUSEBUTTONS   43

MEMVAR m_TrackingTT, m_TrackingMouse

FUNCTION Main()

   LOCAL nWidth := 0, nHeight := 0 
   
   IF IsMousePresent() .AND. GetImageInfo( "logo.jpg", @nWidth, @nHeight )

      DEFINE WINDOW Form_1 ;
         MAIN ;
         CLIENTAREA nWidth, nHeight + 70 ;
         TITLE "ToolTip Sample (" + __FILE__ + ")" ;
         ON RELEASE ReleaseControl( m_TrackingTT ) 

      @ 0,0 IMAGE Img_Logo PICTURE "logo.jpg" WIDTH nWidth HEIGHT nHeight ;
            ON MOUSEHOVER Img_Logo_OnMouseHover() ;
            ON MOUSELEAVE Img_Logo_OnMouseLeave()

      @ 155,30 LABEL Label_1 VALUE "Move a mouse cursor over part # of picture" TRANSPARENT FONT "ARIAL" SIZE 34 ;
         FONTCOLOR PINK BACKCOLOR YELLOW AUTOSIZE

      END WINDOW

      CreateTrackingToolTip()

      CENTER   WINDOW Form_1
      ACTIVATE WINDOW Form_1

   ENDIF

   RETURN 0

/////////////////////////////////////////////////////////////////////////////
PROCEDURE CreateTrackingToolTip()

   LOCAL nStyle := TTS_ALWAYSTIP
   LOCAL nFlags := hb_bitOr( TTF_IDISHWND, TTF_TRACK, TTF_ABSOLUTE )

   PUBLIC m_TrackingTT := ;
            InitToolTipEx( Form_1.Img_Logo.Handle, Nil, "", "Position:", If( IsVistaOrLater(), 4, 1 ), nStyle, nFlags )

   PUBLIC m_TrackingMouse := .F.

   RETURN


PROCEDURE Img_Logo_OnMouseHover()

   STATIC oldXY := { 0, 0 }

   LOCAL  newXY := GetCursorPos( Form_1.Img_Logo.Handle ), cTip

   IF m_TrackingMouse == .F.
      // Activate the tooltip
      TTM_TrackActivate( m_TrackingTT, Form_1.Img_Logo.Handle, .T. )
      m_TrackingMouse := .T.
   ENDIF

   // Make sure the mouse has actually moved
   IF oldXY[_X_] != newXY[_X_] .OR. oldXY[_Y_] != newXY[_Y_]

      oldXY := newXY
      cTip  := Determine_The_Portion_Of_The_Picture( newXY )
      // Update the tooltip text
      TTM_UpdateTipText( m_TrackingTT, Form_1.Img_Logo.Handle, cTip )
      // Update the tooltip position
      TTM_TrackPosition( m_TrackingTT, Form_1.Img_Logo.Handle, { newXY[_X_] + 10, newXY[_Y_] - 20 }  )
   ENDIF

   RETURN


PROCEDURE Img_Logo_OnMouseLeave()

   // Deactivate the tooltip
   TTM_TrackActivate( m_TrackingTT, Form_1.Img_Logo.Handle, .F. )
   m_TrackingMouse := .F.

   RETURN

/////////////////////////////////////////////////////////////////////////////
FUNCTION Determine_The_Portion_Of_The_Picture( aPoint )

   STATIC s_aImage := { { 0, 0, 200, 149 }, { 202, 0, 691, 149 }, { 693, 0, 933, 149 } }
   LOCAL nArea
   LOCAL cMsg  := ""
           
   IF ( nArea := Ascan( s_aImage, { |aRect| PtInRect( aPoint, aRect ) } ) ) > 0

      cMsg += "Pos Y: " + hb_NtoS( aPoint[ 2 ] ) + "; " 
      cMsg += "Pos X: " + hb_NtoS( aPoint[ 1 ] )
      cMsg += CRLF + CRLF + "Area #" + hb_NtoS( nArea )
      cMsg += CRLF + "Part " + hb_NtoS( nArea ) + " of a picture." 
   
   ENDIF 

   RETURN cMsg


STATIC FUNCTION IsMousePresent()
/*
   RETURN ( GetSystemMetrics( SM_MOUSEPRESENT ) != 0  )

   This   value  is  rarely  zero,  because of support for virtual mice and
   because  some   systems  detect the presence of the port  instead of the
   presence of a mouse.
*/
   RETURN ( GetSystemMetrics( SM_CMOUSEBUTTONS ) > 0  )


STATIC FUNCTION GetImageInfo( cPicFile, nPicWidth, nPicHeight )

   LOCAL aSize := hb_GetImageSize( cPicFile )

   nPicWidth  := aSize[ 1 ]
   nPicHeight := aSize[ 2 ]

   RETURN ( nPicWidth > 0 )
