/*
 * Harbour MiniGUI Message-Only Window Demo
 * (c) 2017 P.Ch.
*/

#include "minigui.ch" 
#include "i_winuser.ch" 

/////////////////////////////////////////////////////////////////////////// 
#define ev_Fire1     (WM_USER + 100) 

///////////////////////////////////////////////////////////////////////////
FUNCTION Main( ... )

   LOCAL hwnd

   // DEFINE WINDOW MESSAGEONLY myWnd EVENTS FUNC myWndEvents RESULT TO hwnd
   MESSAGEONLY myWnd EVENTS myWndEvents TO hwnd

   IF Empty( hwnd ) ; MsgInfo( "Oops!" )
      QUIT
   ENDIF

   DEFINE WINDOW Win_1 ;
      CLIENTAREA 400, 400 ;
      TITLE 'WndEvents(HWND_MESSAGE) Demo' ;
      MAIN ;
      ON RELEASE DestroyWindow( hwnd )

      DEFINE BUTTONEX FireButton1
          ROW      290
          COL      50
          CAPTION  "Fire 1"
          ACTION   EMIT ev_Fire1 OF hwnd
          WIDTH    140
          HEIGHT   40
      END BUTTONEX

   END WINDOW

   Win_1.Center
   Win_1.Activate
  
RETURN 0

///////////////////////////////////////////////////////////////////////////
FUNCTION MyWndEvents( hWnd, message, wParam, lParam )

   LOCAL result := 0

   HB_SYMBOL_UNUSED( hWnd )

   IF message == WM_CREATE
      MsgInfo( 'Got It!' )

   ELSEIF message == ev_Fire1
      MsgInfo( 'Got It Again!' )

      result := 1
   ENDIF

RETURN result
