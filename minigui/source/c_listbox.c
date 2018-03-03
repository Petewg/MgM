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

#include <mgdefs.h>

#include <commctrl.h>
#include <windowsx.h>

#ifndef WC_LISTBOX
#define WC_LISTBOX  "ListBox"
#endif

#define TOTAL_TABS  10

HINSTANCE GetInstance( void );

HB_FUNC( INITLISTBOX )
{
   HWND hwnd;
   HWND hbutton;
   int  Style = WS_CHILD | WS_VSCROLL | LBS_DISABLENOSCROLL | LBS_NOTIFY | LBS_NOINTEGRALHEIGHT;

   hwnd = ( HWND ) HB_PARNL( 1 );

   if( ! hb_parl( 9 ) )
      Style = Style | WS_VISIBLE;

   if( ! hb_parl( 10 ) )
      Style = Style | WS_TABSTOP;

   if( hb_parl( 11 ) )
      Style = Style | LBS_SORT;

   if( hb_parl( 13 ) )
      Style = Style | LBS_USETABSTOPS;

   if( hb_parl( 14 ) )
      Style = Style | LBS_MULTICOLUMN | WS_HSCROLL;

   hbutton = CreateWindowEx
             (
      WS_EX_CLIENTEDGE,
      WC_LISTBOX,
      "",
      Style,
      hb_parni( 3 ),
      hb_parni( 4 ),
      hb_parni( 5 ),
      hb_parni( 6 ),
      hwnd,
      ( HMENU ) HB_PARNL( 2 ),
      GetInstance(),
      NULL
             );

   if( hb_parl( 12 ) )
      MakeDragList( hbutton );

   if( hb_parl( 14 ) )
      SendMessage( hbutton, LB_SETCOLUMNWIDTH, ( WPARAM ) ( hb_parni( 5 ) - 20 ), 0 );

   HB_RETNL( ( LONG_PTR ) hbutton );
}

/* Modified by P.Ch. 16.10. */
HB_FUNC( LISTBOXGETSTRING )
{
   int    iLen = SendMessage( ( HWND ) HB_PARNL( 1 ), LB_GETTEXTLEN, ( WPARAM ) hb_parni( 2 ) - 1, ( LPARAM ) 0 );
   char * cString;

   if( iLen > 0 && NULL != ( cString = ( char * ) hb_xgrab( ( iLen + 1 ) * sizeof( TCHAR ) ) ) )
   {
      SendMessage( ( HWND ) HB_PARNL( 1 ), LB_GETTEXT, ( WPARAM ) hb_parni( 2 ) - 1, ( LPARAM ) cString );
      hb_retclen_buffer( cString, iLen );
   }
   else
   {
      hb_retc_null();
   }
}

HB_FUNC( INITMULTILISTBOX )
{
   HWND hwnd;
   HWND hbutton;
   int  Style = LBS_EXTENDEDSEL | WS_CHILD | WS_VSCROLL | LBS_DISABLENOSCROLL | LBS_NOTIFY | LBS_MULTIPLESEL | LBS_NOINTEGRALHEIGHT;

   hwnd = ( HWND ) HB_PARNL( 1 );

   if( ! hb_parl( 9 ) )
      Style = Style | WS_VISIBLE;

   if( ! hb_parl( 10 ) )
      Style = Style | WS_TABSTOP;

   if( hb_parl( 11 ) )
      Style = Style | LBS_SORT;

   if( hb_parl( 13 ) )
      Style = Style | LBS_USETABSTOPS;

   if( hb_parl( 14 ) )
      Style = Style | LBS_MULTICOLUMN;

   hbutton = CreateWindowEx
             (
      WS_EX_CLIENTEDGE,
      WC_LISTBOX,
      "",
      Style,
      hb_parni( 3 ),
      hb_parni( 4 ),
      hb_parni( 5 ),
      hb_parni( 6 ),
      hwnd,
      ( HMENU ) HB_PARNL( 2 ),
      GetInstance(),
      NULL
             );

   if( hb_parl( 12 ) )
      MakeDragList( hbutton );

   HB_RETNL( ( LONG_PTR ) hbutton );
}

HB_FUNC( LISTBOXGETMULTISEL )
{
   HWND hwnd = ( HWND ) HB_PARNL( 1 );
   int  i;
   int  buffer[ 32768 ];
   int  n;

   n = SendMessage( hwnd, LB_GETSELCOUNT, 0, 0 );

   SendMessage( hwnd, LB_GETSELITEMS, ( WPARAM ) ( n ), ( LPARAM ) buffer );

   hb_reta( n );

   for( i = 0; i < n; i++ )
      HB_STORNI( buffer[ i ] + 1, -1, i + 1 );
}

HB_FUNC( LISTBOXSETMULTISEL )
{
   PHB_ITEM wArray;

   HWND hwnd = ( HWND ) HB_PARNL( 1 );

   int i, n, l;

   wArray = hb_param( 2, HB_IT_ARRAY );

   l = hb_parinfa( 2, 0 ) - 1;

   n = SendMessage( hwnd, LB_GETCOUNT, 0, 0 );

   // CLEAR CURRENT SELECTIONS
   for( i = 0; i < n; i++ )
      SendMessage( hwnd, LB_SETSEL, ( WPARAM ) ( 0 ), ( LPARAM ) i );

   // SET NEW SELECTIONS
   for( i = 0; i <= l; i++ )
      SendMessage( hwnd, LB_SETSEL, ( WPARAM ) ( 1 ), ( LPARAM ) ( hb_arrayGetNI( wArray, i + 1 ) ) - 1 );
}

HB_FUNC( LISTBOXSETMULTITAB )
{
   PHB_ITEM wArray;
   int      nTabStops[ TOTAL_TABS ];
   int      l, i;
   DWORD    dwDlgBase = GetDialogBaseUnits();
   int      baseunitX = LOWORD( dwDlgBase );

   HWND hwnd = ( HWND ) HB_PARNL( 1 );

   wArray = hb_param( 2, HB_IT_ARRAY );

   l = hb_parinfa( 2, 0 ) - 1;

   for( i = 0; i <= l; i++ )
      nTabStops[ i ] = MulDiv( hb_arrayGetNI( wArray, i + 1 ), 4, baseunitX );

   SendMessage( hwnd, LB_SETTABSTOPS, l, ( LPARAM ) &nTabStops );
}

HB_FUNC( _GETDDLMESSAGE )
{
   UINT g_dDLMessage;

   g_dDLMessage = RegisterWindowMessage( DRAGLISTMSGSTRING );

   hb_retnl( ( LONG ) g_dDLMessage );
}

HB_FUNC( GET_DRAG_LIST_NOTIFICATION_CODE )
{
   LPARAM lParam        = ( LPARAM ) HB_PARNL( 1 );
   LPDRAGLISTINFO lpdli = ( LPDRAGLISTINFO ) lParam;

   hb_retni( lpdli->uNotification );
}

HB_FUNC( GET_DRAG_LIST_DRAGITEM )
{
   int    nDragItem;
   LPARAM lParam        = ( LPARAM ) HB_PARNL( 1 );
   LPDRAGLISTINFO lpdli = ( LPDRAGLISTINFO ) lParam;

   nDragItem = LBItemFromPt( lpdli->hWnd, lpdli->ptCursor, TRUE );

   hb_retni( nDragItem );
}

HB_FUNC( DRAG_LIST_DRAWINSERT )
{
   HWND   hwnd          = ( HWND ) HB_PARNL( 1 );
   LPARAM lParam        = ( LPARAM ) HB_PARNL( 2 );
   int    nItem         = hb_parni( 3 );
   LPDRAGLISTINFO lpdli = ( LPDRAGLISTINFO ) lParam;
   int nItemCount;

   nItemCount = SendMessage( ( HWND ) lpdli->hWnd, LB_GETCOUNT, 0, 0 );

   if( nItem < nItemCount )
      DrawInsert( hwnd, lpdli->hWnd, nItem );
   else
      DrawInsert( hwnd, lpdli->hWnd, -1 );
}

HB_FUNC( DRAG_LIST_MOVE_ITEMS )
{
   LPARAM lParam        = ( LPARAM ) HB_PARNL( 1 );
   LPDRAGLISTINFO lpdli = ( LPDRAGLISTINFO ) lParam;

   char string[ 1024 ];
   int  result;

   result = ListBox_GetText( lpdli->hWnd, hb_parni( 2 ), string );
   if( result != LB_ERR )
      result = ListBox_DeleteString( lpdli->hWnd, hb_parni( 2 ) );
   if( result != LB_ERR )
      result = ListBox_InsertString( lpdli->hWnd, hb_parni( 3 ), string );
   if( result != LB_ERR )
      result = ListBox_SetCurSel( lpdli->hWnd, hb_parni( 3 ) );

   hb_retl( result != LB_ERR ? TRUE : FALSE );
}
