/*
 * Harbour MiniGUI AppEvents Demo
 * (c) 2017 P.Ch.
*/

#include "minigui.ch"

//////////////////////////////////////////////////////////////////////////////
#define WM_APP       0x8000
#define ev_Fire1     (WM_APP + 1)
#define ev_Fire2     (WM_APP + 2)
#define ev_Fire3     (WM_APP + 3)
#define ev_FireOnce  (WM_APP + 10)

//////////////////////////////////////////////////////////////////////////////
FUNCTION Main()

   LOCAL bEvent1 := {|h,m| HB_SYMBOL_UNUSED(h), MsgInfo('ID:'+hb_NtoS(m), 'Event fired:[1]')}
   LOCAL bEvent2 := {|h,m| HB_SYMBOL_UNUSED(h), MsgInfo('ID:'+hb_NtoS(m), 'Event fired:[2]')}
   LOCAL bEvent3 := {|h,m| HB_SYMBOL_UNUSED(h), MsgInfo('ID:'+hb_NtoS(m), 'Event fired:[3]')}
   LOCAL bEvent4 := {|h,m| HB_SYMBOL_UNUSED(h), MsgInfo('ID:'+hb_NtoS(m), 'Event fired:[4]')}
   LOCAL bEvent0 := {|h,m| HB_SYMBOL_UNUSED(h), MsgInfo('ID:'+hb_NtoS(m), 'Event fired:[0]')}

   DEFINE WINDOW WinMain ;
      CLIENTAREA 600, 400 ;
      TITLE 'AppEvents Demo' ;
      MAIN 

      ON APPEVENT ev_Fire1 ACTION bEvent1 OF ThisWindow.Handle
      ON APPEVENT ev_Fire2 ACTION bEvent2 OF ThisWindow.Handle
      ON APPEVENT ev_Fire3 ACTION bEvent3 OF ThisWindow.Handle

      // change action of event ev_Fire3 to codeblock bEvent4
      UPDATE APPEVENT ev_Fire3 OF ThisWindow.Handle NOACTIVE
      UPDATE APPEVENT ev_Fire3 ACTION bEvent4 OF ThisWindow.Handle 

      ON APPEVENT ev_FireOnce ACTION bEvent0 OF ThisWindow.Handle ONCE
      // REMOVE APPEVENT ALL OF ThisWindow.Handle ONCE

      DEFINE BUTTONEX FireButton1
         ROW      290
         COL      50
         CAPTION  "Fire 1"
         ACTION   EMIT ev_Fire1 OF WinMain.Handle
         WIDTH    140
         HEIGHT   40
      END BUTTONEX

      DEFINE BUTTONEX FireButton2
         ROW      340
         COL      50
         CAPTION  "Fire 2"
         ACTION   EMIT ev_Fire2 OF WinMain.Handle
         WIDTH    140
         HEIGHT   40
      END BUTTONEX

      DEFINE BUTTONEX FireButton3
         ROW      290
         COL      200
         CAPTION  "Fire 3"
         ACTION   EMIT ev_Fire3 OF WinMain.Handle
         WIDTH    140
         HEIGHT   40
      END BUTTONEX

      DEFINE BUTTONEX FireButton4
         ROW      340
         COL      200
         CAPTION  "Fire Once"
         ACTION   EMIT ev_FireOnce OF WinMain.Handle
         WIDTH    140
         HEIGHT   40
      END BUTTONEX

      DEFINE BUTTONEX FireButton5
         ROW      290
         COL      400
         CAPTION  "About On"
         ACTION   GetInfo( WinMain.Handle, .F. )
         WIDTH    140
         HEIGHT   40
      END BUTTONEX

      DEFINE BUTTONEX FireButton6
         ROW      340
         COL      400
         CAPTION  "About Once"
         ACTION   GetInfo( WinMain.Handle, .T. )
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

   MsgInfo( cMsgs, iif( lOnce, "Once", "On" ) )

RETURN
