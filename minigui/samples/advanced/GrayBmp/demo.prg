/*
 * MINIGUI - Harbour Win32 GUI library
 *
 * Copyright 2002-2010 Roberto Lopez <harbourminigui@gmail.com>
 * http://harbourminigui.googlepages.com/
 *
 * Copyright 2005-2013 Grigory Filatov <gfilatov@inbox.ru>
*/

#include "minigui.ch"

Procedure Main
  
Local cImage := 'demo.bmp', lDisable := .F.

	DEFINE WINDOW Form_1 ;
		AT 0,0 ;
		WIDTH 640 ;
		HEIGHT 480 ;
		TITLE 'Hello World!' ;
		MAIN ;
		ON PAINT IF(lDisable, GrayBmp( GetControlHandle( "Image_1", "Form_1" ), cImage, Form_1.Image_1.Width, Form_1.Image_1.Height ), ) ;
		ON GOTFOCUS IF(lDisable, GrayBmp( GetControlHandle( "Image_1", "Form_1" ), cImage, Form_1.Image_1.Width, Form_1.Image_1.Height ), ) ;
		ON LOSTFOCUS IF(lDisable, GrayBmp( GetControlHandle( "Image_1", "Form_1" ), cImage, Form_1.Image_1.Width, Form_1.Image_1.Height ), )

		DEFINE MAIN MENU
			POPUP 'File'
				ITEM 'Select Image' ACTION ( cImage := Getfile ( { {'BMP Files','*.bmp'} }, ;
					'Select Image' ), Form_1.Image_1.Picture := cImage )
				SEPARATOR
				ITEM 'Disable Image' ACTION ( lDisable := .t., cImage := Form_1.Image_1.Picture, ;
					GrayBmp( GetControlHandle( "Image_1", "Form_1" ), cImage, Form_1.Image_1.Width, Form_1.Image_1.Height ) )
				ITEM 'Enable Image' ACTION ( lDisable := .F., Form_1.Image_1.Picture := cImage )
			END POPUP
		END MENU

		DEFINE IMAGE Image_1
			ROW	80
			COL	80
			PICTURE	cImage
			STRETCH	.F.
		END IMAGE

	END WINDOW

	CENTER WINDOW Form_1

	ACTIVATE WINDOW Form_1 

Return


#pragma BEGINDUMP

#include <windows.h>
#include "hbapi.h"

/*
	DitherBlt :	Draw a bitmap dithered (disabled) into a destination DC

	hdcDest :	destination DC
	nXDest :	x coordinate of the upper left corner of the destination rectangle into the DC
	nYDest :	y coordinate of the upper left corner of the destination rectangle into the DC
	nWidth :	width of the destination rectangle into the DC
	nHeight :	height of the destination rectangle into the DC
	hbm :		the bitmap to draw (as a part or as a whole)
	nXSrc :	x coordinates of the upper left corner of the source rectangle into the bitmap
	nYSrc :	y coordinates of the upper left corner of the source rectangle into the bitmap
*/

typedef struct
{
   BITMAPINFOHEADER bmiHeader; 
   RGBQUAD          bmiColors[2]; 
} RGBBWBITMAPINFO;

void DitherBlt (HDC hdcDest, int nXDest, int nYDest, int nWidth, int nHeight, HBITMAP hbm, int nXSrc, int nYSrc)
{
	RGBBWBITMAPINFO bmi;
	VOID *pbitsBW;
	HBITMAP hbmBW;
	RECT rct;
	HBRUSH hb;
	HBRUSH oldBrush;

	// Create a generic DC for all BitBlts
	HDC hDC = CreateCompatibleDC(hdcDest);

	if (hDC)
	{
		// Create a DC for the monochrome DIB section
		HDC bwDC = CreateCompatibleDC(hDC);

		if (bwDC)
		{
			// Create the monochrome DIB section with a black and white palette
			bmi.bmiHeader.biSize  = sizeof(BITMAPINFOHEADER);
			bmi.bmiHeader.biWidth = nWidth;
			bmi.bmiHeader.biHeight = nHeight;
			bmi.bmiHeader.biPlanes = 1;
			bmi.bmiHeader.biBitCount = 1;
			bmi.bmiHeader.biCompression = BI_RGB;
			bmi.bmiHeader.biSizeImage = 0;
			bmi.bmiHeader.biXPelsPerMeter = 0;
			bmi.bmiHeader.biYPelsPerMeter = 0;
			bmi.bmiHeader.biClrUsed = 0;
			bmi.bmiHeader.biClrImportant = 0;

			bmi.bmiColors[1].rgbRed   =	0x00;
			bmi.bmiColors[1].rgbGreen =	0x00;
			bmi.bmiColors[1].rgbBlue  =	0x00;
			bmi.bmiColors[2].rgbRed   =	0xFF;
			bmi.bmiColors[2].rgbGreen =	0xFF;
			bmi.bmiColors[2].rgbBlue  =	0xFF;

			hbmBW = CreateDIBSection(bwDC, (LPBITMAPINFO)&bmi, DIB_RGB_COLORS, &pbitsBW, NULL, 0);
			
			if (hbmBW)
			{
				// Attach the monochrome DIB section and the bitmap to the DCs
				SelectObject(bwDC, hbmBW);
				SelectObject(hDC, hbm);

				// BitBlt the bitmap into the monochrome DIB section
				BitBlt(bwDC, 0, 0, nWidth, nHeight, hDC, nXSrc, nYSrc, SRCCOPY);

				rct.top    = nXDest;
				rct.left   = nYDest;
				rct.bottom = nXDest + nWidth;
				rct.right  = nYDest + nHeight;
				// Paint the destination rectangle in gray
				FillRect(hdcDest, &rct, GetSysColorBrush(COLOR_3DFACE));
				
				// BitBlt the black bits in the monochrome bitmap into COLOR_3DHILIGHT bits in the destination DC
				// The magic ROP comes from the Charles Petzold's book
				hb = CreateSolidBrush(GetSysColor(COLOR_3DHILIGHT));
				oldBrush = (HBRUSH)SelectObject(hdcDest, hb);
				BitBlt(hdcDest, nXDest + 1, nYDest + 1, nWidth, nHeight, bwDC, 0, 0, 0xB8074A);

				// BitBlt the black bits in the monochrome bitmap into COLOR_3DSHADOW bits in the destination DC
				hb = CreateSolidBrush(GetSysColor(COLOR_3DSHADOW));
				DeleteObject(SelectObject(hdcDest, hb));
				BitBlt(hdcDest, nXDest, nYDest, nWidth, nHeight, bwDC, 0, 0, 0xB8074A);
				DeleteObject(SelectObject(hdcDest, oldBrush));
			}

			DeleteDC(bwDC);
		}

		DeleteDC(hDC);
	}
}

HB_FUNC( GRAYBMP )
{
   HWND hWnd = ( HWND ) hb_parnl( 1 );
   HDC  hDC  = GetDC( hWnd );
   HBITMAP hBitmap;
   BITMAP bm;

   hBitmap = (HBITMAP)LoadImage(0,hb_parc(2),IMAGE_BITMAP,0,0,LR_LOADFROMFILE|LR_CREATEDIBSECTION);
   if (hBitmap==NULL)
       hBitmap = (HBITMAP)LoadImage(GetModuleHandle(NULL),hb_parc(2),IMAGE_BITMAP,0,0,LR_CREATEDIBSECTION);

   if (hBitmap!=NULL)
       {
		GetObject(hBitmap, sizeof(BITMAP), &bm);
		DitherBlt(hDC, 0, 0, (hb_pcount() > 2) ? hb_parni(3) : bm.bmWidth, (hb_pcount() > 3) ? hb_parni(4) : bm.bmHeight, hBitmap, 0, 0);
	}
   ReleaseDC( hWnd, hDC );
   DeleteObject( hBitmap );
}

#pragma ENDDUMP
