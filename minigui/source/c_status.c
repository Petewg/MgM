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

    "WHAT32"
    Copyright 2002 AJ Wos <andrwos@aust1.net>

    "HWGUI"
    Copyright 2001-2015 Alexander S.Kresin <alex@belacy.ru>

   ---------------------------------------------------------------------------*/

#define _WIN32_IE  0x0501

#include <mgdefs.h>

#include <commctrl.h>

HINSTANCE GetInstance( void );
HINSTANCE GetResources( void );

HB_FUNC( INITMESSAGEBAR )
{
   HWND hWndSB;
   int  ptArray[ 40 ];  // Array defining the number of parts/sections
   int  nrOfParts = 1;

   hWndSB = CreateStatusWindow( WS_CHILD | WS_VISIBLE | SBT_TOOLTIPS, NULL, ( HWND ) HB_PARNL( 1 ), hb_parni( 2 ) );

   if( hWndSB )
      SendMessage( hWndSB, SB_SETPARTS, nrOfParts, ( LPARAM ) ( LPINT ) ptArray );

   HB_RETNL( ( LONG_PTR ) hWndSB );
}

HB_FUNC( INITITEMBAR )
{
   HWND  hWndSB;
   int   cSpaceInBetween = 8;
   int   ptArray[ 40 ]; // Array defining the number of parts/sections
   int   nrOfParts = 0;
   int   n;
   RECT  rect;
   HDC   hDC;
   WORD  displayFlags;
   HICON hIcon;
   int   Style;
   int   cx;
   int   cy;

   hWndSB = ( HWND ) HB_PARNL( 1 );
   Style  = GetWindowLong( ( HWND ) GetParent( hWndSB ), GWL_STYLE );

   switch( hb_parni( 8 ) )
   {
      case 0:  displayFlags = 0; break;
      case 1:  displayFlags = SBT_POPOUT; break;
      case 2:  displayFlags = SBT_NOBORDERS; break;
      default: displayFlags = 0;
   }

   if( hb_parnl( 5 ) )
   {
      nrOfParts = SendMessage( hWndSB, SB_GETPARTS, 40, 0 );
      SendMessage( hWndSB, SB_GETPARTS, 40, ( LPARAM ) ( LPINT ) ptArray );
   }

   nrOfParts++;

   hDC = GetDC( hWndSB );
   GetClientRect( hWndSB, &rect );

   if( hb_parnl( 5 ) == 0 )
      ptArray[ nrOfParts - 1 ] = rect.right;
   else
   {
      for( n = 0; n < nrOfParts - 1; n++ )
         ptArray[ n ] -= hb_parni( 4 ) - cSpaceInBetween;

      if( Style & WS_SIZEBOX )
      {
         if( nrOfParts == 2 )
            ptArray[ 0 ] -= 21;

         ptArray[ nrOfParts - 1 ] = rect.right - rect.bottom - rect.top + 2;
      }
      else
         ptArray[ nrOfParts - 1 ] = rect.right;
   }

   ReleaseDC( hWndSB, hDC );

   SendMessage( hWndSB, SB_SETPARTS, nrOfParts, ( LPARAM ) ( LPINT ) ptArray );

   cy = rect.bottom - rect.top - 4;
   cx = cy;

   hIcon = ( HICON ) LoadImage( GetResources(), hb_parc( 6 ), IMAGE_ICON, cx, cy, 0 );

   if( hIcon == NULL )
      hIcon = ( HICON ) LoadImage( NULL, hb_parc( 6 ), IMAGE_ICON, cx, cy, LR_LOADFROMFILE );

   if( ! ( hIcon == NULL ) )
      SendMessage( hWndSB, SB_SETICON, ( WPARAM ) ( nrOfParts - 1 ), ( LPARAM ) hIcon );

   SendMessage( hWndSB, SB_SETTEXT, ( nrOfParts - 1 ) | displayFlags, ( LPARAM ) hb_parc( 2 ) );
   SendMessage( hWndSB, SB_SETTIPTEXT, ( WPARAM ) ( nrOfParts - 1 ), ( LPARAM ) hb_parc( 7 ) );

   hb_retni( nrOfParts );
}

HB_FUNC( SETITEMBAR )
{
   char cString[ 1024 ] = "";
   int  displayFlags;

   displayFlags = HIWORD( SendMessage( ( HWND ) HB_PARNL( 1 ), SB_GETTEXT, ( WPARAM ) hb_parni( 3 ), ( LPARAM ) cString ) );
   SendMessage( ( HWND ) HB_PARNL( 1 ), SB_SETTEXT, hb_parni( 3 ) | displayFlags, ( LPARAM ) hb_parc( 2 ) );
}

HB_FUNC( GETITEMBAR )
{
   char * cString;
   HWND   hWnd;
   int    iPos;

   hWnd    = ( HWND ) HB_PARNL( 1 );
   iPos    = hb_parni( 2 );
   cString = ( char * ) hb_xgrab( LOWORD( SendMessage( hWnd, SB_GETTEXTLENGTH, iPos - 1, 0 ) ) + 1 );
   SendMessage( hWnd, SB_GETTEXT, ( WPARAM ) iPos - 1, ( LPARAM ) cString );
   hb_retc( cString );
   hb_xfree( cString );
}

HB_FUNC( REFRESHITEMBAR )
{
   HWND hWndSB;
   int  ptArray[ 40 ];  // Array defining the number of parts/sections
   int  nDev;
   int  n, s;
   int  nrOfParts;
   RECT rect;
   HDC  hDC;
   int  size;

   hWndSB    = ( HWND ) HB_PARNL( 1 );
   size      = hb_parni( 2 );
   nrOfParts = SendMessage( hWndSB, SB_GETPARTS, 40, 0 );
   SendMessage( hWndSB, SB_GETPARTS, 40, ( LPARAM ) ( LPINT ) ptArray );

   hDC = GetDC( hWndSB );
   GetClientRect( hWndSB, &rect );

   if( ( nrOfParts == 1 ) || ( IsZoomed( GetParent( hWndSB ) ) ) || ( ! ( GetWindowLong( ( HWND ) GetParent( hWndSB ), GWL_STYLE ) & WS_SIZEBOX ) ) )
      nDev = rect.right - ptArray[ nrOfParts - 1 ];
   else
      nDev = rect.right - ptArray[ nrOfParts - 1 ] - rect.bottom - rect.top + 2;

   s = TRUE;
   if( rect.right > 0 )
      for( n = 0; n <= nrOfParts - 1; n++ )
      {

         if( n == 0 )
         {
            if( size >= ptArray[ n ] && nDev < 0 )
               s = FALSE;
            else
            {
               if( ptArray[ n ] + nDev < size )
                  nDev = size - ptArray[ n ];

               ptArray[ n ] += nDev;
            }
         }
         else if( s )
            ptArray[ n ] += nDev;

      }

   ReleaseDC( hWndSB, hDC );

   SendMessage( hWndSB, SB_SETPARTS, nrOfParts, ( LPARAM ) ( LPINT ) ptArray );
   hb_retni( nrOfParts );
}

HB_FUNC( KEYTOGGLE )
{
   BYTE pBuffer[ 256 ];
   WORD wKey = ( WORD ) hb_parni( 1 );

   GetKeyboardState( pBuffer );

   if( pBuffer[ wKey ] & 0x01 )
      pBuffer[ wKey ] &= 0xFE;
   else
      pBuffer[ wKey ] |= 0x01;

   SetKeyboardState( pBuffer );
}

HB_FUNC( KEYTOGGLENT )
{
   BYTE wKey = ( BYTE ) hb_parni( 1 );

   keybd_event( wKey, 0x45, KEYEVENTF_EXTENDEDKEY | 0, 0 );
   keybd_event( wKey, 0x45, KEYEVENTF_EXTENDEDKEY | KEYEVENTF_KEYUP, 0 );
}

HB_FUNC( SETSTATUSITEMICON )
{
   HWND  hwnd;
   RECT  rect;
   HICON hIcon;
   int   cx;
   int   cy;

   hwnd = ( HWND ) HB_PARNL( 1 );

   // Unloads from memory current icon

   DestroyIcon( ( HICON ) SendMessage( hwnd, SB_GETICON, ( WPARAM ) hb_parni( 2 ) - 1, ( LPARAM ) 0 ) );

   GetClientRect( hwnd, &rect );

   cy = rect.bottom - rect.top - 4;
   cx = cy;

   hIcon = ( HICON ) LoadImage( GetResources(), hb_parc( 3 ), IMAGE_ICON, cx, cy, 0 );

   if( hIcon == NULL )
      hIcon = ( HICON ) LoadImage( NULL, hb_parc( 3 ), IMAGE_ICON, cx, cy, LR_LOADFROMFILE );

   SendMessage( hwnd, SB_SETICON, ( WPARAM ) hb_parni( 2 ) - 1, ( LPARAM ) hIcon );
}

HB_FUNC( SETSTATUSBARSIZE )
{
   HLOCAL hloc;
   LPINT  lpParts;

   HWND hwndStatus = ( HWND ) HB_PARNL( 1 );
   int  nParts     = hb_parinfa( 2, 0 );
   int  nWidth;
   int  i;

   // Set Widths from array

   hloc    = LocalAlloc( LHND, sizeof( int ) * nParts );
   lpParts = ( LPINT ) LocalLock( hloc );

   nWidth = 0;

   for( i = 0; i < nParts; i++ )
   {
      nWidth       = nWidth + HB_PARNI( 2, i + 1 );
      lpParts[ i ] = nWidth;
   }

   SendMessage( hwndStatus, SB_SETPARTS, ( WPARAM ) nParts, ( LPARAM ) lpParts );

   MoveWindow( ( HWND ) hwndStatus, 0, 0, 0, 0, TRUE );

   LocalUnlock( hloc );
   LocalFree( hloc );
}

HB_FUNC( REFRESHSTATUSITEM )
{
   HWND hwndStatus = ( HWND ) HB_PARNL( 1 );
   RECT rc;

   SendMessage( hwndStatus, SB_GETRECT, ( WPARAM ) hb_parni( 2 ) - 1, ( LPARAM ) &rc );
   RedrawWindow( hwndStatus, &rc, NULL, RDW_ERASE | RDW_INVALIDATE | RDW_ALLCHILDREN | RDW_ERASENOW | RDW_UPDATENOW );
}

HB_FUNC( REFRESHPROGRESSITEM )       // RefreshProgressItem( HwndStatus, NrItem, hProgress )
{
   HWND hwndStatus = ( HWND ) HB_PARNL( 1 );
   RECT rc;

   SendMessage( hwndStatus, SB_GETRECT, ( WPARAM ) hb_parni( 2 ) - 1, ( LPARAM ) &rc );
   SetWindowPos( ( HWND ) HB_PARNL( 3 ), 0, rc.left, rc.top, 0, 0, SWP_NOSIZE | SWP_NOZORDER | SWP_NOACTIVATE );
}

HB_FUNC( CREATEPROGRESSBARITEM )     // CreateProgressBarItem( HwndStatus, NrItem )
{
   HWND hwndStatus = ( HWND ) HB_PARNL( 1 );
   HWND hwndProgressBar;
   RECT rc;
   int  Style = WS_CHILD | PBS_SMOOTH;

   SendMessage( hwndStatus, SB_GETRECT, ( WPARAM ) hb_parni( 2 ) - 1, ( LPARAM ) &rc );
   if( hb_parni( 3 ) )
      Style = Style | WS_VISIBLE;

   if
   (
      (
         hwndProgressBar = CreateWindowEx
                           (
            0,
            PROGRESS_CLASS,
            ( LPCTSTR ) NULL,
            Style,
            rc.top,
            rc.left,
            rc.right - rc.left,
            rc.bottom - rc.top - 1, // No size or position.
            hwndStatus,             // Handle to the parent window.
            ( HMENU ) NULL,         // ID for the progress window.
            GetInstance(),          // Current instance.
            ( LPVOID ) NULL
                           )
      ) != NULL
   )
   {
      SendMessage( hwndProgressBar, PBM_SETRANGE, 0, MAKELONG( hb_parni( 4 ), hb_parni( 5 ) ) );
      SendMessage( hwndProgressBar, PBM_SETPOS, ( WPARAM ) hb_parni( 3 ), 0 );

      HB_RETNL( ( LONG_PTR ) hwndProgressBar );
   }
   else // No application-defined data.
   {
      HB_RETNL( ( LONG_PTR ) NULL );
   }
}

HB_FUNC( SETPOSPROGRESSBARITEM )     // SetPosProgressBarItem( HwndProgressBar, nPos )
{
   HWND hwndProgressBar = ( HWND ) HB_PARNL( 1 );

   ShowWindow(  hwndProgressBar, hb_parni( 2 ) ? SW_SHOW : SW_HIDE );
   SendMessage( hwndProgressBar, PBM_SETPOS, ( WPARAM ) hb_parni( 2 ), 0 );
}
