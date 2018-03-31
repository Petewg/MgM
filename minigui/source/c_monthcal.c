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

   Parts of this code is contributed and used here under permission of his author:
       Copyright 2006 (C) Grigory Filatov <gfilatov@inbox.ru>
   ---------------------------------------------------------------------------*/

#define _WIN32_IE  0x0501

#include <mgdefs.h>
#include <commctrl.h>
#include "hbapiitm.h"
#include "hbvm.h"

#ifdef __cplusplus
extern "C" {
#endif
extern HFONT PrepareFont( char *, int, int, int, int, int, int, int );
#ifdef __cplusplus
}
#endif
LRESULT CALLBACK  OwnMCProc( HWND hmonthcal, UINT Msg, WPARAM wParam, LPARAM lParam );

HINSTANCE GetInstance( void );

HB_FUNC( INITMONTHCAL )
{
   HWND hwnd;
   HWND hmonthcal;
   RECT rc;
   INITCOMMONCONTROLSEX icex;
   int   Style;
   HFONT hfont;
   int   bold      = FW_NORMAL;
   int   italic    = 0;
   int   underline = 0;
   int   strikeout = 0;
   int   angle     = 0;

   icex.dwSize = sizeof( icex );
   icex.dwICC  = ICC_DATE_CLASSES;
   InitCommonControlsEx( &icex );

   hwnd = ( HWND ) HB_PARNL( 1 );

   Style = WS_BORDER | WS_CHILD;

   if( hb_parl( 9 ) )
      Style = Style | MCS_NOTODAY;

   if( hb_parl( 10 ) )
      Style = Style | MCS_NOTODAYCIRCLE;

   if( hb_parl( 11 ) )
      Style = Style | MCS_WEEKNUMBERS;

   if( ! hb_parl( 12 ) )
      Style = Style | WS_VISIBLE;

   if( ! hb_parl( 13 ) )
      Style = Style | WS_TABSTOP;

   hmonthcal = CreateWindowEx( 0, MONTHCAL_CLASS, "", Style, 0, 0, 0, 0, hwnd, ( HMENU ) HB_PARNL( 2 ), GetInstance(), NULL );

   SetProp( ( HWND ) hmonthcal, "oldmcproc", ( HWND ) GetWindowLongPtr( ( HWND ) hmonthcal, GWLP_WNDPROC ) );
   SetWindowLongPtr( hmonthcal, GWLP_WNDPROC, ( LONG_PTR ) ( WNDPROC ) OwnMCProc );

   if( hb_parl( 14 ) )
      bold = FW_BOLD;

   if( hb_parl( 15 ) )
      italic = 1;

   if( hb_parl( 16 ) )
      underline = 1;

   if( hb_parl( 17 ) )
      strikeout = 1;

   hfont = PrepareFont( ( char * ) hb_parc( 7 ), ( LPARAM ) hb_parni( 8 ), bold, italic, underline, strikeout, angle, DEFAULT_CHARSET );

   SendMessage( hmonthcal, ( UINT ) WM_SETFONT, ( WPARAM ) hfont, ( LPARAM ) 1 );

   MonthCal_GetMinReqRect( hmonthcal, &rc );

   SetWindowPos( hmonthcal, NULL, hb_parni( 3 ), hb_parni( 4 ), rc.right, rc.bottom, SWP_NOZORDER );

   hb_reta( 2 );
   HB_STORVNL( ( LONG_PTR ) hmonthcal, -1, 1 );
   HB_STORVNL( ( LONG_PTR ) hfont, -1, 2 );
}

HB_FUNC( SETMONTHCALVALUE )
{
   HWND       hwnd;
   SYSTEMTIME sysTime;

   hwnd = ( HWND ) HB_PARNL( 1 );

   sysTime.wYear      = ( WORD ) hb_parni( 2 );
   sysTime.wMonth     = ( WORD ) hb_parni( 3 );
   sysTime.wDay       = ( WORD ) hb_parni( 4 );
   sysTime.wDayOfWeek = LOWORD( SendMessage( hwnd, MCM_GETFIRSTDAYOFWEEK, 0, 0 ) );

   sysTime.wHour         = 0;
   sysTime.wMinute       = 0;
   sysTime.wSecond       = 0;
   sysTime.wMilliseconds = 0;

   MonthCal_SetCurSel( hwnd, &sysTime );
}

HB_FUNC( GETMONTHCALVALUE )
{
   SYSTEMTIME st;

   SendMessage( ( HWND ) HB_PARNL( 1 ), MCM_GETCURSEL, 0, ( LPARAM ) &st );

   switch( hb_parni( 2 ) )
   {
      case 1: hb_retni( st.wYear ); break;
      case 2: hb_retni( st.wMonth ); break;
      case 3: hb_retni( st.wDay );
   }
}

HB_FUNC( SETPOSMONTHCAL )
{
   HWND hmonthcal;
   RECT rc;

   hmonthcal = ( HWND ) HB_PARNL( 1 );
   MonthCal_GetMinReqRect( hmonthcal, &rc );

   SetWindowPos( hmonthcal, NULL, hb_parni( 2 ), hb_parni( 3 ), rc.right, rc.bottom, SWP_NOZORDER );
}

LRESULT CALLBACK OwnMCProc( HWND hwnd, UINT Msg, WPARAM wParam, LPARAM lParam )
{
   static PHB_SYMB pSymbol = NULL;
   long int        r;
   WNDPROC         OldWndProc;

   OldWndProc = ( WNDPROC ) ( LONG_PTR ) GetProp( hwnd, "oldmcproc" );

   switch( Msg )
   {
      case WM_DESTROY:
         SetWindowLongPtr( hwnd, GWLP_WNDPROC, ( LONG_PTR ) ( WNDPROC ) OldWndProc );
         RemoveProp( hwnd, "oldmcproc" );
         break;

      case WM_MOUSEACTIVATE:
      case WM_SETFOCUS:
      case WM_KILLFOCUS:
         if( ! pSymbol )
            pSymbol = hb_dynsymSymbol( hb_dynsymGet( "OMONTHCALEVENTS" ) );

         if( pSymbol )
         {
            hb_vmPushSymbol( pSymbol );
            hb_vmPushNil();
            hb_vmPushNumInt( ( LONG_PTR ) hwnd );
            hb_vmPushLong( Msg );
            hb_vmPushNumInt( wParam );
            hb_vmPushNumInt( lParam );
            hb_vmDo( 4 );
         }

         r = hb_parnl( -1 );

         if( r != 0 )
            return r;
         else
            return CallWindowProc( OldWndProc, hwnd, Msg, wParam, lParam );
   }

   return CallWindowProc( OldWndProc, hwnd, Msg, wParam, lParam );
}
