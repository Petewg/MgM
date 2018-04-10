FUNCTION DiaFiesta(DFesta)
   LOCAL DFesta2, FPascua:=DomingoPascua(YEAR(DFesta))
   IF DAY(DFesta)=1  .AND. MONTH(DFesta)=1  .OR. ;
      DAY(DFesta)=6  .AND. MONTH(DFesta)=1  .OR. ;
      DAY(DFesta)=19 .AND. MONTH(DFesta)=3  .OR. ;
      DAY(DFesta)=1  .AND. MONTH(DFesta)=5  .OR. ;
      DAY(DFesta)=6  .AND. MONTH(DFesta)=8  .OR. ; //fiesta aldaia
      DAY(DFesta)=15 .AND. MONTH(DFesta)=8  .OR. ;
      DAY(DFesta)=9  .AND. MONTH(DFesta)=10 .OR. ;
      DAY(DFesta)=12 .AND. MONTH(DFesta)=10 .OR. ;
      DAY(DFesta)=1  .AND. MONTH(DFesta)=11 .OR. ;
      DAY(DFesta)=6  .AND. MONTH(DFesta)=12 .OR. ;
      DAY(DFesta)=8  .AND. MONTH(DFesta)=12 .OR. ;
      DAY(DFesta)=25 .AND. MONTH(DFesta)=12 .OR. ;
      DFesta=FPascua-2 .OR. ; //Viernes Santo
      DFesta=FPascua+1 .OR. ; //Lunes de Pascua
      DFesta=FPascua+8 .OR. ; //2º Lunes de Pascua
      DAY(DFesta)=24 .AND. MONTH(DFesta)=3 .AND. YEAR(DFesta)=2005 .OR. ; //Jueves Santo
      DAY(DFesta)=2  .AND. MONTH(DFesta)=5 .AND. YEAR(DFesta)=2005 .OR. ; //Dia del trabajador
      DAY(DFesta)=17 .AND. MONTH(DFesta)=3 .AND. YEAR(DFesta)=2006 .OR. ; //fiesta aldaia
      DAY(DFesta)=13 .AND. MONTH(DFesta)=4 .AND. YEAR(DFesta)=2006 .OR. ; //Jueves Santo
      DAY(DFesta)=20 .AND. MONTH(DFesta)=3 .AND. YEAR(DFesta)=2008        //Jueves Santo
      DFesta2:=.T.
   ELSE
      DFesta2:=.F.
   ENDIF
RETURN(DFesta2)

FUNCTION DIASLABORALES(xFDIA1,xFDIA2)
   LOCAL xDIA1:=MAX(xFDIA1,xFDIA2)-MIN(xFDIA1,xFDIA2)
   LOCAL N, xDIA2:=0
   xFDIA1:=MIN(xFDIA1,xFDIA2)
   IF xDIA1>0
      FOR N=0 TO xDIA1
         IF DIAFIESTA(xFDIA1+N)<>.T. .AND. UPPER(DIANOM(xFDIA1+N))<>"SABADO" .AND. UPPER(DIANOM(xFDIA1+N))<>"DOMINGO"
            xDIA2++
         ENDIF
      NEXT
   ENDIF
RETURN(xDIA2)

FUNCTION DomingoPascua(a)
LOCAL b:=a-1900
LOCAL c:=b % 19
LOCAL d:=INT((7*c+1)/19)
LOCAL e:=(11*c-d+4) % 29
LOCAL f:=INT(b/4)
LOCAL g:=(b+f-e+31) % 7
LOCAL FPASCUA:=CTOD("31-03-"+STR(a,4))+25-g-e
RETURN(FPASCUA)
