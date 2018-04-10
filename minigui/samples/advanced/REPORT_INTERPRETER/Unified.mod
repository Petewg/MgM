#!HBPRINT
#!MiniPrint
#!PdfPrint
# REPORTS.MOD This Line Will be ignored!
[Declare]80/PREV

SET UNITS MM
set Vruler 12 .t.
set Hruler 215 .t.
SET JOB NAME [Simple Print demo]
SET PAPERSIZE DMPAPER_A4
//SET CHARSET ANSI_CHARSET
set euro 1;set money 1;set separator ON
(aadd(format,ed_g_pic(Field->incoming)))
SET MONEY 0
SET COLORMODE 0
SET QUALITY HIGH
SET OFFSET HBPCOMPATIBLE
set debug list declare
DEFINE BRUSH BP1 STYLE BS_HATCHED COLOR LAVENDER HATCH HS_CROSS
DEFINE PEN P1 STYLE PS_SOLID WIDTH 3
SELECT FONT F0
SET ORIENTATION Portrait
//var pizza C []
//(Pizza:= owr:prndrv)
If (owr:prndrv = "PDF")
   SET JOB NAME [Winreport Pdf demo]
Endif
//msgbox(oWr:aStat[ 'Hbcompatible' ])
[HEAD]12
@10,14 print image rosa.jpg width 35 height 35
   @(1*lstep+3),105 SAY [INFORME DE ARTISTAS DE CINE] FONT ARIAL SIZE 16 BOLD ITALIC align center
   @(3*lstep),105 SAY [Segundo titulo] FONT ARIAL SIZE 16 BOLD ITALIC align center
*  200, 100 say  [E] FONT ARIAL SIZE 100
*if (owr:prndrv="MINI")
*   @(1*lstep),10 SAY [Pag.] FONT ARIAL SIZE 10 ;(1*lstep) 25 SAY trans(m->npag,[999]) FONT ARIAL SIZE 10
*   @(1*lstep),178 SAY date() font [COURIER NEW] SIZE 10 BOLD align CENTER
*   @(2*lstep),178 SAY Time() FONT [COURIER NEW] SIZE 10 BOLD align CENTER
*Else
   @(1*lstep),10 SAY [Pag.] FONT ARIAL SIZE 10 ;(1*lstep) 25 SAY trans(m->npag,[999]) FONT ARIAL SIZE 10
   @(1*lstep),178 SAY date() font [COURIER NEW] SIZE 10 BOLD align CENTER
   @(2*lstep),178 SAY Time() FONT [COURIER NEW] SIZE 10 BOLD align CENTER
* Endif
@(4*lstep),11,(4*lstep),203 LINE
@(5*lstep),25 SAY [SIMPLE                                    APELLIDO                 DOBLE] font [Helvetica] SIZE 10 BOLD
SET DEBUG OFF
@(5*lstep),200 SAY [INGRESOS] font [Helvetica] SIZE 10 BOLD RIGHT
SET DEBUG OFF
@((61)*Lstep) (32) ((63)*Lstep) (65) RECTANGLE //ROUNDRECT ROUNDR 10 ROUNDC 10 PEN N1 BRUSH B0
@(62*lstep),35 SAY (owr:prndrv) font [COURIER NEW] SIZE 20 BOLD

*MSGBOX(61*lstep,"LSTEP")
@(6*lstep),11 ,(6*lstep),203 LINE
SET TEXT ALIGN LEFT
set debug off

@(55*lstep),133 PRINT [Report Interpreter] FONT [COURIER NEW] SIZE 16 BOLD
@(58*lstep),135 SAY [Generation  IV ] FONT [Arial] SIZE 16 BOLD UNDERLINE color lightsalmon
set backcolor white
*/
[BODY]40
@(NLINE*lstep), 0 SAY m->nline FONT ARIAL SIZE 10 BOLD align left COLOR BLUE
@(NLINE*lstep),21 SAY Field->first FONT ARIAL SIZE 10 BOLD align left COLOR BLUE
@(NLINE*lstep),71 SAY Field->code FONT ARIAL SIZE 10 BOLD COLOR [255,0,150] align right
@(NLINE*lstep),74 PRINT Field->LAST FONT ARIAL SIZE 10 BOLD  COLOR [255,0,150]
@(NLINE*lstep),108 MEMOSAY FIELD->BIO len 35 FONT ARIAL SIZE 10 BOLD        color red
@(NLINE*lstep),200 SAY trans(Field->INCOMING,format[1]) color ORANGE FONT ARIAL SIZE 10 BOLD align right
[FEET]4
@((eline+3)*lstep), 9 SAY if(last_pag,"Bye bye [End of DEMO]",[]) FONT ARIAL SIZE 16 BOLD ITALIC color red
SELECT BRUSH B0
if (npag = 1 )
   @ 225,88 BARCODE [http://hmgextended.com/] TYPE QRCODE HEIGHT 5 WIDTH .5 SUBTITLE
   @ 30,108 BARCODE 477012345678 TYPE EAN13 HEIGHT 10 WIDTH 0.5 SUBTITLE  internal
Endif
   @  225,20 BARCODE ABC123 TYPE CODE39 HEIGHT 5 WIDTH 0.5 SUBTITLE INTERNAL
   @  232,20 BARCODE ABC123 TYPE CODE39 HEIGHT 10 WIDTH 0.5 SUBTITLE FLAG HB_zebra_flag_checksum
   @  250,20 BARCODE ABC123 TYPE CODE39 HEIGHT 5 WIDTH 0.3 SUBTITLE FLAG [HB_zebra_flag_checksum + HB_ZEBRA_FLAG_WIDE2_5]
   @  270,20 BARCODE ABC123 TYPE CODE39 HEIGHT 5 WIDTH 0.5 SUBTITLE internal FLAG HB_zebra_flag_checksum+HB_ZEBRA_FLAG_WIDE3
*/
Endif

[END]
