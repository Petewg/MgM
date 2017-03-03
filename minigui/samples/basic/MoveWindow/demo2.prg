/*
 * MiniGUI Demo
*/

#include "minigui.ch"

Function Main()

DEFINE WINDOW Form_1 ;
   AT 0,0 ;
   WIDTH 450 HEIGHT 400 ;
   TITLE 'Main Window' ;
   MAIN ;
   ON MOUSECLICK MoveActiveWindow( This.Handle ) ;
   ON INIT CreaChild() ;
   ON MOVE MoveTest() ;
   ON SIZE MoveTest() ;
   NOMAXIMIZE NOMINIMIZE

   ON KEY ESCAPE ACTION ThisWindow.Release

   DEFINE STATUSBAR
       STATUSITEM "Click on Form and holding mouse's button for moving this window" FONTCOLOR BLACK CENTERALIGN
   END STATUSBAR

END WINDOW

CENTER WINDOW Form_1
ACTIVATE WINDOW Form_1

Return Nil


Function CreaChild()
Local xPos := Form_1.Col
Local yPos := Form_1.Row
Local nWidth := Form_1.Width

DEFINE WINDOW Form_2 ;
   AT yPos,xPos+nWidth ;
   WIDTH 350 HEIGHT 200 ;
   TITLE 'Child Window' ;
   CHILD NOSYSMENU ;
   ON MOUSECLICK Form_2.Height := ( Form_1.Height )

   DEFINE STATUSBAR
       STATUSITEM "This window CHILD will be 'anchored' to the MAIN" FONTCOLOR BLACK CENTERALIGN
   END STATUSBAR

   DEFINE TIMER t_1 INTERVAL 250 ACTION ( Form_1.SetFocus, Form_2.t_1.Release )

END WINDOW

ACTIVATE WINDOW Form_2

RETURN Nil


#define HTCAPTION          2
#define WM_NCLBUTTONDOWN   161

Function MoveActiveWindow( hWnd )

	PostMessage( hWnd, WM_NCLBUTTONDOWN, HTCAPTION, 0 )

Return Nil


Function MoveTest()
Local xPos := hb_ntos( _HMG_MouseRow - GetTitleHeight() - GetBorderWidth() )
Local yPos := hb_ntos( _HMG_MouseCol - GetBorderWidth() )
Local nWidth := Form_1.Width

	Form_1.StatusBar.Item(1):="Row: "+yPos+" / Col: "+xPos+" | "+hb_ntos(nWidth)

	ChgChild()

Return Nil


Function ChgChild()
Local xPos := Form_1.Col
Local yPos := Form_1.Row
Local nWidth := Form_1.Width

	Form_2.Row := yPos
	Form_2.Col := xPos + nWidth

Return Nil
