# REPORT.MOD This Line Will be ignored!
# case ncpl= 80    nfsize:=12
# case ncpl= 96    nfsize=10
# case ncpl= 120   nfsize:=8
# case ncpl= 140   nfsize:=7
# case ncpl= 160   nfsize:=6

[Declare]80/PREV/sele 
(HBPRN:docname:="Fantasy Print demo")
SET PAPERSIZE DMPAPER_A4
VAR TEMPO [] c ;(TEMPO:=TIME())
define imagelist ILIST1 picture flags
# set orientation landscape
set preview on ; set COLORMODE MONO
# set quality high
# set bin dmbin_manual
ENABLE THUMBNAILS;SET CHARSET ANSI_CHARSET
var Apolybx NIL A;var TC 0 n
var Apolyx NIL A;var Apolyn NIL A;var ADO 0 n ;var Adi [] C
var TCode 0 n;var MAXROW 0 n;var MAXCOL 0 n
set euro 1;set money 1;set separator ON
(aadd(format,ed_g_pic(Field->incoming)))
set money 0
(aPolyx:= {{5,1},{5,79},{25,79},{25,1}})
//(GroupField, Head string, Column string, count total for, where the gtotal, total string, total column, paper_feed_every_group)
// total for = Fieldname or array with multiple fieldname
GROUP([first],[*  * Name *  * ],"AUTO","INCOMING","AUTO","** Subtotal **",4,.T.)
DEFINE FONT AF1 NAME ARIAL SIZE 16 bold italic
DEFINE FONT AF2 NAME [TIMES NEW ROMAN] SIZE 16 italic UNDERLINE BOLD
DEFINE FONT AB8 NAME ARIAL SIZE 10 BOLD
DEFINE FONT AB10 NAME [Courier New] SIZE 10 bold 
define pen p0 style PS_SOLID width 1 color 0x000000
DEFINE PEN N1 STYLE PS_DOT WIDTH 1 COLOR BLACK
DEFINE PEN GP1 STYLE PS_DASHDOT WIDTH 3 COLOR PINK
define brush B2 style BS_NULL
define brush b1 style BS_HATCHED color yellow hatch HS_DIAGCROSS
define brush bP1 style BS_HATCHED color green hatch HS_CROSS
select font f0
select pen p0
define elliptic region r0 at 0 0 20 30
define elliptic region r1 at 0 (hbprn:maxcol)-30 20 (hbprn:maxcol)
define elliptic region r2 at 10 20 40 (hbprn:maxcol)-20
define polygon region pl vertex apolyx style RGN_OR
combine regions r0 r1 to r4 style RGN_OR
combine regions r4 r2 to r5 style RGN_OR
combine regions r5 pl to r6 style RGN_OR
SET PREVIEW RECT 20 20 700 900
set preview scale 1.1
Set polyfill mode winding
Set textchar extra 4
SET ORIENTATION Portrait
DEFINE PEN P12 Ps_INSIDEFRAME WIDTH 0.2 COLOR 0,0,255
DEFINE BRUSH B0 SOLID COLOR 0xCCFFAA
# gridcol(.F.)
# gridrow(.T.)
(aPolyn:= {{20 ,24} ,{43,2},{12,24}})
(aPolybx:={{40,40},{35,35},{30,50},{35,57},{40,64},{50,55},{40,35}})
####################################################################
# msgbox("Press Enter to start the elaboration!",[Start Test1]) 
####################################################################
[HEAD]12
(if(npag = 2,hbprn:selectcliprgn("r5"),'')) 
(if(npag <> 2,hbprn:deletecliprgn(),''))
1 2 SAY [Pag.] COLOR Pink ;1 12 SAY trans(m->npag,[999]) COLOR blue
(maxrow := HBPRN:MAXROW)
set print margins top 0 left 0
 
0 0 MAXROW (HBPRN:MAXCOL) RECTANGLE BRUSH b0 PEN P2
## 3 4 picture rosa.jpg SIZE 35 55 Extend 35 55
3 4 picture rosa.jpg SIZE 8 14
 2 0 SAY (HBPRN:MAXCOL) COLOR orange
 set textcolor orange
 1 16 SAY [INFORME DE ARTISTAS DE CINE] FONT AF1
 set textcolor pink
 1 63 SAY date() font AB10 align TA_CENTER
# debug_on
set textcolor BLUE;2 63 SAY Time() FONT AB10 color fucHsia align TA_CENTER
# debug_off

# set textcolor COLOR([ORANGE]) 
# set textcolor COLOR([GREEN])
set backcolor white
set textcolor BLACK
2 35 SAY [Segundo titulo] FONT AF1 align center color pink
SELECT PEN P1
55 10 LINETO 
4 2 4 15 LINE ;4 16 4 29 LINE;4 30 4 59 LINE;4 60 4 78 LINE
# CHANGE PEN P1 PS_DOT WIDTH 1 COLOR BLACK

55 10 LINETO PEN P0 ; 4 62 8 79 LINE PEN P0
5 5 SAY [    SIMPLE] font ab10 color yellow
5 16 say [APELLIDO  ,       DOBLE] FONT AB10 COLOR BLUE 
5 60 say [INGRESOS] FONT AB10 COLOR Blue 
6 2 6 15 LINE ; 6 16 6 29 LINE;6 30 6 59 LINE;6 60 6 78 LINE
SET TEXT ALIGN LEFT
52 50 (hbprn:maxRow)+1 (hbprn:maxcol)+1 RECTANGLE pen p1 brush bp1
10 30 20 50 CHORD RADIAL1 10 50 RADIAL2 15 75 PEN GP1 BRUSH B0
10 30 28 50 CHORD RADIAL1 10 50 RADIAL2 95 95 PEN GP1
4 20 5 20 draw text [esempgio di draw] Style BS_pattern font AB10
(flob:=12)
SELECT PEN P0
SELECT brush B2
set backcolor white
 2 50 3.8 55 DRAW IMAGELIST ILIST1 ICON 15 BACKGROUND WHITE

[BODY]40
# NLINE 67 SAY ed_g_pic(Field->incoming)
set textcolor BLACK
# (ADO += Field->photo)
(Tcode += Field->code)
NLINE 0 SAY m->nline FONT AB8 align left COLOR BLUE
NLINE 6 SAY Field->first FONT AB8 align left COLOR BLUE
NLINE 26 SAY Field->code FONT AB8 COLOR [255,250,0] align right 
NLINE 27 textOUT Field->last FONT AB8 COLOR BLUE
NLINE 40 MEMOSAY FIELD->BIO len 35 FONT Ab8 color red
//NLINE 68 SAY Field->incoming color ORANGE FONT Ab8 align right
NLINE 77 SAY trans(Field->incoming,format[1]) color ORANGE FONT Ab8 align right
set textcolor 0
[FEET]4 
polygon apolyn PEN p0 BRUSH b1
polybezier apolybx PEN p0
# if(last_pag,adi := [ Empty],[WWWW])
ELINE 2 SAY if(last_pag,[End Total for code = ]+TRANS(Tcode,"@be 999,999,999.99"),'') FONT Ab8 color blue
set textcolor PINK
(Nline+1) 5 SAY if(!last_pag,[SubTotal for Code = ]+TRANS(Tcode,"@e 999,999,999.99"),[Pink color!]) FONT AB8
set textcolor COLOR(112,150,255)
(eline+3) 9 SAY if(last_pag,"Bye bye [End of DEMO]",[]) FONT AF1 color red
(eline+5) 9 SAY (tcode/2) FONT AF1 color red
(eline+5) 29 SAY M->TEMPO FONT AF1 color red
(if(m->npag > 1,hbprn:deletecliprgn(),''))
####################################################################
# if(last_pag,msgbox("End elaboration: Now you can see a preview!",[End Test2]),[])
####################################################################
[END]
