!MINIPRINT
[Declare]80/PREV/sele
SET JOB NAME [Simple MiniPrint demo]
SET PAPERSIZE DMPAPER_A4
define imagelist ILIST1 picture flags
SET CHARSET ANSI_CHARSET
set euro 1;set money 1;set separator ON
(aadd(format,ed_g_pic(Field->incoming)))
set money 0
//set debug list declare
DEFINE BRUSH BP1 STYLE BS_HATCHED COLOR LAVENDER HATCH HS_CROSS
SELECT FONT F0
SET ORIENTATION Portrait
var pizza c ''

(m->pizza := "MiniPrn" )
set debug off
//msgbox(str(maxrow))
[HEAD]8
@(1*lstep),12 SAY [Pag.] ;(1*lstep) 25 SAY trans(m->npag,[999])
@8,14 PRINT IMAGE ROSA.JPG HEIGHT 18 WIDTH 17 STRETCH
@(1*lstep),105 SAY [INFORME DE ARTISTAS DE CINE] FONT ARIAL SIZE 16 BOLD ITALIC align center
@(1*lstep),178 SAY date() font [COURIER NEW] SIZE 10 BOLD align CENTER
@(2*lstep),178 SAY Time() FONT [COURIER NEW] SIZE 10 BOLD align CENTER
@(2*lstep),105 SAY [Segundo titulo] FONT ARIAL SIZE 16 BOLD ITALIC align center
@(4*lstep),11 PRINT LINE TO (4*lstep),203 PENWIDTH .1
@(5*lstep),25 SAY [SIMPLE                                    APELLIDO                 DOBLE] font [Helvetica] SIZE 10 BOLD
@(5*lstep),200 SAY [INGRESOS] font [Helvetica] SIZE 10 BOLD  align right
*@(5*lstep)-2.5,52 SAY (Pizza) font [COURIER NEW] SIZE 20 BOLD
@(6*lstep),11 PRINT LINE TO (6*lstep),203 PENWIDTH .1
SET TEXT ALIGN LEFT
@(52*lstep ),130 PRINT RECTANGLE TO ( ((maxRow)-1 )*lstep ),(maxcol)+1 PENWIDTH .1
@(55*lstep),133 PRINT [Report Interpreter] FONT [COURIER NEW] SIZE 16 BOLD
@(58*lstep),135 SAY [Generation  IV ] FONT [times] SIZE 16 BOLD UNDERLINE color lightsalmon
set backcolor white
@(2*lstep),50,3.8,55 DRAW IMAGELIST ILIST1 ICON 15 BACKGROUND WHITE
[BODY]40
@(NLINE*lstep),21 SAY Field->first FONT ARIAL SIZE 10 BOLD align left COLOR BLUE
@(NLINE*lstep),71 SAY Field->code FONT ARIAL SIZE 10 BOLD COLOR [255,0,150] align right
@(NLINE*lstep),74 PRINT Field->LAST FONT ARIAL SIZE 10 BOLD
@(NLINE*lstep),108 MEMOSAY FIELD->BIO len 35 FONT ARIAL SIZE 10 BOLD        color red
@(NLINE*lstep),200 SAY trans(Field->INCOMING,format[1]) color ORANGE FONT ARIAL SIZE 10 BOLD align right
[FEET]4 
@((eline+3)*lstep), 9 SAY if(last_pag,"Bye bye [End of DEMO]",[]) FONT ARIAL SIZE 16 BOLD ITALIC color red
[END]
