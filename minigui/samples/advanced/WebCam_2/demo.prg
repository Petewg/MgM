 /*
  * MINIGUI - Harbour Win32 GUI library Demo
  *
  * Copyright 2011-2018 Grigory Filatov <gfilatov@inbox.ru>
 */

#include "minigui.ch"
#include "BosTaurus.ch"

*-----------------------------------------------------------------------------*
PROCEDURE Main
*-----------------------------------------------------------------------------*

   DEFINE WINDOW Form_1 ;
      AT 0, 0 ;
      WIDTH 440 + GetBorderWidth() ;
      HEIGHT 300 + GetTitleHeight() + GetBorderHeight() ;
      TITLE 'WebCam Preview Demo' ;
      MAIN ;
      NOMAXIMIZE NOSIZE ;
      ON INIT ( ;
                 CaptureImage() ;  // capture initialization
              ) ;
      ON RELEASE ( ;
                 CloseWebCam() ;
                 ) ;
      ON RESTORE ( ;
                 CaptureImage() ;  // capture initialization
                 )

   @ 20, 60 WEBCAM WebCam_1 ;
      WIDTH 250 HEIGHT 210 ;
      RATE 20 ;
      START

   DEFINE IMAGE Image_1
      ROW 120
      COL 280
      WIDTH   150
      HEIGHT  110
      STRETCH .T.
   END IMAGE

   DEFINE BUTTON Button_1
      ROW 10
      COL 20
      WIDTH   120
      CAPTION 'Start WebCam'
      ACTION  ( CreateWebCam(), CaptureImage() )
   END BUTTON

   DEFINE BUTTON Button_2
      ROW 10
      COL 150
      WIDTH   120
      CAPTION 'Stop WebCam'
      ACTION  CloseWebCam()
   END BUTTON

   DEFINE BUTTON Button_3
      ROW 80
      COL 315
      WIDTH   80
      CAPTION 'Capture'
      ACTION  CaptureImage()
   END BUTTON

   DEFINE LABEL Label_1
      ROW 59
      COL 19
      WIDTH   252
      HEIGHT  212
      BORDER  .T.
   END LABEL

   DEFINE LABEL Label_2
      ROW 119
      COL 279
      WIDTH   152
      HEIGHT  112
      BORDER  .T.
   END LABEL

   ON KEY ESCAPE ACTION ThisWindow.Release

   END WINDOW

   CENTER WINDOW Form_1

   ACTIVATE WINDOW Form_1

RETURN

*-----------------------------------------------------------------------------*
PROCEDURE CreateWebCam
*-----------------------------------------------------------------------------*

   IF ! IsControlDefined( WebCam_1, Form_1 )

      @ 20, 60 WEBCAM WebCam_1 OF Form_1 ;
         WIDTH 250 HEIGHT 210 ;
         RATE 20

      Form_1.WebCam_1.Start()
      DO EVENTS

      Form_1.Button_3.Enabled := .T.

   ENDIF

RETURN

*-----------------------------------------------------------------------------*
PROCEDURE CloseWebCam
*-----------------------------------------------------------------------------*

   IF IsControlDefined( WebCam_1, Form_1 )

      Form_1.WebCam_1.Release()
      DO EVENTS

      Form_1.Image_1.hBitmap := Nil
      Form_1.Button_3.Enabled := .F.

   ENDIF

RETURN

*-----------------------------------------------------------------------------*
PROCEDURE CaptureImage
*-----------------------------------------------------------------------------*
   LOCAL hBitmap
   LOCAL nWidth
   LOCAL nHeight

   IF GetControlIndex( 'WebCam_1', 'Form_1' ) > 0

      IF cap_EditCopy( GetControlHandle ( 'WebCam_1', 'Form_1' ) )

         DO EVENTS

         nWidth := GetProperty( "Form_1", "Image_1", "Width" )
         nHeight := GetProperty( "Form_1", "Image_1", "Height" )

         hBitmap := BT_BitmapClipboardGet( 'Form_1' )

         IF ! Empty( hBitmap )

            DO EVENTS

            Form_1.Image_1.hBitmap := BT_BitmapCopyAndResize( hBitmap, nWidth, nHeight, NIL, BT_RESIZE_COLORONCOLOR )

            BT_BitmapSaveFile( hBitmap, "webcam.jpg", BT_FILEFORMAT_JPG )

            BT_BitmapRelease( hBitmap )

            BT_BitmapClipboardClean( 'Form_1' )

            DO EVENTS

         ENDIF

      ELSE

         MsgAlert( 'Capture is failure!', 'Error' )

      ENDIF

   ENDIF

RETURN
