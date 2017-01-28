# Bolla.MOD This Linees Will be ignored!
# case ncpl= 80    nfsize:=12
# case ncpl= 96    nfsize=10
# case ncpl= 120   nfsize:=8
# case ncpl= 140   nfsize:=7
# case ncpl= 160   nfsize:=6

[Declare]80 /sele
SET JOB NAME [Documento di trasporto]
SET PAPERSIZE DMPAPER_A4
VAR TEMPO [] c;(TEMPO:=time());(TEMPO += "Brutto")
dbSelect("Progrb")
SET ORIENTATION PORTRAIT  // SET ORIENTATION LANDSCAPE 
SET PRINT MARGINS TOP 0 LEFT 5
SET PREVIEW ON ;SET COLORMODE 0
ENABLE THUMBNAILS;SET CHARSET ANSI_CHARSET
var HC1 2 n ; var Hr1 2 n ; var Hr1_1 2 n
var CB1 5 n ; var CB2 -12 N;var CB3 2 n
var RB1 1 n ; var CBE 12 n;
var ADO 0 n  
var MAXROW 0 n ;var MAXCOL 0 n
VAR FC1 2 N ; VAR FR1 0 N

DEFINE PEN P1 STYLE PS_SOLID WIDTH 1 COLOR GREEN 
DEFINE PEN N1 STYLE PS_Solid WIDTH 8 COLOR BLACK
DEFINE BRUSH BP1 STYLE BS_HATCHED COLOR GREEN HATCH HS_CROSS
define brush b1 style BS_HATCHED color aqua hatch HS_DIAGCROSS

SELECT FONT F0
SELECT PEN P0
SET PREVIEW RECT 2 2 700 900
SET PREVIEW SCALE 1.5
SET SPLASH TO  ... Please wait ...    Work in Progress
(maxrow := HBPRN:MAXROW)
(maxcol := HBPRN:MAXCOL)
[HEAD]11
SET TEXTCOLOR BLUE
//REMARKS The virgole or the spaces of separation have the same effect 
//{|| action } = codeblok for esclusion condition

{|| .not. progrb->fatturata } 16 2 20 30 RECTANGLE pen p1 brush b1
{|| .not. progrb->fatturata },(NLINE+17),(15+CB2) SAY [Non Fatturata],FONT,[Courier New] SIZE 20 bold,align,left,color,red

{|| !progrb->fatturata } (NLINE+18) (15+CB2) SAY [NOT INVOICED] FONT [Courier New] SIZE 20 bold align left color [0,0,255]  //Egual to BLUE

*@ (1+hr1),(1+hc1) SAY [Spett.le Ditta] font A8

@ (2+hr1),(1+hc1) SAY what("clienti",alltrim(progrb->cliente),1,"RAG_SOC") FONT ARIAL SIZE 10 BOLD color black
@ (3+hr1),(1+hc1) SAY what("clienti",alltrim(progrb->cliente),1,"indirizzo") FONT ARIAL SIZE 10 BOLD
(HR1 :=IF (EMPTY(what("clienti",alltrim(progrb->cliente),1,"indirizzo")),HR1-1,HR1_1))
@ (4+hr1),(1+hc1) SAY what("clienti",alltrim(progrb->cliente),1,"CAP") FONT ARIAL SIZE 10 BOLD
//DEBUG_ON
(4+hr1) (7+hc1) SAY (rtrim(what("clienti",alltrim(progrb->cliente),1,"Citta"))+[ (]+what("clienti",alltrim(progrb->cliente),1,"prov")+[ )]) FONT ARIAL SIZE 10
//DEBUG_OFF       
@ (5+rb1),(38+cb1) SAY [Your City, ] FONT ARIAL SIZE 10 align left
@ (5+rb1),(45+cb1) SAY DTOC(progrb->GENERATO) FONT ARIAL SIZE 10 BOLD
@ (7+rb1),3 say [Notes of month ] FONT ARIAL SIZE 12 bold
SET TEXTCHAR EXTRA 2
@ (7+rb1),46 SAY cmonth(progrb->generato-29) FONT ARIAL SIZE 12 bold align left
SET TEXTCHAR EXTRA 0
@ (maxrow-1),(maxcol-19) say if( mx_pg > 0,"Pagina "+ltrim(str(npag))+" di "+ltrim(str(Tpg)),[]) FONT ARIAL SIZE 12 align rigth
*/
@ (1+hr1),(maxcol-18) say "Npag "+ltrim(str(npag)) FONT ARIAL SIZE 12 align rigth
@ (2+hr1),(maxcol-18) say "Mx_pg "+ltrim(str(MX_pg)) FONT ARIAL SIZE 12 align rigth
@ (3+hr1),(maxcol-18) say "Npgr "+ltrim(str(nPgr))+" di "+ltrim(str(mx_pg)) FONT ARIAL SIZE 12 align rigth
*@ (1+hr1),(maxcol-18) say if( mx_pg > 0,"Pagina "+ltrim(str(npag))+" di "+ltrim(str(Tpg)),"*"+ltrim(str(npag))+"*") FONT ARIAL SIZE 12 align rigth
@ (8+rb1),(30+CB2+CBE) say [  Quantità   Importo Unitario] FONT ARIAL SIZE 10
@ (8+rb1),(60+CB2+CBE+CB3)  say [Dare] FONT ARIAL SIZE 10 align right
SELECT PEN P1
# 5 (maxcol) LINETO 
#(flob:=20)
SET TEXT ALIGN LEFT
[BODY]3
// In this area you can usa ONLY ONE codeblok for esclusion condition {|| action }
SET TEXTCOLOR BLACK
(ado += field->importo_t)
@(NLINE) (15+CB2) SAY Field->Des_causa FONT ARIAL SIZE 10 align left
@ NLINE (47+CB2) SAY trans(Field->NUMERO,"@ze 9,999") FONT ARIAL SIZE 10 align right
@ NLINE (38+CB2+CBE) SAY [€ .] FONT ARIAL SIZE 10 align left
@ NLINE (59+CB2) SAY trans(Field->Importo_u,"@ze 999,999.99") FONT ARIAL SIZE 10 align right
@ NLINE (50+CB2+CBE) SAY if(!empty(Field->Des_causa),[€ .],[]) FONT ARIAL SIZE 10 align left
@ NLINE (60+CB2+CB3+CBE) SAY trans(Field->Importo_t,"@ze 999,999.99") FONT ARIAL SIZE 10 bold align right
set textcolor 0  //Egual to SET TEXTCOLOR BLACK
[FEET]15
(m->nline) 2 (m->nline) (m->maxcol-10) LINE pen n1
SET TEXTCHAR EXTRA 2.5
@ (maxrow*0.8),5 SAY [HbPrn DEMO] FONT ARIAL SIZE 78 angle 45 color CYAN
@ (maxrow*0.9),8 SAY [By Report ] FONT ARIAL SIZE 78 angle 45 color Gold
@ (maxrow),12 SAY [Interpreter] FONT ARIAL SIZE 78 bold underline angle 45 color Gold
// SET TEXTCOLOR BLACK
SET TEXTCHAR EXTRA 0
{|| progrb->fatturata} (NLINE+1),(15+CB2) SAY if(last_pag,if (progrb->fatturata,[Legge 414 del 31.12.1991 maggiorazione],[]),[Segue sul foglio N° ]+ltrim(str(npgr+1))+[ continue to sheet N° ]+ltrim(str(npgr+1))) FONT ARIAL SIZE 10 align left color black
{|| progrb->fatturata} (NLINE+2),(15+CB2) SAY if(last_pag,[del   ]+TRANS(progrb->cassa_rag,"@ze 999")+[ % su € .],[]) FONT ARIAL SIZE 10 align left
{|| progrb->fatturata} (NLINE+2),(34+CB2) SAY if(last_pag,[pari a],[]) FONT ARIAL SIZE 10 align left
{|| progrb->fatturata} (NLINE+2),(32+CB2) SAY if(last_pag,trans(m->ado,"@ez 999,999.99"),[]) FONT ARIAL SIZE 10 bold align right
{|| progrb->fatturata} (NLINE+2),(50+CB2+CBE) SAY if(last_pag,[€ .],[]) FONT ARIAL SIZE 10 align left
{|| progrb->fatturata} (NLINE+2),(60+CB2+CB3+CBE) SAY if(last_pag,trans(progrb->tot_cassa,"@ze 999,999.99"),[]) FONT ARIAL SIZE 10 bold align right
{|| progrb->fatturata} (NLINE+3),(50+CB2+CBE) (NLINE+3) (60+CB2+CB3+CBE) LINE pen n1
{|| progrb->fatturata} (NLINE+4),(50+CB2+CBE) SAY if(last_pag,[€ .],[]) FONT ARIAL SIZE 10 align left
{|| progrb->fatturata} (NLINE+4),(60+CB2+CB3+CBE) SAY if(last_pag,trans(progrb->tot_cassa+M->ADO,"@ze 999,999.99"),[]) FONT ARIAL SIZE 10 bold align right
*DEBUG_on
{|| progrb->fatturata} @ (NLINE+5),(15+CB2) SAY if(last_pag,[TVA ]+TRANS(progrb->cOD_IVA,"@ze 999")+ [ % on € .],[]) FONT ARIAL SIZE 10 align left
DEBUG_off
{|| progrb->fatturata} (NLINE+5),(34+CB2) SAY if(last_pag,[pari a],[]) FONT ARIAL SIZE 10 align left
{|| progrb->fatturata} (NLINE+5),(32+CB2) say if(last_pag,trans(progrb->tot_cassa+M->ADO,"@ze 999,999.99"),[]) FONT ARIAL SIZE 10 bold align right
{|| progrb->fatturata} (NLINE+5),(50+CB2+CBE) SAY if(last_pag,[€ .],[]) FONT ARIAL SIZE 10 align left
{|| progrb->fatturata} (NLINE+5),(60+CB2+CB3+CBE) SAY if(last_pag,trans(progrb->tot_iva,"@ze 999,999.99"),[]) FONT ARIAL SIZE 10 bold align right
{|| progrb->fatturata} (NLINE+6),(50+CB2+CBE) (NLINE+6) (60+CB2+CB3+CBE) LINE pen n1
{|| progrb->fatturata} (NLINE+7),(50+CB2+CBE) SAY if(last_pag,[€ .],[]) FONT ARIAL SIZE 10 align left
{|| progrb->fatturata} (NLINE+7),(60+CB2+CB3+CBE) SAY if(last_pag,trans(progrb->tot_iva+progrb->tot_cassa+m->ado,"@ze 999,999.99"),[]) FONT ARIAL SIZE 10 bold align right
{|| progrb->fatturata} (NLINE+8),(15+CB2) SAY if(last_pag,[R.A.]+ltrim(str(progrb->cod_iva,0))+[ % su € .],[]) FONT ARIAL SIZE 10 align left
{|| progrb->fatturata} (NLINE+8),(34+CB2) SAY if(last_pag,[pari a],[]) FONT ARIAL SIZE 10 align left
{|| progrb->fatturata} (NLINE+8),(32+CB2) SAY if(last_pag,trans(m->ado,"@ez 999,999.99"),[]) FONT ARIAL SIZE 10 bold align right
{|| progrb->fatturata} (NLINE+8),(50+CB2+CBE) SAY if(last_pag,[€ .],[]) FONT ARIAL SIZE 10 align left
{|| progrb->fatturata} (NLINE+8),(60+CB2+CB3+CBE) SAY if(last_pag,trans(progrb->ritenuta,"@ze -999,999.99"),[]) FONT ARIAL SIZE 10 bold align right

@ (NLINE+9) (48+CB2+CBE) picture Sfondo.bmp SIZE 3 (13+CB3) Extend 3 (13+CB3)
@ (NLINE+10) (35-cb2-cbe-cb3) SAY if(last_pag,[TOTALE],[]) FONT ARIAL SIZE 10 bold align rigth color black
@ (NLINE+10) (50+CB2+CBE) SAY if(last_pag,[€ .],[]) FONT [TIMES NEW ROMAN] SIZE 16 BOLD align left
@ (NLINE+10) (60+CB2+CB3+CBE) SAY if(last_pag,trans(if(progrb->fatturata,progrb->IMPORTO,m->ado),"@ze 999,999.99"),[]) FONT [TIMES NEW ROMAN] SIZE 16 BOLD align right

@ (NLINE+12+FR1) (1+FC1) SAY if(last_pag,[Remark: You can change the number of generated pages changing the value ],[]) FONT ARIAL SIZE 10 bold align LEFT
@ (NLINE+14+FR1) (7+FC1) SAY if(last_pag,"of necessary lines in the section [ Body ] -> Number <-  Ie: [BODY]5",[]) FONT ARIAL SIZE 10 bold align LEFT
@ (NLINE+16+FR1) (1+FC1) SAY "+ and - in the numerical keyboard act on the zoom " FONT ARIAL SIZE 16 bold align LEFT
(ado := if(last_pag,0,ado))

#############################################################################################
# If(last_pag,msgbox("End elaboration: Now you can see a preview!",[End Test2]+str(nline)),[])
#############################################################################################
[END]
