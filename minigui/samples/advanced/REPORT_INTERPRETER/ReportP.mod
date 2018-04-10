!PDFPRINT
# REPORTS.MOD This Line Will be ignored!
[Declare]80/PREV
VAR PIZZA C ''
VAR PLT C []
VAR PLT1 C []
VAR PLT2 C []
(PLT := [This is a small paragraph to be printed inside a rectangular area left aligned.])
(m->pizza := "Pdf" )
SET SPLASH TO
SET DEBUG OFF
SET UNITS MM
SET PAPERSIZE DMPAPER_A4
SET JOB NAME [TestHaru]
SET OFFSET HBPCOMPATIBLE 3.5
SET HPDFDOC COMPRESS ALL
SET HPDFDOC PAGENUMBERING FROM 1 STYLE LETTERS PREFIX "Page: "
//SET HPDFDOC PASSWORD OWNER [Pierpaolo] USER [TEST]
SET HPDFDOC PAGEMODE TO OUTLINE
SET HPDFINFO DATECREATED TO [01-01-2013] TIME [19:00:00]
SET HPDFINFO AUTHOR TO [Pierpaolo Martinello]
SET HPDFINFO CREATOR TO [Pierpaolo Martinello]
SET HPDFINFO TITLE   TO [Report interpreter Pdf export]
SET HPDFINFO SUBJECT TO [A Test of pdf creation with Report Interpreter]
SET HPDFINFO KEYWORDS TO [HMG, HPDF, Documentation, LibHaru, Harbour, MiniGUI]

set euro 1;set money 1;set separator ON
(aadd(format,ed_g_pic(Field->incoming)))
set money 0

[HEAD]8

@(1*lstep),12 SAY [Pag.] FONT ARIAL SIZE 10 BOLD ;(1*lstep) 25 SAY trans(m->npag,[999]) FONT ARIAL SIZE 10
@8,14 picture ROSA.JPG size 18 17
@(1*lstep+3),105 SAY [INFORME DE ARTISTAS DE CINE] FONT ARIAL SIZE 16 BOLD ITALIC align center
@(1*lstep),178 SAY date() font [COURIER NEW] SIZE 10 BOLD align CENTER
@(2*lstep),178 SAY Time() FONT [COURIER NEW] SIZE 10 BOLD align CENTER
@(2*lstep+4),105 SAY [Segundo titulo] FONT ARIAL SIZE 16 BOLD ITALIC align center
SET DEBUG OFF
@(4*lstep),11,(4*lstep),203 LINE
SET DEBUG OFF
@ (4*lstep),11 PRINT LINE TO (4*lstep), 203 PENWIDTH 0.1 
@(5*lstep),25 SAY [SIMPLE                                    APELLIDO                 DOBLE] font [Helvetica] SIZE 10 BOLD
@(5*lstep),200 SAY [INGRESOS] font [Helvetica] SIZE 10 BOLD right
@(5*lstep),42 SAY (Pizza) font [COURIER NEW] SIZE 20 BOLD
@(6*lstep),11 ,(6*lstep),203 LINE
@(52*lstep ),130,( ((maxRow)-1 ) ),(maxcol) RECTANGLE pen p1 ;// brush bp1
@(55*lstep),133 PRINT [Report Interpreter] FONT [COURIER NEW] SIZE 16 BOLD
@(58*lstep),135 SAY [Generation  IV ] FONT [times] SIZE 16 BOLD UNDERLINE color lightsalmon
[BODY]40

@(NLINE*lstep),21 SAY Field->first FONT ARIAL SIZE 10 BOLD align left COLOR BLUE
@(NLINE*lstep),71 SAY Field->code FONT ARIAL SIZE 10 BOLD COLOR [255,0,150] align right
@(NLINE*lstep),74 PRINT Field->LAST FONT ARIAL SIZE 10 BOLD
@(NLINE*lstep),108 MEMOSAY FIELD->BIO len 35 FONT ARIAL SIZE 10 BOLD        color red
@(NLINE*lstep),200 SAY trans(Field->INCOMING,format[1]) color ORANGE FONT ARIAL SIZE 10 BOLD align right

[FEET]4
 @((eline+3)*lstep), 9 SAY if(last_pag,"Bye bye [End of DEMO]",[]) FONT ARIAL SIZE 16 BOLD ITALIC color red
[END]
