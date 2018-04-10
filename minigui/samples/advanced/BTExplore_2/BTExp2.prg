/***************************************************
 
  Exploring Bos Taurus of Dr. CLAUDIO SOTO from Uruguay
 
  Image converter
  
 ***************************************************
 
Bos Taurus :

  AUTOR:    Dr. CLAUDIO SOTO
  PAIS:     URUGUAY
  E-MAIL:   srvet@adinet.com.uy
  BLOG:     http://srvet.blogspot.com

Sample by : esgici
  
***************************************************/

#include "hmg.ch"
#include "hmg_hpdf.ch"

STATIC hImage, hImageDisplay, cImgFilName

#define BTExp_FILEFORMAT_PDF   0xFF


PROCEDURE Main()

   SET CENT ON
   SET DATE GERM
   
   hImage        := 0
   hImageDisplay := 0
   cImgFilName   := ''

   DEFINE WINDOW frmBTExp_IC;
      AT 0,0;
      WIDTH  700;
      HEIGHT 600;
      TITLE "Exploring Bos Taurus for HMG  -- Image Converter";
      ICON "BT_Icon" ;
      ON INIT BTExp_OpenImgFile() ; 
      ON RELEASE BT_BitmapRelease ( hImage ) ;
      ON MAXIMIZE BTExp_SetImageAdjust() ;
      ON SIZE BTExp_SetImageAdjust() ;
      MAIN
      
      ON KEY ESCAPE         ACTION ThisWindow.Release
      
      DEFINE MAIN MENU 
      
         DEFINE POPUP '&File'
         
            ITEM "&Open"            NAME mit_RFile      ACTION BTExp_OpenImgFile()
               
            DEFINE POPUP  '&Save As ...'  NAME mitSaveAs
               ITEM "&BMP"          NAME mit_WFBMP_0   ACTION SaveAs ( BT_FILEFORMAT_BMP )
               ITEM "&JPG"          NAME mit_WFJPG_1   ACTION SaveAs ( BT_FILEFORMAT_JPG )
               ITEM "&GIF"          NAME mit_WFGIF_2   ACTION SaveAs ( BT_FILEFORMAT_GIF )
               ITEM "&TIF"          NAME mit_WFTIF_3   ACTION SaveAs ( BT_FILEFORMAT_TIF )
               ITEM "&PNG"          NAME mit_WFPNG_4   ACTION SaveAs ( BT_FILEFORMAT_PNG )
               ITEM "&PDF"          NAME mit_WFPDF_5   ACTION SaveAs ( BTExp_FILEFORMAT_PDF )
            END POPUP // File
            
            ITEM "&Print"           NAME mit_Print     ACTION Pict2Prn()            
            
            ITEM "&Close"           NAME mit_Close     ACTION BTExp_CloseImgFile()
            SEPARATOR
            
            ITEM "E&xit"  ACTION ThisWindow.Release
       
         END POPUP // File

         POPUP '?'                    
            ITEM 'About &BT'  ACTION MsgInfo( BT_InfoName() + Space(3) + ;
                                              BT_InfoVersion() + CRLF + ;
                                              BT_InfoAuthor () + CRLF + ;
                                              "E-MAIL:   srvet@adinet.com.uy" + CRLF + ;
                                              "BLOG:     http://srvet.blogspot.com", "BT Info" )
            ITEM '&Author of sample'  ACTION MsgInfo( "AUTHOR:   B. Esgici "+ CRLF + ;
                                            "E-MAIL:   esgici@gmail.com" + CRLF + ;
                                            "BLOG:     http://vivaclipper.wordpress.com", "Author Info" )
                                           
         END POPUP // Info
         
         @  0, 0 IMAGE imgTestImage PICTURE NIL ACTION NIL
         
      END MENU // MAIN

      DEFINE STATUSBAR FONT 'Verdana' SIZE 8
          STATUSITEM ""
          STATUSITEM ""
          DATE WIDTH 80
          CLOCK WIDTH 90
      END STATUSBAR
      
   END WINDOW // frmBTExp_IC

   
   frmBTExp_IC.mitSaveAs.Enabled := .F.
   frmBTExp_IC.mit_Print.Enabled := .F.
   frmBTExp_IC.mit_Close.Enabled := .F.

   CENTER WINDOW   frmBTExp_IC
   ACTIVATE WINDOW frmBTExp_IC
   
RETURN // BTExplore.Main()


*-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.

PROCEDURE BTExp_CloseImgFile()                 // Close an Image file

   IF hImage <> 0
      frmBTExp_IC.mitSaveAs.Enabled := .F.
      frmBTExp_IC.mit_Print.Enabled := .F.
      frmBTExp_IC.mit_Close.Enabled := .F.
      frmBTExp_IC.StatusBar.Item( 1 ) := ''
      frmBTExp_IC.StatusBar.Item( 2 ) := ''

      BT_BitmapRelease ( hImage )

      BT_HMGSetImage( "frmBTExp_IC", "imgTestImage", 0 )    // Sets a specified bitmap into an Image Control of HMG (@...IMAGE) and automatically
                                                            // releases the handle of the bitmap previously associated to the Image Control
      hImage        := 0
      hImageDisplay := 0
      cImgFilName   := ''
   ENDIF

RETURN


*-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.

PROCEDURE BTExp_SetImageAdjust()
LOCAL New_Width , New_Height

   IF hImage <> 0
      New_Width  := min ( BT_ClientAreaWidth  ( "frmBTExp_IC" ) , BT_BitmapWidth (hImage) )
      New_Height := min ( BT_ClientAreaHeight ( "frmBTExp_IC" ) , BT_BitmapHeight(hImage) )

      hImageDisplay := BT_BitmapCopyAndResize( hImage, New_Width, New_Height, BT_SCALE )

      BT_HMGSetImage( "frmBTExp_IC", "imgTestImage", hImageDisplay )   // Sets a specified bitmap into an Image Control of HMG (@...IMAGE) and automatically
                                                                       // releases the handle of the bitmap previously associated to the Image Control
   ENDIF

RETURN


*-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.

PROCEDURE BTExp_OpenImgFile()                 // Open an Image file


   cImgFilName := Getfile( { {'All images','*.png; *.jpg; *.bmp; *.tif; *.gif'},;    // acFilter
                             {'PNG Files', '*.png'},;
                             {'JPG Files', '*.jpg'},;
                             {'BMP Files', '*.bmp'},;
                             {'TIF Files', '*.tif'},;
                             {'GIF Files', '*.gif'} },;                          
                              'Open Image' ) 

   IF ! EMPTY( cImgFilName ) .OR. FILE( cImgFilName )  

      hImage := BT_BitmapLoadFile( cImgFilName )

      IF hImage <> 0

         BTExp_SetImageAdjust()

         frmBTExp_IC.StatusBar.Item( 1 ) := cImgFilName
         frmBTExp_IC.StatusBar.Item( 2 ) := HB_NTOS( BT_BitmapWidth(hImage) ) +' x '+ HB_NTOS( BT_BitmapHeight(hImage) ) +" pixels"
         frmBTExp_IC.mitSaveAs.Enabled := .T.
         frmBTExp_IC.mit_Print.Enabled := .T.
         frmBTExp_IC.mit_Close.Enabled := .T.
      ELSE
         MsgStop( "Couldn't open " + cImgFilName + " file as a image !"+CRLF+CRLF+;
                  "Not Image File OR unsupported file format ! ", "OPEN ERROR !" )
      ENDIF
      
   ENDIF ! EMPTY( cBMFileName )
   
RETURN // BTExp_OpenImgFile()


*-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.

PROCEDURE SaveAs ( nNewImageType )

   LOCAL cNewImageType,;
         cTargetFileNam,;
         lContinue := .T.
         
   IF ! EMPTY( cImgFilName ) .AND. hImage # 0

      cNewImageType  := SUBSTR( This.Name, 7, 3 )
      cTargetFileNam := LEFT( cImgFilName, LEN( cImgFilName )- 3 ) + cNewImageType

      IF FILE( cTargetFileNam )
          
         lContinue := MsgYesNo( cTargetFileNam + " file exist;" + CRLF + CRLF +;
                                         "OVERWRITE ?", "Confirm Overwrite" )
      ENDIF
      
      IF lContinue                             
         
         IF nNewImageType <> BTExp_FILEFORMAT_PDF
         
            IF BT_BitmapSaveFile( hImage, cTargetFileNam, nNewImageType )
               MsgInfo( "Image saved as " + cNewImageType + " in:" + CRLF + cTargetFileNam )
            ELSE
               MsgInfo( "Saving as " + cNewImageType + " is UNSUCCESSFUL !", "ERROR !")
            ENDIF         
            
         ELSE  // Target is PDF
         
            Pict2PDF( cTargetFileNam )
            
         ENDIF
         
      ENDIF lContinue                             
      
   ENDIF   
   
RETURN // SaveAs()


*-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.

PROCEDURE Pict2PDF( ;
                    cTargetFileNam )             

   LOCAL cTmpFName := TEMPFILE(, "png")
   
   LOCAL nImgOrjWidth,;     
         nImgOrjHeight,;
         nImgPDFWidth,;
         nImgPDFHeight,;
         lSelPDF         

   nImgOrjWidth  := BT_BitmapWidth( hImage )            
   nImgOrjHeight := BT_BitmapHeight( hImage )
   
   nImgPDFWidth  := MIN( nImgOrjWidth / 2.54, 170 )
   
   IF nImgPDFWidth # nImgOrjWidth            
      nImgPDFHeight := nImgOrjHeight / ( nImgOrjWidth / nImgPDFWidth )
   ELSE
      nImgPDFHeight :=  nImgOrjHeight
   ENDIF   
   
   BT_BitmapSaveFile( hImage, cTmpFName, 4 )
   
   SELECT HPDFDOC ( cTargetFileNam ) TO lSelPDF // papersize HPDF_PAPER_A4
   
   IF lSelPDF
      START HPDFDOC
   
         START HPDFPAGE
            @ 20,  20 HPDFPRINT IMAGE cTmpFName WIDTH nImgPDFWidth HEIGHT nImgPDFHeight
         END HPDFPAGE   
      
      END HPDFDOC

      IF FILE( cTargetFileNam )            
         MsgInfo( "PDF Builded as " + cTargetFileNam ) 
      ELSE
         MsgStop( "PDF Building Unsuccessful" + CRLF + CRLF + ;
                  "Please check your folder for file names.", ;                                                     
                  "Unexpected ERROR !" ) 
      ENDIF FILE( cTargetFileNam )                           
      
   ELSE   
      MsgStop( "SELECT PDFDOC is unsuccessful", "ERROR !" )         
   ENDIF lSelPDF
   
   FILEDELETE( cTmpFName )
            
RETURN // Pict2PDF()            


*-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.

PROCEDURE Pict2Prn()                      // ( previously loaded ) Picture -> Print

   LOCAL lSelPrntr
   
   SELECT PRINTER DIALOG TO lSelPrntr PREVIEW
   
   IF lSelPrntr
      START PRINTDOC 
         START PRINTPAGE
               @ 20, 20 PRINT IMAGE cImgFilName;
                        WIDTH  170 ;
                        HEIGHT 170 
         END PRINTPAGE
      END PRINTDOC 
      MsgInfo('Print Picture Finished')
   ELSE   
      MsgBox( "Printing Picture is unsuccessful" )
   ENDIF lSelPrntr
   
RETURN // Pict2Prn()
