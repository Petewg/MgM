/*
 * MINIGUI - Harbour Win32 GUI library Demo
 *
 * Copyright 2002-2010 Roberto Lopez <harbourminigui@gmail.com>
 * http://harbourminigui.googlepages.com/
 *
 * Copyright 2005-2017 Grigory Filatov <gfilatov@inbox.ru>
*/

ANNOUNCE RDDSYS

#include "minigui.ch"

#define PROGRAM 'Clipbrd Clear'
#define VERSION ' version 1.2'
#define COPYRIGHT ' Grigory Filatov, 2005-2017'

#define MsgAlert( c ) MsgExclamation( c, "Error" )

#define CF_TEXT     1
#define CF_BITMAP   2
#define CF_MAXCOUNT 14

STATIC lClipbrdFull := .F.

*--------------------------------------------------------*
PROCEDURE Main( ... )
*--------------------------------------------------------*
   LOCAL aPar, i, lClear := .F. , lExit := .F.

   SET MULTIPLE OFF WARNING

   IF PCount() > 0

      aPar := hb_AParams()

      FOR i := 1 TO Len( aPar )
         IF ValType( aPar[i] ) == "C"
            IF Upper( aPar[i] ) == "/CLEAR"
               lClear := .T.
               EXIT
            ENDIF
         ENDIF
      NEXT

      IF lClear
         FOR i := 1 TO Len( aPar )
            IF ValType( aPar[i] ) == "C"
               IF Upper( aPar[i] ) == "/EXIT"
                  lExit := .T.
                  EXIT
               ENDIF
            ENDIF
         NEXT
      ENDIF

   ENDIF

   lClipbrdFull := IsClipbrdFull()

   IF lClear
      ClipClear()
      PlayOK()
   ENDIF

   IF ! lExit

      DEFINE WINDOW Form_1 ;
         AT 0, 0 ;
         WIDTH 0 HEIGHT 0 ;
         TITLE PROGRAM ;
         ICON "ICON_2" ;
         MAIN NOSHOW ;
         NOTIFYICON IF( lClipbrdFull, "ICON_1", "ICON_2" ) ;
         NOTIFYTOOLTIP PROGRAM ;
         ON NOTIFYCLICK ClipClear()
		
      DEFINE NOTIFY MENU

         ITEM '&Clipboard Viewer' ACTION ClipbrdView()

         SEPARATOR

         ITEM '&About...' ACTION ShellAbout( "", ;
            PROGRAM + VERSION + CRLF + ;
            "Copyright " + Chr( 169 ) + COPYRIGHT, LoadIconByName( "ICON_2", 32, 32 ) )
         SEPARATOR

         ITEM 'E&xit' ACTION Form_1.Release

      END MENU

      DEFINE TIMER Timer_1  ;
         INTERVAL 750 ;
         ACTION ( lClipbrdFull := IsClipbrdFull(), Form_1.NotifyIcon := iif( lClipbrdFull, "ICON_1", "ICON_2" ) )

      END WINDOW

      ACTIVATE WINDOW Form_1

   ENDIF

RETURN

*--------------------------------------------------------*
PROCEDURE ClipClear()
*--------------------------------------------------------*

   IF lClipbrdFull .AND. OpenClipboard( Application.Handle )

      IF .NOT. EmptyClipboard()
         MsgAlert( "The clipboard is not available now!" )
      ENDIF

      CloseClipboard()

   ENDIF

RETURN

*--------------------------------------------------------*
STATIC FUNCTION IsClipbrdFull()
*--------------------------------------------------------*
   LOCAL i, lRet := .F.

   FOR i := 1 TO CF_MAXCOUNT
      IF IsClipboardFormatAvailable( i )
         lRet := .T.
         EXIT
      ENDIF
   NEXT

RETURN lRet

*--------------------------------------------------------*
PROCEDURE ClipbrdView()
*--------------------------------------------------------*
   LOCAL cText := "", hBitmap, aSize

   IF lClipbrdFull .AND. ( IsClipboardFormatAvailable( CF_TEXT ) .OR. IsClipboardFormatAvailable( CF_BITMAP ) )

      IF IsWindowDefined( Form_2 )
         BringWindowToTop( GetFormHandle( "Form_2" ) )
         RETURN
      ENDIF

      DEFINE WINDOW Form_2 ;
         TITLE 'Clipboard Viewer' ;
         ICON "ICON_2" ;
         CHILD NOMAXIMIZE NOSIZE ;
         BACKCOLOR WHITE

      ON KEY ESCAPE ACTION Form_2.Release

      IF IsClipboardFormatAvailable( CF_TEXT )

         IF OpenClipboard( Application.Handle )

            cText := GetClipboardData( CF_TEXT )

            CloseClipboard()

         ENDIF

         DEFINE EDITBOX Text_1
            ROW    0
            COL    0
            WIDTH  Form_2.Width - GetBorderWidth()
            HEIGHT Form_2.Height - GetBorderHeight() - GetTitleHeight()
            VALUE  cText
            FONTBOLD .T.
            BACKCOLOR WHITE
         END EDITBOX

      ELSE

         DEFINE IMAGE Image_1
            ROW    2
            COL    2
            WIDTH  Form_2.Width - GetBorderWidth()
            HEIGHT Form_2.Height - GetBorderHeight() - GetTitleHeight()
         END IMAGE

         IF OpenClipboard( Application.Handle )

            hBitmap := GetClipboardData( CF_BITMAP )

            CloseClipboard()

            Form_2.Image_1.HBitmap := hBitmap

            aSize := GetBitmapSize( hBitmap )

            IF aSize[1] > 32 .AND. aSize[1] < ( Form_2.Width ) .AND. aSize[2] > 32 .AND. aSize[2] < ( Form_2.Height )
               Form_2.Width := aSize[1] + GetBorderWidth() + 2
               Form_2.Height := aSize[2] + GetBorderHeight() + GetTitleHeight() + 2
            ENDIF

         ENDIF

      ENDIF

      END WINDOW

      CENTER WINDOW Form_2
      ACTIVATE WINDOW Form_2

   ELSE

      MsgStop( "Nothing to watch!" )

   ENDIF

RETURN


#pragma BEGINDUMP

#include <mgdefs.h>

HB_FUNC( ISCLIPBOARDFORMATAVAILABLE )
{
   hb_retl( IsClipboardFormatAvailable( hb_parni(1) ) );
}

HB_FUNC( OPENCLIPBOARD )
{
   hb_retl( OpenClipboard( (HWND) hb_parnl(1) ) ) ;
}

HB_FUNC( CLOSECLIPBOARD )
{
   hb_retl( CloseClipboard() );
}

HB_FUNC( EMPTYCLIPBOARD )
{
   hb_retl( EmptyClipboard() ) ;
}

HB_FUNC( GETCLIPBOARDDATA )
{
   WORD wType = hb_parni( 1 );
   HGLOBAL hMem;

   switch( wType )
   {
      case CF_TEXT:
           hMem = GetClipboardData( CF_TEXT );
           if( hMem )
           {
              hb_retc( ( char * ) GlobalLock( hMem ) );
              GlobalUnlock( hMem );
           }
           else
              hb_retc( "" );
           break;

      case CF_BITMAP:
           if( IsClipboardFormatAvailable( CF_BITMAP ) )
              HB_RETNL( ( LONG_PTR ) GetClipboardData( CF_BITMAP ) );
           else
              hb_retnl( 0 );
   }
}

#pragma ENDDUMP
