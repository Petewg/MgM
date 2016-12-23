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
#include "hbapiitm.h"
#include "hbapierr.h"

#ifdef MAKELONG
#undef MAKELONG
#endif
#define MAKELONG( a, b )  ( ( LONG ) ( ( ( WORD ) ( ( DWORD_PTR ) ( a ) & 0xffff ) ) | ( ( ( DWORD ) ( ( WORD ) ( ( DWORD_PTR ) ( b ) & 0xffff ) ) ) << 16 ) ) )

extern BOOL _isValidCtrlClass( HWND, LPCTSTR );

extern HINSTANCE g_hInstance;

HB_FUNC( INITLISTVIEW )
{
   HWND hwnd;
   HWND hbutton;
   int  style;

   INITCOMMONCONTROLSEX i;

   i.dwSize = sizeof( INITCOMMONCONTROLSEX );
   i.dwICC  = ICC_LISTVIEW_CLASSES;
   InitCommonControlsEx( &i );

   hwnd = ( HWND ) HB_PARNL( 1 );

   style = LVS_SHOWSELALWAYS | WS_CHILD | WS_VISIBLE | LVS_REPORT;

   if( ! hb_parl( 9 ) )
      style = style | LVS_SINGLESEL;

   if( ! hb_parl( 12 ) )
      style = style | WS_TABSTOP;

   if( ! hb_parl( 10 ) )
      style = style | LVS_NOCOLUMNHEADER;
   else if( hb_parl( 11 ) )
      style = style | LVS_NOSORTHEADER;

   if( hb_parl( 7 ) )
      style = style | LVS_OWNERDATA;

   hbutton = CreateWindowEx
             (
      WS_EX_CLIENTEDGE,
      WC_LISTVIEW,
      "",
      style,
      hb_parni( 3 ),
      hb_parni( 4 ),
      hb_parni( 5 ),
      hb_parni( 6 ),
      hwnd,
      ( HMENU ) HB_PARNL( 2 ),
      g_hInstance,
      NULL
             );

   if( hb_parl( 7 ) )
      ListView_SetItemCount( hbutton, hb_parni( 8 ) );

   HB_RETNL( ( LONG_PTR ) hbutton );
}

HB_FUNC( LISTVIEW_SETITEMCOUNT )
{
   ListView_SetItemCount( ( HWND ) HB_PARNL( 1 ), hb_parni( 2 ) );
}

HB_FUNC( ADDLISTVIEWBITMAP )        // Grid+
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
         SendMessage( hbutton, LVM_SETIMAGELIST, ( WPARAM ) LVSIL_SMALL, ( LPARAM ) himl );
   }

   hb_retni( ( INT ) cx );
}

HB_FUNC( ADDLISTVIEWBITMAPHEADER )  // Grid+
{
   HWND       hheader;
   HIMAGELIST himl = ( HIMAGELIST ) NULL;
   HBITMAP    hbmp;
   PHB_ITEM   hArray;
   char *     caption;
   int        l9;
   int        s;
   int        cx;
   int        cy;

   hheader = ListView_GetHeader( ( HWND ) HB_PARNL( 1 ) );

   if( hheader )
   {
      l9     = hb_parinfa( 2, 0 ) - 1;
      hArray = hb_param( 2, HB_IT_ARRAY );

      if( l9 != 0 )
      {
         caption = ( char * ) hb_arrayGetCPtr( hArray, 1 );

         // Determine Image Size Based Upon First Image
         himl = ImageList_LoadImage
                (
            g_hInstance,
            caption,
            0,
            l9,
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
               l9,
               CLR_DEFAULT,
               IMAGE_BITMAP,
               LR_LOADTRANSPARENT | LR_LOADFROMFILE | LR_DEFAULTCOLOR | LR_LOADMAP3DCOLORS
                   );

         ImageList_GetIconSize( himl, &cx, &cy );

         ImageList_Destroy( himl );

         himl = ImageList_Create( cx, cy, ILC_COLOR8 | ILC_MASK, l9 + 1, l9 + 1 );

         for( s = 0; s <= l9; s++ )
         {
            caption = ( char * ) hb_arrayGetCPtr( hArray, s + 1 );

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

            ImageList_AddMasked( himl, hbmp, CLR_DEFAULT );
            DeleteObject( hbmp );
         }

         if( himl != NULL )
            SendMessage( hheader, HDM_SETIMAGELIST, 0, ( LPARAM ) himl );
      }
   }

   HB_RETNL( ( LONG_PTR ) himl );
}

HB_FUNC( LISTVIEW_GETFIRSTITEM )
{
   hb_retni( ListView_GetNextItem( ( HWND ) HB_PARNL( 1 ), -1, LVNI_ALL | LVNI_SELECTED ) + 1 );
}

/* code INITLISTVIEWCOLUMNS function was borrowed from ooHG */
HB_FUNC( INITLISTVIEWCOLUMNS )
{
   PHB_ITEM wArray;
   PHB_ITEM hArray;
   PHB_ITEM jArray;

   HWND      hc;
   LV_COLUMN COL;
   int       iLen;
   int       s;
   int       iColumn = 0;

   hc = ( HWND ) HB_PARNL( 1 );

   iLen   = hb_parinfa( 2, 0 ) - 1;
   hArray = hb_param( 2, HB_IT_ARRAY );
   wArray = hb_param( 3, HB_IT_ARRAY );
   jArray = hb_param( 4, HB_IT_ARRAY );

   COL.mask = LVCF_FMT | LVCF_WIDTH | LVCF_TEXT | LVCF_SUBITEM;

   for( s = 0; s <= iLen; s++ )
   {
      COL.fmt      = hb_arrayGetNI( jArray, s + 1 );
      COL.cx       = hb_arrayGetNI( wArray, s + 1 );
      COL.pszText  = ( char * ) hb_arrayGetCPtr( hArray, s + 1 );
      COL.iSubItem = iColumn;
      ListView_InsertColumn( hc, iColumn, &COL );
      if( iColumn == 0 && COL.fmt != LVCFMT_LEFT )
      {
         iColumn++;
         COL.iSubItem = iColumn;
         ListView_InsertColumn( hc, iColumn, &COL );
      }

      iColumn++;
   }

   if( iColumn != s )
      ListView_DeleteColumn( hc, 0 );
}

HB_FUNC( ADDLISTVIEWITEMS )
{
   PHB_ITEM hArray;
   char *   caption;
   LV_ITEM  LI;
   HWND     h;
   int      l;
   int      s;
   int      c;

   h      = ( HWND ) HB_PARNL( 1 );
   l      = hb_parinfa( 2, 0 ) - 1;
   hArray = hb_param( 2, HB_IT_ARRAY );
   c      = ListView_GetItemCount( h );

   caption = ( char * ) hb_arrayGetCPtr( hArray, 1 );

   LI.mask      = LVIF_TEXT | LVIF_IMAGE;
   LI.state     = 0;
   LI.stateMask = 0;
   LI.iImage    = hb_parni( 3 );
   LI.iSubItem  = 0;
   LI.iItem     = c;
   LI.pszText   = caption;
   ListView_InsertItem( h, &LI );

   for( s = 1; s <= l; s = s + 1 )
   {
      caption = ( char * ) hb_arrayGetCPtr( hArray, s + 1 );
      ListView_SetItemText( h, c, s, caption );
   }
}

HB_FUNC( LISTVIEW_SETCURSEL )
{
   ListView_SetItemState( ( HWND ) HB_PARNL( 1 ), ( WPARAM ) hb_parni( 2 ) - 1, LVIS_FOCUSED | LVIS_SELECTED, LVIS_FOCUSED | LVIS_SELECTED );
}

HB_FUNC( LISTVIEWGETMULTISEL )
{
   HWND hwnd = ( HWND ) HB_PARNL( 1 );
   int  i;
   int  n;
   int  j;

   n = SendMessage( hwnd, LVM_GETSELECTEDCOUNT, 0, 0 );

   hb_reta( n );

   i = -1;
   j = 0;

   while( 1 )
   {
      i = ListView_GetNextItem( ( HWND ) HB_PARNL( 1 ), i, LVNI_ALL | LVNI_SELECTED );

      if( i == -1 )
         break;
      else
         j++;

      HB_STORNI( i + 1, -1, j );
   }
}

HB_FUNC( LISTVIEWSETMULTISEL )
{
   PHB_ITEM wArray;

   HWND hwnd = ( HWND ) HB_PARNL( 1 );

   int i;
   int l;
   int n;

   wArray = hb_param( 2, HB_IT_ARRAY );

   l = hb_parinfa( 2, 0 ) - 1;

   n = SendMessage( hwnd, LVM_GETITEMCOUNT, 0, 0 );

   // CLEAR CURRENT SELECTIONS
   for( i = 0; i < n; i++ )
      ListView_SetItemState( hwnd, ( WPARAM ) i, 0, LVIS_FOCUSED | LVIS_SELECTED );

   // SET NEW SELECTIONS
   for( i = 0; i <= l; i++ )
      ListView_SetItemState( hwnd, hb_arrayGetNI( wArray, i + 1 ) - 1, LVIS_FOCUSED | LVIS_SELECTED, LVIS_FOCUSED | LVIS_SELECTED );
}

HB_FUNC( LISTVIEWSETITEM )
{
   PHB_ITEM hArray;
   char *   caption;
   HWND     h;
   int      l;
   int      s;
   int      c;

   h      = ( HWND ) HB_PARNL( 1 );
   l      = hb_parinfa( 2, 0 ) - 1;
   hArray = hb_param( 2, HB_IT_ARRAY );
   c      = hb_parni( 3 ) - 1;

   for( s = 0; s <= l; s = s + 1 )
   {
      caption = ( char * ) hb_arrayGetCPtr( hArray, s + 1 );
      ListView_SetItemText( h, c, s, caption );
   }
}

HB_FUNC( LISTVIEWGETITEM )
{
   char string[ 1024 ] = "";
   HWND h;
   int  s;
   int  c;
   int  l;

   h = ( HWND ) HB_PARNL( 1 );

   c = hb_parni( 2 ) - 1;

   l = hb_parni( 3 );

   hb_reta( l );

   for( s = 0; s <= l - 1; s++ )
   {
      ListView_GetItemText( h, c, s, string, 1024 );
      HB_STORC( string, -1, s + 1 );
   }
}

HB_FUNC( LISTVIEWGETITEMROW )
{
   POINT point;

   ListView_GetItemPosition( ( HWND ) HB_PARNL( 1 ), hb_parni( 2 ), &point );

   hb_retnl( point.y );
}

HB_FUNC( LISTVIEWGETITEMCOUNT )
{
   hb_retnl( ListView_GetItemCount( ( HWND ) HB_PARNL( 1 ) ) );
}

HB_FUNC( SETGRIDCOLUMNHEADER )
{
   LV_COLUMN COL;

   COL.mask    = LVCF_FMT | LVCF_TEXT;
   COL.pszText = ( char * ) hb_parc( 3 );
   COL.fmt     = hb_parni( 4 );

   ListView_SetColumn( ( HWND ) HB_PARNL( 1 ), hb_parni( 2 ) - 1, &COL );
}

HB_FUNC( SETGRIDCOLUMNHEADERIMAGE )
{
   LV_COLUMN COL;
   int       fmt = LVCFMT_IMAGE | LVCFMT_COL_HAS_IMAGES;

   COL.mask = LVCF_FMT | LVCF_IMAGE;

   if( hb_parl( 4 ) )
      fmt = fmt | LVCFMT_BITMAP_ON_RIGHT | LVCFMT_RIGHT;
   else
      fmt = fmt | LVCFMT_LEFT;

   COL.fmt    = fmt;
   COL.iImage = hb_parni( 3 ) - 1;

   ListView_SetColumn( ( HWND ) HB_PARNL( 1 ), hb_parni( 2 ) - 1, &COL );
}

HB_FUNC( LISTVIEWGETCOUNTPERPAGE )
{
   hb_retnl( ListView_GetCountPerPage( ( HWND ) HB_PARNL( 1 ) ) );
}

HB_FUNC( LISTVIEW_ENSUREVISIBLE )
{
   ListView_EnsureVisible( ( HWND ) HB_PARNL( 1 ), hb_parni( 2 ) - 1, 1 );
}

HB_FUNC( SETIMAGELISTVIEWITEMS )
{
   LV_ITEM LI;
   HWND    h;

   h = ( HWND ) HB_PARNL( 1 );

   LI.mask      = LVIF_IMAGE;
   LI.state     = 0;
   LI.stateMask = 0;
   LI.iImage    = hb_parni( 3 );
   LI.iSubItem  = 0;
   LI.iItem     = hb_parni( 2 ) - 1;

   ListView_SetItem( h, &LI );
}

HB_FUNC( GETIMAGELISTVIEWITEMS )
{
   LV_ITEM LI;
   HWND    h;
   int     i;

   h = ( HWND ) HB_PARNL( 1 );

   LI.mask      = LVIF_IMAGE;
   LI.state     = 0;
   LI.stateMask = 0;
   LI.iSubItem  = 0;
   LI.iItem     = hb_parni( 2 ) - 1;

   ListView_GetItem( h, &LI );
   i = LI.iImage;

   hb_retni( i );
}

HB_FUNC( LISTVIEW_GETTOPINDEX )
{
   hb_retnl( ListView_GetTopIndex( ( HWND ) HB_PARNL( 1 ) ) );
}

HB_FUNC( LISTVIEW_REDRAWITEMS )
{
   hb_retnl( ListView_RedrawItems( ( HWND ) HB_PARNL( 1 ), hb_parni( 2 ), hb_parni( 3 ) ) );
}

HB_FUNC( LISTVIEW_HITTEST )
{
   POINT point;
   LVHITTESTINFO lvhti;

   point.y = hb_parni( 2 );
   point.x = hb_parni( 3 );

   lvhti.pt = point;

   if( hb_parni( 4 ) )  // checkbox area.
   {
      ListView_HitTest( ( HWND ) HB_PARNL( 1 ), &lvhti );

      if( lvhti.flags & LVHT_ONITEMSTATEICON )
         hb_retl( 1 );
      else
         hb_retl( 0 );
   }
   else  // item area.
   {
      ListView_SubItemHitTest( ( HWND ) HB_PARNL( 1 ), &lvhti );

      if( lvhti.flags & LVHT_ONITEM )
      {
         hb_reta( 2 );
         HB_STORNI( lvhti.iItem + 1, -1, 1 );
         HB_STORNI( lvhti.iSubItem + 1, -1, 2 );
      }
      else
      {
         hb_reta( 2 );
         HB_STORNI( 0, -1, 1 );
         HB_STORNI( 0, -1, 2 );
      }
   }
}

HB_FUNC( LISTVIEW_GETSUBITEMRECT )
{
   RECT * pRect;

   pRect = ( RECT * ) hb_xgrab( sizeof( RECT ) );

   ListView_GetSubItemRect( ( HWND ) HB_PARNL( 1 ), hb_parni( 2 ), hb_parni( 3 ), LVIR_BOUNDS, pRect );

   hb_reta( 4 );
   HB_STORNI( pRect->top, -1, 1 );
   HB_STORNI( pRect->left, -1, 2 );
   HB_STORNI( pRect->right - pRect->left, -1, 3 );
   HB_STORNI( pRect->bottom - pRect->top, -1, 4 );

   hb_xfree( ( void * ) pRect );
}

HB_FUNC( LISTVIEW_GETITEMRECT )
{
   RECT * pRect;

   pRect = ( RECT * ) hb_xgrab( sizeof( RECT ) );

   ListView_GetItemRect( ( HWND ) HB_PARNL( 1 ), hb_parni( 2 ), pRect, LVIR_LABEL );

   hb_reta( 4 );
   HB_STORNI( pRect->top, -1, 1 );
   HB_STORNI( pRect->left, -1, 2 );
   HB_STORNI( pRect->right - pRect->left, -1, 3 );
   HB_STORNI( pRect->bottom - pRect->top, -1, 4 );

   hb_xfree( ( void * ) pRect );
}

HB_FUNC( LISTVIEW_UPDATE )
{
   ListView_Update( ( HWND ) HB_PARNL( 1 ), hb_parni( 2 ) - 1 );
}

HB_FUNC( LISTVIEW_SCROLL )
{
   ListView_Scroll( ( HWND ) HB_PARNL( 1 ), hb_parni( 2 ), hb_parni( 3 ) );
}

HB_FUNC( LISTVIEW_SETBKCOLOR )
{
   ListView_SetBkColor( ( HWND ) HB_PARNL( 1 ), ( COLORREF ) RGB( hb_parni( 2 ), hb_parni( 3 ), hb_parni( 4 ) ) );
}

HB_FUNC( LISTVIEW_SETTEXTBKCOLOR )
{
   ListView_SetTextBkColor( ( HWND ) HB_PARNL( 1 ), ( COLORREF ) RGB( hb_parni( 2 ), hb_parni( 3 ), hb_parni( 4 ) ) );
}

HB_FUNC( LISTVIEW_SETTEXTCOLOR )
{
   ListView_SetTextColor( ( HWND ) HB_PARNL( 1 ), ( COLORREF ) RGB( hb_parni( 2 ), hb_parni( 3 ), hb_parni( 4 ) ) );
}

HB_FUNC( LISTVIEW_GETTEXTCOLOR )
{
   hb_retnl( ListView_GetTextColor( ( HWND ) HB_PARNL( 1 ) ) );
}

HB_FUNC( LISTVIEW_GETBKCOLOR )
{
   hb_retnl( ListView_GetBkColor( ( HWND ) HB_PARNL( 1 ) ) );
}

HB_FUNC( LISTVIEW_ADDCOLUMN )
{
   LV_COLUMN COL;
   HWND      hwnd    = ( HWND ) HB_PARNL( 1 );
   int       iColumn = hb_parni( 2 ) - 1;
   PHB_ITEM  pValue  = hb_itemNew( NULL );

   hb_itemCopy( pValue, hb_param( 4, HB_IT_STRING ) );

   COL.mask     = LVCF_WIDTH | LVCF_TEXT | LVCF_FMT | LVCF_SUBITEM;
   COL.cx       = hb_parni( 3 );
   COL.pszText  = ( char * ) hb_itemGetCPtr( pValue );
   COL.iSubItem = iColumn;
   COL.fmt      = hb_parni( 5 );

   ListView_InsertColumn( hwnd, iColumn, &COL );

   if( iColumn == 0 && COL.fmt != LVCFMT_LEFT )
   {
      COL.iSubItem = 1;
      ListView_InsertColumn( hwnd, 1, &COL );
      ListView_DeleteColumn( hwnd, 0 );
   }

   SendMessage( hwnd, LVM_DELETEALLITEMS, 0, 0 );

   RedrawWindow( hwnd, NULL, NULL, RDW_ERASE | RDW_INVALIDATE | RDW_ALLCHILDREN | RDW_ERASENOW | RDW_UPDATENOW );
}

HB_FUNC( LISTVIEW_DELETECOLUMN )
{
   HWND hwnd = ( HWND ) HB_PARNL( 1 );

   ListView_DeleteColumn( hwnd, hb_parni( 2 ) - 1 );

   SendMessage( hwnd, LVM_DELETEALLITEMS, 0, 0 );

   RedrawWindow( hwnd, NULL, NULL, RDW_ERASE | RDW_INVALIDATE | RDW_ALLCHILDREN | RDW_ERASENOW | RDW_UPDATENOW );
}

HB_FUNC( LISTVIEW_GETCOLUMNWIDTH )
{
   hb_retni( ListView_GetColumnWidth( ( HWND ) HB_PARNL( 1 ), hb_parni( 2 ) ) );
}

HB_FUNC( LISTVIEW_SETCOLUMNWIDTH )  // (JK) HMG Experimental Build 6
{
   hb_retl( ListView_SetColumnWidth( ( HWND ) HB_PARNL( 1 ), hb_parni( 2 ), hb_parni( 3 ) ) );
}

HB_FUNC( LISTVIEW_GETCHECKSTATE )
{
   HWND hwndLV = ( HWND ) HB_PARNL( 1 );

   if( _isValidCtrlClass( hwndLV, WC_LISTVIEW ) )
   {
      hb_retl( ListView_GetCheckState( hwndLV, hb_parni( 2 ) - 1 ) );
   }
   else
   {
      hb_errRT_BASE_SubstR( EG_ARG, 0, "MiniGUI Err.", HB_ERR_FUNCNAME, 1, hb_paramError( 1 ) );
   }
}

HB_FUNC( LISTVIEW_SETCHECKSTATE )
{
   HWND hwndLV = ( HWND ) HB_PARNL( 1 );

   if( _isValidCtrlClass( hwndLV, WC_LISTVIEW ) )
   {
      ListView_SetCheckState( hwndLV, hb_parni( 2 ) - 1, hb_parl( 3 ) );

      hb_retl( HB_TRUE );
   }
   else
   {
      hb_errRT_BASE_SubstR( EG_ARG, 0, "MiniGUI Err.", HB_ERR_FUNCNAME, 1, hb_paramError( 1 ) );
   }
}

HB_FUNC( LISTVIEW_GETCOLUMNCOUNT )  // Dr. Claudio Soto 2016/APR/07
{
   HWND hwndLV = ( HWND ) HB_PARNL( 1 );

   if( _isValidCtrlClass( hwndLV, WC_LISTVIEW ) )
   {
      hb_retni( Header_GetItemCount( ListView_GetHeader( hwndLV ) ) );
   }
   else
   {
      hb_errRT_BASE_SubstR( EG_ARG, 0, "MiniGUI Err.", HB_ERR_FUNCNAME, 1, hb_paramError( 1 ) );
   }
}
