#include <hmg.ch>

#define HTCAPTION          2
#define WM_NCLBUTTONDOWN   161

PROCEDURE Main()
   LOCAL aFormColor := {31,37,61}
   LOCAL HeaderBackColor := {  52, 104, 175 }
   LOCAL HeaderFontColor := { 255, 255, 255 }
   LOCAL smallFontSize   := 10
   LOCAL mainFontSize    := 12
   LOCAL mainFont        := 'Verdana'

   LOAD WINDOW MainFrm
   SET CENTERWINDOW RELATIVE PARENT
   CENTER WINDOW MainFrm
   ACTIVATE WINDOW MainFrm

RETURN


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
   