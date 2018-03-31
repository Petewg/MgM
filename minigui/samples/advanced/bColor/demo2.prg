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
/*  1 */   "YL Соломенный", ;
/*  2 */   "Y  Желтый", ;
/*  3 */   "H  Коричневый", ;
/*  4 */   "HR Коричнево красноватый", ;
/*  5 */   "RH Красно коричневатый", ;
/*  6 */   "R  Красный", ;
/*  7 */   "RD Темно красный", ;
/*  8 */   "RM Красный с малиновым", ;
/*  9 */   "MR Малиново красный", ;
/* 10 */   "M  Малиновый", ;
/* 11 */   "ML Светло малиновый", ;
/* 12 */   "MV Малиновый с фиолетом", ;
/* 13 */   "VM Фиолетовый с малиновым", ;
/* 14 */   "V  Фиолетовый", ;
/* 15 */   "VD Темно фиолетовый", ;
/* 16 */   "VB Фиолетовый с голубым", ;
/* 17 */   "BD БлеклоГолубой но темный", ;
/* 18 */   "B  Синий", ;
/* 19 */   "BC Синий блеклый к бюрезе", ;
/* 20 */   "CD Темная берюза", ;
/* 21 */   "CL Блеклая берюза", ;
/* 22 */   "C  Берюза", ;
/* 23 */   "CG Берюза с зеленью", ;
/* 24 */   "AC Светлая берюза зеленоватая", ;
/* 25 */   "A  Морская волна", ;
/* 26 */   "GA Блеклая зелень", ;
/* 27 */   "GL Блеклая светлая зелень", ;
/* 28 */   "G  Зеленый", ;
/* 29 */   "GF Темно зеленый блеклый", ;
/* 30 */   "GG Изумруд", ;
/* 31 */   "GN Сероватая зелень", ;
/* 32 */   "GD Темноватая зелень", ;
/* 33 */   "GO Блеклая серая зелень", ;
/* 34 */   "OL Грязная зелень", ;
/* 35 */   "O  Оливки", ;
/* 36 */   "W  Черно белый", ;
/* 37 */   "Z  Зарплата", ;   
/* 38 */   "ZB Зарплата Голубая", ;
/* 39 */   "ZG Зарплата Зеленая" }

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
