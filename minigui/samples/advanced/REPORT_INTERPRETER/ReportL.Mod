//!HBPRINT
#Clienti.MOD This Line Will be ignored!
#case ncpl= 80    nfsize:=12
#case ncpl= 96    nfsize=10
#case ncpl= 120   nfsize:=8
#case ncpl= 140   nfsize:=7
#case ncpl= 160   nfsize:=6

[Declare]120/PREV
set units MM
set print margins top 0 left 4
set COLORMODE 0
SET CHARSET ANSI_CHARSET
SET OFFSET HBPCOMPATIBLE
SET JOB NAME [Barcode]
SET SPLASH TO ... Por favor espere ...    Labels en proceso

SET PRINT MARGINS TOP 0 LEFT 25

var C1 14 n
var Hr1 1 n
var C2 109 n
var cnt 0 N

SET TEXT ALIGN LEFT
MsgExclamation("This demo produces two colums of label"+Chr(10)+chr(13)+"20 labels for sheet on A4 paper!",oWr:prndrv+"-PRINT Barcode inside!")
[HEAD]1
35,75 say (oWr:prndrv+[-PRINT]) FONT ARIAL SIZE 18
[BODY]63
set debug off
set textcolor BLACK
if (int(cnt/2) == cnt/2)
   // la parte sinistra   /left side
   ((nline+2+hr1)*Lstep)   (C1)    SAY [Articolo:] FONT ARIAL SIZE 10 align left
   ((nline+2+hr1)*Lstep)   (C1+15) SAY ltrim(str(Field->CODE)) FONT ARIAL SIZE 10 align left
   ((nline+5.4+hr1)*Lstep) (C1+30) SAY [€.] FONT ARIAL SIZE 16 bold italic align left
*
   ((nline+1.5+hr1)*Lstep) (C1+28) BARCODE ltrim(str(Field->CODE)) TYPE CODE39 HEIGHT 5 WIDTH 0.5 SUBTITLE VSH 1
   //((nline+2.5+hr1)*Lstep) (C1+28) SAY ("*"+ltrim(str(Field->CODE))+"*") FONT [Free 3 of 9] size 25 align left
   //((nline+3.1+hr1)*Lstep) (C1+35) SAY ("*"+ltrim(str(Field->CODE))+"*") FONT ARIAL SIZE 8 align center
   ((nline+4+hr1)*Lstep)   (C1)    SAY Field->last FONT ARIAL SIZE 10 BOLD align left
   ((nline+5.4+hr1)*Lstep) (C1+35) SAY field->incoming FONT ARIAL SIZE 16 bold italic align left
else
*   // la parte destra    /right side
   ((nline+1+hr1)*Lstep)   (C2)    SAY [Articolo:] FONT ARIAL SIZE 10 align left
   ((nline+1+hr1)*Lstep)   (C2+15) SAY ltrim(str(Field->CODE)) FONT ARIAL SIZE 10 align left
   ((nline+4.4+hr1)*Lstep) (C2+30) SAY [€.] FONT ARIAL SIZE 16 bold italic align left
*
   ((nline+1.5)*Lstep) (C2+28) BARCODE ltrim(str(Field->CODE)) TYPE CODE39 HEIGHT 5 WIDTH 0.5 SUBTITLE  VSH 1
   //((nline+1.5+hr1)*Lstep) (C2+28) SAY ("*"+ltrim(str(Field->CODE))+"*") FONT [Free 3 of 9] size 25 align left
   //((nline+2.1+hr1)*Lstep) (C2+35) SAY ("*"+ltrim(str(Field->CODE))+"*") FONT ARIAL SIZE 8 align center
   ((nline+3+hr1)*Lstep)   (C2)    SAY Field->last FONT ARIAL SIZE 10 BOLD align left
   ((nline+4.4+hr1)*Lstep) (C2+35) SAY field->incoming FONT ARIAL SIZE 16 bold italic align left
   (nline:= nline +5)
Endif
(cnt ++)
set textcolor BLACK
[FEET]0
(cnt:=0)
[END]