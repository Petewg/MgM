/*----------------------------------------------------------------------------
   MINIGUI - Harbour Win32 GUI library source code

   Copyright 2002-2010 Roberto Lopez <harbourminigui@gmail.com>
   http://harbourminigui.googlepages.com/

   BTNTEXTBOX control source code
   (C)2006-2011 Janusz Pora <januszpora@onet.eu>

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

#include "hbapiitm.h"
#include "hbstack.h"
#include "hbvm.h"

#ifndef WC_EDIT
#define WC_EDIT    TEXT( "Edit" )
#define WC_BUTTON  TEXT( "Button" )
#endif

#define TBB1       2
#define TBB2       3

LRESULT CALLBACK OwnBtnTextProc( HWND hbutton, UINT msg, WPARAM wParam, LPARAM lParam );

#ifdef UNICODE
   LPWSTR AnsiToWide( LPCSTR );
#endif
HINSTANCE GetInstance( void );
HINSTANCE GetResources( void );

HB_FUNC( INITBTNTEXTBOX )
{
   HWND hwnd;                    // Handle of the parent window/form.
   HWND hedit;                   // Handle of the child window/control.
   int  iStyle;                  // TEXTBOX window base style.
   int  ibtnStyle1, ibtnStyle2;  // BUTTON window base style.
   HWND himage, himage2;
   HWND hBtn1, hBtn2;
   BOOL fBtn2 = hb_parl( 20 );
   int  BtnWidth2;
   int  BtnWidth = ( HB_ISNIL( 18 ) ? 0 : ( int ) hb_parni( 18 ) );

   // Get the handle of the parent window/form.
   hwnd = ( HWND ) HB_PARNL( 1 );

   BtnWidth  = ( BtnWidth >= GetSystemMetrics( SM_CYSIZE ) ? BtnWidth : GetSystemMetrics( SM_CYSIZE ) - 1 );
   BtnWidth2 = ( fBtn2 ? BtnWidth : 0 );

   iStyle = WS_CHILD | ES_AUTOHSCROLL | WS_CLIPCHILDREN;

   if( hb_parl( 12 ) )  // if <lNumeric> is TRUE, then ES_NUMBER style is added.
      iStyle = iStyle | ES_NUMBER;
   else
   {
      if( hb_parl( 10 ) ) // if <lUpper> is TRUE, then ES_UPPERCASE style is added.
         iStyle = iStyle | ES_UPPERCASE;

      if( hb_parl( 11 ) ) // if <lLower> is TRUE, then ES_LOWERCASE style is added.
         iStyle = iStyle | ES_LOWERCASE;
   }

   if( hb_parl( 13 ) )  // if <lPassword> is TRUE, then ES_PASSWORD style is added.
      iStyle = iStyle | ES_PASSWORD;

   if( hb_parl( 14 ) )
      iStyle = iStyle | ES_RIGHT;

   if( ! hb_parl( 15 ) )
      iStyle = iStyle | WS_VISIBLE;

   if( ! hb_parl( 16 ) )
      iStyle = iStyle | WS_TABSTOP;

   if( hb_parl( 21 ) )
      iStyle = iStyle | ES_READONLY;

   // Creates the child Frame control.
   hedit = CreateWindowEx
           (
      WS_EX_CLIENTEDGE,
      WC_EDIT,
      TEXT( "" ),
      iStyle,
      hb_parni( 3 ),
      hb_parni( 4 ),
      hb_parni( 5 ),
      hb_parni( 6 ),
      ( HWND ) hwnd,
      ( HMENU ) NULL,
      GetInstance(),
      NULL
           );

   SetProp( ( HWND ) hedit, TEXT( "OldWndProc" ), ( HWND ) GetWindowLongPtr( ( HWND ) hedit, GWLP_WNDPROC ) );
   SetWindowLongPtr( hedit, GWLP_WNDPROC, ( LONG_PTR ) ( WNDPROC ) OwnBtnTextProc );

   SendMessage( hedit, ( UINT ) EM_LIMITTEXT, ( WPARAM ) hb_parni( 9 ), ( LPARAM ) 0 );

   if( hb_parc( 17 ) != NULL )
   {
#ifndef UNICODE
      LPCSTR lpImageName = hb_parc( 17 );
#else
      LPWSTR lpImageName = AnsiToWide( ( char * ) hb_parc( 17 ) );
#endif
      himage = ( HWND ) LoadImage( GetResources(), lpImageName, IMAGE_BITMAP, 0, 0, LR_LOADMAP3DCOLORS | LR_LOADTRANSPARENT );

      if( himage == NULL )
         himage = ( HWND ) LoadImage( NULL, lpImageName, IMAGE_BITMAP, 0, 0, LR_LOADFROMFILE | LR_LOADMAP3DCOLORS | LR_LOADTRANSPARENT );

      if( himage != NULL )
      {
         BITMAP bm;
         GetObject( himage, sizeof( BITMAP ), &bm );
         if( bm.bmWidth > BtnWidth - 4 || bm.bmHeight > hb_parni( 6 ) - 5 )
         {
            DeleteObject( himage );
            himage = ( HWND ) LoadImage( GetResources(), lpImageName, IMAGE_BITMAP, BtnWidth - 4, hb_parni(
                                            6 ) - 6, LR_LOADMAP3DCOLORS | LR_LOADTRANSPARENT );
            if( himage == NULL )
               himage = ( HWND ) LoadImage( NULL, lpImageName, IMAGE_BITMAP, BtnWidth - 4, hb_parni(
                                               6 ) - 6, LR_LOADFROMFILE | LR_LOADMAP3DCOLORS | LR_LOADTRANSPARENT );
         }
      }
   }
   else
      himage = NULL;

   if( hb_parc( 19 ) != NULL )
   {
#ifndef UNICODE
      LPCSTR lpImageName2 = hb_parc( 19 );
#else
      LPWSTR lpImageName2 = AnsiToWide( ( char * ) hb_parc( 19 ) );
#endif
      himage2 = ( HWND ) LoadImage( GetResources(), lpImageName2, IMAGE_BITMAP, 0, 0, LR_LOADMAP3DCOLORS | LR_LOADTRANSPARENT );

      if( himage2 == NULL )
         himage2 = ( HWND ) LoadImage( NULL, lpImageName2, IMAGE_BITMAP, 0, 0, LR_LOADFROMFILE | LR_LOADMAP3DCOLORS | LR_LOADTRANSPARENT );

      if( himage2 != NULL )
      {
         BITMAP bm;
         GetObject( himage2, sizeof( BITMAP ), &bm );
         if( bm.bmWidth > BtnWidth2 - 4 || bm.bmHeight > hb_parni( 6 ) - 5 )
         {
            DeleteObject( himage2 );
            himage2 = ( HWND ) LoadImage( GetResources(), lpImageName2, IMAGE_BITMAP, BtnWidth2 - 4, hb_parni(
                                             6 ) - 6, LR_LOADMAP3DCOLORS | LR_LOADTRANSPARENT );

            if( himage2 == NULL )
               himage2 = ( HWND ) LoadImage( NULL, lpImageName2, IMAGE_BITMAP, BtnWidth2 - 4, hb_parni(
                                                6 ) - 6, LR_LOADFROMFILE | LR_LOADMAP3DCOLORS | LR_LOADTRANSPARENT );
         }
      }
   }
   else
      himage2 = NULL;

   ibtnStyle1 = BS_NOTIFY | WS_CHILD | WS_VISIBLE;

   ibtnStyle1 = ibtnStyle1 | ( hb_parl( 22 ) ? BS_DEFPUSHBUTTON : BS_PUSHBUTTON );

   if( himage != NULL )
      ibtnStyle1 = ibtnStyle1 | BS_BITMAP;

   ibtnStyle2 = BS_NOTIFY | WS_CHILD | BS_PUSHBUTTON | WS_VISIBLE;

   if( himage2 != NULL )
      ibtnStyle2 = ibtnStyle2 | BS_BITMAP;

   hBtn1 = CreateWindow
              ( WC_BUTTON,
              TEXT( "..." ),
              ibtnStyle1,
              hb_parni( 5 ) - BtnWidth - 3,
              -1,
              BtnWidth,
              hb_parni( 6 ) - 2,
              ( HWND ) hedit,
              ( HMENU ) TBB1,
              GetInstance(),
              NULL
              );

   if( fBtn2 )
      hBtn2 = CreateWindow
                 ( WC_BUTTON,
                 TEXT( "..." ),
                 ibtnStyle2,
                 hb_parni( 5 ) - BtnWidth - BtnWidth2 - 3,
                 -1,
                 BtnWidth,
                 hb_parni( 6 ) - 2,
                 ( HWND ) hedit,
                 ( HMENU ) TBB2,
                 GetInstance(),
                 NULL
                 );
   else
      hBtn2 = 0;

   if( himage != NULL )
      SendMessage( hBtn1, ( UINT ) BM_SETIMAGE, ( WPARAM ) IMAGE_BITMAP, ( LPARAM ) himage );

   if( himage2 != NULL )
      SendMessage( hBtn2, ( UINT ) BM_SETIMAGE, ( WPARAM ) IMAGE_BITMAP, ( LPARAM ) himage2 );

   hb_reta( 5 );
   HB_STORVNL( ( LONG_PTR ) hedit, -1, 1 );
   HB_STORVNL( ( LONG_PTR ) hBtn1, -1, 2 );
   HB_STORVNL( ( LONG_PTR ) hBtn2, -1, 3 );
   HB_STORVNL( ( LONG_PTR ) himage, -1, 4 );
   HB_STORVNL( ( LONG_PTR ) himage2, -1, 5 );

}

HB_FUNC( REDEFBTNTEXTBOX )
{
   HWND hedit, himage, himage2;
   HWND hBtn1, hBtn2;
   BOOL fBtn2;
   int  width, height, BtnWidth2;
   int  BtnWidth = ( HB_ISNIL( 3 ) ? 0 : ( int ) hb_parni( 3 ) );

   hedit     = ( HWND ) HB_PARNL( 1 );
   fBtn2     = hb_parl( 5 );
   BtnWidth  = ( BtnWidth >= GetSystemMetrics( SM_CYSIZE ) ? BtnWidth : GetSystemMetrics( SM_CYSIZE ) - 1 );
   BtnWidth2 = ( fBtn2 ?  BtnWidth : 0 );
   width     = hb_parni( 6 );
   height    = hb_parni( 7 );

   SetProp( ( HWND ) hedit, TEXT( "OldWndProc" ), ( HWND ) GetWindowLongPtr( ( HWND ) hedit, GWLP_WNDPROC ) );
   SetWindowLongPtr( hedit, GWLP_WNDPROC, ( LONG_PTR ) ( WNDPROC ) OwnBtnTextProc );

   if( ! ( hb_parc( 2 ) == NULL ) )
   {
#ifndef UNICODE
      LPCSTR lpImageName = hb_parc( 2 );
#else
      LPWSTR lpImageName = AnsiToWide( ( char * ) hb_parc( 2 ) );
#endif
      himage = ( HWND ) LoadImage( GetResources(), lpImageName, IMAGE_BITMAP, 0, 0, LR_LOADMAP3DCOLORS | LR_LOADTRANSPARENT );

      if( himage == NULL )
         himage = ( HWND ) LoadImage( NULL, lpImageName, IMAGE_BITMAP, 0, 0, LR_LOADFROMFILE | LR_LOADMAP3DCOLORS | LR_LOADTRANSPARENT );

      if( himage != NULL )
      {
         BITMAP bm;
         GetObject( himage, sizeof( BITMAP ), &bm );
         if( bm.bmWidth > BtnWidth - 4 || bm.bmHeight > height - 5 )
         {
            DeleteObject( himage );
            himage = ( HWND ) LoadImage( GetResources(), lpImageName, IMAGE_BITMAP, BtnWidth - 4, height - 6, LR_LOADMAP3DCOLORS | LR_LOADTRANSPARENT );
            if( himage == NULL )
               himage = ( HWND ) LoadImage( NULL, lpImageName, IMAGE_BITMAP, BtnWidth - 4, height - 6, LR_LOADFROMFILE | LR_LOADMAP3DCOLORS | LR_LOADTRANSPARENT );
         }
      }
   }
   else
      himage = NULL;

   if( ! ( hb_parc( 4 ) == NULL ) )
   {
#ifndef UNICODE
      LPCSTR lpImageName2 = hb_parc( 4 );
#else
      LPWSTR lpImageName2 = AnsiToWide( ( char * ) hb_parc( 4 ) );
#endif
      himage2 = ( HWND ) LoadImage( GetResources(), lpImageName2, IMAGE_BITMAP, 0, 0, LR_LOADMAP3DCOLORS | LR_LOADTRANSPARENT );

      if( himage2 == NULL )
         himage2 = ( HWND ) LoadImage( NULL, lpImageName2, IMAGE_BITMAP, 0, 0, LR_LOADFROMFILE | LR_LOADMAP3DCOLORS | LR_LOADTRANSPARENT );

      if( himage2 != NULL )
      {
         BITMAP bm;
         GetObject( himage2, sizeof( BITMAP ), &bm );
         if( bm.bmWidth > BtnWidth2 - 4 || bm.bmHeight > height - 5 )
         {
            DeleteObject( himage2 );
            himage2 = ( HWND ) LoadImage( GetResources(), lpImageName2,
                                          IMAGE_BITMAP, BtnWidth2 - 4, height - 6, LR_LOADMAP3DCOLORS | LR_LOADTRANSPARENT );

            if( himage2 == NULL )
               himage2 = ( HWND ) LoadImage( NULL, lpImageName2,
                                          IMAGE_BITMAP, BtnWidth2 - 4, height - 6, LR_LOADFROMFILE | LR_LOADMAP3DCOLORS | LR_LOADTRANSPARENT );
         }
      }
   }
   else
      himage2 = NULL;

   hBtn1 = CreateWindow
           (
      WC_BUTTON,
      TEXT( "..." ),
      BS_NOTIFY | WS_CHILD | BS_PUSHBUTTON | WS_VISIBLE | BS_BITMAP,
      width - BtnWidth - 4,
      -1,
      BtnWidth,
      height - 2,
      ( HWND ) hedit,
      ( HMENU ) TBB1,
      GetInstance(),
      NULL
           );

   if( fBtn2 )
      hBtn2 = CreateWindow
              (
         WC_BUTTON,
         TEXT( "..." ),
         BS_NOTIFY | WS_CHILD | BS_PUSHBUTTON | WS_VISIBLE | BS_BITMAP,
         width - BtnWidth - BtnWidth2 - 4,
         -1,
         BtnWidth,
         height - 2,
         ( HWND ) hedit,
         ( HMENU ) TBB2,
         GetInstance(),
         NULL
              );
   else
      hBtn2 = 0;

   if( ! ( himage == NULL ) )
      SendMessage( hBtn1, ( UINT ) BM_SETIMAGE, ( WPARAM ) IMAGE_BITMAP, ( LPARAM ) himage );

   if( ! ( himage2 == NULL ) )
      SendMessage( hBtn2, ( UINT ) BM_SETIMAGE, ( WPARAM ) IMAGE_BITMAP, ( LPARAM ) himage2 );

   SendMessage( hedit, EM_SETMARGINS, EC_LEFTMARGIN | EC_RIGHTMARGIN, MAKELONG( 0, BtnWidth + BtnWidth2 + 2 ) );

   hb_reta( 5 );
   HB_STORVNL( ( LONG_PTR ) hedit, -1, 1 );
   HB_STORVNL( ( LONG_PTR ) hBtn1, -1, 2 );
   HB_STORVNL( ( LONG_PTR ) hBtn2, -1, 3 );
   HB_STORVNL( ( LONG_PTR ) himage, -1, 4 );
   HB_STORVNL( ( LONG_PTR ) himage2, -1, 5 );
}

HB_FUNC( SETTBBTNMARGIN )   //SetTbBtnMargin(hEdit, BtnWidth, fBtns, fBtn2)
{
   HWND hedit    = ( HWND ) HB_PARNL( 1 );
   int  BtnWidth = ( int ) hb_parni( 2 );
   BOOL fBtns    = hb_parl( 3 );
   BOOL fBtn2    = hb_parl( 4 );
   int  BtnWidth2;

   BtnWidth  = ( BtnWidth >= GetSystemMetrics( SM_CYSIZE ) ? BtnWidth : GetSystemMetrics( SM_CYSIZE ) - 1 );
   BtnWidth  = ( fBtns ? BtnWidth : 0 );
   BtnWidth2 = ( fBtn2 ? BtnWidth : 0 );

   SendMessage( hedit, EM_SETMARGINS, EC_LEFTMARGIN | EC_RIGHTMARGIN, MAKELONG( 0, BtnWidth + BtnWidth2 + 2 ) );
}

LRESULT CALLBACK OwnBtnTextProc( HWND hwnd, UINT Msg, WPARAM wParam, LPARAM lParam )
{
   static PHB_SYMB pSymbol = NULL;
   long int        r;
   WNDPROC         OldWndProc;

   OldWndProc = ( WNDPROC ) ( LONG_PTR ) GetProp( hwnd, TEXT( "OldWndProc" ) );

   switch( Msg )
   {
      case WM_CONTEXTMENU:
      case WM_COMMAND:

         if( lParam != 0 && ( HIWORD( wParam ) == BN_CLICKED || Msg == WM_CONTEXTMENU ) )
         {
            if( ! pSymbol )
               pSymbol = hb_dynsymSymbol( hb_dynsymGet( "TBBTNEVENTS" ) );

            if( pSymbol )
            {
               hb_vmPushSymbol( pSymbol );
               hb_vmPushNil();
               hb_vmPushNumInt( ( LONG_PTR ) hwnd );
               hb_vmPushNumInt( lParam );
               hb_vmPushLong( Msg );
               hb_vmDo( 3 );
            }

            r = hb_parnl( -1 );

            if( r != 0 )
               return r;
            else
               return CallWindowProc( OldWndProc, hwnd, Msg, wParam, lParam );
         }
   }

   return CallWindowProc( OldWndProc, hwnd, Msg, wParam, lParam );
}
