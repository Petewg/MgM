/*
 * HMG - Harbour Win32 GUI library Demo
 *
 * Copyright 2016 Dr. Claudio Soto <srvet@adinet.com.uy>
 */

#include "hmg.ch"
#include "Directry.ch"

*------------------------------------------------------------------------------*
Function Main()
*------------------------------------------------------------------------------*

   DEFINE WINDOW Win_1 ;
      CLIENTAREA 400, 300 ;
      TITLE 'MiniPrint Library Test: Insert Page Number' ;
      MAIN 

      @ 50, 50 BUTTON Button_1 CAPTION "Test" ACTION PrintTest() DEFAULT

   END WINDOW
   CENTER WINDOW Win_1
   ACTIVATE WINDOW Win_1

Return Nil


*------------------------------------------------------------------------------*
Procedure PrintTest
*------------------------------------------------------------------------------*
   LOCAL lSuccess

   SELECT PRINTER DIALOG TO lSuccess PREVIEW

   If lSuccess == .F.
      MsgStop('Print Error')
      Return
   EndIf

   // Measure Units Are Millimeters

   START PRINTDOC

         // first page
         START PRINTPAGE

            @ 20,20 PRINT "Filled Rectangle Sample:" ;
               FONT "Arial" ;
               SIZE 20 

            @ 30,20 PRINT RECTANGLE ;
               TO 40,190 ;
               PENWIDTH 0.1;
               COLOR {255,255,0}

            @ 60,20 PRINT RECTANGLE ;
               TO 100,190 ;
               PENWIDTH 0.1;
               COLOR {255,255,0};
               FILLED

            @ 110,20 PRINT RECTANGLE ;
               TO 150,190 ;
               PENWIDTH 0.1;
               COLOR {255,255,0};
               ROUNDED

            @ 160,20 PRINT RECTANGLE ;
               TO 200,190 ;
               PENWIDTH 0.1;
               COLOR {255,255,0};
               FILLED;
               ROUNDED

         END PRINTPAGE

         // second page
         START PRINTPAGE

            @ 20,20 PRINT "Filled Rectangle Sample:" ;
               FONT "Arial" ;
               SIZE 20 

            @ 30,20 PRINT RECTANGLE ;
               TO 40,190 ;
               PENWIDTH 0.1

            @ 60,20 PRINT RECTANGLE ;
               TO 100,190 ;
               PENWIDTH 0.1;
               FILLED

            @ 110,20 PRINT RECTANGLE ;
               TO 150,190 ;
               PENWIDTH 0.1;
               ROUNDED

            @ 160,20 PRINT RECTANGLE ;
               TO 200,190 ;
               PENWIDTH 0.1;
               FILLED;
               ROUNDED

         END PRINTPAGE

         // call this function after a last END PRINTPAGE and before END PRINTDOC command
         ProcInsertPageNumber( OpenPrinterGetDC() )

   END PRINTDOC

Return


************************************************************************************************************

PROCEDURE ProcInsertPageNumber( hDC )
   LOCAL cFuncNameCallBack := "ProcDrawEMFCallBack"
   LOCAL cFoldPrefix := GetTempFolder() + "\"
   LOCAL cNamePrefix := cFoldPrefix + _hmg_printer_timestamp + "_hmg_print_preview_"
   LOCAL aFiles :=  DIRECTORY( cNamePrefix + "*.EMF" )
   LOCAL cFileNameOld, cFileNameNew, i, nError
   MEMVAR nPageNumber
   PRIVATE nPageNumber := 1

   FOR i := 1 TO LEN( aFiles ) 
      cFileNameOld := cFoldPrefix + aFiles [ i ] [ F_NAME ]
      cFileNameNew := cFoldPrefix + "New_" + aFiles [ i ] [ F_NAME ]
      nError := BT_DrawEMF( hDC, cFileNameOld, cFileNameNew, cFuncNameCallBack )
      IF nError == 0
         FERASE( cFileNameOld ) 
         FRENAME( cFileNameNew, cFileNameOld )
      ELSE
         MsgStop("Error ("+ hb_NtoS( nError ) +") in write into EMF: " + cFileNameOld )
      ENDIF
   NEXT

RETURN


*************************************************************************************************************

FUNCTION ProcDrawEMFCallBack( hDC, leftMM, topMM, rightMM, bottomMM, leftPx, topPx, rightPx, bottomPx, IsParamHDC )  // rectangle that bounded the area to draw, in milimeters and pixels
   LOCAL Old_PageDC := OpenPrinterGetPageDC()

   HB_SYMBOL_UNUSED( leftMM )
   HB_SYMBOL_UNUSED( bottomMM )
   HB_SYMBOL_UNUSED( leftPx )
   HB_SYMBOL_UNUSED( topPx)
   HB_SYMBOL_UNUSED( rightPx)
   HB_SYMBOL_UNUSED( bottomPx)
   HB_SYMBOL_UNUSED( IsParamHDC )

   OpenPrinterGetPageDC() := hDC
   @ topMM + 15, rightMM - 65 PRINT "Page Number: " + hb_NtoS( M->nPageNumber++ ) + " of " + hb_NtoS( _hmg_printer_PageCount ) FONT "Arial" SIZE 12
   OpenPrinterGetPageDC() := Old_PageDC

RETURN NIL



#pragma BEGINDUMP

#include <mgdefs.h>
#include "hbvm.h"


//**********************************************************************************************************************
//* BT_DrawEMF ( [ hDC ] , cFileNameOld , cFileNameNew , cFuncNameCallBack )  --->  Return nError, e.g. Zero is OK
//**********************************************************************************************************************

HB_FUNC( BT_DRAWEMF )
{
   HDC     hDC = ( HDC ) HB_PARNL( 1 );
   TCHAR * cFileNameOld      = ( TCHAR * ) hb_parc( 2 );
   TCHAR * cFileNameNew      = ( TCHAR * ) hb_parc( 3 );
   CHAR *  cFuncNameCallBack = ( CHAR * ) hb_parc( 4 );

   HB_BOOL IsParamHDC = ( hDC ? HB_TRUE : HB_FALSE );

   HDC hDC_EMF;
   HENHMETAFILE hEMF_Old = NULL;
   HENHMETAFILE hEMF_New;

   ENHMETAHEADER emh;
   HRSRC         hResourceData;
   HGLOBAL       hGlobalResource;
   LPVOID        lpGlobalResource;
   DWORD         nFileSize;

   INT iWidthMM;
   INT iHeightMM;
   INT iWidthPx;
   INT iHeightPx;

   PHB_DYNS pDynSym = hb_dynsymFindName( cFuncNameCallBack );

   if( pDynSym == NULL )
   {
      hb_retni( 1 );
      return;
   }

   // Load MetaFile from Resource
   hResourceData = FindResource( NULL, cFileNameOld, "EMF" );
   if( hResourceData )
   {
      hGlobalResource = LoadResource( NULL, hResourceData );
      if( hGlobalResource )
      {
         lpGlobalResource = LockResource( hGlobalResource );
         nFileSize        = SizeofResource( NULL, hResourceData );
         hEMF_Old         = SetEnhMetaFileBits( nFileSize, lpGlobalResource );
      }
   }

   // If fail, load MetaFile from Disk
   if( hEMF_Old == NULL )
      hEMF_Old = GetEnhMetaFile( cFileNameOld );

   // If fail load from Resource and Disk return False
   if( hEMF_Old == NULL )
   {
      hb_retni( 2 );
      return;
   }

   // Get the header of MetaFile
   ZeroMemory( &emh, sizeof( ENHMETAHEADER ) );
   emh.nSize = sizeof( ENHMETAHEADER );
   if( GetEnhMetaFileHeader( hEMF_Old, sizeof( ENHMETAHEADER ), &emh ) == 0 )
   {
      DeleteEnhMetaFile( hEMF_Old );
      hb_retni( 3 );
      return;
   }

   if( IsParamHDC )
      hDC_EMF = CreateEnhMetaFile( hDC, cFileNameNew, ( RECT * ) &emh.rclFrame, "" );
   else
   {
      hDC       = GetDC( NULL );
      iWidthMM  = GetDeviceCaps( hDC, HORZSIZE );
      iHeightMM = GetDeviceCaps( hDC, VERTSIZE );
      iWidthPx  = GetDeviceCaps( hDC, HORZRES  );
      iHeightPx = GetDeviceCaps( hDC, VERTRES  );
      hDC_EMF   = CreateEnhMetaFile( hDC, cFileNameNew, ( RECT * ) &emh.rclFrame, "" );

      if( hDC_EMF == NULL )
         ReleaseDC( NULL, hDC );

      emh.rclBounds.left   = ( emh.rclFrame.left / 100 ) * iWidthPx / iWidthMM;
      emh.rclBounds.top    = ( emh.rclFrame.top / 100 ) * iHeightPx / iHeightMM;
      emh.rclBounds.right  = ( emh.rclFrame.right / 100 ) * iWidthPx / iWidthMM;
      emh.rclBounds.bottom = ( emh.rclFrame.bottom / 100 ) * iHeightPx / iHeightMM;
   }

   if( hDC_EMF == NULL )
   {
      DeleteEnhMetaFile( hEMF_Old );
      hb_retni( 4 );
      return;
   }

   // Play Old MetaFile into New MetaFile
   PlayEnhMetaFile( hDC_EMF, hEMF_Old, ( RECT * ) &emh.rclBounds );

   hb_vmPushSymbol( hb_dynsymSymbol( pDynSym ) );
   hb_vmPushNil();                                        // places NIL at Self
   hb_vmPushNumInt( ( LONG_PTR ) hDC_EMF );
   hb_vmPushLong( ( LONG ) emh.rclFrame.left / 100 );     // push values in milimeters
   hb_vmPushLong( ( LONG ) emh.rclFrame.top / 100 );
   hb_vmPushLong( ( LONG ) emh.rclFrame.right / 100 );
   hb_vmPushLong( ( LONG ) emh.rclFrame.bottom / 100 );
   hb_vmPushLong( ( LONG ) emh.rclBounds.left   );        // push values in pixels
   hb_vmPushLong( ( LONG ) emh.rclBounds.top    );
   hb_vmPushLong( ( LONG ) emh.rclBounds.right  );
   hb_vmPushLong( ( LONG ) emh.rclBounds.bottom );
   hb_vmPushLogical( ( BOOL ) IsParamHDC );
   hb_vmDo( 1 + 4 + 4 + 1 );

   // Release hDC
   hEMF_New = CloseEnhMetaFile( hDC_EMF );

   // Release handles
   DeleteEnhMetaFile( hEMF_Old );
   DeleteEnhMetaFile( hEMF_New );

   if( IsParamHDC == FALSE )
      ReleaseDC( NULL, hDC );

   hb_retni( S_OK );   // OK status
}

#pragma ENDDUMP
