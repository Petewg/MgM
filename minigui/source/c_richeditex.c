/*----------------------------------------------------------------------------
   HMG - Harbour Windows GUI library source code

   Copyright 2002-2017 Roberto Lopez <mail.box.hmg@gmail.com>
   http://sites.google.com/site/hmgweb/

   Head of HMG project:

      2002-2012 Roberto Lopez <mail.box.hmg@gmail.com>
      http://sites.google.com/site/hmgweb/

      2012-2017 Dr. Claudio Soto <srvet@adinet.com.uy>
      http://srvet.blogspot.com

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
   contained in this release of HMG.

   The exception is that, if you link the HMG library with other
   files to produce an executable, this does not by itself cause the resulting
   executable to be covered by the GNU General Public License.
   Your use of that executable is in no way restricted on account of linking the
   HMG library code into it.

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
        Copyright 2001-2008 Alexander S.Kresin <alex@kresin.ru>

   ---------------------------------------------------------------------------*/

#include <mgdefs.h>
#include <commdlg.h>
#include <commctrl.h>

#if defined( _MSC_VER )
# pragma warning(push)
# pragma warning(disable:4201)  /* warning C4201: nonstandard extension used: nameless struct/union */
#endif
#include <richedit.h>
#if defined( _MSC_VER )
# pragma warning(pop)
#endif
#include <shlwapi.h>

#ifdef __XHARBOUR__
# define HB_PARNL3       hb_parnl
#else
# define HB_PARNL3       hb_parvnl
#endif

#ifdef __POCC__
# define PFNS_NEWNUMBER  0x8000
#endif

#if defined ( __WATCOMC__ )
# define SF_USECODEPAGE  0x0020 /* CodePage given by high word */
#endif
// by Dr. Claudio Soto, January 2014

#ifndef CP_UNICODE
# define CP_UNICODE      1200 // The text is UTF-16 (the WCHAR data type)
#endif

#ifdef UNICODE
   LPSTR  WideToAnsi( LPWSTR );
#endif
HINSTANCE GetInstance( void );

static HINSTANCE hRELib = NULL;

HB_FUNC( INITRICHEDITBOXEX )
{
   HWND  hWnd        = ( HWND ) HB_PARNL( 1 );
   HMENU hMenu       = ( HMENU ) HB_PARNL( 2 );
   HWND  hWndControl = NULL;

   int Style = ES_MULTILINE | ES_WANTRETURN | WS_CHILD | ES_NOHIDESEL;

   if( hb_parl( 10 ) )
      Style = Style | ES_READONLY;

   if( ! hb_parl( 11 ) )
      Style = Style | WS_VISIBLE;

   if( ! hb_parl( 12 ) )
      Style = Style | WS_TABSTOP;

   if( ! hb_parl( 13 ) )
      Style = Style | WS_HSCROLL;

   Style = Style | ( ( ! hb_parl( 14 ) ) ? WS_VSCROLL : ES_AUTOVSCROLL );

   if( ! hRELib )
      hRELib = LoadLibrary( TEXT( "RichEd20.dll" ) );

   if( hRELib )
   {
      hWndControl = CreateWindowEx( WS_EX_CLIENTEDGE, ( LPCTSTR ) RICHEDIT_CLASS,
                                    TEXT( "" ),
                                    Style,
                                    hb_parni( 3 ),
                                    hb_parni( 4 ),
                                    hb_parni( 5 ),
                                    hb_parni( 6 ),
                                    hWnd,
                                    hMenu,
                                    GetInstance(),
                                    NULL );

      SendMessage( hWndControl, EM_LIMITTEXT, ( WPARAM ) hb_parni( 9 ), 0 );
      SendMessage( hWndControl, EM_SETEVENTMASK, ( WPARAM ) 0, ( LPARAM ) ( ENM_CHANGE | ENM_SELCHANGE | ENM_PROTECTED | ENM_SCROLL | ENM_LINK | ENM_KEYEVENTS | ENM_REQUESTRESIZE | ENM_MOUSEEVENTS ) );

      SendMessage( hWndControl, EM_SETTYPOGRAPHYOPTIONS, TO_ADVANCEDTYPOGRAPHY, TO_ADVANCEDTYPOGRAPHY );

      RegisterClipboardFormat( CF_RTF );
      RegisterClipboardFormat( CF_RETEXTOBJ );
   }

   HB_RETNL( ( LONG_PTR ) hWndControl );
}

HB_FUNC( UNLOADRICHEDITEXLIB )
{
   if( hRELib )
   {
      FreeLibrary( hRELib );
      hRELib = NULL;
   }
}

DWORD CALLBACK EditStreamCallbackRead( DWORD_PTR dwCookie, LPBYTE lpBuff, LONG cb, LONG * pcb )
{
   HANDLE hFile = ( HANDLE ) dwCookie;

   if( ReadFile( hFile, ( LPVOID ) lpBuff, ( DWORD ) cb, ( LPDWORD ) pcb, NULL ) )
      return 0;
   else
      return ( DWORD ) -1;
}

//        RichEditBox_StreamIn ( hWndControl, cFileName, lSelection, nDataFormat )
HB_FUNC( RICHEDITBOX_STREAMIN )
{
   HWND       hWndControl = ( HWND ) HB_PARNL( 1 );
#ifndef UNICODE
   TCHAR *    cFileName = ( TCHAR * ) hb_parc( 2 );
#else
   TCHAR *    cFileName = ( TCHAR * ) hb_osStrU16Encode( hb_parc( 2 ) );
#endif
   BOOL       lSelection  = ( BOOL ) hb_parl( 3 );
   LONG       nDataFormat = ( LONG ) hb_parnl( 4 );
   HANDLE     hFile;
   EDITSTREAM es;
   LONG       Format;

   switch( nDataFormat )
   {
      case 1:   Format = SF_TEXT; break;                                      // ANSI and UTF-8 with BOM
      case 2:   Format = ( CP_UTF8 << 16 ) | SF_USECODEPAGE | SF_TEXT; break; // ANSI and UTF-8 without BOM
      case 3:   Format = SF_TEXT | SF_UNICODE; break;                         // UTF-16 LE
      case 4:   Format = SF_RTF;  break;
      case 5:   Format = ( CP_UTF8 << 16 ) | SF_USECODEPAGE | SF_RTF; break;
      default:  Format = SF_RTF; break;
   }

   if( lSelection )
      Format = Format | SFF_SELECTION;

   if( ( hFile = CreateFile( cFileName, GENERIC_READ, FILE_SHARE_READ, NULL, OPEN_EXISTING, FILE_FLAG_SEQUENTIAL_SCAN, NULL ) ) == INVALID_HANDLE_VALUE )
   {
      hb_retl( FALSE );
      return;
   }

   es.pfnCallback = EditStreamCallbackRead;
   es.dwCookie    = ( DWORD_PTR ) hFile;
   es.dwError     = 0;

   SendMessage( hWndControl, EM_STREAMIN, ( WPARAM ) Format, ( LPARAM ) &es );

   CloseHandle( hFile );

   if( es.dwError )
      hb_retl( FALSE );
   else
      hb_retl( TRUE );
}

DWORD CALLBACK EditStreamCallbackWrite( DWORD_PTR dwCookie, LPBYTE lpBuff, LONG cb, LONG * pcb )
{
   HANDLE hFile = ( HANDLE ) dwCookie;

   if( WriteFile( hFile, ( LPVOID ) lpBuff, ( DWORD ) cb, ( LPDWORD ) pcb, NULL ) )
      return 0;
   else
      return ( DWORD ) -1;
}

//        RichEditBox_StreamOut ( hWndControl, cFileName, lSelection, nDataFormat )
HB_FUNC( RICHEDITBOX_STREAMOUT )
{
   HWND       hWndControl = ( HWND ) HB_PARNL( 1 );
#ifndef UNICODE
   TCHAR *    cFileName = ( TCHAR * ) hb_parc( 2 );
#else
   TCHAR *    cFileName = ( TCHAR * ) hb_osStrU16Encode( hb_parc( 2 ) );
#endif
   BOOL       lSelection  = ( BOOL ) hb_parl( 3 );
   LONG       nDataFormat = ( LONG ) hb_parnl( 4 );
   HANDLE     hFile;
   EDITSTREAM es;
   LONG       Format;

   switch( nDataFormat )
   {
      case 1:   Format = SF_TEXT; break;                                      // ANSI and UTF-8 with BOM
      case 2:   Format = ( CP_UTF8 << 16 ) | SF_USECODEPAGE | SF_TEXT; break; // ANSI and UTF-8 without BOM
      case 3:   Format = SF_TEXT | SF_UNICODE; break;                         // UTF-16 LE
      case 4:   Format = SF_RTF;  break;
      case 5:   Format = ( CP_UTF8 << 16 ) | SF_USECODEPAGE | SF_RTF; break;
      default:  Format = SF_RTF; break;
   }

   if( lSelection )
      Format = Format | SFF_SELECTION;

   if( ( hFile = CreateFile( cFileName, GENERIC_WRITE, FILE_SHARE_WRITE, NULL, CREATE_ALWAYS, FILE_ATTRIBUTE_NORMAL, NULL ) ) == INVALID_HANDLE_VALUE )
   {
      hb_retl( FALSE );
      return;
   }

   es.pfnCallback = EditStreamCallbackWrite;
   es.dwCookie    = ( DWORD_PTR ) hFile;
   es.dwError     = 0;

   SendMessage( hWndControl, EM_STREAMOUT, ( WPARAM ) Format, ( LPARAM ) &es );

   CloseHandle( hFile );

   if( es.dwError )
      hb_retl( FALSE );
   else
      hb_retl( TRUE );
}

//        RichEditBox_RTFLoadResourceFile ( hWndControl, cFileName, lSelect )
HB_FUNC( RICHEDITBOX_RTFLOADRESOURCEFILE )
{
   HWND hWndControl       = ( HWND ) HB_PARNL( 1 );
#ifndef UNICODE
   TCHAR *      cFileName = ( TCHAR * ) hb_parc( 2 );
#else
   TCHAR *      cFileName = ( TCHAR * ) hb_osStrU16Encode( hb_parc( 2 ) );
#endif
   BOOL         lSelect   = ( BOOL ) hb_parl( 3 );

   HRSRC   hResourceData;
   HGLOBAL hGlobalResource;
   TCHAR * lpGlobalResource = NULL;

   hResourceData = FindResource( NULL, cFileName, TEXT( "RTF" ) );
   if( hResourceData != NULL )
   {
      hGlobalResource = LoadResource( NULL, hResourceData );
      if( hGlobalResource != NULL )
      {
         lpGlobalResource = LockResource( hGlobalResource );
         if( lpGlobalResource != NULL )
         {
            SETTEXTEX ST;
            ST.flags = ( lSelect ? ST_SELECTION : ST_DEFAULT );
               #ifdef UNICODE
            ST.codepage = CP_UNICODE;
               #else
            ST.codepage = CP_ACP;
               #endif
            SendMessage( hWndControl, EM_SETTEXTEX, ( WPARAM ) &ST, ( LPARAM ) lpGlobalResource );
         }
         FreeResource( hGlobalResource );
      }
   }

   if( lpGlobalResource == NULL )
      hb_retl( ( BOOL ) FALSE );
   else
      hb_retl( ( BOOL ) TRUE );
}

//        RichEditBox_SetRTFTextMode ( hWndControl, lRTF )
HB_FUNC( RICHEDITBOX_SETRTFTEXTMODE )
{
   HWND hWndControl = ( HWND ) HB_PARNL( 1 );
   BOOL lRTF        = ( HB_ISLOG( 2 ) ? ( BOOL ) hb_parl( 2 ) : TRUE );
   LONG Mode        = ( lRTF ? TM_RICHTEXT : TM_PLAINTEXT ) | TM_MULTILEVELUNDO | TM_MULTICODEPAGE;

   SendMessage( hWndControl, EM_SETTEXTMODE, ( WPARAM ) Mode, 0 );
}

//        RichEditBox_IsRTFTextMode ( hWndControl ) --> return lRTF
HB_FUNC( RICHEDITBOX_ISRTFTEXTMODE )
{
   HWND    hWndControl = ( HWND ) HB_PARNL( 1 );
   LRESULT lResult     = SendMessage( hWndControl, EM_GETTEXTMODE, 0, 0 );

   hb_retl( ( BOOL ) ( lResult & TM_RICHTEXT ) );
}

//        RichEditBox_SetAutoURLDetect ( hWndControl, lLink )
HB_FUNC( RICHEDITBOX_SETAUTOURLDETECT )
{
   HWND hWndControl = ( HWND ) HB_PARNL( 1 );
   BOOL lLink       = ( HB_ISLOG( 2 ) ? ( BOOL ) hb_parl( 2 ) : TRUE );

   SendMessage( hWndControl, EM_AUTOURLDETECT, ( WPARAM ) lLink, 0 );
}

//        RichEditBox_GetAutoURLDetect ( hWndControl ) --> return lLink
HB_FUNC( RICHEDITBOX_GETAUTOURLDETECT )
{
   HWND hWndControl = ( HWND ) HB_PARNL( 1 );
   BOOL lLink       = ( BOOL ) SendMessage( hWndControl, EM_GETAUTOURLDETECT, 0, 0 );

   hb_retl( ( BOOL ) lLink );
}

//        RichEditBox_SetBkgndColor ( hWndControl, [ aBkgndColor ] )
HB_FUNC( RICHEDITBOX_SETBKGNDCOLOR )
{
   HWND hWndControl = ( HWND ) HB_PARNL( 1 );

   if( HB_ISARRAY( 2 ) )
      SendMessage( hWndControl, EM_SETBKGNDCOLOR, 0, ( LPARAM ) RGB( HB_PARNI( 2, 1 ), HB_PARNI( 2, 2 ), HB_PARNI( 2, 3 ) ) );
   else
      SendMessage( hWndControl, EM_SETBKGNDCOLOR, ( WPARAM ) 1, 0 );  // Set to the window background system color
}

//        RichEditBox_SetZoom ( hWndControl, nNumerator, nDenominator )
HB_FUNC( RICHEDITBOX_SETZOOM ) // ZoomRatio = nNumerator / nDenominator
{
   HWND hWndControl = ( HWND ) HB_PARNL( 1 );

   SendMessage( hWndControl, EM_SETZOOM, ( WPARAM ) hb_parni( 2 ), ( LPARAM ) hb_parni( 3 ) ); //    1/64 < ZoomRatio < 64
}

//        RichEditBox_GetZoom ( hWndControl, @nNumerator, @nDenominator )
HB_FUNC( RICHEDITBOX_GETZOOM )
{
   int  nNumerator, nDenominator;
   HWND hWndControl = ( HWND ) HB_PARNL( 1 );

   SendMessage( hWndControl, EM_GETZOOM, ( WPARAM ) &nNumerator, ( LPARAM ) &nDenominator );

   if( HB_ISBYREF( 2 ) )
      hb_storni( nNumerator, 2 );

   if( HB_ISBYREF( 3 ) )
      hb_storni( nDenominator, 3 );
}

//        RichEditBox_SetFont( hWndControl, cFontName, nFontSize, lBold, lItalic, lUnderline, lStrikeout, aTextColor, aBackColor, nScript, lLink )
HB_FUNC( RICHEDITBOX_SETFONT )
{
   HWND        hWndControl = ( HWND ) HB_PARNL( 1 );
   CHARFORMAT2 CharFormat2;
   DWORD       Mask    = 0;
   DWORD       Effects = 0;

   ZeroMemory( &CharFormat2, sizeof( CHARFORMAT2 ) );
   CharFormat2.cbSize = sizeof( CHARFORMAT2 );

   if( HB_ISCHAR( 2 ) )
   {
#ifndef UNICODE
   TCHAR *    szFaceName = ( TCHAR * ) hb_parc( 2 );
#else
   TCHAR *    szFaceName = ( TCHAR * ) hb_osStrU16Encode( ( char * ) hb_parc( 2 ) );
#endif
      Mask = Mask | CFM_FACE;
      lstrcpy( CharFormat2.szFaceName, szFaceName );
   }

   if( HB_ISNUM( 3 ) && hb_parnl( 3 ) )
   {
      Mask = Mask | CFM_SIZE;
      CharFormat2.yHeight = hb_parnl( 3 ) * 20 / 1;   // yHeight (character height) is in twips (1/1440 of an inch or 1/20 of a printer point)
   }

   if( HB_ISLOG( 4 ) )
   {
      Mask = Mask | CFM_BOLD;
      if( hb_parl( 4 ) )
         Effects = Effects | CFE_BOLD;
   }

   if( HB_ISLOG( 5 ) )
   {
      Mask = Mask | CFM_ITALIC;
      if( hb_parl( 5 ) )
         Effects = Effects | CFE_ITALIC;
   }

   if( HB_ISLOG( 6 ) )
   {
      Mask = Mask | CFM_UNDERLINE;
      if( hb_parl( 6 ) )
         Effects = Effects | CFE_UNDERLINE;
   }

   if( HB_ISLOG( 7 ) )
   {
      Mask = Mask | CFM_STRIKEOUT;
      if( hb_parl( 7 ) )
         Effects = Effects | CFE_STRIKEOUT;
   }

   if( HB_ISARRAY( 8 ) )
   {
      Mask = Mask | CFM_COLOR;
      CharFormat2.crTextColor = RGB( HB_PARNI( 8, 1 ), HB_PARNI( 8, 2 ), HB_PARNI( 8, 3 ) );
   }
   else if( HB_ISNUM( 8 ) && hb_parnl( 8 ) == -1 )
   {
      Mask    = Mask | CFM_COLOR;
      Effects = Effects | CFE_AUTOCOLOR;    // equivalent to GetSysColor(COLOR_WINDOWTEXT)
   }

   if( HB_ISARRAY( 9 ) )
   {
      Mask = Mask | CFM_BACKCOLOR;
      CharFormat2.crBackColor = RGB( HB_PARNI( 9, 1 ), HB_PARNI( 9, 2 ), HB_PARNI( 9, 3 ) );
   }
   else if( HB_ISNUM( 9 ) && hb_parnl( 9 ) == -1 )
   {
      Mask    = Mask | CFM_BACKCOLOR;
      Effects = Effects | CFE_AUTOBACKCOLOR;    // equivalent to GetSysColor(COLOR_WINDOW)
   }

   if( HB_ISNUM( 10 ) )
   {
      Mask = Mask | CFM_SUBSCRIPT | CFM_SUPERSCRIPT;    // The CFE_SUPERSCRIPT and CFE_SUBSCRIPT values are mutually exclusive
      if( hb_parnl( 10 ) == 1 )
         Effects = Effects | CFE_SUBSCRIPT;
      if( hb_parnl( 10 ) == 2 )
         Effects = Effects | CFE_SUPERSCRIPT;
   }

   if( HB_ISLOG( 11 ) )
   {
      Mask = Mask | CFM_LINK;
      if( hb_parl( 11 ) )
         Effects = Effects | CFE_LINK;
   }

   CharFormat2.dwMask    = Mask;
   CharFormat2.dwEffects = Effects;

   if( SendMessage( hWndControl, EM_SETCHARFORMAT, SCF_SELECTION, ( LPARAM ) &CharFormat2 ) )
      hb_retl( TRUE );
   else
      hb_retl( FALSE );
}

//        RichEditBox_GetFont( hWndControl, @cFontName, @nFontSize, @lBold, @lItalic, @lUnderline, @lStrikeout, @aTextColor, @aBackColor, @nScript, @lLink )
HB_FUNC( RICHEDITBOX_GETFONT )
{
   HWND        hWndControl = ( HWND ) HB_PARNL( 1 );
   CHARFORMAT2 CharFormat2;
   DWORD       Mask;
   DWORD       Effects;
#ifdef UNICODE
   LPSTR pStr;
#endif

   ZeroMemory( &CharFormat2, sizeof( CHARFORMAT2 ) );

   CharFormat2.cbSize = sizeof( CHARFORMAT2 );
   Mask = CFM_FACE | CFM_SIZE | CFM_BOLD | CFM_ITALIC | CFM_UNDERLINE | CFM_STRIKEOUT | CFM_COLOR | CFM_BACKCOLOR | CFM_SUBSCRIPT | CFM_SUPERSCRIPT | CFM_LINK;
   CharFormat2.dwMask = Mask;
   SendMessage( hWndControl, EM_GETCHARFORMAT, SCF_SELECTION, ( LPARAM ) &CharFormat2 );
   Effects = CharFormat2.dwEffects;

   if( HB_ISBYREF( 2 ) )
   {
#ifndef UNICODE
      hb_storc( CharFormat2.szFaceName, 2 );
#else
      pStr = WideToAnsi( CharFormat2.szFaceName );
      hb_storc( pStr, 2 );
      hb_xfree( pStr );
#endif
   }

   if( HB_ISBYREF( 3 ) )
      hb_stornl( ( LONG ) ( CharFormat2.yHeight * 1 / 20 ), 3 );  // yHeight (character height) is in twips (1/1440 of an inch or 1/20 of a printer point)

   if( HB_ISBYREF( 4 ) )
      hb_storl( ( BOOL ) ( Effects & CFE_BOLD ), 4 );

   if( HB_ISBYREF( 5 ) )
      hb_storl( ( BOOL ) ( Effects & CFE_ITALIC ), 5 );

   if( HB_ISBYREF( 6 ) )
      hb_storl( ( BOOL ) ( Effects & CFE_UNDERLINE ), 6 );

   if( HB_ISBYREF( 7 ) )
      hb_storl( ( BOOL ) ( Effects & CFE_STRIKEOUT ), 7 );

   if( HB_ISBYREF( 8 ) )
   {
      PHB_ITEM pArray = hb_param( 8, HB_IT_ANY );
      hb_arrayNew( pArray, 3 );
      hb_arraySetNL( pArray, 1, GetRValue( CharFormat2.crTextColor ) );
      hb_arraySetNL( pArray, 2, GetGValue( CharFormat2.crTextColor ) );
      hb_arraySetNL( pArray, 3, GetBValue( CharFormat2.crTextColor ) );
   }

   if( HB_ISBYREF( 9 ) )
   {
      PHB_ITEM pArray = hb_param( 9, HB_IT_ANY );
      hb_arrayNew( pArray, 3 );
      hb_arraySetNL( pArray, 1, GetRValue( CharFormat2.crBackColor ) );
      hb_arraySetNL( pArray, 2, GetGValue( CharFormat2.crBackColor ) );
      hb_arraySetNL( pArray, 3, GetBValue( CharFormat2.crBackColor ) );
   }

   if( HB_ISBYREF( 10 ) )
   {
      if( Effects & CFE_SUPERSCRIPT )
         hb_stornl( ( LONG ) 2, 10 );
      else if( Effects & CFE_SUBSCRIPT )
         hb_stornl( ( LONG ) 1, 10 );
      else
         hb_stornl( ( LONG ) 0, 10 );
   }

   if( HB_ISBYREF( 11 ) )
      hb_storl( ( BOOL ) ( Effects & CFE_LINK ), 11 );

}

//        RichEditBox_SetSelRange ( hWndControl, { nMin, nMax } )
HB_FUNC( RICHEDITBOX_SETSELRANGE )
{
   CHARRANGE CharRange;
   HWND      hWndControl = ( HWND ) HB_PARNL( 1 );

   CharRange.cpMin = ( LONG ) HB_PARVNL( 2, 1 );
   CharRange.cpMax = ( LONG ) HB_PARVNL( 2, 2 );

   SendMessage( hWndControl, EM_EXSETSEL, 0, ( LPARAM ) &CharRange );
}

//        RichEditBox_GetSelRange ( hWndControl ) --> return { nMin, nMax }
HB_FUNC( RICHEDITBOX_GETSELRANGE )
{
   CHARRANGE CharRange;
   HWND      hWndControl = ( HWND ) HB_PARNL( 1 );

   SendMessage( hWndControl, EM_EXGETSEL, 0, ( LPARAM ) &CharRange );
   hb_reta( 2 );
   HB_STORVNL( ( LONG ) CharRange.cpMin, -1, 1 );
   HB_STORVNL( ( LONG ) CharRange.cpMax, -1, 2 );
}

//        RichEditBox_ReplaceSel ( hWndControl, cText )   ==   RichEditBox_SetText ( hWndControl , .T. , cText )
HB_FUNC( RICHEDITBOX_REPLACESEL )
{
   HWND   hWndControl = ( HWND ) HB_PARNL( 1 );
   CHAR * cBuffer     = ( CHAR * ) hb_parc( 2 );

   SendMessage( hWndControl, EM_REPLACESEL, ( WPARAM ) ( BOOL ) TRUE, ( LPARAM ) cBuffer );
}

//        RichEditBox_SetText ( hWndControl , lSelect , cText )
HB_FUNC( RICHEDITBOX_SETTEXT )
{
   HWND   hWndControl = ( HWND ) HB_PARNL( 1 );
   BOOL   lSelect     = ( BOOL ) hb_parl( 2 );
   CHAR * cBuffer     = ( CHAR * ) hb_parc( 3 );

   SETTEXTEX ST;

   ST.flags = ( lSelect ? ST_SELECTION : ST_DEFAULT );
   #ifdef UNICODE
   ST.codepage = CP_UNICODE;
   #else
   ST.codepage = CP_ACP;
   #endif
   SendMessage( hWndControl, EM_SETTEXTEX, ( WPARAM ) &ST, ( LPARAM ) cBuffer );
}

//        RichEditBox_GetText ( hWndControl , lSelect )
HB_FUNC( RICHEDITBOX_GETTEXT )
{
#ifdef UNICODE
   LPSTR pStr;
#endif
   HWND hWndControl = ( HWND ) HB_PARNL( 1 );
   BOOL lSelect     = ( BOOL ) hb_parl( 2 );

   TCHAR cBuffer[ 4096 ];

   GETTEXTEX GT;

   GT.cb    = sizeof( cBuffer );
   GT.flags = ( lSelect ? GT_SELECTION : GT_DEFAULT );
   #ifdef UNICODE
   GT.codepage = CP_UNICODE;
   #else
   GT.codepage = CP_ACP;
   #endif
   GT.lpDefaultChar = NULL;
   GT.lpUsedDefChar = NULL;

   SendMessage( hWndControl, EM_GETTEXTEX, ( WPARAM ) &GT, ( LPARAM ) &cBuffer );

#ifndef UNICODE
   hb_retc( cBuffer );
#else
   pStr = WideToAnsi( cBuffer );
   hb_retc( pStr );
   hb_xfree( pStr );
#endif
}

//        RichEditBox_GetTextLength ( hWndControl )
HB_FUNC( RICHEDITBOX_GETTEXTLENGTH )
{
   HWND hWndControl = ( HWND ) HB_PARNL( 1 );
   LONG nLength;
   GETTEXTLENGTHEX GTL;

   GTL.flags = GTL_NUMCHARS;
   #ifdef UNICODE
   GTL.codepage = CP_UNICODE;
   #else
   GTL.codepage = CP_ACP;
   #endif
   nLength = ( LONG ) SendMessage( hWndControl, EM_GETTEXTLENGTHEX, ( WPARAM ) &GTL, 0 );

   hb_retnl( ( LONG ) nLength );
}

//        RichEditBox_GetTextRange ( hWndControl ,  { nMin, nMax }  )
HB_FUNC( RICHEDITBOX_GETTEXTRANGE )
{
#ifdef UNICODE
   LPSTR pStr;
#endif
   HWND      hWndControl = ( HWND ) HB_PARNL( 1 );

   TCHAR     cBuffer[ 4096 ];

   TEXTRANGE TextRange;

   TextRange.lpstrText  = cBuffer;
   TextRange.chrg.cpMin = HB_PARNL3( 2, 1 );
   TextRange.chrg.cpMax = HB_PARNL3( 2, 2 );

   SendMessage( hWndControl, EM_GETTEXTRANGE, 0, ( LPARAM ) &TextRange );

#ifndef UNICODE
   hb_retc( TextRange.lpstrText );
#else
   pStr = WideToAnsi( TextRange.lpstrText );
   hb_retc( pStr );
   hb_xfree( pStr );
#endif
}

//        RichEditBox_FindText ( hWndControl, cFind, lDown, lMatchCase, lWholeWord, lSelectFindText )
HB_FUNC( RICHEDITBOX_FINDTEXT )
{
   HWND    hWndControl    = ( HWND ) HB_PARNL( 1 );
#ifndef UNICODE
   TCHAR * cFind          = ( TCHAR * ) hb_parc( 2 );
#else
   TCHAR * cFind          = ( TCHAR * ) hb_osStrU16Encode( hb_parc( 2 ) );
#endif
   BOOL    Down           = ( BOOL ) ( HB_ISNIL( 3 ) ? TRUE  : hb_parl( 3 ) );
   BOOL    MatchCase      = ( BOOL ) ( HB_ISNIL( 4 ) ? FALSE : hb_parl( 4 ) );
   BOOL    WholeWord      = ( BOOL ) ( HB_ISNIL( 5 ) ? FALSE : hb_parl( 5 ) );
   BOOL    SelectFindText = ( BOOL ) ( HB_ISNIL( 6 ) ? TRUE  : hb_parl( 6 ) );

   CHARRANGE CharRange;
   int       Options = 0;

   #ifdef UNICODE
   FINDTEXTEXW FindText;
   #else
   FINDTEXTEX FindText;
   #endif

   if( Down )
      Options = Options | FR_DOWN;

   if( MatchCase )
      Options = Options | FR_MATCHCASE;

   if( WholeWord )
      Options = Options | FR_WHOLEWORD;

   SendMessage( hWndControl, EM_EXGETSEL, 0, ( LPARAM ) &CharRange );

   if( Down )
   {
      CharRange.cpMin = CharRange.cpMax;
      CharRange.cpMax = -1;
   }
   else
   {
      CharRange.cpMin = CharRange.cpMin;
      CharRange.cpMax = 0;
   }

   FindText.chrg      = CharRange;
   FindText.lpstrText = cFind;

   #ifdef UNICODE
   SendMessage( hWndControl, EM_FINDTEXTEXW, ( WPARAM ) Options, ( LPARAM ) &FindText );
   #else
   SendMessage( hWndControl, EM_FINDTEXTEX, ( WPARAM ) Options, ( LPARAM ) &FindText );
   #endif

   if( SelectFindText == FALSE )
      FindText.chrgText.cpMin = FindText.chrgText.cpMax;

   SendMessage( hWndControl, EM_EXSETSEL, 0, ( LPARAM ) &FindText.chrgText );

   hb_reta( 2 );
   HB_STORVNL( FindText.chrgText.cpMin, -1, 1 );
   HB_STORVNL( FindText.chrgText.cpMax, -1, 2 );
}

//        RichEditBox_SetParaFormat ( hWndControl, nAlignment, nNumbering, nNumberingStyle, nNumberingStart, ndOffset, ndLineSpacing, ndStartIndent )
HB_FUNC( RICHEDITBOX_SETPARAFORMAT )
{
   HWND   hWndControl    = ( HWND ) HB_PARNL( 1 );
   WORD   Alignment      = ( WORD ) ( HB_ISNIL( 2 ) ?    0 : hb_parni( 2 ) );
   WORD   Numbering      = ( WORD ) ( HB_ISNIL( 3 ) ?    0 : hb_parni( 3 ) );
   WORD   NumberingStyle = ( WORD ) ( HB_ISNIL( 4 ) ?    0 : hb_parni( 4 ) );
   WORD   NumberingStart = ( WORD ) ( HB_ISNIL( 5 ) ?    0 : hb_parni( 5 ) );
   double Offset         = HB_ISNIL( 6 ) ?  0.0 : ( double ) hb_parnd( 6 );
   double LineSpacing    = HB_ISNIL( 7 ) ?  0.0 : ( double ) hb_parnd( 7 );
   double StartIndent    = HB_ISNIL( 8 ) ?  0.0 : ( double ) hb_parnd( 8 );

   PARAFORMAT2 ParaFormat2;
   DWORD       Mask = 0;

   ZeroMemory( &ParaFormat2, sizeof( PARAFORMAT2 ) );

   ParaFormat2.cbSize = sizeof( PARAFORMAT2 );

   if( Alignment > 0 )
   {
      Mask = Mask | PFM_ALIGNMENT;
      switch( Alignment )
      {
         case 1:  ParaFormat2.wAlignment = PFA_LEFT; break;
         case 2:  ParaFormat2.wAlignment = PFA_RIGHT; break;
         case 3:  ParaFormat2.wAlignment = PFA_CENTER; break;
         case 4:  ParaFormat2.wAlignment = PFA_JUSTIFY; break;

         default: ParaFormat2.wAlignment = PFA_LEFT; break;
      }
   }

   if( Numbering > 0 )
   {
      Mask = Mask | PFM_NUMBERING;
      switch( Numbering )
      {
         case 1:  ParaFormat2.wNumbering = 0; break;             // No paragraph numbering or bullets
         case 2:  ParaFormat2.wNumbering = PFN_BULLET; break;    // Insert a bullet at the beginning of each selected paragraph
         case 3:  ParaFormat2.wNumbering = PFN_ARABIC; break;    // Use Arabic numbers          ( 0,  1,   2, ... )
         case 4:  ParaFormat2.wNumbering = PFN_LCLETTER; break;  // Use lowercase letters       ( a,  b,   c, ... )
         case 5:  ParaFormat2.wNumbering = PFN_LCROMAN; break;   // Use lowercase Roman letters ( i, ii, iii, ... )
         case 6:  ParaFormat2.wNumbering = PFN_UCLETTER; break;  // Use uppercase letters       ( A,  B,   C, ... )
         case 7:  ParaFormat2.wNumbering = PFN_UCROMAN; break;   // Use uppercase Roman letters ( I, II, III, ... )
         case 8:  ParaFormat2.wNumbering = 7; break;             // Uses a sequence of characters beginning with the Unicode character specified
         // by the nNumberingStart
         default: ParaFormat2.wNumbering = 0; break;
      }
   }


   if( NumberingStyle > 0 )
   {
      Mask = Mask | PFM_NUMBERINGSTYLE;
      switch( NumberingStyle )
      {
         case 1:  ParaFormat2.wNumberingStyle = PFNS_PAREN; break;      // Follows the number with a right parenthesis.
         case 2:  ParaFormat2.wNumberingStyle = PFNS_PARENS; break;     // Encloses the number in parentheses
         case 3:  ParaFormat2.wNumberingStyle = PFNS_PERIOD; break;     // Follows the number with a period
         case 4:  ParaFormat2.wNumberingStyle = PFNS_PLAIN; break;      // Displays only the number
         case 5:  ParaFormat2.wNumberingStyle = PFNS_NONUMBER; break;   // Continues a numbered list without applying the next number or bullet
         case 6:  ParaFormat2.wNumberingStyle = PFNS_NEWNUMBER; break;  // Starts a new number with nNumberingStart

         default: ParaFormat2.wNumberingStyle = 0; break;
      }
   }


   if( HB_ISNUM( 5 ) )
   {
      Mask = Mask | PFM_NUMBERINGSTART;
      ParaFormat2.wNumberingStart = NumberingStart;
   }


   if( HB_ISNUM( 6 ) )
   {
      Mask = Mask | PFM_OFFSET;
      ParaFormat2.dxOffset = ( LONG ) ( ( double ) ( Offset * 1440.0 / 25.4 ) ); // Offset is in millimeters ( 1 inch = 25.4 mm = 1440 twips )
   }


   if( LineSpacing > 0.0 )
   {
      Mask = Mask | PFM_LINESPACING;
      ParaFormat2.bLineSpacingRule = 5;    // Spacing from one line to the next, 20 twips = single-spaced text
      ParaFormat2.dyLineSpacing    = ( LONG ) ( ( double ) ( LineSpacing * 20.0 / 1.0 ) );
   }


   if( HB_ISNUM( 8 ) )
   {
      Mask = Mask | PFM_STARTINDENT;
      ParaFormat2.dxStartIndent = ( LONG ) ( ( double ) ( StartIndent * 1440.0 / 25.4 ) ); // StartIndent is in millimeters ( 1 inch = 25.4 mm = 1440 twips )
   }

   ParaFormat2.dwMask = Mask;
   SendMessage( hWndControl, EM_SETPARAFORMAT, 0, ( LPARAM ) &ParaFormat2 );
}

//        RichEditBox_GetParaFormat ( hWndControl, @nAlignment, @nNumbering, @nNumberingStyle, @nNumberingStart, @Offset, @ndLineSpacing, @ndStartIndent )
HB_FUNC( RICHEDITBOX_GETPARAFORMAT )
{
   HWND   hWndControl = ( HWND ) HB_PARNL( 1 );
   WORD   Alignment   = 0;
   WORD   Numbering   = 0;
   WORD   NumberingStyle;
   WORD   NumberingStart;
   double Offset;
   double LineSpacing = 0.0;
   double StartIndent;

   PARAFORMAT2 ParaFormat2;

   ZeroMemory( &ParaFormat2, sizeof( PARAFORMAT2 ) );

   ParaFormat2.cbSize = sizeof( PARAFORMAT2 );
   ParaFormat2.dwMask = PFM_ALIGNMENT | PFM_NUMBERING | PFM_NUMBERINGSTYLE | PFM_NUMBERINGSTART | PFM_LINESPACING | PFM_STARTINDENT | PFM_OFFSET;

   SendMessage( hWndControl, EM_GETPARAFORMAT, 0, ( LPARAM ) &ParaFormat2 );

   if( HB_ISBYREF( 2 ) )
   {
      if( ParaFormat2.wAlignment == PFA_LEFT )
         Alignment = 1;
      else if( ParaFormat2.wAlignment == PFA_RIGHT )
         Alignment = 2;
      else if( ParaFormat2.wAlignment == PFA_CENTER )
         Alignment = 3;
      else if( ParaFormat2.wAlignment == PFA_JUSTIFY )
         Alignment = 4;

      hb_stornl( ( LONG ) Alignment, 2 );
   }

   if( HB_ISBYREF( 3 ) )
   {
      if( ParaFormat2.wNumbering == 0 )
         Numbering = 1;
      else if( ParaFormat2.wNumbering == PFN_BULLET )
         Numbering = 2;
      else if( ParaFormat2.wNumbering == PFN_ARABIC )
         Numbering = 3;
      else if( ParaFormat2.wNumbering == PFN_LCLETTER )
         Numbering = 4;
      else if( ParaFormat2.wNumbering == PFN_LCROMAN )
         Numbering = 5;
      else if( ParaFormat2.wNumbering == PFN_UCLETTER )
         Numbering = 6;
      else if( ParaFormat2.wNumbering == PFN_UCROMAN )
         Numbering = 7;
      else if( ParaFormat2.wNumbering == 7 )
         Numbering = 8;

      hb_stornl( ( LONG ) Numbering, 3 );
   }

   if( HB_ISBYREF( 4 ) )
   {
      if( ParaFormat2.wNumberingStyle == PFNS_PAREN )
         NumberingStyle = 1;
      else if( ParaFormat2.wNumberingStyle == PFNS_PARENS )
         NumberingStyle = 2;
      else if( ParaFormat2.wNumberingStyle == PFNS_PERIOD )
         NumberingStyle = 3;
      else if( ParaFormat2.wNumberingStyle == PFNS_PLAIN )
         NumberingStyle = 4;
      else if( ParaFormat2.wNumberingStyle == PFNS_NONUMBER )
         NumberingStyle = 5;
      else if( ParaFormat2.wNumberingStyle == PFNS_NEWNUMBER )
         NumberingStyle = 6;
      else
         NumberingStyle = 0;

      hb_stornl( ( LONG ) NumberingStyle, 4 );
   }

   if( HB_ISBYREF( 5 ) )
   {
      NumberingStart = ParaFormat2.wNumberingStart;
      hb_stornl( ( LONG ) NumberingStart, 5 );
   }

   if( HB_ISBYREF( 6 ) )
   {
      Offset = ( double ) ParaFormat2.dxOffset;
      hb_stornd( ( double ) ( Offset * 25.4 / 1440.0 ), 6 );
   }

   if( HB_ISBYREF( 7 ) )
   {
      if( ParaFormat2.bLineSpacingRule == 0 )
         LineSpacing = 1.0;
      else if( ParaFormat2.bLineSpacingRule == 1 )
         LineSpacing = 1.5;
      else if( ParaFormat2.bLineSpacingRule == 2 )
         LineSpacing = 2.0;
      else if( ParaFormat2.bLineSpacingRule == 3 )
         LineSpacing = ( ( double ) ParaFormat2.dyLineSpacing ) * -1.0;  // if < 0 is in twips
      else if( ParaFormat2.bLineSpacingRule == 4 )
         LineSpacing = ( ( double ) ParaFormat2.dyLineSpacing ) * -1.0;  // if < 0 is in twips
      else if( ParaFormat2.bLineSpacingRule == 5 )
         LineSpacing = ( ( double ) ParaFormat2.dyLineSpacing ) * 1.0 / 20.0;

      hb_stornd( ( double ) LineSpacing, 7 );
   }

   if( HB_ISBYREF( 8 ) )
   {
      StartIndent = ( double ) ParaFormat2.dxStartIndent;
      hb_stornd( ( double ) ( StartIndent * 25.4 / 1440.0 ), 8 );
   }
}

HB_FUNC( RICHEDITBOX_SELCOPY )
{
   HWND hWndControl = ( HWND ) HB_PARNL( 1 );

   SendMessage( hWndControl, WM_COPY, 0, 0 );    // copy the current selection to the clipboard in CF_TEXT format
}

HB_FUNC( RICHEDITBOX_SELPASTE )
{
   HWND hWndControl = ( HWND ) HB_PARNL( 1 );

   SendMessage( hWndControl, WM_PASTE, 0, 0 );    // copy the current content of the clipboard at the current caret position,
}                                                 // data is inserted only if the clipboard contains data in CF_TEXT format

HB_FUNC( RICHEDITBOX_SELCUT )
{
   HWND hWndControl = ( HWND ) HB_PARNL( 1 );

   SendMessage( hWndControl, WM_CUT, 0, 0 );    // delete (cut) the current selection and place the deleted content on the clipboard
}

HB_FUNC( RICHEDITBOX_SELCLEAR )
{
   HWND hWndControl = ( HWND ) HB_PARNL( 1 );

   SendMessage( hWndControl, WM_CLEAR, 0, 0 );    // delete (cut) the current selection
}

HB_FUNC( RICHEDITBOX_CHANGEUNDO )
{
   HWND hWndControl = ( HWND ) HB_PARNL( 1 );

   SendMessage( hWndControl, EM_UNDO, 0, 0 );
}

HB_FUNC( RICHEDITBOX_CHANGEREDO )
{
   HWND hWndControl = ( HWND ) HB_PARNL( 1 );

   SendMessage( hWndControl, EM_REDO, 0, 0 );
}

HB_FUNC( RICHEDITBOX_CLEARUNDOBUFFER )
{
   HWND hWndControl = ( HWND ) HB_PARNL( 1 );

   SendMessage( hWndControl, EM_EMPTYUNDOBUFFER, 0, 0 );
}

HB_FUNC( RICHEDITBOX_CANPASTE )
{
   HWND hWndControl = ( HWND ) HB_PARNL( 1 );

   hb_retl( ( BOOL ) SendMessage( hWndControl, EM_CANPASTE, 0, 0 ) );
}

HB_FUNC( RICHEDITBOX_CANUNDO )
{
   HWND hWndControl = ( HWND ) HB_PARNL( 1 );

   hb_retl( ( BOOL ) SendMessage( hWndControl, EM_CANUNDO, 0, 0 ) );
}

HB_FUNC( RICHEDITBOX_CANREDO )
{
   HWND hWndControl = ( HWND ) HB_PARNL( 1 );

   hb_retl( ( BOOL ) SendMessage( hWndControl, EM_CANREDO, 0, 0 ) );
}

//        RichEditBox_GetRect ( hWndControl ) --> { nLeft, nTop, nRight, nBottom }
HB_FUNC( RICHEDITBOX_GETRECT )
{
   HWND hWndControl = ( HWND ) HB_PARNL( 1 );
   RECT rc;

   SendMessage( hWndControl, EM_GETRECT, ( WPARAM ) 0, ( LPARAM ) &rc );

   hb_reta( 4 );
   HB_STORNI( rc.left, -1, 1 );
   HB_STORNI( rc.top, -1, 2 );
   HB_STORNI( rc.right, -1, 3 );
   HB_STORNI( rc.bottom, -1, 4 );
}

//        RichEditBox_SetRect ( hWndControl, { nLeft, nTop, nRight, nBottom } )
HB_FUNC( RICHEDITBOX_SETRECT )
{
   HWND hWndControl = ( HWND ) HB_PARNL( 1 );
   RECT rc;

   rc.left   = HB_PARNI( 2, 1 );
   rc.top    = HB_PARNI( 2, 2 );
   rc.right  = HB_PARNI( 2, 3 );
   rc.bottom = HB_PARNI( 2, 4 );

   SendMessage( hWndControl, EM_SETRECT, ( WPARAM ) 1, ( LPARAM ) &rc );
}

//        RichEditBox_PastEspecial ( hWndControl , ClipboardFormat )
HB_FUNC( RICHEDITBOX_PASTESPECIAL )    // Paste a specific clipboard format in a rich edit control
{
   HWND hWndControl = ( HWND ) HB_PARNL( 1 );

   if( HB_ISCHAR( 2 ) )
   {
      CHAR * ClipboardFormat = ( CHAR * ) hb_parc( 2 );
      SendMessage( hWndControl, EM_PASTESPECIAL, ( WPARAM ) ClipboardFormat, ( LPARAM ) NULL );
   }
   else
   {
      WPARAM ClipboardFormat = ( WPARAM ) hb_parnl( 2 );
      SendMessage( hWndControl, EM_PASTESPECIAL, ( WPARAM ) ClipboardFormat, ( LPARAM ) NULL );
   }
}

//        RichEditBox_SetMargins ( hWndControl, LeftMargin, RightMargin )
HB_FUNC( RICHEDITBOX_SETMARGINS )
{
   HWND hWndControl = ( HWND ) HB_PARNL( 1 );
   WORD LeftMargin  = ( WORD ) hb_parni( 2 ); // in pixels
   WORD RightMargin = ( WORD ) hb_parni( 3 ); // in pixels

   SendMessage( hWndControl, EM_SETMARGINS, EC_USEFONTINFO, ( LPARAM ) MAKELPARAM( LeftMargin, RightMargin ) );
}

//        RichEditBox_FormatRange ( hWndControl, hDCPrinter, nLeft, nTop, nRight, nBottom, { cpMin , cpMax } )
HB_FUNC( RICHEDITBOX_FORMATRANGE )
{
   FORMATRANGE FormatRange;
   RECT        rc;
   LONG        cpMin;

   HWND hWndControl = ( HWND ) HB_PARNL( 1 );
   HDC  hDCPrinter  = ( HDC ) HB_PARNL( 2 );

   rc.left   = hb_parni( 3 );  // in twips
   rc.top    = hb_parni( 4 );  // in twips
   rc.right  = hb_parni( 5 );  // in twips
   rc.bottom = hb_parni( 6 );  // in twips

   FormatRange.hdc        = hDCPrinter;
   FormatRange.hdcTarget  = hDCPrinter;
   FormatRange.rc         = rc;
   FormatRange.rcPage     = rc;
   FormatRange.chrg.cpMin = HB_PARNL3( 7, 1 );
   FormatRange.chrg.cpMax = HB_PARNL3( 7, 2 );

   cpMin = ( LONG ) SendMessage( hWndControl, EM_FORMATRANGE, ( WPARAM ) ( BOOL ) TRUE, ( LPARAM ) &FormatRange );

   SendMessage( hWndControl, EM_FORMATRANGE, ( WPARAM ) ( BOOL ) FALSE, ( LPARAM ) NULL );

   hb_retnl( ( LONG ) cpMin );
}

//        RichEditBox_PosFromChar ( hWndControl , nPosChar )   return --> { nRowScreen, nColScreen } or { -1, -1 } if character is not displayed
HB_FUNC( RICHEDITBOX_POSFROMCHAR )
{
   HWND   hWndControl = ( HWND ) HB_PARNL( 1 );
   LONG   nPosChar    = ( LONG ) hb_parnl( 2 );
   POINTL PointL;
   POINT  Point;

   SendMessage( hWndControl, EM_POSFROMCHAR, ( WPARAM ) &PointL, ( LPARAM ) nPosChar );   // Retrieves the client area coordinates of
                                                                                          // a specified character in an edit control
   hb_reta( 2 );

   // A returned coordinate can be a negative value if the specified character is not displayed in the edit control's client area
   if( PointL.y < 0 || PointL.x < 0 )
   {
      Point.y = -1;
      Point.x = -1;
   }
   else
   {
      Point.x = ( INT ) PointL.x;
      Point.y = ( INT ) PointL.y;
      ClientToScreen( hWndControl, &Point );
   }

   HB_STORNI( ( INT ) Point.y, -1, 1 );
   HB_STORNI( ( INT ) Point.x, -1, 2 );
}

//********************************************************************
// by Dr. Claudio Soto ( January 2014 )
//********************************************************************

static TCHAR       cFindWhat[ 1024 ];
static TCHAR       cReplaceWith[ 1024 ];
static FINDREPLACE FindReplace;
static HWND        hDlgFindReplace = NULL;

HB_FUNC( REGISTERFINDMSGSTRING )
{
   UINT MessageID = RegisterWindowMessage( FINDMSGSTRING );

   hb_retnl( ( LONG ) MessageID );
}

HB_FUNC( FINDREPLACEDLG )
{
   HWND    hWnd           = HB_ISNIL( 1 ) ? GetActiveWindow() : ( HWND ) HB_PARNL( 1 );
   BOOL    NoUpDown       = ( BOOL ) ( HB_ISNIL( 2 ) ? FALSE : hb_parl( 2 ) );
   BOOL    NoMatchCase    = ( BOOL ) ( HB_ISNIL( 3 ) ? FALSE : hb_parl( 3 ) );
   BOOL    NoWholeWord    = ( BOOL ) ( HB_ISNIL( 4 ) ? FALSE : hb_parl( 4 ) );
   BOOL    CheckDown      = ( BOOL ) ( HB_ISNIL( 5 ) ? TRUE  : hb_parl( 5 ) );
   BOOL    CheckMatchCase = ( BOOL ) ( HB_ISNIL( 6 ) ? FALSE : hb_parl( 6 ) );
   BOOL    CheckWholeWord = ( BOOL ) ( HB_ISNIL( 7 ) ? FALSE : hb_parl( 7 ) );
   BOOL    lReplace       = ( BOOL ) hb_parl( 10 );
#ifndef UNICODE
   TCHAR * FindWhat       = ( TCHAR * ) hb_parc( 8 );
   TCHAR * ReplaceWith    = ( TCHAR * ) hb_parc( 9 );
   TCHAR * cTitle         = ( TCHAR * ) hb_parc( 11 );
#else
   TCHAR * FindWhat       = ( TCHAR * ) hb_osStrU16Encode( hb_parc( 8 ) );
   TCHAR * ReplaceWith    = ( TCHAR * ) hb_osStrU16Encode( hb_parc( 9 ) );
   TCHAR * cTitle         = ( TCHAR * ) hb_osStrU16Encode( hb_parc( 11 ) );
#endif

   if( hDlgFindReplace == NULL )
   {
      ZeroMemory( &FindReplace, sizeof( FindReplace ) );

      lstrcpy( cFindWhat, FindWhat );
      lstrcpy( cReplaceWith, ReplaceWith );

      FindReplace.lStructSize = sizeof( FindReplace );
      FindReplace.Flags       = ( NoUpDown  ? FR_HIDEUPDOWN : 0 ) | ( NoMatchCase    ? FR_HIDEMATCHCASE : 0 ) | ( NoWholeWord    ? FR_HIDEWHOLEWORD : 0 )
                                | ( CheckDown ? FR_DOWN : 0 ) | ( CheckMatchCase ? FR_MATCHCASE : 0 ) | ( CheckWholeWord ? FR_WHOLEWORD : 0 );
      FindReplace.hwndOwner        = hWnd;
      FindReplace.lpstrFindWhat    = cFindWhat;
      FindReplace.wFindWhatLen     = sizeof( cFindWhat ) / sizeof( TCHAR );
      FindReplace.lpstrReplaceWith = cReplaceWith;
      FindReplace.wReplaceWithLen  = sizeof( cReplaceWith ) / sizeof( TCHAR );

      if( lReplace )
         hDlgFindReplace = ReplaceText( &FindReplace );
      else
         hDlgFindReplace = FindText( &FindReplace );

      if( HB_ISCHAR( 11 ) )
         SetWindowText( hDlgFindReplace, cTitle );

      ShowWindow( hDlgFindReplace, SW_SHOW );
   }
}

HB_FUNC( FINDREPLACEDLGSETTITLE )
{
   TCHAR * cTitle = ( TCHAR * ) hb_parc( 1 );

   if( hDlgFindReplace != NULL )
      SetWindowText( hDlgFindReplace, cTitle );
}

HB_FUNC( FINDREPLACEDLGGETTITLE )
{
#ifdef UNICODE
   LPSTR pStr;
#endif
   TCHAR cTitle[ 256 ];

   if( hDlgFindReplace != NULL )
   {
      GetWindowText( hDlgFindReplace, cTitle, sizeof( cTitle ) / sizeof( TCHAR ) );
#ifndef UNICODE
      hb_retc( cTitle );
#else
      pStr = WideToAnsi( cTitle );
      hb_retc( pStr );
      hb_xfree( pStr );
#endif
   }
   else
   {
#ifndef UNICODE
      hb_retc( "" );
#else
      pStr = WideToAnsi( TEXT( "" ) );
      hb_retc( pStr );
      hb_xfree( pStr );
#endif
   }
}

HB_FUNC( FINDREPLACEDLGSHOW )
{
   BOOL lShow = HB_ISNIL( 1 ) ? TRUE : hb_parl( 1 );

   if( hDlgFindReplace != NULL )
   {
      if( lShow )
         ShowWindow( hDlgFindReplace, SW_SHOW );
      else
         ShowWindow( hDlgFindReplace, SW_HIDE );
   }
}

HB_FUNC( FINDREPLACEDLGGETHANDLE )
{
   HB_RETNL( ( LONG_PTR ) hDlgFindReplace );
}

HB_FUNC( FINDREPLACEDLGISRELEASE )
{
   hb_retl( ( BOOL ) ( hDlgFindReplace == NULL ) );
}

HB_FUNC( FINDREPLACEDLGRELEASE )
{
   BOOL lDestroy = HB_ISNIL( 1 ) ? TRUE : hb_parl( 1 );

   if( hDlgFindReplace != NULL && lDestroy )
      DestroyWindow( hDlgFindReplace );
   hDlgFindReplace = NULL;
}

HB_FUNC( FINDREPLACEDLGGETOPTIONS )
{
#ifdef UNICODE
   LPSTR pStr, pStr2;
#endif
   LPARAM        lParam = ( LPARAM ) HB_PARNL( 1 );
   FINDREPLACE * FR     = ( FINDREPLACE * ) lParam;
   LONG          nRet   = -1;

   if( FR->Flags & FR_DIALOGTERM )
      nRet = 0;

   if( FR->Flags & FR_FINDNEXT )
      nRet = 1;

   if( FR->Flags & FR_REPLACE )
      nRet = 2;

   if( FR->Flags & FR_REPLACEALL )
      nRet = 3;

   hb_reta( 6 );

   HB_STORVNL( ( LONG ) nRet, -1, 1 );
#ifndef UNICODE
   HB_STORC( FR->lpstrFindWhat, -1, 2 );
#else
   pStr = WideToAnsi( FR->lpstrFindWhat );
   HB_STORC( pStr, -1, 2 );
   hb_xfree( pStr );
#endif
#ifndef UNICODE
   HB_STORC( FR->lpstrReplaceWith, -1, 3 );
#else
   pStr2 = WideToAnsi( FR->lpstrReplaceWith );
   HB_STORC( pStr2, -1, 3 );
   hb_xfree( pStr2 );
#endif
   HB_STORL( ( BOOL ) ( FR->Flags & FR_DOWN ), -1, 4 );
   HB_STORL( ( BOOL ) ( FR->Flags & FR_MATCHCASE ), -1, 5 );
   HB_STORL( ( BOOL ) ( FR->Flags & FR_WHOLEWORD ), -1, 6 );
}
