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

#include <mgdefs.h>

#include <commctrl.h>
#include <windowsx.h>

#ifndef WC_LISTBOX
#define WC_LISTBOX  "ListBox"
#endif

#define BUFFER      MAX_PATH

HINSTANCE GetInstance( void );

static int m_nHeightItem = 16;

HB_FUNC( INITCHKLISTBOX )
{
   HWND hwnd;
   HWND hbutton;
   int  Style = WS_CHILD | WS_VSCROLL | LBS_DISABLENOSCROLL | LBS_NOTIFY | LBS_NOINTEGRALHEIGHT | LBS_OWNERDRAWFIXED | LBS_HASSTRINGS | LBS_WANTKEYBOARDINPUT;

   hwnd = ( HWND ) HB_PARNL( 1 );
   m_nHeightItem = 16;

   if( ! hb_parl( 9 ) )
      Style = Style | WS_VISIBLE;

   if( ! hb_parl( 10 ) )
      Style = Style | WS_TABSTOP;

   if( hb_parl( 11 ) )
      Style = Style | LBS_SORT;

   if( hb_parni( 12 ) )
      m_nHeightItem = hb_parni( 12 );

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

   HB_RETNL( ( LONG_PTR ) hbutton );
}

HB_FUNC( INITMULTICHKLISTBOX )
{
   HWND hwnd;
   HWND hbutton;
   int  Style = LBS_EXTENDEDSEL | WS_CHILD | WS_VSCROLL | LBS_DISABLENOSCROLL | LBS_NOTIFY | LBS_MULTIPLESEL | LBS_NOINTEGRALHEIGHT | LBS_OWNERDRAWFIXED | LBS_HASSTRINGS;

   hwnd = ( HWND ) HB_PARNL( 1 );
   m_nHeightItem = 16;

   if( ! hb_parl( 9 ) )
      Style = Style | WS_VISIBLE;

   if( ! hb_parl( 10 ) )
      Style = Style | WS_TABSTOP;

   if( hb_parl( 11 ) )
      Style = Style | LBS_SORT;

   if( hb_parni( 12 ) )
      m_nHeightItem = hb_parni( 12 );

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

   HB_RETNL( ( LONG_PTR ) hbutton );
}

HB_FUNC( CHKLISTBOXINSERTITEM )
{
   HWND   hwnd     = ( HWND ) HB_PARNL( 1 );
   char * pstr     = ( char * ) hb_parc( 2 );
   int    lbItem   = hb_parni( 3 ) - 1;
   int    bChecked = hb_parni( 4 );

   SendMessage( hwnd, LB_INSERTSTRING, ( WPARAM ) lbItem, ( LPARAM ) pstr );
   SendMessage( hwnd, LB_SETITEMDATA, ( WPARAM ) lbItem, ( LPARAM ) bChecked );
}

HB_FUNC( CHKLISTBOXADDITEM )
{
   HWND   hwnd     = ( HWND ) HB_PARNL( 1 );
   char * pstr     = ( char * ) hb_parc( 2 );
   int    bChecked = hb_parni( 3 );
   int    lbItem;

   m_nHeightItem = hb_parni( 4 );
   lbItem        = SendMessage( hwnd, LB_ADDSTRING, 0, ( LPARAM ) pstr );
   SendMessage( hwnd, LB_SETITEMDATA, ( WPARAM ) lbItem, ( LPARAM ) bChecked );
}

HB_FUNC( SETCHKLBITEMHEIGHT ) // set the height of a string in pixels
{
   TCHAR achBuffer[ BUFFER ];
   HWND  hwnd     = ( HWND ) HB_PARNL( 1 );
   HDC   hdc      = GetDC( hwnd );
   HFONT hFont    = ( HFONT ) HB_PARNL( 2 );
   HFONT hOldFont = ( HFONT ) NULL;
   SIZE  sz;

   if( ! hdc )
   {
      hwnd = GetActiveWindow();
      hdc  = GetDC( hwnd );
   }
   SendMessage( hwnd, LB_GETTEXT, 0, ( LPARAM ) achBuffer );

   if( hFont )
      hOldFont = ( HFONT ) SelectObject( hdc, hFont );

   GetTextExtentPoint32( hdc, achBuffer, strlen( achBuffer ), &sz );

   if( sz.cy > m_nHeightItem )
   {
      m_nHeightItem = sz.cy;

      SendMessage( hwnd, LB_SETITEMHEIGHT, 0, MAKELPARAM( m_nHeightItem, 0 ) );
   }

   if( hFont )
      SelectObject( hdc, hOldFont );

   ReleaseDC( hwnd, hdc );
}

HB_FUNC( CHKLIST_SETCHECKBOX )
{
   HWND hwnd            = ( HWND ) HB_PARNL( 1 );
   int  lbItem          = hb_parni( 2 ) - 1;
   int  bChecked        = hb_parni( 3 );
   char cString[ 1024 ] = "";

   SendMessage( hwnd, LB_GETTEXT, ( WPARAM ) lbItem, ( LPARAM ) cString );
   SendMessage( hwnd, LB_DELETESTRING, ( WPARAM ) lbItem, 0 );
   SendMessage( hwnd, LB_INSERTSTRING, ( WPARAM ) lbItem, ( LPARAM ) cString );
   SendMessage( hwnd, LB_SETITEMDATA, ( WPARAM ) lbItem, ( LPARAM ) bChecked );
}

HB_FUNC( CHKLIST_GETCHECKBOX )
{
   HWND hwnd   = ( HWND ) HB_PARNL( 1 );
   int  lbItem = hb_parni( 2 );
   int  iCheck = ( int ) SendMessage( hwnd, LB_GETITEMDATA, ( WPARAM ) lbItem - 1, 0 );

   hb_retl( ( BOOL ) iCheck - 1 );
}

HB_FUNC( _ONMEASURELISTBOXITEM )
{
   LPMEASUREITEMSTRUCT lpmis;

   lpmis = ( LPMEASUREITEMSTRUCT ) HB_PARNL( 1 );

   // Set the height of the list box items.
   lpmis->itemHeight = m_nHeightItem;
}

HB_FUNC( _ONDRAWLISTBOXITEM )
{
   PDRAWITEMSTRUCT pdis;
   TCHAR      achBuffer[ BUFFER ];
   size_t     cch;
   int        yPos, iCheck, style = 0;
   TEXTMETRIC tm;
   RECT       rcCheck;
   HBRUSH     hBackBrush;

   pdis = ( PDRAWITEMSTRUCT ) HB_PARNL( 1 );

   // If there are no list box items, skip this message.
   if( ( int ) pdis->itemID > -1 )
   {
      // Draw the bitmap and text for the list box item. Draw a
      // rectangle around the bitmap if it is selected.

      switch( pdis->itemAction )
      {
         case ODA_SELECT:
         case ODA_DRAWENTIRE:

            iCheck = ( int ) SendMessage( pdis->hwndItem, LB_GETITEMDATA, pdis->itemID, 0 );

            if( pdis->itemState & ODS_SELECTED )
            {
               SetTextColor( pdis->hDC, GetSysColor( COLOR_HIGHLIGHTTEXT ) );
               SetBkColor( pdis->hDC, GetSysColor( COLOR_HIGHLIGHT ) );
               hBackBrush = CreateSolidBrush( GetSysColor( COLOR_HIGHLIGHT ) );

            }
            else
            {
               SetTextColor( pdis->hDC, GetSysColor( COLOR_WINDOWTEXT ) );
               SetBkColor( pdis->hDC, GetSysColor( COLOR_WINDOW ) );
               hBackBrush = CreateSolidBrush( GetSysColor( COLOR_WINDOW ) );
            }
            FillRect( pdis->hDC, &pdis->rcItem, hBackBrush );
            DeleteObject( hBackBrush );
            rcCheck = pdis->rcItem;
            if( iCheck )
            {
               rcCheck.left   += 4;
               rcCheck.top    += 2;
               rcCheck.right   = rcCheck.left + ( pdis->rcItem.bottom - pdis->rcItem.top );
               rcCheck.bottom -= 2;

               if( iCheck == 1 )
               {
                  style = DFCS_BUTTONCHECK;
               }
               else if( iCheck == 2 )
               {
                  style = DFCS_BUTTONCHECK | DFCS_CHECKED;
               }
               DrawFrameControl( pdis->hDC, &rcCheck, DFC_BUTTON, style );

            }

            // Draw the string associated with the item.
            //
            // Get the item string from the list box.
            SendMessage( pdis->hwndItem, LB_GETTEXT,
                         pdis->itemID, ( LPARAM ) achBuffer );

            // Get the metrics for the current font.
            GetTextMetrics( pdis->hDC, &tm );

            // Calculate the vertical position for the item string
            // so that the string will be vertically centered in the
            // item rectangle.
            yPos = ( pdis->rcItem.bottom + pdis->rcItem.top -
                     tm.tmHeight ) / 2;
            // Get the character length of the item string.
            cch = strlen( achBuffer );
            // Draw the string in the item rectangle, leaving a six
            // pixel gap between the item bitmap and the string.
            TextOut( pdis->hDC, rcCheck.right + 6, yPos, achBuffer, cch );

            break;

         case ODA_FOCUS:
            DrawFocusRect( pdis->hDC, &pdis->rcItem );
            break;
      }
   }
}

/*
   Function GETMISCTLTYPE return value of CtlType MEASUREITEMSTRUCT member
 */
HB_FUNC( GETMISCTLTYPE )
{
   LPMEASUREITEMSTRUCT pmis = ( LPMEASUREITEMSTRUCT ) HB_PARNL( 1 );

   if( pmis )
      hb_retni( ( UINT ) pmis->CtlType );
}
