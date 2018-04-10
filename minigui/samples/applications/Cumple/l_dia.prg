FUNCTION DIA(FDIA1,LONG1)
LOCAL FDIA2:=""
LONG1:=IF(LONG1=NIL, 10 ,LONG1)
   IF VALTYPE(FDIA1)<>"D"
      FDIA2=PADR(VALTYPE(FDIA1),LONG1," ")
      RETURN(FDIA2)
   ENDIF
   IF VALTYPE(LONG1)<>"N"
      FDIA2=PADR(VALTYPE(LONG1),LONG1," ")
      RETURN(FDIA2)
   ENDIF
   DO CASE
   CASE FDIA1=CTOD("  -  -  ")
      IF LONG1<0
         FDIA2=SPACE(LONG1*-1)
      ELSE
         FDIA2=SPACE(LONG1)
      ENDIF
   CASE LONG1=5  //31-01
      FDIA2=STRZERO(DAY(FDIA1),2)
      FDIA2=FDIA2+"-"
      FDIA2=FDIA2+STRZERO(MONTH(FDIA1),2)
   CASE LONG1=6  //31-ENE
      FDIA2=STRZERO(DAY(FDIA1),2)
      FDIA2=FDIA2+"-"
      FDIA2=FDIA2+RTRIM(MESNOM(FDIA1,3))
   CASE LONG1=-10 //LUN,31-ENE
      FDIA2=LEFT(RTRIM(DIANOM(FDIA1)),3)
      FDIA2=FDIA2+","
      FDIA2=FDIA2+STRZERO(DAY(FDIA1),2)
      FDIA2=FDIA2+"-"
      FDIA2=FDIA2+RTRIM(MESNOM(FDIA1,3))
   CASE LONG1=8  //31-01-92
      FDIA2=STRZERO(DAY(FDIA1),2)
      FDIA2=FDIA2+"-"
      FDIA2=FDIA2+STRZERO(MONTH(FDIA1),2)
      FDIA2=FDIA2+"-"
      FDIA2=FDIA2+RIGHT(STRZERO(YEAR(FDIA1),4),2)
   CASE LONG1=9  //31-ENE-92
      FDIA2=STRZERO(DAY(FDIA1),2)
      FDIA2=FDIA2+"-"
      FDIA2=FDIA2+RTRIM(MESNOM(FDIA1,3))
      FDIA2=FDIA2+"-"
      FDIA2=FDIA2+RIGHT(STRZERO(YEAR(FDIA1),4),2)
   CASE LONG1=10 //31-01-1992
      FDIA2=STRZERO(DAY(FDIA1),2)
      FDIA2=FDIA2+"-"
      FDIA2=FDIA2+STRZERO(MONTH(FDIA1),2)
      FDIA2=FDIA2+"-"
      FDIA2=FDIA2+STRZERO(YEAR(FDIA1),4)
   CASE LONG1=11  //31-ENE-1992
      FDIA2=STRZERO(DAY(FDIA1),2)
      FDIA2=FDIA2+"-"
      FDIA2=FDIA2+RTRIM(MESNOM(FDIA1,3))
      FDIA2=FDIA2+"-"
      FDIA2=FDIA2+STRZERO(YEAR(FDIA1),4)
   CASE LONG1=12  //LUN,31-01-92
      FDIA2=LEFT(RTRIM(DIANOM(FDIA1)),3)
      FDIA2=FDIA2+","
      FDIA2=FDIA2+STRZERO(DAY(FDIA1),2)
      FDIA2=FDIA2+"-"
      FDIA2=FDIA2+STRZERO(MONTH(FDIA1),2)
      FDIA2=FDIA2+"-"
      FDIA2=FDIA2+RIGHT(STRZERO(YEAR(FDIA1),4),2)
   CASE LONG1=13  //LUN,31-ENE-92
      FDIA2=LEFT(RTRIM(DIANOM(FDIA1)),3)
      FDIA2=FDIA2+","
      FDIA2=FDIA2+STRZERO(DAY(FDIA1),2)
      FDIA2=FDIA2+"-"
      FDIA2=FDIA2+RTRIM(MESNOM(FDIA1,3))
      FDIA2=FDIA2+"-"
      FDIA2=FDIA2+RIGHT(STRZERO(YEAR(FDIA1),4),2)
   CASE LONG1=18 //31-Enero-1992
      FDIA2=FDIA2+LTRIM(STR(DAY(FDIA1)))
      FDIA2=FDIA2+"-"
      FDIA2=FDIA2+RTRIM(MESNOM(FDIA1))
      FDIA2=FDIA2+"-"
      FDIA2=FDIA2+STRZERO(YEAR(FDIA1),4)
      FDIA2=PADR(FDIA2,18," ")
   CASE LONG1=24 //31 de Enero de 1992
      FDIA2=FDIA2+LTRIM(STR(DAY(FDIA1)))
      FDIA2=FDIA2+" de "
      FDIA2=FDIA2+RTRIM(MESNOM(FDIA1))
      FDIA2=FDIA2+" de "
      FDIA2=FDIA2+STRZERO(YEAR(FDIA1),4)
      FDIA2=PADR(FDIA2,24," ")
   CASE LONG1=35 //LUNES, 31 de Enero de 1992
      FDIA2=RTRIM(DIANOM(FDIA1))
      FDIA2=FDIA2+", "
      FDIA2=FDIA2+LTRIM(STR(DAY(FDIA1)))
      FDIA2=FDIA2+" de "
      FDIA2=FDIA2+RTRIM(MESNOM(FDIA1))
      FDIA2=FDIA2+" de "
      FDIA2=FDIA2+STRZERO(YEAR(FDIA1),4)
      FDIA2=PADR(FDIA2,35," ")
   CASE LONG1=-6 //310192
      FDIA2=STRZERO(DAY(FDIA1),2)
      FDIA2=FDIA2+STRZERO(MONTH(FDIA1),2)
      FDIA2=FDIA2+RIGHT(STRZERO(YEAR(FDIA1),4),2)
   CASE LONG1=-8 //31011992
      FDIA2=STRZERO(DAY(FDIA1),2)
      FDIA2=FDIA2+STRZERO(MONTH(FDIA1),2)
      FDIA2=FDIA2+RIGHT(STRZERO(YEAR(FDIA1),4),4)
   CASE LONG1=-1008 //19920131
      FDIA2=RIGHT(STRZERO(YEAR(FDIA1),4),4)
      FDIA2=FDIA2+STRZERO(MONTH(FDIA1),2)
      FDIA2=FDIA2+STRZERO(DAY(FDIA1),2)
   OTHERWISE
      IF LONG1<0
         FDIA2=SPACE(LONG1*-1)
      ELSE
         FDIA2=SPACE(LONG1)
      ENDIF
   ENDCASE
RETURN(FDIA2)

*
FUNCTION DIANOM(FDIA1,LONG1)
LOCAL FDIA2:=""
LOCAL FDIA3
IF VALTYPE(FDIA1)<>"D" .AND. VALTYPE(FDIA1)<>"N"
   FDIA2=PADR(VALTYPE(FDIA1),LONG1," ")
   RETURN(FDIA2)
ENDIF
LONG1:=IF(LONG1=NIL, 9 ,LONG1)
IF VALTYPE(LONG1)<>"N"
   FDIA2=PADR(VALTYPE(LONG1),LONG1," ")
   RETURN(FDIA2)
ENDIF
   DO CASE
   CASE VALTYPE(FDIA1)="D"
      FDIA3:=DOW(FDIA1)
   CASE VALTYPE(FDIA1)="N"
      FDIA3:=FDIA1
   OTHERWISE
      FDIA2=PADR(VALTYPE(FDIA1),LONG1," ")
      RETURN(FDIA2)
   ENDCASE

   DO CASE
   CASE FDIA3=2
      FDIA2="lunes"
   CASE FDIA3=3
      FDIA2="martes"
   CASE FDIA3=4
      FDIA2="miercoles"
   CASE FDIA3=5
      FDIA2="jueves"
   CASE FDIA3=6
      FDIA2="viernes"
   CASE FDIA3=7
      FDIA2="sabado"
   CASE FDIA3=1
      FDIA2="domingo"
   OTHERWISE
      FDIA2=SPACE(LONG1)
   ENDCASE
   FDIA2=PADR(FDIA2,LONG1," ")
RETURN(FDIA2)

*
FUNCTION DIANUM(FDIA1)
   LOCAL NDIA2:=0, FDIA3
   DO CASE
   CASE VALTYPE(FDIA1)="D"
      FDIA3:=DOW(FDIA1)
   CASE VALTYPE(FDIA1)="N"
      FDIA3:=FDIA1
   OTHERWISE
      NDIA2=0
      RETURN(NDIA2)
   ENDCASE

   DO CASE
   CASE FDIA3=2
      NDIA2=1
   CASE FDIA3=3
      NDIA2=2
   CASE FDIA3=4
      NDIA2=3
   CASE FDIA3=5
      NDIA2=4
   CASE FDIA3=6
      NDIA2=5
   CASE FDIA3=7
      NDIA2=6
   CASE FDIA3=1
      NDIA2=7
   OTHERWISE
      NDIA2=0
   ENDCASE
RETURN(NDIA2)

*
FUNCTION DIASEM(FDIA1)
   LOCAL FDIA2:=0
   DO CASE
   CASE DOW(FDIA1)=2
      FDIA2=1 //"lunes"
   CASE DOW(FDIA1)=3
      FDIA2=2 //"martes"
   CASE DOW(FDIA1)=4
      FDIA2=3 //"miercoles"
   CASE DOW(FDIA1)=5
      FDIA2=4 //"jueves"
   CASE DOW(FDIA1)=6
      FDIA2=5 //"viernes"
   CASE DOW(FDIA1)=7
      FDIA2=6 //"sabado"
   CASE DOW(FDIA1)=1
      FDIA2=7 //"domingo"
   ENDCASE
RETURN(FDIA2)

*
FUNCTION DIANUMNOM(NDIA1)
   LOCAL NDIA2:=""
   DO CASE
   CASE NDIA1=1
      NDIA2="lunes"
   CASE NDIA1=2
      NDIA2="martes"
   CASE NDIA1=3
      NDIA2="miercoles"
   CASE NDIA1=4
      NDIA2="jueves"
   CASE NDIA1=5
      NDIA2="viernes"
   CASE NDIA1=6
      NDIA2="sabado"
   CASE NDIA1=7
      NDIA2="domingo"
   ENDCASE
RETURN(NDIA2)

*
FUNCTION MESNOM(FDIA1,LONG1)
LOCAL FDIA2:=""
LOCAL FDIA3
IF VALTYPE(FDIA1)<>"D" .AND. VALTYPE(FDIA1)<>"N"
   FDIA2=PADR(VALTYPE(FDIA1),LONG1," ")
   RETURN(FDIA2)
ENDIF
LONG1:=IF(LONG1=NIL, 10 ,LONG1)
IF VALTYPE(LONG1)<>"N"
   FDIA2=PADR(VALTYPE(LONG1),LONG1," ")
   RETURN(FDIA2)
ENDIF
   DO CASE
   CASE VALTYPE(FDIA1)="D"
      FDIA3:=MONTH(FDIA1)
   CASE VALTYPE(FDIA1)="N"
      FDIA3:=FDIA1
   OTHERWISE
      FDIA2=PADR(VALTYPE(FDIA1),LONG1," ")
      RETURN(FDIA2)
   ENDCASE

   DO CASE
   CASE FDIA3=1
      FDIA2="enero"
   CASE FDIA3=2
      FDIA2="febrero"
   CASE FDIA3=3
      FDIA2="marzo"
   CASE FDIA3=4
      FDIA2="abril"
   CASE FDIA3=5
      FDIA2="mayo"
   CASE FDIA3=6
      FDIA2="junio"
   CASE FDIA3=7
      FDIA2="julio"
   CASE FDIA3=8
      FDIA2="agosto"
   CASE FDIA3=9
      FDIA2="septiembre"
   CASE FDIA3=10
      FDIA2="octubre"
   CASE FDIA3=11
      FDIA2="noviembre"
   CASE FDIA3=12
      FDIA2="diciembre"
   OTHERWISE
      FDIA2=SPACE(LONG1)
   ENDCASE
   FDIA2=PADR(FDIA2,LONG1," ")
RETURN(FDIA2)

*
FUNCTION DIACAR(FDIA0,FMTO) //DIA,CAR,DTOS
   LOCAL FDIA1, FDIA2, FDIA3, FDIA4
   FMTO:=IF(FMTO=NIL, "DIA" ,FMTO)
   FDIA0:=STRTRAN(FDIA0,"/","-")

   FDIA1:=LEFT(FDIA0,AT("-",FDIA0)-1)
   DO CASE
   CASE AT("ENE",UPPER(FDIA0))<>0
      FDIA2:="01"
   CASE AT("FEB",UPPER(FDIA0))<>0
      FDIA2:="02"
   CASE AT("MAR",UPPER(FDIA0))<>0
      FDIA2:="03"
   CASE AT("ABR",UPPER(FDIA0))<>0
      FDIA2:="04"
   CASE AT("MAY",UPPER(FDIA0))<>0
      FDIA2:="05"
   CASE AT("JUN",UPPER(FDIA0))<>0
      FDIA2:="06"
   CASE AT("JUL",UPPER(FDIA0))<>0
      FDIA2:="07"
   CASE AT("AGO",UPPER(FDIA0))<>0
      FDIA2:="08"
   CASE AT("SEP",UPPER(FDIA0))<>0
      FDIA2:="09"
   CASE AT("OCT",UPPER(FDIA0))<>0
      FDIA2:="10"
   CASE AT("NOV",UPPER(FDIA0))<>0
      FDIA2:="11"
   CASE AT("DIC",UPPER(FDIA0))<>0
      FDIA2:="12"
   OTHERWISE
      FDIA2:="00"
   ENDCASE
   FDIA3:=SUBSTR(FDIA0,RAT("-" , FDIA0)+1 , LEN(FDIA0)-RAT("-",FDIA0) )
   DO CASE
   CASE UPPER(FMTO)="DIA"
      FDIA4:=CTOD(FDIA1+"-"+FDIA2+"-"+FDIA3)
   CASE UPPER(FMTO)="CAR"
      FDIA4:=FDIA1+"-"+FDIA2+"-"+FDIA3
   CASE UPPER(FMTO)="DTOS"
      FDIA4:=FDIA3+FDIA2+FDIA1
   OTHERWISE
      FDIA4:=CTOD(FDIA1+"-"+FDIA2+"-"+FDIA3)
   ENDCASE
RETURN(FDIA4)

*
FUNCTION DIAFINMES(FDIA1)
   LOCAL FDIA2:=CTOD("01-"+STRZERO(MONTH(FDIA1-DAY(FDIA1)+35),2)+"-"+STRZERO(YEAR(FDIA1-DAY(FDIA1)+35),4))-1
RETURN(FDIA2)

FUNCTION DIAINIMES(FDIA1)
   LOCAL FDIA2:=FDIA1-DAY(FDIA1)+1
RETURN(FDIA2)

*
FUNCTION DIAMESMAS(FDIA1,FMES1)
   LOCAL N, FDIA2:=FDIA1
   FOR N=1 TO FMES1
      FDIA2:=CTOD("01-"+STRZERO(MONTH(FDIA2),2)+"-"+STRZERO(YEAR(FDIA2),4))+35
      FDIA2:=DIAFINMES(FDIA2)
      IF DAY(FDIA1)<DAY(FDIA2)
         FDIA2:=CTOD(STRZERO(DAY(FDIA1),2)+"-"+STRZERO(MONTH(FDIA2),2)+"-"+STRZERO(YEAR(FDIA2),4))
      ENDIF
   NEXT
RETURN(FDIA2)
