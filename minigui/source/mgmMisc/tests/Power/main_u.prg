#include <hmg.ch>

#define _UNICODE 

request hb_codepage_utf8ex
PROCEDURE Main()
   LOCAL aFormColor := {31,37,61}
   LOCAL HeaderBackColor := {  52, 104, 175 }
   LOCAL HeaderFontColor := { 255, 255, 255 }
   LOCAL smallFontSize   := 10
   LOCAL mainFontSize    := 12
   LOCAL mainFont        := 'Verdana'
   
   hb_cdpselect( "UTF8EX" )

   LOAD WINDOW MainFrm_u
   SET CENTERWINDOW RELATIVE PARENT
   CENTER WINDOW MainFrm_u
   ACTIVATE WINDOW MainFrm_u

RETURN

#define HTCAPTION          2
#define WM_NCLBUTTONDOWN   161
PROCEDURE MoveActiveWindow( hWnd, cForm )

   LOCAL nMouseRow := GetCursorRow()
   LOCAL nFormRow := GetProperty(cForm,'Row')

   hb_Default( @hWnd, GetActiveWindow() )
   IF (nMouseRow >= nFormRow) .AND. (nMouseRow <= (nFormRow + 45))
     PostMessage( hWnd, WM_NCLBUTTONDOWN, HTCAPTION, 0 )
   ENDIF

PROCEDURE MsgAbout()
   MsgInfo( '«Ask, and it shall be given you; seek, and ye shall find; '+ hb_eol()+;
            ' knock, and it shall be opened unto you:'+ hb_eol()+;
            ' For every one that asketh receiveth; and he that seeketh findeth; '+hb_eol()+;
            ' and to him that knocketh it shall be opened.»',;
            "About.." )
RETURN

PROCEDURE ChkUni()

   IF IsWindowUnicode( GetActiveWindow() )
      MsgInfo( "Unicode!" )
   ELSE
      MsgInfo( "Ansi!" )
   ENDIF
   RETURN
   
      
   
#pragma begindump
#include <mgdefs.h>

HB_FUNC( ISWINDOWUNICODE )
{
   hb_retl( IsWindowUnicode( (HWND) hb_parnl( 1 ) ) );
}
#pragma enddump



