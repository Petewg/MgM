/*
   MINIGUI - Harbour Win32 GUI library source code

   Copyright 2002-2010 Roberto Lopez <harbourminigui@gmail.com>
   http://harbourminigui.googlepages.com/

   This    program  is  free  software;  you can redistribute it and/or modify
   it under  the  terms  of the GNU General Public License as published by the
   Free  Software   Foundation;  either  version 2 of the License, or (at your
   option) any later version.

   This   program   is   distributed  in  the hope that it will be useful, but
   WITHOUT    ANY    WARRANTY;    without   even   the   implied  warranty  of
   MERCHANTABILITY  or  FITNESS  FOR A PARTICULAR PURPOSE. See the GNU General
   Public License for more details.

   You   should  have  received a copy of the GNU General Public License along
   with   this   software;   see  the  file COPYING. If not, write to the Free
   Software   Foundation,   Inc.,   59  Temple  Place,  Suite  330, Boston, MA
   02111-1307 USA (or visit the web site http://www.gnu.org/).

   As   a   special  exception, you have permission for additional uses of the
   text  contained  in  this  release  of  Harbour Minigui.

   The   exception   is that,   if   you  link  the  Harbour  Minigui  library
   with  other    files   to  produce   an   executable,   this  does  not  by
   itself   cause  the   resulting   executable    to   be  covered by the GNU
   General  Public  License.  Your    use  of that   executable   is   in   no
   way  restricted on account of linking the Harbour-Minigui library code into
   it.

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

   Parts  of  this  code  is contributed and used here under permission of his
   author: Copyright 2016-2017 (C) P.Chornyj <myorg63@mail.ru>
 */

#define _WIN32_IE     0x0501

#if ( defined ( __MINGW32__ ) || defined ( __XCC__ ) ) && ( _WIN32_WINNT < 0x0500 )
#define _WIN32_WINNT  0x0500
#endif

#include <mgdefs.h>
#include <commctrl.h>
#include "hbapiitm.h"
#include "hbvm.h"
#ifdef __XHARBOUR__
#include "thread.h"
#else
#include "hbwinuni.h"
#include "hbthread.h"
#endif
#include "hbatomic.h"

#ifndef WC_STATIC
#define WC_STATIC         "Static"
#endif

#ifdef MAKELONG
#undef MAKELONG
#endif
#define MAKELONG( a, b )  ( ( LONG ) ( ( ( WORD ) ( ( DWORD_PTR ) ( a ) & 0xffff ) ) | ( ( ( DWORD ) ( ( WORD ) ( ( DWORD_PTR ) ( b ) & 0xffff ) ) ) << 16 ) ) )

#define DEFAULT_LISTENER  "EVENTS"
#define MAX_EVENTS        64

// locals types
typedef struct tagAppEvent
{
   UINT     message;
   PHB_ITEM bAction;
   BOOL     active;
} APPEVENT, * APPEVENT_PTR;

typedef struct tagEventsHolder
{
   HWND       hwnd;
   BOOL       active;
   size_t     count;
   HB_COUNTER used;
   APPEVENT   events[ MAX_EVENTS ];
} EVENTSHOLDER, * EVENTSHOLDER_PTR;

typedef struct tagMyParam
{
   PHB_DYNS Listener;
} MYPARAMS;

typedef struct tagMyUserData
{
   UINT     cbSize;
   MYPARAMS myParam;
} MYUSERDATA, UNALIGNED * PMYUSERDATA;

typedef struct tagWinEvent
{
   UINT     message;
   PHB_ITEM bBefore;
   PHB_ITEM bAction;
   PHB_ITEM bAfter;
   BOOL     active;
} WINEVENT, * WINEVENT_PTR;

typedef struct tagWinEventsHolder
{
   HWND       hwnd;
   BOOL       active;
   size_t     count;
   HB_COUNTER used;
   WINEVENT   events[ MAX_EVENTS ];
} WINEVENTSHOLDER, * WINEVENTSHOLDER_PTR;

// extern functions
extern void       hmg_ErrorExit( LPCTSTR lpMessage, DWORD dwError, BOOL bExit );
extern HBITMAP    HMG_LoadImage( const char * FileName );
// locals functions
static size_t  AppEventScan( EVENTSHOLDER * events, UINT message );
static LRESULT AppEventDo( EVENTSHOLDER * events, HB_BOOL bOnce, HWND hWnd, UINT message, WPARAM wParam, LPARAM lParam );
static LRESULT AppEventOn( HWND hWnd, UINT message, WPARAM wParam, LPARAM lParam );
static HB_BOOL AppEventRemove( HWND hWnd, const char * pszName, UINT message );
static size_t  WinEventScan( WINEVENTSHOLDER * events, UINT message );
static LRESULT WinEventDo( WINEVENTSHOLDER * events, HB_BOOL bOnce, HWND hWnd, UINT message, WPARAM wParam, LPARAM lParam );
static LRESULT WinEventOn( HWND hWnd, UINT message, WPARAM wParam, LPARAM lParam );
static HB_BOOL WinEventRemove( HWND hWnd, const char * pszName, UINT message );
LRESULT CALLBACK MsgOnlyWndProc( HWND hWnd, UINT message, WPARAM wParam, LPARAM lParam );
LRESULT CALLBACK WndProc( HWND hWnd, UINT message, WPARAM wParam, LPARAM lParam );
// extern variables
extern HINSTANCE g_hInstance;
extern HWND      g_hWndMain;
extern HACCEL    g_hAccel;
// static variables
static PHB_DYNS g_ListenerDyns = NULL;
#ifdef __XHARBOUR__
static HB_CRITICAL_T s_lst_mtx;
#define HMG_LISTENER_LOCK    HB_CRITICAL_LOCK( s_lst_mtx );
#define HMG_LISTENER_UNLOCK  HB_CRITICAL_UNLOCK( s_lst_mtx );
#else
static HB_CRITICAL_NEW( s_lst_mtx );
#define HMG_LISTENER_LOCK    hb_threadEnterCriticalSection( &s_lst_mtx )
#define HMG_LISTENER_UNLOCK  hb_threadLeaveCriticalSection( &s_lst_mtx )
#endif // __XHARBOUR__

HB_FUNC( GETGLOBALLISTENER )
{
   if( NULL != g_ListenerDyns )
      hb_retc( hb_dynsymName( g_ListenerDyns ) );
   else
      hb_retc_null();
}

HB_FUNC( SETGLOBALLISTENER )
{
   const char * pszNewName = hb_parc( 1 );

   if( pszNewName && hb_dynsymIsFunction( hb_dynsymGet( pszNewName ) ) )
   {
      HMG_LISTENER_LOCK;
      g_ListenerDyns = hb_dynsymGet( pszNewName ); hb_retl( HB_TRUE );
      HMG_LISTENER_UNLOCK;
   }
   else
      hb_retl( HB_FALSE );
}

HB_FUNC( RESETGLOBALLISTENER )
{
   HMG_LISTENER_LOCK;
   g_ListenerDyns = hb_dynsymGet( DEFAULT_LISTENER );
   HMG_LISTENER_UNLOCK;
}

static size_t AppEventScan( EVENTSHOLDER * events, UINT message )
{
   size_t i, nPos = 0;

   for( i = 0; i < events->count; i++ )
   {
      if( message == events->events[ i ].message )
      {
         nPos = ( i + 1 ); break;
      }
   }

   return nPos;
}

static HB_BOOL AppEventRemove( HWND hWnd, const char * pszProp, UINT message )
{
   if( IsWindow( hWnd ) )
   {
      EVENTSHOLDER * events = ( EVENTSHOLDER * ) GetProp( hWnd, pszProp );

      if( events != NULL )
      {
         if( message != 0 )
         {
            size_t nPos = AppEventScan( events, message );

            if( nPos > 0 )                                           // if found
            {
               hb_itemRelease( events->events[ nPos - 1 ].bAction ); // delete old codeblock

               events->events[ nPos - 1 ].message = 0;
               events->events[ nPos - 1 ].bAction = NULL;
               events->events[ nPos - 1 ].active  = FALSE;

               HB_ATOM_DEC( &events->used );
            }
         }
         else
         {
            size_t i;

            for( i = 0; i < events->count; i++ ) // delete all not empty items with codeblocks
               if( events->events[ i ].bAction != NULL && HB_IS_BLOCK( events->events[ i ].bAction ) )
                  hb_itemRelease( events->events[ i ].bAction );

            HB_ATOM_SET( &events->used, 0 );
         }

         if( ! HB_ATOM_GET( &events->used ) )
         {
            events = ( EVENTSHOLDER * ) RemoveProp( hWnd, pszProp );

            hb_xfree( events ); // delete events holder
         }

         return HB_TRUE;
      }
   }

   return HB_FALSE;
}

static LRESULT AppEventDo( EVENTSHOLDER * events, HB_BOOL bOnce, HWND hWnd, UINT message, WPARAM wParam, LPARAM lParam )
{
   size_t nPos = AppEventScan( events, message );

   if( ( nPos > 0 ) && events->active && ( events->events[ nPos - 1 ].active &&
                                           ( ( events->events[ nPos - 1 ].bAction != NULL ) && HB_IS_BLOCK( events->events[ nPos - 1 ].bAction ) ) ) )
   {
      PHB_ITEM phWnd    = hb_itemPutNInt( NULL, ( LONG_PTR ) hWnd );
      PHB_ITEM pmessage = hb_itemPutNS( NULL, message );
      PHB_ITEM pwParam  = hb_itemPutNInt( NULL, ( LONG_PTR ) wParam );
      PHB_ITEM plParam  = hb_itemPutNInt( NULL, ( LONG_PTR ) lParam );

      hb_evalBlock( events->events[ nPos - 1 ].bAction, phWnd, pmessage, pwParam, plParam, NULL );

      hb_itemRelease( phWnd );
      hb_itemRelease( pmessage );
      hb_itemRelease( pwParam );
      hb_itemRelease( plParam );

      if( HB_TRUE == bOnce )
         AppEventRemove( hWnd, "ONCE", message );

      return ( LRESULT ) hb_parnl( -1 );
   }

   return ( LRESULT ) 0;
}

static LRESULT AppEventOn( HWND hWnd, UINT message, WPARAM wParam, LPARAM lParam )
{
   LRESULT r = 0;

   if( IsWindow( hWnd ) )
   {
      EVENTSHOLDER * events = ( EVENTSHOLDER * ) GetProp( hWnd, "ONCE" );

      if( NULL != events )
      {
         if( hWnd == events->hwnd )
            r = AppEventDo( events, HB_TRUE, hWnd, message, wParam, lParam );
      }

      events = ( EVENTSHOLDER * ) GetProp( hWnd, "ON" );

      if( NULL != events )
      {
         if( hWnd == events->hwnd )
            r = AppEventDo( events, HB_FALSE, hWnd, message, wParam, lParam );
      }
   }

   return r;
}

HB_FUNC( APPEVENTS )
{
   BOOL bRes    = FALSE;
   HWND hWnd    = ( HWND ) ( LONG_PTR ) HB_PARNL( 1 );
   UINT message = ( UINT ) hb_parns( 2 );

   if( IsWindow( hWnd ) && ( message >= WM_APP && message <= ( WM_APP + MAX_EVENTS ) ) )
   {
      BOOL bInit = FALSE;
      const char *   pszProp = hb_parldef( 5, HB_TRUE ) ? "ONCE" : "ON";
      EVENTSHOLDER * events  = ( EVENTSHOLDER * ) GetProp( hWnd, pszProp );
      size_t         nPos;

      if( events == NULL )
      {
         events         = ( EVENTSHOLDER * ) hb_xgrabz( sizeof( EVENTSHOLDER ) );
         events->hwnd   = hWnd;
         events->active = hb_parldef( 4, HB_TRUE );
         events->count  = ( size_t ) sizeof( events->events ) / sizeof( APPEVENT );

         HB_ATOM_SET( &events->used, 0 );

         bInit = TRUE;
      }

      nPos = AppEventScan( events, message ); // arleady exists ?

      if( nPos > 0 )
         hb_itemRelease( events->events[ nPos - 1 ].bAction );
      else
      {
         nPos = bInit ? 1 : AppEventScan( events, 0 );
         if( nPos > 0 )
            HB_ATOM_INC( &events->used );
      }

      if( nPos > 0 )
      {
         events->events[ nPos - 1 ].message = message;
         events->events[ nPos - 1 ].bAction = hb_itemNew( hb_param( 3, HB_IT_BLOCK ) );
         events->events[ nPos - 1 ].active  = hb_parldef( 4, HB_TRUE );

         bRes = TRUE;
      }

      if( bInit )
         bRes = SetProp( hWnd, pszProp, ( HANDLE ) events ) ? HB_TRUE : HB_FALSE;
   }

   hb_retl( bRes ? HB_TRUE : HB_FALSE );
}

HB_FUNC( APPEVENTSREMOVE )
{
   HB_BOOL bDel    = HB_FALSE;
   HWND    hWnd    = ( HWND ) ( LONG_PTR ) HB_PARNL( 1 );
   UINT    message = ( UINT ) hb_parns( 2 );

   if( IsWindow( hWnd ) )
   {
      const char * pszProp = hb_parldef( 3, HB_TRUE ) ? "ONCE" : "ON";

      bDel = AppEventRemove( hWnd, pszProp, message );
   }

   hb_retl( bDel );
}

HB_FUNC( APPEVENTSUPDATE )
{
   HB_BOOL bUpd    = HB_FALSE;
   HWND    hWnd    = ( HWND ) ( LONG_PTR ) HB_PARNL( 1 );
   UINT    message = ( UINT ) hb_parns( 2 );

   if( IsWindow( hWnd ) )
   {
      const char *   pszProp = hb_parldef( 5, HB_TRUE ) ? "ONCE" : "ON";
      EVENTSHOLDER * events  = ( EVENTSHOLDER * ) GetProp( hWnd, pszProp );

      if( events != NULL )
      {
         if( message >= WM_APP && message <= ( WM_APP + MAX_EVENTS ) )
         {
            size_t nPos = AppEventScan( events, message ); // arleady exists ?

            if( nPos > 0 )
            {
               if( HB_IS_BLOCK( hb_param( 3, HB_IT_ANY ) ) )
               {
                  hb_itemRelease( events->events[ nPos - 1 ].bAction );
                  events->events[ nPos - 1 ].bAction = hb_itemNew( hb_param( 3, HB_IT_BLOCK ) );
               }

               events->events[ nPos - 1 ].active = hb_parldef( 4, HB_TRUE );

               bUpd = HB_TRUE;
            }
         }
         else if( message == 0 )
         {
            events->active = hb_parldef( 4, events->active );

            bUpd = HB_TRUE;
         }
      }
   }

   hb_retl( bUpd );
}

HB_FUNC( ENUMAPPEVENTS )
{
   HWND hWnd = ( HWND ) ( LONG_PTR ) HB_PARNL( 1 );
   const char * pszProp = hb_parldef( 2, HB_TRUE ) ? "ONCE" : "ON";
   PHB_ITEM     aEvents = hb_itemArrayNew( 0 );

   if( IsWindow( hWnd ) )
   {
      EVENTSHOLDER * events = ( EVENTSHOLDER * ) GetProp( hWnd, pszProp );

      if( events != NULL )
      {
         size_t i;

         for( i = 0; i < events->count; i++ )
         {
            PHB_ITEM aEvent = hb_itemArrayNew( 3 );

            hb_arraySetNInt( aEvent, 1, events->events[ i ].message );
            hb_arraySetL( aEvent, 2, events->events[ i ].active );

            if( events->events[ i ].bAction != NULL && HB_IS_BLOCK( events->events[ i ].bAction ) )
               hb_arraySet( aEvent, 3, hb_itemClone( events->events[ i ].bAction ) );
            else
               hb_arraySet( aEvent, 3, NULL );

            hb_arrayAddForward( aEvents, aEvent );

            hb_itemRelease( aEvent );
         }
      }
   }

   hb_itemReturnRelease( aEvents );
}

HB_FUNC( GETAPPEVENTSINFO )
{
   HWND hWnd = ( HWND ) ( LONG_PTR ) HB_PARNL( 1 );
   const char * pszProp = hb_parldef( 2, HB_TRUE ) ? "ONCE" : "ON";
   PHB_ITEM     aInfo;

   if( IsWindow( hWnd ) )
   {
      EVENTSHOLDER * events = ( EVENTSHOLDER * ) GetProp( hWnd, pszProp );

      aInfo = hb_itemArrayNew( ( events != NULL ) ? 4 : 0 );

      if( events != NULL )
      {
         hb_arraySetNInt( aInfo, 1, ( LONG_PTR ) events->hwnd );
         hb_arraySetNS( aInfo, 2, events->count );
         hb_arraySetNS( aInfo, 3, ( HB_ISIZ ) HB_ATOM_GET( &events->used ) );
         hb_arraySetL( aInfo, 4, events->active );
      }
   }
   else
      aInfo = hb_itemArrayNew( 0 );

   hb_itemReturnRelease( aInfo );
}

static size_t WinEventScan( WINEVENTSHOLDER * events, UINT message )
{
   size_t i, nPos = 0;

   for( i = 0; i < events->count; i++ )
   {
      if( message == events->events[ i ].message )
      {
         nPos = ( i + 1 ); break;
      }
   }

   return nPos;
}

static HB_BOOL WinEventRemove( HWND hWnd, const char * pszProp, UINT message )
{
   if( IsWindow( hWnd ) )
   {
      WINEVENTSHOLDER * events = ( WINEVENTSHOLDER * ) GetProp( hWnd, pszProp );

      if( events != NULL )
      {
         if( message != 0 )
         {
            size_t nPos = WinEventScan( events, message );

            if( nPos > 0 )                                           // if found
            {
               hb_itemRelease( events->events[ nPos - 1 ].bAction ); // delete old codeblock

               events->events[ nPos - 1 ].message = 0;
               events->events[ nPos - 1 ].bAction = NULL;
               events->events[ nPos - 1 ].active  = FALSE;

               HB_ATOM_DEC( &events->used );
            }
         }
         else
         {
            size_t i;

            for( i = 0; i < events->count; i++ ) // delete all not empty items with codeblocks
               if( events->events[ i ].bAction != NULL && HB_IS_BLOCK( events->events[ i ].bAction ) )
                  hb_itemRelease( events->events[ i ].bAction );

            HB_ATOM_SET( &events->used, 0 );
         }

         if( ! HB_ATOM_GET( &events->used ) )
         {
            events = ( WINEVENTSHOLDER * ) RemoveProp( hWnd, pszProp );

            hb_xfree( events ); // delete events holder
         }

         return HB_TRUE;
      }
   }

   return HB_FALSE;
}

static LRESULT WinEventDo( WINEVENTSHOLDER * events, HB_BOOL bOnce, HWND hWnd, UINT message, WPARAM wParam, LPARAM lParam )
{
   size_t nPos = WinEventScan( events, message );

   if( ( nPos > 0 ) && events->active && ( events->events[ nPos - 1 ].active &&
                                           ( ( events->events[ nPos - 1 ].bAction != NULL ) && HB_IS_BLOCK( events->events[ nPos - 1 ].bAction ) ) ) )
   {
      PHB_ITEM phWnd    = hb_itemPutNInt( NULL, ( LONG_PTR ) hWnd );
      PHB_ITEM pmessage = hb_itemPutNS( NULL, message );
      PHB_ITEM pwParam  = hb_itemPutNInt( NULL, ( LONG_PTR ) wParam );
      PHB_ITEM plParam  = hb_itemPutNInt( NULL, ( LONG_PTR ) lParam );

      hb_evalBlock( events->events[ nPos - 1 ].bAction, phWnd, pmessage, pwParam, plParam, NULL );

      hb_itemRelease( phWnd );
      hb_itemRelease( pmessage );
      hb_itemRelease( pwParam );
      hb_itemRelease( plParam );

      if( HB_TRUE == bOnce )
         WinEventRemove( hWnd, "ONCE", message );

      return ( LRESULT ) hb_parnl( -1 );
   }

   return ( LRESULT ) 0;
}

static LRESULT WinEventOn( HWND hWnd, UINT message, WPARAM wParam, LPARAM lParam )
{
   LRESULT r = 0;

   if( IsWindow( hWnd ) )
   {
      WINEVENTSHOLDER * events = ( WINEVENTSHOLDER * ) GetProp( hWnd, "ONCE" );

      if( NULL != events )
      {
         if( hWnd == events->hwnd )
            r = WinEventDo( events, HB_TRUE, hWnd, message, wParam, lParam );
      }

      events = ( WINEVENTSHOLDER * ) GetProp( hWnd, "ON" );

      if( NULL != events )
      {
         if( hWnd == events->hwnd )
            r = WinEventDo( events, HB_FALSE, hWnd, message, wParam, lParam );
      }
   }

   return r;
}

HB_FUNC( WINEVENTS )
{
   BOOL bRes    = FALSE;
   HWND hWnd    = ( HWND ) ( LONG_PTR ) HB_PARNL( 1 );
   UINT message = ( UINT ) hb_parns( 2 );

   if( IsWindow( hWnd ) && ( message <= ( WM_APP + MAX_EVENTS ) ) )
   {
      BOOL bInit = FALSE;
      const char *      pszProp = hb_parldef( 5, HB_TRUE ) ? "ONCE" : "ON";
      WINEVENTSHOLDER * events  = ( WINEVENTSHOLDER * ) GetProp( hWnd, pszProp );
      size_t nPos;

      if( events == NULL )
      {
         events         = ( WINEVENTSHOLDER * ) hb_xgrabz( sizeof( WINEVENTSHOLDER ) );
         events->hwnd   = hWnd;
         events->active = hb_parldef( 4, HB_TRUE );
         events->count  = ( size_t ) sizeof( events->events ) / sizeof( WINEVENT );

         HB_ATOM_SET( &events->used, 0 );

         bInit = TRUE;
      }

      nPos = WinEventScan( events, message ); // arleady exists ?

      if( nPos > 0 )
         hb_itemRelease( events->events[ nPos - 1 ].bAction );
      else
      {
         nPos = bInit ? 1 : WinEventScan( events, 0 );
         if( nPos > 0 )
            HB_ATOM_INC( &events->used );
      }

      if( nPos > 0 )
      {
         events->events[ nPos - 1 ].message = message;
         events->events[ nPos - 1 ].bAction = hb_itemNew( hb_param( 3, HB_IT_BLOCK ) );
         events->events[ nPos - 1 ].active  = hb_parldef( 4, HB_TRUE );

         bRes = TRUE;
      }

      if( bInit )
         bRes = SetProp( hWnd, pszProp, ( HANDLE ) events ) ? HB_TRUE : HB_FALSE;
   }

   hb_retl( bRes ? HB_TRUE : HB_FALSE );
}

HB_FUNC( WINEVENTSREMOVE )
{
   HB_BOOL bDel    = HB_FALSE;
   HWND    hWnd    = ( HWND ) ( LONG_PTR ) HB_PARNL( 1 );
   UINT    message = ( UINT ) hb_parns( 2 );

   if( IsWindow( hWnd ) )
   {
      const char * pszProp = hb_parldef( 3, HB_TRUE ) ? "ONCE" : "ON";

      bDel = WinEventRemove( hWnd, pszProp, message );
   }

   hb_retl( bDel );
}

HB_FUNC( WINEVENTSUPDATE )
{
   HB_BOOL bUpd    = HB_FALSE;
   HWND    hWnd    = ( HWND ) ( LONG_PTR ) HB_PARNL( 1 );
   UINT    message = ( UINT ) hb_parns( 2 );

   if( IsWindow( hWnd ) )
   {
      const char *      pszProp = hb_parldef( 5, HB_TRUE ) ? "ONCE" : "ON";
      WINEVENTSHOLDER * events  = ( WINEVENTSHOLDER * ) GetProp( hWnd, pszProp );

      if( events != NULL )
      {
         if( message <= ( WM_APP + MAX_EVENTS ) )
         {
            size_t nPos = WinEventScan( events, message ); // arleady exists ?

            if( nPos > 0 )
            {
               if( HB_IS_BLOCK( hb_param( 3, HB_IT_ANY ) ) )
               {
                  hb_itemRelease( events->events[ nPos - 1 ].bAction );
                  events->events[ nPos - 1 ].bAction = hb_itemNew( hb_param( 3, HB_IT_BLOCK ) );
               }

               events->events[ nPos - 1 ].active = hb_parldef( 4, HB_TRUE );

               bUpd = HB_TRUE;
            }
         }
         else if( message == 0 )
         {
            events->active = hb_parldef( 4, events->active );

            bUpd = HB_TRUE;
         }
      }
   }

   hb_retl( bUpd );
}

HB_FUNC( ENUMWINEVENTS )
{
   HWND hWnd = ( HWND ) ( LONG_PTR ) HB_PARNL( 1 );
   const char * pszProp = hb_parldef( 2, HB_TRUE ) ? "ONCE" : "ON";
   PHB_ITEM     aEvents = hb_itemArrayNew( 0 );

   if( IsWindow( hWnd ) )
   {
      WINEVENTSHOLDER * events = ( WINEVENTSHOLDER * ) GetProp( hWnd, pszProp );

      if( events != NULL )
      {
         size_t i;

         for( i = 0; i < events->count; i++ )
         {
            PHB_ITEM aEvent = hb_itemArrayNew( 3 );

            hb_arraySetNInt( aEvent, 1, events->events[ i ].message );
            hb_arraySetL( aEvent, 2, events->events[ i ].active );

            if( events->events[ i ].bAction != NULL && HB_IS_BLOCK( events->events[ i ].bAction ) )
               hb_arraySet( aEvent, 3, hb_itemClone( events->events[ i ].bAction ) );
            else
               hb_arraySet( aEvent, 3, NULL );

            hb_arrayAddForward( aEvents, aEvent );

            hb_itemRelease( aEvent );
         }
      }
   }

   hb_itemReturnRelease( aEvents );
}

HB_FUNC( GETWINEVENTSINFO )
{
   HWND hWnd = ( HWND ) ( LONG_PTR ) HB_PARNL( 1 );
   const char * pszProp = hb_parldef( 2, HB_TRUE ) ? "ONCE" : "ON";
   PHB_ITEM     aInfo;

   if( IsWindow( hWnd ) )
   {
      WINEVENTSHOLDER * events = ( WINEVENTSHOLDER * ) GetProp( hWnd, pszProp );

      aInfo = hb_itemArrayNew( ( events != NULL ) ? 4 : 0 );

      if( events != NULL )
      {
         hb_arraySetNInt( aInfo, 1, ( LONG_PTR ) events->hwnd );
         hb_arraySetNS( aInfo, 2, events->count );
         hb_arraySetNS( aInfo, 3, events->used );
         hb_arraySetL( aInfo, 4, events->active );
      }
   }
   else
      aInfo = hb_itemArrayNew( 0 );

   hb_itemReturnRelease( aInfo );
}

LRESULT CALLBACK MsgOnlyWndProc( HWND hWnd, UINT message, WPARAM wParam, LPARAM lParam )
{
   LONG_PTR lpUserData;
   LRESULT  result;

   if( message == WM_CREATE )
   {
      PMYUSERDATA pUserData = ( PMYUSERDATA ) ( ( ( LPCREATESTRUCT ) lParam )->lpCreateParams );

      if( pUserData )
      {
         SetLastError( 0 );

         SetWindowLongPtr( hWnd, GWLP_USERDATA, ( LONG_PTR ) pUserData );

         if( GetLastError() != 0 )
            return -1;
         else
            SetWindowPos( hWnd, 0, 0, 0, 0, 0, SWP_NOZORDER | SWP_NOMOVE | SWP_NOSIZE | SWP_NOACTIVATE );
      }
   }
   else if( message == WM_NCDESTROY )
   {
      lpUserData = SetWindowLongPtr( hWnd, GWLP_USERDATA, ( LONG_PTR ) 0 );

      if( lpUserData )
      {
         PMYUSERDATA pUserData = ( PMYUSERDATA ) lpUserData;

         if( pUserData->cbSize == sizeof( MYUSERDATA ) )
            hb_xfree( pUserData );
      }
   }
   else if( message == WM_DESTROY )
   {
      WinEventRemove( hWnd, "ONCE", 0 );
      WinEventRemove( hWnd, "ON", 0 );
   }

   result     = WinEventOn( hWnd, message, wParam, lParam );
   lpUserData = GetWindowLongPtr( hWnd, GWLP_USERDATA );

   if( lpUserData )
   {
      PMYUSERDATA pUserData     = ( PMYUSERDATA ) lpUserData;
      PHB_DYNS    pListenerDyns = pUserData->myParam.Listener;
      PHB_SYMB    pListenerSymb = hb_dynsymSymbol( pListenerDyns );

      if( pListenerSymb )
      {
         if( hb_vmRequestReenter() )
         {
            hb_vmPushSymbol( pListenerSymb );
            hb_vmPushNil();
            hb_vmPushNumInt( ( LONG_PTR ) hWnd );
            hb_vmPushLong( message );
            hb_vmPushNumInt( wParam );
            hb_vmPushNumInt( lParam );
            hb_vmDo( 4 );

            result = ( LRESULT ) hb_parnl( -1 );

            hb_vmRequestRestore();
         }
      }
   }

   return ( result != 0 ) ? result : DefWindowProc( hWnd, message, wParam, lParam );
}

HB_FUNC( INITMESSAGEONLYWINDOW )
{
   HWND hwnd = NULL;

#ifndef __XHARBOUR__
   void *  hClassName;
   LPCTSTR lpClassName = HB_PARSTR( 1, &hClassName, NULL );
#else
   const char * lpClassName = hb_parc( 1 );
#endif

   if( lpClassName )
   {
      WNDCLASSEX wcx = { 0 };

      wcx.cbSize        = sizeof( wcx );
      wcx.lpfnWndProc   = MsgOnlyWndProc;
      wcx.cbClsExtra    = 0;               // no extra class memory
      wcx.cbWndExtra    = 0;               // no extra window memory
      wcx.hInstance     = g_hInstance;
      wcx.lpszClassName = lpClassName;

      if( RegisterClassEx( &wcx ) )
      {
         const char * pszFuncName = hb_parc( 2 );

         if( pszFuncName && hb_dynsymIsFunction( hb_dynsymGet( pszFuncName ) ) )
         {
            PMYUSERDATA pUserData = ( PMYUSERDATA ) hb_xgrabz( sizeof( MYUSERDATA ) );

            pUserData->cbSize = sizeof( MYUSERDATA );
            pUserData->myParam.Listener = hb_dynsymGet( pszFuncName );

            hwnd = CreateWindowEx( 0, lpClassName, 0, 0, 0, 0, 0, 0, HWND_MESSAGE, 0, g_hInstance, ( LPVOID ) pUserData );
         }
         else
            hwnd = CreateWindowEx( 0, lpClassName, 0, 0, 0, 0, 0, 0, HWND_MESSAGE, 0, g_hInstance, 0 );
      }
      else
         hmg_ErrorExit( TEXT( "Window Registration Failed!" ), 0, TRUE );
   }

#ifndef __XHARBOUR__
   hb_strfree( hClassName );
#endif
   HB_RETNL( ( LONG_PTR ) hwnd );
}

/* Modified by P.Ch. 17.06. */
HB_FUNC( INITDUMMY )
{
   HB_RETNL( ( LONG_PTR ) CreateWindowEx( 0, WC_STATIC, "", WS_CHILD, 0, 0, 0, 0, ( HWND ) ( LONG_PTR ) HB_PARNL( 1 ), ( HMENU ) 0, g_hInstance, NULL ) );
}

/* Modified by P.Ch. 17.06. */
LRESULT CALLBACK WndProc( HWND hWnd, UINT message, WPARAM wParam, LPARAM lParam )
{
   LRESULT  r = 0;
   PHB_SYMB g_ListenerSymb = hb_dynsymSymbol( g_ListenerDyns );

   if( message == WM_DESTROY )
   {
      AppEventRemove( hWnd, "ONCE", 0 );
      AppEventRemove( hWnd, "ON", 0 );

      if( IsWindow( g_hWndMain ) && hWnd == g_hWndMain && g_hAccel != NULL )
      {
         if( DestroyAcceleratorTable( g_hAccel ) )
            g_hAccel = NULL;
      }
   }

   if( message >= WM_APP && message <= ( WM_APP + MAX_EVENTS ) )
      r = AppEventOn( hWnd, message, wParam, lParam );
   else if( g_ListenerSymb )
   {
#ifndef __XHARBOUR__
      if( hb_vmRequestReenter() )
      {
#endif
      hb_vmPushSymbol( g_ListenerSymb );
      hb_vmPushNil();
      hb_vmPushNumInt( ( LONG_PTR ) hWnd );
      hb_vmPushLong( message );
      hb_vmPushNumInt( wParam );
      hb_vmPushNumInt( lParam );
      hb_vmDo( 4 );

      r = ( LRESULT ) hb_parnl( -1 );
#ifndef __XHARBOUR__
      hb_vmRequestRestore();
   }
#endif
   }

   return ( r != 0 ) ? r : DefWindowProc( hWnd, message, wParam, lParam );
}

HB_FUNC( INITWINDOW )
{
   HWND hwnd;
   int Style = WS_POPUP, ExStyle;

   if( hb_parl( 16 ) )
      ExStyle = WS_EX_CONTEXTHELP;
   else
   {
      ExStyle = 0;
      if( ! hb_parl( 6 ) )
         Style = Style | WS_MINIMIZEBOX;

      if( ! hb_parl( 7 ) )
         Style = Style | WS_MAXIMIZEBOX;
   }

   if( ! hb_parl( 8 ) )
      Style = Style | WS_SIZEBOX;

   if( ! hb_parl( 9 ) )
      Style = Style | WS_SYSMENU;

   if( ! hb_parl( 10 ) )
      Style = Style | WS_CAPTION;

   if( hb_parl( 11 ) )
      ExStyle = ExStyle | WS_EX_TOPMOST;

   if( hb_parl( 14 ) )
      Style = Style | WS_VSCROLL;

   if( hb_parl( 15 ) )
      Style = Style | WS_HSCROLL;

   if( hb_parl( 17 ) )
      ExStyle = ExStyle | WS_EX_PALETTEWINDOW;

   if( hb_parl( 18 ) ) // Panel
   {
      Style   = WS_CHILD;
      ExStyle = ExStyle | WS_EX_CONTROLPARENT | WS_EX_STATICEDGE;
   }

   hwnd = CreateWindowEx
          (
      ExStyle,
      hb_parc( 12 ),
      hb_parc( 1 ),
      Style,
      hb_parni( 2 ),
      hb_parni( 3 ),
      hb_parni( 4 ),
      hb_parni( 5 ),
      ( HWND ) ( LONG_PTR ) HB_PARNL( 13 ),
      ( HMENU ) NULL,
      g_hInstance,
      NULL
          );

   if( NULL != hwnd )
      HB_RETNL( ( LONG_PTR ) hwnd );
   else
      MessageBox( 0, "Window Creation Failed!", "Error!", MB_ICONEXCLAMATION | MB_OK | MB_SYSTEMMODAL );
}

HB_FUNC( INITMODALWINDOW )
{
   HWND parent;
   HWND hwnd;
   int Style;
   int ExStyle = 0;

   if( hb_parl( 13 ) )
      ExStyle = WS_EX_CONTEXTHELP;

   parent = ( HWND ) ( LONG_PTR ) HB_PARNL( 6 );

   Style = WS_POPUP;

   if( ! hb_parl( 7 ) )
      Style = Style | WS_SIZEBOX;

   if( ! hb_parl( 8 ) )
      Style = Style | WS_SYSMENU;

   if( ! hb_parl( 9 ) )
      Style = Style | WS_CAPTION;

   if( hb_parl( 11 ) )
      Style = Style | WS_VSCROLL;

   if( hb_parl( 12 ) )
      Style = Style | WS_HSCROLL;

   hwnd = CreateWindowEx
          (
      ExStyle,
      hb_parc( 10 ),
      hb_parc( 1 ),
      Style,
      hb_parni( 2 ),
      hb_parni( 3 ),
      hb_parni( 4 ),
      hb_parni( 5 ),
      parent,
      ( HMENU ) NULL,
      g_hInstance,
      NULL
          );

   if( NULL != hwnd )
      HB_RETNL( ( LONG_PTR ) hwnd );
   else
      MessageBox( 0, "Window Creation Failed!", "Error!", MB_ICONEXCLAMATION | MB_OK | MB_SYSTEMMODAL );
}

HB_FUNC( INITSPLITCHILDWINDOW )
{
   HWND hwnd;
   int Style;

   Style = WS_POPUP;

   if( ! hb_parl( 4 ) )
      Style = Style | WS_CAPTION;

   if( hb_parl( 7 ) )
      Style = Style | WS_VSCROLL;

   if( hb_parl( 8 ) )
      Style = Style | WS_HSCROLL;

   hwnd = CreateWindowEx
          (
      WS_EX_STATICEDGE | WS_EX_TOOLWINDOW,
      hb_parc( 3 ),
      hb_parc( 5 ),
      Style,
      0,
      0,
      hb_parni( 1 ),
      hb_parni( 2 ),
      0,
      ( HMENU ) NULL,
      g_hInstance,
      NULL
          );

   if( NULL != hwnd )
      HB_RETNL( ( LONG_PTR ) hwnd );
   else
      MessageBox( 0, "Window Creation Failed!", "Error!", MB_ICONEXCLAMATION | MB_OK | MB_SYSTEMMODAL );
}

HB_FUNC( INITSPLITBOX )
{
   HWND hwndOwner = ( HWND ) ( LONG_PTR ) HB_PARNL( 1 );
   REBARINFO rbi;
   HWND hwndRB;
   INITCOMMONCONTROLSEX icex;

   int Style = WS_CHILD | WS_VISIBLE | WS_CLIPSIBLINGS | WS_CLIPCHILDREN | RBS_BANDBORDERS | RBS_VARHEIGHT | RBS_FIXEDORDER;

   if( hb_parl( 2 ) )
      Style = Style | CCS_BOTTOM;

   if( hb_parl( 3 ) )
      Style = Style | CCS_VERT;

   icex.dwSize = sizeof( INITCOMMONCONTROLSEX );
   icex.dwICC  = ICC_COOL_CLASSES | ICC_BAR_CLASSES;
   InitCommonControlsEx( &icex );

   hwndRB = CreateWindowEx
            (
      WS_EX_TOOLWINDOW | WS_EX_DLGMODALFRAME,
      REBARCLASSNAME,
      NULL,
      Style,
      0,
      0,
      0,
      0,
      hwndOwner,
      NULL,
      g_hInstance,
      NULL
            );

   // Initialize and send the REBARINFO structure.
   rbi.cbSize = sizeof( REBARINFO );   // Required when using this struct.
   rbi.fMask  = 0;
   rbi.himl   = ( HIMAGELIST ) NULL;
   SendMessage( hwndRB, RB_SETBARINFO, 0, ( LPARAM ) &rbi );

   HB_RETNL( ( LONG_PTR ) hwndRB );
}

/* Modified by P.Ch. 16.10.-16.12.,17.06. */
HB_FUNC( REGISTERWINDOW )
{
   WNDCLASS WndClass;
   HBRUSH hBrush = 0;
   HICON hIcon;
   HCURSOR hCursor;
   LPCTSTR lpIconName = HB_ISCHAR( 1 ) ? hb_parc( 1 ) : ( HB_ISNUM( 1 ) ? MAKEINTRESOURCE( ( WORD ) hb_parnl( 1 ) ) : NULL );

#ifndef __XHARBOUR__
   void *  hClassName;
   LPCTSTR lpClassName = HB_PARSTR( 2, &hClassName, NULL );
#else
   const char * lpClassName = hb_parc( 2 );
#endif
   LPCSTR lpCursorName = HB_ISCHAR( 4 ) ? hb_parc( 4 ) : ( HB_ISNUM( 4 ) ? MAKEINTRESOURCE( ( WORD ) hb_parnl( 4 ) ) : NULL );

   WndClass.style       = CS_DBLCLKS | /*CS_HREDRAW | CS_VREDRAW |*/ CS_OWNDC;
   WndClass.lpfnWndProc = WndProc;
   WndClass.cbClsExtra  = 0;
   WndClass.cbWndExtra  = 0;
   WndClass.hInstance   = g_hInstance;

   // icon from resource
   hIcon = LoadIcon( g_hInstance, lpIconName );
   // from file
   if( NULL == hIcon && HB_ISCHAR( 1 ) )
      hIcon = ( HICON ) LoadImage( NULL, lpIconName, IMAGE_ICON, 0, 0, LR_LOADFROMFILE + LR_DEFAULTSIZE );
   WndClass.hIcon = ( ( NULL != hIcon ) ? hIcon : LoadIcon( NULL, IDI_APPLICATION ) );

   // cursor from resource
   hCursor = LoadCursor( g_hInstance, lpCursorName );
   // from file
   if( ( NULL == hCursor ) && HB_ISCHAR( 4 ) )
      hCursor = LoadCursorFromFile( lpCursorName );
   WndClass.hCursor = ( ( NULL != hCursor ) ? hCursor : LoadCursor( NULL, IDC_ARROW ) );

   if( HB_ISARRAY( 3 ) )  // old behavior (before 16.10.)
   {
      if( HB_PARNI( 3, 1 ) == -1 )
         hBrush = ( HBRUSH ) ( COLOR_BTNFACE + 1 );
      else
         hBrush = CreateSolidBrush( RGB( HB_PARNI( 3, 1 ), HB_PARNI( 3, 2 ), HB_PARNI( 3, 3 ) ) );
   }
   else if( HB_ISCHAR( 3 ) || HB_ISNUM( 3 ) )
   {
      HBITMAP hImage;
      LPCTSTR lpImageName = HB_ISCHAR( 3 ) ? hb_parc( 3 ) : ( HB_ISNUM( 3 ) ? MAKEINTRESOURCE( ( WORD ) hb_parnl( 3 ) ) : NULL );

      hImage = ( HBITMAP ) LoadImage( g_hInstance, lpImageName, IMAGE_BITMAP, 0, 0, LR_LOADMAP3DCOLORS | LR_LOADTRANSPARENT );

      if( hImage == NULL && HB_ISCHAR( 3 ) )
         hImage = ( HBITMAP ) LoadImage( NULL, lpImageName, IMAGE_BITMAP, 0, 0, LR_LOADFROMFILE | LR_LOADMAP3DCOLORS | LR_LOADTRANSPARENT );

      if( hImage == NULL )
         hImage = ( HBITMAP ) HMG_LoadImage( hb_parc( 3 ) );

      if( hImage != NULL )
         hBrush = CreatePatternBrush( hImage );
   }

   WndClass.hbrBackground = ( NULL != hBrush ) ? hBrush : ( hBrush = ( HBRUSH ) ( COLOR_BTNFACE + 1 ) );
   WndClass.lpszMenuName  = NULL;
   WndClass.lpszClassName = lpClassName;

   if( ! RegisterClass( &WndClass ) )
      hmg_ErrorExit( TEXT( "Window Registration Failed!" ), 0, TRUE );

#ifndef __XHARBOUR__
   hb_strfree( hClassName );
#endif
   HB_RETNL( ( LONG_PTR ) hBrush );
}

/* Modified by P.Ch. 17.06. */
HB_FUNC( REGISTERSPLITCHILDWINDOW )
{
   WNDCLASS WndClass;
   HBRUSH hbrush  = 0;
   LPCTSTR lpIcon = HB_ISCHAR( 1 ) ? hb_parc( 1 ) : ( HB_ISNIL( 1 ) ? NULL : MAKEINTRESOURCE( ( WORD ) hb_parnl( 1 ) ) );

#ifndef __XHARBOUR__
   void *  hClassName;
   LPCTSTR lpClassName = HB_PARSTR( 2, &hClassName, NULL );
#else
   const char * lpClassName = hb_parc( 2 );
#endif

   WndClass.style       = CS_OWNDC;
   WndClass.lpfnWndProc = WndProc;
   WndClass.cbClsExtra  = 0;
   WndClass.cbWndExtra  = 0;
   WndClass.hInstance   = g_hInstance;
   WndClass.hIcon       = LoadIcon( g_hInstance, lpIcon );
   if( WndClass.hIcon == NULL )
      WndClass.hIcon = ( HICON ) LoadImage( 0, lpIcon, IMAGE_ICON, 0, 0, LR_LOADFROMFILE + LR_DEFAULTSIZE );

   if( WndClass.hIcon == NULL )
      WndClass.hIcon = LoadIcon( NULL, IDI_APPLICATION );

   WndClass.hCursor = LoadCursor( NULL, IDC_ARROW );

   if( HB_PARNI( 3, 1 ) == -1 )
      WndClass.hbrBackground = ( HBRUSH ) ( COLOR_BTNFACE + 1 );
   else
   {
      hbrush = CreateSolidBrush( RGB( HB_PARNI( 3, 1 ), HB_PARNI( 3, 2 ), HB_PARNI( 3, 3 ) ) );
      WndClass.hbrBackground = hbrush;
   }

   WndClass.lpszMenuName  = NULL;
   WndClass.lpszClassName = lpClassName;

   if( ! RegisterClass( &WndClass ) )
      hmg_ErrorExit( TEXT( "Window Registration Failed!" ), 0, TRUE );

#ifndef __XHARBOUR__
   hb_strfree( hClassName );
#endif
   HB_RETNL( ( LONG_PTR ) hbrush );
}

/* Modified by P.Ch. 17.06. */
HB_FUNC( UNREGISTERWINDOW )
{
#ifndef __XHARBOUR__
   void *  hClassName;
   LPCTSTR lpClassName = HB_PARSTR( 1, &hClassName, NULL );
#else
   const char * lpClassName = hb_parc( 1 );
#endif

   UnregisterClass( lpClassName, g_hInstance );
#ifndef __XHARBOUR__
   hb_strfree( hClassName );
#endif
}

HB_FUNC( MSC_VER )
{
#if defined( _MSC_VER ) && ! defined( __POCC__ )
   hb_retnl( _MSC_VER );
#else
   hb_retnl( 0 );
#endif
}
