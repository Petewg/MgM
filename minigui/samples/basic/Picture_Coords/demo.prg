/*
 * MINIGUI - Harbour Win32 GUI library Demo
 *
 * Copyright 2015 Verchenko Andrey <verchenkoag@gmail.com>
*/

#include "MiniGUI.ch"

Procedure Main()
Local nWidth, nHeight

IF GetImageInfo( "logo.jpg", @nWidth, @nHeight )

  DEFINE WINDOW Form_1 ;
	AT 0,0 ;
	WIDTH nWidth + 2*GetBorderWidth() HEIGHT nHeight + GetTitleHeight() + 2*GetBorderHeight() ;
	MAIN ;
	TITLE "Test a mouse click on the one picture which is divided into 3 parts" 

	@ 0,0 IMAGE Img_Logo PICTURE "logo.jpg" WIDTH nWidth HEIGHT nHeight ;
          ON MOUSEHOVER RC_CURSOR( "MINIGUI_FINGER" ) ;
          ACTION Determine_the_portion_of_the_picture()   

  END WINDOW

  CENTER WINDOW Form_1
  ACTIVATE WINDOW Form_1

ENDIF

Return

#ifdef __XHARBOUR__
   #define ENUMINDEX hb_EnumIndex()
#else
   #define ENUMINDEX aPart:__EnumIndex
#endif
/////////////////////////////////////////////////////////////////////////////
Procedure Determine_the_portion_of_the_picture() 
Local nY, nX, aCoords := GetCursorPos()
Local cMsg, aImage := {}, aPart, nLeft, nWidth

AADD( aImage , { 0,000,149,200, "Part 1 of a picture" } )
AADD( aImage , { 0,202,149,488, "Part 2 of a picture" } )
AADD( aImage , { 0,693,149,239, "Part 3 of a picture" } )

nY := aCoords[1] - Form_1.Row - GetTitleHeight() - GetBorderHeight()
nX := aCoords[2] - Form_1.Col - GetBorderWidth()
cMsg := "Pos y: "+HB_NtoS(nY)+" Pos x: "+HB_NtoS(nX)

FOR EACH aPart IN aImage
  nLeft := aPart[2]
  nWidth := aPart[4]
  IF nX > nLeft .AND. nX < nLeft + nWidth
    cMsg += CRLF + CRLF + "Area #" + HB_NtoS(ENUMINDEX)
    cMsg += CRLF + CRLF + aPart[5] 
    MsgInfo( cMsg )
  ENDIF
NEXT

Return

Function GetImageInfo( cPicFile, nPicWidth, nPicHeight )
   Local aSize := hb_GetImageSize( cPicFile )

   nPicWidth  := aSize [1]
   nPicHeight := aSize [2]

Return (nPicWidth > 0)
