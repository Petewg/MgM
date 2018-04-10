# Bolla.MOD This Linees Will be ignored!
# case ncpl= 80    nfsize:=12
# case ncpl= 96    nfsize=10
# case ncpl= 120   nfsize:=8
# case ncpl= 140   nfsize:=7
# case ncpl= 160   nfsize:=6

[Declare]80 /prev
SET JOB NAME [Documento di trasporto]
SET PAPERSIZE DMPAPER_A4
SET UNITS MM
VAR TEMPO [] c;(TEMPO:=time());(TEMPO += "Brutto")
dbSelect("Progrb")
SET ORIENTATION PORTRAIT  // SET ORIENTATION LANDSCAPE
SET OFFSET HBPCOMPATIBLE
SET PRINT MARGINS TOP 0 LEFT 5
SET PREVIEW ON ;SET COLORMODE 0
ENABLE THUMBNAILS;SET CHARSET ANSI_CHARSET
var HC1 22 n ; var Hr1 2 n ; var Hr1_1 2 n
var CB1 89 n ; var CB2 8 N;var CB3 20 n
var RB1 1 n ; var CBE 12 n;
var ADO 0 n  
var MAXROW 0 n ;var MAXCOL 0 n
VAR FC1 25 N ; VAR FR1 0 N

DEFINE PEN P1 STYLE PS_SOLID WIDTH 1 COLOR GREEN 
DEFINE PEN N1 STYLE PS_Solid WIDTH 10 COLOR BLACK
DEFINE BRUSH BP1 STYLE BS_HATCHED COLOR GREEN HATCH HS_CROSS
define brush b1 style BS_HATCHED color aqua hatch HS_DIAGCROSS
define brush b2 style BS_NULL


SELECT FONT F0
SELECT PEN P0
SET PREVIEW RECT 2 2 700 900
SET PREVIEW SCALE 1.5
SET SPLASH TO  ... Please wait ...    Work in Progress
(m->maxrow := HBPRN:MAXROW)
(m->maxcol := HBPRN:MAXCOL)
[HEAD]11
   # msgbox(maxrow)
// SET DEBUG On
SET TEXTCOLOR BLUE
//REMARKS The virgole or the spaces of separation have the same effect 
//{|| action } = codeblok for esclusion condition

{|| .not. progrb->fatturata } (16*lstep) 20 (20*lstep) 94 RECTANGLE pen p1 brush b1
{|| .not. progrb->fatturata },((nLine+17*lstep)),(15+CB2) SAY [Non Fatturata],FONT,[Courier New] SIZE 20 bold,align,left,color,red

{|| !progrb->fatturata } ((nLine+18*lstep)+2) (15+CB2) SAY [NOT INVOICED] FONT [Courier New] SIZE 20 bold align left color [0,0,255]

//DEBUG_ON
@ ((2+hr1)*lstep),(1+hc1) SAY what("clienti",alltrim(progrb->cliente),1,"RAG_SOC") FONT ARIAL SIZE 10 BOLD color black
@ ((3+hr1)*lstep),(1+hc1) SAY what("clienti",alltrim(progrb->cliente),1,"indirizzo") FONT ARIAL SIZE 10 BOLD
(HR1 :=IF (EMPTY(what("clienti",alltrim(progrb->cliente),1,"indirizzo")),HR1-1,HR1_1))
@ ((4+hr1)*lstep),(1+hc1) SAY what("clienti",alltrim(progrb->cliente),1,"CAP") FONT ARIAL SIZE 10 BOLD
//DEBUG_ON
((4+hr1)*lstep) (15+hc1) SAY (rtrim(what("clienti",alltrim(progrb->cliente),1,"Citta"))+[ ( ]+what("clienti",alltrim(progrb->cliente),1,"prov")+[ )]) FONT ARIAL SIZE 10
DEBUG_OFF
@ ((5+rb1)*lstep),(38+cb1) SAY [Your City, ] FONT ARIAL SIZE 10 align left
@ ((5+rb1)*lstep),(56+cb1) SAY DTOC(progrb->GENERATO) FONT ARIAL SIZE 10 BOLD
@ ((7+rb1)*lstep),23 say [Notes of month ] FONT ARIAL SIZE 12 bold
SET TEXTCHAR EXTRA 5
@ ((7+rb1)*lstep),134 SAY cmonth(progrb->generato-29) FONT ARIAL SIZE 12 bold align left
SET TEXTCHAR EXTRA 0
@ (290),(maxcol-30) say if( mx_pg > 0,"Pagina "+ltrim(str(npag))+" di "+ltrim(str(Tpg)),[]) FONT ARIAL SIZE 12 align rigth
*/
@ (2*lstep+hr1),(maxcol-28) say "Npag "+ltrim(str(npag)) FONT ARIAL SIZE 12 align rigth
@ (3*lstep+hr1),(maxcol-28) say "Mx_pg "+ltrim(str(MX_pg)) FONT ARIAL SIZE 12 align rigth
@ (4*lstep+hr1),(maxcol-28) say "Npgr "+ltrim(str(nPgr))+" di "+ltrim(str(mx_pg)) FONT ARIAL SIZE 12 align rigth
*@ (1+hr1),(maxcol-18) say if( mx_pg > 0,"Pagina "+ltrim(str(npag))+" di "+ltrim(str(Tpg)),"*"+ltrim(str(npag))+"*") FONT ARIAL SIZE 12 align rigth
@ ((8+rb1)*lstep),(75+CB2+CBE) say [  Quantita'   Importo Unitario] FONT ARIAL SIZE 10
@ ((8+rb1)*lstep),(150+CB2+CBE+CB3)  say [Dare] FONT ARIAL SIZE 10 align right
SELECT PEN P1
# 5 (maxcol) LINETO 
SET TEXT ALIGN LEFT
[BODY]3
// In this area you can usa ONLY ONE codeblok for esclusion condition {|| action }
SET TEXTCOLOR BLACK
(ado += field->importo_t)
@ (nLine*lstep) (15+CB2) SAY Field->Des_causa FONT ARIAL SIZE 10 align left
@ (nLine*lstep) (100+CB2) SAY trans(Field->NUMERO,"@ze 9,999") FONT ARIAL SIZE 10 align right
@ (nLine*lstep) (95+CB2+CBE) SAY [€ .] FONT ARIAL SIZE 10 align left
@ (nLine*lstep) (129+CB2) SAY trans(Field->Importo_u,"@ze 999,999.99") FONT ARIAL SIZE 10 align right
@ (nLine*lstep) (130+CB2+CBE) SAY if(!empty(Field->Des_causa),[€ .],[]) FONT ARIAL SIZE 10 align left
@ (nLine*lstep) (150+CB2+CB3+CBE) SAY trans(Field->Importo_t,"@ze 999,999.99") FONT ARIAL SIZE 10 bold align right
set textcolor 0  //Egual to SET TEXTCOLOR BLACK
[FEET]15
(nLine*lstep) 21 (m->(nLine*lstep)) (m->maxcol-10) LINE pen n1
SET TEXTCHAR EXTRA 2.5
@ (290*0.8),25 SAY [HbPrn DEMO] FONT ARIAL SIZE 78 angle 45 color CYAN
@ (290*0.9),38 SAY [By Report ] FONT ARIAL SIZE 78 angle 45 color Gold
@ (280),20 SAY [Interpreter] FONT ARIAL SIZE 78 bold strikeout UNDERLINE angle 0 color Gold
// SET TEXTCOLOR BLACK
SET TEXTCHAR EXTRA 0
{|| progrb->fatturata} ((nLine+1)*lstep),(15+CB2) SAY if(last_pag,if (progrb->fatturata,[Legge 414 del 31.12.1991 maggiorazione],[]),[Segue sul foglio N  ]+ltrim(str(npgr+1))+[ continue to sheet N  ]+ltrim(str(npgr+1))) FONT ARIAL SIZE 10 align left color black
{|| progrb->fatturata} ((nLine+2)*lstep),(15+CB2) SAY if(last_pag,[del   ]+TRANS(progrb->cassa_rag,"@ze 999")+[ % su € .],[]) FONT ARIAL SIZE 10 align left
{|| progrb->fatturata} ((nLine+2)*lstep),(63+CB2) SAY if(last_pag,[pari a],[]) FONT ARIAL SIZE 10 align left
{|| progrb->fatturata} ((nLine+2)*lstep),(59+CB2) SAY if(last_pag,trans(m->ado,"@ez 999,999.99"),[]) FONT ARIAL SIZE 10 bold align right
{|| progrb->fatturata} ((nLine+2)*lstep),(130+CB2+CBE) SAY if(last_pag,[€ .],[]) FONT ARIAL SIZE 10 align left
{|| progrb->fatturata} ((nLine+2)*lstep),(150+CB2+CB3+CBE) SAY if(last_pag,trans(progrb->tot_cassa,"@ze 999,999.99"),[]) FONT ARIAL SIZE 10 bold align right
{|| progrb->fatturata} ((nLine+3)*lstep),(130+CB2+CBE) ((nLine+3)*lstep) (150+CB2+CB3+CBE) LINE pen n1
{|| progrb->fatturata} ((nLine+4)*lstep),(130+CB2+CBE) SAY if(last_pag,[€ .],[]) FONT ARIAL SIZE 10 align left
{|| progrb->fatturata} ((nLine+4)*lstep),(150+CB2+CB3+CBE) SAY if(last_pag,trans(progrb->tot_cassa+M->ADO,"@ze 999,999.99"),[]) FONT ARIAL SIZE 10 bold align right
*DEBUG_on
{|| progrb->fatturata} @ ((nLine+5)*lstep),(15+CB2) SAY if(last_pag,[TVA ]+TRANS(progrb->cOD_IVA,"@ze 999")+ [ % on € .],[]) FONT ARIAL SIZE 10 align left
DEBUG_off
{|| progrb->fatturata} ((nLine+5)*lstep),(63+CB2) SAY if(last_pag,[pari a],[]) FONT ARIAL SIZE 10 align left
{|| progrb->fatturata} ((nLine+5)*lstep),(59+CB2) say if(last_pag,trans(progrb->tot_cassa+M->ADO,"@ze 999,999.99"),[]) FONT ARIAL SIZE 10 bold align right
{|| progrb->fatturata} ((nLine+5)*lstep),(130+CB2+CBE) SAY if(last_pag,[€ .],[]) FONT ARIAL SIZE 10 align left
{|| progrb->fatturata} ((nLine+5)*lstep),(150+CB2+CB3+CBE) SAY if(last_pag,trans(progrb->tot_iva,"@ze 999,999.99"),[]) FONT ARIAL SIZE 10 bold align right
{|| progrb->fatturata} ((nLine+6)*lstep),(130+CB2+CBE) ((nLine+6)*lstep) (150+CB2+CB3+CBE) LINE pen n1
{|| progrb->fatturata} ((nLine+7)*lstep),(130+CB2+CBE) SAY if(last_pag,[€ .],[]) FONT ARIAL SIZE 10 align left
{|| progrb->fatturata} ((nLine+7)*lstep),(150+CB2+CB3+CBE) SAY if(last_pag,trans(progrb->tot_iva+progrb->tot_cassa+m->ado,"@ze 999,999.99"),[]) FONT ARIAL SIZE 10 bold align right
{|| progrb->fatturata} ((nLine+8)*lstep),(15+CB2) SAY if(last_pag,[R.A.]+ltrim(str(progrb->cod_iva,0))+[ % su € .],[]) FONT ARIAL SIZE 10 align left
{|| progrb->fatturata} ((nLine+8)*lstep),(63+CB2) SAY if(last_pag,[pari a],[]) FONT ARIAL SIZE 10 align left
{|| progrb->fatturata} ((nLine+8)*lstep),(59+CB2) SAY if(last_pag,trans(m->ado,"@ez 999,999.99"),[]) FONT ARIAL SIZE 10 bold align right
{|| progrb->fatturata} ((nLine+8)*lstep),(130+CB2+CBE) SAY if(last_pag,[€ .],[]) FONT ARIAL SIZE 10 align left
{|| progrb->fatturata} ((nLine+8)*lstep),(150+CB2+CB3+CBE) SAY if(last_pag,trans(progrb->ritenuta,"@ze -999,999.99"),[]) FONT ARIAL SIZE 10 bold align right

@ ((nLine+9)*lstep) (55+cb1) ((nLine+11.5)*lstep) (104+cb1) ROUNDRECT ROUNDR 10 ROUNDC 10 brush b2 pen N1

@ ((nLine+10)*lstep) (70-cb2-cbe-cb3) SAY if(last_pag,[TOTALE],[]) FONT ARIAL SIZE 10 bold align rigth color black
@ ((nLine+10)*lstep) (130+CB2+CBE) SAY if(last_pag,[€ .],[]) FONT [TIMES NEW ROMAN] SIZE 16 BOLD align left
@ ((nLine+10)*lstep) (150+CB2+CB3+CBE) SAY if(last_pag,trans(if(progrb->fatturata,progrb->IMPORTO,m->ado),"@ze 999,999.99"),[]) FONT [TIMES NEW ROMAN] SIZE 16 BOLD align right

@ ((nLine+12+FR1)*lstep) (1+FC1) SAY if(last_pag,[Remark: You can change the number of generated pages changing the value ],[]) FONT ARIAL SIZE 10 bold align LEFT
@ ((nLine+14+FR1)*lstep) (7+FC1) SAY if(last_pag,"of necessary lines in the section [ Body ] -> Number <-  Ie: [BODY]5",[]) FONT ARIAL SIZE 10 bold align LEFT
@ ((nLine+16+FR1)*lstep) (1+FC1) SAY "+ and - in the numerical keyboard act on the zoom with hbprinter " FONT ARIAL SIZE 14 bold align LEFT
(ado := if(last_pag,0,ado))

#############################################################################################
# If(last_pag,msgbox("End elaboration: Now you can see a preview!",[End Test2]+str(nline)),[])
#############################################################################################
[END]
