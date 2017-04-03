/*
 * MINIGUI - Harbour Win32 GUI library Demo
 *
 * Copyright 2015 Verchenko Andrey <verchenkoag@gmail.com>
 *
 * Last Revised By P.Chornyj <myorg63@mail.ru> 10.22.2016
*/

#include "MiniGUI.ch"

PROCEDURE Main()

   LOCAL nWidth, nHeight

   IF GetImageInfo( "logo.jpg", @nWidth, @nHeight )

      DEFINE WINDOW Form_1 ;
	      MAIN ;
      	CLIENTAREA nWidth, nHeight + 30 ;
      	TITLE "Test a mouse click on the one picture which is divided into 3 parts (" + __FILE__ + ")"

      	@ 0,0 IMAGE Img_Logo PICTURE "logo.jpg" WIDTH nWidth HEIGHT nHeight ;
            ON MOUSEHOVER RC_CURSOR( "MINIGUI_FINGER" ) ;
            ACTION Determine_the_portion_of_the_picture()   

      END WINDOW

      CENTER   WINDOW Form_1
      ACTIVATE WINDOW Form_1

   ENDIF

   RETURN

/////////////////////////////////////////////////////////////////////////////
#ifdef __XHARBOUR__
   #define ENUMINDEX hb_EnumIndex()
#else
   #define ENUMINDEX aPart:__EnumIndex
#endif

PROCEDURE Determine_the_portion_of_the_picture() 

   STATIC aImage := {}

   LOCAL nY, nX, aCoords := GetCursorPos()
   LOCAL cMsg, aPart, nLeft, nWidth

   IF Empty( aImage )
      AADD( aImage, { 0,000,149,200, "Part 1 of a picture" } )
      AADD( aImage, { 0,202,149,488, "Part 2 of a picture" } )
      AADD( aImage, { 0,693,149,239, "Part 3 of a picture" } )
   ENDIF

   nY := aCoords[1] - Form_1.Row - GetTitleHeight() - GetBorderHeight()
   nX := aCoords[2] - Form_1.Col - GetBorderWidth()

   cMsg := "Pos y: " + hb_NtoS( nY ) + " Pos x: " + hb_NtoS( nX )

   FOR EACH aPart IN aImage
      nLeft  := aPart[2]
      nWidth := aPart[4]

      IF nX > nLeft .AND. nX < nLeft + nWidth
         cMsg += CRLF + CRLF + "Area #" + HB_NtoS( ENUMINDEX )
         cMsg += CRLF + CRLF + aPart[5] 

         MsgInfo( cMsg )
     ENDIF
   NEXT

   RETURN

STATIC FUNCTION GetImageInfo( cPicFile, nPicWidth, nPicHeight )

   LOCAL aSize := hb_GetImageSize( cPicFile )

   nPicWidth  := aSize[1]
   nPicHeight := aSize[2]

   RETURN ( nPicWidth > 0 )
