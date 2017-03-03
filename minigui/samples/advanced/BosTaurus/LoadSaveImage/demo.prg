#include "hmg.ch"
#include "BosTaurus.CH"
*******************************************************************************
 * HMG - Harbour Win32 GUI library Demo
 * Copyright 2002 Roberto Lopez <mail.box.hmg@gmail.com>
 * http://sites.google.com/site/hmgweb/
*******************************************************************************
* Bos Taurus Graphic Library for HMG
* AUTOR:    Dr. CLAUDIO SOTO
* PAIS:     URUGUAY
* E-MAIL:   srvet@adinet.com.uy
* BLOG:     http://srvet.blogspot.com
*******************************************************************************
* test_pix by aarca   2017
* fatteio@yahoo.it
*
* adapted for miniguiExtended (mingw) by p.d. 01/02/2017
******************************************************************************* 

#define _BMP_FILE "test.bmp"
#define _JPG_FILE "test.jpg"


DECLARE WINDOW MainForm

STATIC hBitmap // bitmap handler, program-wide visible variable

PROCEDURE MAIN()

   SetCurrentFolder( GetStartUpFolder() )

   LOAD WINDOW  MainForm

   CENTER WINDOW MainForm 
   
   ACTIVATE WINDOW MainForm

   RETURN


PROCEDURE InitProc()
   LOCAL cImage :=  GetFile( { {'Image files','*.jpg;*.bmp'} } , 'Open .JPG image file', hb_CWD(), .F. , .T. )
   IF ! Empty( cImage )
      hBitmap := BT_BitmapLoadFile( cImage )
      BT_ClientAreaInvalidateAll ( "MainForm" )
   ENDIF
   RETURN 
   
PROCEDURE ReleaseProc()
   BT_bitmaprelease( hBitmap )
   IF hb_vfExists( _BMP_FILE )
      hb_vfErase( _BMP_FILE )
   ENDIF
   IF hb_vfExists( _JPG_FILE )
      hb_vfErase( _JPG_FILE )
   ENDIF
   RETURN



PROCEDURE pix_test_paint()
   LOCAL  hDC, BTstruct

	hDC := BT_CreateDC ( "MainForm",  BT_HDC_INVALIDCLIENTAREA, @BTstruct )
	BT_DrawBitmap( hDC, 0, 0, 765, 450, BT_STRETCH, hBitmap )
	BT_DeleteDC( BTstruct )
	* BT_bitmaprelease(hBitmap)

	RETURN 

PROCEDURE pix_test_draw_image()
   LOCAL cImage
   BT_bitmapRelease( hBitmap )
   MainForm.ButtonBmpSave.show
   MainForm.ButtonJpgSave.show
   
   If IsControlDefined( Label_1, MainForm )
      MainForm.Label_1.release 
   ENDIF
   cImage :=  GetFile( { {'Image files','*.jpg;*.bmp'} } , 'Open .JPG image file', /*hb_CWD()*/, .F. , .T. )
   hBitmap := BT_BitmapLoadFile( cImage ) 
   ERASE WINDOW MainForm

   * BT_bitmaprelease(hBitmap)

   RETURN


PROCEDURE pix_test_save_image( cType )

   LOCAL hBitmap_copy, hBitmap_clone, cFileName
   
   SetCurrentFolder( GetStartUpFolder() )

	hBitmap_copy := BT_BitmapCopyAndResize (hBitmap, BT_BitmapWidth (hBitmap),  BT_BitmapHeight (hBitmap), BT_SCALE, BT_RESIZE_HALFTONE)
	
	hBitmap_clone := BT_BitmapClone (hBitmap, 0, 0, BT_BitmapWidth (hBitmap), BT_BitmapHeight (hBitmap), BT_SCALE)	

	IF ( cType == "BMP" )
      cFileName := _BMP_FILE
		BT_BitmapSaveFile( hBitmap_copy, cFileName, BT_FILEFORMAT_BMP )
		MainForm.ButtonBmpSave.hide
		MainForm.ButtonJpgSave.hide
	ENDIF
	
	IF ( cType == "JPG" )
      cFileName := _JPG_FILE
		BT_BitmapSaveFile (hBitmap_copy, cFileName, BT_FILEFORMAT_JPG)
		** with BT_FILEFORMAT_JPG  RAM is HEAVILY charged
		MainForm.ButtonBmpSave.hide
		MainForm.ButtonJpgSave.hide		
	ENDIF

	BT_bitmaprelease( hBitmap )
	BT_bitmaprelease( hBitmap_copy )		
	BT_bitmaprelease( hBitmap_clone )

	If IsControlDefined( Label_1, MainForm )
      MainForm.Label_1.release
	ENDIF
	
	ERASE WINDOW MainForm
	
	@ 70,30 LABEL Label_1 ;
      PARENT MainForm ;
      VALUE "File " + cFileName + " saved. Click `Load image` button to repeat" ;
      WIDTH 500 ;
      HEIGHT 40 ;
      FONT 'Segoe UI' SIZE 14;
      AUTOSIZE 
	

   RETURN
   