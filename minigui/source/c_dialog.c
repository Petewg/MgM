/*----------------------------------------------------------------------------
   MINIGUI - Harbour Win32 GUI library source code

   Copyright 2002-2010 Roberto Lopez <harbourminigui@gmail.com>
   http://harbourminigui.googlepages.com/

   DIALOG form source code
   (c)2005-2008 Janusz Pora <januszpora@onet.eu>

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
#include "hbvm.h"

extern HINSTANCE g_hInstance;

LRESULT CALLBACK HMG_DlgProc( HWND hWnd, UINT message, WPARAM wParam, LPARAM lParam )
{
   static PHB_SYMB pSymbol = NULL;
   long int        r;

   if( ! pSymbol )
      pSymbol = hb_dynsymSymbol( hb_dynsymGet( "DIALOGPROC" ) );

   if( pSymbol )
   {
      hb_vmPushSymbol( pSymbol );
      hb_vmPushNil();
      hb_vmPushNumInt( ( LONG_PTR ) hWnd );
      hb_vmPushLong( message );
      hb_vmPushNumInt( wParam );
      hb_vmPushNumInt( lParam );
      hb_vmDo( 4 );
   }

   r = hb_parnl( -1 );
   return r;
}

LRESULT CALLBACK HMG_ModalDlgProc( HWND hWnd, UINT message, WPARAM wParam, LPARAM lParam )
{
   static PHB_SYMB pSymbol = NULL;
   long int        r;

   if( ! pSymbol )
      pSymbol = hb_dynsymSymbol( hb_dynsymGet( "MODALDIALOGPROC" ) );

   if( pSymbol )
   {
      hb_vmPushSymbol( pSymbol );
      hb_vmPushNil();
      hb_vmPushNumInt( ( LONG_PTR ) hWnd );
      hb_vmPushLong( message );
      hb_vmPushNumInt( wParam );
      hb_vmPushNumInt( lParam );
      hb_vmDo( 4 );
   }

   r = hb_parnl( -1 );
   return r;
}

HB_FUNC( INITMODALDIALOG )
{
   LRESULT lResult;

   lResult = DialogBox( g_hInstance, MAKEINTRESOURCE( hb_parni( 2 ) ), ( HWND ) HB_PARNL( 1 ), ( DLGPROC ) HMG_ModalDlgProc );

   HB_RETNL( ( LONG_PTR ) lResult );
}

HB_FUNC( INITDIALOG )
{
   HWND hwndDlg;

   hwndDlg = CreateDialog( g_hInstance, MAKEINTRESOURCE( hb_parni( 2 ) ), ( HWND ) HB_PARNL( 1 ), ( DLGPROC ) HMG_DlgProc );

   HB_RETNL( ( LONG_PTR ) hwndDlg );
}

HB_FUNC( GETDIALOGITEMHANDLE )
{
   HWND CtrlItem;

   CtrlItem = GetDlgItem( ( HWND ) HB_PARNL( 1 ), hb_parni( 2 ) );

   HB_RETNL( ( LONG_PTR ) CtrlItem );
}

HB_FUNC( CHECKDLGBUTTON )
{
   CheckDlgButton( ( HWND ) HB_PARNL( 2 ), hb_parni( 1 ), BST_CHECKED );
}

HB_FUNC( UNCHECKDLGBUTTON )
{
   CheckDlgButton( ( HWND ) HB_PARNL( 2 ), hb_parni( 1 ), BST_UNCHECKED );
}

HB_FUNC( SETDIALOGITEMTEXT )
{
   hb_retl( SetDlgItemText( ( HWND ) HB_PARNL( 1 ), hb_parni( 2 ), ( LPCSTR ) hb_parc( 3 ) ) );
}

HB_FUNC( ENDDIALOG )
{
   EndDialog( ( HWND ) HB_PARNL( 1 ), hb_parni( 2 ) );
}

HB_FUNC( ADDDIALOGPAGES )
{
   PHB_ITEM hArray;
   HWND     hwnd;
   TC_ITEM  tie;
   int      l;
   int      i;

   hwnd = ( HWND ) HB_PARNL( 1 );

   l      = hb_parinfa( 2, 0 ) - 1;
   hArray = hb_param( 2, HB_IT_ARRAY );

   tie.mask   = TCIF_TEXT;
   tie.iImage = -1;

   for( i = l; i >= 0; i = i - 1 )
   {
      tie.pszText = ( char * ) hb_arrayGetCPtr( hArray, i + 1 );

      TabCtrl_InsertItem( hwnd, 0, &tie );
   }

   TabCtrl_SetCurSel( hwnd, hb_parni( 3 ) - 1 );
   TabCtrl_SetCurFocus( hwnd, hb_parni( 3 ) - 1 );
}

HB_FUNC( GETDLGCTRLID )
{
   hb_retni( GetDlgCtrlID( ( HWND ) HB_PARNL( 1 ) ) );
}

HB_FUNC( SETDLGITEMINT )
{
   SetDlgItemInt
   (
      ( HWND ) HB_PARNL( 1 ),             // handle of dialog box
      hb_parni( 2 ),                      // identifier of control
      ( UINT ) hb_parni( 3 ),             // text to set
      ( hb_pcount() < 4 || HB_ISNIL( 4 ) || ! hb_parl( 4 ) ) ? 0 : 1
   );
}

HB_FUNC( GETDLGITEMTEXT )
{
   int    iLen  = hb_parni( 3 );
   char * cText = ( char * ) hb_xgrab( iLen + 1 );

   GetDlgItemText
   (
      ( HWND ) HB_PARNL( 1 ),             // handle of dialog box
      hb_parni( 2 ),                      // identifier of control
      ( LPTSTR ) cText,                   // address of buffer for text
      iLen                                // maximum size of string
   );
   hb_retc( cText );
   hb_xfree( cText );
}

HB_FUNC( GETEDITTEXT )
{
   HWND   hDlg  = ( HWND ) HB_PARNL( 1 );
   int    id    = hb_parni( 2 );
   USHORT iLen  = ( USHORT ) SendMessage( GetDlgItem( hDlg, id ), WM_GETTEXTLENGTH, 0, 0 );
   char * cText = ( char * ) hb_xgrab( iLen + 2 );

   GetDlgItemText
   (
      hDlg,                               // handle of dialog box
      id,                                 // identifier of control
      ( LPTSTR ) cText,                   // address of buffer for text
      iLen + 1                            // maximum size of string
   );
   hb_retc( cText );
   hb_xfree( cText );
}

HB_FUNC( CHECKRADIOBUTTON )
{
   CheckRadioButton
   (
      ( HWND ) HB_PARNL( 1 ),             // handle of dialog box
      hb_parni( 2 ),                      // identifier of first radio button in group
      hb_parni( 3 ),                      // identifier of last radio button in group
      hb_parni( 4 )                       // identifier of radio button to select
   );
}

HB_FUNC( ISDLGBUTTONCHECKED )
{
   UINT nRes = IsDlgButtonChecked( ( HWND ) HB_PARNL( 1 ),  // handle of dialog box
                                   hb_parni( 2 )            // button identifier
                                   );

   if( nRes == BST_CHECKED )
      hb_retl( TRUE );
   else
      hb_retl( FALSE );
}

static LPWORD lpwAlign( LPWORD lpIn )
{
   ULONG_PTR ul;

   ul   = ( ULONG_PTR ) lpIn;
   ul  += 3;
   ul >>= 2;
   ul <<= 2;
   return ( LPWORD ) ul;
}

static int nCopyAnsiToWideChar( LPWORD lpWCStr, LPCSTR lpAnsiIn )
{
   int    CodePage = GetACP();
   LPWSTR pszDst;
   int    nDstLen = MultiByteToWideChar( CodePage, 0, lpAnsiIn, -1, NULL, 0 );
   int    i;

   if( nDstLen > 0 )
   {
      pszDst = ( LPWSTR ) hb_xgrab( nDstLen * 2 );

      MultiByteToWideChar( CodePage, 0, lpAnsiIn, -1, pszDst, nDstLen );

      for( i = 0; i < nDstLen; i++ )
         *( lpWCStr + i ) = *( pszDst + i );

      hb_xfree( pszDst );
   }

   return nDstLen;
}

long GetSizeDlgTemp( PHB_ITEM dArray, PHB_ITEM cArray )
{
   PHB_ITEM iArray;
   LONG     ln;
   int      s, nItem;
   LONG     lTemplateSize = 36;

   nItem = hb_arrayLen( cArray );

   ln = hb_arrayGetCLen( dArray, 10 );    //caption
   lTemplateSize += ln * 2;
   if( hb_arrayGetNI( dArray, 4 ) & DS_SETFONT )
   {
      ln = hb_arrayGetCLen( dArray, 11 ); //fontname
      lTemplateSize += ln * 2;
      lTemplateSize += 3;
   }

   for( s = 0; s < nItem; s++ )
   {
      iArray         = ( PHB_ITEM ) hb_arrayGetItemPtr( cArray, s + 1 );
      lTemplateSize += 36;
      ln = hb_arrayGetCLen( iArray, 3 );  //class
      lTemplateSize += ln * 2;
      ln = hb_arrayGetCLen( iArray, 10 ); //caption
      lTemplateSize += ln * 2;
   }

   return lTemplateSize;
}

PWORD CreateDlgTemplate( long lTemplateSize, PHB_ITEM dArray, PHB_ITEM cArray )
{
   PWORD pw, pdlgtemplate;

   LONG     baseUnit  = GetDialogBaseUnits();
   int      baseunitX = LOWORD( baseUnit ), baseunitY = HIWORD( baseUnit );
   int      nItem, s, x, y, w, h;
   WORD     iPointSize;
   PHB_ITEM iArray;

   ULONG  Style, ExStyle, HelpId, Id;
   char * strtemp;

   int nchar;

   pdlgtemplate = ( WORD * ) LocalAlloc( LPTR, lTemplateSize );

   pw = pdlgtemplate;

   ExStyle = HB_arrayGetNL( dArray, 5 );  //ExStyle
   Style   = HB_arrayGetNL( dArray, 4 );  //style
   x       = hb_arrayGetNI( dArray, 6 );  //x
   y       = hb_arrayGetNI( dArray, 7 );  //y
   w       = hb_arrayGetNI( dArray, 8 );  //w
   h       = hb_arrayGetNI( dArray, 9 );  //h
   nItem   = hb_arrayLen( cArray );

   *pw++   = 1;            // DlgVer
   *pw++   = 0xFFFF;       // Signature
   *pw++   = 0;            // LOWORD HelpID
   *pw++   = 0;            // HIWORD HelpID
   *pw++   = LOWORD( ExStyle );
   *pw++   = HIWORD( ExStyle );
   *pw++   = LOWORD( Style );
   *pw++   = HIWORD( Style );
   *pw++   = ( WORD ) nItem;                              // NumberOfItems
   *pw++   = ( WORD ) MulDiv( x, 4, baseunitX );          // x
   *pw++   = ( WORD ) MulDiv( y, 8, baseunitY );          // y
   *pw++   = ( WORD ) MulDiv( w, 4, baseunitX );          // cx
   *pw++   = ( WORD ) MulDiv( h, 8, baseunitY );          // cy
   *pw++   = 0;                                           // Menu
   *pw++   = 0;                                           // Class
   strtemp = ( char * ) hb_arrayGetCPtr( dArray, 10 );    //caption
   nchar   = nCopyAnsiToWideChar( pw, strtemp );
   pw     += nchar;
   if( hb_arrayGetNI( dArray, 4 ) & DS_SETFONT )
   {
      iPointSize = ( WORD ) hb_arrayGetNI( dArray, 12 );                //fontsize
      *pw++      = iPointSize;
      *pw++      = ( WORD ) ( hb_arrayGetL( dArray, 13 ) ? 700 : 400 ); //bold
      *pw++      = ( WORD ) hb_arrayGetL( dArray, 14 );
      strtemp    = ( char * ) hb_arrayGetCPtr( dArray, 11 );            //font
      nchar      = nCopyAnsiToWideChar( pw, strtemp );
      pw        += nchar;
   }

   for( s = 0; s < nItem; s = s + 1 )
   {
      iArray = ( PHB_ITEM ) hb_arrayGetItemPtr( cArray, s + 1 );
      pw     = lpwAlign( pw );

      HelpId  = HB_arrayGetNL( iArray, 11 ); //HelpId
      ExStyle = HB_arrayGetNL( iArray, 5 );  //exstyle
      Style   = HB_arrayGetNL( iArray, 4 );  //style  item
      Id      = hb_arrayGetNI( iArray, 1 );

      *pw++ = LOWORD( HelpId );
      *pw++ = HIWORD( HelpId );
      *pw++ = LOWORD( ExStyle );
      *pw++ = HIWORD( ExStyle );
      *pw++ = LOWORD( Style );
      *pw++ = HIWORD( Style );
      *pw++ = ( WORD ) MulDiv( hb_arrayGetNI( iArray, 6 ), 4, baseunitX ); // x
      *pw++ = ( WORD ) MulDiv( hb_arrayGetNI( iArray, 7 ), 8, baseunitY ); // y
      *pw++ = ( WORD ) MulDiv( hb_arrayGetNI( iArray, 8 ), 4, baseunitX ); // cx
      *pw++ = ( WORD ) MulDiv( hb_arrayGetNI( iArray, 9 ), 8, baseunitY ); // cy
      *pw++ = ( WORD ) Id;                                                 // LOWORD (Control ID)
      *pw++ = 0;                                                           // HOWORD (Control ID)

      strtemp = ( char * ) hb_arrayGetCPtr( iArray, 3 );                   //class
      nchar   = nCopyAnsiToWideChar( pw, strtemp );
      pw     += nchar;

      strtemp = ( char * ) hb_arrayGetCPtr( iArray, 10 ); //caption
      nchar   = nCopyAnsiToWideChar( pw, strtemp );
      pw     += nchar;
      *pw++   = 0; // Advance pointer over nExtraStuff WORD.
   }

   *pw = 0;       // Number of bytes of extra data.
   return pdlgtemplate;
}

HB_FUNC( CREATEDLGTEMPLATE )
{
   PWORD pdlgtemplate;
   HWND  hwnd;
   HWND  hwndDlg;

   PHB_ITEM dArray;
   PHB_ITEM cArray;

   BOOL    modal;
   LRESULT lResult;
   long    lTemplateSize;

   hwnd = ( HWND ) HB_PARNL( 1 );

   dArray = hb_param( 2, HB_IT_ARRAY );
   cArray = hb_param( 3, HB_IT_ARRAY );
   modal  = hb_arrayGetL( dArray, 3 );

   lTemplateSize = GetSizeDlgTemp( dArray, cArray );

   pdlgtemplate = CreateDlgTemplate( lTemplateSize, dArray, cArray );

   if( modal )
   {
      lResult = DialogBoxIndirect( g_hInstance, ( LPDLGTEMPLATE ) pdlgtemplate, hwnd, ( DLGPROC ) HMG_ModalDlgProc );
      LocalFree( pdlgtemplate );
      HB_RETNL( ( LONG_PTR ) lResult );
   }
   else
   {
      hwndDlg = CreateDialogIndirect( g_hInstance, ( LPDLGTEMPLATE ) pdlgtemplate, hwnd, ( DLGPROC ) HMG_DlgProc );
      LocalFree( pdlgtemplate );
      HB_RETNL( ( LONG_PTR ) hwndDlg );
   }
}

HB_FUNC( INITEXCOMMONCONTROLS )
{
   INITCOMMONCONTROLSEX i;

   i.dwSize = sizeof( INITCOMMONCONTROLSEX );

   switch( hb_parni( 1 ) )
   {
      case 1:  i.dwICC = ICC_DATE_CLASSES; break;
      case 2:  i.dwICC = ICC_TREEVIEW_CLASSES; break;
      case 3:  i.dwICC = ICC_INTERNET_CLASSES; break;
      default: i.dwICC = ICC_DATE_CLASSES;
   }

   InitCommonControlsEx( &i );
}
