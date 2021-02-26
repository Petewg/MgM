/*----------------------------------------------------------------------------
 MINIGUI - Harbour Win32 GUI library source code

 Copyright 2002-2010 Roberto Lopez <harbourminigui@gmail.com>
 http://harbourminigui.googlepages.com/

 Property Grid control source code
 (C)2007-2011 Janusz Pora <januszpora@onet.eu>

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
    Copyright 2001 Alexander S.Kresin <alex@belacy.belgorod.su>
    Copyright 2001 Antonio Linares <alinares@fivetech.com>
   www - http://harbour-project.org

   "Harbour Project"
   Copyright 1999-2012, http://harbour-project.org/

   "WHAT32"
   Copyright 2002 AJ Wos <andrwos@aust1.net>

   "HWGUI"
     Copyright 2001-2009 Alexander S.Kresin <alex@belacy.belgorod.su>

---------------------------------------------------------------------------*/

#define _WIN32_IE 0x0500
#define _WIN32_WINNT 0x0400

#define PG_DEFAULT   0
#define PG_CATEG     1
#define PG_STRING    2
#define PG_INTEGER   3
#define PG_DOUBLE    4
#define PG_SYSCOLOR  5
#define PG_COLOR     6
#define PG_LOGIC     7
#define PG_DATE      8
#define PG_FONT      9
#define PG_ARRAY     10
#define PG_ENUM      11
#define PG_FLAG      12
#define PG_SYSINFO   13
#define PG_IMAGE     14
#define PG_CHECK     15
#define PG_SIZE      16
#define PG_FILE      17
#define PG_FOLDER    18
#define PG_LIST      19
#define PG_USERFUN   20
#define PG_PASSWORD  21

#define CY_BITMAP    16
#define CX_BITMAP    16

#include <shlobj.h>
#include <windows.h>
#include <commctrl.h>
#include "hbapi.h"
#include "hbvm.h"
#include "hbstack.h"
#include "hbapiitm.h"

#if defined( __WATCOMC__ )
// fix for typo in OWATCOM winuser.h
    #define BDR_RIASEDOUTER  BDR_RAISEDOUTER
#endif

#ifdef __XHARBOUR__
#define HB_STORC( n, x, y )  hb_storc( n, x, y )
#define HB_STORL( n, x, y )  hb_storl( n, x, y )
#define HB_STORNI( n, x, y ) hb_storni( n, x, y )
#define HB_STORNL( n, x, y ) hb_stornl( n, x, y )
#else
#define HB_STORC( n, x, y )  hb_storvc( n, x, y )
#define HB_STORL( n, x, y )  hb_storvl( n, x, y )
#define HB_STORNI( n, x, y ) hb_storvni( n, x, y )
#define HB_STORNL( n, x, y ) hb_storvnl( n, x, y )
#endif

#ifdef __XHARBOUR__
#include "hbverbld.h"
#if defined(HB_VER_CVSID) && ( HB_VER_CVSID < 9798 )
#define HB_ISNIL( n )        ISNIL( n )
#endif
#endif

#ifdef MAKELONG
  #undef MAKELONG
#endif
#define MAKELONG( a, b )   ( ( LONG ) ( ( ( WORD ) ( ( DWORD_PTR ) ( a ) & 0xffff ) ) | ( ( ( DWORD ) ( ( WORD ) ( ( DWORD_PTR ) ( b ) & 0xffff ) ) ) << 16 ) ) )

typedef struct
{
   HWND        hPropGrid;
   HWND        hPropEdit;
   HWND        hInfoTitle;
   HWND        hInfoText;
   HWND        hInfoFrame;
   HWND        hHeader;
   HWND        hFramePG;
   HWND        hOkBtn;
   HWND        hApplyBtn;
   HWND        hCancelBtn;
   HWND        hHelpBtn;
   HTREEITEM   hItemActive;
   HTREEITEM   hItemEdit;
   RECT        rcInfo;                    // rectangle for the Info control
   WNDPROC     oldproc;                   // need to remember the old window procedure
   int         cxLeftPG;                  // Left Position PG.
   int         cyTopPG;                   // Top position PG
   int         cxWidthPG;                 // Width Frame PG
   int         cyHeightPG;                // Height frame PG
   int         cxMiddleEdge;
   int         stylePG;
   int         cyHeader;                  // Height header PG
   int         cyPG;                      // Height Tree PG
   int         cyInfo;                    // Height Info PG
   int         cyBtn;                     // Height button PG
   int         nIndent;
   BOOL        fDisable;
   BOOL        readonly;
   BOOL        lInfoShow;
   BOOL        lOkBtn;
   BOOL        lApplyBtn;
   BOOL        lCancelBtn;
   BOOL        lHelpBtn;
} PROPGRD, *PPROPGRD;

typedef struct
{
   UINT        fButtonDown;               // is the button2 up/down?
   int         nButton;                   // is the button2 ?
   int         ItemType;                  // type of Item Property
   BOOL        fMouseDown;                // is the mouse activating the button?
   WNDPROC     oldproc;                   // need to remember the old window procedure
   int         cxLeftEdge, cxRightEdge;   // size of the current window borders.
   int         cyTopEdge, cyBottomEdge;   // given these, we know where to insert our button
   int         uState;
   int         cxButton;
   BOOL        fMouseActive;
   HWND        himage;
   HTREEITEM   hItem;
   PROPGRD     ppgrd;
} INSBTN, *PINSBTN;

typedef struct
{
   LPTSTR   ItemName;
   LPTSTR   ItemValue;
   LPTSTR   ItemData;
   BOOL     ItemDisabled;
   BOOL     ItemChanged;
   BOOL     ItemEdit;
   int      ItemType;
   int      ItemID;
   LPTSTR   ItemInfo;
   LPTSTR   ItemValueName;
} LPARAMDATA, *PLPARAMDATA;

struct fontProcData
{
   HWND        hWndPG;
   HTREEITEM   hParentItem;
   BYTE        lfCharSet;
   LOGFONT     *plfTreeView;
};

extern HBITMAP    HMG_LoadPicture( char * FileName, int New_Width, int New_Height, HWND hWnd, int ScaleStretch, int Transparent, long BackgroundColor, int AdjustImage );

HWND              EditPG( HWND hWnd, RECT rc, HTREEITEM hItem, int ItemType, PROPGRD ppgrd, BOOL DisEdit );
HTREEITEM         GetNextItemPG( HWND TreeHandle, HTREEITEM hTreeItem );
LRESULT CALLBACK  OwnPropGridProc( HWND hWnd, UINT Msg, WPARAM wParam, LPARAM lParam );
LRESULT CALLBACK  OwnFramePgProc( HWND hFramePG, UINT Msg, WPARAM wParam, LPARAM lParam );
LRESULT CALLBACK  PGEditProc( HWND hEdit, UINT msg, WPARAM wParam, LPARAM lParam );
void              SetIndentLine( HWND hWnd, HTREEITEM hParent, RECT *rc, RECT *rcIndent, int nIndent );
void              _ToggleInfo( HWND hWndPg );

static COLORREF   m_crText, m_crTextCg, m_crBack, m_crBackCg, m_crLine, m_crTextDis;
static HIMAGELIST m_hImgList = 0;
static int        m_nHeightHeader = 0;

//----------------------------------------------------------------------------------

BOOL InsertBtnPG( HWND hWnd, HTREEITEM hItem, int nBtn, int ItemType, PROPGRD pgrd )
{
   INSBTN   *pbtn;

   pbtn = HeapAlloc( GetProcessHeap(), 0, sizeof(INSBTN) );

   if( !pbtn )
   {
      return FALSE;
   }

   pbtn->fButtonDown = FALSE;
   pbtn->nButton = nBtn;
   pbtn->ItemType = ItemType;
   pbtn->hItem = hItem;
   pbtn->cxButton = GetSystemMetrics( SM_CXVSCROLL );
   pbtn->ppgrd = pgrd;
   pbtn->himage = 0;       // todo

   // replace the old window procedure with our new one

   pbtn->oldproc = ( WNDPROC ) SetWindowLong( hWnd, GWL_WNDPROC, (LONG) PGEditProc );

   // associate our button state structure with the window

   SetWindowLong( hWnd, GWL_USERDATA, (LONG) pbtn );

   // force the edit control to update its non-client area

   SetWindowPos( hWnd, 0, 0, 0, 0, 0, SWP_FRAMECHANGED | SWP_NOMOVE | SWP_NOSIZE | SWP_NOACTIVATE | SWP_NOZORDER );

   return TRUE;
}

//----------------------------------------------------------------------------------

void GetBtnPG( INSBTN *pbtn, RECT *rect )
{
   if( pbtn->nButton > 0 )
   {
      rect->right -= pbtn->cxRightEdge;
      rect->top += pbtn->cyTopEdge;
      rect->bottom -= pbtn->cyBottomEdge;
      rect->left = rect->right - pbtn->cxButton;
      if( pbtn->cxRightEdge > pbtn->cxLeftEdge )
      {
         OffsetRect( rect, pbtn->cxRightEdge - pbtn->cxLeftEdge, 0 );
      }
   }
}

//----------------------------------------------------------------------------------

void DrawInsBtnPG( HWND hWnd, INSBTN *pbtn, RECT *prect )
{
   HDC   hdc;
   HWND  hBitmap = pbtn->himage;
   hdc = GetWindowDC( hWnd );
   if( pbtn->nButton )
   {
      if( pbtn->fButtonDown == TRUE )
      {
         DrawEdge( hdc, prect, EDGE_RAISED, BF_RECT | BF_FLAT | BF_ADJUST );
         FillRect( hdc, prect, GetSysColorBrush(COLOR_BTNFACE) );
         OffsetRect( prect, 1, 1 );
      }
      else
      {
         DrawEdge( hdc, prect, EDGE_RAISED, BF_RECT | BF_ADJUST );
         FillRect( hdc, prect, GetSysColorBrush(COLOR_BTNFACE) );
      }

      if( hBitmap == NULL )
      {
         SetBkMode( hdc, TRANSPARENT );
         DrawText( hdc, "...", 3, prect, DT_CENTER | DT_VCENTER | DT_SINGLELINE );
      }
      else
      {
         int      wRow = prect->top;
         int      wCol = prect->left;
         int      wWidth = prect->right - prect->left;
         int      wHeight = prect->bottom - prect->top;

         HDC      hDCmem = CreateCompatibleDC( hdc );
         BITMAP   bitmap;
         DWORD    dwRaster = SRCCOPY;

         SelectObject( hDCmem, hBitmap );
         GetObject( hBitmap, sizeof(BITMAP), (LPVOID) & bitmap );
         if( wWidth && (wWidth != bitmap.bmWidth || wHeight != bitmap.bmHeight) )
         {
            StretchBlt( hdc, wCol, wRow, wWidth, wHeight, hDCmem, 0, 0, bitmap.bmWidth, bitmap.bmHeight, dwRaster );
         }
         else
         {
            BitBlt( hdc, wCol, wRow, bitmap.bmWidth, bitmap.bmHeight, hDCmem, 0, 0, dwRaster );
         }

         DeleteDC( hDCmem );
      }
   }

   ReleaseDC( hWnd, hdc );
}

//----------------------------------------------------------------------------------

void LineVert( HDC hDC, int x, int y0, int y1 )
{
   POINT Line[2];
   Line[0].x = x;
   Line[0].y = y0;
   Line[1].x = x;
   Line[1].y = y1;
   Polyline( hDC, Line, 2 );
}

//----------------------------------------------------------------------------------

void LineHorz( HDC hDC, int x0, int x1, int y )
{
   POINT Line[2];
   Line[0].x = x0;
   Line[0].y = y;
   Line[1].x = x1;
   Line[1].y = y;
   Polyline( hDC, Line, 2 );
}

//----------------------------------------------------------------------------------

BOOL InitPropGrd
(
   HWND  hWndPG,
   int   col,
   int   row,
   int   width,
   int   height,
   int   indent,
   int   datawidth,
   int   style,
   BOOL  readonly,
   BOOL  lInfoShow,
   int   cyInfo,
   int   PGHeight,
   HWND  hTitle,
   HWND  hInfo,
   HWND  hFrame,
   HWND  hHeader,
   HWND  hFramePG,
   HWND  hBtnOk,
   HWND  hBtnApply,
   HWND  hBtnCancel,
   HWND  hBtnHelp
)
{
   PROPGRD  *ppgrd;
   RECT rcCtrl;
   RECT rcButton;
   HWND  hwndButton;
   int num_buttons = 0;
   int x, y, h ;
   int cyMargin = GetSystemMetrics( SM_CYFRAME )  ;
   int cxMargin = GetSystemMetrics( SM_CYDLGFRAME );
   int buttonWidth;
   int buttonHeight = 0;
   ppgrd = HeapAlloc( GetProcessHeap(), 0, sizeof(PROPGRD) );

   if( !ppgrd )
   {
      return FALSE;
   }
   TreeView_SetIndent( hWndPG, indent );
   indent = TreeView_GetIndent( hWndPG );

   GetWindowRect( hFrame, &rcCtrl );
   CopyRect( &ppgrd->rcInfo, &rcCtrl );

   ppgrd->hPropGrid = hWndPG;
   ppgrd->hPropEdit = 0;
   ppgrd->hInfoTitle = hTitle;
   ppgrd->hInfoText = hInfo;
   ppgrd->hInfoFrame = hFrame;
   ppgrd->hHeader = hHeader;
   ppgrd->hFramePG = hFramePG;
   ppgrd->hOkBtn = hBtnOk;
   ppgrd->hApplyBtn = hBtnApply;
   ppgrd->hCancelBtn = hBtnCancel;
   ppgrd->hHelpBtn = hBtnHelp;
   ppgrd->hItemActive = 0;
   ppgrd->hItemEdit = 0;
   ppgrd->cxLeftPG = col;
   ppgrd->cyTopPG = row;

   ppgrd->cxWidthPG = width;
   ppgrd->cyHeightPG = height;
   ppgrd->cyHeader = m_nHeightHeader;
   ppgrd->cyInfo = cyInfo;
   ppgrd->cyPG = PGHeight;
   ppgrd->cxMiddleEdge = width - datawidth;
   ppgrd->stylePG = style;
   ppgrd->fDisable = FALSE;
   ppgrd->readonly = readonly;
   ppgrd->lInfoShow = lInfoShow;
   ppgrd->lOkBtn = ( (int) hBtnOk > 0 );
   ppgrd->lApplyBtn = ( (int) hBtnApply > 0 );
   ppgrd->lCancelBtn = ( (int) hBtnCancel > 0);
   ppgrd->lHelpBtn = ( (int) hBtnHelp > 0);
   ppgrd->nIndent = indent;
   m_crText = GetSysColor( COLOR_WINDOWTEXT );
   m_crTextCg = GetSysColor( COLOR_APPWORKSPACE );
   m_crTextDis = GetSysColor( COLOR_GRAYTEXT );
   m_crBack = GetSysColor( COLOR_WINDOW );
   m_crBackCg = GetSysColor( COLOR_ACTIVEBORDER );
   m_crLine = m_crTextCg;  //GetSysColor( COLOR_GRAYTEXT );

   if( ppgrd->lOkBtn )
   {
      num_buttons++;
   }

   if( ppgrd->lApplyBtn )
   {
      num_buttons++;
   }

   if( ppgrd->lCancelBtn )
   {
      num_buttons++;
   }

   if( ppgrd->lHelpBtn )
   {
      num_buttons++;
   }

   if( num_buttons > 0 )
   {
      if( ppgrd->lOkBtn )
      {
         // Move the first button "OK" below the tab control.
         hwndButton = ppgrd->hOkBtn;
         GetWindowRect( hwndButton, &rcButton );
         buttonWidth = rcButton.right - rcButton.left;
         buttonHeight = rcButton.bottom - rcButton.top;
         x = ppgrd->cxWidthPG - ( (cxMargin + buttonWidth) * num_buttons ) - GetSystemMetrics(SM_CXDLGFRAME);
         y = ppgrd->cyHeightPG - (buttonHeight+5);
         SetWindowPos( hwndButton, 0, x, y, 0, 0, SWP_NOSIZE | SWP_NOZORDER | SWP_NOACTIVATE );
         num_buttons--;
      }

      if( ppgrd->lCancelBtn )
      {
         // Move the second button "Cancel" to the right of the first.
         hwndButton = ppgrd->hCancelBtn;
         if( buttonHeight == 0 )
         {
            GetWindowRect( hwndButton, &rcButton );
            buttonWidth = rcButton.right - rcButton.left;
            buttonHeight = rcButton.bottom - rcButton.top;
         }
         x = ppgrd->cxWidthPG - ( (cxMargin + buttonWidth) * num_buttons ) - GetSystemMetrics(SM_CXDLGFRAME);
         y = ppgrd->cyHeightPG - (buttonHeight+5);

         SetWindowPos( hwndButton, 0, x, y, 0, 0, SWP_NOSIZE | SWP_NOZORDER | SWP_NOACTIVATE );
         EnableWindow( hwndButton, FALSE );
         num_buttons--;
      }

      if( ppgrd->lApplyBtn )
      {
         // Move the thrid button "Apply" to the right of the second.
         hwndButton = ppgrd->hApplyBtn;
         if( buttonHeight == 0 )
         {
            GetWindowRect( hwndButton, &rcButton );
            buttonWidth = rcButton.right - rcButton.left;
            buttonHeight = rcButton.bottom - rcButton.top;
         }
         x = ppgrd->cxWidthPG - ( (cxMargin + buttonWidth) * num_buttons ) - GetSystemMetrics(SM_CXDLGFRAME);
         y = ppgrd->cyHeightPG - (buttonHeight+5);

         SetWindowPos( hwndButton, 0, x, y, 0, 0, SWP_NOSIZE | SWP_NOZORDER | SWP_NOACTIVATE );
         EnableWindow( hwndButton, FALSE );

         num_buttons--;
      }

      if( ppgrd->lHelpBtn )
      {
         // Move the thrid button "Help" to the right of the second.
         hwndButton = ppgrd->hHelpBtn;
         if( buttonHeight == 0 )
         {
            GetWindowRect( hwndButton, &rcButton );
            buttonWidth = rcButton.right - rcButton.left;
            buttonHeight = rcButton.bottom - rcButton.top;
         }
         x = ppgrd->cxWidthPG - ( (cxMargin + buttonWidth) * num_buttons ) - GetSystemMetrics(SM_CXDLGFRAME);
         y = ppgrd->cyHeightPG - (buttonHeight+5);

         SetWindowPos( hwndButton, 0, x, y, 0, 0, SWP_NOSIZE | SWP_NOZORDER | SWP_NOACTIVATE );
      }

      ppgrd->cyBtn = buttonHeight + cyMargin +  GetSystemMetrics(SM_CYDLGFRAME);

      x = 0;
      y = ppgrd->cyPG+ ppgrd->cyHeader - ppgrd->cyBtn;
      h = ppgrd->cyPG -  ppgrd->cyBtn ;

      SetWindowPos( hWndPG, 0, 0, 0, ppgrd->cxWidthPG, h, SWP_FRAMECHANGED | SWP_NOMOVE | SWP_NOACTIVATE | SWP_NOZORDER );
      SetWindowPos( hFrame, 0, x,    y,    0, 0, SWP_FRAMECHANGED | SWP_NOSIZE | SWP_NOZORDER | SWP_NOACTIVATE );
      SetWindowPos( hTitle, 0, x+10, y+10, 0, 0, SWP_FRAMECHANGED | SWP_NOSIZE | SWP_NOZORDER | SWP_NOACTIVATE );
      SetWindowPos( hInfo,  0, x+20, y+26, 0, 0, SWP_NOSIZE | SWP_NOZORDER | SWP_NOACTIVATE );

      GetWindowRect( hFrame, &rcCtrl );
      CopyRect( &ppgrd->rcInfo, &rcCtrl );

   }

   // replace the old window procedure with our new one

   ppgrd->oldproc = ( WNDPROC ) SetWindowLong( hWndPG, GWL_WNDPROC, (LONG) OwnPropGridProc );
   SetWindowLong( hFramePG, GWL_WNDPROC, (LONG) (WNDPROC) OwnFramePgProc );

   // associate our button state structure with the window

   SetWindowLong( hFramePG,GWL_USERDATA, (LONG) ppgrd );
   SetWindowLong( hWndPG,  GWL_USERDATA, (LONG) ppgrd );
   SetWindowLong( hHeader, GWL_USERDATA, (LONG) ppgrd );
   SetWindowLong( hBtnOk,  GWL_USERDATA, (LONG) ppgrd );
   SetWindowLong( hBtnCancel,GWL_USERDATA, (LONG) ppgrd );
   SetWindowLong( hBtnApply, GWL_USERDATA, (LONG) ppgrd );
   SetWindowLong( hBtnHelp,  GWL_USERDATA, (LONG) ppgrd );

   // force the edit control to update its non-client area

   SetWindowPos( hWndPG, 0, 0, 0, 0, 0, SWP_FRAMECHANGED | SWP_NOMOVE | SWP_NOSIZE | SWP_NOACTIVATE | SWP_NOZORDER );

   return TRUE;
}

//----------------------------------------------------------------------------------

BOOL InsertItem( HWND hwndHeader, LPSTR lpsz, int CurrIndex, int Width )   //HBITMAP hBitmap)
{
   HD_ITEM  hdi;

   hdi.mask = HDI_FORMAT | HDI_WIDTH;
   hdi.fmt = HDF_LEFT;        // Left-justify the item.
   if( lpsz )
   {
      hdi.mask |= HDI_TEXT;   // The .pszText member is valid.
      hdi.pszText = lpsz;     // The text for the item.
      hdi.cxy = Width;        // The initial width.
      hdi.cchTextMax = lstrlen( hdi.pszText );  // The length of the string.
      hdi.fmt |= HDF_STRING;                    // This item is a string.
   }

   /* to do
   if (hBitmap)
   {
      hdi.mask |= HDI_BITMAP; // The .hbm member is valid.
      hdi.cxy = 32;           // The initial width.
      hdi.hbm = hBitmap;      // The handle to the bitmap.
      hdi.fmt |= HDF_BITMAP;  // This item is a bitmap.
   }
   */

   if( Header_InsertItem(hwndHeader, CurrIndex, &hdi) == TRUE )
   {
      return TRUE;
   }

   return FALSE;
}

//----------------------------------------------------------------------------------

HWND CreateHeaderWindow( HWND hwndParent )
{
   HWND        hwndHeader;
   RECT        rcParent;
   HD_LAYOUT   hdl;
   WINDOWPOS   wp;

   if
   (
      (
         hwndHeader = CreateWindowEx
            (
               0,
               WC_HEADER,
               (LPCTSTR) NULL,
               WS_CHILD | WS_BORDER | HDS_BUTTONS | HDS_HORZ,
               0,
               0,
               0,
               0,             // No size or position.
               hwndParent,    // Handle to the parent window.
               (HMENU) NULL,  // ID for the header window.
               GetModuleHandle(NULL),  // Current instance.
               (LPVOID) NULL
            )
      ) == NULL
   )
   {  // No application-defined data.
      return( HWND ) NULL;
   }

   GetClientRect( hwndParent, &rcParent );

   hdl.prc = &rcParent;
   hdl.pwpos = &wp;

   if( Header_Layout(hwndHeader, &hdl) == FALSE )
   {
      return( HWND ) NULL;
   }

   SetWindowPos( hwndHeader, wp.hwndInsertAfter, wp.x, wp.y, wp.cx, wp.cy, wp.flags | SWP_SHOWWINDOW );
   m_nHeightHeader = wp.cy;

   return hwndHeader;
}

void PropGridPaintButton( HDC hDC, RECT rc, BOOL bExpanded, int nIndent )
{
   HPEN     hBoxPen, hMrkPen, hOldPen;
   HBRUSH   hNewBrush, hOldBrush;
   int      h = rc.bottom - rc.top, x = rc.left + ( nIndent - 9 ) / 2, y = rc.top + ( h - 9 ) / 2 + 1;

   hBoxPen = CreatePen( PS_SOLID, 1, m_crLine );
   hMrkPen = CreatePen( PS_SOLID, 1, RGB(0, 0, 0) );
   hNewBrush = CreateSolidBrush( RGB(255, 255, 255) );

   hOldPen = ( HPEN ) SelectObject( hDC, hBoxPen );
   hOldBrush = ( HBRUSH ) SelectObject( hDC, hNewBrush );

   // Draw the box

   Rectangle( hDC, x, y, x + 9, y + 9 );

   // Now, the - or + sign

   SelectObject( hDC, hMrkPen );

   LineHorz( hDC, x + 2, x + 7, y + 4 );     // '-'
   if( !bExpanded )
   {
      LineVert( hDC, x + 4, y + 2, y + 7 );  // '+'
   }

   SelectObject( hDC, hOldPen );
   SelectObject( hDC, hOldBrush );

   DeleteObject( hMrkPen );
   DeleteObject( hBoxPen );
   DeleteObject( hNewBrush );
}

LRESULT PropGridOnCustomDraw ( HWND hWnd, LPARAM lParam )
{
   NMHDR          *pNMHDR = ( NMHDR FAR * ) lParam;
   NMTVCUSTOMDRAW *pCD = ( NMTVCUSTOMDRAW * ) pNMHDR;
   DWORD          dwDrawStage;
   HBRUSH         m_brush = NULL;
   LRESULT        pResult;
   PROPGRD        *ppgrd = ( PROPGRD * ) GetWindowLong( hWnd, GWL_USERDATA );
   int            nIndent = ppgrd->nIndent;

   pResult = CDRF_SKIPDEFAULT;
   dwDrawStage = pCD->nmcd.dwDrawStage;

   if( dwDrawStage == CDDS_PREPAINT )
   {
      m_hImgList = TreeView_GetImageList( hWnd, TVSIL_NORMAL );
      pResult = CDRF_NOTIFYITEMDRAW;
   }
   else if( dwDrawStage == CDDS_ITEMPREPAINT )
   {
      pResult = CDRF_NOTIFYPOSTPAINT;
   }
   else if( dwDrawStage == CDDS_ITEMPOSTPAINT )
   {
      HDC         hDC = pCD->nmcd.hdc;
      HPEN        hLinPen, hOldPen;
      HBRUSH      hBackBrush, hOldBrush, hIndentBrush;
      HTREEITEM   hItem = ( HTREEITEM ) pCD->nmcd.dwItemSpec, hParent = TreeView_GetParent( hWnd, hItem );
      RECT        rc = pCD->nmcd.rc;
      TV_DISPINFO tvdi;
      LPARAMDATA  *pItemData = NULL;
      HWND        hPropEdit;
      LONG        hFont;
      RECT        rcText, rcItem, rcProp, rcEdit, rcCheck, rcIndent;
      TCHAR       szText[255];
      TCHAR       PropText[1024];
      TCHAR       PropInfo[1024];
      int         iImage, cx, cy, iCheck, style;

      if( rc.bottom >= SendMessage(hWnd, TVM_GETITEMHEIGHT, 0, 0) )
      {
         hLinPen = CreatePen( PS_SOLID, 1, m_crLine );

         hOldPen = ( HPEN ) SelectObject( hDC, hLinPen );
         hOldBrush = ( HBRUSH ) SelectObject( hDC, m_brush );

         rcItem = rc;
         rcProp = rc;
         rcIndent = rc;
         rcProp.left = ppgrd->cxMiddleEdge + 1;
         rcProp.top += 1;
         rcText = rc;
         rcText.right = ppgrd->cxMiddleEdge - 1;
         rcIndent.right = 0;

         tvdi.item.mask = TVIF_CHILDREN | TVIF_HANDLE | TVIF_IMAGE | TVIF_SELECTEDIMAGE | TVIF_STATE | TVIF_TEXT | TVIF_PARAM;
         tvdi.item.hItem = hItem;
         tvdi.item.pszText = szText;
         tvdi.item.cchTextMax = 255;
         if( !TreeView_GetItem(hWnd, &tvdi.item) )
         {
            SelectObject( hDC, hOldBrush );
            SelectObject( hDC, hOldPen );
            DeleteObject( hLinPen );
            pResult = CDRF_SKIPDEFAULT;
            hb_retnl( pResult );
         }

         if( tvdi.item.lParam )
         {
            pItemData = ( LPARAMDATA * ) tvdi.item.lParam;
            if( pItemData )
            {
               strcpy( szText, pItemData->ItemName );
               if( pItemData->ItemType == PG_PASSWORD )
                  {
                     strcpy( PropText, "*****" );
                  } else
                     strcpy( PropText, pItemData->ItemValue );

               strcpy( PropInfo, pItemData->ItemInfo );
            }
         }

         if( pCD->nmcd.uItemState & CDIS_FOCUS )
         {
            ppgrd->hItemActive = hItem;
            ppgrd->fDisable = pItemData->ItemDisabled;
         }

         if( hParent )
         {
            SetIndentLine( hWnd, hParent, &rc, &rcIndent, nIndent );
         }

         // Clear the background

         if( pCD->nmcd.uItemState & CDIS_FOCUS )
         {
            hBackBrush = CreateSolidBrush( GetSysColor(COLOR_HIGHLIGHT) );
         }
         else
         {
            if( tvdi.item.cChildren == 1 )
            {
               hBackBrush = CreateSolidBrush( m_crBackCg );
            }
            else
            {
               hBackBrush = CreateSolidBrush( m_crBack );
            }
         }

         hIndentBrush = CreateSolidBrush( m_crBackCg );
         FillRect( hDC, &rcItem, hBackBrush );
         FillRect( hDC, &rcIndent, hIndentBrush );
         DeleteObject( hBackBrush );
         DeleteObject( hIndentBrush );

         // Draw the grid lines

         DrawEdge( hDC, &rcItem, BDR_RAISEDOUTER, BF_BOTTOM );
         DrawEdge( hDC, &rcProp, BDR_SUNKENOUTER, BF_LEFT );

         // DrawEdge(hDC, &rcItem, BDR_SUNKENINNER, BF_BOTTOM);
         // DrawEdge(hDC, &rcProp, BDR_SUNKENINNER, BF_LEFT);
         //
         // Paint the buttons, if any
         //

         if( GetWindowLong(hWnd, GWL_STYLE) & TVS_HASBUTTONS )
         {
            if( tvdi.item.cChildren == 1 )
            {
               PropGridPaintButton( hDC, rc, tvdi.item.state & TVIS_EXPANDED, nIndent );
            }
            else if( tvdi.item.cChildren == I_CHILDRENCALLBACK )
            {
               PropGridPaintButton( hDC, rc, FALSE, nIndent );
            }

            // If we have buttons we must make room for them

            rc.left += nIndent;
            rcText.left = rc.left;
         }

         // Check if we have any check button to draw

         iCheck = tvdi.item.state >> 12;
         if( iCheck > 0 )
         {
            rcCheck = rcProp;
            rcCheck.left += 4;
            rcCheck.top += 1;
            rcCheck.right = rcCheck.left + nIndent;
            rcCheck.bottom -= 2;

            if( iCheck == 1 )
            {
               style = DFCS_BUTTONCHECK;
            }
            else //if( iCheck == 2 )
            {
               style = DFCS_BUTTONCHECK | DFCS_CHECKED;
            }

            if( pItemData->ItemDisabled )
            {
               style = style | DFCS_INACTIVE;
            }

            DrawFrameControl( hDC, &rcCheck, DFC_BUTTON, style );

            rcProp.left = rcCheck.right;
         }

         // Check if we have any normal icons to draw

         if( m_hImgList )
         {
            if( pCD->nmcd.uItemState & CDIS_SELECTED )
            {
               iImage = tvdi.item.iSelectedImage;
            }
            else
            {
               iImage = tvdi.item.iImage;
            }

            if( iImage > 0 )
            {
               ImageList_GetIconSize( m_hImgList, &cx, &cy );
               ImageList_DrawEx( m_hImgList, iImage - 1, hDC, rcProp.left + 5, rcProp.top + 1, 0, 0, CLR_DEFAULT, CLR_DEFAULT, ILD_NORMAL );
               rcProp.left += cx + 7;
            }
         }

         if( pCD->nmcd.uItemState & CDIS_FOCUS )
         {
            SetTextColor( hDC, RGB(255, 255, 255) );
            SetBkColor( hDC, GetSysColor(COLOR_HIGHLIGHT) );
         }
         else
         {
            if( tvdi.item.cChildren == 1 )
            {
               SetTextColor( hDC, m_crText );
               SetBkColor( hDC, m_crBackCg );
            }
            else
            {
               SetTextColor( hDC, m_crText );
               SetBkColor( hDC, m_crBack );
            }
         }

         if( !(ppgrd->hItemEdit == hItem) )
         {
            if( pCD->nmcd.uItemState & CDIS_FOCUS )
            {
               if( ppgrd->hItemEdit )
               {
                  PostMessage( ppgrd->hPropEdit, WM_CLOSE, 0, 0 );
                  ppgrd->hItemEdit = 0;
               }

               SetWindowText( ppgrd->hInfoTitle, szText );
               SetWindowText( ppgrd->hInfoText, PropInfo );

               if( !(pItemData->ItemDisabled) && (!(ppgrd->readonly)) && !(pItemData->ItemType == PG_CHECK) )
               {
                  rcEdit = rcProp;
                  if( pItemData->ItemType == PG_SYSCOLOR )
                  {
                     rcEdit.left = ppgrd->cxMiddleEdge;
                  }

                  hFont = SendMessage( hWnd, WM_GETFONT, 0, 0 );
                  hPropEdit = EditPG( hWnd, rcEdit, hItem, pItemData->ItemType, *ppgrd, pItemData->ItemEdit );
                  rcEdit = rcProp;
                  if( ppgrd->hItemEdit )
                  {
                     PostMessage( ppgrd->hPropEdit, WM_CLOSE, 0, 0 );
                  }

                  ppgrd->hItemEdit = hItem;
                  SendMessage( hPropEdit, WM_SETFONT, (WPARAM) hFont, TRUE );
                  ppgrd->hPropEdit = hPropEdit;
               }
            }
         }

         // Calculate the text drawing rectangle

         rcProp.left += 4;

         DrawText( hDC, szText, -1, &rcText, DT_LEFT | DT_NOPREFIX | DT_SINGLELINE | DT_VCENTER | DT_CALCRECT );
         DrawText( hDC, PropText, -1, &rcProp, DT_LEFT | DT_NOPREFIX | DT_SINGLELINE | DT_VCENTER | DT_CALCRECT );
         rcText.right = ppgrd->cxMiddleEdge - 1;

         // Now, draw the text

         DrawText( hDC, szText, -1, &rcText, DT_LEFT | DT_NOPREFIX | DT_SINGLELINE | DT_VCENTER | DT_END_ELLIPSIS );

         if( pItemData->ItemDisabled )
         {
            SetTextColor( hDC, m_crTextDis );
         }

         if( pItemData->ItemChanged )
         {
            HFONT    hFontBold, hOldFont;
            HFONT    hFont = ( HFONT ) SendMessage( hWnd, WM_GETFONT, 0, 0 );
            LOGFONT  lf = { 0 };
            GetObject( hFont, sizeof(LOGFONT), &lf );
            lf.lfWeight |= FW_BOLD;

            hFontBold = CreateFontIndirect( &lf );
            hOldFont = ( HFONT ) SelectObject( pCD->nmcd.hdc, hFontBold );

            DeleteObject( hFontBold );
            DrawText( hDC, PropText, -1, &rcProp, DT_LEFT | DT_NOPREFIX | DT_SINGLELINE | DT_VCENTER | DT_CALCRECT );
            DrawText( hDC, PropText, -1, &rcProp, DT_LEFT | DT_NOPREFIX | DT_SINGLELINE | DT_VCENTER );
            SelectObject( pCD->nmcd.hdc, hOldFont );
         }
         else
         {
            DrawText( hDC, PropText, -1, &rcProp, DT_LEFT | DT_NOPREFIX | DT_SINGLELINE | DT_VCENTER );
         }

         // Clean up

         SelectObject( hDC, hOldBrush );
         SelectObject( hDC, hOldPen );

         DeleteObject( hBackBrush );
         DeleteObject( hLinPen );

         pResult = CDRF_SKIPDEFAULT;
      }
   }
   else
   {
      pResult = CDRF_SKIPDEFAULT;
   }

   return ( pResult );
}

HB_FUNC( INITPROPGRID )
{
   INITCOMMONCONTROLSEX icex;

   HWND                 hWndPG, hTitle, hInfo, hFrame, hHeader, hFramePG;
   HWND                 hBtnOk, hBtnApply, hBtnCancel, hBtnHelp, hwndParent;
   int                  style, InfoStyle, iHeight, PGHeight;
   PHB_ITEM             hArray;
   PHB_ITEM             MsgArray;
   int x,y,w,h;
   x =  hb_parni(2);
   y =  hb_parni(3),
   w =  hb_parni(4),
   h =  hb_parni(5),
   hwndParent = (HWND) hb_parnl(1);
   style = WS_VISIBLE | WS_TABSTOP | WS_CHILD | TVS_HASBUTTONS | TVS_FULLROWSELECT | TVS_NOHSCROLL | TVS_SHOWSELALWAYS ;
   if( hb_parl(12) )
      style = style  | TVS_SINGLEEXPAND ;

   iHeight = hb_parni( 10 );

   icex.dwSize = sizeof( INITCOMMONCONTROLSEX );
   icex.dwICC = ICC_TREEVIEW_CLASSES | ICC_DATE_CLASSES | ICC_USEREX_CLASSES;;
   InitCommonControlsEx( &icex );

   hArray = hb_param( 11, HB_IT_ARRAY );
   MsgArray = hb_param( 17, HB_IT_ARRAY );

   hFramePG = CreateWindowEx
      (
         WS_EX_CONTROLPARENT,
         "button",
         "",
         WS_CHILD | BS_GROUPBOX | WS_VISIBLE ,
         x,
         y,
         w,
         h,
         (HWND) hwndParent,
         (HMENU)  NULL,
         GetModuleHandle(NULL),
         NULL
      );


   SetProp( (HWND) hFramePG, "oldframepgproc", (HWND) GetWindowLong((HWND) hFramePG, GWL_WNDPROC) );


   if( hb_arrayLen(hArray) > 0 )
   {
      hHeader = CreateHeaderWindow( hFramePG );

      InsertItem( hHeader, (char *) hb_arrayGetCPtr(hArray, 1), 1, w - hb_parni(7) + 3 );
      InsertItem( hHeader, (char *) hb_arrayGetCPtr(hArray, 2), 2, w );

   }
   else
   {
      style = style | WS_BORDER;
      hHeader = 0;
      m_nHeightHeader = 0;
   }

   if( hb_parl(9) )
   {
      PGHeight = h - iHeight - m_nHeightHeader;
      InfoStyle = WS_CHILD | WS_VISIBLE;
   }
   else
   {
      PGHeight = h - m_nHeightHeader;
      InfoStyle = WS_CHILD;
   }

   x = 0;
   y = 0;
   hWndPG = CreateWindowEx
      (
         WS_EX_CLIENTEDGE,
         WC_TREEVIEW,
         "",
         style,
         x,
         y + m_nHeightHeader ,
         w,
         PGHeight ,
         (HWND)  hFramePG,
         (HMENU)  NULL,
         GetModuleHandle(NULL),
         NULL
      );



   hFrame = CreateWindowEx
      (
         WS_EX_TRANSPARENT,
         "static",
         "",
         InfoStyle  | SS_OWNERDRAW  | SS_NOTIFY | WS_BORDER,          // SS_SUNKEN ,
         x,
         y + PGHeight + m_nHeightHeader,
         w,
         iHeight ,
         (HWND)  hFramePG,
         (HMENU)  NULL,
         GetModuleHandle(NULL),
         NULL
      );

   hTitle = CreateWindowEx
      (
         WS_EX_TRANSPARENT,
         "static",
         "",
         InfoStyle | SS_NOTIFY ,
         x + 10,
         y + PGHeight + m_nHeightHeader + 10,
         w - 20,
         20,
         (HWND)  hFramePG,
         (HMENU) NULL,
         GetModuleHandle(NULL),
         NULL
      );

   hInfo = CreateWindowEx
      (
         WS_EX_TRANSPARENT,
         "static",
         "",
         InfoStyle | SS_NOTIFY,
         x + 20,
         y + PGHeight + m_nHeightHeader + 26,
         w - 30,
         iHeight - 36,
         (HWND)  hFramePG,
         (HMENU)  NULL,
         GetModuleHandle(NULL),
         NULL
      );
   if( hb_parl(13) )
     {
         hBtnOk = CreateWindow
            ( "button",
            (char *) hb_arrayGetCPtr(MsgArray, 4),
            BS_NOTIFY | WS_CHILD | BS_PUSHBUTTON | WS_VISIBLE,
            0,
            0,
            70,
            20,
            (HWND)  hFramePG,
            (HMENU) NULL,
            GetModuleHandle(NULL),
            NULL
            );


      } else  hBtnOk = 0;

   if( hb_parl(14) )
     {
         hBtnApply = CreateWindow
            ( "button",
            (char *) hb_arrayGetCPtr(MsgArray, 1),
            BS_NOTIFY | WS_CHILD | BS_PUSHBUTTON | WS_VISIBLE,
            0,
            0,
            70,
            20,
            (HWND)  hFramePG,
            (HMENU) NULL,
            GetModuleHandle(NULL),
            NULL
            );

      } else  hBtnApply = 0;

   if( hb_parl(15) )
     {
         hBtnCancel = CreateWindow
            ( "button",
           (char *) hb_arrayGetCPtr(MsgArray, 3),
            BS_NOTIFY | WS_CHILD | BS_PUSHBUTTON | WS_VISIBLE,
            0,
            0,
            70,
            20,
            (HWND)  hFramePG,
            (HMENU) NULL,
            GetModuleHandle(NULL),
            NULL
            );
      } else hBtnCancel = 0;

   if( hb_parl(16) )
     {
         hBtnHelp = CreateWindow
            ( "button",
            (char *) hb_arrayGetCPtr(MsgArray, 2),
            BS_NOTIFY | WS_CHILD | BS_PUSHBUTTON | WS_VISIBLE,
            0,
            0,
            70,
            20,
            (HWND)  hFramePG,
            (HMENU) NULL,
            GetModuleHandle(NULL),
            NULL
            );
      } else hBtnHelp = 0;


   InitPropGrd
   (
      hWndPG,
      x,
      y,
      w,
      h,
      hb_parni(6),
      hb_parni(7),
      style,
      hb_parl(8),
      hb_parl(9),
      iHeight,
      PGHeight,
      hTitle,
      hInfo,
      hFrame,
      hHeader,
      hFramePG,
      hBtnOk,
      hBtnApply,
      hBtnCancel,
      hBtnHelp
   );

   hb_reta( 10 );
   HB_STORNL( (LONG) hWndPG,   -1, 1 );
   HB_STORNL( (LONG) hTitle,   -1, 2 );
   HB_STORNL( (LONG) hInfo,    -1, 3 );
   HB_STORNL( (LONG) hFrame,   -1, 4 );
   HB_STORNL( (LONG) hHeader,  -1, 5 );
   HB_STORNL( (LONG) hFramePG, -1, 6 );
   HB_STORNL( (LONG) hBtnOk,   -1, 7 );
   HB_STORNL( (LONG) hBtnApply, -1, 8 );
   HB_STORNL( (LONG) hBtnCancel, -1, 9 );
   HB_STORNL( (LONG) hBtnHelp,   -1, 10 );
}

LRESULT CALLBACK OwnPropGridProc( HWND hWnd, UINT Msg, WPARAM wParam, LPARAM lParam )
{
   static PHB_SYMB   pSymbol = NULL;

   long int          r;
   WNDPROC           OldWndProc;
   RECT              rect, rc;
   LPDRAWITEMSTRUCT  lpdis;
   HIMAGELIST        himl;

   COLORREF          clrBackground;
   COLORREF          clrForeground;

   char              achTemp[256];  // temporary buffer
   HDC               hDC;
   int               iImage, cx, cy;
   TV_ITEM           tvi;
   int               iCheck;

   // get the button state structure

   PROPGRD           *ppgrd = ( PROPGRD * ) GetWindowLong( hWnd, GWL_USERDATA );
   OldWndProc = ppgrd->oldproc;
   switch( Msg )
   {
      case WM_DESTROY:
         OldWndProc = ppgrd->oldproc;
         HeapFree( GetProcessHeap(), 0, ppgrd );
         return CallWindowProc( OldWndProc, hWnd, Msg, wParam, lParam );

      case WM_DRAWITEM:
         lpdis = ( LPDRAWITEMSTRUCT ) lParam;
         if( (long int) lpdis->itemID == -1 )
         {  // empty item
            break;
         }

         hDC = lpdis->hDC;
         rc = lpdis->rcItem;
         himl = ( HIMAGELIST ) lpdis->itemData;
         iImage = lpdis->itemID;
         if( lpdis->itemState & ODS_SELECTED )
         {
            clrForeground = SetTextColor( hDC, GetSysColor(COLOR_HIGHLIGHTTEXT) );
            clrBackground = SetBkColor( hDC, GetSysColor(COLOR_HIGHLIGHT) );
         }
         else
         {
            clrForeground = SetTextColor( hDC, m_crText );
            clrBackground = SetBkColor( hDC, m_crBack );
         }

         rc.left += 2;

         if( himl )
         {
            ImageList_Draw( himl, iImage, hDC, rc.left, rc.top, ILD_NORMAL );
            ImageList_GetIconSize( himl, &cx, &cy );
            rc.left += cx;
         }

         SendMessage( lpdis->hwndItem, CB_GETLBTEXT, lpdis->itemID, (LPARAM) (LPCSTR) achTemp );
         rc.left += 6;
         if( lpdis->itemState & ODS_COMBOBOXEDIT )
         {
            rc.right += 20;
            rc.bottom += 4;
            rc.top -= 4;
         }
         else
         {
            rc.right += 10;
            rc.bottom += 2;
         }

         DrawText( hDC, achTemp, -1, &rc, DT_LEFT | DT_NOPREFIX | DT_SINGLELINE | DT_VCENTER );

         // Restore the previous colors.

         SetTextColor( lpdis->hDC, clrForeground );
         SetBkColor( lpdis->hDC, clrBackground );
         break;

      case WM_GETDLGCODE:
         return DLGC_WANTALLKEYS;

      case WM_NCCALCSIZE:
         {
            GetWindowRect( hWnd, &rect );
            OffsetRect( &rect, -rect.left, -rect.top );
            CallWindowProc( ppgrd->oldproc, hWnd, Msg, wParam, lParam );
            ppgrd->cxLeftPG = rect.left;
//            ppgrd->cxRightEdge = rect.right;
            ppgrd->cyTopPG = rect.top;
//            ppgrd->cyBottomEdge = rect.bottom;
            return 0;
         }

      case WM_NCPAINT:
         m_crBack =  GetSysColor(COLOR_WINDOW) ;

         CallWindowProc( ppgrd->oldproc, hWnd, Msg, wParam, lParam );
         return 0;

      case WM_VSCROLL:
         {
            PostMessage( ppgrd->hPropEdit, WM_CLOSE, 0, 0 );
            ppgrd->hItemEdit = 0;
            SetFocus( hWnd );
            break;
         }

      case WM_LBUTTONDBLCLK:
         {
            memset( &tvi, 0, sizeof(TV_ITEM) );
            tvi.mask = TVIF_HANDLE | TVIF_STATE;
            tvi.stateMask = TVIS_STATEIMAGEMASK;
            tvi.hItem = ppgrd->hItemActive;
            TreeView_GetItem( hWnd, &tvi );

            iCheck = tvi.state >> 12;

            if( (iCheck > 0) && !(ppgrd->fDisable) )
            {
               iCheck = iCheck == 2 ? 1 : 2;
               tvi.state = INDEXTOSTATEIMAGEMASK( iCheck );
               TreeView_SetItem( hWnd, &tvi );
               PostMessage( hWnd, WM_COMMAND, MAKEWPARAM(iCheck, BN_CLICKED), (LPARAM) ppgrd->hItemActive );
            }
            break;
         }

      case WM_LBUTTONUP:
      case WM_LBUTTONDOWN:
      case WM_KILLFOCUS:
         if( !((HWND) wParam == ppgrd->hPropEdit) )
         {
            PostMessage( ppgrd->hPropEdit, WM_CLOSE, 0, 0 );
            ppgrd->hItemEdit = 0;
         }
         break;

      case NM_SETFOCUS:
         if( !((HWND) wParam == ppgrd->hPropEdit) )
         {
            PostMessage( ppgrd->hPropEdit, WM_CLOSE, 0, 0 );
            ppgrd->hItemEdit = 0;
         }
         break;

      case WM_COMMAND:
      case WM_CHAR:
      case WM_NOTIFY:
         {
            if( !pSymbol )
            {
               pSymbol = hb_dynsymSymbol( hb_dynsymGet("OPROPGRIDEVENTS") );
            }

            if( pSymbol )
            {
               hb_vmPushSymbol( pSymbol );
               hb_vmPushNil();
               hb_vmPushLong( (LONG) hWnd );
               hb_vmPushLong( Msg );
               hb_vmPushLong( wParam );
               hb_vmPushLong( lParam );
               hb_vmPushLong( (LONG) ppgrd->hItemActive );
               hb_vmPushLong( (LONG) ppgrd->hPropEdit );
               hb_vmDo( 6 );
            }

            r = hb_parnl( -1 );

            if( r != 0 )
            {
               return r;
            }
            else
            {
               return( CallWindowProc(OldWndProc, hWnd, Msg, wParam, lParam) );
            }
         }
   }

   return( CallWindowProc(OldWndProc, hWnd, Msg, wParam, lParam) );
}

LRESULT CALLBACK OwnFramePgProc( HWND hFramePG, UINT Msg, WPARAM wParam, LPARAM lParam )
{
   static PHB_SYMB   pSymbol = NULL;
   long int          r;
   WNDPROC           OldWndProc;
   HDC               hDC;
   RECT              rc;
   PROPGRD  *ppgrd = ( PROPGRD * ) GetWindowLong( hFramePG, GWL_USERDATA );

   OldWndProc = ( WNDPROC ) ( LONG_PTR ) GetProp( hFramePG, "oldframepgproc" );

   switch( Msg )
   {
      case WM_DESTROY:
         SetWindowLong( hFramePG, GWL_WNDPROC, (DWORD) OldWndProc );
         RemoveProp( hFramePG, "oldframepgproc" );
         break;

      case WM_DRAWITEM:

         hDC = GetWindowDC( GetParent(  hFramePG ));
         rc = ppgrd->rcInfo;

         rc.left   += 1;
         rc.right  -= 1;
         rc.bottom -= 1;
         FillRect( hDC, &rc, GetSysColorBrush(COLOR_BTNFACE) );
         ReleaseDC( hFramePG, hDC );

         break;
      case WM_COMMAND:

         if ( lParam != 0 && HIWORD(wParam) == BN_CLICKED )
         {
            if ( ppgrd )
               {
                     if( !pSymbol )
                     {
                        pSymbol = hb_dynsymSymbol( hb_dynsymGet("PGBTNEVENTS") );
                     }

                     if( pSymbol )
                     {
                           hb_vmPushSymbol( pSymbol );
                           hb_vmPushNil();
                           hb_vmPushLong( (LONG) ppgrd->hPropGrid );
                           hb_vmPushLong( (LONG) lParam );
                           hb_vmDo( 2 );
                     }

                     r = hb_parnl( -1 );

                     if( r != 0 )
                        {
                        return r;
                        }
                     else
                        {
                        return( CallWindowProc(OldWndProc, hFramePG, Msg, wParam, lParam) );
                        }
                }
        }
        else
        {
           return( CallWindowProc(OldWndProc, hFramePG, Msg, wParam, lParam) );
        }

      case WM_NOTIFY:
         {

            NMHDR    *nmhdr = ( NMHDR * ) lParam;
            HWND     hWndHD = nmhdr->hwndFrom;

            switch( nmhdr->code )
            {
               case HDN_ENDTRACK:
                  break;

               case HDN_ITEMCHANGED:
                  {
                     HD_ITEM  hdi;
                     int      dWidth;
                     hdi.mask = HDI_WIDTH;
                     Header_GetItem( hWndHD, 0, &hdi );
                     dWidth = ppgrd->cxMiddleEdge - hdi.cxy;
                     ppgrd->cxMiddleEdge = hdi.cxy - 3;
                     Header_GetItem( hWndHD, 1, &hdi );
                     hdi.cxy += dWidth;
                     RedrawWindow( ppgrd->hPropGrid, NULL, NULL, RDW_ERASE | RDW_INVALIDATE | RDW_ALLCHILDREN | RDW_ERASENOW | RDW_UPDATENOW );
                     break;
                  }

               case HDN_BEGINTRACK:
                  break;

               case HDN_ITEMCLICK:
                  break;

               case HDN_ITEMDBLCLICK:
                  {
                     LPNMHEADER  nmh = ( LPNMHEADER ) lParam;
                     if( nmh->iItem == 0 )
                     {
                        if( !pSymbol )
                        {
                           pSymbol = hb_dynsymSymbol( hb_dynsymGet("EXPANDPG") );
                        }

                        if( pSymbol )
                        {
                           hb_vmPushSymbol( pSymbol );
                           hb_vmPushNil();
                           hb_vmPushLong( (LONG) ppgrd->hPropGrid );
                           hb_vmPushLong( 0 );
                           hb_vmDo( 2 );
                        }
                     }
                     else
                     {
                        _ToggleInfo( ppgrd->hPropGrid );
                     }
                     break;
                  }
               case NM_CUSTOMDRAW:
                  {
                  if  (hWndHD ==  ppgrd->hPropGrid )
                     return ( PropGridOnCustomDraw ( hWndHD , lParam )) ;
                  break;
                  }
            }
         }
   }

   return( CallWindowProc(OldWndProc, hFramePG, Msg, wParam, lParam) );
}

HB_FUNC( PROPGRIDONCUSTOMDRAW )
{
   LRESULT    pResult;

   pResult = PropGridOnCustomDraw (( HWND ) hb_parnl( 1 ), (LPARAM) hb_parnl( 2 ));

   hb_retnl( pResult );
}

void SetIndentLine( HWND hWnd, HTREEITEM hParent, RECT *rc, RECT *rcIndent, int nIndent )
{
   HTREEITEM   hGrand;

   // Check if the parent has a parent itself and process it

   hGrand = TreeView_GetParent( hWnd, hParent );
   if( hGrand )
   {
      SetIndentLine( hWnd, hGrand, rc, rcIndent, nIndent );
   }

   rc->left += nIndent;
   rcIndent->right += nIndent;
}

HB_FUNC( GETNOTIFYPROPGRIDITEM )
{
   NMHDR          *pNMHDR = ( NMHDR FAR * ) hb_parnl( 1 );
   NMTVCUSTOMDRAW *pCD = ( NMTVCUSTOMDRAW * ) pNMHDR;
   HTREEITEM      hItem = ( HTREEITEM ) pCD->nmcd.dwItemSpec;
   hb_retnl( (LONG) hItem );
}

HB_FUNC( ADDPGITEM )
{
   HWND              hWndTV = ( HWND ) hb_parnl( 1 );

   HTREEITEM         hPrev = ( HTREEITEM ) hb_parnl( 2 );
   HTREEITEM         hRet;

   TV_ITEM           tvi;
   TV_INSERTSTRUCT   is;
   LPARAMDATA        *pData;

   pData = ( LPARAMDATA * ) hb_xgrab( (sizeof(LPARAMDATA)) );
   ZeroMemory( pData, sizeof(LPARAMDATA) );

   pData->ItemName = hb_strndup( hb_parc(7), 255 );
   pData->ItemValue = hb_strndup( hb_parc(8), 1024 );
   pData->ItemData = hb_strndup( hb_parc(9), 1024 );
   pData->ItemDisabled = hb_parl( 10 );
   pData->ItemChanged = hb_parl( 11 );
   pData->ItemEdit = hb_parl( 12 );
   pData->ItemType = hb_parni( 13 );
   pData->ItemID = hb_parni( 14 );
   pData->ItemInfo = hb_strndup( hb_parc(15), 1024 );
   pData->ItemValueName = hb_strndup( hb_parc(16), 255 );

   tvi.mask = TVIF_TEXT | TVIF_IMAGE | TVIF_SELECTEDIMAGE | TVIF_PARAM | TVIF_STATE;
   tvi.stateMask = TVIS_STATEIMAGEMASK;
   tvi.pszText = (char *) hb_parc( 3 );
   tvi.cchTextMax = 255;
   tvi.iImage = hb_parni( 4 );
   tvi.iSelectedImage = hb_parni( 5 );
   tvi.state = INDEXTOSTATEIMAGEMASK( hb_parni(6) );
   tvi.lParam = ( LPARAM ) pData;

   #if ( defined( __BORLANDC__ ) && __BORLANDC__ <= 1410 )
   is.DUMMYUNIONNAME.item = tvi;
   #else
   is.item = tvi;
   #endif
   if( hPrev == 0 )
   {
      is.hInsertAfter = hPrev;
      is.hParent = NULL;
   }
   else
   {
      is.hInsertAfter = TVI_LAST;
      is.hParent = hPrev;
   }

   hRet = TreeView_InsertItem( hWndTV, &is );

   hb_retnl( (LONG) hRet );
}

void Pg_SetData( HWND hWnd, HTREEITEM hItem, LPTSTR cValue, LPTSTR cData, BOOL lData )
{
   HWND        TreeHandle;
   HTREEITEM   TreeItemHandle;
   TV_ITEM     TreeItem;
   LPARAMDATA  *pData;

   memset( &TreeItem, 0, sizeof(TV_ITEM) );

   TreeHandle = hWnd;
   TreeItemHandle = hItem;

   TreeItem.mask = TVIF_HANDLE | TVIF_PARAM;
   TreeItem.hItem = TreeItemHandle;
   TreeView_GetItem( (HWND) TreeHandle, &TreeItem );
   if( TreeItem.lParam )
   {
      pData = ( LPARAMDATA * ) TreeItem.lParam;
      if( pData )
      {
         if( !(strcmp(pData->ItemValue, cValue) == 0) )
         {
            pData->ItemValue = hb_strndup( cValue, 1024 );
            pData->ItemChanged = TRUE;
            PostMessage( TreeHandle, WM_COMMAND, MAKEWPARAM(pData->ItemType, EN_CHANGE), (LPARAM) TreeItemHandle );
         }

         if( !(strcmp(pData->ItemData, cData) == 0) && (lData) )
         {
            pData->ItemData = hb_strndup( cData, 1024 );
         }
      }
   }
}

HB_FUNC( PG_SETDATAITEM )
{
   Pg_SetData( (HWND) hb_parnl(1), (HTREEITEM) hb_parnl(2), (LPSTR) hb_parc(3), (LPSTR) hb_parc(4), (BOOL) hb_parl(5) );
}

HB_FUNC( PG_ENABLEITEM )     //   Pg_EnableItem(  TreeHandle, TreeItemHandle, lEnable );
{

   HWND        TreeHandle;
   HTREEITEM   TreeItemHandle;
   TV_ITEM     TreeItem;
   LPARAMDATA  *pData;

   memset( &TreeItem, 0, sizeof(TV_ITEM) );

   TreeHandle = (HWND) hb_parnl(1);
   TreeItemHandle = (HTREEITEM) hb_parnl(2);

   TreeItem.mask = TVIF_HANDLE | TVIF_PARAM;
   TreeItem.hItem = TreeItemHandle;
   TreeView_GetItem( (HWND) TreeHandle, &TreeItem );
   if( TreeItem.lParam )
   {
      pData = ( LPARAMDATA * ) TreeItem.lParam;
      if( pData )
      {
         pData->ItemDisabled = (BOOL) !hb_parl(3);
         PostMessage( TreeHandle, WM_SETREDRAW, (WPARAM ) TRUE, 0);
      }
   }
}

HB_FUNC( PG_CHANGEITEM )     //   Pg_ChangeItem(  TreeHandle, TreeItemHandle, lChange );
{

   HWND        TreeHandle;
   HTREEITEM   TreeItemHandle;
   TV_ITEM     TreeItem;
   LPARAMDATA  *pData;

   memset( &TreeItem, 0, sizeof(TV_ITEM) );

   TreeHandle = (HWND) hb_parnl(1);
   TreeItemHandle = (HTREEITEM) hb_parnl(2);

   TreeItem.mask = TVIF_HANDLE | TVIF_PARAM;
   TreeItem.hItem = TreeItemHandle;
   TreeView_GetItem( (HWND) TreeHandle, &TreeItem );
   if( TreeItem.lParam )
   {
      pData = ( LPARAMDATA * ) TreeItem.lParam;
      if( pData )
      {
         pData->ItemChanged = (BOOL) hb_parl(3);
       }
   }
}
HB_FUNC( PG_GETITEM )
{
   HWND        TreeHandle;
   HTREEITEM   TreeItemHandle;
   TV_ITEM     TreeItem;
   LPARAMDATA  *pData;
   int         nType;

   memset( &TreeItem, 0, sizeof(TV_ITEM) );

   TreeHandle = ( HWND ) hb_parnl( 1 );
   TreeItemHandle = ( HTREEITEM ) hb_parnl( 2 );
   nType = ( int ) hb_parni( 3 );

   TreeItem.mask = TVIF_HANDLE | TVIF_PARAM;
   TreeItem.hItem = TreeItemHandle;
   TreeView_GetItem( (HWND) TreeHandle, &TreeItem );
   pData = ( LPARAMDATA * ) TreeItem.lParam;

   if( nType == 0 )
   {
      hb_reta( 10 );
      HB_STORC( pData->ItemName, -1, 1 );
      HB_STORC( pData->ItemValue, -1, 2 );
      HB_STORC( pData->ItemData, -1, 3 );
      HB_STORL( pData->ItemDisabled, -1, 4 );
      HB_STORL( pData->ItemChanged, -1, 5 );
      HB_STORL( pData->ItemEdit, -1, 6 );
      HB_STORNI( pData->ItemType, -1, 7 );
      HB_STORNI( pData->ItemID, -1, 8 );
      HB_STORC( pData->ItemInfo, -1, 9 );
      HB_STORC( pData->ItemValueName, -1, 10 );
   }
   else if( nType == 1 )
   {
      hb_retc( pData->ItemName );
   }
   else if( nType == 2 )
   {
      hb_retc( pData->ItemValue );
   }
   else if( nType == 3 )
   {
      hb_retc( pData->ItemData );
   }
   else if( nType == 4 )
   {
      hb_retl( pData->ItemDisabled );
   }
   else if( nType == 5 )
   {
      hb_retl( pData->ItemChanged );
   }
   else if( nType == 6 )
   {
      hb_retni( pData->ItemEdit );
   }
   else if( nType == 7 )
   {
      hb_retni( pData->ItemType );
   }
   else if( nType == 8 )
   {
      hb_retni( pData->ItemID );
   }
   else if( nType == 9 )
   {
      hb_retc( pData->ItemInfo );
   }
   else if( nType == 10 )
   {
      hb_retc( pData->ItemValueName );
   }
   else
   {
      hb_retc( pData->ItemValue );
   }
}

HTREEITEM GetNextItemPG( HWND TreeHandle, HTREEITEM hTreeItem )
{
   HTREEITEM   hTreeItemBack = hTreeItem;
   hTreeItem = TreeView_GetChild( TreeHandle, hTreeItem );
   if( !hTreeItem )
   {
      hTreeItem = TreeView_GetNextSibling( TreeHandle, hTreeItemBack );
   }

   if( !hTreeItem )
   {
      while( (!hTreeItem) && (hTreeItemBack) )
      {
         hTreeItemBack = TreeView_GetParent( TreeHandle, hTreeItemBack );
         hTreeItem = TreeView_GetNextSibling( TreeHandle, hTreeItemBack );
      }
   }

   return hTreeItem;
}

HB_FUNC( PG_GETNEXTITEM )
{
   HWND        TreeHandle;
   HTREEITEM   ItemHandle;
   HTREEITEM   NextItemHandle;

   TreeHandle = ( HWND ) hb_parnl( 1 );
   ItemHandle = ( HTREEITEM ) hb_parnl( 2 );
   NextItemHandle = GetNextItemPG( TreeHandle, ItemHandle );
   hb_retnl( (LONG) NextItemHandle );
}

HB_FUNC( PG_GETROOT )
{
   HWND        TreeHandle;
   HTREEITEM   ItemHandle;

   TreeHandle = ( HWND ) hb_parnl( 1 );

   ItemHandle = TreeView_GetRoot( TreeHandle );

   hb_retnl( (LONG) ItemHandle );
}

HB_FUNC( PG_ENSUREVISIBLE )
{
   HWND        TreeHandle;
   HTREEITEM   ItemHandle;
   BOOL        lVisible;

   TreeHandle = ( HWND ) hb_parnl( 1 );
   ItemHandle = ( HTREEITEM ) hb_parnl( 2 );

   lVisible = TreeView_EnsureVisible( TreeHandle, ItemHandle );

   hb_retl( (BOOL) lVisible );

}

HB_FUNC( PG_ISVISIBLE )
{
   HWND        TreeHandle;
   HTREEITEM   ItemHandle;
   HTREEITEM   ItemHdl;
   BOOL        lVisible = FALSE;

   TreeHandle = ( HWND ) hb_parnl( 1 );
   ItemHandle = ( HTREEITEM ) hb_parnl( 2 );

   ItemHdl = TreeView_GetFirstVisible ( TreeHandle );
   while( ItemHdl )
   {
      if( ItemHdl == ItemHandle )
      {
         lVisible = TRUE;
         break;
      }
      ItemHdl = TreeView_GetNextVisible( TreeHandle, ItemHdl );
   }
   hb_retl( (BOOL) lVisible );
}

HB_FUNC( PG_SEARCHID )        //PG_SearchID(hWndPG,nID)
{
   HWND        TreeHandle;
   HTREEITEM   TreeItemHandle;
   TV_ITEM     TreeItem;
   LPARAMDATA  *pData;
   int         nID;

   memset( &TreeItem, 0, sizeof(TV_ITEM) );
   TreeHandle = ( HWND ) hb_parnl( 1 );
   nID = ( int ) hb_parni( 2 );
   TreeItemHandle = TreeView_GetRoot( TreeHandle );
   while( TreeItemHandle )
   {
      TreeItem.mask = TVIF_HANDLE | TVIF_PARAM;
      TreeItem.hItem = TreeItemHandle;
      TreeView_GetItem( (HWND) TreeHandle, &TreeItem );
      pData = ( LPARAMDATA * ) TreeItem.lParam;

      if( pData->ItemID == nID )
      {
         break;
      }

      TreeItemHandle = GetNextItemPG( TreeHandle, TreeItemHandle );
   }

   hb_retnl( (LONG) TreeItemHandle );
}

HB_FUNC( PG_SEARCHCATEGORY )  //PG_SearchCategory(hWndPG,cCategory)
{
   HWND        TreeHandle;
   HTREEITEM   TreeItemHandle;
   TV_ITEM     TreeItem;
   LPARAMDATA  *pData;
   LPTSTR      cName;   // temporary buffer
   memset( &TreeItem, 0, sizeof(TV_ITEM) );
   TreeHandle = ( HWND ) hb_parnl( 1 );
   cName = hb_strndup( hb_parc(2), 255 );
   TreeItemHandle = TreeView_GetRoot( TreeHandle );
   while( TreeItemHandle )
   {
      TreeItem.mask = TVIF_HANDLE | TVIF_PARAM;
      TreeItem.hItem = TreeItemHandle;
      TreeView_GetItem( (HWND) TreeHandle, &TreeItem );
      pData = ( LPARAMDATA * ) TreeItem.lParam;
      if( strcmp(pData->ItemName, cName) == 0 )
      {
         break;
      }

      TreeItemHandle = GetNextItemPG( TreeHandle, TreeItemHandle );
   }

   hb_retnl( (LONG) TreeItemHandle );
}

HB_FUNC( PG_TOGGLEINFO )   // Pg_ToggleInfo( hWndPG )
{
   _ToggleInfo( (HWND) hb_parnl(1) );
}

void _ToggleInfo( HWND hWndPG )
{
   PROPGRD  *ppgrd = ( PROPGRD * ) GetWindowLong( hWndPG, GWL_USERDATA );
   int      height, width;

   width = ppgrd->cxWidthPG;

   if( ppgrd->lInfoShow )
   {
      ShowWindow( ppgrd->hInfoTitle, SW_HIDE );
      ShowWindow( ppgrd->hInfoText, SW_HIDE );
      ShowWindow( ppgrd->hInfoFrame, SW_HIDE );
      height = ppgrd->cyPG -  ppgrd->cyBtn + ppgrd->cyInfo  ;
      SetWindowPos( hWndPG, 0, 0, 0, width, height, SWP_FRAMECHANGED | SWP_NOMOVE | SWP_NOACTIVATE | SWP_NOZORDER );
      ppgrd->lInfoShow = FALSE;
   }
   else
   {
      ShowWindow( ppgrd->hInfoTitle, SW_SHOW );
      ShowWindow( ppgrd->hInfoText, SW_SHOW );
      ShowWindow( ppgrd->hInfoFrame, SW_SHOW );
      height = ppgrd->cyPG -  ppgrd->cyBtn ;
      SetWindowPos( hWndPG, 0, 0, 0, width, height, SWP_FRAMECHANGED | SWP_NOMOVE | SWP_NOACTIVATE | SWP_NOZORDER );
      ppgrd->lInfoShow = TRUE;
   }
}

HB_FUNC( ADDTREEITEMS )
{
   PHB_ITEM hArray;
   char     *caption;
   LV_ITEM  LI;
   HWND     h;
   int      l;
   int      s;
   int      c;

   h = ( HWND ) hb_parnl( 1 );
   l = hb_parinfa( 2, 0 ) - 1;
   hArray = hb_param( 2, HB_IT_ARRAY );
   c = ListView_GetItemCount( h );

   caption = (char *) hb_arrayGetCPtr( hArray, 1 );

   LI.mask = LVIF_TEXT | LVIF_IMAGE;   // Browse+
   LI.state = 0;
   LI.stateMask = 0;
   LI.iImage = hb_parni( 3 );          // Browse+
   LI.iSubItem = 0;
   LI.iItem = c;
   LI.pszText = (char *) caption;
   ListView_InsertItem( h, &LI );

   for( s = 1; s <= l; s = s + 1 )
   {
      caption = (char *) hb_arrayGetCPtr( hArray, s + 1 );
      ListView_SetItemText( h, c, s, (char *) caption );
   }

   hb_retni( (INT) c );
}

HB_FUNC( INITPROPGRIDIMAGELIST )
{
   HWND        hWndPG;
   HIMAGELIST  himl;
   int         cx = 0;
   hWndPG = ( HWND ) hb_parnl( 1 );
   himl = ( HIMAGELIST ) hb_parnl( 2 );

   if( himl != NULL )
   {
      SendMessage( hWndPG, TVM_SETIMAGELIST, (WPARAM) TVSIL_NORMAL, (LPARAM) himl );
      cx = ImageList_GetImageCount( himl );
   }

   hb_retni( (INT) cx );
}

HB_FUNC( RESETPROPGRIDIMAGELIST )
{
   HWND        hWndPG;
   HIMAGELIST  himl;
   HTREEITEM   hItemPG;
   TV_ITEM     TItem;

   int         cx;
   hWndPG = ( HWND ) hb_parnl( 1 );
   hItemPG = ( HTREEITEM ) hb_parnl( 2 );

   memset( &TItem, 0, sizeof(TV_ITEM) );

   TItem.mask = TVIF_HANDLE | TVIF_IMAGE | TVIF_SELECTEDIMAGE;
   TItem.hItem = hItemPG;

   TreeView_GetItem( (HWND) hWndPG, &TItem );

   himl = ( HIMAGELIST ) SendMessage( hWndPG, TVM_GETIMAGELIST, (WPARAM) TVSIL_NORMAL, 0 );
   ImageList_Replace( himl, ( int ) TItem.iImage - 1, (HBITMAP) hb_parnl(3), 0 );
   SendMessage( hWndPG, TVM_SETIMAGELIST, (WPARAM) TVSIL_NORMAL, (LPARAM) himl );
   cx = ImageList_GetImageCount( himl );
   hb_retni( (INT) cx );
}

HB_FUNC( PG_REDRAWITEM )
{
   hb_retl( TreeView_SelectItem((HWND) hb_parnl(1), (HTREEITEM) hb_parnl(2)) );
}

HB_FUNC( TREEVIEW_SETBOLDITEM )
{
   TVITEM      tvItem;
   HWND        TreeHandle;
   HTREEITEM   ItemHandle;
   BOOL        bold;
   TreeHandle = ( HWND ) hb_parnl( 1 );
   ItemHandle = ( HTREEITEM ) hb_parnl( 2 );
   bold = ( BOOL ) hb_parl( 3 );
   tvItem.mask = TVIF_HANDLE | TVIF_STATE;
   tvItem.hItem = ItemHandle;
   tvItem.stateMask = TVIS_BOLD;
   tvItem.state = bold ? TVIS_BOLD : 0;

   TreeView_SetItem( TreeHandle, &tvItem );
}

HB_FUNC( SETNODECOLOR )
{
   LPARAM            lParam = hb_parnl( 1 );

   LPNMTVCUSTOMDRAW  lplvcd = ( LPNMTVCUSTOMDRAW ) lParam;

   lplvcd->clrText = hb_parni( 3 );
   lplvcd->clrTextBk = hb_parni( 2 );
   lplvcd->iLevel = 0;
   hb_retni( CDRF_NEWFONT );
}

HB_FUNC( GETNOTIFYTREEITEM )
{
   hb_retnl( (LONG) ((NMTREEVIEW FAR *) hb_parnl(1))->itemNew.hItem );
}

HB_FUNC( PGCOMBOADDSTRING )
{
   DWORD       dwIndex;
   HIMAGELIST  hILst = ( HIMAGELIST ) hb_parnl( 3 );
   char        *cString = (char *) hb_parc( 2 );
   dwIndex = SendMessage( (HWND) hb_parnl(1), CB_ADDSTRING, 0, (LPARAM) cString );
   if( hb_parnl(3) )
   {
      SendMessage( (HWND) hb_parnl(1), CB_SETITEMDATA, dwIndex, (LPARAM) hILst );
   }
}

HB_FUNC( PG_SETPICTURE )
{
   HBITMAP  hBitmap;

   hBitmap = HMG_LoadPicture( (char *) hb_parc(2), hb_parni(3), hb_parni(4), (HWND) hb_parnl(1), 0, 0, -1, 0 );

   hb_retnl( (LONG) hBitmap );
}

HB_FUNC( CREATECOLORBMP1 ) //CreateColorBmp( hWnd,nColor,BmpWidh,BmpHeight)
{
   HBRUSH   hOldBrush;
   HBRUSH   hColorBrush;
   HBRUSH   hBlackBrush = CreateSolidBrush( RGB(1, 1, 1) );
   HBRUSH   hBgBrush = CreateSolidBrush( RGB(255, 255, 255) );

   RECT     rect;
   HBITMAP  hBmp;
   HWND     handle = ( HWND ) hb_parnl( 1 );
   COLORREF clr = hb_parnl( 2 );
   int      width = HB_ISNIL( 3 ) ? 20 : hb_parni( 3 );
   int      height = HB_ISNIL( 4 ) ? 20 : hb_parni( 4 );
   HDC      imgDC = GetDC( handle );
   HDC      tmpDC = CreateCompatibleDC( imgDC );

   SetRect( &rect, 0, 0, width, height ); // Size Bmp
   hBmp = CreateCompatibleBitmap( imgDC, width, height );

   SelectObject( tmpDC, hBmp );

   hOldBrush = SelectObject( tmpDC, hBgBrush );
   FillRect( tmpDC, &rect, hBgBrush );

   rect.left += 1;
   rect.top += 1;
   rect.right -= 1;
   rect.bottom -= 1;

   SelectObject( tmpDC, hBlackBrush );
   DrawEdge( tmpDC, &rect, BDR_SUNKENINNER, BF_RECT );

   rect.top += 1;
   rect.left += 1;
   rect.right -= 1;
   rect.bottom -= 1;

   hColorBrush = CreateSolidBrush( clr );
   SelectObject( tmpDC, hColorBrush );

   FillRect( tmpDC, &rect, hColorBrush );

   SelectObject( tmpDC, hOldBrush );
   DeleteObject( hColorBrush );
   DeleteObject( hBlackBrush );
   DeleteObject( hBgBrush );

   DeleteDC( tmpDC );
   ReleaseDC( handle, imgDC );

   hb_retnl( (LONG) hBmp );
   DeleteObject( hBmp );
}

HB_FUNC( CREATECOLORBMP )  //CreateColorBmp( hWnd,nColor,BmpWidh,BmpHeight)
{
   HBRUSH   hOldBrush;
   HBRUSH   hColorBrush;
   HBRUSH   hBlackBrush = CreateSolidBrush( RGB(1, 1, 1) );
   HBRUSH   hBgBrush = CreateSolidBrush( RGB(255, 255, 255) );

   RECT     rect;
   HBITMAP  hBmp;
   HWND     handle = ( HWND ) hb_parnl( 1 );
   COLORREF clr = hb_parnl( 2 );
   int      width = hb_parni( 3 );
   int      height = hb_parni( 4 );
   HDC      imgDC = GetDC( handle );
   HDC      tmpDC = CreateCompatibleDC( imgDC );

   if( (width == 0) & (height == 0) )
   {
      width = 20;
      height = 16;
   }

   SetRect( &rect, 0, 0, width, height ); // Size Bmp
   hBmp = CreateCompatibleBitmap( imgDC, width, height );

   SelectObject( tmpDC, hBmp );

   hOldBrush = SelectObject( tmpDC, hBgBrush );
   FillRect( tmpDC, &rect, hBgBrush );

   rect.left += 1;
   rect.top += 1;
   rect.right -= 1;
   rect.bottom -= 1;

   SelectObject( tmpDC, hBlackBrush );
   DrawEdge( tmpDC, &rect, BDR_SUNKENINNER, BF_RECT );

   rect.top += 1;
   rect.left += 1;
   rect.right -= 1;
   rect.bottom -= 1;

   hColorBrush = CreateSolidBrush( clr );
   SelectObject( tmpDC, hColorBrush );

   FillRect( tmpDC, &rect, hColorBrush );

   SelectObject( tmpDC, hOldBrush );
   DeleteObject( hBlackBrush );
   DeleteObject( hBgBrush );
   DeleteObject( hColorBrush );

   DeleteDC( imgDC );
   DeleteDC( tmpDC );

   hb_retnl( (LONG) hBmp );
}

HB_FUNC( GET_IMAGELIST )   //Get_ImageList(hWnd)
{
   hb_retnl( (LONG) SendMessage((HWND) hb_parnl(1), CBEM_GETIMAGELIST, 0, 0) );
}

HB_FUNC( IL_ADDMASKEDINDIRECT )  //IL_AddMaskedIndirect( hwnd , himage , color , ix , iy , imagecount )
{
   BITMAP   bm;
   HBITMAP  himage = ( HBITMAP ) hb_parnl( 2 );
   COLORREF clrBk   = CLR_NONE;
   LRESULT  lResult = -1;
   int      ic      = 1;

   if( hb_parnl( 3 ) )
      clrBk = ( COLORREF ) hb_parnl( 3 );

   if( hb_parni( 6 ) )
      ic = hb_parni( 6 );

   if( GetObject( himage, sizeof( BITMAP ), &bm ) != 0 )
   {
      if( ( hb_parni( 4 ) * ic == bm.bmWidth ) & ( hb_parni( 5 ) == bm.bmHeight ) )
         lResult = ImageList_AddMasked( ( HIMAGELIST ) hb_parnl( 1 ), himage, clrBk );

      DeleteObject( himage );
   }

   hb_retni( lResult );
}

HB_FUNC( IL_GETIMAGESIZE ) //IL_GetImageSize(  himage )
{
   int   cx, cy;

   ImageList_GetIconSize( (HIMAGELIST) hb_parnl(1), &cx, &cy );

   hb_reta( 2 );  // { cx, cy }
   HB_STORNI( cx, -1, 1 );
   HB_STORNI( cy, -1, 2 );
}

HB_FUNC( GETDATEPICKER )
{
   hb_retni( (LONG) DateTime_GetMonthCal((HWND) hb_parnl(1)) );
}

HWND EditPG( HWND hWnd, RECT rc, HTREEITEM hItem, int ItemType, PROPGRD ppgrd , BOOL DisEdit)
{
   static PHB_SYMB   pSymbol = NULL;
   HWND              hEdit;
   char              *cClass, *cName;

   int               Style = WS_CHILD | WS_VISIBLE;
   int               nBtn = 0;
   int               height = rc.bottom - rc.top - 1;

   cName = "";
   switch( ItemType )
   {
      case PG_DEFAULT:
      case PG_CATEG:
      case PG_STRING:
      case PG_INTEGER:
      case PG_DOUBLE:
      case PG_SYSINFO:
      case PG_SIZE:
      case PG_FLAG:
         Style = Style | WS_VISIBLE | ES_AUTOHSCROLL;
         if ( DisEdit )
            Style = Style | ES_READONLY;
         if ( ItemType == PG_INTEGER )
             Style = Style  | ES_NUMBER;
         cClass = "EDIT";
         break;

      case PG_COLOR:
      case PG_IMAGE:
      case PG_FILE:
      case PG_FOLDER:
      case PG_FONT:
      case PG_ARRAY:
      case PG_USERFUN:
         Style = Style | ES_AUTOHSCROLL;
         if ( DisEdit )
            Style = Style | ES_READONLY;
         cClass = "EDIT";
         nBtn = 1;
         break;

      case PG_PASSWORD:
         Style = Style | ES_AUTOHSCROLL | ES_PASSWORD;
         if ( DisEdit )
            Style = Style | ES_READONLY;
         cClass = "EDIT";
         break;
      case PG_LOGIC:
         Style = Style | WS_VSCROLL | CBS_DROPDOWNLIST | CBS_OWNERDRAWFIXED | CBS_HASSTRINGS;   // | CBS_AUTOHSCROLL;
         cClass = "COMBOBOX";
         height = 200;
         break;

      case PG_LIST:
         Style = Style | WS_VSCROLL | CBS_DROPDOWN | CBS_OWNERDRAWFIXED | CBS_HASSTRINGS ;//| CBS_AUTOHSCROLL;  ;
         cClass = "COMBOBOX";
         height = 200;
         break;

      case PG_SYSCOLOR:
      case PG_ENUM:
         Style = Style | WS_VSCROLL | CBS_DROPDOWNLIST | CBS_OWNERDRAWFIXED | CBS_HASSTRINGS;   // | CBS_AUTOHSCROLL;  ;
         cClass = "COMBOBOX";       //WC_COMBOBOXEX ;
         height = 200;
         break;

      case PG_DATE:
         Style = Style;             //|  DTS_UPDOWN ;
         cClass = DATETIMEPICK_CLASS;
         cName = "DateTime";
         break;

      default:
         cClass = "EDIT";
   }

   hEdit = CreateWindowEx
      (
         0,
         cClass,
         cName,
         Style,
         rc.left + 1,
         rc.top - 1,
         rc.right - rc.left - 1,
         height,
         hWnd,
         (HMENU) hb_parni(2),
         GetModuleHandle(NULL),
         NULL
      );

   switch( ItemType )
   {
      case PG_LOGIC:
         SendMessage( hEdit, CB_SETITEMHEIGHT, (WPARAM) - 1, (LPARAM) rc.bottom - rc.top - 6 );
         SendMessage( hEdit, CB_SETITEMHEIGHT, (WPARAM) 0, (LPARAM) rc.bottom - rc.top );
         break;

      case PG_COLOR:
      case PG_DATE:
      case PG_USERFUN:
         break;

      case PG_ENUM:
      case PG_LIST:
      case PG_SYSCOLOR:
         {
            SendMessage( hEdit, CB_SETITEMHEIGHT, (WPARAM) - 1, (LPARAM) rc.bottom - rc.top - 6 );
            break;
         }

      case PG_ARRAY:
         SendMessage( hEdit, CB_SETITEMHEIGHT, (WPARAM) - 1, (LPARAM) rc.bottom - rc.top - 6 );
   }

   InsertBtnPG( hEdit, hItem, nBtn, ItemType, ppgrd );

   if( !pSymbol )
   {
      pSymbol = hb_dynsymSymbol( hb_dynsymGet("_PGINITDATA") );
   }

   if( pSymbol )
   {
      hb_vmPushSymbol( pSymbol );
      hb_vmPushNil();
      hb_vmPushLong( (LONG) hWnd );
      hb_vmPushLong( (LONG) hEdit );
      hb_vmPushLong( (LONG) hItem );
      hb_vmPushLong( (LONG) ItemType );
      hb_vmDo( 4 );
   }

   return( hEdit );
}

LRESULT CALLBACK PGEditProc( HWND hEdit, UINT Msg, WPARAM wParam, LPARAM lParam )
{
   static PHB_SYMB   pSymbol = NULL;
   long int          r;
   WNDPROC           OldWndProc;
   HTREEITEM         hItem;
   HWND              hWndParent;
   RECT              *prect;
   RECT              oldrect;
   RECT              rect;
   POINT             pt;
   UINT              oldstate;

   // get the button state structure

   INSBTN            *pbtn = ( INSBTN * ) GetWindowLong( hEdit, GWL_USERDATA );
   OldWndProc = pbtn->oldproc;
   hItem = pbtn->hItem;
   hWndParent = GetParent( hEdit );

   switch( Msg )
   {
      case WM_NCDESTROY:
         OldWndProc = pbtn->oldproc;
         HeapFree( GetProcessHeap(), 0, pbtn );
         return CallWindowProc( OldWndProc, hEdit, Msg, wParam, lParam );

      case WM_GETDLGCODE:
         return DLGC_WANTALLKEYS;   //+DLGC_WANTARROWS+DLGC_WANTCHARS+DLGC_HASSETSEL ;

      case WM_NCCALCSIZE:
         {
            prect = ( RECT * ) lParam;
            oldrect = *prect;

            CallWindowProc( pbtn->oldproc, hEdit, Msg, wParam, lParam );
            SendMessage( hEdit, WM_SETREDRAW, 1, 0 );

            if( pbtn->nButton )
            {
               pbtn->cxLeftEdge = prect->left - oldrect.left;
               pbtn->cxRightEdge = oldrect.right - prect->right;
               pbtn->cyTopEdge = prect->top - oldrect.top;
               pbtn->cyBottomEdge = oldrect.bottom - prect->bottom;
               prect->right -= pbtn->cxButton;
            }

            return 0;
         }

      case WM_NCPAINT:
         {
            CallWindowProc( pbtn->oldproc, hEdit, Msg, wParam, lParam );
            if( pbtn->nButton )
            {
               GetWindowRect( hEdit, &rect );
               OffsetRect( &rect, -rect.left, -rect.top );

               GetBtnPG( pbtn, &rect );

               DrawInsBtnPG( hEdit, pbtn, &rect );
            }

            return 0;
         }

      case WM_NCHITTEST:
         if( pbtn->nButton )
         {
            pt.x = LOWORD( lParam );
            pt.y = HIWORD( lParam );

            GetWindowRect( hEdit, &rect );
            GetBtnPG( pbtn, &rect );

            if( PtInRect(&rect, pt) )
            {
               return HTBORDER;
            }
         }
         break;

      case WM_NCLBUTTONDBLCLK:
      case WM_NCLBUTTONDOWN:
         if( pbtn->nButton )
         {
            pt.x = LOWORD( lParam );
            pt.y = HIWORD( lParam );

            GetWindowRect( hEdit, &rect );
            pt.x -= rect.left;
            pt.y -= rect.top;
            OffsetRect( &rect, -rect.left, -rect.top );
            GetBtnPG( pbtn, &rect );

            if( PtInRect(&rect, pt) )
            {
               SetCapture( hEdit );
               pbtn->fButtonDown = TRUE;
               pbtn->fMouseDown = TRUE;
               DrawInsBtnPG( hEdit, pbtn, &rect );
            }
         }
         break;

      case WM_MOUSEMOVE:
         if( pbtn->nButton )
         {
            if( pbtn->fMouseDown == TRUE )
            {
               pt.x = LOWORD( lParam );
               pt.y = HIWORD( lParam );
               ClientToScreen( hEdit, &pt );

               GetWindowRect( hEdit, &rect );

               pt.x -= rect.left;
               pt.y -= rect.top;
               OffsetRect( &rect, -rect.left, -rect.top );

               GetBtnPG( pbtn, &rect );

               oldstate = pbtn->fButtonDown;

               if( PtInRect(&rect, pt) )
               {
                  pbtn->fButtonDown = 1;
               }
               else
               {
                  pbtn->fButtonDown = 0;
               }

               if( oldstate != pbtn->fButtonDown )
               {
                  DrawInsBtnPG( hEdit, pbtn, &rect );
               }
            }
         }
         break;

      case WM_KEYDOWN:
         if( wParam == VK_DOWN )
         {
            LPSTR cData[1024];
            GetWindowText( hEdit, (LPSTR) cData, 1024 );
            Pg_SetData( GetParent(hEdit), pbtn->hItem, (LPSTR) cData, "", FALSE );
            PostMessage( GetParent(hEdit), WM_KEYDOWN, VK_DOWN, MAKEWPARAM(0, 0) );
            SetFocus( GetParent(hEdit) );
         }

         if( wParam == VK_UP )
         {
            LPSTR cData[1024];
            GetWindowText( hEdit, (LPSTR) cData, 1024 );
            Pg_SetData( GetParent(hEdit), pbtn->hItem, (LPSTR) cData, "", FALSE );
            PostMessage( GetParent(hEdit), WM_KEYDOWN, VK_UP, MAKEWPARAM(0, 0) );
            SetFocus( GetParent(hEdit) );
         }
         break;

      case WM_LBUTTONUP:
         if( pbtn->nButton )
         {
            if( pbtn->fMouseDown == TRUE )
            {
               pt.x = LOWORD( lParam );
               pt.y = HIWORD( lParam );
               ClientToScreen( hEdit, &pt );

               GetWindowRect( hEdit, &rect );

               pt.x -= rect.left;
               pt.y -= rect.top;
               OffsetRect( &rect, -rect.left, -rect.top );

               GetBtnPG( pbtn, &rect );

               if( PtInRect(&rect, pt) )
               {
                  PostMessage( hEdit, WM_COMMAND, MAKEWPARAM(pbtn->ItemType, BN_CLICKED), (LPARAM) hItem );
                  SetFocus( hEdit );
               }

               ReleaseCapture();
               pbtn->fButtonDown = FALSE;
               pbtn->fMouseDown = FALSE;

               DrawInsBtnPG( hEdit, pbtn, &rect );
            }
         }
         break;

      case WM_CHAR:
         if( wParam == 13 )
         {
            LPSTR cData[1024];
            GetWindowText( hEdit, (LPSTR) cData, 1024 );
            Pg_SetData( GetParent(hEdit), pbtn->hItem, (LPSTR) cData, "", FALSE );
            PostMessage( GetParent(hEdit), WM_KEYDOWN, VK_DOWN, MAKEWPARAM(0, 0) );
            SetFocus( GetParent(hEdit) );
         }
         break;

      case WM_CREATE:
      case WM_NCCREATE:
      case WM_COMMAND:
      case WM_SETFOCUS:
         {
            if( !pSymbol )
            {
               pSymbol = hb_dynsymSymbol( hb_dynsymGet("OPGEDITEVENTS") );
            }

            if( pSymbol )
            {
               hb_vmPushSymbol( pSymbol );
               hb_vmPushNil();
               hb_vmPushLong( (LONG) hEdit );
               hb_vmPushLong( Msg );
               hb_vmPushLong( wParam );
               hb_vmPushLong( lParam );
               hb_vmPushLong( (LONG) hWndParent );
               hb_vmPushLong( (LONG) hItem );
               hb_vmDo( 6 );
            }

            r = hb_parnl( -1 );

            if( r != 0 )
            {
               return r;
            }
            else
            {
               return( CallWindowProc(OldWndProc, hEdit, Msg, wParam, lParam) );
            }
         }

      case WM_KILLFOCUS:
         {
            if( pbtn->ppgrd.hItemEdit )
            {
               PostMessage( pbtn->ppgrd.hPropEdit, WM_CLOSE, 0, 0 );
               pbtn->ppgrd.hItemEdit = 0;
            }

            if( !pSymbol )
            {
               pSymbol = hb_dynsymSymbol( hb_dynsymGet("OPGEDITEVENTS") );
            }

            if( pSymbol )
            {
               hb_vmPushSymbol( pSymbol );
               hb_vmPushNil();
               hb_vmPushLong( (LONG) hEdit );
               hb_vmPushLong( Msg );
               hb_vmPushLong( wParam );
               hb_vmPushLong( lParam );
               hb_vmPushLong( (LONG) hWndParent );
               hb_vmPushLong( (LONG) hItem );
               hb_vmDo( 6 );
            }

            r = hb_parnl( -1 );

            if( r != 0 )
            {
               return r;
            }
            else
            {
               return( CallWindowProc(OldWndProc, hEdit, Msg, wParam, lParam) );
            }
         }
   }

   return( CallWindowProc(OldWndProc, hEdit, Msg, wParam, lParam) );
}

#if defined( __BORLANDC__ )
#pragma argsused
#endif

int CALLBACK enumFontFamilyProc( ENUMLOGFONTEX *lpelfe, NEWTEXTMETRICEX *lpntme, DWORD FontType, LPARAM lParam )
{
#if defined( __MINGW32__ )
   UNREFERENCED_PARAMETER( lpntme );
#endif
   if( lpelfe && lParam )
   {
      if( FontType == TRUETYPE_FONTTYPE )
      {  //DEVICE_FONTTYPE | RASTER_FONTTYPE
         SendMessage( (HWND) lParam, CB_ADDSTRING, 0, (LPARAM) (LPSTR) lpelfe->elfFullName );
      }
   }

   return 1;
}

void enumFonts( HWND hWndEdit )  // , BYTE lfCharSet)
{
   LOGFONT  lf;
   HDC      hDC = GetDC( NULL );
   HWND     hWnd = hWndEdit;
   lf.lfCharSet = ANSI_CHARSET;
   lf.lfPitchAndFamily = 0;
   strcpy( lf.lfFaceName, "\0" );

   EnumFontFamiliesEx( hDC, &lf, (FONTENUMPROC) enumFontFamilyProc, (LPARAM) hWnd, 0 );

   ReleaseDC( NULL, hDC );
}

HB_FUNC( PG_GETFONTS )
{
   enumFonts( (HWND) hb_parnl(1) );
}

HB_FUNC( DIALOGUNITSX)
{
   int  baseunitX = LOWORD( GetDialogBaseUnits() );

   hb_retni( ((INT) hb_parni(1) * 4 )/ baseunitX );
}

HB_FUNC( DIALOGUNITSY)
{
   int  baseunitY =  HIWORD( GetDialogBaseUnits() );

   hb_retni( ((INT) hb_parni(1) * 8 )/ baseunitY );
}
