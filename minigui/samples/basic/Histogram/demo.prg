/*
 * MINIGUI - Harbour Win32 GUI library Demo
 *
 * Copyright 2002-05 Roberto Lopez <harbourminigui@gmail.com>
 * http://harbourminigui.googlepages.com/
 *
 * Copyright 2006 MigSoft <fugaz_cl@yahoo.es>
*/

#include <hmg.ch>

#xtranslate PRINT GRAPH [ OF ] <windowname> ;
	[ <lpreview : PREVIEW> ] ;
	[ <ldialog : DIALOG> ] ;
	=>;
	printgraph ( <"windowname"> , <.lpreview.> , <.ldialog.> )

Static aSer, aClr, aSern, aYVal, cTit

*-----------------------------------------------------------------------------*
Function Main
*-----------------------------------------------------------------------------*
   Set Navigation extended
   Load Window Grafico
   Center Window Grafico
   Activate Window Grafico
Return Nil

*-----------------------------------------------------------------------------*
Procedure Presenta(nTipo)
*-----------------------------------------------------------------------------*
   Do Case
      Case nTipo = 0       //  Histogram

           aSer:= {{Grafico.Text_5.value,Grafico.Text_9.value,Grafico.Text_13.value}, ;
                   {Grafico.Text_6.value,Grafico.Text_10.value,Grafico.Text_14.value},;
                   {Grafico.Text_7.value,Grafico.Text_11.value,Grafico.Text_15.value},;
                   {Grafico.Text_8.value,Grafico.Text_12.value,Grafico.Text_16.value} }

           aClr:= {Grafico.Label_5.Fontcolor,Grafico.Label_6.Fontcolor, ;
                   Grafico.Label_7.Fontcolor,Grafico.Label_8.Fontcolor}

           aSern:={Grafico.Text_1.value,Grafico.Text_2.value, ;
                   Grafico.Text_3.value,Grafico.Text_4.value }

           aYVal:={Grafico.Text_17.value,Grafico.Text_18.value,Grafico.Text_19.value }

           cTit:= Grafico.Text_20.value

           Set Font To "Arial", 14
           Load Window Veamos
           On Key Escape Of Veamos Action Veamos.Release
           Center Window Veamos
           Activate Window Veamos

      Case nTipo = 1       //  Pie 1

           cTit:= Grafico.Text_1.value
           aSer:= {Grafico.Text_5.value,Grafico.Text_9.value,Grafico.Text_13.value}

      Case nTipo = 2       //  Pie 2

           cTit:= Grafico.Text_2.value
           aSer:= {Grafico.Text_6.value,Grafico.Text_10.value,Grafico.Text_14.value}

      Case nTipo = 3       //  Pie 3

           cTit:= Grafico.Text_3.value
           aSer:= {Grafico.Text_7.value,Grafico.Text_11.value,Grafico.Text_15.value}

      Case nTipo = 4       //  Pie 4

           cTit:= Grafico.Text_4.value
           aSer:= {Grafico.Text_8.value,Grafico.Text_12.value,Grafico.Text_16.value}

      Case nTipo = 5       //  Pie 5

           cTit:= Grafico.Text_17.value
           aSer:= {Grafico.Text_5.value,Grafico.Text_6.value,;
                   Grafico.Text_7.value,Grafico.Text_8.value }

      Case nTipo = 6       //  Pie 6

           cTit:= Grafico.Text_18.value
           aSer:= {Grafico.Text_9.value ,Grafico.Text_10.value,;
                   Grafico.Text_11.value,Grafico.Text_12.value }

      Case nTipo = 7       //  Pie 7

           cTit:= Grafico.Text_19.value
           aSer:= {Grafico.Text_13.value,Grafico.Text_14.value,;
                   Grafico.Text_15.value,Grafico.Text_16.value }

   EndCase

   If nTipo > 0 .and. nTipo < 8
      IF nTipo < 5
         aYVal:={Grafico.Text_17.value,Grafico.Text_18.value,Grafico.Text_19.value}
         aClr:= {Grafico.Label_3.Fontcolor,Grafico.Label_4.Fontcolor, ;
                                           Grafico.Label_11.Fontcolor }
      Else
          aYVal:={Grafico.Text_1.value,Grafico.Text_2.value,;
                  Grafico.Text_3.value,Grafico.Text_4.value }
          aClr:= {Grafico.Label_5.Fontcolor,Grafico.Label_6.Fontcolor,;
                  Grafico.Label_7.Fontcolor,Grafico.Label_8.Fontcolor }
      Endif
      Set Font To "Arial", 12
      Load Window Veamos2
      Center Window Veamos2
      Activate Window Veamos2
   Endif

Return
*-----------------------------------------------------------------------------*
Procedure elGrafico()
*-----------------------------------------------------------------------------*
Local nTop := 20, nLeft := 20, nBottom := 400, nRight := 610

	ERASE WINDOW Veamos

	DRAW GRAPH							;
		IN WINDOW Veamos                                        ;
		AT nTop, nLeft						;
		TO nBottom, nRight					;
		TITLE cTit                                              ;
		TYPE BARS						;
		SERIES aSer                                             ;
  		YVALUES aYval                                           ;
		DEPTH 15						;
		BARWIDTH 15						;
		HVALUES 5						;
		SERIENAMES aSern                                        ;
		COLORS aClr                                             ;
		3DVIEW    						;
		SHOWGRID                        			;
		SHOWXVALUES                     			;
		SHOWYVALUES                     			;
		SHOWLEGENDS 						;
		NOBORDER DATAMASK "9999"

	App.Cargo := { nTop , nLeft , nRight - nLeft , nBottom - nTop }

Return
*-----------------------------------------------------------------------------*
Procedure PieGraph()
*-----------------------------------------------------------------------------*

   ERASE Window Veamos2

   DRAW GRAPH IN WINDOW Veamos2 AT 20,20 TO 400,610	;
        TITLE cTit TYPE PIE				;
        SERIES aSer					;
        DEPTH 15					;
        SERIENAMES aYVal				;
        COLORS aClr					;
        3DVIEW						;
        SHOWXVALUES					;
        SHOWLEGENDS					;
	NOBORDER

Return
*-----------------------------------------------------------------------------*
Function printgraph ( cWindowName , lPreview , lDialog )
*-----------------------------------------------------------------------------*
local aLocation

	If .Not. _IsWindowDefined ( cWindowName )
		MsgMiniGUIError("Window: "+ cWindowName + " is not defined." )
	Endif

	If ValType ( App.Cargo ) <> 'A' .And. Len ( App.Cargo ) <> 4
		MsgMiniGUIError ("Window: "+ cWindowName + " have not a graph.")
	Endif

	if valtype ( lPreview ) = 'U'
		lPreview := .F.
	endif

	if valtype ( lDialog ) = 'U'
		lDialog := .F.
	endif

	aLocation := App.Cargo

	PrintWindow ( cWindowName , lPreview , lDialog , aLocation [1] , aLocation [2] , aLocation [3] , aLocation [4] )

return nil

*------------------------------------------------------------------------------*
FUNCTION PrintWindow ( cWindowName , lPreview , ldialog , nRow , nCol , nWidth , nHeight )
*------------------------------------------------------------------------------*
LOCAL lSuccess
LOCAL TempName 
LOCAL W
LOCAL H
LOCAL HO
LOCAL VO
LOCAL bw , bh , r , tw , th
LOCAL ntop , nleft , nbottom , nright

	if	valtype ( nRow ) == 'U' ;
		.or. ;
		valtype ( nCol ) == 'U' ;
		.or. ;
		valtype ( nWidth ) == 'U' ;
		.or. ;
		valtype ( nHeight ) == 'U' 

		ntop	:= -1
		nleft	:= -1
		nbottom	:= -1
		nright	:= -1

	else

		ntop	:= nRow
		nleft	:= nCol
		nbottom	:= nHeight + nRow
		nright	:= nWidth + nCol

	endif

	if ValType ( lDialog ) == 'U'
		lDialog	:= .F.
	endif

	if ValType ( lPreview ) == 'U'
		lPreview := .F.
	endif

	if lDialog 

		IF lPreview
			SELECT PRINTER DIALOG TO lSuccess PREVIEW
		ELSE
			SELECT PRINTER DIALOG TO lSuccess 
		ENDIF

		IF ! lSuccess
			RETURN NIL
		ENDIF
	
	else

		IF lPreview
			SELECT PRINTER DEFAULT TO lSuccess PREVIEW ORIENTATION PRINTER_ORIENT_LANDSCAPE
		ELSE
			SELECT PRINTER DEFAULT TO lSuccess 
		ENDIF

		IF ! lSuccess
			MSGMINIGUIERROR ( "Can't Init Printer." )
		ENDIF

	endif

	if ! _IsWIndowDefined ( cWindowName )
		MSGMINIGUIERROR ( 'Window Not Defined.' )
	endif

	TempName := GetTempFolder() + '\_hmg_printwindow_' + alltrim(str(int(seconds()*100))) + '.bmp' 

	SAVEWINDOWBYHANDLE ( GetFormHandle ( cWindowName ) , TempName , ntop , nleft , nbottom , nright )

	HO := GETPRINTABLEAREAHORIZONTALOFFSET()
	VO := GETPRINTABLEAREAVERTICALOFFSET()

	W := GETPRINTABLEAREAWIDTH() - 10 - ( HO * 2 ) 
	H := GETPRINTABLEAREAHEIGHT() - 10 - ( VO * 2 ) 

	if ntop == -1

		bw := GetProperty ( cWindowName , 'Width' ) 
		bh := GetProperty ( cWindowName , 'Height' ) - GetTitleHeight ()

	else

		bw := nright - nleft
		bh := nbottom - ntop

	endif


	r := bw / bh

	tw := 0
	th := 0

	do while .t.

		tw ++	
		th := tw / r 

		if tw > w .or. th > h
			exit
		endif

	enddo

	START PRINTDOC

		START PRINTPAGE

			@ VO + 10 + ( ( h - th ) / 2 ) , HO + 10 + ( ( w - tw ) / 2 ) PRINT IMAGE TempName WIDTH tW HEIGHT tH 

		END PRINTPAGE

	END PRINTDOC

	 DoEvents()
	Ferase(TempName)

RETURN NIL


#pragma BEGINDUMP

#define _WIN32_WINNT  0x0400

#include <windows.h>
#include "hbapi.h"

///////////////////////////////////////////////////////////////////////////////
// SAVE WINDOW (Based On Code Contributed by Ciro Vargas Clemov)
///////////////////////////////////////////////////////////////////////////////

HANDLE ChangeBmpFormat( HBITMAP, HPALETTE );
WORD GetDIBColors( LPSTR lpDIB );

HB_FUNC( SAVEWINDOWBYHANDLE ) 
{

	HWND				hWnd	= ( HWND ) hb_parnl( 1 );
	HDC				hDC	= GetDC( hWnd );
	HDC				hMemDC ;
	RECT				rc ;
	HBITMAP				hBitmap ;
	HBITMAP				hOldBmp ;
	HPALETTE			hPal = 0;
	const char * 			File	= hb_parc(2) ;
	HANDLE				hDIB ;
	int				top	= hb_parni(3) ;
	int				left	= hb_parni(4) ;
	int				bottom	= hb_parni(5) ;
	int				right	= hb_parni(6) ;
	BITMAPFILEHEADER		bmfHdr ;     
	LPBITMAPINFOHEADER		lpBI ;       
	HANDLE				filehandle ;         
	DWORD				dwDIBSize ;
	DWORD				dwWritten ;
	DWORD				dwBmBitsSize ;

	if ( top != -1 && left != -1 && bottom != -1 && right != -1 )
	{
		rc.top = top ;
		rc.left = left ;
		rc.bottom = bottom ;
		rc.right = right ;
	}
	else
	{
		GetClientRect( hWnd, &rc );
	}

	hMemDC  = CreateCompatibleDC( hDC );
	hBitmap = CreateCompatibleBitmap( hDC, rc.right-rc.left, rc.bottom-rc.top );
	hOldBmp = ( HBITMAP ) SelectObject( hMemDC, hBitmap );
	BitBlt( hMemDC, 0, 0 , rc.right-rc.left, rc.bottom-rc.top, hDC, rc.top, rc.left, SRCCOPY );
	SelectObject( hMemDC, hOldBmp );
	hDIB = ChangeBmpFormat(hBitmap ,hPal);

	filehandle = CreateFile( File , GENERIC_WRITE, 0, NULL, CREATE_ALWAYS, FILE_ATTRIBUTE_NORMAL | FILE_FLAG_SEQUENTIAL_SCAN, NULL);

	lpBI = (LPBITMAPINFOHEADER)GlobalLock(hDIB);
	if (!lpBI)
	{
		CloseHandle(filehandle);
		return;
	}

	if (lpBI->biSize != sizeof(BITMAPINFOHEADER))
	{
		GlobalUnlock(hDIB);
		CloseHandle(filehandle);
		return;
	}

	bmfHdr.bfType = ((WORD) ('M' << 8) | 'B'); 

	dwDIBSize = *(LPDWORD)lpBI + ( GetDIBColors( (LPSTR) lpBI ) * sizeof(RGBTRIPLE)) ;

	dwBmBitsSize = ((((lpBI->biWidth)*((DWORD)lpBI->biBitCount))+ 31) / 32 * 4) *  lpBI->biHeight;
	dwDIBSize += dwBmBitsSize;
	lpBI->biSizeImage = dwBmBitsSize;
                   
	bmfHdr.bfSize = dwDIBSize + sizeof(BITMAPFILEHEADER);
	bmfHdr.bfReserved1 = 0;
	bmfHdr.bfReserved2 = 0;

	bmfHdr.bfOffBits = (DWORD)sizeof(BITMAPFILEHEADER) + lpBI->biSize + ( GetDIBColors( (LPSTR) lpBI ) * sizeof(RGBTRIPLE)) ;

	WriteFile(filehandle, (LPSTR)&bmfHdr, sizeof(BITMAPFILEHEADER), &dwWritten, NULL);
   
	WriteFile(filehandle, (LPSTR)lpBI, dwDIBSize, &dwWritten, NULL);

	GlobalUnlock(hDIB);
	CloseHandle(filehandle);

	DeleteObject( hBitmap );
	DeleteDC( hMemDC );
	GlobalFree (hDIB);
	ReleaseDC( hWnd, hDC );

}

#pragma ENDDUMP
