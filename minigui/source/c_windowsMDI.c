/*----------------------------------------------------------------------------
   MINIGUI - Harbour Win32 GUI library source code

   Copyright 2002-2010 Roberto Lopez <harbourminigui@gmail.com>
   http://harbourminigui.googlepages.com/

   MDI window source code
   (C)2005 Janusz Pora <januszpora@onet.eu>

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
    Copyright 2001 Alexander S.Kresin <alex@kresin.ru>
    Copyright 2001 Antonio Linares <alinares@fivetech.com>
    www - https://harbour.github.io/

    "Harbour Project"
    Copyright 1999-2021, https://harbour.github.io/

    "WHAT32"
    Copyright 2002 AJ Wos <andrwos@aust1.net>

    "HWGUI"
    Copyright 2001-2018 Alexander S.Kresin <alex@kresin.ru>

   ---------------------------------------------------------------------------*/

#include <mgdefs.h>

#include <commctrl.h>

#include "hbvm.h"

#ifndef __XHARBOUR__
#include "hbwinuni.h"
#else
#define HB_STRNCPY  hb_strncpy
#endif

LRESULT CALLBACK  MdiWndProc( HWND hwnd, UINT msg, WPARAM wParam, LPARAM lParam );
LRESULT CALLBACK  MdiChildWndProc( HWND hwnd, UINT msg, WPARAM wParam, LPARAM lParam );

#ifdef UNICODE
   LPWSTR AnsiToWide( LPCSTR );
#endif
HINSTANCE GetResources( void );
HINSTANCE GetInstance( void );

static HWND hwndMDIClient;

HB_FUNC( REGISTERMDIWINDOW )
{
#ifndef UNICODE
   LPCTSTR lpIconName = HB_ISCHAR( 1 ) ? hb_parc( 1 ) : NULL;
   LPCTSTR lpClassName = hb_parc( 2 );
#else
   LPWSTR lpIconName = HB_ISCHAR( 1 ) ? AnsiToWide( ( char * ) hb_parc( 1 ) ) : NULL;
   LPWSTR lpClassName = AnsiToWide( ( char * ) hb_parc( 2 ) );
#endif
   WNDCLASS WndClass;

   HBRUSH hbrush = 0;

   memset( &WndClass, 0, sizeof( WNDCLASS ) );

   WndClass.style       = CS_HREDRAW | CS_VREDRAW | CS_DBLCLKS;
   WndClass.lpfnWndProc = MdiWndProc;
   WndClass.cbClsExtra  = 0;
   WndClass.cbWndExtra  = 0;
   WndClass.hInstance   = GetInstance();
   WndClass.hIcon       = LoadIcon( GetResources(), lpIconName );
   if( WndClass.hIcon == NULL )
      WndClass.hIcon = ( HICON ) LoadImage( NULL, lpIconName, IMAGE_ICON, 0, 0, LR_LOADFROMFILE + LR_DEFAULTSIZE );

   if( WndClass.hIcon == NULL )
      WndClass.hIcon = LoadIcon( NULL, IDI_APPLICATION );

   WndClass.hCursor = LoadCursor( NULL, IDC_ARROW );
   if( HB_PARNI( 3, 1 ) == -1 )
      WndClass.hbrBackground = ( HBRUSH ) ( COLOR_WINDOW + 1 );
   else
   {
      hbrush = CreateSolidBrush( RGB( HB_PARNI( 3, 1 ), HB_PARNI( 3, 2 ), HB_PARNI( 3, 3 ) ) );
      WndClass.hbrBackground = hbrush;
   }

   WndClass.lpszMenuName  = NULL;
   WndClass.lpszClassName = lpClassName;

   if( ! RegisterClass( &WndClass ) )
   {
      MessageBox( 0, TEXT( "Window MDI Registration Failed!" ), TEXT( "Error!" ), MB_ICONEXCLAMATION | MB_OK | MB_SYSTEMMODAL );
      ExitProcess( 0 );
   }

   WndClass.style       = 0;
   WndClass.lpfnWndProc = ( WNDPROC ) MdiChildWndProc;
   WndClass.cbClsExtra  = 0;
   WndClass.cbWndExtra  = 20;
   WndClass.hInstance   = GetInstance();

   // Owner of this class

   WndClass.hIcon = LoadIcon( GetResources(), lpIconName );
   if( WndClass.hIcon == NULL )
      WndClass.hIcon = ( HICON ) LoadImage( NULL, lpIconName, IMAGE_ICON, 0, 0, LR_LOADFROMFILE + LR_DEFAULTSIZE );

   if( WndClass.hIcon == NULL )
      WndClass.hIcon = LoadIcon( NULL, IDI_APPLICATION );

   WndClass.hCursor = LoadCursor( NULL, IDC_ARROW );

   if( HB_PARNI( 3, 1 ) == -1 )
      WndClass.hbrBackground = ( HBRUSH ) ( COLOR_WINDOW + 1 );
   else
      WndClass.hbrBackground = hbrush;

   WndClass.lpszMenuName  = NULL;
   WndClass.lpszClassName = TEXT( "MdiChildWndClass" );
   if( ! RegisterClass( ( LPWNDCLASS ) &WndClass ) )
   {
      MessageBox( 0, TEXT( "Window MdiChild Registration Failed!" ), TEXT( "Error!" ), MB_ICONEXCLAMATION | MB_OK | MB_SYSTEMMODAL );
      ExitProcess( 0 );
   }

   HB_RETNL( ( LONG_PTR ) hbrush );
}

LRESULT CALLBACK MdiWndProc( HWND hWnd, UINT message, WPARAM wParam, LPARAM lParam )
{
   static PHB_SYMB pSymbol = NULL;
   long int        r;

   if( ! pSymbol )
      pSymbol = hb_dynsymSymbol( hb_dynsymGet( "EVENTS" ) );

   if( pSymbol )
   {
      hb_vmPushSymbol( pSymbol );
      hb_vmPushNil();
      hb_vmPushNumInt( ( LONG_PTR ) hWnd );
      hb_vmPushLong( message );
      hb_vmPushNumInt( wParam );
      hb_vmPushNumInt( lParam );
      hb_vmDo( 4 );
   }

   r = hb_parnl( -1 );

   if( r != 0 )
      return r;
   else
      return DefFrameProc( hWnd, hwndMDIClient, message, wParam, lParam );
}

LRESULT CALLBACK MdiChildWndProc( HWND hWnd, UINT message, WPARAM wParam, LPARAM lParam )
{
   static PHB_SYMB pSymbol = NULL;
   long int        r;

   if( ! pSymbol )
      pSymbol = hb_dynsymSymbol( hb_dynsymGet( "MDIEVENTS" ) );

   if( pSymbol )
   {
      hb_vmPushSymbol( pSymbol );
      hb_vmPushNil();
      hb_vmPushNumInt( ( LONG_PTR ) hWnd );
      hb_vmPushLong( message );
      hb_vmPushNumInt( wParam );
      hb_vmPushNumInt( lParam );
      hb_vmDo( 4 );
   }

   r = hb_parnl( -1 );

   if( r == 0 )
      return DefMDIChildProc( hWnd, message, wParam, lParam );
   else
      return r;
}

HB_FUNC( INITMDIWINDOW )
{
#ifndef UNICODE
   LPCSTR lpWindowName = hb_parc( 1 );
   LPCSTR lpClassName  = hb_parc( 12 );
#else
   LPWSTR lpWindowName = AnsiToWide( ( char * ) hb_parc( 1 ) );
   LPWSTR lpClassName  = AnsiToWide( ( char * ) hb_parc( 12 ) );
#endif
   HWND  hwnd;
   DWORD Style = WS_CLIPSIBLINGS | WS_CLIPCHILDREN | WS_BORDER | WS_SYSMENU | WS_THICKFRAME;
   DWORD ExStyle;

   if( hb_parl( 16 ) )
      ExStyle = WS_EX_CONTEXTHELP;
   else
   {
      ExStyle = 0;
      if( ! hb_parl( 6 ) )
         Style = Style | WS_MINIMIZEBOX;

      if( ! hb_parl( 7 ) )
         Style = Style | WS_MAXIMIZEBOX;
   }

   if( ! hb_parl( 8 ) )
      Style = Style | WS_SIZEBOX;

   if( ! hb_parl( 9 ) )
      Style = Style | WS_SYSMENU;

   if( ! hb_parl( 10 ) )
      Style = Style | WS_CAPTION;

   if( hb_parl( 11 ) )
      ExStyle = ExStyle | WS_EX_TOPMOST;

   if( hb_parl( 14 ) )
      Style = Style | WS_VSCROLL;

   if( hb_parl( 15 ) )
      Style = Style | WS_HSCROLL;

   hwnd = CreateWindowEx
          (
      ExStyle,
      lpClassName,
      lpWindowName,
      Style,
      hb_parni( 2 ),
      hb_parni( 3 ),
      hb_parni( 4 ),
      hb_parni( 5 ),
      ( HWND ) HB_PARNL( 13 ),
      ( HMENU ) NULL,
      GetInstance(),
      NULL
          );

   if( hwnd == NULL )
   {
      MessageBox( 0, TEXT( "MDI Window Creation Failed!" ), TEXT( "Error!" ), MB_ICONEXCLAMATION | MB_OK | MB_SYSTEMMODAL );
      return;
   }

   HB_RETNL( ( LONG_PTR ) hwnd );
}

HB_FUNC( INITMDICLIENTWINDOW )
{
   HWND hwndparent;
   int  icount;

   CLIENTCREATESTRUCT ccs;

   memset( &ccs, 0, sizeof( ccs ) );

   hwndparent = ( HWND ) HB_PARNL( 1 );

   icount = GetMenuItemCount( GetMenu( hwndparent ) );

   // Find window menu where children will be listed

   ccs.hWindowMenu  = GetSubMenu( GetMenu( hwndparent ), icount - 2 );
   ccs.idFirstChild = 0;

   // Create the MDI client filling the client area

   hwndMDIClient = CreateWindow
                   (
      TEXT( "mdiclient" ),
      NULL,
      WS_CHILD | WS_CLIPCHILDREN | WS_VSCROLL | WS_HSCROLL | WS_VISIBLE,
      0,
      0,
      0,
      0,
      hwndparent,
      ( HMENU ) 0xCAC,
      GetInstance(),
      ( LPSTR ) &ccs
                   );

   ShowWindow( hwndMDIClient, SW_SHOW );

   HB_RETNL( ( LONG_PTR ) hwndMDIClient );
}

HB_FUNC( INITMDICHILDWINDOW )
{
   HWND hwndChild;
   MDICREATESTRUCT mcs;
   TCHAR      rgch[ 150 ];
   static int cUntitled;
   DWORD      Style = 0;

   if( hb_parl( 9 ) )
      rgch[ 0 ] = 0;
   else
   {
      if( hb_parc( 2 ) == NULL )
         wsprintf( rgch, TEXT( "Untitled%d" ), cUntitled++ );
      else
      {
#ifndef UNICODE
         LPCTSTR lpTitle = hb_parc( 2 );
#else
         LPWSTR  lpTitle = AnsiToWide( ( char * ) hb_parc( 2 ) );
#endif
         HB_STRNCPY( rgch, lpTitle, 149 );
         rgch[ 149 ] = 0;
      }
   }

   if( hb_parl( 10 ) )
      Style = Style | WS_VSCROLL;

   if( hb_parl( 11 ) )
      Style = Style | WS_HSCROLL;

   // Create the MDI child window

   mcs.szClass = TEXT( "MdiChildWndClass" ); // window class name
   mcs.szTitle = rgch;               // window title
   mcs.hOwner  = GetInstance();      // owner
   mcs.x       = hb_parni( 3 );      // x position
   mcs.y       = hb_parni( 4 );      // y position
   mcs.cx      = hb_parni( 5 );      // width
   mcs.cy      = hb_parni( 6 );      // height
   mcs.style   = Style;              // window style
   mcs.lParam  = 0;                  // lparam
   hwndChild   = ( HWND ) SendMessage( ( HWND ) HB_PARNL( 1 ), WM_MDICREATE, 0, ( LPARAM ) ( LPMDICREATESTRUCT ) &mcs );

   if( hwndChild != NULL )
   {
      Style = GetWindowLong( hwndChild, GWL_STYLE );

      if( hb_parl( 7 ) )
         Style = Style & ( ~WS_MINIMIZEBOX );

      if( hb_parl( 8 ) )
         Style = Style & ( ~WS_MAXIMIZEBOX );

      if( hb_parl( 9 ) )
         Style = Style & ( ~WS_CAPTION );

      SetWindowLongPtr( hwndChild, GWL_STYLE, Style );

      ShowWindow( hwndChild, SW_SHOW );
   }

   HB_RETNL( ( LONG_PTR ) hwndChild );
}

HB_FUNC( ARRANGEICONICWINDOWS )
{
   hb_retni( ArrangeIconicWindows( ( HWND ) HB_PARNL( 1 ) ) );
}

HB_FUNC( DEFMDICHILDPROC )
{
   hb_retnl( ( LONG ) DefMDIChildProc( ( HWND ) HB_PARNL( 1 ), hb_parnl( 2 ), hb_parnl( 3 ), hb_parnl( 4 ) ) );
}

HB_FUNC( DEFFRAMEPROC )
{
   hb_retnl( ( LONG ) DefFrameProc( ( HWND ) HB_PARNL( 1 ), ( HWND ) HB_PARNL( 2 ), hb_parnl( 3 ), hb_parnl( 4 ), hb_parnl( 5 ) ) );
}

HB_FUNC( SIZECLIENTWINDOW )
{
   RECT rc, rcClient;

   GetClientRect( ( HWND ) HB_PARNL( 1 ), &rcClient );
   if( HB_PARNL( 2 ) )
   {
      GetWindowRect( ( HWND ) HB_PARNL( 2 ), &rc );
      ScreenToClient( ( HWND ) HB_PARNL( 1 ), ( LPPOINT ) &rc.left );
      rcClient.bottom = rc.top;
   }

   rcClient.top = hb_parnl( 4 );
   MoveWindow( ( HWND ) HB_PARNL( 3 ), rcClient.left, rcClient.top, rcClient.right - rcClient.left, rcClient.bottom - rcClient.top, TRUE );
}
