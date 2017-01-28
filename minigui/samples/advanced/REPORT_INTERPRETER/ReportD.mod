*!Miniprint
# REPORTS.MOD This Line Will be ignored!
[Declare]80/PREV
SET UNITS MM
SET JOB NAME [Simple Print demo]
SET SPLASH TO ... Por favor espere...    Produção em curso
SET PAPERSIZE DMPAPER_A4
define imagelist ILIST1 picture flags
SET CHARSET ANSI_CHARSET
set euro 1;set money 1;set separator ON
(aadd(format,ed_g_pic(Field->incoming)))
set money 0
//set debug list declare
DEFINE BRUSH BP1 STYLE BS_HATCHED COLOR LAVENDER HATCH HS_CROSS
DEFINE BRUSH B1 STYLE BS_HATCHED COLOR AQUA HATCH HS_DIAGCROSS
DEFINE PEN P1 STYLE PS_SOLID WIDTH 1 
DEFINE PEN P12 Ps_INSIDEFRAME WIDTH 0.2 COLOR 0,0,255
DEFINE FONT "xX" NAME [COURIER NEW] SIZE 12 UNDERLINE BOLD
SELECT FONT F0
SET ORIENTATION Portrait
var pizza c ''
(m->Pizza:=if (oWr:prndrv = "MINI","Miniprint","Hbprn"))
set debug off
msgexclamation("This demo produces 2 pages for each"+Chr(10)+chr(13)+"record with memo field NOT empty!")
if  (oWr:prndrv = "HBPR")
    msginfo("If you want using Miniprint instead, erase the # at first line of ReportD.mod")
Else
    msginfo("If you want using HBPRINTER instead, Put one # at first line of ReportD.mod")
Endif
[HEAD]8
SET TEXTCOLOR BLACK
@(1*lstep),12 SAY [Pag.] FONT ARIAL SIZE 10 ;(1*lstep) 25 SAY trans(m->npag,[999]) FONT ARIAL SIZE 10
if (oWr:prndrv = "MINI")
   @8,14 PRINT IMAGE ROSA.JPG HEIGHT 18 WIDTH 17 STRETCH
Else
   @8,14 picture ROSA.JPG size 18 17
Endif
@(1*lstep+3),105 SAY [INFORME DE ARTISTAS DE CINE] FONT ARIAL SIZE 16 BOLD ITALIC align center
@(1*lstep),178 SAY date() font [COURIER NEW] SIZE 10 BOLD align CENTER
@(2*lstep),178 SAY Time() FONT [COURIER NEW] SIZE 10 BOLD align CENTER
@(2*lstep+4),105 SAY [Segundo titulo] FONT ARIAL SIZE 16 BOLD ITALIC align center
if (oWr:prndrv = "MINI")
   @(5*lstep),11 PRINT LINE TO (5*lstep),203 PENWIDTH .1
   @(6*lstep),11 PRINT LINE TO (6*lstep),203 PENWIDTH .1
Else
   @(4*lstep),11,(4*lstep),203 LINE
   @(6*lstep),11 ,(6*lstep),203 LINE
Endif
@(5*lstep),27 SAY [SIMPLE                   APELLIDO           DOBLE                     INGRESOS] font [COURIER NEW] SIZE 10 BOLD
@(8*lstep),45 SAY (Pizza) font [COURIER NEW] SIZE 20 BOLD

// this following line is necessary for memo!!!!
@ 0,0 SAY [] FONT ARIAL SIZE 14 BOLD
set backcolor white
@(2*lstep+3),130,(4*lstep+4),145 DRAW IMAGELIST ILIST1 ICON 15 BACKGROUND WHITE
[BODY]45
@(NLINE*lstep),21 SAY Field->first FONT ARIAL SIZE 10 BOLD align left COLOR BLUE
@(NLINE*lstep),71 SAY Field->code FONT ARIAL SIZE 10 BOLD COLOR [255,0,150] align right
@(NLINE*lstep),74 PRINT Field->LAST FONT ARIAL SIZE 10 BOLD
@(NLINE*lstep),200 SAY trans(Field->INCOMING,format[1]) color ORANGE FONT ARIAL SIZE 10 BOLD align right

( Page2(15,52, FIELD->BIO,35,"BROWN") )
* mm row,mm col, argmemo,arglen,argcolor1)
(nline --)
[FEET]4
@((eline+3)*lstep), 9 SAY if(last_pag,"Bye bye [End of DEMO]",[]) FONT ARIAL SIZE 16 BOLD ITALIC color red
[END]
/*
@(52*LSTEP),50,(hbprn:maxRow)+1,(hbprn:maxcol)+1 RECTANGLE pen p1 brush bp1
@2,50,3.8,55 DRAW IMAGELIST ILIST1 ICON 15 BACKGROUND WHITE
*/
