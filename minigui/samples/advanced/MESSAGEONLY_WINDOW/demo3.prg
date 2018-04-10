
#include "minigui.ch"
#include "i_winuser.ch"

///////////////////////////////////////////////////////////////////////////
#define WM_APP       0x8000

#define ev_Fire1     (WM_USER + 100)
#define ev_Fire2     (WM_APP + 1)
#define ev_Fire3     (WM_APP + 2)
#define ev_FireOnce  (WM_APP + 64)

///////////////////////////////////////////////////////////////////////////
FUNCTION Main(...)

   LOCAL hwnd 

   LOCAL bEvent1 := {|h,m| HB_SYMBOL_UNUSED(h), MsgInfo('ID:'+hb_NtoS(m), 'Event fired:[1]')}
   LOCAL bEvent2 := {|h,m| HB_SYMBOL_UNUSED(h), MsgInfo('ID:'+hb_NtoS(m), 'Event fired:[2]')}
   LOCAL bEvent3 := {|h,m| HB_SYMBOL_UNUSED(h), MsgInfo('ID:'+hb_NtoS(m), 'Event fired:[3]')}
   LOCAL bEvent4 := {|h,m| HB_SYMBOL_UNUSED(h), MsgInfo('ID:'+hb_NtoS(m), 'Event fired:[4]')}
   LOCAL bEvent0 := {|h,m| HB_SYMBOL_UNUSED(h), MsgInfo('ID:'+hb_NtoS(m), 'Event fired:[0]')}

   // DEFINE WINDOW MESSAGEONLY myWnd EVENTS FUNC myWndEvents RESULT TO hwnd
   MESSAGEONLY myWnd EVENTS myWndEvents TO hwnd

   IF Empty( hwnd ) ; MsgInfo( "Oops!")
      QUIT
   ENDIF

   ON WINEVENT ev_Fire1 ACTION bEvent1 OF hwnd
   ON WINEVENT ev_Fire2 ACTION bEvent2 OF hwnd
   ON WINEVENT ev_Fire3 ACTION bEvent3 OF hwnd

   UPDATE WINEVENT ev_Fire3 OF hwnd NOACTIVE
   UPDATE WINEVENT ev_Fire3 ACTION bEvent4 OF hwnd

   ON WINEVENT ev_FireOnce ACTION bEvent0 OF hwnd ONCE
   // REMOVE WINEVENT ALL OF ThisWindow.Handle ONCE

   DEFINE WINDOW WinMain ;
      CLIENTAREA 600, 400 ;
      TITLE 'WndEvents(HWND_MESSAGE) Demo-3' ;
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

      DEFINE BUTTONEX FireButton2
         ROW      340
         COL      50
         CAPTION  "Fire 2"
         ACTION   EMIT ev_Fire2 OF hwnd
         WIDTH    140
         HEIGHT   40
      END BUTTONEX

      DEFINE BUTTONEX FireButton3
         ROW      290
         COL      200
         CAPTION  "Fire 3"
         ACTION   EMIT ev_Fire3 OF hwnd
         WIDTH    140
         HEIGHT   40
      END BUTTONEX

      DEFINE BUTTONEX FireButton4
         ROW      340
         COL      200
         CAPTION  "Fire Once"
         ACTION   EMIT ev_FireOnce OF hwnd
         WIDTH    140
         HEIGHT   40
      END BUTTONEX

      DEFINE BUTTONEX FireButton5
         ROW      290
         COL      400
         CAPTION  "About On"
         ACTION   GetInfo( hwnd, .F. )
         WIDTH    140
         HEIGHT   40
      END BUTTONEX

      DEFINE BUTTONEX FireButton6
         ROW      340
         COL      400
         CAPTION  "About Once"
         ACTION   GetInfo( hwnd, .T. )
         WIDTH    140
         HEIGHT   40
      END BUTTONEX

   END WINDOW

   WinMain.Center
   WinMain.Activate

RETURN 0

//////////////////////////////////////////////////////////////////////////////
STATIC PROCEDURE GetInfo( hwnd, lOnce )

   LOCAL aInfo := GetAppEventsInfo( hwnd,lOnce )
   LOCAL cMsgs

   IF ! Empty( aInfo )   
#ifndef __XHARBOUR__
      cMsgs := hb_strFormat ;
      ( ;
         e"Holder:\t\t%d\nCount of events:\t%d\nUsed events:\t%d\nStatus:\t\t%s", ;
         aInfo[1], aInfo[2], aInfo[3], Iif( aInfo[4], "active", "not active" ) ;
      )
#else
      cMsgs := "" // FIXME
#endif
   ELSE
      cMsgs := "Not Installed."
   ENDIF

   MsgInfo( cMsgs, If( lOnce, "Once", "On" ) )

RETURN

///////////////////////////////////////////////////////////////////////////
FUNCTION MyWndEvents( hWnd, message, ... )

   LOCAL result := 0

   IF message == WM_CREATE
      MsgInfo( 'Got It!' )
   ELSEIF message == ev_Fire1
      MsgInfo( 'Got It Again!' )

      result := 1
   ENDIF

RETURN result
