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
   LOCAL bEvent := {|h,m| HB_SYMBOL_UNUSED(h), MsgInfo('Got It!'), 1}

   MESSAGEONLY myWnd TO hwnd
   ON WINEVENT ev_Fire1 ACTION bEvent OF hwnd

   DEFINE WINDOW Win_1 ;
      CLIENTAREA 400, 400 ;
      TITLE 'WndEvents(HWND_MESSAGE) Demo-2' ;
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
