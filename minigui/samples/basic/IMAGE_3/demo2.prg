/*
 * MINIGUI - Harbour Win32 GUI library Demo
 * (c) 2017 Grigory Filatov <gfilatov@inbox.ru>
*/

#include <hmg.ch>

FUNCTION Main

   define window win_1 ;
      main ;
      clientarea 400, 300 ;
      title "Reading PNG Image from a File" ;
      backcolor { 204, 220, 240 } nosize

      ON KEY ESCAPE ACTION win_1.Release()

      DEFINE TOOLBAR ToolBar_1 BUTTONSIZE 48,18 FLAT BORDER

	BUTTON Button_1 ;
		CAPTION 'File' ;
		ACTION LoadImage() ;
		TOOLTIP 'Load PNG Image From File'

      END TOOLBAR

   end window

   win_1.minbutton := .F.
   win_1.maxbutton := .F.

   win_1.Center()
   win_1.Activate()

RETURN NIL


PROCEDURE LoadImage()
   LOCAL IsThemed := IsThemed()
   LOCAL cFile, aSize, n := iif(IsThemed, 0, 2)

   cFile := GetFile( { {'Select PNG File (*.png)', '*.png'} }, 'Open a File', GetCurrentFolder(), .F., .T. )
   IF Empty (cFile)
      RETURN
   ENDIF

   aSize := hb_GetImageSize( cFile )
   win_1.width := aSize[ 1 ] + iif(IsThemed, 1, 2) * GetBorderWidth() + 2
   win_1.height := aSize[ 2 ] + GetToolBarHeight() + GetTitleHeight() + iif(IsThemed, 1, 2) * GetBorderHeight()
   win_1.Center()

   IF IsControlDefined (Image_1, Win_1) == .T.
      Win_1.Image_1.Release()
   ENDIF

   DEFINE IMAGE Image_1
      PARENT            Win_1
      ROW               GetToolBarHeight()
      COL               2
      WIDTH             aSize[ 1 ]
      HEIGHT            aSize[ 2 ]
      PICTURE           cFile
      ADJUSTIMAGE       .T.
      TRANSPARENT       .T.
   END IMAGE

   IF IsControlDefined (Frame_1, Win_1) == .T.
      Win_1.Frame_1.Release()
   ENDIF

   @ (Win_1.Image_1.Row - n), (Win_1.Image_1.Col - n) FRAME Frame_1 OF Win_1 ;
      WIDTH  (Win_1.Image_1.Width  + n + n) ;
      HEIGHT (Win_1.Image_1.Height + n + n) ;
      TRANSPARENT 

RETURN


STATIC FUNCTION GetToolBarHeight()
   LOCAL h := win_1.ToolBar_1.Handle

RETURN (LoWord( GetSizeToolBar( h ) ) + iif(IsThemed(), 1, 2) * GetBorderHeight())
