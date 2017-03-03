#include "minigui.ch"

DECLARE WINDOW Form_1


PROCEDURE Determine_The_Portion_Of_The_Picture()

   LOCAL aPoint := GetCursorPos( Form_1.Img_Logo.Handle )

   LOCAL nArea
   LOCAL cMsg  := ""
           
   IF ( nArea := Ascan( m_aImage, { |aRect| PtInRect( aPoint, aRect ) } ) ) > 0

      cMsg += "Pos Y: " + hb_NtoS( aPoint[ 2 ] ) + "; " 
      cMsg += "Pos X: " + hb_NtoS( aPoint[ 1 ] )
      cMsg += CRLF + CRLF + "Area #" + hb_NtoS( nArea )
      cMsg += CRLF + CRLF + "Part "  + hb_NtoS( nArea ) + " of a picture." 
   
      MsgInfo( cMsg )

   ENDIF

   RETURN


#define SM_MOUSEPRESENT    19
#define SM_CMOUSEBUTTONS   43

FUNCTION IsMousePresent()

/*
   RETURN ( GetSystemMetrics( SM_MOUSEPRESENT ) != 0  )

   This   value  is  rarely  zero,  because of support for virtual mice and
   because  some   systems  detect the presence of the port  instead of the
   presence of a mouse.
*/
   RETURN ( GetSystemMetrics( SM_CMOUSEBUTTONS ) > 0  )


FUNCTION GetImageInfo( cPicFile, nPicWidth, nPicHeight )

   LOCAL aSize := hb_GetImageSize( cPicFile )

   nPicWidth  := aSize[ 1 ]
   nPicHeight := aSize[ 2 ]

   RETURN ( nPicWidth > 0 )
