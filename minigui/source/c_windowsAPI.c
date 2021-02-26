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
    www - http://harbour-project.org

    "Harbour Project"
    Copyright 1999-2017, http://harbour-project.org/

    "WHAT32"
    Copyright 2002 AJ Wos <andrwos@aust1.net>

    "HWGUI"
    Copyright 2001-2015 Alexander S.Kresin <alex@belacy.ru>

   ---------------------------------------------------------------------------*/

#define _WIN32_IE      0x0501

#include <mgdefs.h>
#if ( defined ( __MINGW32__ ) || defined ( __XCC__ ) ) && ( _WIN32_WINNT < 0x0500 )
# define _WIN32_WINNT  0x0500
#endif

#include <commctrl.h>
#include <richedit.h>
#include <shellapi.h>

#include "hbapiitm.h"
#include "hbapierr.h"
#include "hbvm.h"

#define WM_TASKBAR  WM_USER + 1043

// extern functions
HINSTANCE      GetResources( void );
extern void    hmg_ErrorExit( LPCTSTR lpMessage, DWORD dwError, BOOL bExit );
extern HBITMAP HMG_LoadImage( const char * FileName );
// local variables
HRGN           BitmapToRegion( HBITMAP hBmp, COLORREF cTransparentColor, COLORREF cTolerance );
// global variables
HWND   g_hWndMain = NULL;
HACCEL g_hAccel   = NULL;
// static variables
static HWND hDlgModeless = NULL;

BOOL SetAcceleratorTable( HWND hWnd, HACCEL hHaccel )
{
   g_hWndMain = hWnd;
   g_hAccel   = hHaccel;

   return TRUE;
}

HB_FUNC( DOMESSAGELOOP )
{
   MSG Msg;
   int status;

   while( ( status = GetMessage( &Msg, NULL, 0, 0 ) ) != 0 )
   {
      if( status == -1 )  // Exception
      {
         // handle the error and possibly exit
         hmg_ErrorExit( TEXT( "DOMESSAGELOOP" ), 0, TRUE );
      }
      else
      {
         hDlgModeless = GetActiveWindow();

         if( hDlgModeless == ( HWND ) NULL || ! TranslateAccelerator( g_hWndMain, g_hAccel, &Msg ) )
         {
            if( ! IsDialogMessage( hDlgModeless, &Msg ) )
            {
               TranslateMessage( &Msg );
               DispatchMessage( &Msg );
            }
         }
      }
   }
}

/*
 * DoEvents is a statement that yields execution of the current
 * thread so that the operating system can process other events.
 * This function cleans out the message loop and executes any other pending
 * business.
 */
HB_FUNC( DOEVENTS )
{
   MSG Msg;

   while( PeekMessage( ( LPMSG ) &Msg, 0, 0, 0, PM_REMOVE ) )
   {
      hDlgModeless = GetActiveWindow();

      if( hDlgModeless == NULL || ! IsDialogMessage( hDlgModeless, &Msg ) )
      {
         TranslateMessage( &Msg );
         DispatchMessage( &Msg );
      }
   }
}

HB_FUNC( EXITPROCESS )
{
   ExitProcess( HB_ISNUM( 1 ) ? hb_parni( 1 ) : 0 );
}

HB_FUNC( SHOWWINDOW )
{
   ShowWindow( ( HWND ) HB_PARNL( 1 ), HB_ISNUM( 2 ) ? hb_parni( 2 ) : SW_SHOW );
}

HB_FUNC( GETACTIVEWINDOW )
{
   HWND hwnd;

   hwnd = GetActiveWindow();

   HB_RETNL( ( LONG_PTR ) hwnd );
}

HB_FUNC( SETACTIVEWINDOW )
{
   SetActiveWindow( ( HWND ) HB_PARNL( 1 ) );
}

HB_FUNC( POSTQUITMESSAGE )
{
   PostQuitMessage( hb_parni( 1 ) );
}

HB_FUNC( DESTROYWINDOW )
{
   DestroyWindow( ( HWND ) HB_PARNL( 1 ) );
}

HB_FUNC( ISWINDOWVISIBLE )
{
   hb_retl( IsWindowVisible( ( HWND ) HB_PARNL( 1 ) ) );
}

HB_FUNC( ISWINDOWENABLED )
{
   hb_retl( IsWindowEnabled( ( HWND ) HB_PARNL( 1 ) ) );
}

HB_FUNC( ENABLEWINDOW )
{
   EnableWindow( ( HWND ) HB_PARNL( 1 ), TRUE );
}

HB_FUNC( DISABLEWINDOW )
{
   EnableWindow( ( HWND ) HB_PARNL( 1 ), FALSE );
}

HB_FUNC( SETFOREGROUNDWINDOW )
{
   SetForegroundWindow( ( HWND ) HB_PARNL( 1 ) );
}

HB_FUNC( BRINGWINDOWTOTOP )
{
   BringWindowToTop( ( HWND ) HB_PARNL( 1 ) );
}

HB_FUNC( GETFOREGROUNDWINDOW )
{
   HWND hwnd;

   hwnd = GetForegroundWindow();
   HB_RETNL( ( LONG_PTR ) hwnd );
}

HB_FUNC( SETWINDOWTEXT )
{
   SetWindowText( ( HWND ) HB_PARNL( 1 ), ( LPCTSTR ) hb_parc( 2 ) );
}

HB_FUNC( SETWINDOWTEXTW )
{
   SetWindowTextW( ( HWND ) HB_PARNL( 1 ), ( LPCWSTR ) hb_parc( 2 ) );
}

HB_FUNC( SETWINDOWBACKGROUND )
{
   SetClassLongPtr( ( HWND ) HB_PARNL( 1 ),       // window handle
                    GCLP_HBRBACKGROUND,           // change back color
                    ( LONG_PTR ) HB_PARNL( 2 ) ); // new brush handle
}

HB_FUNC( SETWINDOWPOS )
{
   hb_retl( ( BOOL ) SetWindowPos( ( HWND ) HB_PARNL( 1 ), ( HWND ) HB_PARNL( 2 ), hb_parni( 3 ), hb_parni( 4 ), hb_parni( 5 ), hb_parni( 6 ), hb_parni( 7 ) ) );
}

HB_FUNC( ANIMATEWINDOW )
{
   HWND  hWnd    = ( HWND ) HB_PARNL( 1 );
   DWORD dwTime  = ( DWORD ) hb_parnl( 2 );
   DWORD dwFlags = ( DWORD ) hb_parnl( 3 );

   hb_retl( ( BOOL ) AnimateWindow( hWnd, dwTime, dwFlags ) );
}

HB_FUNC( FLASHWINDOWEX )
{
   FLASHWINFO FlashWinInfo;

   FlashWinInfo.cbSize    = sizeof( FLASHWINFO );
   FlashWinInfo.hwnd      = ( HWND ) HB_PARNL( 1 );
   FlashWinInfo.dwFlags   = ( DWORD ) hb_parnl( 2 );
   FlashWinInfo.uCount    = ( UINT ) hb_parnl( 3 );
   FlashWinInfo.dwTimeout = ( DWORD ) hb_parnl( 4 );

   hb_retl( ( BOOL ) FlashWindowEx( &FlashWinInfo ) );
}

HB_FUNC( SETLAYEREDWINDOWATTRIBUTES )
{
   HWND hWnd = ( HWND ) HB_PARNL( 1 );

   if( IsWindow( hWnd ) )
   {
      HMODULE hDll = GetModuleHandle( TEXT( "user32.dll" ) );

      hb_retl( HB_FALSE );

      if( NULL != hDll )
      {
         typedef BOOL ( __stdcall * SetLayeredWindowAttributes_ptr )( HWND, COLORREF, BYTE, DWORD );

         SetLayeredWindowAttributes_ptr fn_SetLayeredWindowAttributes =
            ( SetLayeredWindowAttributes_ptr ) GetProcAddress( hDll, "SetLayeredWindowAttributes" );

         if( NULL != fn_SetLayeredWindowAttributes )
         {
            COLORREF crKey   = ( COLORREF ) hb_parnl( 2 );
            BYTE     bAlpha  = ( BYTE ) hb_parni( 3 );
            DWORD    dwFlags = ( DWORD ) hb_parnl( 4 );

            if( ! ( GetWindowLongPtr( hWnd, GWL_EXSTYLE ) & WS_EX_LAYERED ) )
               SetWindowLongPtr( hWnd, GWL_EXSTYLE, GetWindowLongPtr( hWnd, GWL_EXSTYLE ) | WS_EX_LAYERED );

            hb_retl( fn_SetLayeredWindowAttributes( hWnd, crKey, bAlpha, dwFlags ) ? HB_TRUE : HB_FALSE );
         }
      }
   }
   else
      hb_errRT_BASE_SubstR( EG_ARG, 3012, "MiniGUI Error", HB_ERR_FUNCNAME, HB_ERR_ARGS_BASEPARAMS );
}

static BOOL CenterIntoParent( HWND hwnd )
{
   HWND hwndParent;
   RECT rect, rectP;
   int  width, height;
   int  screenwidth, screenheight;
   int  x, y;

   // make the window relative to its parent
   hwndParent = GetParent( hwnd );

   GetWindowRect( hwnd, &rect );
   GetWindowRect( hwndParent, &rectP );

   width  = rect.right - rect.left;
   height = rect.bottom - rect.top;

   x = ( ( rectP.right - rectP.left ) - width ) / 2 + rectP.left;
   y = ( ( rectP.bottom - rectP.top ) - height ) / 2 + rectP.top;

   screenwidth  = GetSystemMetrics( SM_CXSCREEN );
   screenheight = GetSystemMetrics( SM_CYSCREEN );

   // make sure that the child window never moves outside of the screen
   if( x < 0 )
      x = 0;
   if( y < 0 )
      y = 0;
   if( x + width > screenwidth )
      x = screenwidth - width;
   if( y + height > screenheight )
      y = screenheight - height;

   MoveWindow( hwnd, x, y, width, height, FALSE );

   return TRUE;
}

HB_FUNC( C_CENTER )
{
   HWND hwnd;
   RECT rect;
   int  w, h, x, y;

   hwnd = ( HWND ) HB_PARNL( 1 );

   if( hb_parl( 2 ) )
      CenterIntoParent( hwnd );
   else
   {
      GetWindowRect( hwnd, &rect );
      w = rect.right - rect.left;
      h = rect.bottom - rect.top;
      x = GetSystemMetrics( SM_CXSCREEN );
      SystemParametersInfo( SPI_GETWORKAREA, 1, &rect, 0 );
      y = rect.bottom - rect.top;

      SetWindowPos( hwnd, HWND_TOP, ( x - w ) / 2, ( y - h ) / 2, 0, 0, SWP_NOSIZE | SWP_NOACTIVATE );
   }
}

HB_FUNC( GETWINDOWTEXT )
{
   HWND   hWnd   = ( HWND ) HB_PARNL( 1 );
   int    iLen   = GetWindowTextLength( hWnd );
   LPTSTR szText = ( TCHAR * ) hb_xgrab( ( iLen + 1 ) * sizeof( TCHAR ) );

   iLen = GetWindowText( hWnd, szText, iLen + 1 );

   hb_retclen( szText, iLen );
   hb_xfree( szText );
}

HB_FUNC( SENDMESSAGE )
{
   HWND hwnd = ( HWND ) HB_PARNL( 1 );

   if( IsWindow( hwnd ) )
      HB_RETNL( ( LONG_PTR ) SendMessage( hwnd, ( UINT ) hb_parni( 2 ), ( WPARAM ) hb_parnl( 3 ), ( LPARAM ) hb_parnl( 4 ) ) );
   else
      hb_errRT_BASE_SubstR( EG_ARG, 5001, "MiniGUI Error", HB_ERR_FUNCNAME, HB_ERR_ARGS_BASEPARAMS );
}

HB_FUNC( SENDMESSAGESTRING )
{
   HB_RETNL( ( LONG_PTR ) SendMessage( ( HWND ) HB_PARNL( 1 ), ( UINT ) hb_parni( 2 ), ( WPARAM ) hb_parnl( 3 ), ( LPARAM ) ( LPSTR ) hb_parc( 4 ) ) );
}

HB_FUNC( GETNOTIFYCODE )
{
   LPARAM  lParam = ( LPARAM ) HB_PARNL( 1 );
   NMHDR * nmhdr  = ( NMHDR * ) lParam;

   hb_retni( nmhdr->code );
}

//JP 107a
HB_FUNC( GETNOTIFYID )
{
   LPARAM  lParam = ( LPARAM ) HB_PARNL( 1 );
   NMHDR * nmhdr  = ( NMHDR * ) lParam;

   HB_RETNL( ( LONG_PTR ) nmhdr->idFrom );
}

HB_FUNC( GETHWNDFROM )
{
   LPARAM  lParam = ( LPARAM ) HB_PARNL( 1 );
   NMHDR * nmhdr  = ( NMHDR * ) lParam;

   HB_RETNL( ( LONG_PTR ) nmhdr->hwndFrom );
}

HB_FUNC( GETDRAWITEMHANDLE )
{
   HB_RETNL( ( LONG_PTR ) ( ( ( DRAWITEMSTRUCT FAR * ) HB_PARNL( 1 ) )->hwndItem ) );
}

HB_FUNC( GETFOCUS )
{
   HB_RETNL( ( LONG_PTR ) GetFocus() );
}

HB_FUNC( GETGRIDCOLUMN )
{
   hb_retnl( ( LPARAM ) ( ( ( NM_LISTVIEW * ) HB_PARNL( 1 ) )->iSubItem ) );
}

HB_FUNC( GETGRIDVKEY )
{
   hb_retnl( ( LPARAM ) ( ( ( LV_KEYDOWN * ) HB_PARNL( 1 ) )->wVKey ) );
}

HB_FUNC( MOVEWINDOW )
{
   hb_retl( MoveWindow( ( HWND ) HB_PARNL( 1 ), hb_parni( 2 ), hb_parni( 3 ), hb_parni( 4 ), hb_parni( 5 ), ( HB_ISNIL( 6 ) ? TRUE : hb_parl( 6 ) ) ) );
}

HB_FUNC( GETSYSTEMMETRICS )
{
   hb_retni( GetSystemMetrics( hb_parni( 1 ) ) );
}

HB_FUNC( GETWINDOWRECT )
{
   RECT rect;

   GetWindowRect( ( HWND ) HB_PARNL( 1 ), &rect );

   if( HB_ISNUM( 2 ) )
   {
      switch( hb_parni( 2 ) )
      {
         case 1: hb_retni( ( INT ) rect.top ); break;
         case 2: hb_retni( ( INT ) rect.left ); break;
         case 3: hb_retni( ( INT ) rect.right - rect.left ); break;
         case 4: hb_retni( ( INT ) rect.bottom - rect.top );
      }
   }
   else if( HB_ISARRAY( 2 ) )
   {
      HB_STORVNL( rect.left, 2, 1 );
      HB_STORVNL( rect.top, 2, 2 );
      HB_STORVNL( rect.right, 2, 3 );
      HB_STORVNL( rect.bottom, 2, 4 );
   }
}

HB_FUNC( GETCLIENTRECT )
{
   RECT rect;

   hb_retl( GetClientRect( ( HWND ) HB_PARNL( 1 ), &rect ) );
   HB_STORVNL( rect.left, 2, 1 );
   HB_STORVNL( rect.top, 2, 2 );
   HB_STORVNL( rect.right, 2, 3 );
   HB_STORVNL( rect.bottom, 2, 4 );
}

HB_FUNC ( GETDESKTOPAREA ) 
{
   RECT rect;

   SystemParametersInfo( SPI_GETWORKAREA, 1, &rect, 0 );

   hb_reta( 4 );
   HB_STORNI( ( INT ) rect.left, -1, 1 );
   HB_STORNI( ( INT ) rect.top, -1, 2 );
   HB_STORNI( ( INT ) rect.right, -1, 3 );
   HB_STORNI( ( INT ) rect.bottom, -1, 4 );
}

HB_FUNC( GETTASKBARHEIGHT )
{
   RECT rect;

   GetWindowRect( FindWindow( "Shell_TrayWnd", NULL ), &rect );
   hb_retni( ( INT ) rect.bottom - rect.top );
}

static BOOL ShowNotifyIcon( HWND hWnd, BOOL bAdd, HICON hIcon, LPSTR szText )
{
   NOTIFYICONDATA nid;

   ZeroMemory( &nid, sizeof( nid ) );

   nid.cbSize = sizeof( NOTIFYICONDATA );
   nid.hIcon  = hIcon;
   nid.hWnd   = hWnd;
   nid.uID    = 0;
   nid.uFlags = NIF_ICON | NIF_MESSAGE | NIF_TIP;
   nid.uCallbackMessage = WM_TASKBAR;
   lstrcpy( nid.szTip, TEXT( szText ) );

   return Shell_NotifyIcon( bAdd ? NIM_ADD : NIM_DELETE, &nid );
}

HB_FUNC( SHOWNOTIFYICON )
{
   hb_retl( ( BOOL ) ShowNotifyIcon( ( HWND ) HB_PARNL( 1 ), ( BOOL ) hb_parl( 2 ), ( HICON ) HB_PARNL( 3 ), ( LPSTR ) hb_parc( 4 ) ) );
}

HB_FUNC( GETCURSORPOS )
{
   POINT pt;

   GetCursorPos( &pt );
   if( hb_pcount() == 1 )
      ScreenToClient( ( HWND ) HB_PARNL( 1 ), &pt );

   hb_reta( 2 );
   if( hb_pcount() == 0 )
   {
      HB_STORNI( pt.y, -1, 1 );
      HB_STORNI( pt.x, -1, 2 );
   }
   else
   {
      HB_STORNI( pt.x, -1, 1 );
      HB_STORNI( pt.y, -1, 2 );
   }
}

HB_FUNC( SCREENTOCLIENT )
{
   LONG  x = ( LONG ) hb_parnl( 2 );
   LONG  y = ( LONG ) hb_parnl( 3 );
   POINT pt;

   pt.x = x;
   pt.y = y;

   ScreenToClient( ( HWND ) HB_PARNL( 1 ), &pt );

   hb_reta( 2 );
   HB_STORNI( pt.x, -1, 1 );
   HB_STORNI( pt.y, -1, 2 );
}

HB_FUNC( LOADTRAYICON )
{
   HICON     himage;
   HINSTANCE hInstance  = ( HINSTANCE ) HB_PARNL( 1 );                                      // handle to application instance
   LPCTSTR   lpIconName = HB_ISCHAR( 2 ) ? hb_parc( 2 ) : MAKEINTRESOURCE( hb_parni( 2 ) ); // name string or resource identifier
   int       cxDesired  = HB_ISNUM( 3 ) ? hb_parni( 3 ) : GetSystemMetrics( SM_CXSMICON );
   int       cyDesired  = HB_ISNUM( 4 ) ? hb_parni( 4 ) : GetSystemMetrics( SM_CYSMICON );

   himage = ( HICON ) LoadImage( hInstance, lpIconName, IMAGE_ICON, cxDesired, cyDesired, LR_DEFAULTCOLOR );

   if( himage == NULL )
      himage = ( HICON ) LoadImage( hInstance, lpIconName, IMAGE_ICON, cxDesired, cyDesired, LR_LOADFROMFILE | LR_DEFAULTCOLOR );

   HB_RETNL( ( LONG_PTR ) himage );
}

static BOOL ChangeNotifyIcon( HWND hWnd, HICON hIcon, LPSTR szText )
{
   NOTIFYICONDATA nid;

   ZeroMemory( &nid, sizeof( nid ) );

   nid.cbSize = sizeof( NOTIFYICONDATA );
   nid.hIcon  = hIcon;
   nid.hWnd   = hWnd;
   nid.uID    = 0;
   nid.uFlags = NIF_ICON | NIF_TIP;
   lstrcpy( nid.szTip, TEXT( szText ) );

   return Shell_NotifyIcon( NIM_MODIFY, &nid );
}

HB_FUNC( CHANGENOTIFYICON )
{
   hb_retl( ( BOOL ) ChangeNotifyIcon( ( HWND ) HB_PARNL( 1 ), ( HICON ) HB_PARNL( 2 ), ( LPSTR ) hb_parc( 3 ) ) );
}

HB_FUNC( GETITEMPOS )
{
   HB_RETNL( ( LONG_PTR ) ( ( ( NMMOUSE FAR * ) HB_PARNL( 1 ) )->dwItemSpec ) );
}

HB_FUNC( SETSCROLLRANGE )
{
   hb_retl( SetScrollRange( ( HWND ) HB_PARNL( 1 ), hb_parni( 2 ), hb_parni( 3 ), hb_parni( 4 ), hb_parl( 5 ) ) );
}

HB_FUNC( GETSCROLLPOS )
{
   hb_retni( GetScrollPos( ( HWND ) HB_PARNL( 1 ), hb_parni( 2 ) ) );
}

HB_FUNC( GETWINDOWSTATE )
{
   WINDOWPLACEMENT wp;

   wp.length = sizeof( WINDOWPLACEMENT );

   GetWindowPlacement( ( HWND ) HB_PARNL( 1 ), &wp );

   hb_retni( wp.showCmd );
}

HB_FUNC( REDRAWWINDOWCONTROLRECT )
{
   RECT r;

   r.top    = hb_parni( 2 );
   r.left   = hb_parni( 3 );
   r.bottom = hb_parni( 4 );
   r.right  = hb_parni( 5 );

   RedrawWindow( ( HWND ) HB_PARNL( 1 ), &r, NULL, RDW_ERASE | RDW_INVALIDATE | RDW_ALLCHILDREN | RDW_ERASENOW | RDW_UPDATENOW );
}

HB_FUNC( ADDSPLITBOXITEM )
{
   REBARBANDINFO rbBand;
   RECT          rc;
   int Style = RBBS_CHILDEDGE | RBBS_GRIPPERALWAYS | RBBS_USECHEVRON;

   if( hb_parl( 4 ) )
      Style = Style | RBBS_BREAK;

   GetWindowRect( ( HWND ) HB_PARNL( 1 ), &rc );

   rbBand.cbSize  = sizeof( REBARBANDINFO );
   rbBand.fMask   = RBBIM_TEXT | RBBIM_STYLE | RBBIM_CHILD | RBBIM_CHILDSIZE | RBBIM_SIZE;
   rbBand.fStyle  = Style;
   rbBand.hbmBack = 0;

   rbBand.lpText    = ( LPSTR ) hb_parc( 5 );
   rbBand.hwndChild = ( HWND ) HB_PARNL( 1 );

   if( hb_parni( 9 ) )
      rbBand.fMask = rbBand.fMask | RBBIM_IDEALSIZE;

   if( ! hb_parl( 8 ) )
   {
      // Not Horizontal
      rbBand.cxMinChild = hb_parni( 6 ) ? hb_parni( 6 ) : 0;
      rbBand.cyMinChild = hb_parni( 7 ) ? hb_parni( 7 ) : rc.bottom - rc.top;
      rbBand.cx         = hb_parni( 3 );
      if( hb_parni( 9 ) )
      {
         rbBand.cxIdeal    = hb_parni( 6 ) ? hb_parni( 6 ) : 0;
         rbBand.cxMinChild = hb_parni( 9 );
      }
      else
         rbBand.cxMinChild = hb_parni( 6 ) ? hb_parni( 6 ) : 0;
   }
   else
   {
      // Horizontal
      if( hb_parni( 6 ) == 0 && hb_parni( 7 ) == 0 )
      {
         // Not ToolBar
         rbBand.cxMinChild = 0;
         rbBand.cyMinChild = rc.right - rc.left;
         rbBand.cx         = rc.bottom - rc.top;
      }
      else
      {
         // ToolBar
         rbBand.cyMinChild = hb_parni( 6 ) ? hb_parni( 6 ) : 0;
         rbBand.cx         = hb_parni( 7 ) ? hb_parni( 7 ) : rc.bottom - rc.top;
         if( hb_parni( 9 ) )
         {
            rbBand.cxIdeal    = hb_parni( 7 ) ? hb_parni( 7 ) : rc.bottom - rc.top;
            rbBand.cxMinChild = hb_parni( 9 );
         }
         else
            rbBand.cxMinChild = hb_parni( 7 ) ? hb_parni( 7 ) : rc.bottom - rc.top;
      }
   }

   SendMessage( ( HWND ) HB_PARNL( 2 ), RB_INSERTBAND, ( WPARAM ) -1, ( LPARAM ) &rbBand );
}

HB_FUNC( C_SETWINDOWRGN )
{
   HRGN    hrgn = NULL;
   HBITMAP hbmp;

   if( hb_parni( 6 ) == 0 )
      SetWindowRgn( GetActiveWindow(), NULL, TRUE );
   else
   {
      switch( hb_parni( 6 ) )
      {
         case 1:
            hrgn = CreateRectRgn( hb_parni( 2 ), hb_parni( 3 ), hb_parni( 4 ), hb_parni( 5 ) );
            break;

         case 2:
            hrgn = CreateEllipticRgn( hb_parni( 2 ), hb_parni( 3 ), hb_parni( 4 ), hb_parni( 5 ) );
            break;

         case 3:
            hrgn = CreateRoundRectRgn( 0, 0, hb_parni( 4 ), hb_parni( 5 ), hb_parni( 2 ), hb_parni( 3 ) );
            break;

         case 4:
            hbmp = ( HBITMAP ) LoadImage( GetResources(), hb_parc( 2 ), IMAGE_BITMAP, 0, 0, LR_CREATEDIBSECTION );
            if( hbmp == NULL )
               hbmp = ( HBITMAP ) LoadImage( NULL, hb_parc( 2 ), IMAGE_BITMAP, 0, 0, LR_LOADFROMFILE | LR_CREATEDIBSECTION );

            hrgn = BitmapToRegion( hbmp, ( COLORREF ) RGB( ( int ) HB_PARNI( 3, 1 ), ( int ) HB_PARNI( 3, 2 ), ( int ) HB_PARNI( 3, 3 ) ), 0x101010 );
            DeleteObject( hbmp );
            break;

         default:
            break;
      }

      SetWindowRgn( ( HWND ) HB_PARNL( 1 ), hrgn, TRUE );
      HB_RETNL( ( LONG_PTR ) hrgn );
   }
}

HB_FUNC( C_SETPOLYWINDOWRGN )
{
   HRGN  hrgn;
   POINT lppt[ 512 ];
   int   i, fnPolyFillMode;
   int   cPoints = hb_parinfa( 2, 0 );

   if( hb_parni( 4 ) == 1 )
      fnPolyFillMode = WINDING;
   else
      fnPolyFillMode = ALTERNATE;

   for( i = 0; i <= cPoints - 1; i++ )
   {
      lppt[ i ].x = HB_PARNI( 2, i + 1 );
      lppt[ i ].y = HB_PARNI( 3, i + 1 );
   }

   hrgn = CreatePolygonRgn( lppt, cPoints, fnPolyFillMode );
   SetWindowRgn( GetActiveWindow(), hrgn, TRUE );
   HB_RETNL( ( LONG_PTR ) hrgn );
}

HB_FUNC( GETHELPDATA )
{
   HB_RETNL( ( LONG_PTR ) ( ( ( HELPINFO FAR * ) HB_PARNL( 1 ) )->hItemHandle ) );
}

HB_FUNC( GETMSKTEXTMESSAGE )
{
   HB_RETNL( ( LONG_PTR ) ( ( ( MSGFILTER FAR * ) HB_PARNL( 1 ) )->msg ) );
}

HB_FUNC( GETMSKTEXTWPARAM )
{
   HB_RETNL( ( LONG_PTR ) ( ( ( MSGFILTER FAR * ) HB_PARNL( 1 ) )->wParam ) );
}

HB_FUNC( GETMSKTEXTLPARAM )
{
   HB_RETNL( ( LONG_PTR ) ( ( ( MSGFILTER FAR * ) HB_PARNL( 1 ) )->lParam ) );
}

HB_FUNC( GETWINDOW )
{
   HB_RETNL( ( LONG_PTR ) GetWindow( ( HWND ) HB_PARNL( 1 ), hb_parni( 2 ) ) );
}

HB_FUNC( GETGRIDOLDSTATE )
{
   LPARAM        lParam = ( LPARAM ) HB_PARNL( 1 );
   NM_LISTVIEW * NMLV   = ( NM_LISTVIEW * ) lParam;

   hb_retni( NMLV->uOldState );
}

HB_FUNC( GETGRIDNEWSTATE )
{
   LPARAM        lParam = ( LPARAM ) HB_PARNL( 1 );
   NM_LISTVIEW * NMLV   = ( NM_LISTVIEW * ) lParam;

   hb_retni( NMLV->uNewState );
}

HB_FUNC( GETGRIDDISPINFOINDEX )
{
   LPARAM        lParam    = ( LPARAM ) HB_PARNL( 1 );
   LV_DISPINFO * pDispInfo = ( LV_DISPINFO * ) lParam;

   int iItem    = pDispInfo->item.iItem;
   int iSubItem = pDispInfo->item.iSubItem;

   hb_reta( 2 );
   HB_STORNI( iItem + 1, -1, 1 );
   HB_STORNI( iSubItem + 1, -1, 2 );
}

HB_FUNC( SETGRIDQUERYDATA )
{
   LPARAM        lParam    = ( LPARAM ) HB_PARNL( 1 );
   LV_DISPINFO * pDispInfo = ( LV_DISPINFO * ) lParam;
   PHB_ITEM      pValue    = hb_itemNew( NULL );

   hb_itemCopy( pValue, hb_param( 2, HB_IT_STRING ) );
   pDispInfo->item.pszText = ( char * ) hb_itemGetCPtr( pValue );
}

HB_FUNC( SETGRIDQUERYIMAGE )
{
   LPARAM        lParam    = ( LPARAM ) HB_PARNL( 1 );
   LV_DISPINFO * pDispInfo = ( LV_DISPINFO * ) lParam;

   pDispInfo->item.iImage = hb_parni( 2 );
}

HB_FUNC( FINDWINDOWEX )
{
   HB_RETNL( ( LONG_PTR ) FindWindowEx( ( HWND ) HB_PARNL( 1 ), ( HWND ) HB_PARNL( 2 ), ( LPCSTR ) hb_parc( 3 ), ( LPCSTR ) hb_parc( 4 ) ) );
}

HB_FUNC( GETDS )
{
   LPARAM lParam = ( LPARAM ) HB_PARNL( 1 );
   LPNMLVCUSTOMDRAW lplvcd = ( LPNMLVCUSTOMDRAW ) lParam;

   if( lplvcd->nmcd.dwDrawStage == CDDS_PREPAINT )
      hb_retni( CDRF_NOTIFYITEMDRAW );
   else if( lplvcd->nmcd.dwDrawStage == CDDS_ITEMPREPAINT )
   {
      if( hb_pcount() > 1 )
      {
         if( ListView_GetNextItem( ( HWND ) HB_PARNL( 2 ), -1, LVNI_ALL | LVNI_SELECTED ) == hb_parni( 3 ) )
            ListView_SetItemState( ( HWND ) HB_PARNL( 2 ), hb_parni( 3 ), 0, LVIS_SELECTED );
      }
      hb_retni( CDRF_NOTIFYSUBITEMDRAW );
   }
   else if( lplvcd->nmcd.dwDrawStage == ( CDDS_SUBITEM | CDDS_ITEMPREPAINT ) )
      hb_retni( -1 );
   else
      hb_retni( CDRF_DODEFAULT );
}

HB_FUNC( GETRC )     // Get ListView CustomDraw Row and Column
{
   LPARAM lParam = ( LPARAM ) HB_PARNL( 1 );
   LPNMLVCUSTOMDRAW lplvcd = ( LPNMLVCUSTOMDRAW ) lParam;

   hb_reta( 2 );
   HB_STORVNL( ( LONG ) lplvcd->nmcd.dwItemSpec + 1, -1, 1 );
   HB_STORNI( ( INT ) lplvcd->iSubItem + 1, -1, 2 );
}

HB_FUNC( SETBCFC )   // Set Dynamic BackColor and ForeColor
{
   LPARAM lParam = ( LPARAM ) HB_PARNL( 1 );
   LPNMLVCUSTOMDRAW lplvcd = ( LPNMLVCUSTOMDRAW ) lParam;

   lplvcd->clrTextBk = hb_parni( 2 );
   lplvcd->clrText   = hb_parni( 3 );

   hb_retni( CDRF_NEWFONT );
}

HB_FUNC( SETBRCCD )  // Set Default BackColor and ForeColor
{
   LPARAM lParam = ( LPARAM ) HB_PARNL( 1 );
   LPNMLVCUSTOMDRAW lplvcd = ( LPNMLVCUSTOMDRAW ) lParam;

   lplvcd->clrText   = RGB( 0, 0, 0 );
   lplvcd->clrTextBk = RGB( 255, 255, 255 );

   hb_retni( CDRF_NEWFONT );
}

HB_FUNC( GETTABBEDCONTROLBRUSH )
{
   RECT   rc;
   HBRUSH hBrush;
   HDC    hDC = ( HDC ) HB_PARNL( 1 );

   SetBkMode( hDC, TRANSPARENT );
   GetWindowRect( ( HWND ) HB_PARNL( 2 ), &rc );
   MapWindowPoints( NULL, ( HWND ) HB_PARNL( 3 ), ( LPPOINT ) ( &rc ), 2 );
   SetBrushOrgEx( hDC, -rc.left, -rc.top, NULL );
   hBrush = ( HBRUSH ) HB_PARNL( 4 );

   HB_RETNL( ( LONG_PTR ) hBrush );
}

HB_FUNC( GETTABBRUSH )
{
   HBRUSH  hBrush;
   RECT    rc;
   HDC     hDC;
   HDC     hDCMem;
   HBITMAP hBmp;
   HBITMAP hOldBmp;
   HWND    hWnd = ( HWND ) HB_PARNL( 1 );

   GetWindowRect( hWnd, &rc );
   hDC    = GetDC( hWnd );
   hDCMem = CreateCompatibleDC( hDC );

   hBmp = CreateCompatibleBitmap( hDC, rc.right - rc.left, rc.bottom - rc.top );

   hOldBmp = ( HBITMAP ) SelectObject( hDCMem, hBmp );

   SendMessage( hWnd, WM_PRINTCLIENT, ( WPARAM ) hDCMem, ( LPARAM ) PRF_ERASEBKGND | PRF_CLIENT | PRF_NONCLIENT );

   hBrush = CreatePatternBrush( hBmp );

   HB_RETNL( ( LONG_PTR ) hBrush );

   SelectObject( hDCMem, hOldBmp );

   DeleteObject( hBmp );
   DeleteDC( hDCMem );
   ReleaseDC( hWnd, hDC );
}

HB_FUNC( INITMINMAXINFO )  // ( hWnd ) --> aMinMaxInfo
{
   long x, y, mx, my;

   if( GetWindowLong( ( HWND ) HB_PARNL( 1 ), GWL_STYLE ) & WS_SIZEBOX )
   {
      x = -GetSystemMetrics( SM_CXFRAME );
      y = -GetSystemMetrics( SM_CYFRAME );
   }
   else
   {
      x = -GetSystemMetrics( SM_CXBORDER );
      y = -GetSystemMetrics( SM_CYBORDER );
   }

   mx = GetSystemMetrics( SM_CXSCREEN ) - 2 * x;
   my = GetSystemMetrics( SM_CYSCREEN ) - 2 * y;

   hb_reta( 8 );
   HB_STORVNL( ( LONG ) mx, -1, 1 );
   HB_STORVNL( ( LONG ) my, -1, 2 );
   HB_STORVNL( ( LONG ) x, -1, 3 );
   HB_STORVNL( ( LONG ) y, -1, 4 );
   HB_STORVNL( ( LONG ) 0, -1, 5 );
   HB_STORVNL( ( LONG ) 0, -1, 6 );
   HB_STORVNL( ( LONG ) mx, -1, 7 );
   HB_STORVNL( ( LONG ) my, -1, 8 );
}

HB_FUNC( SETMINMAXINFO )   // ( pMinMaxInfo, aMinMaxInfo ) --> 0
{
   MINMAXINFO * pMinMaxInfo = ( MINMAXINFO * ) HB_PARNL( 1 );

   pMinMaxInfo->ptMaxSize.x      = HB_PARVNL( 2, 1 );
   pMinMaxInfo->ptMaxSize.y      = HB_PARVNL( 2, 2 );
   pMinMaxInfo->ptMaxPosition.x  = HB_PARVNL( 2, 3 );
   pMinMaxInfo->ptMaxPosition.y  = HB_PARVNL( 2, 4 );
   pMinMaxInfo->ptMinTrackSize.x = HB_PARVNL( 2, 5 );
   pMinMaxInfo->ptMinTrackSize.y = HB_PARVNL( 2, 6 );
   pMinMaxInfo->ptMaxTrackSize.x = HB_PARVNL( 2, 7 );
   pMinMaxInfo->ptMaxTrackSize.y = HB_PARVNL( 2, 8 );

   hb_retni( 0 );
}

HB_FUNC( ISWINDOWHANDLE )
{
   hb_retl( IsWindow( ( HWND ) HB_PARNL( 1 ) ) ? HB_TRUE : HB_FALSE );
}

HB_FUNC( GETWINDOWBRUSH )
{
   HB_RETNL( ( LONG_PTR ) GetClassLongPtr( ( HWND ) HB_PARNL( 1 ), GCLP_HBRBACKGROUND ) );
}

HB_FUNC( SETWINDOWBRUSH )
{
   HB_RETNL( ( LONG_PTR ) SetClassLongPtr( ( HWND ) HB_PARNL( 1 ), GCLP_HBRBACKGROUND, ( LONG_PTR ) HB_PARNL( 2 ) ) );
}

HB_FUNC( CREATEHATCHBRUSH )
{
   HB_RETNL( ( LONG_PTR ) CreateHatchBrush( hb_parnl( 1 ), ( COLORREF ) hb_parnl( 2 ) ) );
}

/* Modified by P.Ch. 16.10. */
HB_FUNC( CREATEPATTERNBRUSH )
{
   HBITMAP hImage;
   LPCTSTR lpImageName = HB_ISCHAR( 1 ) ? hb_parc( 1 ) : ( HB_ISNUM( 1 ) ? MAKEINTRESOURCE( hb_parni( 1 ) ) : NULL );

   hImage = ( HBITMAP ) LoadImage( GetResources(), lpImageName, IMAGE_BITMAP, 0, 0, LR_LOADMAP3DCOLORS | LR_LOADTRANSPARENT );

   if( hImage == NULL && HB_ISCHAR( 1 ) )
   {
      hImage = ( HBITMAP ) LoadImage( NULL, lpImageName, IMAGE_BITMAP, 0, 0, LR_LOADFROMFILE | LR_LOADMAP3DCOLORS | LR_LOADTRANSPARENT );
   }
   if( hImage == NULL )
   {
      hImage = ( HBITMAP ) HMG_LoadImage( hb_parc( 1 ) );
   }

   HB_RETNL( ( hImage != NULL ) ? ( LONG_PTR ) CreatePatternBrush( hImage ) : ( LONG_PTR ) 0 );
}

/*
   BitmapToRegion: Create a region from the "non-transparent" pixels of a bitmap
   Author        : Jean-Edouard Lachand-Robert
   (http://www.geocities.com/Paris/LeftBank/1160/resume.htm), June 1998.

   hBmp :              Source bitmap
   cTransparentColor : Color base for the "transparent" pixels
                       (default is black)
   cTolerance :        Color tolerance for the "transparent" pixels.

   A pixel is assumed to be transparent if the value of each of its 3
   components (blue, green and red) is
   greater or equal to the corresponding value in cTransparentColor and is
   lower or equal to the corresponding value in cTransparentColor + cTolerance.
 */
#define ALLOC_UNIT  100

HRGN BitmapToRegion( HBITMAP hBmp, COLORREF cTransparentColor, COLORREF cTolerance )
{
   HRGN   hRgn = NULL;
   VOID * pbits32;
   DWORD  maxRects = ALLOC_UNIT;

   if( hBmp )
   {
      // Create a memory DC inside which we will scan the bitmap content
      HDC hMemDC = CreateCompatibleDC( NULL );
      if( hMemDC )
      {
         BITMAP bm;
         BITMAPINFOHEADER RGB32BITSBITMAPINFO;
         HBITMAP          hbm32;

         // Get bitmap size
         GetObject( hBmp, sizeof( bm ), &bm );

         // Create a 32 bits depth bitmap and select it into the memory DC
         RGB32BITSBITMAPINFO.biSize          = sizeof( BITMAPINFOHEADER );
         RGB32BITSBITMAPINFO.biWidth         = bm.bmWidth;
         RGB32BITSBITMAPINFO.biHeight        = bm.bmHeight;
         RGB32BITSBITMAPINFO.biPlanes        = 1;
         RGB32BITSBITMAPINFO.biBitCount      = 32;
         RGB32BITSBITMAPINFO.biCompression   = BI_RGB;
         RGB32BITSBITMAPINFO.biSizeImage     = 0;
         RGB32BITSBITMAPINFO.biXPelsPerMeter = 0;
         RGB32BITSBITMAPINFO.biYPelsPerMeter = 0;
         RGB32BITSBITMAPINFO.biClrUsed       = 0;
         RGB32BITSBITMAPINFO.biClrImportant  = 0;

         hbm32 = CreateDIBSection( hMemDC, ( BITMAPINFO * ) &RGB32BITSBITMAPINFO, DIB_RGB_COLORS, &pbits32, NULL, 0 );
         if( hbm32 )
         {
            HBITMAP holdBmp = ( HBITMAP ) SelectObject( hMemDC, hbm32 );

            // Create a DC just to copy the bitmap into the memory DC
            HDC hDC = CreateCompatibleDC( hMemDC );
            if( hDC )
            {
               // Get how many bytes per row we have for the bitmap bits (rounded up to 32 bits)
               BITMAP    bm32;
               HANDLE    hData;
               RGNDATA * pData;
               BYTE *    p32;
               BYTE      lr, lg, lb, hr, hg, hb;
               INT       y, x;
               HRGN      h;

               GetObject( hbm32, sizeof( bm32 ), &bm32 );
               while( bm32.bmWidthBytes % 4 )
                  bm32.bmWidthBytes++;

               // Copy the bitmap into the memory DC
               holdBmp = ( HBITMAP ) SelectObject( hDC, hBmp );
               BitBlt( hMemDC, 0, 0, bm.bmWidth, bm.bmHeight, hDC, 0, 0, SRCCOPY );

               // For better performances, we will use the  ExtCreateRegion() function to create the  region.
               // This function take a RGNDATA structure on  entry.
               // We will add rectangles by amount of ALLOC_UNIT number in this structure.
               hData = GlobalAlloc( GMEM_MOVEABLE, sizeof( RGNDATAHEADER ) + ( sizeof( RECT ) * maxRects ) );

               pData = ( RGNDATA * ) GlobalLock( hData );
               pData->rdh.dwSize = sizeof( RGNDATAHEADER );
               pData->rdh.iType  = RDH_RECTANGLES;
               pData->rdh.nCount = pData->rdh.nRgnSize = 0;
               SetRect( &pData->rdh.rcBound, MAXLONG, MAXLONG, 0, 0 );

               // Keep on hand highest and lowest values for the  "transparent" pixels
               lr = GetRValue( cTransparentColor );
               lg = GetGValue( cTransparentColor );
               lb = GetBValue( cTransparentColor );
               hr = ( BYTE ) HB_MIN( 0xff, lr + GetRValue( cTolerance ) );
               hg = ( BYTE ) HB_MIN( 0xff, lg + GetGValue( cTolerance ) );
               hb = ( BYTE ) HB_MIN( 0xff, lb + GetBValue( cTolerance ) );

               // Scan each bitmap row from bottom to top (the bitmap is  inverted vertically)
               p32 = ( BYTE * ) bm32.bmBits + ( bm32.bmHeight - 1 ) * bm32.bmWidthBytes;
               for( y = 0; y < bm.bmHeight; y++ )     // Scan each bitmap pixel from left to right
               {
                  for( x = 0; x < bm.bmWidth; x++ )   // Search for a continuous range of "non transparent pixels"
                  {
                     int    x0 = x;
                     LONG * p  = ( LONG * ) p32 + x;
                     while( x < bm.bmWidth )
                     {
                        BYTE b = GetRValue( *p );
                        if( b >= lr && b <= hr )
                        {
                           b = GetGValue( *p );
                           if( b >= lg && b <= hg )
                           {
                              b = GetBValue( *p );
                              if( b >= lb && b <= hb )
                                 break;   // This pixel is "transparent"
                           }
                        }

                        p++;
                        x++;
                     }

                     if( x > x0 )         // Add the pixels (x0, y) to (x, y+1) as a new rectangle in the region
                     {
                        RECT * pr;
                        if( pData->rdh.nCount >= maxRects )
                        {
                           GlobalUnlock( hData );
                           maxRects += ALLOC_UNIT;
                           hData     = GlobalReAlloc( hData, sizeof( RGNDATAHEADER ) + ( sizeof( RECT ) * maxRects ), GMEM_MOVEABLE );
                           pData     = ( RGNDATA * ) GlobalLock( hData );
                        }

                        pr = ( RECT * ) &pData->Buffer;
                        SetRect( &pr[ pData->rdh.nCount ], x0, y, x, y + 1 );
                        if( x0 < pData->rdh.rcBound.left )
                           pData->rdh.rcBound.left = x0;

                        if( y < pData->rdh.rcBound.top )
                           pData->rdh.rcBound.top = y;

                        if( x > pData->rdh.rcBound.right )
                           pData->rdh.rcBound.right = x;

                        if( y + 1 > pData->rdh.rcBound.bottom )
                           pData->rdh.rcBound.bottom = y + 1;

                        pData->rdh.nCount++;

                        // On Windows98, ExtCreateRegion() may fail if  the number of rectangles is too
                        // large (ie: > 4000).
                        // Therefore, we have to create the region by multiple steps.
                        if( pData->rdh.nCount == 2000 )
                        {
                           h = ExtCreateRegion( NULL, sizeof( RGNDATAHEADER ) + ( sizeof( RECT ) * maxRects ), pData );
                           if( hRgn )
                           {
                              CombineRgn( hRgn, hRgn, h, RGN_OR );
                              DeleteObject( h );
                           }
                           else
                              hRgn = h;

                           pData->rdh.nCount = 0;
                           SetRect( &pData->rdh.rcBound, MAXLONG, MAXLONG, 0, 0 );
                        }
                     }
                  }

                  // Go to next row (remember, the bitmap is inverted vertically)
                  p32 -= bm32.bmWidthBytes;
               }

               // Create or extend the region with the remaining  rectangles
               h = ExtCreateRegion( NULL, sizeof( RGNDATAHEADER ) + ( sizeof( RECT ) * maxRects ), pData );
               if( hRgn )
               {
                  CombineRgn( hRgn, hRgn, h, RGN_OR );
                  DeleteObject( h );
               }
               else
                  hRgn = h;

               // Clean up
               GlobalFree( hData );
               SelectObject( hDC, holdBmp );
               DeleteDC( hDC );
            }

            DeleteObject( SelectObject( hMemDC, holdBmp ) );
         }

         DeleteDC( hMemDC );
      }
   }

   return hRgn;
}
