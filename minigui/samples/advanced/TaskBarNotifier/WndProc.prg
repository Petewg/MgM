/*
 * WNDPROC for Harbour TTaskbarNotifier Class 
 * Copyright 2007 P.Chornyj <myorg63@mail.ru>
 *
 * Last revision 19.09.2007
 *
*/

#include "taskbarnotifier.ch"

ANNOUNCE CLASS_TTASKBARNOTIFIER_WP

/*
 (WNDPROC) _OnTaskbarNotifierEvents  
*/

#define WM_USER       1024
#define WM_PAINT      15
#define WM_MOUSEFIRST 512
#define WM_MOUSEMOVE  512
#define WM_LBUTTONDBLCLK  515
#define WM_MOUSEHOVER 673
#define WM_MOUSEENTER WM_USER + 3
#define WM_MOUSELEAVE 675

FUNCTION _OnTaskbarNotifierEvents( hWnd, Msg, nwParam, nlParam )
LOCAL TN := TTaskbarNotifier():GetById( hWnd )
LOCAL nResult := 0

IF ( Hb_IsObject( TN ) )

   SWITCH Msg
   CASE WM_PAINT
         TN:OnPaint()
         nResult := 0
         EXIT

   CASE WM_MOUSEENTER
         TN:OnMouseEnter( nwParam, nlParam )
         nResult := 1
         EXIT

   CASE WM_MOUSEMOVE
   CASE WM_MOUSEHOVER
         TN:OnMouseMove( nwParam, nlParam )
         nResult := 1
         EXIT

   CASE WM_MOUSELEAVE
         TN:OnMouseLeave( nwParam, nlParam )
         nResult := 1
         EXIT

   CASE WM_LBUTTONDBLCLK
         TN:OnMouseDblClick( nwParam, nlParam )
         nResult := 1
         EXIT

   END SWITCH

ENDIF

RETURN ( nResult )

#pragma BEGINDUMP

#include "windows.h"
#include "hbapi.h"
#include "hbvm.h"
#include "hbstack.h"
#include "hbapiitm.h"
#include "item.api"

#define TID_POLLMOUSE    100
#define MOUSE_POLL_DELAY 100
#define WM_MOUSEENTER WM_USER + 3

static PHB_SYMB pSymbolEvents = NULL;
LRESULT CALLBACK TTaskbarNotifierWndProc( HWND, UINT, WPARAM, LPARAM );

/*
*/
HB_FUNC ( REGISTERTASKBARNOTIFIERWINDOW )
{
   WNDCLASS WndClass;

   WndClass.style         = CS_OWNDC | CS_DBLCLKS;
   WndClass.lpfnWndProc   = TTaskbarNotifierWndProc;
   WndClass.cbClsExtra    = 0;
   WndClass.cbWndExtra    = 0;
   WndClass.hInstance     = GetModuleHandle( NULL );
   WndClass.hIcon         = LoadIcon(NULL, IDI_APPLICATION);
   WndClass.hCursor       = LoadCursor(NULL, IDC_HAND);
   WndClass.hbrBackground = (HBRUSH)( 0 /*COLOR_BTNFACE + 1*/ );
   WndClass.lpszMenuName  = NULL;
   WndClass.lpszClassName = hb_parc(1);

   if( !RegisterClass( &WndClass ) )
   {
      hb_retl( FALSE );
   }
   else
   {
      hb_retl( TRUE );
   }
}

/*
*/
LRESULT CALLBACK TTaskbarNotifierWndProc( HWND hWnd, UINT message, WPARAM wParam, LPARAM lParam )
{
   long int lRes = 0;

   switch( message )
   {
      RECT rc;
      POINT pt;

      case WM_MOUSEMOVE:

      GetWindowRect( hWnd, &rc );
      GetCursorPos( &pt );

      if( PtInRect( &rc, pt ) )
      {
         SetTimer( hWnd, TID_POLLMOUSE, MOUSE_POLL_DELAY, NULL);
         if( GetCapture() != hWnd )
         {
                 SetCapture( hWnd );
                 SendMessage( hWnd, WM_MOUSEENTER, 0, 0L );
         }
         break;
      }
      ReleaseCapture();
      KillTimer( hWnd, TID_POLLMOUSE );
      PostMessage( hWnd, WM_MOUSELEAVE, 0, 0L );
      break;

      case WM_TIMER:
      if ( wParam != TID_POLLMOUSE )
         break;

      GetWindowRect( hWnd, &rc );
      GetCursorPos( &pt );
      if( PtInRect( &rc,pt ) )
      {
         SendMessage( hWnd, WM_MOUSEHOVER, 0, 0L );
         break;
      }
      ReleaseCapture();
      KillTimer( hWnd, TID_POLLMOUSE );
      PostMessage( hWnd, WM_MOUSELEAVE, 0, 0L );
      break;
   }

   if ( ! pSymbolEvents )
      pSymbolEvents = hb_dynsymSymbol( hb_dynsymGet( "_ONTASKBARNOTIFIEREVENTS" ));

   if ( pSymbolEvents )
   {
      hb_vmPushSymbol( pSymbolEvents );
      hb_vmPushNil();
      hb_vmPushLong( ( LONG ) hWnd );
      hb_vmPushLong( message );
      hb_vmPushLong( wParam );
      hb_vmPushLong( lParam );
      hb_vmDo( 4 );

      lRes = hb_parnl( -1 );
   }
   
   if ( lRes != 0 )
   {
           return lRes;
   }
   else
   {
           return( DefWindowProc( hWnd, message, wParam, lParam ));
   }
}

#pragma ENDDUMP
