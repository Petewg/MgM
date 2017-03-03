/*
 * MiniGUI Demo
 *
 * Author: Luis Vasquez <luisvasquezcl@yahoo.com>
 *
 * Added support to multiple windows by Mahmoud Fayed <msfclipper@yahoo.com>
*/

#include "minigui.ch"

#define VERTICAL 1
#define HORIZONTAL 2
#define ANGULO 3
#define OPEN 1
#define CLOSE 2

STATIC nWinsCount := 1
 
FUNCTION Main
 
 DEFINE WINDOW Win_1 ;
  AT 0,0 ;
  WIDTH 400 ;
  HEIGHT 300 ;
  TITLE 'Test Window with effect' ;
  MAIN
 
  @ 14, 10 LABEL LABEL_1 VALUE 'Select Window effect:'
  @ 10, 140 COMBOBOX COMBO_1 ITEMS {'Vertical','Horizontal','Angle'} VALUE 1
  @ 40, 10 BUTTON btn1 caption 'Open Window' ACTION P1() WIDTH 120
  @ 80, 10 EDITBOX EDIT_1 VALUE 'Select the effect to apply to the window and then open and close the window and see the effect is maintained for both events' WIDTH 360 HEIGHT 150 NOHSCROLL

 END WINDOW

 CENTER WINDOW Win_1
 ACTIVATE WINDOW Win_1

RETURN NIL


PROCEDURE P1
 LOCAL cWindowName

 cWindowName := "Win_" + Alltrim(Str(++nWinsCount))
 
 DEFINE WINDOW &cWindowName ;
  AT 300,350 ;
  WIDTH 300 ;
  HEIGHT 300 ;
  TITLE 'Hello World!' ;
  CHILD ;
  ON INIT WindowEfect(cWindowName, OPEN, win_1.combo_1.value) ;
  ON RELEASE WindowEfect(cWindowName, CLOSE, win_1.combo_1.value)
  
  DEFINE LABEL LABEL_1
   ROW 10
   COL 10
   WIDTH 300
   VALUE 'Window with effect'
   FONTNAME 'Arial'
   FONTSIZE 12
   FONTBOLD .T.
  END LABEL

  DEFINE BUTTON BTN1
   ROW 40
   COL 10
   CAPTION '&Close'
   ACTION DoMethod(cWindowName,"release")
  END BUTTON

 END WINDOW

 ACTIVATE WINDOW &cWindowName

RETURN


PROCEDURE WindowEfect( cWin, nEvento, nEfecto )
 LOCAL hWin, i
 LOCAL r, c, w, h
 LOCAL nw, nh
 LOCAL nTop := 0

 If nEvento == OPEN 
  DoMethod( cWin, 'hide' )
 Endif
 
 hWin := GetFormHandle( cWin )
 r := GetProperty( cWin, 'Row' )
 c := GetProperty( cWin, 'Col' )
 w := GetProperty( cWin, 'Width' )
 h := GetProperty( cWin, 'Height' )
 nw := w
 nh := h
 
 SetProperty( cWin, 'WIDTH', 0 )
 SetProperty( cWin, 'HEIGHT', 0 )

 If nEvento == OPEN
  DoMethod( cWin, 'show' )
 Endif

 SWITCH nEfecto
 CASE VERTICAL
  nTop := h
  EXIT
 CASE HORIZONTAL
  nTop := w
  EXIT
 CASE ANGULO
  nTop := 500
  nw := w/500
  nh := h/500  
 ENDSWITCH
 
 FOR i:=1 TO nTop
  
  SWITCH nEfecto
  CASE VERTICAL
   nh := IF( nEvento = OPEN, i, h-i )
   EXIT
  CASE HORIZONTAL
   nw := IF( nEvento = OPEN, i, w-i )
   EXIT
  CASE ANGULO
   IF nEvento = OPEN
    nw := (w/500)*i
    nh := (h/500)*i
   ELSE
    nw := w-((w/500)*i)
    nh := h-((h/500)*i)
   ENDIF
  ENDSWITCH
  
  MoveWindow( hWin, c, r, nw, nh, .t. )
 NEXT

RETURN
