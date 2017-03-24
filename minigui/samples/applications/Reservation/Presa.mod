!MINIPRINT
[Declare]80/PREV/sele
SET JOB NAME [Elenco prenotazioni]
SET PAPERSIZE DMPAPER_A4
SET CHARSET ANSI_CHARSET
set euro 1;set money 0;set separator ON
DEFINE BRUSH BP1 STYLE BS_HATCHED COLOR LAVENDER HATCH HS_CROSS
SELECT FONT F0
SET ORIENTATION Portrait
SET UNITS MM
set debug off
(SET( 11 , !ofatt:listdelete ))
var TC 0 n

[HEAD]7
@(2*lstep),12 SAY [Pag.] ;(2*lstep) 20 SAY trans(m->npag,[999])
@6,30 PRINT IMAGE img\farfalla.png HEIGHT 10 WIDTH 10 STRETCH TRANSPARENT
@(1*lstep)+3,178 SAY date() font [COURIER NEW] SIZE 10 BOLD align CENTER
@(2*lstep)+3,178 SAY Time() FONT [COURIER NEW] SIZE 10 BOLD align CENTER

@(4*lstep),11 PRINT LINE TO (4*lstep),200 PENWIDTH .1
if (alng = 1)
   @(1*lstep)+3,105 SAY [REPORT BOOKINGS] FONT ARIAL SIZE 16 BOLD ITALIC align center
   @(4*lstep)+3,13 SAY [Date    Resource From  To   Event                             By] font [COURIER NEW] SIZE 10 BOLD
else
   @(1*lstep)+3,105 SAY [ELENCO PRENOTAZIONI] FONT ARIAL SIZE 16 BOLD ITALIC align center
   @(4*lstep)+3,13 SAY [In data  Risorsa Dalle Alle Motivo                            Da] font [COURIER NEW] SIZE 10 BOLD
Endif
if (ofatt:listdelete)
   @(4*lstep),175 SAY IF(ALNG=1,[Erased ],[Cancellato]) font [COURIER NEW] SIZE 10 BOLD
Endif
@(5*lstep),11 PRINT LINE TO (5*lstep),200 PENWIDTH .1
SET TEXT ALIGN LEFT
set backcolor white
[BODY]60
set debug off
(tc ++ )
if (deleted() .and. ofatt:listdelete .and. day(Field->data_canc)>0)
   @((nline*lstep)),10 PRINT RECTANGLE TO  ((nline+1)*lstep ),(200 ) PENWIDTH .1
Endif
if (ofatt:listdelete)
   @(NLINE*lstep),180 SAY if(day(Field->data_canc)>0,Field->data_canc,[]) FONT [COURIER NEW] SIZE 8 BOLD
Endif
@(NLINE*lstep),12 SAY Field->data_in FONT [COURIER NEW] SIZE 8 BOLD align left COLOR BLUE
@(NLINE*lstep),32 SAY (arisorse[alng,val(Field->resource)]) FONT [COURIER NEW] SIZE 8 BOLD
@(NLINE*lstep),49 SAY Field->time_in FONT [COURIER NEW] SIZE 8 BOLD COLOR GREEN
@(NLINE*lstep),62 SAY Field->time_out FONT [COURIER NEW] SIZE 8 BOLD COLOR RED
@(NLINE*lstep),72 SAY left(Field->motivo,42) FONT [COURIER NEW] SIZE 8 BOLD
@(NLINE*lstep),145 SAY Field->da FONT [COURIER NEW] SIZE 8 BOLD
set debug oFF
[FEET]4 
// set debug on
@(eline*lstep),11 PRINT LINE TO (eline*lstep),200 PENWIDTH .1
if (alng = 1)
   @((eline+1)*lstep), 11 SAY if(last_pag,"End of List,",[]) FONT ARIAL SIZE 10 BOLD ITALIC
   @((eline+1)*lstep), 32 SAY if(last_pag,"with selection from "+trim(DtoW(m->a_res[1]))+" to "+Dtow(m->a_res[2]),[]) FONT ARIAL SIZE 10 BOLD ITALIC
   @((eline+1)*lstep), 160 SAY "Total bookings: "+ltrim(str(tc)) FONT ARIAL SIZE 10 BOLD ITALIC
else
   @((eline+1)*lstep), 11 SAY if(last_pag,"Fine Listato,",[]) FONT ARIAL SIZE 10 BOLD ITALIC
   @((eline+1)*lstep), 32 SAY if(last_pag,"con selezione dal "+trim(DtoW(m->a_res[1]))+" al "+Dtow(m->a_res[2]),[]) FONT ARIAL SIZE 10 BOLD ITALIC
   @((eline+1)*lstep), 160 SAY "Totale prenotazioni: "+ltrim(str(tc)) FONT ARIAL SIZE 10 BOLD ITALIC
Endif
set debug off
[END]
