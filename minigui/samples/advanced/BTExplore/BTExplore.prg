/***************************************************
 
  Exploring Bos Taurus of Dr. CLAUDIO SOTO from Uruguay

  Phase 1 : Select ( GetFile() ) and load image file 

 ***************************************************

Bos Taurus :

  AUTOR:    Dr. CLAUDIO SOTO
  PAIS:     URUGUAY
  E-MAIL:   srvet@adinet.com.uy
  BLOG:     http://srvet.blogspot.com

***************************************************/

#include "hmg.ch"

STATIC nFrmNo, aHandles

PROCEDURE Main()

   nFrmNo := 0
   aHandles := {}

   DEFINE WINDOW frmBTExpMain;
      AT 0,0;
      WIDTH  700;
      HEIGHT 600;
      TITLE "Exploring Bos Taurus for HMG";
      ICON "BT_Icon" ;
      ON RELEASE ReleaseAll() ;
      MAIN

      ON KEY ESCAPE ACTION ThisWindow.Release

      DEFINE MAIN MENU 

	DEFINE POPUP '&File' NAME mitFile
         
            ITEM '&Open'     NAME mit_Open       ACTION BTEx_OpenImgFile()
            
            SEPARATOR
            
            ITEM "E&xit"     ACTION ThisWindow.Release
       
	END POPUP // File
         
	POPUP '?'                    

            ITEM '&About'  ACTION MsgInfo( BT_InfoName() + Space(3) + ;
                                           BT_InfoVersion() + CRLF + ;
                                           BT_InfoAuthor () + CRLF + ;
                                           "E-MAIL:   srvet@adinet.com.uy" + CRLF + ;
                                           "BLOG:     http://srvet.blogspot.com", "Info" )
         END POPUP // Info

      END MENU // MAIN

      DEFINE STATUSBAR FONT 'Verdana' SIZE 8
          STATUSITEM ""
          STATUSITEM ""
          DATE WIDTH 80
          CLOCK WIDTH 90
      END STATUSBAR

   END WINDOW // frmBTExpMain

   CENTER WINDOW   frmBTExpMain
   ACTIVATE WINDOW frmBTExpMain

RETURN // BTExplore.Main()

*-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.

PROCEDURE ReleaseAll()

   AEVAL( aHandles, { | hImage, i1 | BT_BitmapRelease( hImage ), aHandles[ i1 ] := NIL } )

RETURN // ReleaseAll()

*-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.

PROCEDURE BTEx_Release( hBitmap )

   BT_BitmapRelease( hBitmap )

   ADEL( aHandles, ASCAN( aHandles, hBitmap ) )

   ASIZE( aHandles, LEN( aHandles ) - 1 )

RETURN // BTEx_Release()

*-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.

PROCEDURE BTEx_Paint(;
                      cFrmName,;
                      hBitmap )

   LOCAL nFrmWidth  := BT_ClientAreaWidth(  cFrmName ),;
         nFrmHeight := BT_ClientAreaHeight( cFrmName )
                                           
   LOCAL hDC, BTstruct
   
   hDC := BT_CreateDC( cFrmName, BT_HDC_INVALIDCLIENTAREA, @BTstruct )

   BT_DrawBitmap( hDC, 0, 0, nFrmWidth, nFrmHeight, BT_SCALE, hBitmap )

   BT_DeleteDC( BTstruct )

RETURN // BTEx_Paint()

*-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.

PROCEDURE BTEx_OpenImgFile()                 // Open an Image file

   LOCAL cImgFileName := GetFile(,, GetCurrentFolder() )  // Image File Name

   LOCAL nParentHeight := frmBTExpMain.Height,;
         nParentCol := frmBTExpMain.Col,;
         nParentRow := frmBTExpMain.Row,;
         nFrmWidth,;
         nFrmHeight 

   LOCAL cFrmName := "frmImg_",;
         hBitmap

   LOCAL nImgWidth,;          // Width of bitmap
         nImgHeight,;         // Height of bitmap
         nAspRatio

   IF ! EMPTY( cImgFileName )     

      cFrmName += STRZERO( ++nFrmNo )
      hBitmap  := BT_BitmapLoadFile( cImgFileName )

      AADD( aHandles, hBitmap )

      nImgWidth  := BT_BitmapWidth( hBitmap )
      nImgHeight := BT_BitmapHeight( hBitmap ) 

      nAspRatio  := nImgWidth / nImgHeight 

      nFrmHeight := MIN( nImgHeight, nParentHeight )
      nFrmWidth  := nFrmHeight * nAspRatio - 40

      DEFINE WINDOW &cFrmName ;
         AT nParentRow + nFrmNo * 40, nParentCol + nFrmNo * 40;
         WIDTH  nFrmWidth ;
         HEIGHT nFrmHeight ;
         ICON "BT_Icon" ;
         TITLE "Bos Taurus Image Library for HMG"  ; 
         ON PAINT    BTEx_Paint( cFrmName, hBitmap ) ;
         ON SIZE     BT_ClientAreaInvalidateAll( cFrmName ) ;
         ON MAXIMIZE BT_ClientAreaInvalidateAll( cFrmName ) ;
         ON RELEASE { || BTEx_Release( hBitmap ), frmBTExpMain.StatusBar.Item(1) := '' } ;
         ON GOTFOCUS {|| frmBTExpMain.StatusBar.Item(1) := cImgFileName } ;
         CHILD

         ON KEY ESCAPE ACTION ThisWindow.Release

      END WINDOW // &cFrmName

      ACTIVATE WINDOW &cFrmName

   ENDIF ! EMPTY( cBMFileName )

RETURN // BTEx_OpenImgFile()
