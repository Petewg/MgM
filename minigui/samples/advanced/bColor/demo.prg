/*
 * MiniGUI bColor(...) Demo
 * bColor('R'), bColor('R+'), bColor('R++'), bColor('R-'), bColor('R--')
*/

#include "minigui.ch"

#ifdef __XHARBOUR__
   #define ENUMINDEX hb_EnumIndex()
#else
   #define ENUMINDEX cSymbol:__EnumIndex
#endif

Function Main
LOCAL aSymbol,y,x,cSymbol

DEFINE WINDOW Form_1 ;
	AT 0,0   ;
	WIDTH  250 ;
	HEIGHT 380 ;
	TITLE 'Test bColor(...) Demo' ;
	MAIN 
       
       aSymbol := {'N', 'B', 'G', 'C', 'R', 'M', 'Y', 'W', 'X', 'Z'}

       y := 20
       
       FOR EACH cSymbol IN aSymbol
           x := 20
           @ y, x LABEL &('Lbl_'+hb_ntos(ENUMINDEX)+'1') WIDTH 40 HEIGHT 24 ;
                  VALUE ' '+cSymbol+'-- '                BACKCOLOR bColor(cSymbol+'--')

           x += 40
           @ y, x LABEL &('Lbl_'+hb_ntos(ENUMINDEX)+'2') WIDTH 40 HEIGHT 24 ;
                  VALUE ' '+cSymbol+'-  '                BACKCOLOR bColor(cSymbol+'-')

           x += 40
           @ y, x LABEL &('Lbl_'+hb_ntos(ENUMINDEX)+'3') WIDTH 40 HEIGHT 24 ;
                  VALUE ' '+cSymbol+'   '                BACKCOLOR bColor(cSymbol)

           x += 40
           @ y, x LABEL &('Lbl_'+hb_ntos(ENUMINDEX)+'4') WIDTH 40 HEIGHT 24 ;
                  VALUE ' '+cSymbol+'+  '                BACKCOLOR bColor(cSymbol+'+')

           x += 40
           @ y, x LABEL &('Lbl_'+hb_ntos(ENUMINDEX)+'5') WIDTH 40 HEIGHT 24 ;
                  VALUE ' '+cSymbol+'++ '                BACKCOLOR bColor(cSymbol+'++')

           y += 30
       NEXT


END WINDOW

CENTER WINDOW Form_1

ACTIVATE WINDOW Form_1

Return Nil

#include "c_bcolor.c"
