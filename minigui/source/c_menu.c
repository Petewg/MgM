/*-------------------------------------------------------------------------
   MINIGUI - Harbour Win32 GUI library source code

   Copyright 2002-2010 Roberto Lopez <harbourminigui@gmail.com>
   http://harbourminigui.googlepages.com/

   This  program is free software; you can redistribute it and/or modify it
   under  the  terms  of the GNU General Public License as published by the
   Free  Software  Foundation; either version 2 of the License, or (at your
   option) any later version.

   This  program  is  distributed  in  the hope that it will be useful, but
   WITHOUT   ANY   WARRANTY;   without   even   the   implied  warranty  of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General
   Public License for more details.

   You  should have received a copy of the GNU General Public License along
   with  this  software;  see  the  file COPYING. If not, write to the Free
   Software  Foundation,  Inc.,  59  Temple  Place,  Suite  330, Boston, MA
   02111-1307 USA (or visit the web site http://www.gnu.org/).

   As  a  special exception, you have permission for additional uses of the
   text contained in this release of Harbour Minigui.

   The  exception  is  that,  if  you link the Harbour Minigui library with
   other  files to produce an executable, this does not by itself cause the
   resulting  executable  to  be covered by the GNU General Public License.
   Your  use  of  that  executable  is  in  no way restricted on account of
   linking the Harbour-Minigui library code into it.

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

   Parts of this code  is contributed and used here under permission of his
   author:
   Copyright 2007 - 2017 (C) P.Chornyj <myorg63@mail.ru>
   ----------------------------------------------------------------------*/

#if ! defined( __WINNT__ )
  #define __WINNT__
#endif

#include <mgdefs.h>
#include "hbapierr.h"
#include "hbapiitm.h"

#ifndef __XHARBOUR__
#include "hbwinuni.h"
#endif

#include "c_menu.h"

// extern functions
extern HBITMAP   Icon2Bmp( HICON hIcon );
extern BOOL      SetAcceleratorTable( HWND, HACCEL );
// extern variables
extern HINSTANCE g_hInstance;

HB_FUNC( SETACCELERATORTABLE )
{
   HWND   hWndMain = ( HWND ) ( LONG_PTR ) HB_PARNL( 1 );
   HACCEL hAccel   = ( HACCEL ) ( LONG_PTR ) HB_PARNL( 2 );

   if( hWndMain && hAccel )
      SetAcceleratorTable( hWndMain, hAccel );
}

HB_FUNC( ACCELERATORTABLE2ARRAY )
{
   HACCEL   hAccel  = ( HACCEL ) ( LONG_PTR ) HB_PARNL( 1 );
   PHB_ITEM aAccels = hb_itemArrayNew( 0 );

   if( hAccel )
   {
      int cAccelEntries = CopyAcceleratorTable( hAccel, NULL, 0 );

      if( cAccelEntries > 0 )
      {
         LPACCEL lpAccel = ( LPACCEL ) hb_xalloc(  cAccelEntries * sizeof( ACCEL ) );

         if( NULL != lpAccel )
         {
            if( CopyAcceleratorTable( hAccel, lpAccel, cAccelEntries ) )
            {
               int i;

               for( i = 0; i < cAccelEntries; i++ )
               {
                  PHB_ITEM aAccel = hb_itemArrayNew( 3 );

                  hb_arraySetNI( aAccel, 1, lpAccel[ i ].fVirt );
                  hb_arraySetNL( aAccel, 2, lpAccel[ i ].key );
                  hb_arraySetNL( aAccel, 3, lpAccel[ i ].cmd );

                  hb_arrayAddForward( aAccels, aAccel );

                  hb_itemRelease( aAccel );
               }

               hb_xfree( lpAccel );
            }
         }
      }
   }

   hb_itemReturnRelease( aAccels );
}

HB_FUNC( ARRAY2ACCELERATORTABLE )
{
   PHB_ITEM pArray = hb_param( 1, HB_IT_ARRAY );
   HB_SIZE  nLen;
   HACCEL   hAccel = NULL;

   if( pArray && ( ( nLen = hb_arrayLen( pArray ) ) > 0 ) )
   {
      LPACCEL lpAccel = ( LPACCEL ) hb_xalloc(  nLen * sizeof( ACCEL ) );

      if( NULL != lpAccel )
      {
         HB_SIZE i;

         for( i = 0; i < nLen; i++ )
         {
            if( hb_arrayGetType( pArray, i + 1 ) & HB_IT_ARRAY )
            {
               PHB_ITEM pAccel = hb_arrayGetItemPtr( pArray, i + 1 );

               if( hb_arrayLen( pAccel ) == 3 )
               {
                  lpAccel[ i ].fVirt = ( BYTE ) hb_arrayGetNI( pAccel, 1 );
                  lpAccel[ i ].key   = ( WORD ) hb_arrayGetNL( pAccel, 2 );
                  lpAccel[ i ].cmd   = ( WORD ) hb_arrayGetNL( pAccel, 3 );
               }
            }
         }

         hAccel = CreateAcceleratorTable( lpAccel, nLen );
         hb_xfree( lpAccel );
      }
   }

   HB_RETNL( ( LONG_PTR ) hAccel );
}


// int WINAPI CopyAcceleratorTable( HACCEL hAccelSrc, LPACCEL lpAccelDst, int cAccelEntries )
HB_FUNC( COPYACCELERATORTABLE )
{
   HACCEL hAccelSrc = ( HACCEL ) ( LONG_PTR ) HB_PARNL( 1 );

   hb_retni( 0 );

   if( NULL != hAccelSrc )
   {
      int cAccelEntries = CopyAcceleratorTable( hAccelSrc, NULL, 0 );

      if( cAccelEntries > 0 )
      {
         LPACCEL lpAccelDst = ( LPACCEL ) hb_xalloc(  cAccelEntries * sizeof( ACCEL ) );

         if( NULL != lpAccelDst )
         {
            hb_retni( CopyAcceleratorTable( hAccelSrc, lpAccelDst, cAccelEntries ) );

            hb_storptr( lpAccelDst, 2 );
         }
      }
   }
}

// HACCEL WINAPI CreateAcceleratorTable( LPACCEL lpAccel, int cAccelEntries )
HB_FUNC( CREATEACCELERATORTABLE )
{
   LPACCEL lpAccels      = ( LPACCEL ) hb_parptr( 1 );
   HACCEL  hAccel        = NULL;
   int     cAccelEntries = hb_parni( 2 );

   if( lpAccels && ( cAccelEntries > 0 ) )
   {
      hAccel = CreateAcceleratorTable( lpAccels, cAccelEntries );

      hb_xfree( lpAccels );
   }

   HB_RETNL( ( LONG_PTR ) hAccel );
}

// BOOL WINAPI DestroyAcceleratorTable( HACCEL hAccel )
HB_FUNC( DESTROYACCELERATORTABLE )
{
   HACCEL hAccel = ( HACCEL ) ( LONG_PTR ) HB_PARNL( 1 );

   hb_retl( DestroyAcceleratorTable( hAccel ) ? HB_TRUE : HB_FALSE );
}

// HACCEL WINAPI LoadAccelerators( HINSTANCE hInstance, LPCTSTR lpTableName )
HB_FUNC( LOADACCELERATORS )
{
   HACCEL    hAccel    = ( HACCEL ) NULL;
   HINSTANCE hInstance = HB_ISNUM( 1 ) ? ( HINSTANCE ) HB_PARNL( 1 ) : g_hInstance;
   LPCTSTR   lpTableName;

   if( HB_ISNUM( 2 ) )
   {
      lpTableName = MAKEINTRESOURCE( ( WORD ) hb_parnl( 2 ) );

      hAccel = LoadAccelerators( hInstance, lpTableName );
   }
   else if( hb_parclen( 2 ) > 0 )
   {
#ifndef __XHARBOUR__
      void * hTableName;
      lpTableName = HB_PARSTR( 2, &hTableName, NULL );
#else
      LPCTSTR lpTableName = ( LPCTSTR ) hb_parc( 2 );
#endif
      hAccel = LoadAccelerators( hInstance, lpTableName );
#ifndef __XHARBOUR__
      hb_strfree( hTableName );
#endif
   }

   HB_RETNL( ( LONG_PTR ) hAccel );
}

// HMENU WINAPI LoadMenu( HINSTANCE hInstance, LPCTSTR lpMenuName )
HB_FUNC( LOADMENU )
{
   HMENU     hMenu     = ( HMENU ) NULL;
   HINSTANCE hInstance = HB_ISNUM( 1 ) ? ( HINSTANCE ) HB_PARNL( 1 ) : g_hInstance;
   LPCTSTR   lpMenuName;

   if( HB_ISNUM( 2 ) )
   {
      lpMenuName = MAKEINTRESOURCE( ( WORD ) hb_parnl( 2 ) );

      hMenu = LoadMenu( hInstance, lpMenuName );
   }
   else if( HB_ISCHAR( 2 ) )
   {
#ifndef __XHARBOUR__
      void * hMenuName;
      lpMenuName = HB_PARSTR( 2, &hMenuName, NULL );
#else
      LPCTSTR lpMenuName = ( LPCTSTR ) hb_parc( 2 );
#endif
      hMenu = LoadMenu( hInstance, lpMenuName );
#ifndef __XHARBOUR__
      hb_strfree( hMenuName );
#endif
   }

   HB_RETNL( ( LONG_PTR ) hMenu );
}

HB_FUNC( _NEWMENUSTYLE )
{
   if( HB_ISLOG( 1 ) )
      s_bCustomDraw = hb_parl( 1 );

   hb_retl( s_bCustomDraw );
}

HB_FUNC( _CLOSEMENU )
{
   hb_retl( ( BOOL ) EndMenu() );
}

HB_FUNC( TRACKPOPUPMENU )
{
   HWND hwnd = ( HWND ) HB_PARNL( 4 );

   SetForegroundWindow( hwnd );            /* hack for Microsoft "feature" */

   TrackPopupMenu( ( HMENU ) HB_PARNL( 1 ), 0, hb_parni( 2 ), hb_parni( 3 ), 0, hwnd, NULL );

   if( hb_pcount() > 4 && HB_ISLOG( 5 ) && hb_parl( 5 ) )
   {
      PostMessage( hwnd, WM_NULL, 0, 0 );  /* hack for tray menu closing */
   }
}

HB_FUNC( SETMENU )
{
   SetMenu( ( HWND ) HB_PARNL( 1 ), ( HMENU ) HB_PARNL( 2 ) );
}

HB_FUNC( XCHECKMENUITEM )
{
   CheckMenuItem( ( HMENU ) HB_PARNL( 1 ), hb_parni( 2 ), MF_CHECKED );
}

HB_FUNC( XUNCHECKMENUITEM )
{
   CheckMenuItem( ( HMENU ) HB_PARNL( 1 ), hb_parni( 2 ), MF_UNCHECKED );
}

HB_FUNC( XENABLEMENUITEM )
{
   EnableMenuItem( ( HMENU ) HB_PARNL( 1 ), hb_parni( 2 ), MF_ENABLED );
}

HB_FUNC( XDISABLEMENUITEM )
{
   EnableMenuItem( ( HMENU ) HB_PARNL( 1 ), hb_parni( 2 ), MF_GRAYED );
}

HB_FUNC( XDISABLECLOSEBUTTON )
{
   EnableMenuItem( GetSystemMenu( ( HWND ) HB_PARNL( 1 ), FALSE ), SC_CLOSE, MF_BYCOMMAND | ( hb_parl( 2 ) ? MF_ENABLED : MF_GRAYED ) );
}

HB_FUNC( CREATEMENU )
{
   HMENU hMenu = CreateMenu();

   #ifndef __WINNT__
   if( s_bCustomDraw )
      SetMenuBarColor( hMenu, clrMenuBar1, TRUE );
   #endif

   HB_RETNL( ( LONG_PTR ) hMenu );
}

HB_FUNC( CREATEPOPUPMENU )
{
   HMENU menu = CreatePopupMenu();

   HB_RETNL( ( LONG_PTR ) menu );
}

HB_FUNC( APPENDMENUSTRING )
{
   UINT Style;

   if( s_bCustomDraw )
   {
      LPMENUITEM lpMenuItem;
      UINT       cch = hb_strnlen( hb_parc( 3 ), 255 );

      lpMenuItem = ( LPMENUITEM ) hb_xgrab( ( sizeof( MENUITEM ) ) );
      ZeroMemory( lpMenuItem, sizeof( MENUITEM ) );

      lpMenuItem->cbSize     = hb_parni( 2 );
      lpMenuItem->uiID       = hb_parni( 2 );
      lpMenuItem->caption    = hb_strndup( hb_parc( 3 ), cch );
      lpMenuItem->cch        = cch;
      lpMenuItem->hBitmap    = ( HBITMAP ) NULL;
      lpMenuItem->hFont      = ( HFONT ) NULL;
      lpMenuItem->uiItemType = hb_parni( 4 );
      lpMenuItem->hwnd       = ( HWND ) NULL;

      switch( hb_parni( 4 ) )
      {
         case 1:
            Style = MF_OWNERDRAW | MF_MENUBREAK;
            break;
         case 2:
            Style = MF_OWNERDRAW | MF_MENUBARBREAK;
            break;
         default:
            Style = MF_OWNERDRAW;
      }
      hb_retl( AppendMenu( ( HMENU ) HB_PARNL( 1 ), Style, hb_parni( 2 ), ( LPTSTR ) lpMenuItem ) );
   }
   else
   {
      switch( hb_parni( 4 ) )
      {
         case 1:
            Style = MF_STRING | MF_MENUBREAK; break;
         case 2:
            Style = MF_STRING | MF_MENUBARBREAK; break;
         default:
            Style = MF_STRING;
      }
      hb_retl( AppendMenu( ( HMENU ) HB_PARNL( 1 ), Style, hb_parni( 2 ), hb_parc( 3 ) ) );
   }
}

HB_FUNC( APPENDMENUPOPUP )
{
   if( s_bCustomDraw )
   {
      LPMENUITEM lpMenuItem;
      UINT       cch = hb_strnlen( hb_parc( 3 ), 255 );

      lpMenuItem = ( LPMENUITEM ) hb_xgrabz( ( sizeof( MENUITEM ) ) );

      lpMenuItem->cbSize     = hb_parni( 2 );
      lpMenuItem->uiID       = hb_parni( 2 );
      lpMenuItem->caption    = hb_strndup( hb_parc( 3 ), cch );
      lpMenuItem->cch        = cch;
      lpMenuItem->hBitmap    = ( HBITMAP ) NULL;
      lpMenuItem->hFont      = ( HFONT ) HB_PARNL( 5 );
      lpMenuItem->uiItemType = hb_parni( 4 );

      hb_retl( AppendMenu( ( HMENU ) HB_PARNL( 1 ), MF_POPUP | MF_OWNERDRAW, hb_parni( 2 ), ( LPTSTR ) lpMenuItem ) );
   }
   else
      hb_retl( AppendMenu( ( HMENU ) HB_PARNL( 1 ), MF_POPUP | MF_STRING, hb_parni( 2 ), hb_parc( 3 ) ) );
}

HB_FUNC( APPENDMENUSEPARATOR )
{
   if( s_bCustomDraw )
   {
      LPMENUITEM lpMenuItem = ( LPMENUITEM ) hb_xgrabz( ( sizeof( MENUITEM ) ) );

      lpMenuItem->uiItemType = 1000;

      hb_retl( AppendMenu( ( HMENU ) HB_PARNL( 1 ), MF_SEPARATOR | MF_OWNERDRAW, 0, ( LPTSTR ) lpMenuItem ) );
   }
   else
      hb_retl( AppendMenu( ( HMENU ) HB_PARNL( 1 ), MF_SEPARATOR, 0, NULL ) );
}

HB_FUNC( MODIFYMENUITEM )
{
   hb_retl( ModifyMenu( ( HMENU ) HB_PARNL( 1 ), hb_parni( 2 ), MF_BYCOMMAND | MF_STRING, hb_parni( 3 ), hb_parc( 4 ) ) );
}

HB_FUNC( INSERTMENUITEM )
{
   hb_retl( InsertMenu( ( HMENU ) HB_PARNL( 1 ), hb_parni( 2 ), MF_BYCOMMAND | MF_STRING, hb_parni( 3 ), hb_parc( 4 ) ) );
}

HB_FUNC( REMOVEMENUITEM )
{
   hb_retl( RemoveMenu( ( HMENU ) HB_PARNL( 1 ), hb_parni( 2 ), MF_BYCOMMAND ) );
}

HB_FUNC( MENUITEM_SETBITMAPS )
{
   HBITMAP himage1;

   himage1 = ( HBITMAP ) LoadImage( g_hInstance, hb_parc( 3 ), IMAGE_BITMAP, 0, 0, LR_DEFAULTCOLOR );
   if( himage1 == NULL )
      himage1 = ( HBITMAP ) LoadImage( 0, hb_parc( 3 ), IMAGE_BITMAP, 0, 0, LR_LOADFROMFILE | LR_DEFAULTCOLOR );

   if( s_bCustomDraw )
   {
      MENUITEMINFO MenuItemInfo;
      MENUITEM *   pMENUITEM;

      MenuItemInfo.cbSize = sizeof( MENUITEMINFO );
      MenuItemInfo.fMask  = MIIM_DATA;

      if( GetMenuItemInfo( ( HMENU ) HB_PARNL( 1 ), hb_parni( 2 ), FALSE, &MenuItemInfo ) )
      {
         pMENUITEM = ( MENUITEM * ) MenuItemInfo.dwItemData;
         if( pMENUITEM->hBitmap != NULL )
            DeleteObject( pMENUITEM->hBitmap );

         pMENUITEM->hBitmap = himage1;
      }
   }
   else
   {
      HBITMAP himage2;
      himage2 = ( HBITMAP ) LoadImage( g_hInstance, hb_parc( 4 ), IMAGE_BITMAP, 0, 0, LR_DEFAULTCOLOR );
      if( himage2 == NULL )
         himage2 = ( HBITMAP ) LoadImage( 0, hb_parc( 4 ), IMAGE_BITMAP, 0, 0, LR_LOADFROMFILE | LR_DEFAULTCOLOR );

      SetMenuItemBitmaps( ( HMENU ) HB_PARNL( 1 ), hb_parni( 2 ), MF_BYCOMMAND, himage1, himage2 );
   }
   HB_RETNL( ( LONG_PTR ) himage1 );
}

HB_FUNC( MENUITEM_SETCHECKMARKS )
{
   if( s_bCustomDraw )
   {
      MENUITEMINFO MenuItemInfo;
      HBITMAP      himage1;
      HBITMAP      himage2;

      himage1 = ( HBITMAP ) LoadImage( g_hInstance, hb_parc( 3 ), IMAGE_BITMAP, 0, 0, LR_DEFAULTCOLOR );
      if( himage1 == NULL )
         himage1 = ( HBITMAP ) LoadImage( 0, hb_parc( 3 ), IMAGE_BITMAP, 0, 0, LR_LOADFROMFILE | LR_DEFAULTCOLOR );
      {
         himage2 = ( HBITMAP ) LoadImage( g_hInstance, hb_parc( 4 ), IMAGE_BITMAP, 0, 0, LR_DEFAULTCOLOR );
         if( himage2 == NULL )
            himage2 = ( HBITMAP ) LoadImage( 0, hb_parc( 4 ), IMAGE_BITMAP, 0, 0, LR_LOADFROMFILE | LR_DEFAULTCOLOR );
      }

      MenuItemInfo.cbSize = sizeof( MENUITEMINFO );
      MenuItemInfo.fMask  = MIIM_CHECKMARKS;

      if( GetMenuItemInfo( ( HMENU ) HB_PARNL( 1 ), hb_parni( 2 ), FALSE, &MenuItemInfo ) )
      {
         if( MenuItemInfo.hbmpChecked != NULL )
            DeleteObject( MenuItemInfo.hbmpChecked );

         MenuItemInfo.hbmpChecked = himage1;

         if( MenuItemInfo.hbmpUnchecked != NULL )
            DeleteObject( MenuItemInfo.hbmpUnchecked );

         MenuItemInfo.hbmpUnchecked = himage2;

         SetMenuItemInfo( ( HMENU ) HB_PARNL( 1 ), hb_parni( 2 ), FALSE, &MenuItemInfo );
      }
   }
}

HB_FUNC( MENUITEM_SETICON )
{
   HBITMAP himage1;
   HICON   hIcon;

   hIcon = ( HICON ) LoadImage( g_hInstance, hb_parc( 3 ), IMAGE_ICON, 0, 0, LR_DEFAULTSIZE | LR_DEFAULTCOLOR );
   if( hIcon == NULL )
      hIcon = ( HICON ) LoadImage( 0, hb_parc( 3 ), IMAGE_ICON, 0, 0, LR_LOADFROMFILE | LR_DEFAULTCOLOR );

   // convert icon to bitmap
   himage1 = Icon2Bmp( hIcon );

   if( s_bCustomDraw )
   {
      MENUITEMINFO MenuItemInfo;
      LPMENUITEM   lpMenuItem;

      MenuItemInfo.cbSize = sizeof( MENUITEMINFO );
      MenuItemInfo.fMask  = MIIM_DATA;

      if( GetMenuItemInfo( ( HMENU ) HB_PARNL( 1 ), hb_parni( 2 ), FALSE, &MenuItemInfo ) )
      {
         lpMenuItem = ( LPMENUITEM ) MenuItemInfo.dwItemData;
         if( lpMenuItem->hBitmap != NULL )
            DeleteObject( lpMenuItem->hBitmap );

         lpMenuItem->hBitmap = himage1;
      }
   }
   else
      SetMenuItemBitmaps( ( HMENU ) HB_PARNL( 1 ), hb_parni( 2 ), MF_BYCOMMAND, himage1, himage1 );

   HB_RETNL( ( LONG_PTR ) himage1 );
}

HB_FUNC( MENUITEM_SETFONT )
{
   if( s_bCustomDraw )
   {
      MENUITEMINFO MenuItemInfo;
      LPMENUITEM   lpMenuItem;

      MenuItemInfo.cbSize = sizeof( MENUITEMINFO );
      MenuItemInfo.fMask  = MIIM_DATA;

      if( GetMenuItemInfo( ( HMENU ) HB_PARNL( 1 ), hb_parni( 2 ), FALSE, &MenuItemInfo ) )
      {
         lpMenuItem = ( LPMENUITEM ) MenuItemInfo.dwItemData;

         if( GetObjectType( ( HGDIOBJ ) HB_PARNL( 3 ) ) == OBJ_FONT )
         {
            if( lpMenuItem->hFont != NULL )
               DeleteObject( lpMenuItem->hFont );

            lpMenuItem->hFont = ( HFONT ) HB_PARNL( 3 );
         }
      }
   }
}

HB_FUNC( XGETMENUCAPTION )
{
   if( s_bCustomDraw )
   {
      MENUITEMINFO MenuItemInfo;
      MENUITEM *   lpMenuItem;

      MenuItemInfo.cbSize = sizeof( MENUITEMINFO );
      MenuItemInfo.fMask  = MIIM_DATA;
      GetMenuItemInfo( ( HMENU ) HB_PARNL( 1 ), hb_parni( 2 ), FALSE, &MenuItemInfo );

      lpMenuItem = ( MENUITEM * ) MenuItemInfo.dwItemData;

      if( lpMenuItem->caption != NULL )
         hb_retclen( lpMenuItem->caption, lpMenuItem->cch );
      else
         hb_retc( "" );
   }
}

HB_FUNC( XSETMENUCAPTION )
{
   if( s_bCustomDraw )
   {
      MENUITEMINFO MenuItemInfo;
      MENUITEM *   lpMenuItem;

      MenuItemInfo.cbSize = sizeof( MENUITEMINFO );
      MenuItemInfo.fMask  = MIIM_DATA;
      GetMenuItemInfo( ( HMENU ) HB_PARNL( 1 ), hb_parni( 2 ), FALSE, &MenuItemInfo );

      lpMenuItem = ( MENUITEM * ) MenuItemInfo.dwItemData;

      if( lpMenuItem->caption != NULL )
      {
         UINT cch = hb_strnlen( hb_parc( 3 ), 255 );

         hb_retclen( lpMenuItem->caption, lpMenuItem->cch );

         hb_xfree( lpMenuItem->caption );

         lpMenuItem->cch     = cch;
         lpMenuItem->caption = hb_strndup( hb_parc( 3 ), cch );
      }
      else
         hb_retc( "" );
   }
}

HB_FUNC( XGETMENUCHECKSTATE )
{
   UINT state;

   state = GetMenuState( ( HMENU ) HB_PARNL( 1 ), hb_parni( 2 ), MF_BYCOMMAND );

   if( state != 0xFFFFFFFF )
      hb_retl( ( state & MF_CHECKED ) ? TRUE : FALSE );
   else
      hb_retl( FALSE );
}

HB_FUNC( XGETMENUENABLEDSTATE )
{
   UINT state;

   state = GetMenuState( ( HMENU ) HB_PARNL( 1 ), hb_parni( 2 ), MF_BYCOMMAND );

   if( state != 0xFFFFFFFF )
      hb_retl( ( ( state & MF_GRAYED ) || ( state & MF_DISABLED ) ) ? FALSE : TRUE );
   else
      hb_retl( FALSE );
}

HB_FUNC( ISMENU )
{
   hb_retl( IsMenu( ( HMENU ) HB_PARNL( 1 ) ) );
}

HB_FUNC( GETMENU )
{
   HB_RETNL( ( LONG_PTR ) GetMenu( ( HWND ) HB_PARNL( 1 ) ) );
}

HB_FUNC( GETSYSTEMMENU )
{
   HB_RETNL( ( LONG_PTR ) GetSystemMenu( ( HWND ) HB_PARNL( 1 ), FALSE ) );
}

HB_FUNC( GETMENUITEMCOUNT )
{
   hb_retni( GetMenuItemCount( ( HMENU ) HB_PARNL( 1 ) ) );
}


/*
 * Owner draw function
 */

/*
 * ODA_DRAWENTIRE - This bit is set when the entire control needs to be drawn.
 * ODA_FOCUS - This bit is set when the control gains or loses input focus. The itemState member should be checked to determine whether the control has focus.
 * ODA_SELECT - This bit is set when only the selection status has changed. The itemState member should be checked to determine the new selection state.
 *
 * Owner draw state
 *
 * ODS_CHECKED - This bit is set if the menu item is to be checked. This bit is used only in a menu.
 * ODS_DISABLED - This bit is set if the item is to be drawn as disabled.
 * ODS_FOCUS - This bit is set if the item has input focus.
 * ODS_GRAYED - This bit is set if the item is to be dimmed. This bit is used only in a menu.
 * ODS_SELECTED - This bit is set if the item's status is selected.
 * ODS_COMBOBOXEDIT - The drawing takes place in the selection field (edit control) of an ownerdrawn combo box.
 * ODS_DEFAULT - The item is the default item.
 */

HB_FUNC( _ONDRAWMENUITEM )
{
   LPDRAWITEMSTRUCT lpdis;
   MENUITEM *       lpMenuItem;
   INT      iLen;
   COLORREF clrText, clrBackground;
   UINT     bkMode;
   BOOL     fSelected = FALSE;
   BOOL     fGrayed   = FALSE;
   BOOL     fChecked  = FALSE;

   HFONT oldfont;

   lpdis      = ( LPDRAWITEMSTRUCT ) HB_PARNL( 1 );
   lpMenuItem = ( MENUITEM * ) lpdis->itemData;

   if( lpdis->CtlType != ODT_MENU )
      return;

   // draw SEPARATOR
   if( lpdis->itemID == 0 )
   {
      DrawSeparator( lpdis->hDC, lpdis->rcItem );
      return;
   }

   if( lpMenuItem->hFont != NULL )
      oldfont = ( HFONT ) SelectObject( lpdis->hDC, lpMenuItem->hFont );
   else
      oldfont = ( HFONT ) SelectObject( lpdis->hDC, GetStockObject( DEFAULT_GUI_FONT ) );

   // save prev. colours state
   clrText       = SetTextColor( lpdis->hDC, clrText1 );
   clrBackground = SetBkColor( lpdis->hDC, clrBk1 );
   bkMode        = SetBkMode( lpdis->hDC, TRANSPARENT );

   // set colours and flags ( fSelected etc. )
   if( ( ( lpdis->itemAction & ODA_SELECT ) || ( lpdis->itemAction & ODA_DRAWENTIRE ) ) && ( ! ( lpdis->itemState & ODS_GRAYED ) ) )
   {
      if( lpdis->itemState & ODS_SELECTED )
      {
         clrText       = SetTextColor( lpdis->hDC, ( lpMenuItem->uiItemType != 1 ) ? clrSelectedText1 : clrMenuBarSelectedText );
         clrBackground = SetBkColor( lpdis->hDC, ( lpMenuItem->uiItemType != 1 ) ? clrSelectedBk1 : clrMenuBar1 );
         fSelected     = TRUE;
      }
      else
      {
         clrText       = SetTextColor( lpdis->hDC, ( lpMenuItem->uiItemType != 1 ) ? clrText1 : clrMenuBarText );
         clrBackground = SetBkColor( lpdis->hDC, ( lpMenuItem->uiItemType != 1 ) ? clrBk2 : clrMenuBar2 );
         fSelected     = FALSE;
      }
   }

   if( lpdis->itemState & ODS_GRAYED )
   {
      clrText = SetTextColor( lpdis->hDC, ( lpMenuItem->uiItemType != 1 ) ? clrGrayedText1 : clrMenuBarGrayedText );
      fGrayed = TRUE;
   }

   if( lpdis->itemState & ODS_CHECKED )
      fChecked = TRUE;

   // draw menu item bitmap background
   if( lpMenuItem->uiItemType != 1 )
      DrawBitmapBK( lpdis->hDC, lpdis->rcItem );

   //draw menu item background
   DrawItemBk( lpdis->hDC, lpdis->rcItem, fSelected, fGrayed, lpMenuItem->uiItemType, ( ( lpMenuItem->hBitmap == NULL ) && ( ! fChecked ) ) );

   // draw menu item border
   if( fSelected && ( ! fGrayed ) )
      DrawSelectedItemBorder
      (
         lpdis->hDC,
         lpdis->rcItem,
         lpMenuItem->uiItemType,
         ( ( lpMenuItem->hBitmap == NULL ) && ( ! fChecked ) )
      );

   // draw bitmap
   if( ( lpMenuItem->hBitmap != NULL ) && ( ! fChecked ) )
   {
      DrawGlyph
      (
         lpdis->hDC,
         lpdis->rcItem.left + cx_delta - 2,
         lpdis->rcItem.top + cy_delta,
         bm_size,
         bm_size,
         lpMenuItem->hBitmap,
         ( COLORREF ) RGB( 125, 125, 125 ),
         ( ( fGrayed ) ? TRUE : FALSE ),
         TRUE
      );

      if( fSelected && ( lpMenuItem->uiItemType != 1 ) && ( eMenuCursorType == Short ) && bSelectedItemBorder3d )
      {
         HPEN pen, pen1, oldPen;
         RECT rect;

         pen  = CreatePen( PS_SOLID, ( UINT ) 1, clrSelectedItemBorder2 );
         pen1 = CreatePen( PS_SOLID, ( UINT ) 1, clrSelectedItemBorder4 );

         oldPen = ( HPEN ) SelectObject( lpdis->hDC, pen1 );

         CopyRect( &rect, &lpdis->rcItem );
         rect.left  += ( cx_delta / 2 - 2 );
         rect.top   += ( cy_delta / 2 );
         rect.right  = rect.left + bm_size + cx_delta;
         rect.bottom = rect.top + bm_size + cy_delta;

         MoveToEx( lpdis->hDC, rect.left, rect.top, NULL );

         LineTo( lpdis->hDC, rect.right, rect.top );
         SelectObject( lpdis->hDC, pen );
         LineTo( lpdis->hDC, rect.right, rect.bottom );
         LineTo( lpdis->hDC, rect.left, rect.bottom );
         SelectObject( lpdis->hDC, pen1 );
         LineTo( lpdis->hDC, rect.left, rect.top );

         SelectObject( lpdis->hDC, oldPen );

         DeleteObject( pen );
         DeleteObject( pen1 );
      }
   }

   // draw menu item text
   iLen = hb_strnlen( lpMenuItem->caption, 255 );

   if( lpMenuItem->uiItemType == 1 )
      DrawText( lpdis->hDC, lpMenuItem->caption, iLen, &lpdis->rcItem, DT_CENTER | DT_VCENTER | DT_SINGLELINE | DT_END_ELLIPSIS | DT_EXPANDTABS );
   else
   {
      lpdis->rcItem.left += ( min_width + cx_delta + 2 );
      DrawText( lpdis->hDC, lpMenuItem->caption, iLen, &lpdis->rcItem, DT_LEFT | DT_VCENTER | DT_SINGLELINE | DT_END_ELLIPSIS | DT_EXPANDTABS );
      lpdis->rcItem.left -= ( min_width + cx_delta + 2 );
   }

   // draw menu item checked mark
   if( fChecked )
   {
      MENUITEMINFO MenuItemInfo;
      SIZE         size;

      MenuItemInfo.cbSize = sizeof( MENUITEMINFO );
      MenuItemInfo.fMask  = MIIM_CHECKMARKS;
      GetMenuItemInfo( ( HMENU ) lpdis->hwndItem, lpdis->itemID, FALSE, &MenuItemInfo );

      size.cx = bm_size;      //GetSystemMetrics(SM_CXMENUCHECK);
      size.cy = bm_size;      //GetSystemMetrics(SM_CYMENUCHECK);
      DrawCheck( lpdis->hDC, size, lpdis->rcItem, fGrayed, fSelected, MenuItemInfo.hbmpChecked );
   }

   SelectObject( lpdis->hDC, oldfont );

   // restore prev. colours state
   SetTextColor( lpdis->hDC, clrText );
   SetBkColor( lpdis->hDC, clrBackground );
   SetBkMode( lpdis->hDC, bkMode );
}

VOID DrawSeparator( HDC hDC, RECT r )
{
   HPEN pen, oldPen;
   RECT rect;

   CopyRect( &rect, &r );
   rect.right = rect.left + min_width + cx_delta / 2;

   if( ( EnabledGradient() ) && ( ! IsColorEqual( clrImageBk1, clrImageBk2 ) ) )
      FillGradient( hDC, &rect, FALSE, clrImageBk1, clrImageBk2 );
   else
   {
      HBRUSH brush = CreateSolidBrush( clrImageBk1 );
      FillRect( hDC, &rect, brush );
      DeleteObject( brush );
   }

   CopyRect( &rect, &r );
   rect.left += ( min_width + cx_delta / 2 );

   if( ( EnabledGradient() ) && ( ! IsColorEqual( clrBk1, clrBk2 ) ) )
      FillGradient( hDC, &rect, FALSE, clrBk1, clrBk2 );
   else
   {
      HBRUSH brush = CreateSolidBrush( clrBk1 );
      FillRect( hDC, &rect, brush );
      DeleteObject( brush );
   }

   CopyRect( &rect, &r );

   pen    = CreatePen( PS_SOLID, ( UINT ) 1, clrSeparator1 );
   oldPen = ( HPEN ) SelectObject( hDC, pen );

   if( eSeparatorPosition == Right )
      rect.left += ( min_width + cx_delta + 2 );
   else if( eSeparatorPosition == Middle )
   {
      rect.left  += ( min_width - cx_delta );
      rect.right -= ( min_width - cx_delta );
   }

   rect.top += ( rect.bottom - rect.top ) / 2;
   MoveToEx( hDC, rect.left, rect.top, NULL );
   LineTo( hDC, rect.right, rect.top );

   if( eSeparatorType == Double )
   {
      HPEN pen1, oldPen1;
      pen1    = CreatePen( PS_SOLID, ( UINT ) 1, clrSeparator2 );
      oldPen1 = ( HPEN ) SelectObject( hDC, pen1 );

      rect.top += 1;
      MoveToEx( hDC, rect.left, rect.top, NULL );
      LineTo( hDC, rect.right, rect.top );

      SelectObject( hDC, oldPen1 );
      DeleteObject( pen1 );
   }

   SelectObject( hDC, oldPen );
   DeleteObject( pen );
}

VOID DrawBitmapBK( HDC hDC, RECT r )
{
   RECT rect;

   CopyRect( &rect, &r );
   rect.right = rect.left + min_width + cx_delta / 2;

   if( ( EnabledGradient() ) && ( ! IsColorEqual( clrImageBk1, clrImageBk2 ) ) )
      FillGradient( hDC, &rect, FALSE, clrImageBk1, clrImageBk2 );
   else
   {
      HBRUSH brush = CreateSolidBrush( clrImageBk1 );
      FillRect( hDC, &rect, brush );
      DeleteObject( brush );
   }
}

VOID DrawItemBk( HDC hDC, RECT r, BOOL Selected, BOOL Grayed, UINT itemType, BOOL clear )
{
   RECT rect;

   CopyRect( &rect, &r );
   if( ( ! Selected ) && ( itemType != 1 ) )
      rect.left += ( min_width + cx_delta / 2 );

   if( ( Selected ) && ( itemType != 1 ) && ( eMenuCursorType == Short ) && ( ! clear ) )
      rect.left += ( min_width + cx_delta / 2 );

   if( ! Grayed )
   {
      if( Selected )
      {
         if( EnabledGradient() )
            FillGradient
            (
               hDC,
               &rect,
               ( itemType == 1 ) ? TRUE : gradientVertical,
               ( itemType == 1 ) ? clrSelectedMenuBarItem1 : clrSelectedBk1,
               ( itemType == 1 ) ? clrSelectedMenuBarItem2 : clrSelectedBk2
            );
         else
         {
            HBRUSH brush = CreateSolidBrush( ( itemType == 1 ) ? clrSelectedMenuBarItem1 : clrSelectedBk1 );
            FillRect( hDC, &rect, brush );
            DeleteObject( brush );
         }
      }
      else
      {
         if( EnabledGradient() && ( ! IsColorEqual( clrMenuBar1, clrMenuBar2 ) ||
                                    ( ! IsColorEqual( clrBk1, clrBk2 ) && ( itemType != 1 ) ) ) )
            FillGradient
            (
               hDC,
               &rect,
               ( ( itemType == 1 ) ? TRUE : FALSE ),
               ( ( itemType == 1 ) ? clrMenuBar1 : clrBk1 ),
               ( ( itemType == 1 ) ? clrMenuBar2 : clrBk2 )
            );
         else
         {
            HBRUSH brush = CreateSolidBrush( ( itemType == 1 ) ? clrMenuBar1 : clrBk1 );
            FillRect( hDC, &rect, brush );
            DeleteObject( brush );
         }
      }
   }
   else
   {
      if( EnabledGradient() )
         FillGradient( hDC, &rect, FALSE, clrGrayedBk1, clrGrayedBk2 );
      else
      {
         HBRUSH brush = CreateSolidBrush( clrGrayedBk1 );
         FillRect( hDC, &rect, brush );
         DeleteObject( brush );
      }
   }
}

VOID DrawSelectedItemBorder( HDC hDC, RECT r, UINT itemType, BOOL clear )
{
   HPEN pen, pen1, oldPen;
   RECT rect;

   if( itemType != 1 )
   {
      pen  = CreatePen( PS_SOLID, ( UINT ) 1, clrSelectedItemBorder1 );
      pen1 = CreatePen( PS_SOLID, ( UINT ) 1, clrSelectedItemBorder3 );
   }
   else
   {
      pen  = CreatePen( PS_SOLID, ( UINT ) 1, clrSelectedItemBorder2 );
      pen1 = CreatePen( PS_SOLID, ( UINT ) 1, clrSelectedItemBorder4 );
   }

   oldPen = ( HPEN ) SelectObject( hDC, pen );

   CopyRect( &rect, &r );
   if( ( eMenuCursorType == Short ) && ( itemType != 1 ) && ( ! clear ) )
      rect.left += ( min_width + cx_delta / 2 );

   InflateRect( &rect, -1, -1 );

   MoveToEx( hDC, rect.left, rect.top, NULL );

   if( ( itemType == 1 ) && bSelectedItemBorder3d )
   {
      LineTo( hDC, rect.right, rect.top );
      SelectObject( hDC, pen1 );
      LineTo( hDC, rect.right, rect.bottom );
      LineTo( hDC, rect.left, rect.bottom );
      SelectObject( hDC, pen );
      LineTo( hDC, rect.left, rect.top );
   }
   else
   {
      LineTo( hDC, rect.right, rect.top );
      LineTo( hDC, rect.right, rect.bottom );
      LineTo( hDC, rect.left, rect.bottom );
      LineTo( hDC, rect.left, rect.top );
   }

   SelectObject( hDC, oldPen );
   DeleteObject( pen );
   DeleteObject( pen1 );
}

VOID DrawCheck( HDC hdc, SIZE size, RECT rect, BOOL disabled, BOOL selected, HBITMAP hbitmap )
{
   if( hbitmap != 0 )
      DrawGlyph
      (
         hdc,
         rect.left + cx_delta / 2,
         rect.top + cy_delta / 2 + 2,
         size.cx,
         size.cy,
         hbitmap,
         ( COLORREF ) RGB( 125, 125, 125 ),
         ( ( disabled ) ? TRUE : FALSE ),
         TRUE
      );
   else
   {
      HPEN   pen, oldPen;
      HBRUSH brush, oldBrush;
      UINT   x, y, w, h;

      if( ( selected ) && ( eMenuCursorType != Short ) )
         brush = CreateSolidBrush( clrSelectedBk1 );
      else
         brush = CreateSolidBrush( clrCheckMarkBk );

      oldBrush = ( HBRUSH ) SelectObject( hdc, brush );

      pen    = CreatePen( PS_SOLID, ( UINT ) 1, clrCheckMarkSq );
      oldPen = ( HPEN ) SelectObject( hdc, pen );

      w = ( size.cx > min_width ? min_width : size.cx );
      h = w;
      x = rect.left + ( min_width - w ) / 2;
      y = rect.top + ( min_height + cy_delta - h ) / 2;

      Rectangle( hdc, x, y, x + w, y + h );

      DeleteObject( pen );

      if( disabled )
         pen = CreatePen( PS_SOLID, ( UINT ) 1, clrCheckMarkGr );
      else
         pen = CreatePen( PS_SOLID, ( UINT ) 1, clrCheckMark );

      SelectObject( hdc, pen );

      MoveToEx( hdc, x + 1, y + 5, NULL );
      LineTo( hdc, x + 4, y + h - 2 );
      MoveToEx( hdc, x + 2, y + 5, NULL );
      LineTo( hdc, x + 4, y + h - 3 );
      MoveToEx( hdc, x + 2, y + 4, NULL );
      LineTo( hdc, x + 5, y + h - 3 );
      MoveToEx( hdc, x + 4, y + h - 3, NULL );
      LineTo( hdc, x + w + 2, y - 1 );
      MoveToEx( hdc, x + 4, y + h - 2, NULL );
      LineTo( hdc, x + w - 2, y + 3 );

      SelectObject( hdc, oldPen );
      SelectObject( hdc, oldBrush );

      DeleteObject( pen );
      DeleteObject( brush );
   }
}

/*
 * Misc
 */

HB_FUNC( SETMENUBITMAPHEIGHT )
{
   bm_size    = hb_parni( 1 );
   min_height = min_width = bm_size + 4;
   hb_retni( bm_size );
}

HB_FUNC( GETMENUBITMAPHEIGHT )
{
   hb_retni( bm_size );
}

HB_FUNC( SETMENUSEPARATORTYPE )
{
   eSeparatorType     = ( SEPARATORTYPE ) hb_parni( 1 );
   eSeparatorPosition = ( SEPARATORPOSITION ) hb_parni( 2 );
}

HB_FUNC( SETMENUSELECTEDITEM3D )
{
   bSelectedItemBorder3d = ( BOOL ) hb_parl( 1 );
}

HB_FUNC( SETMENUCURSORTYPE )
{
   eMenuCursorType = ( MENUCURSORTYPE ) hb_parni( 1 );
}

/*
 * Color Management of HMG menus
 */

#ifndef __WINNT__
VOID SetMenuBarColor( HMENU hMenu, COLORREF clrBk, BOOL fSubMenu )
{
   MENUINFO MenuInfo;

   MenuInfo.cbSize = sizeof( MENUINFO );
   GetMenuInfo( hMenu, &MenuInfo );

   MenuInfo.fMask = MIM_BACKGROUND;
   if( fSubMenu )
      MenuInfo.fMask |= MIM_APPLYTOSUBMENUS;

   MenuInfo.hbrBack = CreateSolidBrush( clrBk );
   SetMenuInfo( hMenu, &MenuInfo );
}
#endif

static BOOL IsColorEqual( COLORREF clr1, COLORREF clr2 )
{
   return ( ( GetRValue( clr1 ) == GetRValue( clr2 ) ) && ( GetGValue( clr1 ) == GetGValue( clr2 ) ) &&
            ( GetBValue( clr1 ) == GetBValue( clr2 ) ) ) ? TRUE : FALSE;
}

HB_FUNC( GETMENUCOLORS )
{
   PHB_ITEM aResult = hb_itemArrayNew( 28 );

   HB_arraySetNL( aResult, 1, clrMenuBar1 );
   HB_arraySetNL( aResult, 2, clrMenuBar2 );
   HB_arraySetNL( aResult, 3, clrMenuBarText );
   HB_arraySetNL( aResult, 4, clrMenuBarSelectedText );
   HB_arraySetNL( aResult, 5, clrMenuBarGrayedText );
   HB_arraySetNL( aResult, 6, clrSelectedMenuBarItem1 );
   HB_arraySetNL( aResult, 7, clrSelectedMenuBarItem2 );
   HB_arraySetNL( aResult, 8, clrText1 );
   HB_arraySetNL( aResult, 9, clrSelectedText1 );
   HB_arraySetNL( aResult, 10, clrGrayedText1 );
   HB_arraySetNL( aResult, 11, clrBk1 );
   HB_arraySetNL( aResult, 12, clrBk2 );
   HB_arraySetNL( aResult, 13, clrSelectedBk1 );
   HB_arraySetNL( aResult, 14, clrSelectedBk2 );
   HB_arraySetNL( aResult, 15, clrGrayedBk1 );
   HB_arraySetNL( aResult, 16, clrGrayedBk2 );
   HB_arraySetNL( aResult, 17, clrImageBk1 );
   HB_arraySetNL( aResult, 18, clrImageBk2 );
   HB_arraySetNL( aResult, 19, clrSeparator1 );
   HB_arraySetNL( aResult, 20, clrSeparator2 );
   HB_arraySetNL( aResult, 21, clrSelectedItemBorder1 );
   HB_arraySetNL( aResult, 22, clrSelectedItemBorder2 );
   HB_arraySetNL( aResult, 23, clrSelectedItemBorder3 );
   HB_arraySetNL( aResult, 24, clrSelectedItemBorder4 );
   HB_arraySetNL( aResult, 25, clrCheckMark );
   HB_arraySetNL( aResult, 26, clrCheckMarkBk );
   HB_arraySetNL( aResult, 27, clrCheckMarkSq );
   HB_arraySetNL( aResult, 28, clrCheckMarkGr );

   hb_itemReturnRelease( aResult );
}

HB_FUNC( SETMENUCOLORS )
{
   PHB_ITEM pArray = hb_param( 1, HB_IT_ARRAY );

   if( ( pArray != NULL ) && ( hb_arrayLen( pArray ) >= 28 ) )
   {
      clrMenuBar1             = ( COLORREF ) HB_PARVNL( 1, 1 );
      clrMenuBar2             = ( COLORREF ) HB_PARVNL( 1, 2 );
      clrMenuBarText          = ( COLORREF ) HB_PARVNL( 1, 3 );
      clrMenuBarSelectedText  = ( COLORREF ) HB_PARVNL( 1, 4 );
      clrMenuBarGrayedText    = ( COLORREF ) HB_PARVNL( 1, 5 );
      clrSelectedMenuBarItem1 = ( COLORREF ) HB_PARVNL( 1, 6 );
      clrSelectedMenuBarItem2 = ( COLORREF ) HB_PARVNL( 1, 7 );
      clrText1         = ( COLORREF ) HB_PARVNL( 1, 8 );
      clrSelectedText1 = ( COLORREF ) HB_PARVNL( 1, 9 );
      clrGrayedText1   = ( COLORREF ) HB_PARVNL( 1, 10 );
      clrBk1                 = ( COLORREF ) HB_PARVNL( 1, 11 );
      clrBk2                 = ( COLORREF ) HB_PARVNL( 1, 12 );
      clrSelectedBk1         = ( COLORREF ) HB_PARVNL( 1, 13 );
      clrSelectedBk2         = ( COLORREF ) HB_PARVNL( 1, 14 );
      clrGrayedBk1           = ( COLORREF ) HB_PARVNL( 1, 15 );
      clrGrayedBk2           = ( COLORREF ) HB_PARVNL( 1, 16 );
      clrImageBk1            = ( COLORREF ) HB_PARVNL( 1, 17 );
      clrImageBk2            = ( COLORREF ) HB_PARVNL( 1, 18 );
      clrSeparator1          = ( COLORREF ) HB_PARVNL( 1, 19 );
      clrSeparator2          = ( COLORREF ) HB_PARVNL( 1, 20 );
      clrSelectedItemBorder1 = ( COLORREF ) HB_PARVNL( 1, 21 );
      clrSelectedItemBorder2 = ( COLORREF ) HB_PARVNL( 1, 22 );
      clrSelectedItemBorder3 = ( COLORREF ) HB_PARVNL( 1, 23 );
      clrSelectedItemBorder4 = ( COLORREF ) HB_PARVNL( 1, 24 );
      clrCheckMark           = ( COLORREF ) HB_PARVNL( 1, 25 );
      clrCheckMarkBk         = ( COLORREF ) HB_PARVNL( 1, 26 );
      clrCheckMarkSq         = ( COLORREF ) HB_PARVNL( 1, 27 );
      clrCheckMarkGr         = ( COLORREF ) HB_PARVNL( 1, 28 );
   }
}

/*
 * Call this funtions on WM_DESTROY, WM_MEASUREITEM of menu owner window
 */

HB_FUNC( _ONDESTROYMENU )
{
   HMENU menu = ( HMENU ) HB_PARNL( 1 );

   if( IsMenu( menu ) )
   {
      HB_BOOL bResult = _DestroyMenu( menu );

#ifdef _ERRORMSG_
      if( ! bResult )
      {
         MessageBox( NULL, "Menu is not destroyed successfully", "Warning", MB_OK | MB_ICONWARNING );
      }
#endif
      if( hb_pcount() > 1 && hb_parl( 2 ) )
      {
         bResult = bResult && DestroyMenu( menu );
      }

      hb_retl( bResult );
   }
   else
   {
      hb_errRT_BASE_SubstR( EG_ARG, 0, "MiniGUI Err.", HB_ERR_FUNCNAME, 1, hb_paramError( 1 ) );
   }
}

static BOOL _DestroyMenu( HMENU menu )
{
   int  i;
   BOOL bResult = TRUE;

   for( i = 0; i < GetMenuItemCount( menu ); i++ )
   {
      MENUITEMINFO MenuItemInfo;
      HMENU        pSubMenu;

      MenuItemInfo.cbSize = sizeof( MENUITEMINFO );
      MenuItemInfo.fMask  = MIIM_CHECKMARKS | MIIM_DATA;

      GetMenuItemInfo( menu, i, TRUE, &MenuItemInfo );

      if( MenuItemInfo.hbmpChecked != NULL )
      {
         bResult = DeleteObject( MenuItemInfo.hbmpChecked );
         MenuItemInfo.hbmpChecked = NULL;
      }

      if( MenuItemInfo.hbmpUnchecked != NULL )
      {
         bResult = bResult && DeleteObject( MenuItemInfo.hbmpUnchecked );
         MenuItemInfo.hbmpUnchecked = NULL;
      }

      if( s_bCustomDraw )
      {
         LPMENUITEM lpMenuItem;
         lpMenuItem = ( LPMENUITEM ) MenuItemInfo.dwItemData;

         if( lpMenuItem->caption != NULL )
         {
            hb_xfree( lpMenuItem->caption );
            lpMenuItem->caption = NULL;
         }

         if( lpMenuItem->hBitmap != NULL )
         {
            bResult = bResult && DeleteObject( lpMenuItem->hBitmap );
            lpMenuItem->hBitmap = NULL;
         }

         if( GetObjectType( ( HGDIOBJ ) lpMenuItem->hFont ) == OBJ_FONT )
         {
            bResult = bResult && DeleteObject( lpMenuItem->hFont );
            lpMenuItem->hFont = NULL;
         }

         hb_xfree( lpMenuItem );
      }

      pSubMenu = GetSubMenu( menu, i );

      if( pSubMenu != NULL )
      {
         bResult = bResult && _DestroyMenu( pSubMenu );
      }
   }

   return bResult;
}

HB_FUNC( _ONMEASUREMENUITEM )
{
   HWND hwnd = ( HWND ) HB_PARNL( 1 );

   if( IsWindow( hwnd ) )
   {
      HDC hdc = GetDC( hwnd );
      LPMEASUREITEMSTRUCT lpmis      = ( LPMEASUREITEMSTRUCT ) HB_PARNL( 4 );
      MENUITEM *          lpMenuItem = ( MENUITEM * ) lpmis->itemData;
      SIZE  size = { 0, 0 };
      HFONT oldfont;

      if( GetObjectType( ( HGDIOBJ ) lpMenuItem->hFont ) == OBJ_FONT )
      {
         oldfont = ( HFONT ) SelectObject( hdc, lpMenuItem->hFont );
      }
      else
      {
         oldfont = ( HFONT ) SelectObject( hdc, GetStockObject( DEFAULT_GUI_FONT ) );
      }

      if( lpMenuItem->uiItemType == 1000 )
      {
         lpmis->itemHeight = 2 * cy_delta;
         lpmis->itemWidth  = 0;
      }
      else
      {
         GetTextExtentPoint32( hdc, lpMenuItem->caption, lpMenuItem->cch, &size );
      }

      if( lpMenuItem->uiItemType == 1 )
      {
         lpmis->itemWidth = size.cx;
      }
      else if( lpmis->itemID > 0 )
      {
         lpmis->itemWidth = min_width + cx_delta + size.cx + 8;
      }

      if( lpMenuItem->uiItemType != 1000 )
      {
         lpmis->itemHeight  = ( size.cy > min_height ? size.cy : min_height );
         lpmis->itemHeight += cy_delta;
      }

      SelectObject( hdc, oldfont );

      ReleaseDC( hwnd, hdc );
   }
   else
   {
      hb_errRT_BASE_SubstR( EG_ARG, 0, "MiniGUI Err.", HB_ERR_FUNCNAME, 1, hb_paramError( 1 ) );
   }
}
