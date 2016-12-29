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

   ---------------------------------------------------------------------------*/

#define _WIN32_IE  0x0501

#include <mgdefs.h>

#include <commctrl.h>
#include <ctype.h>

extern BOOL Array2Point( PHB_ITEM aPoint, POINT * pt );

extern HINSTANCE g_hInstance;

// JD 11/05/2006

char * strtrim( char * str )
{
   #if ! defined( __POCC__ ) && ! defined( __MINGW32__ )

   char * ibuf, * obuf;

   if( str )
   {
      for( ibuf = obuf = str; *ibuf; )
      {
         while( *ibuf && ( isspace( *ibuf ) ) )
            ibuf++;

         if( *ibuf && ( obuf != str ) )
            *( obuf++ ) = ' ';

         while( *ibuf && ( ! isspace( *ibuf ) ) )
            *( obuf++ ) = *( ibuf++ );
      }

      *obuf = '\0';
   }
   #endif
   return str;
}

HB_FUNC( INITTABCONTROL )
{
   PHB_ITEM hArray;
   HWND     hwnd;
   HWND     hbutton;
   TC_ITEM  tie;
   int      l;
   int      i;

   int Style = WS_CHILD | WS_VISIBLE | TCS_TOOLTIPS;       //JR

   if( hb_parl( 11 ) )
      Style = Style | TCS_BUTTONS;

   if( hb_parl( 12 ) )
      Style = Style | TCS_FLATBUTTONS;

   if( hb_parl( 13 ) )
      Style = Style | TCS_HOTTRACK;

   if( hb_parl( 14 ) )
      Style = Style | TCS_VERTICAL;

   if( hb_parl( 15 ) )
      Style = Style | TCS_BOTTOM;

   if( hb_parl( 16 ) )
      Style = Style | TCS_MULTILINE;

   if( hb_parl( 17 ) )
      Style = Style | TCS_OWNERDRAWFIXED;

   if( ! hb_parl( 18 ) )
      Style = Style | WS_TABSTOP;

   l      = hb_parinfa( 7, 0 ) - 1;
   hArray = hb_param( 7, HB_IT_ARRAY );

   hwnd = ( HWND ) HB_PARNL( 1 );

   hbutton = CreateWindow
             (
      WC_TABCONTROL,
      NULL,
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

   tie.mask   = TCIF_TEXT;
   tie.iImage = -1;

   for( i = l; i >= 0; i = i - 1 )
   {
      tie.pszText = ( char * ) hb_arrayGetCPtr( hArray, i + 1 );

      TabCtrl_InsertItem( hbutton, 0, &tie );
   }

   TabCtrl_SetCurSel( hbutton, hb_parni( 8 ) - 1 );

   HB_RETNL( ( LONG_PTR ) hbutton );
}

HB_FUNC( TABCTRL_SETCURSEL )
{
   HWND hwnd;
   int  s;

   hwnd = ( HWND ) HB_PARNL( 1 );
   s    = hb_parni( 2 );

   TabCtrl_SetCurSel( hwnd, s - 1 );
}

HB_FUNC( TABCTRL_GETCURSEL )
{
   HWND hwnd;

   hwnd = ( HWND ) HB_PARNL( 1 );
   hb_retni( TabCtrl_GetCurSel( hwnd ) + 1 );
}

HB_FUNC( TABCTRL_INSERTITEM )
{
   HWND    hwnd;
   TC_ITEM tie;
   int     i;

   hwnd = ( HWND ) HB_PARNL( 1 );
   i    = hb_parni( 2 );

   tie.mask    = TCIF_TEXT;
   tie.iImage  = -1;
   tie.pszText = ( char * ) hb_parc( 3 );

   TabCtrl_InsertItem( hwnd, i, &tie );
}

HB_FUNC( TABCTRL_DELETEITEM )
{
   HWND hwnd;
   int  i;

   hwnd = ( HWND ) HB_PARNL( 1 );
   i    = hb_parni( 2 );

   TabCtrl_DeleteItem( hwnd, i );
}

HB_FUNC( SETTABCAPTION )
{
   TC_ITEM tie;

   tie.mask = TCIF_TEXT;

   tie.pszText = ( char * ) hb_parc( 3 );

   TabCtrl_SetItem( ( HWND ) HB_PARNL( 1 ), hb_parni( 2 ) - 1, &tie );
}

HB_FUNC( ADDTABBITMAP )
{
   HWND       hbutton;
   HIMAGELIST himl = ( HIMAGELIST ) NULL;
   HBITMAP    hbmp;
   PHB_ITEM   hArray;
   char *     caption;
   int        l;
   int        s;
   int        cx;
   int        cy;
   TC_ITEM    tie;

   // JD 11/05/2006 Significant re-write from original ( logic and additions )

   HDC hDC;
   int i = 0;

   hbutton = ( HWND ) HB_PARNL( 1 );
   l       = hb_parinfa( 2, 0 ) - 1;
   hArray  = hb_param( 2, HB_IT_ARRAY );

   // Determine Image Size Based Upon First Image FOUND

   for( s = 0; s <= l; s++ )
   {
      caption = ( char * ) hb_arrayGetCPtr( hArray, s + 1 );

      if( strlen( strtrim( caption ) ) > 0 )
      {
         i = s + 1;
         break;
      }
   }

   // We found at least 1 Image to determine size of BitMap

   if( i != 0 )
   {
      caption = ( char * ) hb_arrayGetCPtr( hArray, i );

      himl = ImageList_LoadImage
             (
         g_hInstance,
         caption,
         0,
         l,
         CLR_DEFAULT,
         IMAGE_BITMAP,
         LR_LOADTRANSPARENT | LR_DEFAULTCOLOR | LR_LOADMAP3DCOLORS
             );

      if( himl == NULL )
         himl = ImageList_LoadImage
                (
            0,
            caption,
            0,
            l,
            CLR_DEFAULT,
            IMAGE_BITMAP,
            LR_LOADTRANSPARENT | LR_LOADFROMFILE | LR_DEFAULTCOLOR | LR_LOADMAP3DCOLORS
                );

      if( himl != NULL )
      {
         ImageList_GetIconSize( himl, &cx, &cy );

         ImageList_Destroy( himl );
      }

      if( ( cx > 0 ) && ( cy > 0 ) )
      {
         himl = ImageList_Create( cx, cy, ILC_COLOR8 | ILC_MASK, l + 1, l + 1 );

         if( himl != NULL )
         {
            for( s = 0; s <= l; s++ )
            {
               caption = ( char * ) hb_arrayGetCPtr( hArray, s + 1 );

               hbmp = NULL;

               if( strlen( strtrim( caption ) ) > 0 )
               {
                  hbmp = ( HBITMAP ) LoadImage
                         (
                     g_hInstance,
                     caption,
                     IMAGE_BITMAP,
                     cx,
                     cy,
                     LR_LOADTRANSPARENT | LR_DEFAULTCOLOR | LR_LOADMAP3DCOLORS
                         );

                  if( hbmp == NULL )
                     hbmp = ( HBITMAP ) LoadImage
                            (
                        0,
                        caption,
                        IMAGE_BITMAP,
                        cx,
                        cy,
                        LR_LOADTRANSPARENT | LR_LOADFROMFILE | LR_DEFAULTCOLOR | LR_LOADMAP3DCOLORS
                            );
               }

               if( hbmp != NULL )
               {
                  ImageList_AddMasked( himl, hbmp, CLR_DEFAULT );
                  DeleteObject( hbmp );
               }
               else
               {
                  // Create Compatible Blank BitMap

                  hDC  = GetDC( hbutton );
                  hbmp = CreateCompatibleBitmap( hDC, cx, cy );

                  ImageList_AddMasked( himl, hbmp, CLR_DEFAULT );

                  DeleteObject( hbmp );
                  ReleaseDC( hbutton, hDC );
               }
            }

            SendMessage( hbutton, TCM_SETIMAGELIST, ( WPARAM ) 0, ( LPARAM ) himl );

            for( s = 0; s <= l; s++ )
            {
               tie.mask   = TCIF_IMAGE;
               tie.iImage = s;
               TabCtrl_SetItem( ( HWND ) hbutton, s, &tie );
            }
         }
      }
   }

   HB_RETNL( ( LONG_PTR ) himl );
}

HB_FUNC( WINDOWFROMPOINT )
{
   POINT Point;

   Array2Point( hb_param( 1, HB_IT_ARRAY ), &Point );
   HB_RETNL( ( LONG_PTR ) WindowFromPoint( Point ) );
}

HB_FUNC( GETMESSAGEPOS )
{
   hb_retnl( ( LONG ) GetMessagePos() );
}
