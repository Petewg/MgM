/*
 * MINIGUI - Harbour Win32 GUI library Demo
 *
 * Copyright 2015 Verchenko Andrey <verchenkoag@gmail.com>
 *
 * Last Revised By P.Chornyj <myorg63@mail.ru> 10.22.2016
*/

#include "minigui.ch"

FUNCTION Main()

   LOCAL nWidth := 0, nHeight := 0

   IF IsMousePresent() .AND. GetImageInfo( "logo.jpg", @nWidth, @nHeight )

      DEFINE WINDOW Form_1 ;
         MAIN ;
         CLIENTAREA nWidth, nHeight + 30 ;
         TITLE "Test a mouse click on the one picture which is divided into 3 parts (" + __FILE__ + ")"

      @ 0,0 IMAGE Img_Logo PICTURE "logo.jpg" WIDTH nWidth HEIGHT nHeight ;
            ON MOUSEHOVER RC_CURSOR( "MINIGUI_FINGER" ) ;
            ACTION Determine_The_Portion_Of_The_Picture()   

      END WINDOW

      CENTER   WINDOW Form_1
      ACTIVATE WINDOW Form_1
   ENDIF

   RETURN 0

/////////////////////////////////////////////////////////////////////////////
PROCEDURE Determine_The_Portion_Of_The_Picture()
   //  { { left, top, right, bottom }, ... }
   STATIC s_aImage := { { 0, 0, 200, 149 }, { 202, 0, 691, 149 }, { 693, 0, 933, 149 } }

   LOCAL aPoint := GetCursorPos( Form_1.Handle )
   LOCAL nArea
   LOCAL cMsg  := ""
           
   IF ( nArea := Ascan( s_aImage, { |aRect| PtInRect( aPoint, aRect ) } ) ) > 0

      cMsg += "Pos Y: " + hb_NtoS( aPoint[2] ) + "; " 
      cMsg += "Pos X: " + hb_NtoS( aPoint[1] )
      cMsg += CRLF + CRLF + "Area #" + hb_NtoS( nArea )
      cMsg += CRLF + CRLF + "Part "  + hb_NtoS( nArea ) + " of a picture." 
   
      MsgInfo( cMsg )
   ENDIF

   RETURN

#define SM_MOUSEPRESENT    19
#define SM_CMOUSEBUTTONS   43

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

   nPicWidth  := aSize[1]
   nPicHeight := aSize[2]

   RETURN ( nPicWidth > 0 )
