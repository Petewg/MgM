/*
 * MiniGUI bColor2(...) Demo
 * bColor2('R'), bColor2('R+'), bColor2('R++'), bColor2('R-'), bColor2('R--')
*/

#include "minigui.ch"

Function Main
LOCAL a,y,x,i,j,k

DEFINE WINDOW Form_1 ;
	AT 0,0   ;
	WIDTH  510 ;
	HEIGHT 680 ;
	TITLE 'Test bColor2(...) Demo' ;
	MAIN 
       
       a := {; 
/*  1 */   "YL ����������", ;
/*  2 */   "Y  ������", ;
/*  3 */   "H  ����������", ;
/*  4 */   "HR ��������� �����������", ;
/*  5 */   "RH ������ ������������", ;
/*  6 */   "R  �������", ;
/*  7 */   "RD ����� �������", ;
/*  8 */   "RM ������� � ���������", ;
/*  9 */   "MR �������� �������", ;
/* 10 */   "M  ���������", ;
/* 11 */   "ML ������ ���������", ;
/* 12 */   "MV ��������� � ��������", ;
/* 13 */   "VM ���������� � ���������", ;
/* 14 */   "V  ����������", ;
/* 15 */   "VD ����� ����������", ;
/* 16 */   "VB ���������� � �������", ;
/* 17 */   "BD ������������� �� ������", ;
/* 18 */   "B  �����", ;
/* 19 */   "BC ����� ������� � ������", ;
/* 20 */   "CD ������ ������", ;
/* 21 */   "CL ������� ������", ;
/* 22 */   "C  ������", ;
/* 23 */   "CG ������ � �������", ;
/* 24 */   "AC ������� ������ �����������", ;
/* 25 */   "A  ������� �����", ;
/* 26 */   "GA ������� ������", ;
/* 27 */   "GL ������� ������� ������", ;
/* 28 */   "G  �������", ;
/* 29 */   "GF ����� ������� �������", ;
/* 30 */   "GG �������", ;
/* 31 */   "GN ��������� ������", ;
/* 32 */   "GD ���������� ������", ;
/* 33 */   "GO ������� ����� ������", ;
/* 34 */   "OL ������� ������", ;
/* 35 */   "O  ������", ;
/* 36 */   "W  ����� �����", ;
/* 37 */   "Z  ��������", ;   
/* 38 */   "ZB �������� �������", ;
/* 39 */   "ZG �������� �������" }

       y := 20
       k := 0
       
       FOR i := 1 TO Len(a)
           j := trim(Left(a[ i ], 2))
           x := iif(i > 20, k, 10)

           @ y, x LABEL &('Lbl_'+hb_ntos(i)+'0') WIDTH 24 HEIGHT 24       ;
                  VALUE ' '+hb_ntos(i)+'.'

           x += 24
           @ y, x LABEL &('Lbl_'+hb_ntos(i)+'1') WIDTH 40 HEIGHT 24       ;
                  VALUE ' '+j+'-- '              BACKCOLOR bColor2(j+'--')

           x += 40
           @ y, x LABEL &('Lbl_'+hb_ntos(i)+'2') WIDTH 40 HEIGHT 24       ;
                  VALUE ' '+j+'-  '              BACKCOLOR bColor2(j+'-')

           x += 40
           @ y, x LABEL &('Lbl_'+hb_ntos(i)+'3') WIDTH 40 HEIGHT 24       ;
                  VALUE ' '+j+'   '              BACKCOLOR bColor2(j)

           x += 40
           @ y, x LABEL &('Lbl_'+hb_ntos(i)+'4') WIDTH 40 HEIGHT 24       ;
                  VALUE ' '+j+'+  '              BACKCOLOR bColor2(j+'+')

           x += 40
           @ y, x LABEL &('Lbl_'+hb_ntos(i)+'5') WIDTH 40 HEIGHT 24       ;
                  VALUE ' '+j+'++ '              BACKCOLOR bColor2(j+'++')

           y += 30
           x += 40
           IF k < 1; k := x + 20
           ENDIF
           IF i == 20; y := 20
           ENDIF
       NEXT

END WINDOW

CENTER WINDOW Form_1

ACTIVATE WINDOW Form_1

Return Nil

#include "c_bcolor.c"
