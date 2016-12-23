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
    Copyright 1999-2016, http://harbour-project.org/

    "WHAT32"
    Copyright 2002 AJ Wos <andrwos@aust1.net>

    "HWGUI"
    Copyright 2001-2015 Alexander S.Kresin <alex@belacy.ru>

   Parts  of  this  code  is contributed and used here under permission of his
   author: Copyright 2016 (C) P.Chornyj <myorg63@mail.ru>
 */

#include <mgdefs.h>
#include "hbapierr.h"
#include "hbapiitm.h"

extern HB_EXPORT BOOL Array2Point( PHB_ITEM aPoint, POINT * pt );
#ifndef __XHARBOUR__
HB_EXPORT PHB_ITEM Rect2Hash( RECT * rc );
BOOL CALLBACK _MonitorEnumProc0( HMONITOR hMonitor, HDC hdcMonitor, LPRECT lprcMonitor, LPARAM dwData );
//BOOL CALLBACK _MonitorEnumProc1( HMONITOR hMonitor, HDC hdcMonitor, LPRECT lprcMonitor, LPARAM dwData );
#endif
static void ClipOrCenterRectToMonitor( LPRECT prc, HMONITOR hMonitor, UINT flags );

HB_FUNC( COUNTMONITORS )
{
   hb_retni( GetSystemMetrics( SM_CMONITORS ) );
}

HB_FUNC( ISSAMEDISPLAYFORMAT )
{
   hb_retl( GetSystemMetrics( SM_SAMEDISPLAYFORMAT ) ? HB_TRUE : HB_FALSE );
}

#ifndef __XHARBOUR__
/*
   The  EnumDisplayMonitors  function  enumerates  display monitors
        (including invisible pseudo-monitors associated with the mirroring drivers)

        BOOL EnumDisplayMonitors( HDC hdc, LPCRECT lprcClip, MONITORENUMPROC lpfnEnum, LPARAM dwData )
 */
HB_FUNC( ENUMDISPLAYMONITORS )
{
   PHB_ITEM pMonitorEnum = hb_itemArrayNew( 0 );

   EnumDisplayMonitors( NULL, NULL, _MonitorEnumProc0, ( LPARAM ) pMonitorEnum );

   hb_itemReturnRelease( pMonitorEnum );
}

BOOL CALLBACK _MonitorEnumProc0( HMONITOR hMonitor, HDC hdcMonitor, LPRECT lprcMonitor, LPARAM dwData )
{
   PHB_ITEM pMonitor = hb_itemArrayNew( 2 );
   PHB_ITEM pRect    = Rect2Hash( lprcMonitor );

   HB_SYMBOL_UNUSED( hdcMonitor );

   hb_arraySetNInt( pMonitor, 1, ( LONG_PTR ) hMonitor );
   hb_itemArrayPut( pMonitor, 2, pRect );

   hb_arrayAddForward( ( PHB_ITEM ) dwData, pMonitor );

   hb_itemRelease( pMonitor );
   hb_itemRelease( pRect );

   return TRUE;
}

//	BOOL GetMonitorInfo( HMONITOR hMonitor, LPMONITORINFO lpmi )
HB_FUNC( GETMONITORINFO )
{
   MONITORINFO mi;

   mi.cbSize = sizeof( MONITORINFO );

   if( GetMonitorInfo( ( HMONITOR ) HB_PARNL( 1 ), &mi ) )
   {
      PHB_ITEM pMonInfo = hb_itemArrayNew( 3 );
      PHB_ITEM pMonitor = Rect2Hash( &mi.rcMonitor );
      PHB_ITEM pWork    = Rect2Hash( &mi.rcWork );

      hb_itemArrayPut( pMonInfo, 1, pMonitor );
      hb_itemArrayPut( pMonInfo, 2, pWork );
      hb_arraySetNInt( pMonInfo, 3, ( LONG_PTR ) mi.dwFlags );

      hb_itemReturnRelease( pMonInfo );
      hb_itemRelease( pMonitor );
      hb_itemRelease( pWork );
   }
   else
      hb_ret();
}
#endif

// HMONITOR MonitorFromPoint( POINT pt, DWORD dwFlags )
HB_FUNC( MONITORFROMPOINT )
{
   POINT pt;

   if( HB_ISARRAY( 1 ) )
   {
      if( ! Array2Point( hb_param( 1, HB_IT_ARRAY ), &pt ) )
         hb_errRT_BASE_SubstR( EG_ARG, 5000, "MiniGUI Error", HB_ERR_FUNCNAME, HB_ERR_ARGS_BASEPARAMS );
      else
         HB_RETNL( ( LONG_PTR ) MonitorFromPoint( pt, hb_parnldef( 2, MONITOR_DEFAULTTONULL ) ) );
   }
   else if( HB_ISNUM( 1 ) && HB_ISNUM( 2 ) )
   {
      pt.x = hb_parnl( 1 );
      pt.y = hb_parnl( 2 );

      HB_RETNL( ( LONG_PTR ) MonitorFromPoint( pt, hb_parnldef( 3, MONITOR_DEFAULTTONULL ) ) );
   }
   else
      hb_errRT_BASE_SubstR( EG_ARG, 5000, "MiniGUI Error", HB_ERR_FUNCNAME, HB_ERR_ARGS_BASEPARAMS );
}

// HMONITOR MonitorFromWindow( HWND  hwnd, DWORD dwFlags )
HB_FUNC( MONITORFROMWINDOW )
{
   HWND hwnd = ( HWND ) HB_PARNL( 1 );

   if( IsWindow( hwnd ) )
      HB_RETNL( ( LONG_PTR ) MonitorFromWindow( hwnd, hb_parnldef( 2, MONITOR_DEFAULTTONULL ) ) );
   else
      hb_errRT_BASE_SubstR( EG_ARG, 5001, "MiniGUI Error", HB_ERR_FUNCNAME, HB_ERR_ARGS_BASEPARAMS );
}

/*
   Based on
   https://msdn.microsoft.com/ru-ru/library/windows/desktop/dd162826(v=vs.85).aspx

   The  most common problem apps have when running on a multimonitor system is
   that  they "clip" or "pin" windows based on the SM_CXSCREEN and SM_CYSCREEN
   system  metrics.  Because of app compatibility reasons these system metrics
   return the size of the primary monitor.

   This shows how you use the multi-monitor functions to do the same thing.
 */

#define MONITOR_CENTER    0x0001       // center rect to monitor
#define MONITOR_CLIP      0x0000       // clip rect to monitor
#define MONITOR_WORKAREA  0x0002       // use monitor work area
#define MONITOR_AREA      0x0000       // use monitor entire area

HB_FUNC( WINDOWTOMONITOR )
{
   HWND hwnd = ( HWND ) HB_PARNL( 1 );

   if( IsWindow( hwnd ) )
   {
      HMONITOR hMonitor = HB_ISNUM( 2 ) ? ( HMONITOR ) HB_PARNL( 2 ) : NULL;
      UINT     flags    = 0 | ( ( UINT ) hb_parnldef( 3, ( MONITOR_CENTER | MONITOR_WORKAREA ) ) );
      RECT     rc;

      GetWindowRect( hwnd, &rc );
      ClipOrCenterRectToMonitor( &rc, hMonitor, flags );

      SetWindowPos( hwnd, NULL, rc.left, rc.top, 0, 0, SWP_NOSIZE | SWP_NOZORDER | SWP_NOACTIVATE );
   }
   else
      hb_errRT_BASE_SubstR( EG_ARG, 5001, "MiniGUI Error", HB_ERR_FUNCNAME, HB_ERR_ARGS_BASEPARAMS );
}

static void ClipOrCenterRectToMonitor( LPRECT prc, HMONITOR hMonitor, UINT flags )
{
   MONITORINFO mi;
   RECT        rc;
   int         w = prc->right - prc->left;
   int         h = prc->bottom - prc->top;

   // get the nearest monitor to the passed rect.
   if( NULL == hMonitor )
      hMonitor = MonitorFromRect( prc, MONITOR_DEFAULTTONEAREST );

   // get the work area or entire monitor rect.
   mi.cbSize = sizeof( mi );
   GetMonitorInfo( hMonitor, &mi );

   rc = ( flags & MONITOR_WORKAREA ) ? mi.rcWork : mi.rcMonitor;

   // center or clip the passed rect to the monitor rect
   if( flags & MONITOR_CENTER )
   {
      prc->left   = rc.left + ( rc.right - rc.left - w ) / 2;
      prc->top    = rc.top + ( rc.bottom - rc.top - h ) / 2;
      prc->right  = prc->left + w;
      prc->bottom = prc->top + h;
   }
   else
   {
      prc->left   = HB_MAX( rc.left, HB_MIN( rc.right - w, prc->left ) );
      prc->top    = HB_MAX( rc.top, HB_MIN( rc.bottom - h, prc->top ) );
      prc->right  = prc->left + w;
      prc->bottom = prc->top + h;
   }
}

#ifndef __XHARBOUR__
HB_EXPORT PHB_ITEM Rect2Hash( RECT * rc )
{
   PHB_ITEM phRect = hb_hashNew( NULL );
   PHB_ITEM pKey   = hb_itemPutCConst( NULL, "left" );
   PHB_ITEM pValue = hb_itemPutNL( NULL, rc->left );

   hb_hashAddNew( phRect, pKey, pValue );

   hb_itemPutCConst( pKey, "top" );
   hb_itemPutNL( pValue, rc->top );
   hb_hashAddNew( phRect, pKey, pValue );

   hb_itemPutCConst( pKey, "right" );
   hb_itemPutNL( pValue, rc->right );
   hb_hashAddNew( phRect, pKey, pValue );

   hb_itemPutCConst( pKey, "bottom" );
   hb_itemPutNL( pValue, rc->bottom );
   hb_hashAddNew( phRect, pKey, pValue );

   hb_itemRelease( pKey );
   hb_itemRelease( pValue );

   return phRect;
}
#endif
