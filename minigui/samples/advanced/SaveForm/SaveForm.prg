/*
  Author..........: Mr. Grigory Filatov
  Contributions...: Mr. Ciro Vargas Clemov
  Adaptations.....: BP Dave
*/

#include "minigui.ch"

*------------------------------------------------------------------------------*
FUNCTION SaveForm ( cWindowName , cFileName , nRow , nCol , nWidth , nHeight )
*------------------------------------------------------------------------------*
Local ntop , nleft , nbottom , nright

   if valtype ( cFileName ) = 'U'
      cFileName := GetStartupFolder() + '\' + cWindowName + '.bmp'
   endif

   if   valtype ( nRow ) = 'U' ;
      .or. ;
      valtype ( nCol ) = 'U' ;
      .or. ;
      valtype ( nWidth ) = 'U' ;
      .or. ;
      valtype ( nHeight ) = 'U' 

      ntop   := -1
      nleft   := -1
      nbottom   := -1
      nright   := -1

   else

      ntop   := nRow
      nleft   := nCol
      nbottom   := nHeight + nRow
      nright   := nWidth + nCol

   endif

   SAVEWINDOWBYHANDLE ( GetFormHandle ( cWindowName ) , cFileName , ntop , nleft , nbottom , nright )

RETURN NIL

#pragma BEGINDUMP

#define HB_OS_WIN_32_USED
#define _WIN32_WINNT  0x0400

#include <shlobj.h>
#include <windows.h>
#include <winuser.h>
#include <wingdi.h>
#include "hbapi.h"
#include "hbvm.h"
#include "hbstack.h"
#include "hbapiitm.h"
#include "commctrl.h"

///////////////////////////////////////////////////////////////////////////////
// SAVE WINDOW (Based On Code Contributed by Ciro Vargas Clemov)
///////////////////////////////////////////////////////////////////////////////

HANDLE ChangeBmpFormat(HBITMAP , HPALETTE );
WORD GetDIBColors(LPSTR lpDIB) ;

HB_FUNC( SAVEWINDOWBYHANDLE ) 
{

   HWND            hWnd   = ( HWND ) hb_parnl( 1 );
   HDC            hDC   = GetDC( hWnd );
   HDC            hMemDC ;
   RECT            rc ;
   HBITMAP         hBitmap ;
   HBITMAP         hOldBmp ;
   HPALETTE         hPal;
   LPSTR            File   = hb_parc(2) ;
   HANDLE         hDIB ;
   int            top   = hb_parni(3) ;
   int            left   = hb_parni(4) ;
   int            bottom   = hb_parni(5) ;
   int            right   = hb_parni(6) ;
   BITMAPFILEHEADER      bmfHdr ;     
   LPBITMAPINFOHEADER   lpBI ;       
   HANDLE         filehandle ;         
   DWORD            dwDIBSize ;
   DWORD            dwWritten ;
   DWORD            dwBmBitsSize ;

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

   DeleteDC( hMemDC );
   GlobalFree (hDIB);
   ReleaseDC( hWnd, hDC );

}

// HANDLE ChangeBmpFormat(HBITMAP hBitmap, HPALETTE hPal) 
// {

   // BITMAP              bm;         
   // BITMAPINFOHEADER    bi;         
   // LPBITMAPINFOHEADER  lpbi;       
   // DWORD               dwLen;      
   // HGLOBAL             hDIB;
   // HGLOBAL             h;
   // HDC                 hDC;        
   // WORD                biBits;     

   // if (!hBitmap)
   // {
      // return 0 ;
   // }

   // if (!GetObject(hBitmap, sizeof(bm), (LPSTR)&bm))
   // {
      // return 0 ;
   // }

   // if ( hPal == 0 )
   // {
      // hPal = GetStockObject(DEFAULT_PALETTE);
   // }

   // biBits = bm.bmPlanes * bm.bmBitsPixel ;

   // if (biBits <= 1)
   // {
      // biBits = 1;
   // }
   // else if (biBits <= 4)
   // {
      // biBits = 4;
   // }
   // else if (biBits <= 8)
   // {
      // biBits = 8;
   // }
   // else  
   // {
           // biBits = 24;
   // }

   // bi.biSize = sizeof(BITMAPINFOHEADER);
   // bi.biWidth = bm.bmWidth;
   // bi.biHeight = bm.bmHeight;
   // bi.biPlanes = 1;
   // bi.biBitCount = biBits;
   // bi.biCompression = BI_RGB;
   // bi.biSizeImage = 0;
   // bi.biXPelsPerMeter = 0;
   // bi.biYPelsPerMeter = 0;
   // bi.biClrUsed = 0;
   // bi.biClrImportant = 0;

   // dwLen = bi.biSize + ( GetDIBColors( (LPSTR)&bi ) * sizeof ( RGBTRIPLE ) ) ;

   // hDC = GetDC(NULL);

   // hPal = SelectPalette(hDC, hPal, FALSE);
   // RealizePalette(hDC);

   // hDIB = GlobalAlloc(GHND, dwLen);

   // if (!hDIB)
   // {
      // SelectPalette(hDC, hPal, TRUE);
      // RealizePalette(hDC);
      // ReleaseDC(NULL, hDC);
      // return 0;
   // }

   // lpbi = (LPBITMAPINFOHEADER)GlobalLock(hDIB);

   // *lpbi = bi;

   // GetDIBits(hDC, hBitmap, 0, (UINT)bi.biHeight, NULL, (LPBITMAPINFO)lpbi,DIB_RGB_COLORS);

   // bi = *lpbi;
   // GlobalUnlock(hDIB);

   // if (bi.biSizeImage == 0)
   // {
      // bi.biSizeImage = ((((DWORD)bm.bmWidth * biBits)+ 31) / 32 * 4) * bm.bmHeight;
   // }

   // dwLen = bi.biSize + ( GetDIBColors( (LPSTR)&bi ) * sizeof(RGBTRIPLE)) + bi.biSizeImage;

   // h = GlobalReAlloc( hDIB, (SIZE_T) dwLen, 0);
   // if ( h )
   // {
      // hDIB = h;
   // }
   // else
   // {
      // GlobalFree(hDIB);
      // hDIB = NULL;
      // SelectPalette(hDC, hPal, TRUE);
      // RealizePalette(hDC);
      // ReleaseDC(NULL, hDC);
      // return hDIB;
   // }

   // lpbi = (LPBITMAPINFOHEADER)GlobalLock(hDIB);

   // if (GetDIBits(hDC, hBitmap, 0, (UINT)bi.biHeight, (LPSTR)lpbi + (WORD)lpbi->biSize + ( GetDIBColors ((LPSTR)lpbi) * sizeof(RGBTRIPLE)) , (LPBITMAPINFO)lpbi, DIB_RGB_COLORS) == 0)
   // {
      // GlobalFree(hDIB);
      // hDIB = NULL;
      // SelectPalette(hDC, hPal, TRUE);
      // RealizePalette(hDC);
      // ReleaseDC(NULL, hDC);
      // return hDIB;
   // }

   // bi = *lpbi;

   // GlobalUnlock(hDIB);
   // SelectPalette(hDC, hPal, TRUE);
   // RealizePalette(hDC);
   // ReleaseDC(NULL, hDC);

   // return hDIB;

// }

// WORD GetDIBColors(LPSTR lpDIB)
// {
    // WORD wBitCount = ((LPBITMAPCOREHEADER)lpDIB)->bcBitCount; ;
    // return wBitCount;
// }

// #pragma ENDDUMP

