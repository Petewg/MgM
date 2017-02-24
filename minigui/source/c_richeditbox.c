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

#include <mgdefs.h>

#include <commctrl.h>
#include <richedit.h>

#if defined ( __MINGW32__ ) && defined ( __MINGW32_VERSION )
#define IMF_AUTOFONT      0x0002
#endif

#if defined ( __WATCOMC__ )
#define ENM_DRAGDROPDONE  0x00000010
#define SF_USECODEPAGE    0x0020          /* CodePage given by high word */
#endif

#if defined( MSFTEDIT_CLASS )
#undef MSFTEDIT_CLASS
#endif
#define MSFTEDIT_CLASS    "RICHEDIT50W"

static BOOL IsWinxpSp1Min( void );

extern HINSTANCE g_hInstance;

static HINSTANCE hRELib = NULL;

HB_FUNC( INITRICHEDITBOX )
{
   HWND   hRE = NULL;
   int    Style;
   char * lpClassName;

   Style = ES_MULTILINE | ES_WANTRETURN | WS_CHILD | ES_NOHIDESEL;

   if( hb_parl( 10 ) )
      Style = Style | ES_READONLY;

   if( ! hb_parl( 11 ) )
      Style = Style | WS_VISIBLE;

   if( ! hb_parl( 12 ) )
      Style = Style | WS_TABSTOP;

   if( ! hb_parl( 13 ) )
      Style = Style | WS_HSCROLL;

   Style = ( hb_parl( 14 ) ) ? ( Style | ES_AUTOVSCROLL ) : ( Style | WS_VSCROLL );

   if( IsWinxpSp1Min() )
   {
      if( ! hRELib )
         hRELib = LoadLibrary( "Msftedit.dll" );

      lpClassName = MSFTEDIT_CLASS;
   }
   else
   {
      if( ! hRELib )
         hRELib = LoadLibrary( "RichEd20.dll" );

      lpClassName = RICHEDIT_CLASS;
   }

   if( hRELib )
   {
      hRE = CreateWindowEx
            (
         WS_EX_CLIENTEDGE,
         ( LPSTR ) lpClassName,
         ( LPSTR ) NULL,
         Style,
         hb_parni( 3 ),
         hb_parni( 4 ),
         hb_parni( 5 ),
         hb_parni( 6 ),
         ( HWND ) HB_PARNL( 1 ),
         ( HMENU ) HB_PARNL( 2 ),
         g_hInstance,
         NULL
            );

      SendMessage( hRE, ( UINT ) EM_EXLIMITTEXT, ( WPARAM ) hb_parni( 9 ), ( LPARAM ) 0 );
      SendMessage( hRE, ( UINT ) EM_SETEVENTMASK, ( WPARAM ) 0, ( LPARAM ) ENM_SELCHANGE | ENM_DRAGDROPDONE | ENM_CHANGE | ENM_SCROLL );
   }

   HB_RETNL( ( LONG_PTR ) hRE );
}

HB_FUNC( UNLOADRICHEDITLIB )
{
   if( hRELib )
   {
      FreeLibrary( hRELib );
      hRELib = NULL;
   }
}

DWORD CALLBACK EditStreamCallbackR( DWORD_PTR dwCookie, LPBYTE lpbBuff, LONG cb, LONG FAR * pcb )
{
   HANDLE hFile = ( HANDLE ) dwCookie;

   if( ! ReadFile( hFile, ( LPVOID ) lpbBuff, cb, ( LPDWORD ) pcb, NULL ) )
      return -1;

   return 0;
}

DWORD CALLBACK EditStreamCallbackW( DWORD_PTR dwCookie, LPBYTE lpbBuff, LONG cb, LONG FAR * pcb )
{
   HANDLE hFile = ( HANDLE ) dwCookie;

   if( ! WriteFile( hFile, ( LPVOID ) lpbBuff, cb, ( LPDWORD ) pcb, NULL ) )
      return -1;

   return 0;
}

HB_FUNC( STREAMIN )        //StreamIn(HWND hwndCtrl, LPCTSTR lpszPath, int typ )
{
   HWND       hwnd;
   HANDLE     hFile;
   EDITSTREAM es;
   long       Flag, Mode;

   hwnd = ( HWND ) HB_PARNL( 1 );
   switch( hb_parni( 3 ) )
   {
      case 1:    Flag = SF_TEXT; Mode = TM_PLAINTEXT; break;
      case 2:    Flag = SF_RTF; Mode = TM_RICHTEXT; break;
      case 3:    Flag = SF_TEXT | SF_UNICODE; Mode = TM_PLAINTEXT; break;
      case 4:    Flag = ( CP_UTF8 << 16 ) | SF_USECODEPAGE | SF_TEXT; Mode = TM_PLAINTEXT; break;
      case 5:    Flag = ( CP_UTF8 << 16 ) | SF_USECODEPAGE | SF_RTF; Mode = TM_RICHTEXT; break;
      case 6:    Flag = ( CP_UTF7 << 16 ) | SF_USECODEPAGE | SF_TEXT; Mode = TM_PLAINTEXT; break;
      default:   Flag = SF_TEXT; Mode = TM_PLAINTEXT;
   }

   // open the source file.
   if( ( hFile = CreateFile( hb_parc( 2 ), GENERIC_READ, FILE_SHARE_READ, NULL, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, NULL ) ) == INVALID_HANDLE_VALUE )
   {
      hb_retl( FALSE );
      return;
   }

   es.pfnCallback = EditStreamCallbackR;
   es.dwCookie    = ( DWORD_PTR ) hFile;
   es.dwError     = 0;

   // send EM_STREAMIN message to the Rich Edit Control.
   SendMessage( hwnd, ( UINT ) EM_STREAMIN, ( WPARAM ) Flag, ( LPARAM ) &es );
   SendMessage( hwnd, ( UINT ) EM_SETTEXTMODE, ( WPARAM ) Mode, 0 );

   CloseHandle( hFile );

   if( es.dwError )
      hb_retl( FALSE );
   else
      hb_retl( TRUE );
}

HB_FUNC( STREAMOUT )       //StreamOut(HWND hwndCtrl, LPCTSTR lpszPath, int Typ )
{
   HWND       hwnd;
   HANDLE     hFile;
   EDITSTREAM es;
   long       Flag;

   hwnd = ( HWND ) HB_PARNL( 1 );
   switch( hb_parni( 3 ) )
   {
      case 1:  Flag = SF_TEXT; break;
      case 2:  Flag = SF_RTF; break;
      case 3:  Flag = SF_TEXT | SF_UNICODE; break;
      case 4:  Flag = ( CP_UTF8 << 16 ) | SF_USECODEPAGE | SF_TEXT; break;
      case 5:  Flag = ( CP_UTF8 << 16 ) | SF_USECODEPAGE | SF_RTF; break;
      case 6:  Flag = ( CP_UTF7 << 16 ) | SF_USECODEPAGE | SF_TEXT; break;
      default: Flag = SF_TEXT;
   }

   // open the destination file.
   if( ( hFile = CreateFile( hb_parc( 2 ), GENERIC_WRITE, FILE_SHARE_WRITE, NULL, CREATE_ALWAYS, FILE_ATTRIBUTE_NORMAL, NULL ) ) == INVALID_HANDLE_VALUE )
   {
      hb_retl( FALSE );
      return;
   }

   es.pfnCallback = EditStreamCallbackW;
   es.dwCookie    = ( DWORD_PTR ) hFile;
   es.dwError     = 0;

   // send EM_STREAMOUT message to the Rich Edit Control.
   SendMessage( hwnd, EM_STREAMOUT, ( WPARAM ) Flag, ( LPARAM ) &es );

   CloseHandle( hFile );

   if( es.dwError )
      hb_retl( FALSE );
   else
      hb_retl( TRUE );
}

HB_FUNC( GETAUTOFONTRTF )  // GetAutoFont(HWND hwnd)
{
   HWND    hwnd;
   LRESULT lAuto;

   hwnd  = ( HWND ) HB_PARNL( 1 );
   lAuto = SendMessage( hwnd, EM_GETLANGOPTIONS, 0, 0 ) & IMF_AUTOFONT;

   if( lAuto )
      hb_retl( TRUE );
   else
      hb_retl( FALSE );
}

HB_FUNC( SETAUTOFONTRTF )  // SetAutoFont(HWND hwnd, lAutoFont)
{
   HWND    hwnd;
   LRESULT lOpt, lResult;

   hwnd = ( HWND ) HB_PARNL( 1 );
   lOpt = SendMessage( hwnd, EM_GETLANGOPTIONS, 0, 0 );

   if( hb_parl( 2 ) )
      lOpt &= IMF_AUTOFONT;
   else
      lOpt &= ~IMF_AUTOFONT;

   lResult = SendMessage( hwnd, EM_SETLANGOPTIONS, 0, lOpt );

   if( lResult )
      hb_retl( TRUE );
   else
      hb_retl( FALSE );
}

HB_FUNC( SETBKGNDCOLOR )   // SetBkgndColor(HWND hwnd, lSyscol, nRed, nGreen, nBlue)
{
   LRESULT  lResult;
   COLORREF bkgcolor;
   INT      syscol = 1;

   bkgcolor = ( COLORREF ) RGB( hb_parni( 3 ), hb_parni( 4 ), hb_parni( 5 ) );
   if( hb_parl( 2 ) )
      syscol = 0;

   lResult = SendMessage( ( HWND ) HB_PARNL( 1 ), ( UINT ) EM_SETBKGNDCOLOR, ( WPARAM ) syscol, ( LPARAM ) bkgcolor );

   hb_retnl( lResult );
}

HB_FUNC( GETFONTRTF )
{
   CHARFORMAT cF;
   long       PointSize;
   int        bold;
   int        Italic;
   int        Underline;
   int        StrikeOut;
   int        SelText;

   cF.cbSize = sizeof( CHARFORMAT );
   cF.dwMask = CFM_BOLD | CFM_ITALIC | CFM_UNDERLINE | CFM_SIZE;
   if( hb_parni( 2 ) > 0 )
      SelText = SCF_SELECTION;
   else
      SelText = SCF_DEFAULT;

   SendMessage( ( HWND ) HB_PARNL( 1 ), EM_GETCHARFORMAT, ( WPARAM ) SelText, ( LPARAM ) &cF );

   PointSize = cF.yHeight / 20;

   bold      = ( cF.dwEffects & CFE_BOLD ) ? 1 : 0;
   Italic    = ( cF.dwEffects & CFE_ITALIC ) ? 1 : 0;
   Underline = ( cF.dwEffects & CFE_UNDERLINE ) ? 1 : 0;
   StrikeOut = ( cF.dwEffects & CFE_STRIKEOUT ) ? 1 : 0;

   hb_reta( 8 );
   HB_STORC( cF.szFaceName, -1, 1 );
   HB_STORVNL( ( LONG ) PointSize, -1, 2 );
   HB_STORL( bold, -1, 3 );
   HB_STORL( Italic, -1, 4 );
   HB_STORVNL( cF.crTextColor, -1, 5 );
   HB_STORL( Underline, -1, 6 );
   HB_STORL( StrikeOut, -1, 7 );
   HB_STORNI( cF.bCharSet, -1, 8 );
}

HB_FUNC( SETFONTRTF )
{
   LRESULT    lResult;
   CHARFORMAT cF;
   DWORD      Mask;
   DWORD      Effects = 0;
   int        SelText = SCF_SELECTION;

   cF.cbSize = sizeof( CHARFORMAT );
   Mask      = SendMessage( ( HWND ) HB_PARNL( 1 ), EM_GETCHARFORMAT, ( WPARAM ) SelText, ( LPARAM ) &cF );

   if( hb_parni( 10 ) > 0 )
      Mask = hb_parni( 10 );

   if( hb_parni( 2 ) > 0 )
      SelText = SCF_SELECTION | SCF_WORD;

   if( hb_parni( 2 ) < 0 )
      SelText = SCF_ALL;

   if( hb_parl( 5 ) )
      Effects = Effects | CFE_BOLD;

   if( hb_parl( 6 ) )
      Effects = Effects | CFE_ITALIC;

   if( hb_parl( 8 ) )
      Effects = Effects | CFE_UNDERLINE;

   if( hb_parl( 9 ) )
      Effects = Effects | CFE_STRIKEOUT;

   cF.dwMask    = Mask;
   cF.dwEffects = Effects;
   if( hb_parnl( 4 ) )
      cF.yHeight = hb_parnl( 4 ) * 20;

   cF.crTextColor = hb_parnl( 7 );

   if( hb_parclen( 3 ) > 0 )
      lstrcpy( cF.szFaceName, hb_parc( 3 ) );

   lResult = SendMessage( ( HWND ) HB_PARNL( 1 ), EM_SETCHARFORMAT, ( WPARAM ) SelText, ( LPARAM ) &cF );

   if( lResult )
      hb_retl( TRUE );
   else
      hb_retl( FALSE );
}

static BOOL IsWinxpSp1Min( void )
{
   char *        pch;
   OSVERSIONINFO osvi;

   osvi.dwOSVersionInfoSize = sizeof( osvi );

   if( ! GetVersionEx( &osvi ) )
      return FALSE;

   if( osvi.dwMajorVersion >= 5 )
   {
      if( osvi.dwMajorVersion == 5 && osvi.dwMinorVersion == 0 )
         return FALSE;
      else if( osvi.dwMajorVersion == 5 && osvi.dwMinorVersion == 1 )
      {
         pch = strstr( osvi.szCSDVersion, "Service Pack" );
         if( lstrcmpi( pch, "Service Pack 1" ) >= 0 )
            return TRUE;
         else
            return FALSE;
      }
      return TRUE;
   }

   return FALSE;
}
