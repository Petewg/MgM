# REPORTS.MOD This Line Will be ignored!
#!MINIPRINT
[Declare]80/PREV
SET UNITS MM
SET JOB NAME [Array Print demo]
SET SPLASH TO S'il vous plaît attendre. création presses
SET PAPERSIZE DMPAPER_A4
define imagelist ILIST1 picture flags
SET CHARSET ANSI_CHARSET
set euro 1;set money 1;set separator ON
set money 0
DEFINE BRUSH BP1 STYLE BS_HATCHED COLOR LAVENDER HATCH HS_CROSS
DEFINE BRUSH B1 STYLE BS_HATCHED COLOR AQUA HATCH HS_DIAGCROSS
DEFINE PEN P1 STYLE PS_SOLID WIDTH 1 
DEFINE PEN P12 Ps_INSIDEFRAME WIDTH 0.2 COLOR 0,0,255
DEFINE FONT "xX" NAME [COURIER NEW] SIZE 12 UNDERLINE BOLD
SELECT FONT F0
SET ORIENTATION Portrait
var pizza [Hbprn] C
(Pizza := oWr:PrnDrv)
ONEATLEAST  1
set debug off
[HEAD]8
SET TEXTCOLOR BLACK
@(1*lstep),12 SAY [Pag.] FONT ARIAL SIZE 10 ;(1*lstep) 25 SAY trans(m->npag,[999]) FONT ARIAL SIZE 10
@8,14 picture ROSA.JPG size 18 17
@(1*lstep+3),105 SAY [INFORME DE ARTISTAS DE CINE] FONT ARIAL SIZE 16 BOLD ITALIC align center
@(1*lstep),178 SAY date() font [COURIER NEW] SIZE 10 BOLD align CENTER
@(2*lstep),178 SAY Time() FONT [COURIER NEW] SIZE 10 BOLD align CENTER
@(2*lstep+4),105 SAY [Segundo titulo] FONT ARIAL SIZE 16 BOLD ITALIC align center
@(4*lstep),11,(4*lstep),203 LINE
@(5*lstep),27 SAY [SIMPLE                   APELLIDO           DOBLE                     INGRESOS] font [COURIER NEW] SIZE 10 BOLD
@(5*lstep),52 SAY (Pizza) font [COURIER NEW] SIZE 20 BOLD
@(6*lstep),11 ,(6*lstep),203 LINE
SET TEXT ALIGN LEFT
SET UNITS MM
@(19*lstep ) 130 (18*lstep ) 170 RECTANGLE pen p1 brush b1
(18*lstep ),135 TEXTOUT [Report Interpreter 4] FONT "XX" COLOR BROWN

@(55*lstep),133 PRINT [Report Interpreter] FONT [COURIER NEW] SIZE 16 BOLD
@(58*lstep),135 SAY [Generation      ] FONT [COURIER NEW] SIZE 16 BOLD UNDERLINE color lightsalmon
@(58*lstep),170 SAY [IV] FONT [COURIER NEW] SIZE 24 BOLD ITALIC color lightsalmon
set backcolor white
@(2*lstep+3),130,(4*lstep+4),145 DRAW IMAGELIST ILIST1 ICON 15 BACKGROUND WHITE
@(52*lstep ),120,( ((maxRow)-1 ) ),(maxcol)-1 RECTANGLE pen p1 brush b1
SET TEXTCOLOR BLACK
[BODY]50

if (npag < 2)
   @ ((nline)*lstep),10 PUTARRAY m->asay len {20,40,25,18} FONT ARIAL SIZE 10 COLOR Blue noframe
   // ((nline)*lstep),10 PUTARRAY m->asay len {40} FONT ARIAL SIZE 10 COLOR Blue noframe
else
   @(nline*lstep),10 PUTARRAY m->asay len {20,40,25,18} FONT ARIAL SIZE 10 COLOR RED
   //@ ((nline)*lstep),10 PUTARRAY m->asay len {40} FONT ARIAL SIZE 10 COLOR RED
Endif
*/
//@nline*lstep,10 memosay m->asay len {10,14,25,18} FONT [COURIER NEW] SIZE 10 BOLD COLOR BLUE

[FEET]4
@((eline+3)*lstep), 9 SAY if(last_pag,[Bye bye ]+ [End of DEMO],[]) FONT ARIAL SIZE 16 BOLD ITALIC color red
[END]