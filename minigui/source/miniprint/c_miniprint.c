/*----------------------------------------------------------------------------
   MINIGUI - Harbour Win32 GUI library source code

   Copyright 2002-2010 Roberto Lopez <harbourminigui@gmail.com>
   http://harbourminigui.googlepages.com/

   This program is free software; you can redistribute it and/or modify it under
   the terms of the GNU General Public License as published by the Free Software
   Foundation; either version 2 of the License, or (at your option) any later
   version.

   This program is distributed in the hope that it will be useful, but WITHOUT
   ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
   FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

   You should have received a copy of the GNU General Public License along with
   this software; see the file COPYING. If not, write to the Free Software
   Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA (or
   visit the web site http://www.gnu.org/).

   As a special exception, you have permission for additional uses of the text
   contained in this release of Harbour Minigui.

   The exception is that, if you link the Harbour Minigui library with other
   files to produce an executable, this does not by itself cause the resulting
   executable to be covered by the GNU General Public License.
   Your use of that executable is in no way restricted on account of linking the
   Harbour-Minigui library code into it.

   Parts of this project are based upon:

        "Harbour GUI framework for Win32"
        Copyright 2001 Alexander S.Kresin <alex@belacy.ru>
        Copyright 2001 Antonio Linares <alinares@fivetech.com>
        www - https://harbour.github.io/

        "Harbour Project"
        Copyright 1999-2018, https://harbour.github.io/

   Parts of this module are based upon:

        "HBPRINT"
        Copyright 2002 Richard Rylko <rrylko@poczta.onet.pl>
        http://rrylko.republika.pl

        "HBPRINTER"
        Copyright 2002 Richard Rylko <rrylko@poczta.onet.pl>
        http://rrylko.republika.pl

   ---------------------------------------------------------------------------*/

///////////////////////////////////////////////////////////////////////////////
// LOW LEVEL C PRINT ROUTINES
///////////////////////////////////////////////////////////////////////////////

#ifndef CINTERFACE
  #define CINTERFACE
#endif

#define WINVER     0x0410

#define NO_LEAN_AND_MEAN

#include <mgdefs.h>
#include "hbapiitm.h"

#include <olectl.h>

#ifndef WC_STATIC
#define WC_STATIC    "Static"
#endif

static DWORD charset = DEFAULT_CHARSET;

HINSTANCE GetInstance( void );
extern HBITMAP HMG_LoadImage( char * FileName );

HB_FUNC( _HMG_SETCHARSET )
{
   charset = ( DWORD ) hb_parnl( 1 );
}

HB_FUNC( _HMG_PRINTER_ABORTDOC )
{
   HDC hdcPrint = ( HDC ) HB_PARNL( 1 );

   AbortDoc( hdcPrint );
}

HB_FUNC( _HMG_PRINTER_STARTDOC )
{

   DOCINFO docInfo;

   HDC hdcPrint = ( HDC ) HB_PARNL( 1 );

   if( hdcPrint != 0 )
   {
      ZeroMemory( &docInfo, sizeof( docInfo ) );
      docInfo.cbSize      = sizeof( docInfo );
      docInfo.lpszDocName = hb_parc( 2 );

      hb_retni( StartDoc( hdcPrint, &docInfo ) );
   }

}

HB_FUNC( _HMG_PRINTER_STARTPAGE )
{

   HDC hdcPrint = ( HDC ) HB_PARNL( 1 );

   if( hdcPrint != 0 )
      StartPage( hdcPrint );

}

HB_FUNC( _HMG_PRINTER_C_PRINT )
{

   // 1:  Hdc
   // 2:  y
   // 3:  x
   // 4:  FontName
   // 5:  FontSize
   // 6:  R Color
   // 7:  G Color
   // 8:  B Color
   // 9:  Text
   // 10: Bold
   // 11: Italic
   // 12: Underline
   // 13: StrikeOut
   // 14: Color Flag
   // 15: FontName Flag
   // 16: FontSize Flag
   // 17: Angle Flag
   // 18: Angle

   HGDIOBJ hgdiobj;

   char FontName[ 32 ];
   int  FontSize;

   DWORD fdwItalic;
   DWORD fdwUnderline;
   DWORD fdwStrikeOut;

   int fnWeight;
   int r;
   int g;
   int b;

   int x = hb_parni( 3 );
   int y = hb_parni( 2 );

   HFONT hfont;

   HDC hdcPrint = ( HDC ) HB_PARNL( 1 );

   int FontHeight;
   int FontAngle;

   if( hdcPrint != 0 )
   {

      // Bold

      if( hb_parl( 10 ) )
         fnWeight = FW_BOLD;
      else
         fnWeight = FW_NORMAL;

      // Italic

      if( hb_parl( 11 ) )
         fdwItalic = TRUE;
      else
         fdwItalic = FALSE;

      // UnderLine

      if( hb_parl( 12 ) )
         fdwUnderline = TRUE;
      else
         fdwUnderline = FALSE;

      // StrikeOut

      if( hb_parl( 13 ) )
         fdwStrikeOut = TRUE;
      else
         fdwStrikeOut = FALSE;

      // Color

      if( hb_parl( 14 ) )
      {
         r = hb_parni( 6 );
         g = hb_parni( 7 );
         b = hb_parni( 8 );
      }
      else
      {
         r = 0;
         g = 0;
         b = 0;
      }

      // Fontname

      if( hb_parl( 15 ) )
         strcpy( FontName, hb_parc( 4 ) );
      else
         strcpy( FontName, "Arial" );

      // FontSize

      if( hb_parl( 16 ) )
         FontSize = hb_parni( 5 );
      else
         FontSize = 10;

      // Angle

      if( hb_parl( 17 ) )
         FontAngle = hb_parni( 18 );
      else
         FontAngle = 0;

      FontHeight = -MulDiv( FontSize, GetDeviceCaps( hdcPrint, LOGPIXELSY ), 72 );

      hfont = CreateFont
              (
         FontHeight,
         0,
         FontAngle,
         FontAngle,
         fnWeight,
         fdwItalic,
         fdwUnderline,
         fdwStrikeOut,
         charset,
         OUT_TT_PRECIS,
         CLIP_DEFAULT_PRECIS,
         DEFAULT_QUALITY,
         FF_DONTCARE,
         FontName
              );

      hgdiobj = SelectObject( hdcPrint, hfont );

      SetTextColor( hdcPrint, RGB( r, g, b ) );
      SetBkMode( hdcPrint, TRANSPARENT );

      TextOut( hdcPrint,
               ( x * GetDeviceCaps( hdcPrint, LOGPIXELSX ) / 1000 ) - GetDeviceCaps( hdcPrint, PHYSICALOFFSETX ),
               ( y * GetDeviceCaps( hdcPrint, LOGPIXELSY ) / 1000 ) - GetDeviceCaps( hdcPrint, PHYSICALOFFSETY ),
               hb_parc( 9 ),
               strlen( hb_parc( 9 ) ) );

      SelectObject( hdcPrint, hgdiobj );

      DeleteObject( hfont );

   }

}

HB_FUNC( _HMG_PRINTER_C_MULTILINE_PRINT )
{

   // 1:  Hdc
   // 2:  y
   // 3:  x
   // 4:  FontName
   // 5:  FontSize
   // 6:  R Color
   // 7:  G Color
   // 8:  B Color
   // 9:  Text
   // 10: Bold
   // 11: Italic
   // 12: Underline
   // 13: StrikeOut
   // 14: Color Flag
   // 15: FontName Flag
   // 16: FontSize Flag
   // 17: ToRow
   // 18: ToCol
   // 19: Alignment

   UINT uFormat = 0;

   HGDIOBJ hgdiobj;

   char FontName[ 32 ];
   int  FontSize;

   DWORD fdwItalic;
   DWORD fdwUnderline;
   DWORD fdwStrikeOut;

   RECT rect;

   int fnWeight;
   int r;
   int g;
   int b;

   int x   = hb_parni( 3 );
   int y   = hb_parni( 2 );
   int toy = hb_parni( 17 );
   int tox = hb_parni( 18 );

   HFONT hfont;

   HDC hdcPrint = ( HDC ) HB_PARNL( 1 );

   int FontHeight;

   if( hdcPrint != 0 )
   {

      // Bold

      if( hb_parl( 10 ) )
         fnWeight = FW_BOLD;
      else
         fnWeight = FW_NORMAL;

      // Italic

      if( hb_parl( 11 ) )
         fdwItalic = TRUE;
      else
         fdwItalic = FALSE;

      // UnderLine

      if( hb_parl( 12 ) )
         fdwUnderline = TRUE;
      else
         fdwUnderline = FALSE;

      // StrikeOut

      if( hb_parl( 13 ) )
         fdwStrikeOut = TRUE;
      else
         fdwStrikeOut = FALSE;

      // Color

      if( hb_parl( 14 ) )
      {
         r = hb_parni( 6 );
         g = hb_parni( 7 );
         b = hb_parni( 8 );
      }
      else
      {
         r = 0;
         g = 0;
         b = 0;
      }

      // Fontname

      if( hb_parl( 15 ) )
         strcpy( FontName, hb_parc( 4 ) );
      else
         strcpy( FontName, "Arial" );

      // FontSize

      if( hb_parl( 16 ) )
         FontSize = hb_parni( 5 );
      else
         FontSize = 10;

      FontHeight = -MulDiv( FontSize, GetDeviceCaps( hdcPrint, LOGPIXELSY ), 72 );

      hfont = CreateFont
              (
         FontHeight,
         0,
         0,
         0,
         fnWeight,
         fdwItalic,
         fdwUnderline,
         fdwStrikeOut,
         charset,
         OUT_TT_PRECIS,
         CLIP_DEFAULT_PRECIS,
         DEFAULT_QUALITY,
         FF_DONTCARE,
         FontName
              );

      if( hb_parni( 19 ) == 0 )
         uFormat = DT_END_ELLIPSIS | DT_NOPREFIX | DT_WORDBREAK | DT_LEFT;
      else if( hb_parni( 19 ) == 2 )
         uFormat = DT_END_ELLIPSIS | DT_NOPREFIX | DT_WORDBREAK | DT_RIGHT;
      else if( hb_parni( 19 ) == 6 )
         uFormat = DT_END_ELLIPSIS | DT_NOPREFIX | DT_WORDBREAK | DT_CENTER;

      hgdiobj = SelectObject( hdcPrint, hfont );

      SetTextColor( hdcPrint, RGB( r, g, b ) );
      SetBkMode( hdcPrint, TRANSPARENT );

      rect.left   = ( x * GetDeviceCaps( hdcPrint, LOGPIXELSX ) / 1000 ) - GetDeviceCaps( hdcPrint, PHYSICALOFFSETX );
      rect.top    = ( y * GetDeviceCaps( hdcPrint, LOGPIXELSY ) / 1000 ) - GetDeviceCaps( hdcPrint, PHYSICALOFFSETY );
      rect.right  = ( tox * GetDeviceCaps( hdcPrint, LOGPIXELSX ) / 1000 ) - GetDeviceCaps( hdcPrint, PHYSICALOFFSETX );
      rect.bottom = ( toy * GetDeviceCaps( hdcPrint, LOGPIXELSY ) / 1000 ) - GetDeviceCaps( hdcPrint, PHYSICALOFFSETY );

      DrawText( hdcPrint,
                hb_parc( 9 ),
                strlen( hb_parc( 9 ) ),
                &rect,
                uFormat
                );

      SelectObject( hdcPrint, hgdiobj );

      DeleteObject( hfont );

   }

}

HB_FUNC( _HMG_PRINTER_ENDPAGE )
{

   HDC hdcPrint = ( HDC ) HB_PARNL( 1 );

   if( hdcPrint != 0 )
      EndPage( hdcPrint );

}

HB_FUNC( _HMG_PRINTER_ENDDOC )
{

   HDC hdcPrint = ( HDC ) HB_PARNL( 1 );

   if( hdcPrint != 0 )
      EndDoc( hdcPrint );

}

HB_FUNC( _HMG_PRINTER_DELETEDC )
{

   HDC hdcPrint = ( HDC ) HB_PARNL( 1 );

   DeleteDC( hdcPrint );

}

HB_FUNC( _HMG_PRINTER_PRINTDIALOG )
{

   PRINTDLG pd;

   LPDEVMODE pDevMode;

   pd.lStructSize         = sizeof( PRINTDLG );
   pd.hDevMode            = ( HANDLE ) NULL;
   pd.hDevNames           = ( HANDLE ) NULL;
   pd.Flags               = PD_RETURNDC | PD_PRINTSETUP;
   pd.hwndOwner           = NULL;
   pd.hDC                 = NULL;
   pd.nFromPage           = 1;
   pd.nToPage             = 0xFFFF;
   pd.nMinPage            = 1;
   pd.nMaxPage            = 0xFFFF;
   pd.nCopies             = 1;
   pd.hInstance           = ( HINSTANCE ) NULL;
   pd.lCustData           = 0L;
   pd.lpfnPrintHook       = ( LPPRINTHOOKPROC ) NULL;
   pd.lpfnSetupHook       = ( LPSETUPHOOKPROC ) NULL;
   pd.lpPrintTemplateName = ( LPSTR ) NULL;
   pd.lpSetupTemplateName = ( LPSTR ) NULL;
   pd.hPrintTemplate      = ( HANDLE ) NULL;
   pd.hSetupTemplate      = ( HANDLE ) NULL;

   if( PrintDlg( &pd ) )
   {
      pDevMode = ( LPDEVMODE ) GlobalLock( pd.hDevMode );

      hb_reta( 4 );
      HB_STORVNL( ( LONG_PTR ) pd.hDC, -1, 1 );
      HB_STORC( ( const char * ) pDevMode->dmDeviceName, -1, 2 );
      HB_STORNI( pDevMode->dmCopies > 1 ? pDevMode->dmCopies : pd.nCopies, -1, 3 );
      HB_STORNI( pDevMode->dmCollate, -1, 4 );

      GlobalUnlock( pd.hDevMode );
   }
   else
   {
      hb_reta( 4 );
      HB_STORVNL( 0, -1, 1 );
      HB_STORC( "", -1, 2 );
      HB_STORNI( 0, -1, 3 );
      HB_STORNI( 0, -1, 4 );
   }

}

HB_FUNC( APRINTERS )
{

   OSVERSIONINFO osvi;

   HGLOBAL cBuffer;
   HGLOBAL pBuffer;

   DWORD dwSize     = 0;
   DWORD dwPrinters = 0;
   DWORD i;

   PRINTER_INFO_4 * pInfo4 = NULL;
   PRINTER_INFO_5 * pInfo  = NULL;

   osvi.dwOSVersionInfoSize = sizeof( OSVERSIONINFO );

   GetVersionEx( &osvi );

   if( osvi.dwPlatformId == VER_PLATFORM_WIN32_NT )
      EnumPrinters( PRINTER_ENUM_LOCAL | PRINTER_ENUM_CONNECTIONS, NULL, 4, NULL, 0, &dwSize, &dwPrinters );
   else
      EnumPrinters( PRINTER_ENUM_LOCAL, NULL, 5, NULL, 0, &dwSize, &dwPrinters );

   pBuffer = ( char * ) GlobalAlloc( GPTR, dwSize );

   if( pBuffer == NULL )
   {
      hb_reta( 0 );
      GlobalFree( pBuffer );
      return;
   }

   if( osvi.dwPlatformId == VER_PLATFORM_WIN32_NT )
      EnumPrinters( PRINTER_ENUM_LOCAL | PRINTER_ENUM_CONNECTIONS, NULL, 4, ( LPBYTE ) pBuffer, dwSize, &dwSize, &dwPrinters );
   else
      EnumPrinters( PRINTER_ENUM_LOCAL, NULL, 5, ( LPBYTE ) pBuffer, dwSize, &dwSize, &dwPrinters );

   if( dwPrinters == 0 )
   {
      hb_reta( 0 );
      GlobalFree( pBuffer );
      return;
   }

   if( osvi.dwPlatformId == VER_PLATFORM_WIN32_NT )
      pInfo4 = ( PRINTER_INFO_4 * ) pBuffer;
   else
      pInfo = ( PRINTER_INFO_5 * ) pBuffer;

   hb_reta( dwPrinters );

   if( osvi.dwPlatformId == VER_PLATFORM_WIN32_NT )
      for( i = 0; i < dwPrinters; i++, pInfo4++ )
      {
         cBuffer = ( char * ) GlobalAlloc( GPTR, 256 );
         strcat( ( char * ) cBuffer, pInfo4->pPrinterName );
         HB_STORC( ( const char * ) cBuffer, -1, i + 1 );
         GlobalFree( cBuffer );
      }
   else
      for( i = 0; i < dwPrinters; i++, pInfo++ )
      {
         cBuffer = ( char * ) GlobalAlloc( GPTR, 256 );
         strcat( ( char * ) cBuffer, pInfo->pPrinterName );
         HB_STORC( ( const char * ) cBuffer, -1, i + 1 );
         GlobalFree( cBuffer );
      }

   GlobalFree( pBuffer );

}

HB_FUNC( _HMG_PRINTER_C_RECTANGLE )
{

   // 1: hDC
   // 2: y
   // 3: x
   // 4: toy
   // 5: tox
   // 6: width
   // 7: R Color
   // 8: G Color
   // 9: B Color
   // 10: lWidth
   // 11: lColor
   // 12: lFilled

   int r;
   int g;
   int b;

   int x = hb_parni( 3 );
   int y = hb_parni( 2 );

   int tox = hb_parni( 5 );
   int toy = hb_parni( 4 );

   int width;

   HDC     hdcPrint = ( HDC ) HB_PARNL( 1 );
   HGDIOBJ hgdiobj;
   HBRUSH  hbrush = NULL;
   HPEN    hpen   = NULL;
   RECT    rect;

   if( hdcPrint != 0 )
   {

      // Width

      if( hb_parl( 10 ) )
         width = hb_parni( 6 );
      else
         width = 1 * 10000 / 254;

      // Color

      if( hb_parl( 11 ) )
      {
         r = hb_parni( 7 );
         g = hb_parni( 8 );
         b = hb_parni( 9 );
      }
      else
      {
         r = 0;
         g = 0;
         b = 0;
      }

      // Filled

      if( hb_parl( 12 ) )
      {
         hbrush  = CreateSolidBrush( ( COLORREF ) RGB( r, g, b ) );
         hgdiobj = SelectObject( hdcPrint, hbrush );
      }
      else
      {
         hpen    = CreatePen( PS_SOLID, ( width * GetDeviceCaps( hdcPrint, LOGPIXELSX ) / 1000 ), ( COLORREF ) RGB( r, g, b ) );
         hgdiobj = SelectObject( hdcPrint, hpen );
      }

      // Border  ( contributed by Alen Uzelac 08.06.2011 )

      rect.left   = ( x * GetDeviceCaps( hdcPrint, LOGPIXELSX ) / 1000 ) - GetDeviceCaps( hdcPrint, PHYSICALOFFSETX );
      rect.top    = ( y * GetDeviceCaps( hdcPrint, LOGPIXELSY ) / 1000 ) - GetDeviceCaps( hdcPrint, PHYSICALOFFSETY );
      rect.right  = ( tox * GetDeviceCaps( hdcPrint, LOGPIXELSX ) / 1000 ) - GetDeviceCaps( hdcPrint, PHYSICALOFFSETX );
      rect.bottom = ( toy * GetDeviceCaps( hdcPrint, LOGPIXELSY ) / 1000 ) - GetDeviceCaps( hdcPrint, PHYSICALOFFSETY );

      if( hb_parl( 12 ) && hb_parl( 13 ) )
         FillRect( hdcPrint, &rect, ( HBRUSH ) hbrush );
      else
         Rectangle( hdcPrint, rect.left, rect.top, rect.right, rect.bottom );

      SelectObject( hdcPrint, ( HGDIOBJ ) hgdiobj );

      if( hb_parl( 12 ) )
         DeleteObject( hbrush );
      else
         DeleteObject( hpen );

   }

}

HB_FUNC( _HMG_PRINTER_C_ROUNDRECTANGLE )
{

   // 1: hDC
   // 2: y
   // 3: x
   // 4: toy
   // 5: tox
   // 6: width
   // 7: R Color
   // 8: G Color
   // 9: B Color
   // 10: lWidth
   // 11: lColor
   // 12: lFilled

   int r;
   int g;
   int b;

   int x = hb_parni( 3 );
   int y = hb_parni( 2 );

   int tox = hb_parni( 5 );
   int toy = hb_parni( 4 );

   int width;

   int w, h, p;

   HDC     hdcPrint = ( HDC ) HB_PARNL( 1 );
   HGDIOBJ hgdiobj;
   HBRUSH  hbrush = NULL;
   HPEN    hpen   = NULL;

   if( hdcPrint != 0 )
   {

      // Width

      if( hb_parl( 10 ) )
         width = hb_parni( 6 );
      else
         width = 1 * 10000 / 254;

      // Color

      if( hb_parl( 11 ) )
      {
         r = hb_parni( 7 );
         g = hb_parni( 8 );
         b = hb_parni( 9 );
      }
      else
      {
         r = 0;
         g = 0;
         b = 0;
      }

      // Filled

      if( hb_parl( 12 ) )
      {
         hbrush  = CreateSolidBrush( ( COLORREF ) RGB( r, g, b ) );
         hgdiobj = SelectObject( ( HDC ) hdcPrint, hbrush );
      }
      else
      {
         hpen    = CreatePen( PS_SOLID, ( width * GetDeviceCaps( hdcPrint, LOGPIXELSX ) / 1000 ), ( COLORREF ) RGB( r, g, b ) );
         hgdiobj = SelectObject( ( HDC ) hdcPrint, hpen );
      }

      w = ( tox * GetDeviceCaps( hdcPrint, LOGPIXELSX ) / 1000 ) - ( x * GetDeviceCaps( hdcPrint, LOGPIXELSX ) / 1000 );
      h = ( toy * GetDeviceCaps( hdcPrint, LOGPIXELSY ) / 1000 ) - ( y * GetDeviceCaps( hdcPrint, LOGPIXELSY ) / 1000 );
      p = ( w + h ) / 2;
      p = p / 10;

      RoundRect( ( HDC ) hdcPrint,
                 ( x * GetDeviceCaps( hdcPrint, LOGPIXELSX ) / 1000 ) - GetDeviceCaps( hdcPrint, PHYSICALOFFSETX ),
                 ( y * GetDeviceCaps( hdcPrint, LOGPIXELSY ) / 1000 ) - GetDeviceCaps( hdcPrint, PHYSICALOFFSETY ),
                 ( tox * GetDeviceCaps( hdcPrint, LOGPIXELSX ) / 1000 ) - GetDeviceCaps( hdcPrint, PHYSICALOFFSETX ),
                 ( toy * GetDeviceCaps( hdcPrint, LOGPIXELSY ) / 1000 ) - GetDeviceCaps( hdcPrint, PHYSICALOFFSETY ),
                 p,
                 p
                 );

      SelectObject( hdcPrint, ( HGDIOBJ ) hgdiobj );

      if( hb_parl( 12 ) )
         DeleteObject( hbrush );
      else
         DeleteObject( hpen );

   }

}

HB_FUNC( _HMG_PRINTER_C_LINE )
{

   // 1: hDC
   // 2: y
   // 3: x
   // 4: toy
   // 5: tox
   // 6: width
   // 7: R Color
   // 8: G Color
   // 9: B Color
   // 10: lWindth
   // 11: lColor
   // 12: lDotted

   int r;
   int g;
   int b;

   int x = hb_parni( 3 );
   int y = hb_parni( 2 );

   int tox = hb_parni( 5 );
   int toy = hb_parni( 4 );

   int width;

   HDC     hdcPrint = ( HDC ) HB_PARNL( 1 );
   HGDIOBJ hgdiobj;
   HPEN    hpen;

   if( hdcPrint != 0 )
   {

      // Width

      if( hb_parl( 10 ) )
         width = hb_parni( 6 );
      else
         width = 1 * 10000 / 254;

      // Color

      if( hb_parl( 11 ) )
      {
         r = hb_parni( 7 );
         g = hb_parni( 8 );
         b = hb_parni( 9 );
      }
      else
      {
         r = 0;
         g = 0;
         b = 0;
      }

      hpen = CreatePen( hb_parl( 12 ) ? PS_DASH : PS_SOLID, ( width * GetDeviceCaps( hdcPrint, LOGPIXELSX ) / 1000 ), ( COLORREF ) RGB( r, g, b ) );

      hgdiobj = SelectObject( hdcPrint, hpen );

      MoveToEx( hdcPrint,
                ( x * GetDeviceCaps( hdcPrint, LOGPIXELSX ) / 1000 ) - GetDeviceCaps( hdcPrint, PHYSICALOFFSETX ),
                ( y * GetDeviceCaps( hdcPrint, LOGPIXELSY ) / 1000 ) - GetDeviceCaps( hdcPrint, PHYSICALOFFSETY ),
                NULL
                );

      LineTo( hdcPrint,
              ( tox * GetDeviceCaps( hdcPrint, LOGPIXELSX ) / 1000 ) - GetDeviceCaps( hdcPrint, PHYSICALOFFSETX ),
              ( toy * GetDeviceCaps( hdcPrint, LOGPIXELSY ) / 1000 ) - GetDeviceCaps( hdcPrint, PHYSICALOFFSETY )
              );

      SelectObject( hdcPrint, ( HGDIOBJ ) hgdiobj );

      DeleteObject( hpen );

   }

}

HB_FUNC( _HMG_PRINTER_SETPRINTERPROPERTIES )
{
   HANDLE hPrinter = NULL;
   DWORD  dwNeeded = 0;
   PRINTER_INFO_2 * pi2;
   DEVMODE *        pDevMode = NULL;
   BOOL bFlag;
   LONG lFlag;

   HDC hdcPrint;

   int fields = 0;

   bFlag = OpenPrinter( ( LPSTR ) hb_parc( 1 ), &hPrinter, NULL );

   if( ! bFlag || ( hPrinter == NULL ) )
   {
#ifdef _ERRORMSG_
      MessageBox( 0, "Printer Configuration Failed! (001)", "Error!", MB_ICONEXCLAMATION | MB_OK | MB_SYSTEMMODAL );
#endif
      hb_reta( 4 );
      HB_STORVNL( 0, -1, 1 );
      HB_STORC( "", -1, 2 );
      HB_STORNI( 0, -1, 3 );
      HB_STORNI( 0, -1, 4 );

      return;
   }

   SetLastError( 0 );

   bFlag = GetPrinter( hPrinter, 2, 0, 0, &dwNeeded );

   if( ( ! bFlag ) && ( ( GetLastError() != ERROR_INSUFFICIENT_BUFFER ) || ( dwNeeded == 0 ) ) )
   {
      ClosePrinter( hPrinter );
#ifdef _ERRORMSG_
      MessageBox( 0, "Printer Configuration Failed! (002)", "Error!", MB_ICONEXCLAMATION | MB_OK | MB_SYSTEMMODAL );
#endif
      hb_reta( 4 );
      HB_STORVNL( 0, -1, 1 );
      HB_STORC( "", -1, 2 );
      HB_STORNI( 0, -1, 3 );
      HB_STORNI( 0, -1, 4 );

      return;
   }

   pi2 = ( PRINTER_INFO_2 * ) GlobalAlloc( GPTR, dwNeeded );

   if( pi2 == NULL )
   {
      ClosePrinter( hPrinter );
#ifdef _ERRORMSG_
      MessageBox( 0, "Printer Configuration Failed! (003)", "Error!", MB_ICONEXCLAMATION | MB_OK | MB_SYSTEMMODAL );
#endif
      hb_reta( 4 );
      HB_STORVNL( 0, -1, 1 );
      HB_STORC( "", -1, 2 );
      HB_STORNI( 0, -1, 3 );
      HB_STORNI( 0, -1, 4 );

      return;
   }

   bFlag = GetPrinter( hPrinter, 2, ( LPBYTE ) pi2, dwNeeded, &dwNeeded );

   if( ! bFlag )
   {
      GlobalFree( pi2 );
      ClosePrinter( hPrinter );
#ifdef _ERRORMSG_
      MessageBox( 0, "Printer Configuration Failed! (004)", "Error!", MB_ICONEXCLAMATION | MB_OK | MB_SYSTEMMODAL );
#endif
      hb_reta( 4 );
      HB_STORVNL( 0, -1, 1 );
      HB_STORC( "", -1, 2 );
      HB_STORNI( 0, -1, 3 );
      HB_STORNI( 0, -1, 4 );

      return;
   }

   if( pi2->pDevMode == NULL )
   {
      dwNeeded = DocumentProperties( NULL, hPrinter, ( LPSTR ) hb_parc( 1 ), NULL, NULL, 0 );
      if( dwNeeded <= 0 )
      {
         GlobalFree( pi2 );
         ClosePrinter( hPrinter );
#ifdef _ERRORMSG_
         MessageBox( 0, "Printer Configuration Failed! (005)", "Error!", MB_ICONEXCLAMATION | MB_OK | MB_SYSTEMMODAL );
#endif
         hb_reta( 4 );
         HB_STORVNL( 0, -1, 1 );
         HB_STORC( "", -1, 2 );
         HB_STORNI( 0, -1, 3 );
         HB_STORNI( 0, -1, 4 );

         return;
      }

      pDevMode = ( DEVMODE * ) GlobalAlloc( GPTR, dwNeeded );
      if( pDevMode == NULL )
      {
         GlobalFree( pi2 );
         ClosePrinter( hPrinter );
#ifdef _ERRORMSG_
         MessageBox( 0, "Printer Configuration Failed! (006)", "Error! (006)", MB_ICONEXCLAMATION | MB_OK | MB_SYSTEMMODAL );
#endif
         hb_reta( 4 );
         HB_STORVNL( 0, -1, 1 );
         HB_STORC( "", -1, 2 );
         HB_STORNI( 0, -1, 3 );
         HB_STORNI( 0, -1, 4 );

         return;
      }

      lFlag = DocumentProperties( NULL, hPrinter, ( LPSTR ) hb_parc( 1 ), pDevMode, NULL, DM_OUT_BUFFER );
      if( lFlag != IDOK || pDevMode == NULL )
      {
         GlobalFree( pDevMode );
         GlobalFree( pi2 );
         ClosePrinter( hPrinter );
#ifdef _ERRORMSG_
         MessageBox( 0, "Printer Configuration Failed! (007)", "Error!", MB_ICONEXCLAMATION | MB_OK | MB_SYSTEMMODAL );
#endif
         hb_reta( 4 );
         HB_STORVNL( 0, -1, 1 );
         HB_STORC( "", -1, 2 );
         HB_STORNI( 0, -1, 3 );
         HB_STORNI( 0, -1, 4 );

         return;
      }

      pi2->pDevMode = pDevMode;
   }

   ///////////////////////////////////////////////////////////////////////
   // Specify Fields
   //////////////////////////////////////////////////////////////////////
   // Orientation
   if( hb_parni( 2 ) != -999 )
      fields = fields | DM_ORIENTATION;

   // PaperSize
   if( hb_parni( 3 ) != -999 )
      fields = fields | DM_PAPERSIZE;

   // PaperLength
   if( hb_parni( 4 ) != -999 )
      fields = fields | DM_PAPERLENGTH;

   // PaperWidth
   if( hb_parni( 5 ) != -999 )
      fields = fields | DM_PAPERWIDTH;

   // Copies
   if( hb_parni( 6 ) != -999 )
      fields = fields | DM_COPIES;

   // Default Source
   if( hb_parni( 7 ) != -999 )
      fields = fields | DM_DEFAULTSOURCE;

   // Print Quality
   if( hb_parni( 8 ) != -999 )
      fields = fields | DM_PRINTQUALITY;

   // Print Color
   if( hb_parni( 9 ) != -999 )
      fields = fields | DM_COLOR;

   // Print Duplex Mode
   if( hb_parni( 10 ) != -999 )
      fields = fields | DM_DUPLEX;

   // Print Collate
   if( hb_parni( 11 ) != -999 )
      fields = fields | DM_COLLATE;

   pi2->pDevMode->dmFields = fields;

   ///////////////////////////////////////////////////////////////////////
   // Load Fields
   //////////////////////////////////////////////////////////////////////
   // Orientation
   if( hb_parni( 2 ) != -999 )
   {
      if( ! ( pi2->pDevMode->dmFields & DM_ORIENTATION ) )
      {
#ifdef _ERRORMSG_
         MessageBox( 0, "Printer Configuration Failed: ORIENTATION Property Not Supported By Selected Printer", "Error!",
                     MB_ICONEXCLAMATION | MB_OK | MB_SYSTEMMODAL );
#endif
         hb_reta( 4 );
         HB_STORVNL( 0, -1, 1 );
         HB_STORC( "", -1, 2 );
         HB_STORNI( 0, -1, 3 );
         HB_STORNI( 0, -1, 4 );

         return;
      }

      pi2->pDevMode->dmOrientation = ( short ) hb_parni( 2 );
   }

   // PaperSize
   if( hb_parni( 3 ) != -999 )
   {
      if( ! ( pi2->pDevMode->dmFields & DM_PAPERSIZE ) )
      {
#ifdef _ERRORMSG_
         MessageBox( 0, "Printer Configuration Failed: PAPERSIZE Property Not Supported By Selected Printer", "Error!",
                     MB_ICONEXCLAMATION | MB_OK | MB_SYSTEMMODAL );
#endif
         hb_reta( 4 );
         HB_STORVNL( 0, -1, 1 );
         HB_STORC( "", -1, 2 );
         HB_STORNI( 0, -1, 3 );
         HB_STORNI( 0, -1, 4 );

         return;
      }

      pi2->pDevMode->dmPaperSize = ( short ) hb_parni( 3 );
   }

   // PaperLength
   if( hb_parni( 4 ) != -999 )
   {
      if( ! ( pi2->pDevMode->dmFields & DM_PAPERLENGTH ) )
      {
#ifdef _ERRORMSG_
         MessageBox( 0, "Printer Configuration Failed: PAPERLENGTH Property Not Supported By Selected Printer", "Error!",
                     MB_ICONEXCLAMATION | MB_OK | MB_SYSTEMMODAL );
#endif
         hb_reta( 4 );
         HB_STORVNL( 0, -1, 1 );
         HB_STORC( "", -1, 2 );
         HB_STORNI( 0, -1, 3 );
         HB_STORNI( 0, -1, 4 );

         return;
      }

      pi2->pDevMode->dmPaperLength = ( short ) ( hb_parni( 4 ) * 10 );
   }

   // PaperWidth
   if( hb_parni( 5 ) != -999 )
   {
      if( ! ( pi2->pDevMode->dmFields & DM_PAPERWIDTH ) )
      {
#ifdef _ERRORMSG_
         MessageBox( 0, "Printer Configuration Failed: PAPERWIDTH Property Not Supported By Selected Printer", "Error!",
                     MB_ICONEXCLAMATION | MB_OK | MB_SYSTEMMODAL );
#endif
         hb_reta( 4 );
         HB_STORVNL( 0, -1, 1 );
         HB_STORC( "", -1, 2 );
         HB_STORNI( 0, -1, 3 );
         HB_STORNI( 0, -1, 4 );

         return;
      }

      pi2->pDevMode->dmPaperWidth = ( short ) ( hb_parni( 5 ) * 10 );
   }

   // Copies
   if( hb_parni( 6 ) != -999 )
   {
      if( ! ( pi2->pDevMode->dmFields & DM_COPIES ) )
      {
#ifdef _ERRORMSG_
         MessageBox( 0, "Printer Configuration Failed: COPIES Property Not Supported By Selected Printer", "Error!", MB_ICONEXCLAMATION | MB_OK | MB_SYSTEMMODAL );
#endif
         hb_reta( 4 );
         HB_STORVNL( 0, -1, 1 );
         HB_STORC( "", -1, 2 );
         HB_STORNI( 0, -1, 3 );
         HB_STORNI( 0, -1, 4 );

         return;
      }

      pi2->pDevMode->dmCopies = ( short ) hb_parni( 6 );
   }

   // Default Source
   if( hb_parni( 7 ) != -999 )
   {
      if( ! ( pi2->pDevMode->dmFields & DM_DEFAULTSOURCE ) )
      {
#ifdef _ERRORMSG_
         MessageBox( 0, "Printer Configuration Failed: DEFAULTSOURCE Property Not Supported By Selected Printer", "Error!",
                     MB_ICONEXCLAMATION | MB_OK | MB_SYSTEMMODAL );
#endif
         hb_reta( 4 );
         HB_STORVNL( 0, -1, 1 );
         HB_STORC( "", -1, 2 );
         HB_STORNI( 0, -1, 3 );
         HB_STORNI( 0, -1, 4 );

         return;
      }

      pi2->pDevMode->dmDefaultSource = ( short ) hb_parni( 7 );
   }

   // Print Quality
   if( hb_parni( 8 ) != -999 )
   {
      if( ! ( pi2->pDevMode->dmFields & DM_PRINTQUALITY ) )
      {
#ifdef _ERRORMSG_
         MessageBox( 0, "Printer Configuration Failed: QUALITY Property Not Supported By Selected Printer", "Error!",
                     MB_ICONEXCLAMATION | MB_OK | MB_SYSTEMMODAL );
#endif
         hb_reta( 4 );
         HB_STORVNL( 0, -1, 1 );
         HB_STORC( "", -1, 2 );
         HB_STORNI( 0, -1, 3 );
         HB_STORNI( 0, -1, 4 );

         return;
      }

      pi2->pDevMode->dmPrintQuality = ( short ) hb_parni( 8 );
   }

   // Print Color
   if( hb_parni( 9 ) != -999 )
   {
      if( ! ( pi2->pDevMode->dmFields & DM_COLOR ) )
      {
#ifdef _ERRORMSG_
         MessageBox( 0, "Printer Configuration Failed: COLOR Property Not Supported By Selected Printer", "Error!", MB_ICONEXCLAMATION | MB_OK | MB_SYSTEMMODAL );
#endif
         hb_reta( 4 );
         HB_STORVNL( 0, -1, 1 );
         HB_STORC( "", -1, 2 );
         HB_STORNI( 0, -1, 3 );
         HB_STORNI( 0, -1, 4 );

         return;
      }

      pi2->pDevMode->dmColor = ( short ) hb_parni( 9 );
   }

   // Print Duplex
   if( hb_parni( 10 ) != -999 )
   {
      if( ! ( pi2->pDevMode->dmFields & DM_DUPLEX ) )
      {
#ifdef _ERRORMSG_
         MessageBox( 0, "Printer Configuration Failed: DUPLEX Property Not Supported By Selected Printer", "Error!", MB_ICONEXCLAMATION | MB_OK | MB_SYSTEMMODAL );
#endif
         hb_reta( 4 );
         HB_STORVNL( 0, -1, 1 );
         HB_STORC( "", -1, 2 );
         HB_STORNI( 0, -1, 3 );
         HB_STORNI( 0, -1, 4 );

         return;
      }

      pi2->pDevMode->dmDuplex = ( short ) hb_parni( 10 );
   }

   // Print Collate
   if( hb_parni( 11 ) != -999 )
   {
      if( ! ( pi2->pDevMode->dmFields & DM_COLLATE ) )
      {
#ifdef _ERRORMSG_
         MessageBox( 0, "Printer Configuration Failed: COLLATE Property Not Supported By Selected Printer", "Error!",
                     MB_ICONEXCLAMATION | MB_OK | MB_SYSTEMMODAL );
#endif
         hb_reta( 4 );
         HB_STORVNL( 0, -1, 1 );
         HB_STORC( "", -1, 2 );
         HB_STORNI( 0, -1, 3 );
         HB_STORNI( 0, -1, 4 );

         return;
      }

      pi2->pDevMode->dmCollate = ( short ) hb_parni( 11 );
   }

   //////////////////////////////////////////////////////////////////////

   pi2->pSecurityDescriptor = NULL;

   lFlag = DocumentProperties( NULL, hPrinter, ( LPSTR ) hb_parc( 1 ), pi2->pDevMode, pi2->pDevMode, DM_IN_BUFFER | DM_OUT_BUFFER );

   if( lFlag != IDOK )
   {
      GlobalFree( pi2 );
      ClosePrinter( hPrinter );
      if( pDevMode )
         GlobalFree( pDevMode );
#ifdef _ERRORMSG_
      MessageBox( 0, "Printer Configuration Failed! (008)", "Error!", MB_ICONEXCLAMATION | MB_OK | MB_SYSTEMMODAL );
#endif
      hb_reta( 4 );
      HB_STORVNL( 0, -1, 1 );
      HB_STORC( "", -1, 2 );
      HB_STORNI( 0, -1, 3 );
      HB_STORNI( 0, -1, 4 );

      return;
   }

   hdcPrint = CreateDC( NULL, TEXT( hb_parc( 1 ) ), NULL, pi2->pDevMode );

   if( hdcPrint != NULL )
   {
      hb_reta( 4 );
      HB_STORVNL( ( LONG_PTR ) hdcPrint, -1, 1 );
      HB_STORC( hb_parc( 1 ), -1, 2 );
      HB_STORNI( ( INT ) pi2->pDevMode->dmCopies, -1, 3 );
      HB_STORNI( ( INT ) pi2->pDevMode->dmCollate, -1, 4 );
   }
   else
   {
      hb_reta( 4 );
      HB_STORVNL( 0, -1, 1 );
      HB_STORC( "", -1, 2 );
      HB_STORNI( 0, -1, 3 );
      HB_STORNI( 0, -1, 4 );
   }

   if( pi2 )
      GlobalFree( pi2 );

   if( hPrinter )
      ClosePrinter( hPrinter );

   if( pDevMode )
      GlobalFree( pDevMode );

}

#if ! ( defined( __XHARBOUR__ ) && ( defined( __MINGW32__ ) || defined( __POCC__ ) ) )

HB_FUNC( GETDEFAULTPRINTER )
{

   OSVERSIONINFO    osvi;
   LPPRINTER_INFO_5 PrinterInfo;
   DWORD Needed, Returned;
   DWORD BufferSize = 254;

   char DefaultPrinter[ 254 ];

   osvi.dwOSVersionInfoSize = sizeof( OSVERSIONINFO );

   GetVersionEx( &osvi );

   if( osvi.dwPlatformId == VER_PLATFORM_WIN32_WINDOWS )
   {

      EnumPrinters( PRINTER_ENUM_DEFAULT, NULL, 5, NULL, 0, &Needed, &Returned );
      PrinterInfo = ( LPPRINTER_INFO_5 ) LocalAlloc( LPTR, Needed );
      EnumPrinters( PRINTER_ENUM_DEFAULT, NULL, 5, ( LPBYTE ) PrinterInfo, Needed, &Needed, &Returned );
      strcpy( DefaultPrinter, PrinterInfo->pPrinterName );
      LocalFree( PrinterInfo );

   }
   else if( osvi.dwPlatformId == VER_PLATFORM_WIN32_NT )
   {

      GetProfileString( "windows", "device", "", DefaultPrinter, BufferSize );
      strtok( DefaultPrinter, "," );

   }

   hb_retc( DefaultPrinter );

}

#endif

HB_FUNC( _HMG_PRINTER_STARTPAGE_PREVIEW )
{

   HDC  tmpDC;
   RECT emfrect;

   SetRect( &emfrect, 0, 0, GetDeviceCaps( ( HDC ) HB_PARNL( 1 ), HORZSIZE ) * 100, GetDeviceCaps( ( HDC ) HB_PARNL( 1 ), VERTSIZE ) * 100 );

   tmpDC = CreateEnhMetaFile( ( HDC ) HB_PARNL( 1 ), hb_parc( 2 ), &emfrect, "" );

   HB_RETNL( ( LONG_PTR ) tmpDC );

}

HB_FUNC( _HMG_PRINTER_ENDPAGE_PREVIEW )
{
   DeleteEnhMetaFile( CloseEnhMetaFile( ( HDC ) HB_PARNL( 1 ) ) );
}

HB_FUNC( _HMG_PRINTER_SHOWPAGE )
{

   HENHMETAFILE hemf;
   HWND         hWnd       = ( HWND ) HB_PARNL( 2 );
   HDC          hDCPrinter = ( HDC ) HB_PARNL( 3 );
   RECT         rct;
   RECT         aux;
   int          zw;
   int          zh;
   int          ClientWidth;
   int          ClientHeight;
   int          xOffset;
   int          yOffset;
   PAINTSTRUCT  ps;
   HDC          hDC = BeginPaint( hWnd, &ps );

   hemf = GetEnhMetaFile( hb_parc( 1 ) );

   GetClientRect( hWnd, &rct );

   ClientWidth  = rct.right - rct.left;
   ClientHeight = rct.bottom - rct.top;

   zw = hb_parni( 5 ) * GetDeviceCaps( hDCPrinter, HORZSIZE ) / 750;
   zh = hb_parni( 5 ) * GetDeviceCaps( hDCPrinter, VERTSIZE ) / 750;

   xOffset = ( ClientWidth - ( GetDeviceCaps( hDCPrinter, HORZSIZE ) * hb_parni( 4 ) / 10000 ) ) / 2;
   yOffset = ( ClientHeight - ( GetDeviceCaps( hDCPrinter, VERTSIZE ) * hb_parni( 4 ) / 10000 ) ) / 2;

   SetRect( &rct,
            xOffset + hb_parni( 6 ) - zw,
            yOffset + hb_parni( 7 ) - zh,
            xOffset + ( GetDeviceCaps( hDCPrinter, HORZSIZE ) * hb_parni( 4 ) / 10000 ) + hb_parni( 6 ) + zw,
            yOffset + ( GetDeviceCaps( hDCPrinter, VERTSIZE ) * hb_parni( 4 ) / 10000 ) + hb_parni( 7 ) + zh
            );

   FillRect( hDC, &rct, ( HBRUSH ) RGB( 255, 255, 255 ) );

   PlayEnhMetaFile( hDC, hemf, &rct );

   // Remove prints outside printable area

   // Right
   aux.top    = 0;
   aux.left   = rct.right;
   aux.right  = ClientWidth;
   aux.bottom = ClientHeight;
   FillRect( hDC, &aux, ( HBRUSH ) GetStockObject( GRAY_BRUSH ) );

   // Bottom
   aux.top    = rct.bottom;
   aux.left   = 0;
   aux.right  = ClientWidth;
   aux.bottom = ClientHeight;
   FillRect( hDC, &aux, ( HBRUSH ) GetStockObject( GRAY_BRUSH ) );

   // Top
   aux.top    = 0;
   aux.left   = 0;
   aux.right  = ClientWidth;
   aux.bottom = yOffset + hb_parni( 7 ) - zh;
   FillRect( hDC, &aux, ( HBRUSH ) GetStockObject( GRAY_BRUSH ) );

   // Left
   aux.top    = 0;
   aux.left   = 0;
   aux.right  = xOffset + hb_parni( 6 ) - zw;
   aux.bottom = ClientHeight;
   FillRect( hDC, &aux, ( HBRUSH ) GetStockObject( GRAY_BRUSH ) );

   // Clean up

   DeleteEnhMetaFile( hemf );

   EndPaint( hWnd, &ps );

}

HB_FUNC( _HMG_PRINTER_GETPAGEWIDTH )
{
   hb_retni( GetDeviceCaps( ( HDC ) HB_PARNL( 1 ), HORZSIZE ) );
}

HB_FUNC( _HMG_PRINTER_GETPAGEHEIGHT )
{
   hb_retni( GetDeviceCaps( ( HDC ) HB_PARNL( 1 ), VERTSIZE ) );
}

HB_FUNC( _HMG_PRINTER_PRINTPAGE )
{

   HENHMETAFILE hemf;

   RECT rect;

   hemf = GetEnhMetaFile( hb_parc( 2 ) );

   SetRect( &rect, 0, 0, GetDeviceCaps( ( HDC ) HB_PARNL( 1 ), HORZRES ), GetDeviceCaps( ( HDC ) HB_PARNL( 1 ), VERTRES ) );

   StartPage( ( HDC ) HB_PARNL( 1 ) );

   PlayEnhMetaFile( ( HDC ) HB_PARNL( 1 ), ( HENHMETAFILE ) hemf, &rect );

   EndPage( ( HDC ) HB_PARNL( 1 ) );

   DeleteEnhMetaFile( hemf );

}

HB_FUNC( _HMG_PRINTER_PREVIEW_ENABLESCROLLBARS )
{
   EnableScrollBar( ( HWND ) HB_PARNL( 1 ), SB_BOTH, ESB_ENABLE_BOTH  );
}

HB_FUNC( _HMG_PRINTER_PREVIEW_DISABLESCROLLBARS )
{
   EnableScrollBar( ( HWND ) HB_PARNL( 1 ), SB_BOTH, ESB_DISABLE_BOTH );
}

HB_FUNC( _HMG_PRINTER_PREVIEW_DISABLEHSCROLLBAR )
{
   EnableScrollBar( ( HWND ) HB_PARNL( 1 ), SB_HORZ, ESB_DISABLE_BOTH );
}

HB_FUNC( _HMG_PRINTER_GETPRINTERWIDTH )
{

   HDC hdc = ( HDC ) HB_PARNL( 1 );

   hb_retnl( GetDeviceCaps( hdc, HORZSIZE ) );

}

HB_FUNC( _HMG_PRINTER_GETPRINTERHEIGHT )
{

   HDC hdc = ( HDC ) HB_PARNL( 1 );

   hb_retnl( GetDeviceCaps( hdc, VERTSIZE ) );

}

HB_FUNC( _HMG_PRINTER_GETPRINTABLEAREAPHYSICALOFFSETX )
{

   HDC hdc = ( HDC ) HB_PARNL( 1 );

   hb_retnl( GetDeviceCaps( hdc, PHYSICALOFFSETX ) );

}

HB_FUNC( _HMG_PRINTER_GETPRINTABLEAREALOGPIXELSX )
{

   HDC hdc = ( HDC ) HB_PARNL( 1 );

   hb_retnl( GetDeviceCaps( hdc, LOGPIXELSX ) );

}

HB_FUNC( _HMG_PRINTER_GETPRINTABLEAREAPHYSICALOFFSETY )
{

   HDC hdc = ( HDC ) HB_PARNL( 1 );

   hb_retnl( GetDeviceCaps( hdc, PHYSICALOFFSETY ) );

}

HB_FUNC( _HMG_PRINTER_GETPRINTABLEAREALOGPIXELSY )
{

   HDC hdc = ( HDC ) HB_PARNL( 1 );

   hb_retnl( GetDeviceCaps( hdc, LOGPIXELSY ) );

}

HB_FUNC( _HMG_PRINTER_C_IMAGE )
{
   // 1: hDC
   // 2: Image File
   // 3: Row
   // 4: Col
   // 5: Height
   // 6: Width
   // 7: Stretch
   // 8: Transparent

   HDC     hdcPrint  = ( HDC ) HB_PARNL( 1 );
   char *  FileName  = ( char * ) hb_parc( 2 );
   BOOL    bBmpImage = TRUE;
   HBITMAP hBitmap;
   HRGN    hRgn;
   HDC     memDC;
   INT     nWidth, nHeight;
   POINT   Point;
   BITMAP  Bmp;
   int     r   = hb_parni( 3 ); // Row
   int     c   = hb_parni( 4 ); // Col
   int     odr = hb_parni( 5 ); // Height
   int     odc = hb_parni( 6 ); // Width
   int     dr;
   int     dc;

   if( hdcPrint != NULL )
   {
      c  = ( c * GetDeviceCaps( hdcPrint, LOGPIXELSX ) / 1000 ) - GetDeviceCaps( hdcPrint, PHYSICALOFFSETX );
      r  = ( r * GetDeviceCaps( hdcPrint, LOGPIXELSY ) / 1000 ) - GetDeviceCaps( hdcPrint, PHYSICALOFFSETY );
      dc = ( odc * GetDeviceCaps( hdcPrint, LOGPIXELSX ) / 1000 );
      dr = ( odr * GetDeviceCaps( hdcPrint, LOGPIXELSY ) / 1000 );

      hBitmap = ( HBITMAP ) LoadImage( GetInstance(), FileName, IMAGE_BITMAP, 0, 0, LR_CREATEDIBSECTION );

      if( hBitmap == NULL )
         hBitmap = ( HBITMAP ) LoadImage( NULL, FileName, IMAGE_BITMAP, 0, 0, LR_LOADFROMFILE | LR_CREATEDIBSECTION );

      if( hBitmap == NULL )
      {
         bBmpImage = FALSE;
         hBitmap   = HMG_LoadImage( FileName );
      }
      if( hBitmap == NULL )
         return;

      GetObject( hBitmap, sizeof( BITMAP ), &Bmp );
      nWidth  = Bmp.bmWidth;
      nHeight = Bmp.bmHeight;

      if( ! hb_parl( 7 ) ) // Scale
      {
         if( odr * nHeight / nWidth <= odr )
            dr = odc * GetDeviceCaps( hdcPrint, LOGPIXELSY ) / 1000 * nHeight / nWidth;
         else
            dc = odr * GetDeviceCaps( hdcPrint, LOGPIXELSX ) / 1000 * nWidth / nHeight;
      }

      GetViewportOrgEx( hdcPrint, &Point );

      hRgn = CreateRectRgn( c + Point.x,
                            r + Point.y,
                            c + dc + Point.x - 1,
                            r + dr + Point.y - 1 );

      SelectClipRgn( hdcPrint, hRgn );

      if( ! bBmpImage )
      {
         if( hb_parl( 7 ) )             // Stretch
            SetStretchBltMode( hdcPrint, COLORONCOLOR );
         else
         {
            GetBrushOrgEx( hdcPrint, &Point );
            SetStretchBltMode( hdcPrint, HALFTONE );
            SetBrushOrgEx( hdcPrint, Point.x, Point.y, NULL );
         }
      }

      memDC = CreateCompatibleDC( hdcPrint );
      SelectObject( memDC, hBitmap );

      if( hb_parl( 8 ) && ! bBmpImage ) // Transparent
         TransparentBlt( hdcPrint, c, r, dc, dr, memDC, 0, 0, nWidth, nHeight, GetPixel( memDC, 0, 0 ) );
      else
         StretchBlt( hdcPrint, c, r, dc, dr, memDC, 0, 0, nWidth, nHeight, SRCCOPY );

      SelectClipRgn( hdcPrint, NULL );

      DeleteObject( hBitmap );
      DeleteDC( memDC );
   }

}

//  GetJobInfo ( cPrinterName, nJobID ) --> { nJobID, cPrinterName, cMachineName, cUserName, cDocument, cDataType, cStatus, nStatus
//                                            nPriorityLevel, nPositionPrintQueue, nTotalPages, nPagesPrinted, cLocalDate, cLocalTime }
HB_FUNC( _HMG_PRINTGETJOBINFO )
{

   char *     cPrinterName = ( char * ) hb_parc( 1 );
   DWORD      nJobID       = ( DWORD ) hb_parni( 2 );
   HANDLE     hPrinter     = NULL;
   char       cDateTime[ 256 ];
   SYSTEMTIME LocalSystemTime;

   if( OpenPrinter( cPrinterName, &hPrinter, NULL ) )
   {
      DWORD        nBytesNeeded = 0;
      DWORD        nBytesUsed   = 0;
      JOB_INFO_1 * Job_Info_1;

      GetJob( hPrinter, nJobID, 1, NULL, 0, &nBytesNeeded );

      if( nBytesNeeded > 0 )
      {
         Job_Info_1 = ( JOB_INFO_1 * ) hb_xgrab( nBytesNeeded );
         ZeroMemory( Job_Info_1, nBytesNeeded );

         if( GetJob( hPrinter, nJobID, 1, ( LPBYTE ) Job_Info_1, nBytesNeeded, &nBytesUsed ) )
         {
            hb_reta( 14 );
            HB_STORNI( ( INT ) Job_Info_1->JobId, -1, 1 );
            HB_STORC(      Job_Info_1->pPrinterName, -1, 2 );
            HB_STORC(      Job_Info_1->pMachineName, -1, 3 );
            HB_STORC(      Job_Info_1->pUserName, -1, 4 );
            HB_STORC(      Job_Info_1->pDocument, -1, 5 );
            HB_STORC(      Job_Info_1->pDatatype, -1, 6 );
            HB_STORC(      Job_Info_1->pStatus, -1, 7 );
            HB_STORNI( ( INT ) Job_Info_1->Status, -1, 8 );
            HB_STORNI( ( INT ) Job_Info_1->Priority, -1, 9 );
            HB_STORNI( ( INT ) Job_Info_1->Position, -1, 10 );
            HB_STORNI( ( INT ) Job_Info_1->TotalPages, -1, 11 );
            HB_STORNI( ( INT ) Job_Info_1->PagesPrinted, -1, 12 );

            SystemTimeToTzSpecificLocalTime( NULL, &Job_Info_1->Submitted, &LocalSystemTime );

            wsprintf( cDateTime, "%02d/%02d/%02d", LocalSystemTime.wYear, LocalSystemTime.wMonth, LocalSystemTime.wDay );
            HB_STORC( cDateTime, -1, 13 );

            wsprintf( cDateTime, "%02d:%02d:%02d", LocalSystemTime.wHour, LocalSystemTime.wMinute, LocalSystemTime.wSecond );
            HB_STORC( cDateTime, -1, 14 );
         }
         else
            hb_reta( 0 );

         if( Job_Info_1 )
            hb_xfree( ( void * ) Job_Info_1 );
      }
      else
         hb_reta( 0 );

      ClosePrinter( hPrinter );
   }
   else
      hb_reta( 0 );

}

HB_FUNC( _HMG_PRINTERGETSTATUS )
{

   char * cPrinterName = ( char * ) hb_parc( 1 );
   HANDLE hPrinter     = NULL;
   DWORD  nBytesNeeded = 0;
   DWORD  nBytesUsed   = 0;
   PRINTER_INFO_6 * Printer_Info_6;

   if( OpenPrinter( cPrinterName, &hPrinter, NULL ) )
   {
      GetPrinter( hPrinter, 6, NULL, 0, &nBytesNeeded );
      if( nBytesNeeded > 0 )
      {
         Printer_Info_6 = ( PRINTER_INFO_6 * ) hb_xgrab( nBytesNeeded );
         ZeroMemory( Printer_Info_6, nBytesNeeded );

         if( GetPrinter( hPrinter, 6, ( LPBYTE ) Printer_Info_6, nBytesNeeded, &nBytesUsed ) )
            hb_retnl( Printer_Info_6->dwStatus );
         else
            hb_retnl( PRINTER_STATUS_NOT_AVAILABLE );

         if( Printer_Info_6 )
            hb_xfree( ( void * ) Printer_Info_6 );
      }
      else
         hb_retnl( PRINTER_STATUS_NOT_AVAILABLE );

      ClosePrinter( hPrinter );
   }
   else
      hb_retnl( PRINTER_STATUS_NOT_AVAILABLE );

}

HB_FUNC( GETTEXTALIGN )
{

   hb_retni( GetTextAlign( ( HDC ) HB_PARNL( 1 ) ) );

}

HB_FUNC( SETTEXTALIGN )
{

   hb_retni( SetTextAlign( ( HDC ) HB_PARNL( 1 ), ( UINT ) hb_parni( 2 ) ) );

}

static HBITMAP loademffile( char * filename, int width, int height, HWND handle, int scalestrech, int whitebackground );

HB_FUNC( INITEMFFILE )
{

   HWND hWnd;
   HWND hWndParent = ( HWND ) HB_PARNL( 1 );
   int  Style      = WS_CHILD | SS_BITMAP;

   if( ! hb_parl( 5 ) )
      Style |= WS_VISIBLE;

   if( hb_parl( 6 ) )
      Style |= SS_NOTIFY;

   hWnd = CreateWindowEx( 0, WC_STATIC, NULL, Style, hb_parni( 3 ), hb_parni( 4 ), 0, 0, hWndParent, ( HMENU ) HB_PARNL( 2 ), GetInstance(), NULL );

   HB_RETNL( ( LONG_PTR ) hWnd );

}

HB_FUNC( C_SETEMFFILE )
{

   HBITMAP hBitmap;

   if( hb_parclen( 2 ) == 0 )
      HB_RETNL( ( LONG_PTR ) NULL );

   hBitmap = loademffile( ( char * ) hb_parc( 2 ), hb_parni( 3 ), hb_parni( 4 ), ( HWND ) HB_PARNL( 1 ), hb_parni( 5 ), hb_parni( 6 ) );

   if( hBitmap != NULL )
      SendMessage( ( HWND ) HB_PARNL( 1 ), ( UINT ) STM_SETIMAGE, ( WPARAM ) IMAGE_BITMAP, ( LPARAM ) hBitmap );

   HB_RETNL( ( LONG_PTR ) hBitmap );

}

static BOOL read_image( char * filename, DWORD * nFileSize, HGLOBAL * hMem )
{

   HANDLE hFile;
   LPVOID lpDest;
   DWORD  dwFileSize;
   DWORD  dwBytesRead = 0;
   BOOL   bRead;

   // open the file
   hFile = CreateFile( filename, GENERIC_READ, 0, NULL, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, NULL );
   if( hFile == INVALID_HANDLE_VALUE )
      return FALSE;
   // we will read the whole file in global memory, find the size first
   dwFileSize = GetFileSize( hFile, NULL );
   // allocate memory to read the whole file
   if( dwFileSize == INVALID_FILE_SIZE || ( *hMem = GlobalAlloc( GHND, dwFileSize ) ) == NULL )
   {
      CloseHandle( hFile );
      return FALSE;
   }

   *nFileSize = dwFileSize;

   // lock memory for image
   lpDest = GlobalLock( *hMem );

   if( lpDest == NULL )
   {
      GlobalFree( *hMem );
      CloseHandle( hFile );
      return FALSE;
   }

   // read file and store in global memory
   bRead = ReadFile( hFile, lpDest, dwFileSize, &dwBytesRead, NULL );

   GlobalUnlock( *hMem );
   CloseHandle( hFile );

   if( ! bRead )
   {
      GlobalFree( *hMem );
      return FALSE;
   }

   return TRUE;

}

static void calc_rect( HWND handle, int width, int height, int scalestrech, LONG lWidth, LONG lHeight, RECT * rect, RECT * rect2 )
{

   if( width == 0 && height == 0 )
      GetClientRect( handle, rect );
   else
      SetRect( rect, 0, 0, width, height );

   SetRect( rect2, 0, 0, rect->right, rect->bottom );

   if( scalestrech == 0 )
   {
      if( ( int ) lWidth * rect->bottom / lHeight <= rect->right )
         rect->right = ( int ) lWidth * rect->bottom / lHeight;
      else
         rect->bottom = ( int ) lHeight * rect->right / lWidth;
   }

   rect->left = ( int ) ( width - rect->right ) / 2;
   rect->top  = ( int ) ( height - rect->bottom ) / 2;

}

static HBITMAP loademffile( char * filename, int width, int height, HWND handle, int scalestrech, int whitebackground )
{

   IStream *  iStream;
   IPicture * iPicture = NULL;
   HGLOBAL    hMem     = ( HGLOBAL ) NULL;
   HRESULT    hr;
   DWORD      nFileSize = 0;
   RECT       rect, rect2;
   HBITMAP    bitmap;
   LONG       lWidth, lHeight;
   HDC        imgDC = GetDC( handle );
   HDC        tmpDC;

   if( read_image( filename, &nFileSize, &hMem ) == FALSE )
   {
      ReleaseDC( handle, imgDC );
      return NULL;
   }
   // don't delete memory on object's release
   hr = CreateStreamOnHGlobal( hMem, FALSE, &iStream );
   if( hr != S_OK || iStream == NULL )
   {
      GlobalFree( hMem );
      ReleaseDC( handle, imgDC );
      return NULL;
   }
   // Load from stream
#if defined( __cplusplus )
   hr = OleLoadPicture( iStream, nFileSize, ( nFileSize == 0 ), IID_IPicture, ( LPVOID * ) &iPicture );
#else
   hr = OleLoadPicture( iStream, nFileSize, ( nFileSize == 0 ), &IID_IPicture, ( LPVOID * ) &iPicture );
   iStream->lpVtbl->Release( iStream );
#endif
   if( hr != S_OK || iPicture == NULL )
   {
      GlobalFree( hMem );
      ReleaseDC( handle, imgDC );
      return NULL;
   }

   iPicture->lpVtbl->get_Width( iPicture, &lWidth );
   iPicture->lpVtbl->get_Height( iPicture, &lHeight );

   calc_rect( handle, width, height, scalestrech, lWidth, lHeight, &rect, &rect2 );

   tmpDC  = CreateCompatibleDC( imgDC );
   bitmap = CreateCompatibleBitmap( imgDC, width, height );
   SelectObject( tmpDC, bitmap );

   if( whitebackground == 1 )
      FillRect( tmpDC, &rect2, ( HBRUSH ) GetStockObject( WHITE_BRUSH ) );
   else
      FillRect( tmpDC, &rect2, ( HBRUSH ) GetSysColorBrush( COLOR_BTNFACE ) );

   // Render to device context
   iPicture->lpVtbl->Render( iPicture, tmpDC, rect.left, rect.top, rect.right, rect.bottom, 0, lHeight, lWidth, -lHeight, NULL );
   iPicture->lpVtbl->Release( iPicture );
   GlobalFree( hMem );

   DeleteDC( tmpDC );
   ReleaseDC( handle, imgDC );

   return bitmap;

}
