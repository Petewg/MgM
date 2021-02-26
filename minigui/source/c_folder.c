/*----------------------------------------------------------------------------
   MINIGUI - Harbour Win32 GUI library source code

   Copyright 2002-2010 Roberto Lopez <harbourminigui@gmail.com>
   http://harbourminigui.googlepages.com/

   FOLDER form source code
   (c)2005-2009 Janusz Pora <januszpora@onet.eu>

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
    Copyright 1999-2020, https://harbour.github.io/

    "WHAT32"
    Copyright 2002 AJ Wos <andrwos@aust1.net>

    "HWGUI"
    Copyright 2001-2018 Alexander S.Kresin <alex@kresin.ru>

   ---------------------------------------------------------------------------*/

#define _WIN32_IE  0x0501

#include <mgdefs.h>

#if defined( _MSC_VER )
#pragma warning ( disable:4996 )
#endif
#include <commctrl.h>

#include "hbapiitm.h"
#include "hbvm.h"

#define FLBTN_OK         1
#define FLBTN_APPLY      2
#define FLBTN_CANCEL     3
#define FLBTN_HELP       4

#define FLN_FIRST        ( 0U - 200U )
#define FLN_SETACTIVE    ( FLN_FIRST - 0 )
#define FLN_KILLACTIVE   ( FLN_FIRST - 1 )
#define FLN_APPLY        ( FLN_FIRST - 2 )
#define FLN_RESET        ( FLN_FIRST - 3 )
#define FLN_HELP         ( FLN_FIRST - 5 )
#define FLN_QUERYCANCEL  ( FLN_FIRST - 6 )
#define FLN_FINISH       ( FLN_FIRST - 7 )

extern PWORD   CreateDlgTemplate( long lTemplateSize, PHB_ITEM dArray, PHB_ITEM cArray );
extern long    GetSizeDlgTemp( PHB_ITEM dArray, PHB_ITEM cArray );

extern HB_PTRUINT wapi_GetProcAddress( HMODULE hmodule, LPCTSTR lpProcName );

typedef BOOL ( WINAPI * fnIsAppThemed )( void );

HINSTANCE GetInstance( void );
HINSTANCE GetResources( void );

static HINSTANCE hUxTheme;

struct _FPI;
typedef struct _FPI FAR * HFLDPAGEINFO;
struct tag_FldPageInfo;


typedef struct tag_FldPageInfo
{
   HWND hwndPage;
   DLGTEMPLATE * apRes;
   BOOL          isDirty;
   LPCTSTR       pszText;
   LPCTSTR       pszTemplate;
   DWORD         dwFlags;
   int  idrc;
   BOOL useCallback;
   BOOL hasIcon;
} FLDPAGEINFO;
typedef const FLDPAGEINFO FAR * LPCFLDPAGEINFO;

//HFLDPAGE
typedef struct tag_fldhdr
{
   HWND hwnd;                                // Folder handle
   HWND hwndTab;                             // tab control
   HWND hwndDisplay;                         // current child dialog box
   RECT rcDisplay;                           // display rectangle for the tab control
   RECT rcFolder;                            // rectangle for the folder control
   HFLDPAGEINFO FAR * fhpage;
   int        nPages;
   int        x;
   int        y;
   int        cx;
   int        cy;
   int        active_page;
   BOOL       isInDirect;
   BOOL       isModal;
   BOOL       hasOk;
   BOOL       hasApply;
   BOOL       hasCancel;
   BOOL       hasHelp;
   BOOL       activeValid;
   BOOL       ended;
   int        width;
   int        height;
   int        nIdFld;
   int        FolderStyle;
   HIMAGELIST hImageList;
} FLDHDRINFO;

typedef struct
{
   WORD  dlgVer;
   WORD  signature;
   DWORD helpID;
   DWORD exStyle;
   DWORD style;
   WORD  cDlgItems;
   short x;
   short y;
   short cx;
   short cy;
} MyDLGTEMPLATEEX;

typedef struct
{
   int x;
   int y;
} PADDING_INFO;

typedef struct _FLHNOTIFY
{
   NMHDR  hdr;
   LPARAM lParam;
} FLHNOTIFY, FAR * LPFLHNOTIFY;

VOID WINAPI FLD_FolderInit( HWND hWndDlg, FLDHDRINFO * pFhi );
DLGTEMPLATE * WINAPI FLD_SetStyleDlgRes( DLGTEMPLATE * pTemplate, DWORD resSize );
DLGTEMPLATE * WINAPI FLD_LockDlgRes( LPCSTR lpszResName );
BOOL WINAPI IsAppThemed( void );
VOID WINAPI       FLD_SelChanged( HWND hWndDlg );
VOID WINAPI       FLD_ChildDialogInit( HWND hWndDlg, HWND hWndParent, int idrc );
LRESULT CALLBACK  HMG_PageFldProc( HWND hWnd, UINT message, WPARAM wParam, LPARAM lParam );
VOID WINAPI       FLD_DialogAlign( HWND hWndDlg );
static BOOL       FLD_PageInfo( DLGTEMPLATE * pTemplate, FLDHDRINFO * pFhi, int index, BOOL resize );
static BOOL       FLD_DoCommand( HWND hWndDlg, WORD wID );
static BOOL       FLD_Apply( HWND hWndDlg, LPARAM lParam );
static void       FLD_Cancel( HWND hWndDlg, LPARAM lParam );
static BOOL       FLD_ShowPage( HWND hWndDlg, int index, FLDHDRINFO * pFhi );
static void       FLD_Changed( HWND hWndParent, HWND hWndDlg );
static void       FLD_UnChanged( HWND hWndParent, HWND hWndDlg );
static LRESULT    FLD_HwndToIndex( HWND hWndDlg, HWND hPageDlg );
static void       FLD_CleanUp( HWND hWndDlg );
static void       FLD_Help( HWND hwndDlg );
static void       FLD_AddBitmap( HWND hWndFolder );
static BOOL       FLD_isAppThemed( void );


static BOOL FLD_isAppThemed( void )
{
   BOOL bRet = FALSE;

   if( hUxTheme == NULL )
      hUxTheme = LoadLibraryEx( TEXT( "uxtheme.dll" ), NULL, 0 );

   if( hUxTheme )
   {
      fnIsAppThemed pfn = ( fnIsAppThemed ) wapi_GetProcAddress( hUxTheme, "IsAppThemed" );
      if( pfn )
         bRet = ( BOOL ) pfn();
   }

   return bRet;
}

LRESULT CALLBACK HMG_FldProc( HWND hWndDlg, UINT message, WPARAM wParam, LPARAM lParam )
{
   static PHB_SYMB pSymbol = NULL;
   long int        r;
   LPNMHDR         lpnmhdr;
   FLDHDRINFO *    pFhi;

   switch( message )
   {
      // wNotifyCode = HIWORD(wParam); // notification code
      // wID = LOWORD(wParam);         // item, control, or accelerator identifier
      // hwndCtl = (HWND) lParam;      // handle of control
      case WM_INITDIALOG:
         pFhi = ( FLDHDRINFO * ) lParam;
         FLD_FolderInit( hWndDlg, pFhi );
         FLD_AddBitmap(  hWndDlg );
         break;

      case WM_CLOSE:
         FLD_Cancel( hWndDlg, 0 );
         break;

      case WM_MOVE:
         FLD_DialogAlign( hWndDlg );
         return FALSE;

      case WM_COMMAND:
         if( lParam != 0 && HIWORD( wParam ) == BN_CLICKED )
            if( ! FLD_DoCommand( hWndDlg, LOWORD( wParam ) ) )
            {
               pFhi = ( FLDHDRINFO * ) GetWindowLongPtr( hWndDlg, GWLP_USERDATA );
               if( ! pFhi )
                  return FALSE;

               /* No default handler, forward notification to active page */
               if( pFhi->activeValid && pFhi->active_page != -1 )
               {
                  HFLDPAGEINFO * hfpi = pFhi->fhpage;
                  FLDPAGEINFO *  fpi  = ( FLDPAGEINFO * ) hfpi[ pFhi->active_page ];
                  HWND hwndPage       = fpi->hwndPage;
                  SendMessage( hwndPage, WM_COMMAND, wParam, lParam );
               }
            }

         return TRUE;

      case WM_NOTIFY:
         lpnmhdr = ( NMHDR FAR * ) lParam;
         if( lpnmhdr != 0 )
            if( lpnmhdr->code == TCN_SELCHANGE )
               FLD_SelChanged( hWndDlg );

         return FALSE;
   }

   if( ! pSymbol )
      pSymbol = hb_dynsymSymbol( hb_dynsymGet( "FOLDERPROC" ) );

   if( pSymbol )
   {
      hb_vmPushSymbol( pSymbol );
      hb_vmPushNil();
      hb_vmPushNumInt( ( LONG_PTR ) hWndDlg );
      hb_vmPushLong( message );
      hb_vmPushNumInt( wParam );
      hb_vmPushNumInt( lParam );
      hb_vmDo( 4 );
   }

   r = hb_parnl( -1 );
   if( r )
      return TRUE;
   else
      return FALSE;
}

LRESULT CALLBACK HMG_PageFldProc( HWND hWndDlg, UINT message, WPARAM wParam, LPARAM lParam )
{
   static PHB_SYMB pSymbol = NULL;
   long int        r;
   int  iSel;
   HWND hWndParent;
   FLDPAGEINFO *  fpi;
   HFLDPAGEINFO * hfpi;
   FLDHDRINFO *   pFhi;

   hWndParent = GetParent( hWndDlg );
   switch( message )
   {
      // wNotifyCode = HIWORD(wParam); // notification code
      // wID = LOWORD(wParam);         // item, control, or accelerator identifier
      // HWND hwndCtl = (HWND) lParam;      // handle of control
      case WM_INITDIALOG:
         pFhi = ( FLDHDRINFO * ) lParam;
         iSel = TabCtrl_GetCurSel( pFhi->hwndTab );
         hfpi = pFhi->fhpage;
         fpi  = ( FLDPAGEINFO * ) hfpi[ iSel ];

         FLD_ChildDialogInit( hWndDlg, hWndParent, fpi->idrc );
         return TRUE;
   }

   if( ! pSymbol )
      pSymbol = hb_dynsymSymbol( hb_dynsymGet( "PAGEFLDPROC" ) );

   if( pSymbol )
   {
      hb_vmPushSymbol( pSymbol );
      hb_vmPushNil();
      hb_vmPushNumInt( ( LONG_PTR ) hWndDlg );
      hb_vmPushLong( message );
      hb_vmPushNumInt( wParam );
      hb_vmPushNumInt( lParam );
      hb_vmDo( 4 );
   }

   r = hb_parnl( -1 );
   if( r )
      return TRUE;
   else
      return FALSE;
}

/****************************************************************************
      CreateFolderPageIndirect(_HMG_aFolderPagesTemp, _HMG_aFolderTemplate, _HMG_aDialogItems)
 *****************************************************************************/
HB_FUNC( CREATEFOLDERPAGEINDIRECT )
{
   DLGTEMPLATE * pdlgtemplate;
   FLDPAGEINFO * pfpi = ( FLDPAGEINFO * ) LocalAlloc( LPTR, sizeof( FLDPAGEINFO ) );

   char * strTitle;
   int    idRC, PageStyle;
   char * ImageName;

   PHB_ITEM sArray;
   PHB_ITEM dArray;
   PHB_ITEM cArray;

   long lTemplateSize;

   sArray        = hb_param( 1, HB_IT_ARRAY ); //Folder Array
   dArray        = hb_param( 2, HB_IT_ARRAY ); //Folder Page Array
   cArray        = hb_param( 3, HB_IT_ARRAY ); //Page Controls Array
   lTemplateSize = GetSizeDlgTemp( dArray, cArray );
   pdlgtemplate  = ( DLGTEMPLATE * ) CreateDlgTemplate( lTemplateSize, dArray, cArray );
   ZeroMemory( pfpi, sizeof( FLDPAGEINFO ) );

   strTitle  = ( char * ) hb_arrayGetCPtr( sArray, 1 );  // Tab Title
   idRC      = hb_arrayGetNI( sArray, 2 );               // Id Dialog resource
   PageStyle = hb_arrayGetNI( sArray, 3 );               // Page Style
   ImageName = ( char * ) hb_arrayGetCPtr( sArray, 4 );

   pfpi->dwFlags  = PageStyle;
   pfpi->pszText  = strTitle;
   pfpi->idrc     = idRC;
   pfpi->apRes    = ( DLGTEMPLATE * ) pdlgtemplate;
   pfpi->hwndPage = 0;
   pfpi->isDirty  = FALSE;
   if( strlen( ImageName ) )
   {
      pfpi->hasIcon     = TRUE;
      pfpi->pszTemplate = ImageName;
   }

   HB_RETNL( ( LONG_PTR ) ( HFLDPAGEINFO ) pfpi );
}

/****************************************************************************
      CreateFolderPage(_HMG_aFolderPagesTemp)
 *****************************************************************************/
HB_FUNC( CREATEFOLDERPAGE )
{
   FLDPAGEINFO * pfpi = ( FLDPAGEINFO * ) LocalAlloc( LPTR, sizeof( FLDPAGEINFO ) );

   PHB_ITEM sArray;
   char *   strTitle;
   int      idRC, PageStyle;
   char *   caption;

   sArray = hb_param( 1, HB_IT_ARRAY );

   ZeroMemory( pfpi, sizeof( FLDPAGEINFO ) );

   strTitle          = ( char * ) hb_arrayGetCPtr( sArray, 1 ); // Caption
   idRC              = hb_arrayGetNI( sArray, 2 );              // Id Dialog resource
   PageStyle         = hb_arrayGetNI( sArray, 3 );              // Page Style
   caption           = ( char * ) hb_arrayGetCPtr( sArray, 4 ); // Page Image
   pfpi->dwFlags     = PageStyle;
   pfpi->pszTemplate = MAKEINTRESOURCE( idRC );
   pfpi->pszText     = strTitle;
   pfpi->idrc        = idRC;

   pfpi->apRes    = FLD_LockDlgRes( MAKEINTRESOURCE( idRC ) );
   pfpi->hwndPage = 0;
   pfpi->isDirty  = FALSE;
   if( strlen( caption ) )
   {
      pfpi->hasIcon     = TRUE;
      pfpi->pszTemplate = caption;
   }

   HB_RETNL( ( LONG_PTR ) ( HFLDPAGEINFO ) pfpi );
}

/****************************************************************************
      CreateDlgFolder( IdFld, _HMG_ActiveFolderHandle, aHwndFolderPages, _HMG_aFolderTemplate, _HMG_aDialogItems, _HMG_FolderInMemory )
 *****************************************************************************/
HB_FUNC( CREATEDLGFOLDER )
{
   HFLDPAGEINFO * hfpi;
   FLDHDRINFO *   pFhi      = ( FLDHDRINFO * ) LocalAlloc( LPTR, sizeof( FLDHDRINFO ) );
   DWORD          dwDlgBase = GetDialogBaseUnits();
   int baseunitX = LOWORD( dwDlgBase ), baseunitY = HIWORD( dwDlgBase );
   LPDLGTEMPLATE pdlgtemplate;
   HWND          hwnd;
   HWND          hWndDlg;

   PHB_ITEM sArray;
   PHB_ITEM pArray;
   PHB_ITEM cArray;

   BOOL    modal;
   LRESULT lResult;
   long    lTemplateSize;
   int     s, nPages, Style, nIdFld;
   int     x, y, cx, cy;

   nIdFld  = ( int ) hb_parni( 1 );
   hWndDlg = ( HWND ) HB_PARNL( 2 );

   sArray = hb_param( 3, HB_IT_ARRAY );      // aHwndFolderPages
   pArray = hb_param( 4, HB_IT_ARRAY );      //_HMG_aFolderTemplate
   cArray = hb_param( 5, HB_IT_ARRAY );      //_HMG_aDialogItems

   //  _HMG_aFolderTemplate := {0,ParentHandle,modal,style,styleEx ,x,y,w,h,caption,fontname,fontsize,bold,Italic,lApplyBtn,lCancelBtn}
   //  _HMG_aFolderTemplate -> {0,ParentHandle,modal,style,styleEx ,x,y,w,h,caption,fontname,fontsize,bold,Italic,lOkBtn,lApplyBtn,lCancelBtn, buttons , flat , hottrack , vertical , bottom, multiline}
   modal = hb_arrayGetL( pArray, 3 );

   nPages = ( int ) hb_arrayLen( sArray );
   x      = hb_arrayGetNI( pArray, 6 );      //x
   y      = hb_arrayGetNI( pArray, 7 );      //y
   cx     = hb_arrayGetNI( pArray, 8 );      //w
   cy     = hb_arrayGetNI( pArray, 9 );      //h
   Style  = WS_CHILD | WS_VISIBLE;
   if( hb_arrayGetL( pArray, 19 ) )
      Style = Style | TCS_BUTTONS;

   if( hb_arrayGetL( pArray, 20 ) )
      Style = Style | TCS_FLATBUTTONS;

   if( hb_arrayGetL( pArray, 21 ) )
      Style = Style | TCS_HOTTRACK;

   if( hb_arrayGetL( pArray, 22 ) )
      Style = Style | TCS_VERTICAL;

   if( hb_arrayGetL( pArray, 23 ) )
      Style = Style | TCS_BOTTOM;

   if( hb_arrayGetL( pArray, 24 ) )
      Style = Style | TCS_MULTILINE;

   hfpi = ( HFLDPAGEINFO * ) malloc( sizeof( HFLDPAGEINFO ) * nPages );

   for( s = 0; s < nPages; s = s + 1 )
      hfpi[ s ] = ( HFLDPAGEINFO ) ( PHB_ITEM ) HB_arrayGetNL( sArray, s + 1 );

   hwnd = ( HWND ) HB_arrayGetNL( pArray, 2 );

   //Fill out the FOLDERHEADERINFO
   pFhi->hwnd        = hWndDlg;
   pFhi->fhpage      = hfpi;
   pFhi->nPages      = nPages;
   pFhi->x           = MulDiv( x, 4, baseunitX );  // x
   pFhi->y           = MulDiv( y, 8, baseunitY );  // y
   pFhi->cx          = MulDiv( cx, 4, baseunitX ); // cx
   pFhi->cy          = MulDiv( cy, 8, baseunitY ); // cy
   pFhi->hasOk       = hb_arrayGetL( pArray, 15 );
   pFhi->hasApply    = hb_arrayGetL( pArray, 16 );
   pFhi->hasCancel   = hb_arrayGetL( pArray, 17 );
   pFhi->hasHelp     = hb_arrayGetL( pArray, 18 );
   pFhi->activeValid = FALSE;
   pFhi->active_page = -1;
   pFhi->isInDirect  = ( BOOL ) hb_parl( 6 ); //InMemory;
   pFhi->nIdFld      = nIdFld;
   pFhi->FolderStyle = Style;

   lTemplateSize = GetSizeDlgTemp( pArray, cArray );
   pdlgtemplate  = ( LPDLGTEMPLATE ) CreateDlgTemplate( lTemplateSize, pArray, cArray );

   if( modal )
   {
      lResult = DialogBoxIndirectParam( GetResources(), ( LPDLGTEMPLATE ) pdlgtemplate, hwnd, ( DLGPROC ) HMG_FldProc, ( LPARAM ) pFhi );
      LocalFree( pdlgtemplate );
      HB_RETNL( ( LONG_PTR ) lResult );
   }
   else
   {
      hWndDlg = CreateDialogIndirectParam( GetResources(), ( LPDLGTEMPLATE ) pdlgtemplate, hwnd, ( DLGPROC ) HMG_FldProc, ( LPARAM ) pFhi );
      LocalFree( pdlgtemplate );
   }

   HB_RETNL( ( LONG_PTR ) hWndDlg );
}

/****************************************************************************
      FolderHwndToIndex(hWndParent, hWndDlg)
 *****************************************************************************/
HB_FUNC( FOLDERHWNDTOINDEX )
{
   int iPageIndex;

   iPageIndex = ( int ) FLD_HwndToIndex( ( HWND ) HB_PARNL( 1 ), ( HWND ) HB_PARNL( 2 ) );

   hb_retni( iPageIndex );
}

/****************************************************************************
      FolderGetCurrentPageHwnd( hWndParent )
 *****************************************************************************/
HB_FUNC( FOLDERGETCURRENTPAGEHWND )
{
   HWND hWndDlg = ( HWND ) HB_PARNL( 1 );
   int  iSel;

   FLDHDRINFO *   pFhi = ( FLDHDRINFO * ) GetWindowLongPtr( hWndDlg, GWLP_USERDATA );
   FLDPAGEINFO *  fpi;
   HFLDPAGEINFO * hfpi;

   hfpi = pFhi->fhpage;
   iSel = TabCtrl_GetCurSel( pFhi->hwndTab );

   fpi = ( FLDPAGEINFO * ) hfpi[ iSel ];

   HB_RETNL( ( LONG_PTR ) fpi->hwndPage );
}

/****************************************************************************
      Folder_Changed(hWndParent, hWndDlg)
 *****************************************************************************/
HB_FUNC( FOLDER_CHANGED )
{
   HWND hWndParent = ( HWND ) HB_PARNL( 1 );
   HWND hWndDlg    = ( HWND ) HB_PARNL( 2 );

   FLD_Changed( hWndParent, hWndDlg );
}

/****************************************************************************
      Folder_UnChanged(hWndParent, hWndDlg)
 *****************************************************************************/
HB_FUNC( FOLDER_UNCHANGED )
{
   HWND hWndParent = ( HWND ) HB_PARNL( 1 );
   HWND hWndDlg    = ( HWND ) HB_PARNL( 2 );

   FLD_UnChanged( hWndParent, hWndDlg );
}

/******************************************************************************
      Folder_IsDirty( hWndParent )
 *****************************************************************************/
HB_FUNC( FOLDER_ISDIRTY )
{
   HWND hWndParent = ( HWND ) HB_PARNL( 1 );
   int  i;
   BOOL lPageDirty = FALSE;

   FLDHDRINFO * pFhi = ( FLDHDRINFO * ) GetWindowLongPtr( hWndParent, GWLP_USERDATA );

   if( ! pFhi )
      return;

   for( i = 0; i < pFhi->nPages; i++ )
   {
      HFLDPAGEINFO * hfpi = pFhi->fhpage;
      FLDPAGEINFO *  fpi  = ( FLDPAGEINFO * ) hfpi[ i ];

      /* look to see if there's any dirty pages */
      if( fpi->isDirty && ! pFhi->activeValid )
         lPageDirty = TRUE;
   }

   hb_retl( ( BOOL ) lPageDirty );
}

/******************************************************************************
      Folder_IsFinish( hWndParent )
 *****************************************************************************/
HB_FUNC( FOLDER_ISFINISH )
{
   HWND hWndParent = ( HWND ) HB_PARNL( 1 );
   BOOL lFooderFinish;

   FLDHDRINFO * pFhi = ( FLDHDRINFO * ) GetWindowLongPtr( hWndParent, GWLP_USERDATA );

   if( ! pFhi->isModal )
      lFooderFinish = ! pFhi->activeValid;
   else
      lFooderFinish = pFhi->ended;

   hb_retl( ( BOOL ) lFooderFinish );
}

/******************************************************************************
      Folder_GetIdFld( hWndParent )
 *****************************************************************************/
HB_FUNC( FOLDER_GETIDFLD )
{
   HWND hWndParent   = ( HWND ) HB_PARNL( 1 );
   FLDHDRINFO * pFhi = ( FLDHDRINFO * ) GetWindowLongPtr( hWndParent, GWLP_USERDATA );

   if( ! pFhi )
      hb_retni( ( int ) hb_parni( 2 ) );
   else
      hb_retni( ( int ) pFhi->nIdFld );
}

/******************************************************************************
      Folder_GetTabHandle( hWndParent )
 *****************************************************************************/
HB_FUNC( FOLDER_GETTABHANDLE )
{
   HWND hWndParent   = ( HWND ) HB_PARNL( 1 );
   FLDHDRINFO * pFhi = ( FLDHDRINFO * ) GetWindowLongPtr( hWndParent, GWLP_USERDATA );

   if( ! pFhi )
      hb_retnl( 0 );
   else
      HB_RETNL( ( LONG_PTR ) pFhi->hwndTab );
}

/******************************************************************************
      Folder_CleanUp( hWndParent )
 *****************************************************************************/
HB_FUNC( FOLDER_CLEANUP )
{
   FLD_CleanUp( ( HWND ) HB_PARNL( 1 ) );
}

/*-----------------------------------------------------------------
      FLD_FolderInit()
   -----------------------------------------------------------------*/
VOID WINAPI FLD_FolderInit( HWND hWndDlg, FLDHDRINFO * pFhi )
{
   HFLDPAGEINFO * hfpi;
   FLDPAGEINFO *  fpi;
   DLGTEMPLATE *  pTemplate;
   OSVERSIONINFO  osvi;

   DWORD  dwDlgBase = GetDialogBaseUnits();
   int    cxMargin  = LOWORD( dwDlgBase ) / 4;
   int    cyMargin  = HIWORD( dwDlgBase ) / 8;
   TCITEM tie;
   RECT   rcTab;
   HWND   hwndButton;
   RECT   rcButton;
   int    i, s, nPages, Style;

   // Save a pointer to the FLDHDR structure.
   SetWindowLongPtr( hWndDlg, GWLP_USERDATA, ( LONG_PTR ) pFhi );

   osvi.dwOSVersionInfoSize = sizeof( OSVERSIONINFO );
   GetVersionEx( &osvi );

   nPages = pFhi->nPages;
   hfpi   = pFhi->fhpage;
   Style  = pFhi->FolderStyle;

   // Create the tab control.
   InitCommonControls();
   pFhi->hwndTab = CreateWindow( WC_TABCONTROL, "", Style, 0, 0, 100, 100, hWndDlg, NULL, GetInstance(), NULL );

   if( pFhi->hwndTab == NULL )
      MessageBox
      (
         NULL,
         TEXT( "Tab Control for Folder could not be created" ),
         TEXT( "Error" ),
         MB_OK | MB_ICONERROR | MB_DEFBUTTON1 | MB_APPLMODAL | MB_SETFOREGROUND
      );

   tie.mask   = TCIF_TEXT | TCIF_IMAGE;
   tie.iImage = -1;

   for( s = 0; s < nPages; s = s + 1 )
   {
      fpi         = ( FLDPAGEINFO * ) hfpi[ s ];
      tie.pszText = ( LPTSTR ) fpi->pszText;
      TabCtrl_InsertItem( pFhi->hwndTab, s, &tie );
   }

   // Determine the bounding rectangle for all child dialog boxes.
   SetRectEmpty( &rcTab );

   //The x, y, cx, and cy members specify values in dialog box units.
   for( i = 0; i < nPages; i++ )
   {
      fpi = ( FLDPAGEINFO * ) hfpi[ i ];
      if( ! pFhi->isInDirect )
      {
         pTemplate = ( DLGTEMPLATE * ) fpi->apRes;
         FLD_PageInfo( pTemplate, pFhi, i, TRUE );
      }
   }

   if( pFhi->cx > rcTab.right )
      rcTab.right = pFhi->cx;

   if( pFhi->cy > rcTab.bottom )
      rcTab.bottom = pFhi->cy;

   rcTab.right  = rcTab.right * LOWORD( dwDlgBase ) / 4;
   rcTab.bottom = rcTab.bottom * HIWORD( dwDlgBase ) / 8;

   // Calculate how large to make the tab control, so
   // the display area can accommodate all the child dialog boxes.
   TabCtrl_AdjustRect( pFhi->hwndTab, TRUE, &rcTab );
   OffsetRect( &rcTab, cxMargin - rcTab.left, cyMargin - rcTab.top );

   // Calculate the display rectangle.
   CopyRect( &pFhi->rcDisplay, &rcTab );
   TabCtrl_AdjustRect( pFhi->hwndTab, FALSE, &pFhi->rcDisplay );

   // Set the size and position of the tab control, buttons and dialog box.
   SetWindowPos( pFhi->hwndTab, NULL, rcTab.left, rcTab.top, rcTab.right - rcTab.left, rcTab.bottom - rcTab.top, SWP_NOZORDER );

   // Created and position of the buttons
   {
      int x, y;
      int num_buttons  = 0;
      int buttonWidth  = 0;
      int buttonHeight = 0;
      int cx = FLD_isAppThemed() ? 2 : 0;

      if( cx )
         cx = osvi.dwMajorVersion >= 6 ? 4 : cx;

      if( hUxTheme != NULL )
      {
         FreeLibrary( hUxTheme );
         hUxTheme = NULL;
      }

      rcButton.bottom = 0;
      rcButton.right  = 0;
      if( pFhi->hasOk )
         num_buttons++;

      if( pFhi->hasApply )
         num_buttons++;

      if( pFhi->hasCancel )
         num_buttons++;

      if( pFhi->hasHelp )
         num_buttons++;

      if( num_buttons > 0 )
      {
         y = rcTab.bottom + cyMargin;
         if( pFhi->hasOk )
         {
            // Move the first button "OK" below the tab control.
            hwndButton = GetDlgItem( hWndDlg, FLBTN_OK );
            GetWindowRect( hwndButton, &rcButton );
            buttonWidth  = rcButton.right - rcButton.left;
            buttonHeight = rcButton.bottom - rcButton.top;
            x = rcTab.right - cx - ( ( cxMargin + buttonWidth ) * num_buttons );

            SetWindowPos( hwndButton, 0, x, y, 0, 0, SWP_NOSIZE | SWP_NOZORDER | SWP_NOACTIVATE );
            num_buttons--;
         }

         if( pFhi->hasCancel )
         {
            // Move the second button "Cancel" to the right of the first.
            hwndButton = GetDlgItem( hWndDlg, FLBTN_CANCEL );
            if( buttonHeight == 0 )
            {
               GetWindowRect( hwndButton, &rcButton );
               buttonWidth  = rcButton.right - rcButton.left;
               buttonHeight = rcButton.bottom - rcButton.top;
            }

            x = rcTab.right - cx - ( ( cxMargin + buttonWidth ) * num_buttons );

            SetWindowPos( hwndButton, 0, x, y, 0, 0, SWP_NOSIZE | SWP_NOZORDER | SWP_NOACTIVATE );
            num_buttons--;
         }

         if( pFhi->hasApply )
         {
            // Move the thrid button "Apply" to the right of the second.
            hwndButton = GetDlgItem( hWndDlg, FLBTN_APPLY );
            if( buttonHeight == 0 )
            {
               GetWindowRect( hwndButton, &rcButton );
               buttonWidth  = rcButton.right - rcButton.left;
               buttonHeight = rcButton.bottom - rcButton.top;
            }

            x = rcTab.right - cx - ( ( cxMargin + buttonWidth ) * num_buttons );

            SetWindowPos( hwndButton, 0, x, y, 0, 0, SWP_NOSIZE | SWP_NOZORDER | SWP_NOACTIVATE );
            EnableWindow( hwndButton, FALSE );

            num_buttons--;
         }

         if( pFhi->hasHelp )
         {
            // Move the thrid button "Help" to the right of the second.
            hwndButton = GetDlgItem( hWndDlg, FLBTN_HELP );
            if( buttonHeight == 0 )
            {
               GetWindowRect( hwndButton, &rcButton );
               buttonWidth  = rcButton.right - rcButton.left;
               buttonHeight = rcButton.bottom - rcButton.top;
            }

            x = rcTab.right - cx - ( ( cxMargin + buttonWidth ) * num_buttons );

            SetWindowPos( hwndButton, 0, x, y, 0, 0, SWP_NOSIZE | SWP_NOZORDER | SWP_NOACTIVATE );
         }
      }

      // Size the dialog box.
      SetWindowPos
      (
         hWndDlg,
         NULL,
         0,
         0,
         rcTab.right + cyMargin + 2 * GetSystemMetrics( SM_CXDLGFRAME ) + 2 * cx,
         rcTab.bottom + 2 * cx + buttonHeight + 2 * cyMargin + 2 * GetSystemMetrics( SM_CYDLGFRAME ) + GetSystemMetrics( SM_CYCAPTION ),
         SWP_NOMOVE | SWP_NOZORDER
      );
   }

   // Simulate selection of the first item.
   FLD_SelChanged( hWndDlg );
}

DLGTEMPLATE * WINAPI FLD_SetStyleDlgRes( DLGTEMPLATE * pTemplate, DWORD resSize )
{
   LPVOID temp;

   temp = LocalAlloc( LPTR, resSize );
   if( ! temp )
      return FALSE;
   memcpy( temp, pTemplate, resSize );
   pTemplate = ( DLGTEMPLATE * ) temp;

   if( ( ( MyDLGTEMPLATEEX * ) pTemplate )->signature == 0xFFFF )
   {
      ( ( MyDLGTEMPLATEEX * ) pTemplate )->style   |= WS_CHILD | WS_TABSTOP | DS_CONTROL;
      ( ( MyDLGTEMPLATEEX * ) pTemplate )->style   &= ~DS_MODALFRAME;
      ( ( MyDLGTEMPLATEEX * ) pTemplate )->style   &= ~WS_CAPTION;
      ( ( MyDLGTEMPLATEEX * ) pTemplate )->style   &= ~WS_SYSMENU;
      ( ( MyDLGTEMPLATEEX * ) pTemplate )->style   &= ~WS_DISABLED;
      ( ( MyDLGTEMPLATEEX * ) pTemplate )->style   &= ~WS_THICKFRAME;
      ( ( MyDLGTEMPLATEEX * ) pTemplate )->exStyle |= WS_EX_CONTROLPARENT;

      //    ((MyDLGTEMPLATEEX*)pTemplate)->style &= ~WS_POPUP;
      ( ( MyDLGTEMPLATEEX * ) pTemplate )->style &= ~WS_VISIBLE;
   }
   else
   {
      pTemplate->style |= WS_CHILD | WS_TABSTOP | DS_CONTROL;
      pTemplate->style &= ~DS_MODALFRAME;

      pTemplate->style &= ~WS_CAPTION;
      pTemplate->style &= ~WS_SYSMENU;
      pTemplate->style &= ~WS_DISABLED;
      pTemplate->style &= ~WS_THICKFRAME;

      //    pTemplate->style &= ~WS_POPUP;
      pTemplate->style &= ~WS_VISIBLE;

      pTemplate->dwExtendedStyle |= WS_EX_CONTROLPARENT;
   }
   return pTemplate;
}

//-----------------------------------------------------------------
// FLD_LockDlgRes - loads and locks a dialog template resource.
// Returns the address of the locked resource.
// lpszResName - name of the resource
//-----------------------------------------------------------------
DLGTEMPLATE * WINAPI FLD_LockDlgRes( LPCSTR lpszResName )
{
   DLGTEMPLATE * pTemplate;
   DWORD         resSize;
   HGLOBAL       hglb;

   HRSRC hrsrc = FindResource( GetResources(), lpszResName, RT_DIALOG );

   resSize = SizeofResource( GetResources(), hrsrc );

   hglb = LoadResource( GetResources(), hrsrc );

   pTemplate = ( DLGTEMPLATE * ) LockResource( hglb );
   pTemplate = FLD_SetStyleDlgRes( pTemplate, resSize );

   return pTemplate;
}

/*-----------------------------------------------------------------
       FLD_SelChanged() - processes the TCN_SELCHANGE notification.()
   -----------------------------------------------------------------*/
VOID WINAPI FLD_SelChanged( HWND hWndDlg )
{
   FLDHDRINFO * pFhi = ( FLDHDRINFO * ) GetWindowLongPtr( hWndDlg, GWLP_USERDATA );

   int iSel = TabCtrl_GetCurSel( pFhi->hwndTab );

   FLD_ShowPage( hWndDlg, iSel, pFhi );
}

/*-----------------------------------------------------------------
       FLD_ChildDialogInit()
   -----------------------------------------------------------------*/
VOID WINAPI FLD_ChildDialogInit( HWND hWndDlg, HWND hWndParent, int idrc )
{
   RECT rcTab;

   static PHB_SYMB pSymbol = NULL;

   DWORD dwDlgBase = GetDialogBaseUnits();
   int   cxMargin  = LOWORD( dwDlgBase ) / 4;
   int   cyMargin  = HIWORD( dwDlgBase ) / 8;

   FLDHDRINFO * pFhi = ( FLDHDRINFO * ) GetWindowLongPtr( hWndParent, GWLP_USERDATA );

   if( pFhi )
   {
      GetWindowRect( pFhi->hwndTab, &rcTab );

      SetWindowPos( hWndDlg, NULL, pFhi->rcDisplay.left + rcTab.left - cxMargin - 1, pFhi->rcDisplay.top + rcTab.top - cyMargin, 0, 0, SWP_NOSIZE );

      pSymbol = hb_dynsymSymbol( hb_dynsymGet( "INITPAGEFLDPROC" ) );
      if( pSymbol )
      {
         hb_vmPushSymbol( pSymbol );
         hb_vmPushNil();
         hb_vmPushNumInt( ( LONG_PTR ) hWndParent );
         hb_vmPushNumInt( ( LONG_PTR ) hWndDlg );
         hb_vmPushLong( ( LONG ) idrc );
         hb_vmDo( 3 );
      }
   }
}

/*-----------------------------------------------------------------
       FLD_DialogAlign()
   -----------------------------------------------------------------*/
VOID WINAPI FLD_DialogAlign( HWND hWndDlg )
{
   RECT  rcTab;
   DWORD dwDlgBase = GetDialogBaseUnits();
   int   cxMargin  = LOWORD( dwDlgBase ) / 4;
   int   cyMargin  = HIWORD( dwDlgBase ) / 8;

   FLDHDRINFO * pFhi = ( FLDHDRINFO * ) GetWindowLongPtr( hWndDlg, GWLP_USERDATA );

   if( pFhi )
   {
      GetWindowRect( pFhi->hwndTab, &rcTab );
      SetWindowPos
      (
         pFhi->hwndDisplay,
         NULL,
         pFhi->rcDisplay.left + rcTab.left - cxMargin - 1,
         pFhi->rcDisplay.top + rcTab.top - cyMargin,
         0,
         0,
         SWP_NOSIZE
      );
   }
}

/*-----------------------------------------------------------------
       FLD_PageInfo()
   -----------------------------------------------------------------*/
static BOOL FLD_PageInfo( DLGTEMPLATE * pTemplate, FLDHDRINFO * pFhi, int index, BOOL resize )
{
   const WORD *  p;
   int           width, height;
   FLDPAGEINFO * fpi;

   if( ! pTemplate )
      return FALSE;

   p = ( const WORD * ) pTemplate;

   if( ( ( const MyDLGTEMPLATEEX * ) pTemplate )->signature == 0xFFFF )
   {
      /* DLGTEMPLATEEX (not defined in any std. header file) */
      p++;     /* dlgVer    */
      p++;     /* signature */
      p += 2;  /* help ID   */
      p += 2;  /* ext style */
      p += 2;  /* style     */
   }
   else
   {
      /* DLGTEMPLATE */
      p += 2;  /* style     */
      p += 2;  /* ext style */
   }

   p++;        /* nb items */
   p++;        /*   x      */
   p++;        /*   y      */
   width = ( WORD ) *p;
   p++;
   height = ( WORD ) *p;
   p++;

   /* remember the largest width and height */
   if( resize )
   {
      if( width > pFhi->cx )
         pFhi->cx = width;

      if( height > pFhi->cy )
         pFhi->cy = height;
   }

   /* menu */
   switch( ( WORD ) *p )
   {
      case 0x0000:   p++; break;
      case 0xffff:   p += 2; break;
      default:       p += lstrlenW( ( LPCWSTR ) p ) + 1; break;
   }

   /* class */
   switch( ( WORD ) *p )
   {
      case 0x0000:   p++; break;
      case 0xffff:   p += 2; break;
      default:       p += lstrlenW( ( LPCWSTR ) p ) + 1; break;
   }

   /* Extract the caption */
   fpi = ( FLDPAGEINFO * ) pFhi->fhpage[ index ];
   fpi->pszText = ( LPCTSTR ) p;

   return TRUE;
}

/*-----------------------------------------------------------------
       FLD_Changed()
   -----------------------------------------------------------------*/
static void FLD_Changed( HWND hWndParent, HWND hwndDirtyPage )
{
   int i;
   FLDHDRINFO * pFhi = ( FLDHDRINFO * ) GetWindowLongPtr( hWndParent, GWLP_USERDATA );

   if( ! pFhi )
      return;

   /* Set the dirty flag of this page.  */
   for( i = 0; i < pFhi->nPages; i++ )
   {
      HFLDPAGEINFO * hfpi = pFhi->fhpage;
      FLDPAGEINFO *  fpi  = ( FLDPAGEINFO * ) hfpi[ i ];
      if( fpi->hwndPage == hwndDirtyPage )
         fpi->isDirty = TRUE;
   }

   /* Enable the Apply button.  */
   if( pFhi->hasApply && pFhi->activeValid )
   {
      HWND hwndApplyBtn = GetDlgItem( hWndParent, FLBTN_APPLY );

      EnableWindow( hwndApplyBtn, TRUE );
   }
}

/*-----------------------------------------------------------------
       FLD_UnChanged()
   -----------------------------------------------------------------*/
static void FLD_UnChanged( HWND hWndParent, HWND hwndCleanPage )
{
   int  i;
   BOOL noPageDirty = TRUE;

   FLDHDRINFO * pFhi = ( FLDHDRINFO * ) GetWindowLongPtr( hWndParent, GWLP_USERDATA );

   if( ! pFhi )
      return;

   for( i = 0; i < pFhi->nPages; i++ )
   {
      /* set the specified page as clean */
      HFLDPAGEINFO * hfpi = pFhi->fhpage;
      FLDPAGEINFO *  fpi  = ( FLDPAGEINFO * ) hfpi[ i ];
      if( fpi->hwndPage == hwndCleanPage )
         fpi->isDirty = FALSE;

      /* look to see if there's any dirty pages */
      if( fpi->isDirty )
         noPageDirty = FALSE;
   }

   /* Disable Apply button.  */
   if( pFhi->hasApply )
   {
      HWND hwndApplyBtn = GetDlgItem( hWndParent, FLBTN_APPLY );
      if( noPageDirty )
         EnableWindow( hwndApplyBtn, FALSE );
   }
}

/*-----------------------------------------------------------------
       FLD_DoCommand()
   -----------------------------------------------------------------*/
static BOOL FLD_DoCommand( HWND hWndDlg, WORD wID )
{
   switch( wID )
   {
      case FLBTN_OK:
      case FLBTN_APPLY:
      {
         FLDHDRINFO * pFhi         = ( FLDHDRINFO * ) GetWindowLongPtr( hWndDlg, GWLP_USERDATA );
         HWND         hwndApplyBtn = GetDlgItem( hWndDlg, FLBTN_APPLY );
         if( pFhi->activeValid )
         {
            if( FLD_Apply( hWndDlg, wID ) == FALSE )
               break;

            if( wID == FLBTN_OK )
            {
               if( ! pFhi )
                  return FALSE;

               if( ! pFhi->isModal )
                  pFhi->activeValid = FALSE;
               else
                  pFhi->ended = TRUE;
            }
            else
               EnableWindow( hwndApplyBtn, FALSE );
         }
         else
         {
            FLHNOTIFY      fln;
            FLDPAGEINFO *  fpi;
            HFLDPAGEINFO * hfpi;
            HWND hwndPage;

            /* Send FLN_FINISH to the current page. */
            fln.hdr.hwndFrom = hWndDlg;
            fln.hdr.idFrom   = 0;
            fln.lParam       = 0;
            fln.hdr.code     = FLN_FINISH;

            hfpi     = pFhi->fhpage;
            fpi      = ( FLDPAGEINFO * ) hfpi[ pFhi->active_page ];
            hwndPage = fpi->hwndPage;

            SendMessage( hwndPage, WM_NOTIFY, 0, ( LPARAM ) &fln );
         }
         break;
      }

      case FLBTN_CANCEL:
         FLD_Cancel( hWndDlg, wID );
         break;

      case FLBTN_HELP:
         FLD_Help( hWndDlg );
         break;

      default:
         return FALSE;
   }

   return TRUE;
}

/*-----------------------------------------------------------------
       FLD_Apply()
   -----------------------------------------------------------------*/
static BOOL FLD_Apply( HWND hWndDlg, LPARAM lParam )
{
   int i;
   FLDPAGEINFO *  fpi;
   HFLDPAGEINFO * hfpi;
   HWND         hwndPage;
   FLHNOTIFY    fln;
   FLDHDRINFO * pFhi = ( FLDHDRINFO * ) GetWindowLongPtr( hWndDlg, GWLP_USERDATA );

   if( pFhi->active_page < 0 )
      return FALSE;

   fln.hdr.hwndFrom = hWndDlg;
   fln.hdr.idFrom   = 0;
   fln.lParam       = 0;

   /* Send FLN_KILLACTIVE to the current page.   */
   fln.hdr.code = FLN_KILLACTIVE;

   hfpi     = pFhi->fhpage;
   fpi      = ( FLDPAGEINFO * ) hfpi[ pFhi->active_page ];
   hwndPage = fpi->hwndPage;

   if( SendMessage( hwndPage, WM_NOTIFY, 0, ( LPARAM ) &fln ) != FALSE )
      return FALSE;

   /* Send FLN_APPLY to all pages.  */
   fln.hdr.code = FLN_APPLY;
   fln.lParam   = lParam;

   for( i = 0; i < pFhi->nPages; i++ )
   {
      hfpi     = pFhi->fhpage;
      fpi      = ( FLDPAGEINFO * ) hfpi[ i ];
      hwndPage = fpi->hwndPage;
      if( hwndPage )
         SendMessage( hwndPage, WM_NOTIFY, ( WPARAM ) lParam, ( LPARAM ) &fln );
   }

   if( lParam == FLBTN_OK )
      pFhi->activeValid = FALSE;

   if( pFhi->active_page >= 0 )
   {
      fln.hdr.hwndFrom = hWndDlg;
      fln.hdr.idFrom   = 0;
      fln.lParam       = 0;
      if( lParam == FLBTN_OK )
         fln.hdr.code = FLN_FINISH;
      else
         fln.hdr.code = FLN_SETACTIVE;

      hfpi     = pFhi->fhpage;
      fpi      = ( FLDPAGEINFO * ) hfpi[ pFhi->active_page ];
      hwndPage = fpi->hwndPage;

      SendMessage( hwndPage, WM_NOTIFY, ( WPARAM ) lParam, ( LPARAM ) &fln );
   }

   return TRUE;
}

/*-----------------------------------------------------------------
      FLD_Cancel()
   -----------------------------------------------------------------*/
static void FLD_Cancel( HWND hWndDlg, LPARAM lParam )
{
   FLDPAGEINFO *  fpi;
   HFLDPAGEINFO * hfpi;
   HWND      hwndPage;
   FLHNOTIFY fln;

   FLDHDRINFO * pFhi = ( FLDHDRINFO * ) GetWindowLongPtr( hWndDlg, GWLP_USERDATA );
   int          i;

   if( pFhi->active_page < 0 )
      return;

   hfpi     = pFhi->fhpage;
   fpi      = ( FLDPAGEINFO * ) hfpi[ pFhi->active_page ];
   hwndPage = fpi->hwndPage;

   fln.hdr.code     = FLN_QUERYCANCEL;
   fln.hdr.hwndFrom = hWndDlg;
   fln.hdr.idFrom   = 0;
   fln.lParam       = 0;

   if( SendMessage( hwndPage, WM_NOTIFY, ( WPARAM ) lParam, ( LPARAM ) &fln ) )
      return;

   fln.hdr.code = FLN_RESET;
   fln.lParam   = lParam;

   for( i = 0; i < pFhi->nPages; i++ )
   {
      hfpi     = pFhi->fhpage;
      fpi      = ( FLDPAGEINFO * ) hfpi[ i ];
      hwndPage = fpi->hwndPage;

      if( hwndPage )
         SendMessage( hwndPage, WM_NOTIFY, ( WPARAM ) lParam, ( LPARAM ) &fln );
   }

   if( ! pFhi->isModal )
      pFhi->activeValid = FALSE;
   else
      pFhi->ended = TRUE;

   fln.hdr.code = FLN_FINISH;
   fpi      = ( FLDPAGEINFO * ) hfpi[ pFhi->active_page ];
   hwndPage = fpi->hwndPage;
   if( hwndPage )
      SendMessage( hwndPage, WM_NOTIFY, ( WPARAM ) lParam, ( LPARAM ) &fln );
}

/*-----------------------------------------------------------------
      FLD_Help()
   -----------------------------------------------------------------*/
static void FLD_Help( HWND hWndDlg )
{
   FLDHDRINFO *   pFhi = ( FLDHDRINFO * ) GetWindowLongPtr( hWndDlg, GWLP_USERDATA );
   HWND           hwndPage;
   FLDPAGEINFO *  fpi;
   HFLDPAGEINFO * hfpi;
   FLHNOTIFY      fln;

   if( pFhi->active_page < 0 )
      return;

   hfpi     = pFhi->fhpage;
   fpi      = ( FLDPAGEINFO * ) hfpi[ pFhi->active_page ];
   hwndPage = fpi->hwndPage;

   fln.hdr.code     = FLN_HELP;
   fln.hdr.hwndFrom = hWndDlg;
   fln.hdr.idFrom   = 0;
   fln.lParam       = 0;

   SendMessage( hwndPage, WM_NOTIFY, 0, ( LPARAM ) &fln );
}

/*-----------------------------------------------------------------
      FLD_ShowPage()
   -----------------------------------------------------------------*/
static BOOL FLD_ShowPage( HWND hWndDlg, int index, FLDHDRINFO * pFhi )
{
   FLDPAGEINFO *  fpi;
   HFLDPAGEINFO * hfpi = pFhi->fhpage;

   if( index == pFhi->active_page )
   {
      fpi = ( FLDPAGEINFO * ) hfpi[ index ];
      if( GetTopWindow( hWndDlg ) != fpi->hwndPage )
         SetWindowPos( fpi->hwndPage, HWND_TOP, 0, 0, 0, 0, SWP_NOSIZE | SWP_NOMOVE );

      return TRUE;
   }

   fpi = ( FLDPAGEINFO * ) hfpi[ index ];
   if( fpi->hwndPage == NULL )
   {
      pFhi->hwndDisplay = CreateDialogIndirectParam
                          (
         GetResources(),
         ( DLGTEMPLATE * ) fpi->apRes,
         hWndDlg,
         ( DLGPROC ) HMG_PageFldProc,
         ( LPARAM ) pFhi
                          );
      fpi->hwndPage = pFhi->hwndDisplay;
   }
   else
      pFhi->hwndDisplay = fpi->hwndPage;

   FLD_DialogAlign( hWndDlg );

   if( pFhi->active_page != -1 )
   {
      fpi = ( FLDPAGEINFO * ) hfpi[ pFhi->active_page ];
      ShowWindow( fpi->hwndPage, SW_HIDE );
   }

   fpi = ( FLDPAGEINFO * ) hfpi[ index ];
   ShowWindow( fpi->hwndPage, SW_SHOW );

   /* Synchronize current selection with tab control*/
   SendMessage( pFhi->hwndTab, TCM_SETCURSEL, index, 0 );

   pFhi->active_page = index;
   pFhi->activeValid = TRUE;

   return TRUE;
}

/*-----------------------------------------------------------------
      FLD_HwndToIndex()
   -----------------------------------------------------------------*/
static LRESULT FLD_HwndToIndex( HWND hWndDlg, HWND hPageDlg )
{
   int index;

   FLDHDRINFO * pFhi = ( FLDHDRINFO * ) GetWindowLongPtr( hWndDlg, GWLP_USERDATA );

   for( index = 0; index < pFhi->nPages; index++ )
   {
      HFLDPAGEINFO * hfpi = pFhi->fhpage;
      FLDPAGEINFO *  fpi  = ( FLDPAGEINFO * ) hfpi[ index ];
      if( fpi->hwndPage == hPageDlg )
         return index;
   }

   return -1;
}

/*-----------------------------------------------------------------
      FLD_CleanUp()
   -----------------------------------------------------------------*/
static void FLD_CleanUp( HWND hWndDlg )
{
   int i;

   FLDHDRINFO * pFhi = ( FLDHDRINFO * ) GetWindowLongPtr( hWndDlg, GWLP_USERDATA );

   if( ! pFhi )
      return;

   for( i = 0; i < pFhi->nPages; i++ )
   {
      HFLDPAGEINFO * hfpi = pFhi->fhpage;
      FLDPAGEINFO *  fpi  = ( FLDPAGEINFO * ) hfpi[ i ];

      if( fpi->hwndPage )
         DestroyWindow( fpi->hwndPage );
   }

   /* If we created the bitmaps, destroy them */
   ImageList_Destroy( pFhi->hImageList );
   LocalFree( pFhi->fhpage );

   GlobalFree( ( HGLOBAL ) pFhi );
}

/*-----------------------------------------------------------------
      FLD_AddBitmap()
   -----------------------------------------------------------------*/
static void FLD_AddBitmap( HWND hWndFolder )
{
   HIMAGELIST    himl = ( HIMAGELIST ) NULL;
   HBITMAP       hbmp;
   FLDPAGEINFO * pfpi = NULL;
   TC_ITEM       tie;
   HDC hDC;
   int l;
   int s;
   int cx = 0;
   int cy = 0;
   int i  = 0;

   FLDHDRINFO * pFhi = ( FLDHDRINFO * ) GetWindowLongPtr( hWndFolder, GWLP_USERDATA );

   l = pFhi->nPages - 1;

   for( s = 0; s <= l; s++ )
   {
      pfpi = ( FLDPAGEINFO * ) pFhi->fhpage[ s ];
      if( pfpi->hasIcon )
      {
         i = s + 1;
         break;
      }
   }

   if( i != 0 )
   {

      himl = ImageList_LoadImage
             (
         GetResources(),
         pfpi->pszTemplate,
         0,
         l,
         CLR_DEFAULT,
         IMAGE_BITMAP,
         LR_LOADTRANSPARENT | LR_DEFAULTCOLOR | LR_LOADMAP3DCOLORS
             );

      if( himl == NULL )
         himl = ImageList_LoadImage
                (
            GetResources(),
            pfpi->pszTemplate,
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
               pfpi = ( FLDPAGEINFO * ) pFhi->fhpage[ s ];

               hbmp = NULL;

               if( pfpi->hasIcon )
               {
                  hbmp = ( HBITMAP ) LoadImage
                         (
                     GetResources(),
                     pfpi->pszTemplate,
                     IMAGE_BITMAP,
                     cx,
                     cy,
                     LR_LOADTRANSPARENT | LR_DEFAULTCOLOR | LR_LOADMAP3DCOLORS
                         );

                  if( hbmp == NULL )
                     hbmp = ( HBITMAP ) LoadImage
                            (
                        NULL,
                        pfpi->pszTemplate,
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

                  hDC  = GetDC( pFhi->hwndTab );
                  hbmp = CreateCompatibleBitmap( hDC, cx, cy );

                  ImageList_AddMasked( himl, hbmp, CLR_DEFAULT );

                  DeleteObject( hbmp );
                  ReleaseDC( pFhi->hwndTab, hDC );
               }
            }

            SendMessage( pFhi->hwndTab, TCM_SETIMAGELIST, ( WPARAM ) 0, ( LPARAM ) himl );

            for( s = 0; s <= l; s++ )
            {
               tie.mask   = TCIF_IMAGE;
               tie.iImage = s;
               TabCtrl_SetItem( ( HWND ) pFhi->hwndTab, s, &tie );
            }
         }
      }
   }

   pFhi->hImageList = himl;
}
