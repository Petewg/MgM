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
    Copyright 1999-2016, http://harbour-project.org/

    "WHAT32"
    Copyright 2002 AJ Wos <andrwos@aust1.net>

    "HWGUI"
    Copyright 2001-2015 Alexander S.Kresin <alex@belacy.ru>

   Parts of this code is contributed and used here under permission of his author:
   Copyright 2005 (C) Jacek Kubica <kubica@wssk.wroc.pl>
   ---------------------------------------------------------------------------*/

#define _WIN32_IE  0x0501

#include <mgdefs.h>
#include <commctrl.h>

extern HINSTANCE g_hInstance;

HB_FUNC( INITDATEPICK )
{
   HWND hwnd;
   HWND hbutton;
   int  Style = WS_CHILD;

   INITCOMMONCONTROLSEX i;

   i.dwSize = sizeof( INITCOMMONCONTROLSEX );
   i.dwICC  = ICC_DATE_CLASSES;
   InitCommonControlsEx( &i );

   hwnd = ( HWND ) HB_PARNL( 1 );

   if( hb_parl( 9 ) )
      Style = Style | DTS_SHOWNONE;

   if( hb_parl( 10 ) )
      Style = Style | DTS_UPDOWN;

   if( hb_parl( 11 ) )
      Style = Style | DTS_RIGHTALIGN;

   if( ! hb_parl( 12 ) )
      Style = Style | WS_VISIBLE;

   if( ! hb_parl( 13 ) )
      Style = Style | WS_TABSTOP;

   hbutton = CreateWindowEx
             (
      WS_EX_CLIENTEDGE,
      DATETIMEPICK_CLASS,
      "DateTime",
      Style,
      hb_parni( 3 ),
      hb_parni( 4 ),
      hb_parni( 5 ),
      hb_parni( 6 ),
      hwnd,
      ( HMENU ) HB_PARNL( 2 ),
      g_hInstance,
      NULL
             );

   HB_RETNL( ( LONG_PTR ) hbutton );
}

HB_FUNC( INITTIMEPICK )
{
   HWND hwnd;
   HWND hbutton;
   int  Style = WS_CHILD;

   INITCOMMONCONTROLSEX i;

   i.dwSize = sizeof( INITCOMMONCONTROLSEX );
   i.dwICC  = ICC_DATE_CLASSES;
   InitCommonControlsEx( &i );

   hwnd = ( HWND ) HB_PARNL( 1 );

   if( hb_parl( 9 ) )
      Style = Style | DTS_SHOWNONE;

   Style = Style | DTS_TIMEFORMAT;
/*
   Style = Style | DTS_UPDOWN;
 */
   if( ! hb_parl( 10 ) )
      Style = Style | WS_VISIBLE;

   if( ! hb_parl( 11 ) )
      Style = Style | WS_TABSTOP;

   hbutton = CreateWindowEx
             (
      WS_EX_CLIENTEDGE,
      DATETIMEPICK_CLASS,
      "DateTime",
      Style,
      hb_parni( 3 ),
      hb_parni( 4 ),
      hb_parni( 5 ),
      hb_parni( 6 ),
      hwnd,
      ( HMENU ) HB_PARNL( 2 ),
      g_hInstance,
      NULL
             );

   HB_RETNL( ( LONG_PTR ) hbutton );
}

HB_FUNC( SETDATEPICK )
{
   HWND       hwnd;
   SYSTEMTIME sysTime;

   hwnd = ( HWND ) HB_PARNL( 1 );

   sysTime.wYear      = ( WORD ) hb_parni( 2 );
   sysTime.wMonth     = ( WORD ) hb_parni( 3 );
   sysTime.wDay       = ( WORD ) hb_parni( 4 );
   sysTime.wDayOfWeek = 0;

   sysTime.wHour         = 0;
   sysTime.wMinute       = 0;
   sysTime.wSecond       = 0;
   sysTime.wMilliseconds = 0;

   SendMessage( hwnd, DTM_SETSYSTEMTIME, GDT_VALID, ( LPARAM ) &sysTime );
}

HB_FUNC( SETTIMEPICK )
{
   HWND       hwnd;
   SYSTEMTIME sysTime;

   hwnd = ( HWND ) HB_PARNL( 1 );

   sysTime.wYear      = 2005;
   sysTime.wMonth     = 1;
   sysTime.wDay       = 1;
   sysTime.wDayOfWeek = 0;

   sysTime.wHour         = ( WORD ) hb_parni( 2 );
   sysTime.wMinute       = ( WORD ) hb_parni( 3 );
   sysTime.wSecond       = ( WORD ) hb_parni( 4 );
   sysTime.wMilliseconds = 0;

   SendMessage( hwnd, DTM_SETSYSTEMTIME, GDT_VALID, ( LPARAM ) &sysTime );
}

HB_FUNC( GETDATEPICKYEAR )
{
   SYSTEMTIME st;

   SendMessage( ( HWND ) HB_PARNL( 1 ), DTM_GETSYSTEMTIME, 0, ( LPARAM ) &st );
   hb_retni( st.wYear );
}

HB_FUNC( GETDATEPICKMONTH )
{
   SYSTEMTIME st;

   SendMessage( ( HWND ) HB_PARNL( 1 ), DTM_GETSYSTEMTIME, 0, ( LPARAM ) &st );
   hb_retni( st.wMonth );
}

HB_FUNC( GETDATEPICKDAY )
{
   SYSTEMTIME st;

   SendMessage( ( HWND ) HB_PARNL( 1 ), DTM_GETSYSTEMTIME, 0, ( LPARAM ) &st );
   hb_retni( st.wDay );
}

HB_FUNC( GETDATEPICKHOUR )
{
   SYSTEMTIME st;

   if( SendMessage( ( HWND ) HB_PARNL( 1 ), DTM_GETSYSTEMTIME, 0, ( LPARAM ) &st ) == GDT_VALID )
      hb_retni( st.wHour );
   else
      hb_retni( -1 );
}

HB_FUNC( GETDATEPICKMINUTE )
{
   SYSTEMTIME st;

   if( SendMessage( ( HWND ) HB_PARNL( 1 ), DTM_GETSYSTEMTIME, 0, ( LPARAM ) &st ) == GDT_VALID )
      hb_retni( st.wMinute );
   else
      hb_retni( -1 );
}

HB_FUNC( GETDATEPICKSECOND )
{
   SYSTEMTIME st;

   if( SendMessage( ( HWND ) HB_PARNL( 1 ), DTM_GETSYSTEMTIME, 0, ( LPARAM ) &st ) == GDT_VALID )
      hb_retni( st.wSecond );
   else
      hb_retni( -1 );
}

HB_FUNC( SETDATEPICKNULL )
{
   SendMessage( ( HWND ) HB_PARNL( 1 ), DTM_SETSYSTEMTIME, GDT_NONE, ( LPARAM ) 0 );
}

HB_FUNC( SETDATEPICKRANGE )
{
   SYSTEMTIME sysTime[ 2 ];
   char *     cDate;
   DWORD      y, m, d;
   WPARAM     wLimit = 0;

   if( HB_ISDATE( 2 ) && HB_ISDATE( 3 ) )
   {
      memset( &sysTime, 0, sizeof( sysTime ) );

      cDate = ( char * ) hb_pards( 2 );
      if( ! ( cDate[ 0 ] == ' ' ) )
      {
         y = ( DWORD ) ( ( cDate[ 0 ] - '0' ) * 1000 ) +
             ( ( cDate[ 1 ] - '0' ) * 100 ) +
             ( ( cDate[ 2 ] - '0' ) * 10 ) + ( cDate[ 3 ] - '0' );
         sysTime[ 0 ].wYear = ( WORD ) y;
         m = ( DWORD ) ( ( cDate[ 4 ] - '0' ) * 10 ) + ( cDate[ 5 ] - '0' );
         sysTime[ 0 ].wMonth = ( WORD ) m;
         d = ( DWORD ) ( ( cDate[ 6 ] - '0' ) * 10 ) + ( cDate[ 7 ] - '0' );
         sysTime[ 0 ].wDay = ( WORD ) d;
         wLimit |= GDTR_MIN;
      }

      cDate = ( char * ) hb_pards( 3 );
      if( ! ( cDate[ 0 ] == ' ' ) )
      {
         y = ( DWORD ) ( ( cDate[ 0 ] - '0' ) * 1000 ) +
             ( ( cDate[ 1 ] - '0' ) * 100 ) +
             ( ( cDate[ 2 ] - '0' ) * 10 ) + ( cDate[ 3 ] - '0' );
         sysTime[ 1 ].wYear = ( WORD ) y;
         m = ( DWORD ) ( ( cDate[ 4 ] - '0' ) * 10 ) + ( cDate[ 5 ] - '0' );
         sysTime[ 1 ].wMonth = ( WORD ) m;
         d = ( DWORD ) ( ( cDate[ 6 ] - '0' ) * 10 ) + ( cDate[ 7 ] - '0' );
         sysTime[ 1 ].wDay = ( WORD ) d;
         wLimit |= GDTR_MAX;
      }

      hb_retl( SendMessage( ( HWND ) HB_PARNL( 1 ), DTM_SETRANGE, wLimit, ( LPARAM ) &sysTime ) );
   }
}

HB_FUNC( SETDATEPICKERDATEFORMAT )
{
   hb_retl( SendMessage( ( HWND ) HB_PARNL( 1 ), DTM_SETFORMAT, 0, ( LPARAM ) ( LPCTSTR ) hb_parc( 2 ) ) );
}
