#include <hmg.ch>

MEMVAR hBitmap

FUNCTION Main()

   PRIVATE hBitmap

   LOAD WINDOW Demo AS Demo_2
   // SET CONTROL Image_1 OF Demo_2 CLIENTEDGE
   SET CONTROL Label_3 OF Demo_2 CLIENTEDGE
   SET CONTROL Label_5 OF Demo_2 CLIENTEDGE
   SET CONTROL Label_7 OF Demo_2 CLIENTEDGE
   SET CONTROL Label_8 OF Demo_2 CLIENTEDGE
   ON KEY ESCAPE OF Demo_2 ACTION ThisWindow.Release
   Demo_2.Center

   IfNotFoundImg( "Demo_2", "Image_1", { 255, 153, 153 } )
   IfNotFoundImg( "Demo_2", "Image_2", CYAN )
   IfNotFoundImg( "Demo_2", "Image_3", GREEN )
   IfNotFoundImg( "Demo_2", "Image_4", YELLOW )

   Demo_2.Activate

RETURN NIL


FUNCTION IfNotFoundImg( cFormName, cControlName, aRGBcolor_Fill_Bk )

   LOCAL nWidth  := GetProperty( cFormName, cControlName, "Width" )
   LOCAL nHeight := GetProperty( cFormName, cControlName, "Height" )
   LOCAL cImgFile := GetProperty( cFormName, cControlName, "Picture" )
   LOCAL hDC, BTstruct

   hBitmap := BT_HMGGetImage ( cFormName, cControlName )
   IF !File( cImgFile ) .AND. Empty( hBitmap )
      hBitmap := BT_BitmapCreateNew ( nWidth, nHeight, aRGBcolor_Fill_Bk )
      hDC := BT_CreateDC ( hBitmap, BT_HDC_BITMAP, @BTstruct )

      BT_DrawRectangle ( hDC, 0, 0, nWidth - 1, nHeight - 1, BLACK, 1 )
      BT_DrawLine ( hDC, 0, 0, nHeight, nWidth, BLACK, 1 )
      BT_DrawLine ( hDC, nHeight, 0, 0, nWidth, BLACK, 1 )
      BT_DeleteDC ( BTstruct )
      BT_HMGSetImage ( cFormName, cControlName, hBitmap, .T. )
   ENDIF

RETURN NIL


FUNCTION Proc_ON_RELEASE

   BT_BitmapRelease ( hBitmap ) // Very important

RETURN NIL


FUNCTION Submit()

   SetNewImage( "Image_1", "HMG" )
   SetNewImage( "Image_2", "PAUL" )
   SetNewImage( "Image_3", "AVAILABLE" )
   SetNewImage( "Image_4", "PRODUCT" )

RETURN NIL


FUNCTION SetNewImage( cControl, cFileName )

   LOCAL hBitmap_aux
   LOCAL cForm := ThisWindow.Name
   LOCAL w := GetProperty( cForm, cControl, "Width" )
   LOCAL h := GetProperty( cForm, cControl, "Height" )

   hBitmap_aux := BT_BitmapLoadFile ( cFileName )

   hBitmap := BT_BitmapCopyAndResize ( hBitmap_aux, w, h, NIL, BT_RESIZE_HALFTONE )
   BT_BitmapRelease ( hBitmap_aux )
   BT_HMGSetImage ( cForm, cControl, hBitmap, .F. )

RETURN NIL
