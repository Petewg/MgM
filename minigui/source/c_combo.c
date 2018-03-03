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

#define _WIN32_IE    0x0501

#include <mgdefs.h>

#include <commctrl.h>

#ifndef WC_COMBOBOX
#define WC_COMBOBOX  "ComboBox"
#endif

HINSTANCE GetInstance( void );
HINSTANCE GetResources( void );

HB_FUNC( INITCOMBOBOX )
{
   HWND hwnd;
   HWND hbutton;
   int  Style;

   hwnd = ( HWND ) HB_PARNL( 1 );

   Style = WS_CHILD | WS_VSCROLL;

   if( ! hb_parl( 9 ) )
      Style = Style | WS_VISIBLE;

   if( ! hb_parl( 10 ) )
      Style = Style | WS_TABSTOP;

   if( hb_parl( 11 ) )
      Style = Style | CBS_SORT;

   Style = ( hb_parl( 12 ) ) ? ( Style | CBS_DROPDOWN ) : ( Style | CBS_DROPDOWNLIST );

   if( hb_parl( 13 ) )
      Style = Style | CBS_NOINTEGRALHEIGHT;

   if( hb_parl( 6 ) )
      Style = Style | CBS_UPPERCASE;

   if( hb_parl( 7 ) )
      Style = Style | CBS_LOWERCASE;

   hbutton = CreateWindow
             (
      WC_COMBOBOX,
      "",
      Style,
      hb_parni( 3 ),
      hb_parni( 4 ),
      hb_parni( 5 ),
      hb_parni( 8 ),
      hwnd,
      ( HMENU ) HB_PARNL( 2 ),
      GetInstance(),
      NULL
             );

   HB_RETNL( ( LONG_PTR ) hbutton );
}

HB_FUNC( INITCOMBOBOXEX )
{
   char * caption;

   HWND       hwnd;
   HWND       hCombo;
   PHB_ITEM   hArray;
   HIMAGELIST himl = ( HIMAGELIST ) NULL;
   HBITMAP    hbmp;

   int l;
   int s;
   int cx;
   int cy;
   int Style;

   INITCOMMONCONTROLSEX icex;

   icex.dwSize = sizeof( INITCOMMONCONTROLSEX );
   icex.dwICC  = ICC_USEREX_CLASSES;
   InitCommonControlsEx( &icex );

   hwnd = ( HWND ) HB_PARNL( 1 );

   Style = WS_CHILD | WS_VSCROLL;

   if( ! hb_parl( 9 ) )
      Style = Style | WS_VISIBLE;

   if( ! hb_parl( 10 ) )
      Style = Style | WS_TABSTOP;

   Style = ( hb_parl( 12 ) ) ? ( Style | CBS_DROPDOWN ) : ( Style | CBS_DROPDOWNLIST );

   if( hb_parl( 13 ) )
      Style = Style | CBS_NOINTEGRALHEIGHT;

   hCombo = CreateWindowEx
            (
      0,
      WC_COMBOBOXEX,
      "",
      Style,
      hb_parni( 3 ),
      hb_parni( 4 ),
      hb_parni( 5 ),
      hb_parni( 8 ),
      hwnd,
      ( HMENU ) HB_PARNL( 2 ),
      GetInstance(),
      NULL
            );

   //  create ImageList (only *.bmp are allowed here !) from aImage array

   l = hb_parinfa( 14, 0 ) - 1;

   if( l != 0 )
   {
      hArray = hb_param( 14, HB_IT_ARRAY );

      caption = ( char * ) hb_arrayGetCPtr( hArray, 1 );

      himl = ImageList_LoadImage
             (
         GetResources(),
         caption,
         0,
         l,
         CLR_DEFAULT,
         IMAGE_BITMAP,
         LR_LOADTRANSPARENT | LR_DEFAULTCOLOR | LR_LOADMAP3DCOLORS
             );

      if( himl == NULL )
         himl = ImageList_LoadImage( GetResources(), caption, 0, l, CLR_NONE, IMAGE_BITMAP, LR_LOADFROMFILE | LR_LOADTRANSPARENT );

      ImageList_GetIconSize( himl, &cx, &cy );

      for( s = 1; s <= l; s = s + 1 )
      {
         caption = ( char * ) hb_arrayGetCPtr( hArray, s + 1 );

         hbmp = ( HBITMAP ) LoadImage( GetResources(), caption, IMAGE_BITMAP, cx, cy, LR_LOADTRANSPARENT );
         if( hbmp == NULL )
            hbmp = ( HBITMAP ) LoadImage( NULL, caption, IMAGE_BITMAP, cx, cy, LR_LOADFROMFILE | LR_LOADTRANSPARENT );

         ImageList_Add( himl, hbmp, NULL );

         DeleteObject( hbmp );
      }
   }

   if( himl == NULL && HB_PARNL( 15 ) > 0 )
      himl = ( HIMAGELIST ) HB_PARNL( 15 );

   // set imagelist for created ComboEx

   if( himl != NULL )
      SendMessage( ( HWND ) hCombo, CBEM_SETIMAGELIST, 0, ( LPARAM ) himl );
   else
      // extend combo without images
      SendMessage
         (                                // returns LRESULT in lResult
         ( HWND ) hCombo,                 // handle to destination control
         ( UINT ) CBEM_SETEXTENDEDSTYLE,  // message ID
         ( WPARAM ) 0,                    // = (WPARAM) (DWORD) dwExMask;
         ( LPARAM ) CBES_EX_NOEDITIMAGE   // = (LPARAM) (DWORD) dwExStyle;
         );

   HB_RETNL( ( LONG_PTR ) hCombo );
}

HB_FUNC( COMBOSETITEMHEIGHT )
{
   HWND hWnd = ( HWND ) HB_PARNL( 1 );
   int  iDesiredHeight = hb_parni( 2 );

   SendMessage( hWnd, CB_SETITEMHEIGHT, ( WPARAM ) -1, ( LPARAM ) iDesiredHeight );
}

HB_FUNC( COMBOSHOWDROPDOWN )
{
   SendMessage( ( HWND ) HB_PARNL( 1 ), CB_SHOWDROPDOWN, ( WPARAM ) 1, ( LPARAM ) 0 );
}

HB_FUNC( COMBOEDITSETSEL )
{
   hb_retni( SendMessage( ( HWND ) HB_PARNL( 1 ), CB_SETEDITSEL, ( WPARAM ) 0, ( LPARAM ) MAKELPARAM( hb_parni( 2 ), hb_parni( 3 ) ) ) );
}

HB_FUNC( COMBOGETEDITSEL )
{
   DWORD pos;

   pos = SendMessage( ( HWND ) HB_PARNL( 1 ), CB_GETEDITSEL, ( WPARAM ) NULL, ( LPARAM ) NULL );

   hb_reta( 2 );

   HB_STORNI( LOWORD( pos ), -1, 1 );
   HB_STORNI( HIWORD( pos ), -1, 2 );
}

HB_FUNC( COMBOSELECTSTRING )
{
   hb_retni( SendMessage( ( HWND ) HB_PARNL( 1 ), CB_SELECTSTRING, ( WPARAM ) -1, ( LPARAM ) hb_parc( 2 ) ) );
}

/* Added by P.Ch. 16.10. */
HB_FUNC( COMBOFINDSTRING )
{
   hb_retnl( ( LONG ) SendMessage( ( HWND ) HB_PARNL( 1 ), ( UINT ) CB_FINDSTRING, ( WPARAM ) -1, ( LPARAM ) hb_parc( 2 ) ) + 1 );
}

HB_FUNC( COMBOFINDSTRINGEXACT )
{
   hb_retnl( ( LONG ) SendMessage( ( HWND ) HB_PARNL( 1 ), ( UINT ) CB_FINDSTRINGEXACT, ( WPARAM ) -1, ( LPARAM ) hb_parc( 2 ) ) + 1 );
}

/* Modified by P.Ch. 16.10. */
HB_FUNC( COMBOGETSTRING )
{
   int    iLen = SendMessage( ( HWND ) HB_PARNL( 1 ), CB_GETLBTEXTLEN, ( WPARAM ) hb_parni( 2 ) - 1, ( LPARAM ) 0 );
   char * cString;

   if( iLen > 0 && NULL != ( cString = ( char * ) hb_xgrab( ( iLen + 1 ) * sizeof( TCHAR ) ) ) )
   {
      SendMessage( ( HWND ) HB_PARNL( 1 ), CB_GETLBTEXT, ( WPARAM ) hb_parni( 2 ) - 1, ( LPARAM ) cString );
      hb_retclen_buffer( cString, iLen );
   }
   else
   {
      hb_retc_null();
   }
}

// extend combo functions  (JK)  HMG 1.0 Exp. Build 8
HB_FUNC( COMBOADDSTRINGEX )
{
   int nImage = hb_parni( 3 );
   COMBOBOXEXITEM cbei;

   cbei.mask           = CBEIF_TEXT | CBEIF_INDENT | CBEIF_IMAGE | CBEIF_SELECTEDIMAGE | CBEIF_OVERLAY;
   cbei.iItem          = -1;
   cbei.pszText        = ( LPTSTR ) hb_parc( 2 );            /* P.Ch. 16.10. */
   cbei.cchTextMax     = hb_parclen( 2 );
   cbei.iImage         = ( nImage - 1 ) * 3;
   cbei.iSelectedImage = ( nImage - 1 ) * 3 + 1;
   cbei.iOverlay       = ( nImage - 1 ) * 3 + 2;
   cbei.iIndent        = 0;

   SendMessage( ( HWND ) HB_PARNL( 1 ), CBEM_INSERTITEM, 0, ( LPARAM ) &cbei );
}

HB_FUNC( COMBOINSERTSTRINGEX )
{
   int nImage = hb_parni( 3 );
   COMBOBOXEXITEM cbei;

   cbei.mask           = CBEIF_TEXT | CBEIF_INDENT | CBEIF_IMAGE | CBEIF_SELECTEDIMAGE | CBEIF_OVERLAY;
   cbei.iItem          = hb_parni( 4 ) - 1;
   cbei.pszText        = ( LPTSTR ) hb_parc( 2 );            /* P.Ch. 16.10. */
   cbei.cchTextMax     = hb_parclen( 2 );
   cbei.iImage         = ( nImage - 1 ) * 3;
   cbei.iSelectedImage = ( nImage - 1 ) * 3 + 1;
   cbei.iOverlay       = ( nImage - 1 ) * 3 + 2;
   cbei.iIndent        = 0;

   SendMessage( ( HWND ) HB_PARNL( 1 ), CBEM_INSERTITEM, 0, ( LPARAM ) &cbei );
}

HB_FUNC( COMBOADDDATASTRINGEX )
{
   COMBOBOXEXITEM cbei;

   cbei.mask           = CBEIF_TEXT | CBEIF_INDENT | CBEIF_IMAGE | CBEIF_SELECTEDIMAGE | CBEIF_OVERLAY;
   cbei.iItem          = -1;
   cbei.pszText        = ( LPTSTR ) hb_parc( 2 );            /* P.Ch. 16.10. */
   cbei.cchTextMax     = hb_parclen( 2 );
   cbei.iImage         = 0;
   cbei.iSelectedImage = 1;
   cbei.iOverlay       = 2;
   cbei.iIndent        = 0;

   SendMessage( ( HWND ) HB_PARNL( 1 ), CBEM_INSERTITEM, 0, ( LPARAM ) &cbei );
}
