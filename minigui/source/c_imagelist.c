/*----------------------------------------------------------------------------
   MINIGUI - Harbour Win32 GUI library source code

   Copyright 2002-2010 Roberto Lopez <harbourminigui@gmail.com>
   http://harbourminigui.googlepages.com/

   IMAGELIST control source code
   (C)2005 Janusz Pora <januszpora@onet.eu>

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

#include <commctrl.h>

#if defined( __BORLANDC__ )
WINCOMMCTRLAPI void WINAPI ImageList_EndDrag( void );
#endif

extern HBITMAP HMG_LoadImage( const char * FileName );
extern HBITMAP HMG_LoadPicture( const char * FileName, int New_Width, int New_Height, HWND hWnd, int ScaleStretch, int Transparent, long BackgroundColor, int AdjustImage,
                                HB_BOOL bAlphaFormat, int iAlpfaConstant );

#ifdef UNICODE
   LPWSTR AnsiToWide( LPCSTR );
#endif
HINSTANCE GetInstance( void );
HINSTANCE GetResources( void );

// Minigui Resources control system
void RegisterResource( HANDLE hResource, LPSTR szType );

HB_FUNC( INITIMAGELIST )   //InitImageList ( cx , cy, mask , nCount )
{
   HIMAGELIST himlIcons;
   UINT       Styl = ILC_COLOR32;

   if( hb_parl( 3 ) )
      Styl = Styl | ILC_MASK;

   InitCommonControls();

   himlIcons = ImageList_Create( ( INT ) hb_parni( 1 ), ( INT ) hb_parni( 2 ), Styl, ( INT ) hb_parni( 4 ), 0 );

   RegisterResource( himlIcons, "IMAGELIST" );
   HB_RETNL( ( LONG_PTR ) himlIcons );
}

HB_FUNC( IL_ADD )          //IL_Add( himl , image , maskimage , ix , iy , imagecount )
{
#ifndef UNICODE
   LPCSTR lpImageName  = hb_parc( 2 );
   LPCSTR lpImageName2 = hb_parc( 3 );
#else
   LPWSTR lpImageName  = AnsiToWide( ( char * ) hb_parc( 2 ) );
   LPWSTR lpImageName2 = AnsiToWide( ( char * ) hb_parc( 3 ) );
#endif
   BITMAP  bm;
   HBITMAP himage1;  // handle to image
   HBITMAP himage2;  // handle to maskimage
   int     lResult = -1;
   int     ic      = 1;

   if( hb_parni( 6 ) )
      ic = hb_parni( 6 );

   himage1 = ( HBITMAP ) LoadImage( GetResources(), lpImageName, IMAGE_BITMAP, 0, 0, LR_LOADMAP3DCOLORS | LR_LOADTRANSPARENT );
   if( himage1 == NULL )
      himage1 = ( HBITMAP ) LoadImage( NULL, lpImageName, IMAGE_BITMAP, 0, 0, LR_LOADFROMFILE | LR_LOADMAP3DCOLORS | LR_LOADTRANSPARENT );

   if( himage1 == NULL )
      himage1 = ( HBITMAP ) HMG_LoadImage( hb_parc( 2 ) );

   himage2 = 0;
   if( hb_parclen( 3 ) )
   {
      himage2 = ( HBITMAP ) LoadImage( GetResources(), lpImageName2, IMAGE_BITMAP, 0, 0, LR_LOADMAP3DCOLORS | LR_LOADTRANSPARENT );
      if( himage2 == NULL )
         himage2 = ( HBITMAP ) LoadImage( NULL, lpImageName2, IMAGE_BITMAP, 0, 0, LR_LOADFROMFILE | LR_LOADMAP3DCOLORS | LR_LOADTRANSPARENT );

      if( himage2 == NULL )
         himage2 = ( HBITMAP ) HMG_LoadImage( hb_parc( 3 ) );
   }

   if( GetObject( himage1, sizeof( BITMAP ), &bm ) != 0 )
   {
      if( ( hb_parni( 4 ) * ic == bm.bmWidth ) & ( hb_parni( 5 ) == bm.bmHeight ) )
         lResult = ImageList_Add( ( HIMAGELIST ) HB_PARNL( 1 ), himage1, himage2 );

      DeleteObject( himage1 );
      if( himage2 )
         DeleteObject( himage2 );
   }

   hb_retni( lResult );
}

HB_FUNC( IL_ADDMASKED )    //IL_AddMasked( himl , image , color , ix , iy , imagecount )
{
#ifndef UNICODE
   LPCSTR lpImageName  = hb_parc( 2 );
#else
   LPWSTR lpImageName  = AnsiToWide( ( char * ) hb_parc( 2 ) );
#endif
   BITMAP   bm;
   HBITMAP  himage1; // handle to image
   COLORREF clrBk   = CLR_NONE;
   int      lResult = -1;
   int      ic      = 1;

   if( hb_parnl( 3 ) )
      clrBk = ( COLORREF ) hb_parnl( 3 );

   if( hb_parni( 6 ) )
      ic = hb_parni( 6 );

   himage1 = ( HBITMAP ) LoadImage( GetResources(), lpImageName, IMAGE_BITMAP, 0, 0, LR_LOADMAP3DCOLORS | LR_LOADTRANSPARENT );
   if( himage1 == NULL )
      himage1 = ( HBITMAP ) LoadImage( NULL, lpImageName, IMAGE_BITMAP, 0, 0, LR_LOADFROMFILE | LR_LOADMAP3DCOLORS | LR_LOADTRANSPARENT );

   if( himage1 == NULL )
      himage1 = ( HBITMAP ) HMG_LoadPicture( hb_parc( 2 ), -1, -1, NULL, 0, 1, -1, 0, HB_FALSE, 255 );

   if( GetObject( himage1, sizeof( BITMAP ), &bm ) != 0 )
   {
      if( ( hb_parni( 4 ) * ic == bm.bmWidth ) & ( hb_parni( 5 ) == bm.bmHeight ) )
         lResult = ImageList_AddMasked( ( HIMAGELIST ) HB_PARNL( 1 ), himage1, clrBk );

      DeleteObject( himage1 );
   }

   hb_retni( lResult );
}

HB_FUNC( IL_DRAW )         //BOOL IL_Draw(HWND hwnd, HIMAGELIST himl, int imageindex, cx , cy)
{
   HDC  hdc;
   HWND hwnd = ( HWND ) HB_PARNL( 1 );

   if( ( hdc = GetDC( hwnd ) ) == NULL )
      hb_retl( FALSE );

   if( ! ImageList_Draw( ( HIMAGELIST ) HB_PARNL( 2 ), ( INT ) hb_parni( 3 ), hdc, hb_parni( 4 ), hb_parni( 5 ), ILD_TRANSPARENT ) )
      hb_retl( FALSE );

   ReleaseDC( hwnd, hdc );

   hb_retl( TRUE );
}

HB_FUNC( IL_REMOVE )       //IL_Remove( hwnd , imageindex )
{
   HIMAGELIST himlIcons;

   himlIcons = ( HIMAGELIST ) HB_PARNL( 1 );

   hb_retl( ImageList_Remove( himlIcons, ( INT ) hb_parni( 2 ) ) );
}

HB_FUNC( IL_SETBKCOLOR )   //IL_SetBkColor( hwnd , color)
{
   COLORREF clrBk = CLR_NONE;

   if( hb_parnl( 2 ) )
      clrBk = hb_parnl( 2 );

   hb_retnl( ( COLORREF ) ImageList_SetBkColor( ( HIMAGELIST ) HB_PARNL( 1 ), clrBk ) );
}

HB_FUNC( IL_ERASEIMAGE )   //IL_EraseImage( hwnd, ix, iy, dx, dy )
{
   RECT rcImage;

   SetRect( &rcImage, hb_parni( 2 ), hb_parni( 3 ), hb_parni( 4 ) + hb_parni( 2 ), hb_parni( 5 ) + hb_parni( 3 ) );

   InvalidateRect( ( HWND ) HB_PARNL( 1 ), &rcImage, TRUE );
   UpdateWindow( ( HWND ) HB_PARNL( 1 ) );
}

HB_FUNC( IL_BEGINDRAG )    //IL_BeginDrag( hwnd, himl, ImageInx, ix, iy )
{
   INT  cx;
   INT  cy;
   RECT rcImage;

   if( ImageList_GetIconSize( ( HIMAGELIST ) HB_PARNL( 2 ), &cx, &cy ) )
   {
      SetRect( &rcImage, hb_parni( 4 ) - 2, hb_parni( 5 ) - 2, hb_parni( 4 ) + cx + 2, hb_parni( 5 ) + cy + 2 );
      InvalidateRect( ( HWND ) HB_PARNL( 1 ), &rcImage, TRUE );
      UpdateWindow( ( HWND ) HB_PARNL( 1 ) );
   }

   hb_retl( ImageList_BeginDrag( ( HIMAGELIST ) HB_PARNL( 2 ), ( INT ) hb_parni( 3 ), ( INT ) 0, ( INT ) 0 ) );
}

HB_FUNC( IL_DRAGMOVE )     //IL_DragMove( ix, iy )
{
   hb_retl( ImageList_DragMove( ( INT ) hb_parni( 1 ), ( INT ) hb_parni( 2 ) ) );
}

HB_FUNC( IL_DRAGENTER )    //IL_DragEnter( hwnd, ix, iy )
{
   hb_retl( ImageList_DragEnter( ( HWND ) HB_PARNL( 1 ), ( INT ) hb_parni( 2 ), ( INT ) hb_parni( 3 ) ) );
}

HB_FUNC( IL_ENDDRAG )      //IL_EndDrag( hwnd )
{
   ImageList_EndDrag();
   ImageList_DragLeave( ( HWND ) HB_PARNL( 1 ) );
}

HB_FUNC( IL_GETIMAGECOUNT ) //IL_GetImageCount( himl )
{
   hb_retni( ImageList_GetImageCount( ( HIMAGELIST ) HB_PARNL( 1 ) ) );
}
