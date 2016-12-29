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

#define _WIN32_IE     0x0501
#ifdef __POCC__
#define _WIN32_WINNT  0x0500
#else
#define _WIN32_WINNT  0x0400
#endif

#include <mgdefs.h>

#include <commdlg.h>
#include <shlobj.h>
#include <commctrl.h>

HB_FUNC( CHOOSEFONT )
{
   CHOOSEFONT cf;
   LOGFONT    lf;
   long       PointSize;
   int        bold;
   HDC        hdc;
   HWND       hwnd;

   strcpy( lf.lfFaceName, hb_parc( 1 ) );

   hwnd = GetActiveWindow();
   hdc  = GetDC( hwnd );

   lf.lfHeight = -MulDiv( hb_parnl( 2 ), GetDeviceCaps( hdc, LOGPIXELSY ), 72 );

   if( hb_parl( 3 ) )
      lf.lfWeight = 700;
   else
      lf.lfWeight = 400;

   if( hb_parl( 4 ) )
      lf.lfItalic = TRUE;
   else
      lf.lfItalic = FALSE;

   if( hb_parl( 6 ) )
      lf.lfUnderline = TRUE;
   else
      lf.lfUnderline = FALSE;

   if( hb_parl( 7 ) )
      lf.lfStrikeOut = TRUE;
   else
      lf.lfStrikeOut = FALSE;

   lf.lfCharSet = ( BYTE ) hb_parni( 8 );

   cf.lStructSize    = sizeof( CHOOSEFONT );
   cf.hwndOwner      = hwnd;
   cf.hDC            = ( HDC ) NULL;
   cf.lpLogFont      = &lf;
   cf.Flags          = HB_ISNUM( 9 ) ? hb_parni( 9 ) : CF_SCREENFONTS | CF_EFFECTS | CF_INITTOLOGFONTSTRUCT;
   cf.rgbColors      = hb_parnl( 5 );
   cf.lCustData      = 0L;
   cf.lpfnHook       = ( LPCFHOOKPROC ) NULL;
   cf.lpTemplateName = ( LPSTR ) NULL;
   cf.hInstance      = ( HINSTANCE ) NULL;
   cf.lpszStyle      = ( LPSTR ) NULL;
   cf.nFontType      = SCREEN_FONTTYPE;
   cf.nSizeMin       = 0;
   cf.nSizeMax       = 0;

   if( ! ChooseFont( &cf ) )
   {
      hb_reta( 8 );
      HB_STORC( "", -1, 1 );
      HB_STORVNL( ( LONG ) 0, -1, 2 );
      HB_STORL( 0, -1, 3 );
      HB_STORL( 0, -1, 4 );
      HB_STORVNL( 0, -1, 5 );
      HB_STORL( 0, -1, 6 );
      HB_STORL( 0, -1, 7 );
      HB_STORNI( 0, -1, 8 );
      ReleaseDC( hwnd, hdc );
      return;
   }

   PointSize = -MulDiv( lf.lfHeight, 72, GetDeviceCaps( hdc, LOGPIXELSY ) );

   if( lf.lfWeight == 700 )
      bold = 1;
   else
      bold = 0;

   hb_reta( 8 );
   HB_STORC( lf.lfFaceName, -1, 1 );
   HB_STORVNL( ( LONG ) PointSize, -1, 2 );
   HB_STORL( bold, -1, 3 );
   HB_STORL( lf.lfItalic, -1, 4 );
   HB_STORVNL( cf.rgbColors, -1, 5 );
   HB_STORL( lf.lfUnderline, -1, 6 );
   HB_STORL( lf.lfStrikeOut, -1, 7 );
   HB_STORNI( lf.lfCharSet, -1, 8 );

   ReleaseDC( hwnd, hdc );
}

HB_FUNC( C_GETFILE )
{
   OPENFILENAME ofn;
   char         buffer[ 32768 ];
   char         cFullName[ 256 ][ 1024 ];
   char         cCurDir[ 512 ];
   char         cFileName[ 512 ];
   int          iFilterIndex = 1;
   int          iPosition    = 0;
   int          iNumSelected = 0;
   int          n;

   DWORD flags = OFN_FILEMUSTEXIST;

   buffer[ 0 ] = 0;

   if( hb_parl( 4 ) )
      flags = flags | OFN_ALLOWMULTISELECT | OFN_EXPLORER;

   if( hb_parl( 5 ) )
      flags = flags | OFN_NOCHANGEDIR;

   if( hb_parni( 6 ) )
      iFilterIndex = hb_parni( 6 );

   memset( ( void * ) &ofn, 0, sizeof( OPENFILENAME ) );
   ofn.lStructSize     = sizeof( ofn );
   ofn.hwndOwner       = GetActiveWindow();
   ofn.lpstrFilter     = hb_parc( 1 );
   ofn.nFilterIndex    = ( DWORD ) iFilterIndex;
   ofn.lpstrFile       = buffer;
   ofn.nMaxFile        = sizeof( buffer );
   ofn.lpstrInitialDir = hb_parc( 3 );
   ofn.lpstrTitle      = hb_parc( 2 );
   ofn.nMaxFileTitle   = 512;
   ofn.Flags = flags;

   if( GetOpenFileName( &ofn ) )
   {
      if( ofn.nFileExtension != 0 )
         hb_retc( ofn.lpstrFile );
      else
      {
         wsprintf( cCurDir, "%s", &buffer[ iPosition ] );
         iPosition = iPosition + strlen( cCurDir ) + 1;

         do
         {
            iNumSelected++;
            wsprintf( cFileName, "%s", &buffer[ iPosition ] );
            iPosition = iPosition + strlen( cFileName ) + 1;
            wsprintf( cFullName[ iNumSelected ], "%s\\%s", cCurDir, cFileName );
         }
         while( ( strlen( cFileName ) != 0 ) && ( iNumSelected <= 255 ) );

         if( iNumSelected > 1 )
         {
            hb_reta( iNumSelected - 1 );

            for( n = 1; n < iNumSelected; n++ )
               HB_STORC( cFullName[ n ], -1, n );
         }
         else
            hb_retc( &buffer[ 0 ] );
      }
   }
   else
      hb_retc( "" );
}

// JK JP

HB_FUNC( C_PUTFILE )
{
   OPENFILENAME ofn;
   char         buffer[ 512 ];
   char         cExt[ 4 ];
   int          iFilterIndex = 1;
   DWORD        flags        = OFN_FILEMUSTEXIST | OFN_EXPLORER;

   if( hb_parl( 4 ) )
      flags |= OFN_NOCHANGEDIR;

   if( hb_parl( 7 ) )  // p.d. 12/05/2016
      flags |= OFN_OVERWRITEPROMPT;

   if( hb_parclen( 5 ) > 0 )
      strcpy( buffer, hb_parc( 5 ) );
   else
      strcpy( buffer, "" );
   strcpy( cExt, "" );

   if( hb_parni( 6 ) )
      iFilterIndex = hb_parni( 6 );

   memset( ( void * ) &ofn, 0, sizeof( OPENFILENAME ) );
   ofn.lStructSize     = sizeof( ofn );
   ofn.hwndOwner       = GetActiveWindow();
   ofn.lpstrFilter     = hb_parc( 1 );
   ofn.nFilterIndex    = ( DWORD ) iFilterIndex;
   ofn.lpstrFile       = buffer;
   ofn.nMaxFile        = 512;
   ofn.lpstrInitialDir = hb_parc( 3 );
   ofn.lpstrTitle      = hb_parc( 2 );
   ofn.Flags       = flags;
   ofn.lpstrDefExt = cExt;

   if( GetSaveFileName( &ofn ) )
   {
      if( ofn.nFileExtension == 0 )
      {
         ofn.lpstrFile = strcat( ofn.lpstrFile, "." );
         ofn.lpstrFile = strcat( ofn.lpstrFile, ofn.lpstrDefExt );
      }
      if( HB_ISBYREF( 6 ) )
         hb_storni( ( int ) ofn.nFilterIndex, 6 );

      hb_retc( ofn.lpstrFile );
   }
   else
      hb_retc( "" );
}

static char s_szWinName[ MAX_PATH + 1 ];

// JK HMG 1.0 Experimental Build 8
// --- callback function for C_BROWSEFORFOLDER(). Contributed By Andy Wos

int CALLBACK BrowseCallbackProc( HWND hWnd, UINT uMsg, LPARAM lParam, LPARAM lpData )
{
   TCHAR szPath[ MAX_PATH ];

   switch( uMsg )
   {
      case BFFM_INITIALIZED:  if( lpData )
         {
            SendMessage( hWnd, BFFM_SETSELECTION, TRUE, lpData );
            SetWindowText( hWnd, ( LPCSTR ) s_szWinName );
         }
         break;
      case BFFM_VALIDATEFAILED:  MessageBeep( MB_ICONHAND ); return 1;
      case BFFM_SELCHANGED:   if( lpData )
         {
            SHGetPathFromIDList( ( LPITEMIDLIST ) lParam, szPath );
            SendMessage( hWnd, BFFM_SETSTATUSTEXT, 0, ( LPARAM ) szPath );
         }
   }

   return 0;
}

HB_FUNC( C_BROWSEFORFOLDER )  // Syntax: C_BROWSEFORFOLDER([<hWnd>],[<cTitle>],[<nFlags>],[<nFolderType>],[<cInitPath>])
{
   HWND         hWnd = HB_ISNIL( 1 ) ? GetActiveWindow() : ( HWND ) HB_PARNL( 1 );
   BROWSEINFO   BrowseInfo;
   char *       lpBuffer = ( char * ) hb_xgrab( MAX_PATH );
   LPITEMIDLIST pidlBrowse;

   if( HB_ISCHAR( 5 ) )
      GetWindowText( hWnd, ( LPSTR ) s_szWinName, MAX_PATH );

   SHGetSpecialFolderLocation( hWnd, HB_ISNIL( 4 ) ? CSIDL_DRIVES : hb_parni( 4 ), &pidlBrowse );

   BrowseInfo.hwndOwner      = hWnd;
   BrowseInfo.pidlRoot       = pidlBrowse;
   BrowseInfo.pszDisplayName = lpBuffer;
   BrowseInfo.lpszTitle      = HB_ISNIL( 2 ) ? "Select a Folder" : hb_parc( 2 );
   BrowseInfo.ulFlags        = HB_ISCHAR( 5 ) ? BIF_STATUSTEXT | BIF_RETURNONLYFSDIRS : hb_parni( 3 );
   BrowseInfo.lpfn   = BrowseCallbackProc;
   BrowseInfo.lParam = HB_ISCHAR( 5 ) ? ( LPARAM ) ( char * ) hb_parc( 5 ) : 0;
   BrowseInfo.iImage = 0;

   pidlBrowse = SHBrowseForFolder( &BrowseInfo );

   if( pidlBrowse )
   {
      SHGetPathFromIDList( pidlBrowse, lpBuffer );
      CoTaskMemFree( pidlBrowse );
      hb_retc( lpBuffer );
   }
   else
      hb_retc( "" );

   hb_xfree( lpBuffer );
}

HB_FUNC( CHOOSECOLOR )
{
   CHOOSECOLOR cc;
   COLORREF    crCustClr[ 16 ];
   int         i;

   for( i = 0; i < 16; i++ )
      crCustClr[ i ] = ( HB_ISARRAY( 3 ) ? ( COLORREF ) HB_PARVNL( 3, i + 1 ) : GetSysColor( COLOR_BTNFACE ) );

   cc.lStructSize  = sizeof( CHOOSECOLOR );
   cc.hwndOwner    = HB_ISNIL( 1 ) ? GetActiveWindow() : ( HWND ) HB_PARNL( 1 );
   cc.rgbResult    = ( COLORREF ) HB_ISNIL( 2 ) ? 0 : hb_parnl( 2 );
   cc.lpCustColors = crCustClr;
   cc.Flags        = ( WORD ) ( HB_ISNIL( 4 ) ? CC_ANYCOLOR | CC_FULLOPEN | CC_RGBINIT : hb_parnl( 4 ) );

   if( ! ChooseColorA( &cc ) )
      hb_retnl( -1 );
   else
      hb_retnl( cc.rgbResult );
}
