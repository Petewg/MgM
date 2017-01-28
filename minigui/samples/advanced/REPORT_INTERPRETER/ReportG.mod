# REPORTG.MOD This Line Will be ignored!
# case ncpl= 80    nfsize:=12
# case ncpl= 96    nfsize=10
# case ncpl= 120   nfsize:=8
# case ncpl= 140   nfsize:=7
# case ncpl= 160   nfsize:=6

[Declare]80/PREV
SET JOB NAME [Group Print demo]
SET SPLASH TO ... Por favor espere ...    Trabajo en proceso
SET PAPERSIZE DMPAPER_A4
VAR TEMPO [] c ;(TEMPO:=TIME())
define imagelist ILIST1 picture flags
set preview on ; set COLORMODE MONO
ENABLE THUMBNAILS;SET CHARSET ANSI_CHARSET
var TC 0 n ;var ADO 0 n ;var Adi [] C
var TCode 0 n;var MAXROW 0 n;var MAXCOL 0 n
set euro 1;set money 1;set separator ON
(aadd(format,ed_g_pic(Field->incoming)))
set money 0
//(GroupField, Head string, Column string, count total for, where the gtotal, total string, total column, paper_feed_every_group)
// total for = Fieldname or array with multiple fieldname
what("Test",trim(first),1,"incoming")

GROUP first {||rtrim(first)+space(1)+str(what("Test",trim(first),1,"incoming"))+space(1)+"***"} AUTO {CODE,INCOMING} AUTO [** Subtotal **] 6 .T.

** DEFINE FONT AF1 NAME ARIAL SIZE 16 BOLD ITALIC
define pen p0 style PS_SOLID width 1 color 0x000000
DEFINE PEN N1 STYLE PS_DOT WIDTH 1 COLOR BLACK
DEFINE PEN GP1 STYLE PS_DASHDOT WIDTH 3 COLOR PINK
define brush B2 style BS_NULL
define brush b1 style BS_HATCHED color aqua hatch HS_DIAGCROSS
define brush bP1 style BS_HATCHED color lavender hatch HS_CROSS
select font f0
select pen p0
(maxrow := HBPRN:MAXROW)
SET PREVIEW RECT 20 20 700 900
set preview scale 1.1
SET ORIENTATION Portrait
DEFINE PEN P12 Ps_INSIDEFRAME WIDTH 0.2 COLOR 0,0,255
DEFINE BRUSH B0 SOLID COLOR 0xCCFFAA
####################################################################
*msgbox("Press Enter to start the Demo!",[Start Group Demo])
####################################################################
[HEAD]12
1 2 SAY [Pag.] COLOR Pink ;1 5 SAY trans(m->npag,[999]) COLOR blue

set print margins top 0 left 0

7 19 11 50 RECTANGLE pen p12 brush b1
@3,4 picture rosa.jpg SIZE 8 14
@2,0 SAY (HBPRN:MAXCOL) COLOR orange
 set textcolor orange
@1,16 SAY [INFORME DE ARTISTAS DE CINE] FONT ARIAL SIZE 16 BOLD ITALIC
 set textcolor pink
@1,63 SAY date() font [COURIER NEW] SIZE 10 BOLD align TA_CENTER
set textcolor BLUE;2 63 SAY Time() FONT [COURIER NEW] SIZE 10 BOLD color fucHsia align TA_CENTER
set backcolor white
set textcolor BLACK
@ 2,35 SAY [Segundo titulo report group] FONT ARIAL SIZE 16 BOLD ITALIC align center color pink
SELECT PEN P1
4 2 4 15 LINE ;4 16 4 29 LINE;4 30 4 59 LINE;4 60 4 78 LINE
@5, 5 SAY [    SIMPLE] font [COURIER NEW] SIZE 10 BOLD color yellow
@5,16 say [APELLIDO  ,       DOBLE] FONT [COURIER NEW] SIZE 10 BOLD COLOR BLUE
@5,60 say [INGRESOS] FONT [COURIER NEW] SIZE 10 BOLD COLOR Blue
6 2 6 15 LINE ; 6 16 6 29 LINE;6 30 6 59 LINE;6 60 6 78 LINE
SET TEXT ALIGN LEFT
52 50 (hbprn:maxRow)+1 (hbprn:maxcol)+1 RECTANGLE pen p1 brush bp1
55 53 TEXTOUT [Report Interpreter] FONT [COURIER NEW] SIZE 16 BOLD
@58,55 SAY [Generation      ] FONT [COURIER NEW] SIZE 16 BOLD UNDERLINE color lightsalmon
@58,70 SAY [III] FONT [COURIER NEW] SIZE 24 BOLD ITALIC color lightsalmon
9 20 7 50 DRAW TEXT [Draw EXAMPLE into Rect] STYLE DT_LEFT FONT [COURIER NEW] SIZE 16 BOLD
//@NLINE, 0 SAY '' FONT ARIAL SIZE 20 bold
set debug off
set debug off
(flob:=12)
SELECT PEN P0
SELECT brush B2
set backcolor white
 2 50 3.8 55 DRAW IMAGELIST ILIST1 ICON 15 BACKGROUND WHITE
*set debug list body
*set debug list declare
[BODY]40
set textcolor BLACK
(Tcode += Field->code)
@NLINE, 0 SAY m->nline FONT ARIAL SIZE 10 BOLD align left COLOR BLUE
@NLINE, 6 SAY Field->first FONT ARIAL SIZE 10 BOLD align left COLOR BLUE
@NLINE,26 SAY Field->code FONT ARIAL SIZE 10 BOLD COLOR [255,0,150] align right
@NLINE,27 TEXTOUT Field->LAST FONT ARIAL SIZE 10 BOLD
@NLINE,40 MEMOSAY FIELD->BIO len 39 FONT ARIAL SIZE 10 BOLD color BROWN
// @NLINE,68 PRINT (incoming) color ORANGE FONT ARIAL SIZE 10 BOLD ALIGN RIGHT
@NLINE,77 SAY trans(Field->INCOMING,format[1]) color ORANGE FONT ARIAL SIZE 10 BOLD align right
set textcolor 0
[FEET]4 
@ELINE, 2 SAY if(last_pag,[End Total for code = ]+TRANS(Tcode,"@be 999,999,999.99"),'') FONT ARIAL SIZE 10 BOLD color blue
set textcolor PINK
@(Nline+1), 5 SAY if(!last_pag,[SubTotal for Code = ]+TRANS(Tcode,"@e 999,999,999.99"),[Pink color for last page!]) FONT ARIAL SIZE 10 BOLD
set textcolor COLOR(112,150,255)
@(eline+3), 9 SAY if(last_pag,"Bye bye [End of DEMO]",[]) FONT ARIAL SIZE 16 BOLD ITALIC color red
@(eline+5), 9 SAY (tcode/2) FONT ARIAL SIZE 16 BOLD ITALIC color red
@(eline+5),29 SAY M->TEMPO FONT ARIAL SIZE 16 BOLD ITALIC color red
####################################################################
# if(last_pag,msgbox("End elaboration: Now you can see a preview!",[End Test2]),[])
####################################################################
[END]
