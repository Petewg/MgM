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

#define _WIN32_IE  0x0501

#include <mgdefs.h>
#include <commctrl.h>

extern HINSTANCE g_hInstance;

HB_FUNC( INITTREE )
{
   INITCOMMONCONTROLSEX icex;

   HWND hWndTV;
   UINT mask;

   if( hb_parni( 9 ) != 0 ) //Tree+
      mask = 0x0000;
   else
      mask = TVS_LINESATROOT;

   icex.dwSize = sizeof( INITCOMMONCONTROLSEX );
   icex.dwICC  = ICC_TREEVIEW_CLASSES;
   InitCommonControlsEx( &icex );

   hWndTV = CreateWindowEx
            (
      WS_EX_CLIENTEDGE,
      WC_TREEVIEW,
      "",
      WS_VISIBLE | WS_TABSTOP | WS_CHILD | TVS_HASLINES | TVS_HASBUTTONS | mask | TVS_SHOWSELALWAYS,
      hb_parni( 2 ),
      hb_parni( 3 ),
      hb_parni( 4 ),
      hb_parni( 5 ),
      ( HWND ) HB_PARNL( 1 ),
      ( HMENU ) HB_PARNL( 6 ),
      g_hInstance,
      NULL
            );

   HB_RETNL( ( LONG_PTR ) hWndTV );
}

HB_FUNC( INITTREEVIEWBITMAP ) // Tree+
{
   HWND       hbutton;
   HIMAGELIST himl;
   HBITMAP    hbmp;
   PHB_ITEM   hArray;
   char *     caption;
   int        l9;
   int        s;
   int        cx;
   int        cy;

   hbutton = ( HWND ) HB_PARNL( 1 );
   l9      = hb_parinfa( 2, 0 ) - 1;
   hArray  = hb_param( 2, HB_IT_ARRAY );

   cx = 0;
   if( l9 != 0 )
   {
      caption = ( char * ) hb_arrayGetCPtr( hArray, 1 );

      himl = ImageList_LoadImage( g_hInstance, caption, 0, l9, CLR_NONE, IMAGE_BITMAP, LR_LOADTRANSPARENT );

      if( himl == NULL )
         himl = ImageList_LoadImage( 0, caption, 0, l9, CLR_NONE, IMAGE_BITMAP, LR_LOADTRANSPARENT | LR_LOADFROMFILE );

      ImageList_GetIconSize( himl, &cx, &cy );

      for( s = 1; s <= l9; s = s + 1 )
      {
         caption = ( char * ) hb_arrayGetCPtr( hArray, s + 1 );

         hbmp = ( HBITMAP ) LoadImage( g_hInstance, caption, IMAGE_BITMAP, cx, cy, LR_LOADTRANSPARENT );
         if( hbmp == NULL )
            hbmp = ( HBITMAP ) LoadImage( 0, caption, IMAGE_BITMAP, cx, cy, LR_LOADTRANSPARENT | LR_LOADFROMFILE );

         ImageList_Add( himl, hbmp, NULL );
         DeleteObject( hbmp );
      }

      if( himl != NULL )
         SendMessage( hbutton, TVM_SETIMAGELIST, ( WPARAM ) TVSIL_NORMAL, ( LPARAM ) himl );
   }

   hb_retni( ( INT ) cx );
}

HB_FUNC( ADDTREEVIEWBITMAP )  // Tree+
{
   HWND       hbutton;
   HIMAGELIST himl;
   HBITMAP    hbmp;

   int cx;
   int cy;
   int ic;

   hbutton = ( HWND ) HB_PARNL( 1 );
   himl    = TreeView_GetImageList( hbutton, TVSIL_NORMAL );
   ic      = 0;

   if( himl != NULL )
   {
      ImageList_GetIconSize( himl, &cx, &cy );

      hbmp = ( HBITMAP ) LoadImage( g_hInstance, hb_parc( 2 ), IMAGE_BITMAP, cx, cy, LR_LOADTRANSPARENT );
      if( hbmp == NULL )
         hbmp = ( HBITMAP ) LoadImage( 0, hb_parc( 2 ), IMAGE_BITMAP, cx, cy, LR_LOADTRANSPARENT | LR_LOADFROMFILE );

      ImageList_Add( himl, hbmp, NULL );
      DeleteObject( hbmp );

      SendMessage( hbutton, TVM_SETIMAGELIST, ( WPARAM ) TVSIL_NORMAL, ( LPARAM ) himl );
      ic = ImageList_GetImageCount( himl );
   }

   hb_retni( ( INT ) ic );
}

HB_FUNC( ADDTREEITEM )
{
   HWND hWndTV = ( HWND ) HB_PARNL( 1 );

   HTREEITEM hPrev = ( HTREEITEM ) HB_PARNL( 2 );
   HTREEITEM hRet;

   TV_ITEM tvi;
   TV_INSERTSTRUCT is;

   tvi.mask = TVIF_TEXT | TVIF_IMAGE | TVIF_SELECTEDIMAGE | TVIF_PARAM;

   tvi.pszText        = ( LPSTR ) hb_parc( 3 );
   tvi.cchTextMax     = 1024;
   tvi.iImage         = hb_parni( 4 );
   tvi.iSelectedImage = hb_parni( 5 );
   tvi.lParam         = hb_parni( 6 );

   #if ( defined( __BORLANDC__ ) && __BORLANDC__ <= 1410 )
   is.DUMMYUNIONNAME.item = tvi;
   #else
   is.item = tvi;
   #endif
   if( hPrev == 0 )
   {
      is.hInsertAfter = hPrev;
      is.hParent      = NULL;
   }
   else
   {
      is.hInsertAfter = TVI_LAST;
      is.hParent      = hPrev;
   }

   hRet = TreeView_InsertItem( hWndTV, &is );

   HB_RETNL( ( LONG_PTR ) hRet );
}

HB_FUNC( TREEVIEW_GETSELECTION )
{
   HWND      TreeHandle;
   HTREEITEM ItemHandle;

   TreeHandle = ( HWND ) HB_PARNL( 1 );

   ItemHandle = TreeView_GetSelection( TreeHandle );

   HB_RETNL( ( LONG_PTR ) ItemHandle );
}

HB_FUNC( TREEVIEW_SELECTITEM )
{
   HWND      TreeHandle;
   HTREEITEM ItemHandle;

   TreeHandle = ( HWND ) HB_PARNL( 1 );
   ItemHandle = ( HTREEITEM ) HB_PARNL( 2 );

   TreeView_SelectItem( TreeHandle, ItemHandle );
}

HB_FUNC( TREEVIEW_DELETEITEM )
{
   HWND      TreeHandle;
   HTREEITEM ItemHandle;

   TreeHandle = ( HWND ) HB_PARNL( 1 );
   ItemHandle = ( HTREEITEM ) HB_PARNL( 2 );

   TreeView_DeleteItem( TreeHandle, ItemHandle );
}

HB_FUNC( TREEVIEW_DELETEALLITEMS )
{
   HWND TreeHandle;

   TreeHandle = ( HWND ) HB_PARNL( 1 );

   TreeView_DeleteAllItems( TreeHandle );
}

HB_FUNC( TREEVIEW_GETCOUNT )
{
   HWND TreeHandle;

   TreeHandle = ( HWND ) HB_PARNL( 1 );

   hb_retni( TreeView_GetCount( TreeHandle ) );
}

HB_FUNC( TREEVIEW_GETPREVSIBLING )
{
   HWND      TreeHandle;
   HTREEITEM ItemHandle;
   HTREEITEM PrevItemHandle;

   TreeHandle = ( HWND ) HB_PARNL( 1 );
   ItemHandle = ( HTREEITEM ) HB_PARNL( 2 );

   PrevItemHandle = TreeView_GetPrevSibling( TreeHandle, ItemHandle );

   HB_RETNL( ( LONG_PTR ) PrevItemHandle );
}

HB_FUNC( TREEVIEW_GETITEM )
{
   HWND      TreeHandle;
   HTREEITEM TreeItemHandle;
   TV_ITEM   TreeItem;
   char      ItemText[ 256 ];

   memset( &TreeItem, 0, sizeof( TV_ITEM ) );

   TreeHandle     = ( HWND ) HB_PARNL( 1 );
   TreeItemHandle = ( HTREEITEM ) HB_PARNL( 2 );

   TreeItem.mask  = TVIF_HANDLE | TVIF_TEXT;
   TreeItem.hItem = TreeItemHandle;

   TreeItem.pszText    = ItemText;
   TreeItem.cchTextMax = 256;

   TreeView_GetItem( TreeHandle, &TreeItem );

   hb_retc( ItemText );
}

HB_FUNC( TREEVIEW_SETITEM )
{
   HWND      TreeHandle;
   HTREEITEM TreeItemHandle;
   TV_ITEM   TreeItem;
   char      ItemText[ 256 ];

   memset( &TreeItem, 0, sizeof( TV_ITEM ) );

   TreeHandle     = ( HWND ) HB_PARNL( 1 );
   TreeItemHandle = ( HTREEITEM ) HB_PARNL( 2 );
   strcpy( ItemText, hb_parc( 3 ) );

   TreeItem.mask  = TVIF_HANDLE | TVIF_TEXT;
   TreeItem.hItem = TreeItemHandle;

   TreeItem.pszText    = ItemText;
   TreeItem.cchTextMax = 256;

   TreeView_SetItem( TreeHandle, &TreeItem );
}

HB_FUNC( TREEITEM_SETIMAGEINDEX )
{
   HWND      TreeHandle = ( HWND ) HB_PARNL( 1 );
   HTREEITEM ItemHandle = ( HTREEITEM ) HB_PARNL( 2 );
   TV_ITEM   TreeItem;

   TreeItem.mask           = TVIF_IMAGE | TVIF_SELECTEDIMAGE;
   TreeItem.hItem          = ItemHandle;
   TreeItem.iImage         = hb_parni( 3 );
   TreeItem.iSelectedImage = hb_parni( 4 );

   TreeView_SetItem( TreeHandle, &TreeItem );
}

HB_FUNC( TREEVIEW_GETSELECTIONID )
{
   HWND      TreeHandle;
   HTREEITEM ItemHandle;
   TV_ITEM   TreeItem;

   TreeHandle = ( HWND ) HB_PARNL( 1 );
   ItemHandle = TreeView_GetSelection( TreeHandle );

   memset( &TreeItem, 0, sizeof( TV_ITEM ) );

   TreeItem.mask  = TVIF_HANDLE | TVIF_PARAM;
   TreeItem.hItem = ItemHandle;

   TreeView_GetItem( TreeHandle, &TreeItem );

   hb_retnl( TreeItem.lParam );
}

HB_FUNC( TREEVIEW_GETNEXTSIBLING )
{
   HWND      TreeHandle;
   HTREEITEM ItemHandle;
   HTREEITEM NextItemHandle;

   TreeHandle = ( HWND ) HB_PARNL( 1 );
   ItemHandle = ( HTREEITEM ) HB_PARNL( 2 );

   NextItemHandle = TreeView_GetNextSibling( TreeHandle, ItemHandle );

   HB_RETNL( ( LONG_PTR ) NextItemHandle );
}

HB_FUNC( TREEVIEW_GETCHILD )
{
   HWND      TreeHandle;
   HTREEITEM ItemHandle;
   HTREEITEM ChildItemHandle;

   TreeHandle = ( HWND ) HB_PARNL( 1 );
   ItemHandle = ( HTREEITEM ) HB_PARNL( 2 );

   ChildItemHandle = TreeView_GetChild( TreeHandle, ItemHandle );

   HB_RETNL( ( LONG_PTR ) ChildItemHandle );
}

HB_FUNC( TREEVIEW_GETPARENT )
{
   HWND      TreeHandle;
   HTREEITEM ItemHandle;
   HTREEITEM ParentItemHandle;

   TreeHandle = ( HWND ) HB_PARNL( 1 );
   ItemHandle = ( HTREEITEM ) HB_PARNL( 2 );

   ParentItemHandle = TreeView_GetParent( TreeHandle, ItemHandle );

   HB_RETNL( ( LONG_PTR ) ParentItemHandle );
}
