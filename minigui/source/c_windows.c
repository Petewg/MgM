/*
   MINIGUI - Harbour Win32 GUI library source code

   Copyright 2002-2010 Roberto Lopez <harbourminigui@gmail.com>
   http://harbourminigui.googlepages.com/

   This    program  is  free  software;  you can redistribute it and/or modify
   it under  the  terms  of the GNU General Public License as published by the
   Free  Software   Foundation;  either  version 2 of the License, or (at your
   option) any later version.

   This   program   is   distributed  in  the hope that it will be useful, but
   WITHOUT    ANY    WARRANTY;    without   even   the   implied  warranty  of
   MERCHANTABILITY  or  FITNESS  FOR A PARTICULAR PURPOSE. See the GNU General
   Public License for more details.

   You   should  have  received a copy of the GNU General Public License along
   with   this   software;   see  the  file COPYING. If not, write to the Free
   Software   Foundation,   Inc.,   59  Temple  Place,  Suite  330, Boston, MA
   02111-1307 USA (or visit the web site http://www.gnu.org/).

   As   a   special  exception, you have permission for additional uses of the
   text  contained  in  this  release  of  Harbour Minigui.

   The   exception   is that,   if   you  link  the  Harbour  Minigui  library
   with  other    files   to  produce   an   executable,   this  does  not  by
   itself   cause  the   resulting   executable    to   be  covered by the GNU
   General  Public  License.  Your    use  of that   executable   is   in   no
   way  restricted on account of linking the Harbour-Minigui library code into
   it.

   Parts of this project are based upon:

    "Harbour GUI framework for Win32"
    Copyright 2001 Alexander S.Kresin <alex@belacy.ru>
    Copyright 2001 Antonio Linares <alinares@fivetech.com>
    www - http://harbour-project.org

    "Harbour Project"
    Copyright 1999-2017, http://harbour-project.org/

    "WHAT32"
    Copyright 2002 AJ Wos <andrwos@aust1.net>

    "HWGUI"
    Copyright 2001-2015 Alexander S.Kresin <alex@belacy.ru>

   Parts  of  this  code  is contributed and used here under permission of his
   author: Copyright 2016 (C) P.Chornyj <myorg63@mail.ru>
 */

#define _WIN32_IE     0x0501

#include <mgdefs.h>
#if ( defined ( __MINGW32__ ) || defined ( __XCC__ ) ) && ( _WIN32_WINNT < 0x0500 )
#define _WIN32_WINNT  0x0500
#endif
#include <commctrl.h>
#include "hbapiitm.h"
#include "hbvm.h"

#ifndef WC_STATIC
#define WC_STATIC     "Static"
#endif

#ifdef MAKELONG
#undef MAKELONG
#endif
#define MAKELONG( a, b )  ( ( LONG ) ( ( ( WORD ) ( ( DWORD_PTR ) ( a ) & 0xffff ) ) | ( ( ( DWORD ) ( ( WORD ) ( ( DWORD_PTR ) ( b ) & 0xffff ) ) ) << 16 ) ) )

extern void       hmg_ErrorExit( LPCTSTR lpMessage, DWORD dwError, BOOL bExit );
extern HBITMAP    HMG_LoadImage( const char * FileName );

extern HINSTANCE g_hInstance;
static PHB_DYNS  g_ListenerDyns = NULL;

#define DEFAULT_LISTENER  "EVENTS"

HB_FUNC( GETGLOBALLISTENER )
{
   if( NULL != g_ListenerDyns )
      hb_retc( hb_dynsymName( g_ListenerDyns ) );
   else
      hb_retc_null();
}

HB_FUNC( SETGLOBALLISTENER )
{
   const char * pszTmp = hb_parc( 1 );

   if( pszTmp && hb_dynsymIsFunction( hb_dynsymFindName( pszTmp ) ) )
   {
      g_ListenerDyns = hb_dynsymGet( pszTmp );
      hb_retl( HB_TRUE );
   }
   else
      hb_retl( HB_FALSE );
}

HB_FUNC( RESETGLOBALLISTENER )
{
   g_ListenerDyns = hb_dynsymGet( DEFAULT_LISTENER );
}

LRESULT CALLBACK WndProc( HWND hWnd, UINT message, WPARAM wParam, LPARAM lParam )
{
   long     r;
   PHB_SYMB g_ListenerSymb = hb_dynsymSymbol( g_ListenerDyns );

   if( g_ListenerSymb )
   {
      hb_vmPushSymbol( g_ListenerSymb );
      hb_vmPushNil();
      hb_vmPushNumInt( ( LONG_PTR ) hWnd );
      hb_vmPushLong( message );
      hb_vmPushNumInt( wParam );
      hb_vmPushNumInt( lParam );
      hb_vmDo( 4 );
   }

   r = hb_parnl( -1 );

   return ( r != 0 ) ? r : DefWindowProc( hWnd, message, wParam, lParam );
}

HB_FUNC( INITDUMMY )
{
   CreateWindowEx( 0, WC_STATIC, "", WS_CHILD, 0, 0, 0, 0, ( HWND ) HB_PARNL( 1 ), ( HMENU ) 0, g_hInstance, NULL );
}

HB_FUNC( INITWINDOW )
{
   HWND hwnd;
   int  Style = WS_POPUP, ExStyle;

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

   if( hb_parl( 17 ) )
      ExStyle = ExStyle | WS_EX_PALETTEWINDOW;

   if( hb_parl( 18 ) ) // Panel
   {
      Style   = WS_CHILD;
      ExStyle = ExStyle | WS_EX_CONTROLPARENT | WS_EX_STATICEDGE;
   }

   hwnd = CreateWindowEx
          (
      ExStyle,
      hb_parc( 12 ),
      hb_parc( 1 ),
      Style,
      hb_parni( 2 ),
      hb_parni( 3 ),
      hb_parni( 4 ),
      hb_parni( 5 ),
      ( HWND ) HB_PARNL( 13 ),
      ( HMENU ) NULL,
      g_hInstance,
      NULL
          );

   if( hwnd == NULL )
   {
      MessageBox( 0, "Window Creation Failed!", "Error!", MB_ICONEXCLAMATION | MB_OK | MB_SYSTEMMODAL );
      return;
   }

   HB_RETNL( ( LONG_PTR ) hwnd );
}

HB_FUNC( INITMODALWINDOW )
{
   HWND parent;
   HWND hwnd;
   int  Style;
   int  ExStyle = 0;

   if( hb_parl( 13 ) )
      ExStyle = WS_EX_CONTEXTHELP;

   parent = ( HWND ) HB_PARNL( 6 );

   Style = WS_POPUP;

   if( ! hb_parl( 7 ) )
      Style = Style | WS_SIZEBOX;

   if( ! hb_parl( 8 ) )
      Style = Style | WS_SYSMENU;

   if( ! hb_parl( 9 ) )
      Style = Style | WS_CAPTION;

   if( hb_parl( 11 ) )
      Style = Style | WS_VSCROLL;

   if( hb_parl( 12 ) )
      Style = Style | WS_HSCROLL;

   hwnd = CreateWindowEx
          (
      ExStyle,
      hb_parc( 10 ),
      hb_parc( 1 ),
      Style,
      hb_parni( 2 ),
      hb_parni( 3 ),
      hb_parni( 4 ),
      hb_parni( 5 ),
      parent,
      ( HMENU ) NULL,
      g_hInstance,
      NULL
          );

   if( hwnd == NULL )
   {
      MessageBox( 0, "Window Creation Failed!", "Error!", MB_ICONEXCLAMATION | MB_OK | MB_SYSTEMMODAL );
      return;
   }

   HB_RETNL( ( LONG_PTR ) hwnd );
}

HB_FUNC( INITSPLITBOX )
{
   HWND      hwndOwner = ( HWND ) HB_PARNL( 1 );
   REBARINFO rbi;
   HWND      hwndRB;
   INITCOMMONCONTROLSEX icex;

   int Style = WS_CHILD | WS_VISIBLE | WS_CLIPSIBLINGS | WS_CLIPCHILDREN | RBS_BANDBORDERS | RBS_VARHEIGHT | RBS_FIXEDORDER;

   if( hb_parl( 2 ) )
      Style = Style | CCS_BOTTOM;

   if( hb_parl( 3 ) )
      Style = Style | CCS_VERT;

   icex.dwSize = sizeof( INITCOMMONCONTROLSEX );
   icex.dwICC  = ICC_COOL_CLASSES | ICC_BAR_CLASSES;
   InitCommonControlsEx( &icex );

   hwndRB = CreateWindowEx
            (
      WS_EX_TOOLWINDOW | WS_EX_DLGMODALFRAME,
      REBARCLASSNAME,
      NULL,
      Style,
      0,
      0,
      0,
      0,
      hwndOwner,
      NULL,
      g_hInstance,
      NULL
            );

   // Initialize and send the REBARINFO structure.
   rbi.cbSize = sizeof( REBARINFO );   // Required when using this struct.
   rbi.fMask  = 0;
   rbi.himl   = ( HIMAGELIST ) NULL;
   SendMessage( hwndRB, RB_SETBARINFO, 0, ( LPARAM ) &rbi );

   HB_RETNL( ( LONG_PTR ) hwndRB );
}

HB_FUNC( INITSPLITCHILDWINDOW )
{
   HWND hwnd;
   int  Style;

   Style = WS_POPUP;

   if( ! hb_parl( 4 ) )
      Style = Style | WS_CAPTION;

   if( hb_parl( 7 ) )
      Style = Style | WS_VSCROLL;

   if( hb_parl( 8 ) )
      Style = Style | WS_HSCROLL;

   hwnd = CreateWindowEx
          (
      WS_EX_STATICEDGE | WS_EX_TOOLWINDOW,
      hb_parc( 3 ),
      hb_parc( 5 ),
      Style,
      0,
      0,
      hb_parni( 1 ),
      hb_parni( 2 ),
      0,
      ( HMENU ) NULL,
      g_hInstance,
      NULL
          );

   if( hwnd == NULL )
   {
      MessageBox( 0, "Window Creation Failed!", "Error!", MB_ICONEXCLAMATION | MB_OK | MB_SYSTEMMODAL );
      return;
   }

   HB_RETNL( ( LONG_PTR ) hwnd );
}

/* Modified by P.Ch. 16.10.-16.12. */
HB_FUNC( REGISTERWINDOW )
{
   WNDCLASS WndClass;

   HBRUSH  hBrush = 0;
   HICON   hIcon;
   HCURSOR hCursor;

   LPCTSTR lpIconName   = HB_ISCHAR( 1 ) ? hb_parc( 1 ) : ( HB_ISNUM( 1 ) ? MAKEINTRESOURCE( hb_parni( 1 ) ) : NULL );
   LPCSTR  lpCursorName = HB_ISCHAR( 4 ) ? hb_parc( 4 ) : ( HB_ISNUM( 4 ) ? MAKEINTRESOURCE( hb_parni( 4 ) ) : NULL );

   WndClass.style       = CS_DBLCLKS | /*CS_HREDRAW | CS_VREDRAW |*/ CS_OWNDC;
   WndClass.lpfnWndProc = WndProc;
   WndClass.cbClsExtra  = 0;
   WndClass.cbWndExtra  = 0;
   WndClass.hInstance   = g_hInstance;

   // icon from resource
   hIcon = LoadIcon( g_hInstance, lpIconName );
   // from file
   if( NULL == hIcon && HB_ISCHAR( 1 ) )
      hIcon = ( HICON ) LoadImage( NULL, lpIconName, IMAGE_ICON, 0, 0, LR_LOADFROMFILE + LR_DEFAULTSIZE );
   WndClass.hIcon = ( ( NULL != hIcon ) ? hIcon : LoadIcon( NULL, IDI_APPLICATION ) );

   // cursor from resource
   hCursor = LoadCursor( g_hInstance, lpCursorName );
   // from file
   if( ( NULL == hCursor ) && HB_ISCHAR( 4 ) )
      hCursor = LoadCursorFromFile( lpCursorName );
   WndClass.hCursor = ( ( NULL != hCursor ) ? hCursor : LoadCursor( NULL, IDC_ARROW ) );

   if( HB_ISARRAY( 3 ) )  // old behavior (before 16.10.)
   {
      if( HB_PARNI( 3, 1 ) == -1 )
         hBrush = ( HBRUSH ) ( COLOR_BTNFACE + 1 );
      else
         hBrush = CreateSolidBrush( RGB( HB_PARNI( 3, 1 ), HB_PARNI( 3, 2 ), HB_PARNI( 3, 3 ) ) );
   }
   else if( HB_ISCHAR( 3 ) || HB_ISNUM( 3 ) )
   {
      HBITMAP hImage;
      LPCTSTR lpImageName = HB_ISCHAR( 3 ) ? hb_parc( 3 ) : ( HB_ISNUM( 3 ) ? MAKEINTRESOURCE( hb_parni( 3 ) ) : NULL );

      hImage = ( HBITMAP ) LoadImage( g_hInstance, lpImageName, IMAGE_BITMAP, 0, 0, LR_LOADMAP3DCOLORS | LR_LOADTRANSPARENT );

      if( hImage == NULL && HB_ISCHAR( 3 ) )
         hImage = ( HBITMAP ) LoadImage( NULL, lpImageName, IMAGE_BITMAP, 0, 0, LR_LOADFROMFILE | LR_LOADMAP3DCOLORS | LR_LOADTRANSPARENT );

      if( hImage == NULL )
         hImage = ( HBITMAP ) HMG_LoadImage( hb_parc( 3 ) );

      if( hImage != NULL )
         hBrush = CreatePatternBrush( hImage );
   }

   WndClass.hbrBackground = ( NULL != hBrush ) ? hBrush : ( hBrush = ( HBRUSH ) ( COLOR_BTNFACE + 1 ) );
   WndClass.lpszMenuName  = NULL;
   WndClass.lpszClassName = hb_parc( 2 );

   if( ! RegisterClass( &WndClass ) )
      hmg_ErrorExit( TEXT( "Window Registration Failed!" ), 0, TRUE );

   HB_RETNL( ( LONG_PTR ) hBrush );
}

HB_FUNC( REGISTERSPLITCHILDWINDOW )
{
   WNDCLASS WndClass;

   HBRUSH  hbrush = 0;
   LPCTSTR lpIcon = HB_ISCHAR( 1 ) ? hb_parc( 1 ) : ( HB_ISNIL( 1 ) ? NULL : MAKEINTRESOURCE( hb_parni( 1 ) ) );

   WndClass.style       = CS_OWNDC;
   WndClass.lpfnWndProc = WndProc;
   WndClass.cbClsExtra  = 0;
   WndClass.cbWndExtra  = 0;
   WndClass.hInstance   = g_hInstance;
   WndClass.hIcon       = LoadIcon( g_hInstance, lpIcon );
   if( WndClass.hIcon == NULL )
      WndClass.hIcon = ( HICON ) LoadImage( 0, lpIcon, IMAGE_ICON, 0, 0, LR_LOADFROMFILE + LR_DEFAULTSIZE );

   if( WndClass.hIcon == NULL )
      WndClass.hIcon = LoadIcon( NULL, IDI_APPLICATION );

   WndClass.hCursor = LoadCursor( NULL, IDC_ARROW );

   if( HB_PARNI( 3, 1 ) == -1 )
      WndClass.hbrBackground = ( HBRUSH ) ( COLOR_BTNFACE + 1 );
   else
   {
      hbrush = CreateSolidBrush( RGB( HB_PARNI( 3, 1 ), HB_PARNI( 3, 2 ), HB_PARNI( 3, 3 ) ) );
      WndClass.hbrBackground = hbrush;
   }

   WndClass.lpszMenuName  = NULL;
   WndClass.lpszClassName = hb_parc( 2 );

   if( ! RegisterClass( &WndClass ) )
      hmg_ErrorExit( TEXT( "Window Registration Failed!" ), 0, TRUE );

   HB_RETNL( ( LONG_PTR ) hbrush );
}

HB_FUNC( UNREGISTERWINDOW )
{
   UnregisterClass( hb_parc( 1 ), g_hInstance );
}
