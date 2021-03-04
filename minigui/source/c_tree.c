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

#define _WIN32_IE  0x0501

#include <mgdefs.h>
#include <commctrl.h>

HIMAGELIST HMG_ImageListLoadFirst( const char * FileName, int cGrow, int Transparent, int * nWidth, int * nHeight );
void HMG_ImageListAdd( HIMAGELIST himl, char * FileName, int Transparent );

#ifdef UNICODE
   LPWSTR AnsiToWide( LPCSTR );
   LPSTR  WideToAnsi( LPWSTR );
#endif
HINSTANCE GetInstance( void );
HINSTANCE GetResources( void );

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
      TEXT( "" ),
      WS_VISIBLE | WS_TABSTOP | WS_CHILD | TVS_HASLINES | TVS_HASBUTTONS | mask | TVS_SHOWSELALWAYS,
      hb_parni( 2 ),
      hb_parni( 3 ),
      hb_parni( 4 ),
      hb_parni( 5 ),
      ( HWND ) HB_PARNL( 1 ),
      ( HMENU ) HB_PARNL( 6 ),
      GetInstance(),
      NULL
            );

   HB_RETNL( ( LONG_PTR ) hWndTV );
}

HB_FUNC( INITTREEVIEWBITMAP ) // Tree+
{
   HWND       hbutton = ( HWND ) HB_PARNL( 1 );
   HIMAGELIST himl    = ( HIMAGELIST ) NULL;
   PHB_ITEM   hArray;
   char *     FileName;
   int        ic = 0;
   int        nCount;
   int        s;

   nCount = ( int ) hb_parinfa( 2, 0 );

   if( nCount > 0 )
   {
      int Transparent = hb_parl( 3 ) ? 0 : 1;
      hArray = hb_param( 2, HB_IT_ARRAY );

      for( s = 1; s <= nCount; s++ )
      {
         FileName = ( char * ) hb_arrayGetCPtr( hArray, s );

         if( himl == NULL )
            himl = HMG_ImageListLoadFirst( FileName, nCount, Transparent, NULL, NULL );
         else
            HMG_ImageListAdd( himl, FileName, Transparent );
      }

      if( himl != NULL )
         SendMessage( hbutton, TVM_SETIMAGELIST, ( WPARAM ) TVSIL_NORMAL, ( LPARAM ) himl );

      ic = ImageList_GetImageCount( himl );
   }

   hb_retni( ( INT ) ic );
}

HB_FUNC( ADDTREEVIEWBITMAP )  // Tree+
{
   HWND       hbutton = ( HWND ) HB_PARNL( 1 );
   HIMAGELIST himl;
   int        Transparent = hb_parl( 3 ) ? 0 : 1;
   int        ic = 0;

   himl = TreeView_GetImageList( hbutton, TVSIL_NORMAL );

   if( himl != NULL )
   {
      HMG_ImageListAdd( himl, ( char * ) hb_parc( 2 ), Transparent );

      SendMessage( hbutton, TVM_SETIMAGELIST, ( WPARAM ) TVSIL_NORMAL, ( LPARAM ) himl );

      ic = ImageList_GetImageCount( himl );
   }

   hb_retni( ( INT ) ic );
}

#define MAX_ITEM_TEXT  256

typedef struct
{
   HTREEITEM ItemHandle;
   LONG      nID;
   BOOL      IsNodeFlag;
} HMG_StructTreeItemLPARAM;

void AddTreeItemLPARAM( HWND hWndTV, HTREEITEM ItemHandle, LONG nID, BOOL IsNodeFlag )
{
   TV_ITEM TV_Item;

   if( ( hWndTV != NULL ) && ( ItemHandle != NULL ) )
   {
      HMG_StructTreeItemLPARAM * TreeItemLPARAM = ( HMG_StructTreeItemLPARAM * ) hb_xgrab( sizeof( HMG_StructTreeItemLPARAM ) );
      TreeItemLPARAM->ItemHandle = ItemHandle;
      TreeItemLPARAM->nID        = nID;
      TreeItemLPARAM->IsNodeFlag = IsNodeFlag;

      TV_Item.mask   = TVIF_PARAM;
      TV_Item.hItem  = ( HTREEITEM ) ItemHandle;
      TV_Item.lParam = ( LPARAM ) TreeItemLPARAM;
      TreeView_SetItem( hWndTV, &TV_Item );
   }
}

HB_FUNC( ADDTREEITEM )
{
   HWND hWndTV = ( HWND ) HB_PARNL( 1 );

   HTREEITEM hPrev = ( HTREEITEM ) HB_PARNL( 2 );
   HTREEITEM hRet;
#ifndef UNICODE
   LPSTR  lpText = ( LPSTR ) hb_parc( 3 );
#else
   LPWSTR lpText = AnsiToWide( ( char * ) hb_parc( 3 ) );
#endif

   TV_ITEM tvi;
   TV_INSERTSTRUCT is;

   LONG nID        = ( LONG ) hb_parnl( 6 );
   BOOL IsNodeFlag = ( BOOL ) hb_parl( 7 );

   tvi.mask = TVIF_TEXT | TVIF_IMAGE | TVIF_SELECTEDIMAGE | TVIF_PARAM;

   tvi.pszText        = lpText;
   tvi.cchTextMax     = 1024;
   tvi.iImage         = hb_parni( 4 );
   tvi.iSelectedImage = hb_parni( 5 );
   tvi.lParam         = nID;

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

   AddTreeItemLPARAM( hWndTV, hRet, nID, IsNodeFlag );

   HB_RETNL( ( LONG_PTR ) hRet );
}

HB_FUNC( TREEVIEW_GETSELECTION )
{
   HWND      TreeHandle;
   HTREEITEM ItemHandle;

   TreeHandle = ( HWND ) HB_PARNL( 1 );

   ItemHandle = TreeView_GetSelection( TreeHandle );

   if( ItemHandle != NULL )
   {
      HB_RETNL( ( LONG_PTR ) ItemHandle );
   }
}

HB_FUNC( TREEVIEW_SELECTITEM )
{
   HWND      TreeHandle;
   HTREEITEM ItemHandle;

   TreeHandle = ( HWND ) HB_PARNL( 1 );
   ItemHandle = ( HTREEITEM ) HB_PARNL( 2 );

   TreeView_SelectItem( TreeHandle, ItemHandle );
}

void TreeView_FreeMemoryLPARAMRecursive( HWND hWndTV, HTREEITEM ItemHandle )
{
   HMG_StructTreeItemLPARAM * TreeItemLPARAM;
   TV_ITEM   TreeItem;
   HTREEITEM ChildItem;
   HTREEITEM NextItem;

   TreeItem.mask   = TVIF_PARAM;
   TreeItem.hItem  = ItemHandle;
   TreeItem.lParam = ( LPARAM ) NULL;
   TreeView_GetItem( hWndTV, &TreeItem );

   TreeItemLPARAM = ( HMG_StructTreeItemLPARAM * ) TreeItem.lParam;
   if( TreeItemLPARAM != NULL )
   {
      hb_xfree( TreeItemLPARAM );
      TreeItem.lParam = ( LPARAM ) NULL;      // for security set lParam = NULL
      TreeView_SetItem( hWndTV, &TreeItem );
   }

   ChildItem = TreeView_GetChild( hWndTV, ItemHandle );
   while( ChildItem != NULL )
   {
      TreeView_FreeMemoryLPARAMRecursive( hWndTV, ChildItem );
      NextItem  = TreeView_GetNextSibling( hWndTV, ChildItem );
      ChildItem = NextItem;
   }
}

HB_FUNC( TREEVIEW_DELETEITEM )
{
   HWND      TreeHandle;
   HTREEITEM ItemHandle;

   TreeHandle = ( HWND ) HB_PARNL( 1 );
   ItemHandle = ( HTREEITEM ) HB_PARNL( 2 );

   TreeView_FreeMemoryLPARAMRecursive( TreeHandle, ItemHandle );

   TreeView_DeleteItem( TreeHandle, ItemHandle );
}

HB_FUNC( TREEVIEW_DELETEALLITEMS )
{
   HWND    TreeHandle = ( HWND ) HB_PARNL( 1 );
   int     nCount     = ( int ) hb_parinfa( 2, 0 );
   int     i;
   TV_ITEM TreeItem;
   HMG_StructTreeItemLPARAM * TreeItemLPARAM;

   for( i = 1; i <= nCount; i++ )
   {
      TreeItem.mask   = TVIF_PARAM;
      TreeItem.hItem  = ( HTREEITEM ) HB_PARVNL( 2, i );
      TreeItem.lParam = ( LPARAM ) 0;

      TreeView_GetItem( TreeHandle, &TreeItem );

      TreeItemLPARAM = ( HMG_StructTreeItemLPARAM * ) TreeItem.lParam;
      if( TreeItemLPARAM != NULL )
         hb_xfree( TreeItemLPARAM );
   }

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
   TCHAR     ItemText[ MAX_ITEM_TEXT ];
#ifdef UNICODE
   LPSTR pStr;
#endif

   TreeHandle     = ( HWND ) HB_PARNL( 1 );
   TreeItemHandle = ( HTREEITEM ) HB_PARNL( 2 );

   memset( &TreeItem, 0, sizeof( TV_ITEM ) );

   TreeItem.mask  = TVIF_TEXT;
   TreeItem.hItem = TreeItemHandle;

   TreeItem.pszText    = ItemText;
   TreeItem.cchTextMax = MAX_ITEM_TEXT;

   TreeView_GetItem( TreeHandle, &TreeItem );

#ifndef UNICODE
   hb_retc( ItemText );
#else
   pStr = WideToAnsi( ItemText );
   hb_retc( pStr );
   hb_xfree( pStr );
#endif
}

HB_FUNC( TREEVIEW_SETITEM )
{
   HWND      TreeHandle;
   HTREEITEM TreeItemHandle;
   TV_ITEM   TreeItem;
   TCHAR     ItemText[ MAX_ITEM_TEXT ];

   TreeHandle     = ( HWND ) HB_PARNL( 1 );
   TreeItemHandle = ( HTREEITEM ) HB_PARNL( 2 );

   memset( &TreeItem, 0, sizeof( TV_ITEM ) );
#ifdef UNICODE
   lstrcpy( ItemText, AnsiToWide( hb_parc( 3 ) ) );
#else
   lstrcpy( ItemText, hb_parc( 3 ) );
#endif

   TreeItem.mask  = TVIF_TEXT;
   TreeItem.hItem = TreeItemHandle;

   TreeItem.pszText    = ItemText;
   TreeItem.cchTextMax = MAX_ITEM_TEXT;

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
   HMG_StructTreeItemLPARAM * TreeItemLPARAM;

   TreeHandle = ( HWND ) HB_PARNL( 1 );
   ItemHandle = TreeView_GetSelection( TreeHandle );

   if( ItemHandle != NULL )
   {
      TreeItem.mask   = TVIF_PARAM;
      TreeItem.hItem  = ItemHandle;
      TreeItem.lParam = ( LPARAM ) 0;

      TreeView_GetItem( TreeHandle, &TreeItem );

      TreeItemLPARAM = ( HMG_StructTreeItemLPARAM * ) TreeItem.lParam;

      hb_retnl( ( LONG ) TreeItemLPARAM->nID );
   }
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

//**************************************************
//    by  Dr. Claudio Soto  (November 2013)
//**************************************************

HB_FUNC( TREEVIEW_GETITEMSTATE )
{
   HWND      hWndTV     = ( HWND ) HB_PARNL( 1 );
   HTREEITEM ItemHandle = ( HTREEITEM ) HB_PARNL( 2 );
   UINT      StateMask  = ( UINT ) hb_parni( 3 );
   UINT      State      = TreeView_GetItemState( hWndTV, ItemHandle, StateMask );

   hb_retni( ( INT ) State );
}

BOOL TreeView_IsNode( HWND hWndTV, HTREEITEM ItemHandle )
{
   if( TreeView_GetChild( hWndTV, ItemHandle ) != NULL )
      return TRUE;
   else
      return FALSE;
}

//--------------------------------------------------------------------------------------------------------
//   TreeView_ExpandChildrenRecursive ( hWndTV, ItemHandle, nExpand, fRecurse )
//--------------------------------------------------------------------------------------------------------

void TreeView_ExpandChildrenRecursive( HWND hWndTV, HTREEITEM ItemHandle, UINT nExpand )
{
   HTREEITEM ChildItem;
   HTREEITEM NextItem;

   if( TreeView_IsNode( hWndTV, ItemHandle ) )
   {
      TreeView_Expand( hWndTV, ItemHandle, nExpand );
      ChildItem = TreeView_GetChild( hWndTV, ItemHandle );

      while( ChildItem != NULL )
      {
         TreeView_ExpandChildrenRecursive( hWndTV, ChildItem, nExpand );

         NextItem  = TreeView_GetNextSibling( hWndTV, ChildItem );
         ChildItem = NextItem;
      }
   }
}

HB_FUNC( TREEVIEW_EXPANDCHILDRENRECURSIVE )
{
   HWND      hWndTV     = ( HWND ) HB_PARNL( 1 );
   HTREEITEM ItemHandle = ( HTREEITEM ) HB_PARNL( 2 );
   UINT      nExpand    = ( UINT ) hb_parnl( 3 );
   BOOL      fRecurse   = ( BOOL ) hb_parl( 4 );
   HWND      hWndParent = GetParent( hWndTV );
   BOOL      lEnabled   = IsWindowEnabled( hWndParent );

   if( fRecurse == FALSE )
      TreeView_Expand( hWndTV, ItemHandle, nExpand );
   else
   {
      EnableWindow( hWndParent, FALSE );

      TreeView_ExpandChildrenRecursive( hWndTV, ItemHandle, nExpand );

      if( lEnabled == TRUE )
         EnableWindow( hWndParent, TRUE );
   }
}

//---------------------------------------------------------------------------------------------------------------------
// TreeView_SortChildrenRecursiveCB ( hWndTV, ItemHandle, fRecurse, lCaseSensitive, lAscendingOrder, nNodePosition )
//---------------------------------------------------------------------------------------------------------------------

#define SORTTREENODE_FIRST  0
#define SORTTREENODE_LAST   1
#define SORTTREENODE_MIX    2

typedef struct
{
   HWND hWndTV;
   BOOL CaseSensitive;
   BOOL AscendingOrder;
   int  NodePosition;
} HMG_StructTreeViewCompareInfo;

int CALLBACK TreeViewCompareFunc( LPARAM lParam1, LPARAM lParam2, LPARAM lParamSort )
{
   HMG_StructTreeItemLPARAM * TreeItemLPARAM1 = ( HMG_StructTreeItemLPARAM * ) lParam1;
   HMG_StructTreeItemLPARAM * TreeItemLPARAM2 = ( HMG_StructTreeItemLPARAM * ) lParam2;

   HMG_StructTreeViewCompareInfo * TreeViewCompareInfo = ( HMG_StructTreeViewCompareInfo * ) lParamSort;

   HWND hWndTV = TreeViewCompareInfo->hWndTV;

   HTREEITEM ItemHandle1 = ( HTREEITEM ) TreeItemLPARAM1->ItemHandle;
   HTREEITEM ItemHandle2 = ( HTREEITEM ) TreeItemLPARAM2->ItemHandle;

   BOOL IsTreeNode1;
   BOOL IsTreeNode2;
   int  CmpValue;

   TCHAR   ItemText1[ MAX_ITEM_TEXT ];
   TV_ITEM TV_Item1;
   TCHAR   ItemText2[ MAX_ITEM_TEXT ];
   TV_ITEM TV_Item2;

   TV_Item1.mask       = TVIF_TEXT;
   TV_Item1.pszText    = ItemText1;
   TV_Item1.cchTextMax = sizeof( ItemText1 ) / sizeof( TCHAR );
   TV_Item1.hItem      = ( HTREEITEM ) ItemHandle1;
   TreeView_GetItem( hWndTV, &TV_Item1 );

   TV_Item2.mask       = TVIF_TEXT;
   TV_Item2.pszText    = ItemText2;
   TV_Item2.cchTextMax = sizeof( ItemText2 ) / sizeof( TCHAR );
   TV_Item2.hItem      = ( HTREEITEM ) ItemHandle2;
   TreeView_GetItem( hWndTV, &TV_Item2 );

   IsTreeNode1 = ( TreeItemLPARAM1->IsNodeFlag == TRUE || TreeView_GetChild( hWndTV, ItemHandle1 ) != NULL ) ? TRUE : FALSE;
   IsTreeNode2 = ( TreeItemLPARAM2->IsNodeFlag == TRUE || TreeView_GetChild( hWndTV, ItemHandle2 ) != NULL ) ? TRUE : FALSE;

   if( TreeViewCompareInfo->CaseSensitive == FALSE )
      CmpValue = lstrcmpi( ItemText1, ItemText2 );
   else
      CmpValue = lstrcmp( ItemText1, ItemText2 );


   if( TreeViewCompareInfo->AscendingOrder == FALSE )
      CmpValue = CmpValue * ( -1 );

   if( TreeViewCompareInfo->NodePosition == SORTTREENODE_FIRST )
   {
      if( IsTreeNode1 == TRUE && IsTreeNode2 == FALSE )
         return -1;
      if( IsTreeNode1 == FALSE && IsTreeNode2 == TRUE )
         return +1;
   }

   if( TreeViewCompareInfo->NodePosition == SORTTREENODE_LAST )
   {
      if( IsTreeNode1 == TRUE && IsTreeNode2 == FALSE )
         return +1;
      if( IsTreeNode1 == FALSE && IsTreeNode2 == TRUE )
         return -1;
   }

   return CmpValue;
}

void TreeView_SortChildrenRecursiveCB( HWND hWndTV, TVSORTCB TVSortCB )
{
   HTREEITEM ChildItem;
   HTREEITEM NextItem;

   if( TreeView_IsNode( hWndTV, TVSortCB.hParent ) )
   {
      TreeView_SortChildrenCB( hWndTV, &TVSortCB, 0 );
      ChildItem = TreeView_GetChild( hWndTV, TVSortCB.hParent );

      while( ChildItem != NULL )
      {
         TVSortCB.hParent = ( HTREEITEM ) ChildItem;
         TreeView_SortChildrenRecursiveCB( hWndTV, TVSortCB );

         NextItem  = TreeView_GetNextSibling( hWndTV, ChildItem );
         ChildItem = NextItem;
      }
   }
}

HB_FUNC( TREEVIEW_SORTCHILDRENRECURSIVECB )
{
   HWND      hWndTV          = ( HWND ) HB_PARNL( 1 );
   HTREEITEM ItemHandle      = ( HTREEITEM ) HB_PARNL( 2 );
   BOOL      fRecurse        = ( BOOL ) hb_parl( 3 );
   BOOL      lCaseSensitive  = ( BOOL ) hb_parl( 4 );
   BOOL      lAscendingOrder = ( BOOL ) hb_parl( 5 );
   INT       nNodePosition   = ( INT ) hb_parnl( 6 );
   HWND      hWndParent      = GetParent( hWndTV );
   BOOL      lEnabled        = IsWindowEnabled( hWndParent );

   TVSORTCB TVSortCB;
   HMG_StructTreeViewCompareInfo TreeViewCompareInfo;

   TreeViewCompareInfo.hWndTV         = hWndTV;
   TreeViewCompareInfo.CaseSensitive  = lCaseSensitive;
   TreeViewCompareInfo.AscendingOrder = lAscendingOrder;
   TreeViewCompareInfo.NodePosition   = nNodePosition;

   TVSortCB.hParent     = ( HTREEITEM ) ItemHandle;
   TVSortCB.lpfnCompare = ( PFNTVCOMPARE ) TreeViewCompareFunc;
   TVSortCB.lParam      = ( LPARAM ) &TreeViewCompareInfo;

   if( fRecurse == FALSE )
      TreeView_SortChildrenCB( hWndTV, &TVSortCB, 0 );
   else
   {
      EnableWindow( hWndParent, FALSE );

      TreeView_SortChildrenRecursiveCB( hWndTV, TVSortCB );

      if( lEnabled == TRUE )
         EnableWindow( hWndParent, TRUE );
   }
}

HB_FUNC( TREEVIEW_GETROOT )
{
   HWND      hWndTV         = ( HWND ) HB_PARNL( 1 );
   HTREEITEM RootItemHandle = TreeView_GetRoot( hWndTV );

   HB_RETNL( ( LONG_PTR ) RootItemHandle );
}

HB_FUNC( TREEITEM_GETID )
{
   HWND      hWndTV     = ( HWND ) HB_PARNL( 1 );
   HTREEITEM ItemHandle = ( HTREEITEM ) HB_PARNL( 2 );

   TV_ITEM TreeItem;

   TreeItem.mask   = TVIF_PARAM;
   TreeItem.hItem  = ItemHandle;
   TreeItem.lParam = ( LPARAM ) 0;

   if( TreeView_GetItem( hWndTV, &TreeItem ) == TRUE )
   {
      HMG_StructTreeItemLPARAM * TreeItemLPARAM = ( HMG_StructTreeItemLPARAM * ) TreeItem.lParam;
      hb_retnl( ( LONG ) TreeItemLPARAM->nID );
   }
}

HB_FUNC( TREEITEM_GETNODEFLAG )
{
   HWND      hWndTV     = ( HWND ) HB_PARNL( 1 );
   HTREEITEM ItemHandle = ( HTREEITEM ) HB_PARNL( 2 );

   HMG_StructTreeItemLPARAM * TreeItemLPARAM;
   TV_ITEM TreeItem;

   TreeItem.mask   = TVIF_PARAM;
   TreeItem.hItem  = ItemHandle;
   TreeItem.lParam = ( LPARAM ) 0;

   TreeView_GetItem( hWndTV, &TreeItem );

   TreeItemLPARAM = ( HMG_StructTreeItemLPARAM * ) TreeItem.lParam;
   hb_retl( ( BOOL ) TreeItemLPARAM->IsNodeFlag );
}
