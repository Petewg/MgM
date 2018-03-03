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
#include <mmsystem.h>

#if defined( __BORLANDC__ )
# pragma warn -use /* unused var */
#endif

#include <vfw.h>

HINSTANCE GetResources( void );

HB_FUNC( MESSAGEBEEP )
{
   hb_retl( MessageBeep( hb_parni( 1 ) ) );
}

HB_FUNC( C_PLAYWAVE )
{
   int     Style = SND_ASYNC;
   HMODULE hmod  = NULL;

   if( hb_parl( 2 ) )
   {
      Style = Style | SND_RESOURCE;
      hmod  = GetResources();
   }
   else
      Style = Style | SND_FILENAME;

   if( hb_parl( 3 ) )
      Style = Style | SND_SYNC;

   if( hb_parl( 4 ) )
      Style = Style | SND_NOSTOP;

   if( hb_parl( 5 ) )
      Style = Style | SND_LOOP;

   if( hb_parl( 6 ) )
      Style = Style | SND_NODEFAULT;

   hb_retl( PlaySound( hb_parc( 1 ), hmod, Style ) );
}

HB_FUNC( STOPWAVE )
{
   hb_retl( PlaySound( ( LPCSTR ) NULL, ( HMODULE ) GetResources(), SND_PURGE ) );
}

HB_FUNC( INITPLAYER )
{
   HWND hwnd;
   int  Style = WS_VISIBLE | WS_CHILD | WS_BORDER;

   if( hb_parl( 7 ) )
      Style = Style | MCIWNDF_NOAUTOSIZEWINDOW;

   if( hb_parl( 8 ) )
      Style = Style | MCIWNDF_NOAUTOSIZEMOVIE;

   if( hb_parl( 9 ) )
      Style = Style | MCIWNDF_NOERRORDLG;

   if( hb_parl( 10 ) )
      Style = Style | MCIWNDF_NOMENU;

   if( hb_parl( 11 ) )
      Style = Style | MCIWNDF_NOOPEN;

   if( hb_parl( 12 ) )
      Style = Style | MCIWNDF_NOPLAYBAR;

   if( hb_parl( 13 ) )
      Style = Style | MCIWNDF_SHOWALL;

   if( hb_parl( 14 ) )
      Style = Style | MCIWNDF_SHOWMODE;

   if( hb_parl( 15 ) )
      Style = Style | MCIWNDF_SHOWNAME;

   if( hb_parl( 16 ) )
      Style = Style | MCIWNDF_SHOWPOS;

   hwnd = MCIWndCreate( ( HWND ) HB_PARNL( 1 ), NULL, Style, hb_parc( 2 ) );

   if( hwnd == NULL )
   {
      MessageBox( 0, "Player Creation Failed!", "Error!", MB_ICONEXCLAMATION | MB_OK | MB_SYSTEMMODAL );
      return;
   }

   MoveWindow( hwnd, hb_parnl( 3 ), hb_parnl( 4 ), hb_parnl( 5 ), hb_parnl( 6 ), TRUE );
   HB_RETNL( ( LONG_PTR ) hwnd );
}

HB_FUNC( MCIFUNC )
{
   HWND mcihand = ( HWND ) HB_PARNL( 1 );
   int  func    = hb_parni( 2 );

   switch( func )
   {
      case 1:  hb_retnl( MCIWndPlay( mcihand ) ); break;
      case 2:  hb_retnl( MCIWndStop( mcihand ) ); break;
      case 3:  hb_retnl( MCIWndPause( mcihand ) ); break;
      case 4:  hb_retnl( MCIWndClose( mcihand ) ); break;
      case 5:            MCIWndDestroy( mcihand ); hb_retnl( 0 ); break;
      case 6:  hb_retnl( MCIWndEject( mcihand ) ); break;
      case 7:  hb_retnl( MCIWndEnd( mcihand ) ); break;
      case 8:  hb_retnl( MCIWndHome( mcihand ) ); break;
      case 9:  hb_retnl( MCIWndOpen( mcihand, hb_parc( 3 ), NULL ) ); break;
      case 10: hb_retnl( MCIWndOpenDialog( mcihand ) ); break;
      case 11: hb_retnl( MCIWndPlayReverse( mcihand ) ); break;
      case 12: hb_retnl( MCIWndResume( mcihand ) ); break;
      case 13:           MCIWndSetRepeat( mcihand, hb_parl( 3 ) ); hb_retnl( 0 ); break;
      case 14: hb_retnl( MCIWndSetSpeed( mcihand, hb_parni( 3 ) ) ); break;
      case 15: hb_retnl( MCIWndSetVolume( mcihand, hb_parni( 3 ) ) ); break;
      case 16:           MCIWndSetZoom( mcihand, hb_parni( 3 ) ); hb_retnl( 0 ); break;
      case 17: hb_retnl( MCIWndGetLength( mcihand ) ); break;
      case 18: hb_retnl( MCIWndGetPosition( mcihand ) ); break;
      case 19: hb_retnl( MCIWndGetVolume( mcihand ) ); break;
      case 20: hb_retnl( MCIWndSeek( mcihand, hb_parni( 3 ) ) ); break;
      default: hb_retnl( 0 );
   }
}

HB_FUNC( INITANIMATE )
{
   HWND hwnd;
   int  Style = WS_VISIBLE | WS_CHILD;

   if( hb_parl( 9 ) )
      Style = Style | WS_BORDER;

   if( hb_parl( 6 ) )
      Style = Style | ACS_AUTOPLAY;

   if( hb_parl( 7 ) )
      Style = Style | ACS_CENTER;

   if( hb_parl( 8 ) )
      Style = Style | ACS_TRANSPARENT;

   hwnd = Animate_Create( ( HWND ) HB_PARNL( 1 ), NULL, Style, GetResources() );

   if( hwnd == NULL )
   {
      MessageBox( 0, "AnimateBox Creation Failed!", "Error!", MB_ICONEXCLAMATION | MB_OK | MB_SYSTEMMODAL );
      return;
   }

   MoveWindow( hwnd, hb_parnl( 2 ), hb_parnl( 3 ), hb_parnl( 4 ), hb_parnl( 5 ), TRUE );
   HB_RETNL( ( LONG_PTR ) hwnd );
}

HB_FUNC( OPENANIMATE )
{
   Animate_Open( ( HWND ) HB_PARNL( 1 ), hb_parc( 2 ) );
}

HB_FUNC( PLAYANIMATE )
{
   Animate_Play( ( HWND ) HB_PARNL( 1 ), 0, -1, 1 );
}

HB_FUNC( SEEKANIMATE )
{
   Animate_Seek( ( HWND ) HB_PARNL( 1 ), hb_parni( 2 ) );
}

HB_FUNC( STOPANIMATE )
{
   Animate_Stop( ( HWND ) HB_PARNL( 1 ) );
}

HB_FUNC( CLOSEANIMATE )
{
   Animate_Close( ( HWND ) HB_PARNL( 1 ) );
}
