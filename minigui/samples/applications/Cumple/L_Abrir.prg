#include "dbinfo.ch"

Function AbrirDBF(AbrirDBF,AbrirCDX,AbrirALI,AbrirSHA,AbrirRUTA,AbrirORDEN)
   LOCAL AbrirORDEN2, SiRuta, SiShared
   LOCAL AUTOPEN2, AbrirERROR1, AbrirERROR2
   AbrirDBF:=UPPER(AbrirDBF)
   AbrirCDX:=IF(AbrirCDX=NIL,AbrirDBF,AbrirCDX)
   AbrirALI:=IF(AbrirALI=NIL,AbrirDBF,AbrirALI)
   AbrirSHA:=IF(AbrirSHA=NIL,"shared",AbrirSHA) //shared/Exclusive
   AbrirRUTA:=IF(AbrirRUTA=NIL,RUTAEMPRESA,AbrirRUTA)
   AbrirORDEN:=IF(AbrirORDEN=NIL,-1,AbrirORDEN)
   AbrirORDEN2:=0

   IF LEN(AbrirRUTA)>0
      IF RIGHT(AbrirRUTA,1)<>"\"
         AbrirRUTA:=AbrirRUTA+"\"
      ENDIF
      AbrirDBF:=AbrirRUTA+AbrirDBF
      IF AbrirCDX<>"SIN_INDICE"
         AbrirCDX:=AbrirRUTA+AbrirCDX
      ENDIF
   ENDIF

***COMPROBAR LA RUTA DEL FICHERO***
   IF SELECT(AbrirALI)<>0
      SELECT(AbrirALI)
      SiRuta := DBINFO(DBI_FULLPATH) //10-DBI_FULLPATH
      IF UPPER(SiRuta)<>UPPER(AbrirDBF)+".DBF"
         AbrirORDEN2:=INDEXORD()
         &AbrirALI->( DBCLOSEAREA() )
      ENDIF
   ENDIF

***COMPROBAR shared/Exclusive***
   IF SELECT(AbrirALI)<>0
      SELECT(AbrirALI)
      SiShared := DBINFO(DBI_SHARED) //36-DBI_SHARED
      IF SiShared=.T. .AND. AbrirSHA<>"shared" .OR. ;
         SiShared=.F. .AND. AbrirSHA="shared"
         AbrirORDEN2:=INDEXORD()
         &AbrirALI->( DBCLOSEAREA() )
      ENDIF
   ENDIF

***COMPROBAR EL INDICE***
   IF SELECT(AbrirALI)<>0
      SELECT(AbrirALI)
      IF INDEXORD()==0 .AND. AbrirCDX<>"SIN_INDICE" .OR. ;
         INDEXORD()<>0 .AND. AbrirCDX=="SIN_INDICE"
         &AbrirALI->( DBCLOSEAREA() )
      ENDIF
   ENDIF

***LO ABRE SIN INDICE Y NO DEVUELVE EL ERROR***
*   AbrirAREA:=IF( SELECT(AbrirALI)<>0 , .F. , .T. )
*   DBUSEAREA( AbrirAREA , [AbrirDISCO] , AbrirDBF , AbrirALI , [<lShared>], [<lReadonly>]) -> NIL

***ABRIR FICHERO***
IF SELECT(AbrirALI)<>0
   SELECT(AbrirALI)
   IF AbrirORDEN<>INDEXORD() .AND. AbrirORDEN>=0
      DBSETORDER(AbrirORDEN)
   ENDIF
ELSE
   AUTOPEN2:=SET(_SET_AUTOPEN)
   SET(_SET_AUTOPEN,.F.)
   DO WHILE .T.
      AbrirERROR1:=0
      AbrirERROR2:=0
      IF AbrirSHA="shared"
**         DBUSEAREA( .T. ,  , AbrirDBF , AbrirALI , .T. , .F. )
         Use (AbrirDBF) Alias (AbrirALI) new shared    VIA "DBFCDX"
      ELSE
**         DBUSEAREA( .T. ,  , AbrirDBF , AbrirALI , .F. , .F. )
         Use (AbrirDBF) Alias (AbrirALI) new Exclusive VIA "DBFCDX"
      ENDIF
      IF NETERR()
         AbrirERROR1:=FERROR()
      ENDIF
      IF AbrirCDX<>"SIN_INDICE" .AND. AbrirERROR1=0
         DbSetIndex(AbrirCDX)
         IF NETERR()
            AbrirERROR2:=FERROR()
         ENDIF
         IF AbrirORDEN2>0 .AND. AbrirERROR2=0
            DBSETORDER(AbrirORDEN2)
         ENDIF
      ENDIF

      IF AbrirERROR1=0 .AND. AbrirERROR2=0
         IF AbrirORDEN<>INDEXORD() .AND. AbrirORDEN>=0
            DBSETORDER(AbrirORDEN)
         ENDIF
      ENDIF

      IF AbrirERROR1=0 .AND. AbrirERROR2=0
         EXIT
      ELSE
         IF MSGYESNO("Fichero: "+AbrirDBF+CHR(13)+ ;
                "Indice: "+AbrirCDX+CHR(13)+ ;
                "Alias: "+AbrirALI+CHR(13)+ ;
                "Compartido: "+IF(AbrirSHA="shared","Si","No")+CHR(13)+ ;
                "Ruta: "+AbrirRUTA+CHR(13)+ ;
                "Error DOS: "+LTRIM(STR(DOSERROR()))+CHR(13)+ ;
                "Error DBF: "+LTRIM(STR(AbrirERROR1))+"-"+Error_Nombre(AbrirERROR1)+CHR(13)+ ;
                "Error CDX: "+LTRIM(STR(AbrirERROR2))+"-"+Error_Nombre(AbrirERROR2)+CHR(13)+ ;
                "Llamado por: "+LTRIM(STR(PROCLINE(1)))+"-"+PROCNAME(1)+CHR(13)+CHR(13)+ ;
                "El fichero esta siento usado"+CHR(13)+ ;
                "¿Desea seguir intentando abrirlo?" ,"error" )=.T.
            LOOP
         ELSE
            EXIT
         ENDIF
      ENDIF

   ENDDO
   SET(_SET_AUTOPEN,AUTOPEN2)

ENDIF
RETURN(FERROR())


Function AbrirDBF1(AbrirDBF,AbrirCDX,AbrirALI,AbrirSHA,AbrirRUTA,AbrirSELECTT)
   LOCAL AUTOPEN2
   AbrirCDX:=IF(AbrirCDX=NIL,AbrirDBF,AbrirCDX)
   AbrirALI:=IF(AbrirALI=NIL,AbrirDBF,AbrirALI)
   AbrirSHA:=IF(AbrirSHA=NIL,"shared",AbrirSHA) //shared/Exclusive
   AbrirRUTA:=IF(AbrirRUTA=NIL,RUTAEMPRESA,AbrirRUTA)
   AbrirSELECTT:=IF(AbrirSELECTT=NIL,0,AbrirSELECTT)

   IF LEN(AbrirRUTA)>0
      IF RIGHT(AbrirRUTA,1)<>"\"
         AbrirRUTA:=AbrirRUTA+"\"
      ENDIF
      AbrirDBF:=AbrirRUTA+AbrirDBF
      IF AbrirCDX<>"SIN_INDICE"
         AbrirCDX:=AbrirRUTA+AbrirCDX
      ENDIF
   ENDIF

***ABRIR FICHERO***
      IF AbrirSELECTT<>0 .AND. AbrirSELECTT<>SELECT(AbrirALI)
         &AbrirALI->( DBCLOSEAREA() )
      ENDIF
      IF AbrirSELECTT<>0
         SELECT(AbrirSELECTT)
      ENDIF
      IF AbrirSHA="shared"
         IF AbrirCDX<>"SIN_INDICE"
            Use &AbrirDBF index &AbrirCDX Alias &AbrirALI VIA "DBFCDX" shared
         ELSE
            AUTOPEN2:=SET(_SET_AUTOPEN)
            SET(_SET_AUTOPEN,.F.)
            Use &AbrirDBF Alias &AbrirALI VIA "DBFCDX" shared
            SET(_SET_AUTOPEN,AUTOPEN2)
         ENDIF
      ELSE
         IF AbrirCDX<>"SIN_INDICE"
            Use &AbrirDBF index &AbrirCDX Alias &AbrirALI VIA "DBFCDX" Exclusive
         ELSE
            AUTOPEN2:=SET(_SET_AUTOPEN)
            SET(_SET_AUTOPEN,.F.)
            Use &AbrirDBF Alias &AbrirALI VIA "DBFCDX" Exclusive
            SET(_SET_AUTOPEN,AUTOPEN2)
         ENDIF
      ENDIF

RETURN(FERROR())

PROCEDURE AbrirDBF2(AbrirDBF,AbrirCDX,AbrirALI,AbrirSHA,AbrirRUTA)
   LOCAL SiRuta, ABRIRNTX1, AbrirNTX2
   AbrirCDX:=IF(AbrirCDX=NIL,AbrirDBF,AbrirCDX)
   AbrirALI:=IF(AbrirALI=NIL,AbrirDBF,AbrirALI)
   AbrirSHA:=IF(AbrirSHA=NIL,"shared",AbrirSHA) //shared/Exclusive
   AbrirRUTA:=IF(AbrirRUTA=NIL,"",AbrirRUTA)
   IF LEN(AbrirRUTA)>0
      IF RIGHT(AbrirRUTA,1)<>"\"
         AbrirRUTA:=AbrirRUTA+"\"
      ENDIF
      AbrirDBF:=AbrirRUTA+AbrirDBF
      IF AbrirCDX<>"SIN_INDICE"
         AbrirCDX:=AbrirRUTA+AbrirCDX
      ENDIF
   ENDIF

***COMPROBAR LA RUTA DEL FICHERO***
   IF SELECT(AbrirALI)<>0
      SELECT(AbrirALI)
      SiRuta := DBINFO(DBI_FULLPATH) //10-DBI_FULLPATH
      IF UPPER(SiRuta)<>UPPER(AbrirDBF)+".DBF"
         &AbrirALI->( DBCLOSEAREA() )
      ENDIF
   ENDIF

   IF SELECT(AbrirALI)<>0
      SELECT(AbrirALI)
   ELSE
      DO CASE
      CASE AT("EMPCON",UPPER(AbrirDBF))<>0
         AbrirNTX1:=AbrirRUTA+"EMPC1"
         USE &AbrirDBF Alias &AbrirALI VIA "DBFNTX" NEW
         DBSETINDEX(AbrirNTX1)
      CASE AT("EMP",UPPER(AbrirDBF))<>0
         AbrirNTX1:=AbrirRUTA+"EMP1"
         USE &AbrirDBF Alias &AbrirALI VIA "DBFNTX" NEW
         DBSETINDEX(AbrirNTX1)
      CASE AT("APUNTES",UPPER(AbrirDBF))<>0
         AbrirNTX1:=AbrirRUTA+"APU1"
         USE &AbrirDBF Alias &AbrirALI VIA "DBFNTX" NEW
         DBSETINDEX(AbrirNTX1)
      CASE AT("CUENTAS",UPPER(AbrirDBF))<>0
         AbrirNTX1:=AbrirRUTA+"CUE1"
         AbrirNTX2:=AbrirRUTA+"CUE2"
         USE &AbrirDBF Alias &AbrirALI VIA "DBFNTX" NEW
         DBSETINDEX(AbrirNTX1)
         DBSETINDEX(AbrirNTX2)
      CASE AT("FAC92",UPPER(AbrirDBF))<>0
         AbrirNTX1:=AbrirRUTA+"FAC1"
         AbrirNTX2:=AbrirRUTA+"FAC2"
         USE &AbrirDBF Alias &AbrirALI VIA "DBFNTX" NEW
         DBSETINDEX(AbrirNTX1)
         DBSETINDEX(AbrirNTX2)
      CASE AT("ARTICULO",UPPER(AbrirDBF))<>0
         AbrirNTX1:=AbrirRUTA+"ART1"
         AbrirNTX2:=AbrirRUTA+"ART2"
         USE &AbrirDBF Alias &AbrirALI VIA "DBFNTX" NEW
         DBSETINDEX(AbrirNTX1)
         DBSETINDEX(AbrirNTX2)
      CASE AT("ALBARAN",UPPER(AbrirDBF))<>0
         AbrirNTX1:=AbrirRUTA+"ALB1"
         USE &AbrirDBF Alias &AbrirALI VIA "DBFNTX" NEW
         DBSETINDEX(AbrirNTX1)
      CASE AT("CLIENTES",UPPER(AbrirDBF))<>0
         AbrirNTX1:=AbrirRUTA+"CLI1"
         AbrirNTX2:=AbrirRUTA+"CLI2"
         USE &AbrirDBF Alias &AbrirALI VIA "DBFNTX" NEW
         DBSETINDEX(AbrirNTX1)
         DBSETINDEX(AbrirNTX2)
      CASE AT("REM",UPPER(AbrirDBF))<>0
         AbrirNTX1:=AbrirCDX
         IF AT(".DBF",UPPER(AbrirNTX1))<>0
            AbrirNTX1:=LEFT(AbrirNTX1,AT(".DBF",UPPER(AbrirNTX1))-1)+".NTX"
         ENDIF
         USE &AbrirDBF Alias &AbrirALI VIA "DBFNTX" NEW
         DBSETINDEX(AbrirNTX1)
      CASE AT("LIN",UPPER(AbrirDBF))<>0
         AbrirNTX1:=AbrirRUTA+AbrirDBF
         USE &AbrirDBF Alias &AbrirALI VIA "DBFNTX" NEW
         DBSETINDEX(AbrirNTX1)
      ENDCASE
   ENDIF
RETURN

Function AbrirDBF3(AbrirDBF,AbrirCDX,AbrirALI,AbrirSHA,AbrirRUTA)
   LOCAL AbrirAREA
   AbrirCDX:=IF(AbrirCDX=NIL,AbrirDBF,AbrirCDX)
   AbrirALI:=IF(AbrirALI=NIL,AbrirDBF,AbrirALI)
   AbrirSHA:=IF(AbrirSHA=NIL, .T.    , .F.    ) //shared/Exclusive
   AbrirRUTA:=IF(AbrirRUTA=NIL,RUTAEMPRESA,AbrirRUTA)

   IF LEN(AbrirRUTA)>0
      IF RIGHT(AbrirRUTA,1)<>"\"
         AbrirRUTA:=AbrirRUTA+"\"
      ENDIF
      AbrirDBF:=AbrirRUTA+AbrirDBF
      IF AbrirCDX<>"SIN_INDICE"
         AbrirCDX:=AbrirRUTA+AbrirCDX
      ENDIF
   ENDIF

   AbrirAREA:=IF(SELECT(AbrirALI)<>0 , .F. , .T. )
*   DBUSEAREA( AbrirAREA , [AbrirDISCO] , AbrirDBF , AbrirALI , [<lShared>], [<lReadonly>])
   DBUSEAREA( AbrirAREA , , AbrirDBF , AbrirALI , AbrirSHA , .F. )
   IF AbrirCDX<>"SIN_INDICE"
      DBSETINDEX(AbrirCDX)
   ENDIF

RETURN(FERROR())


STATIC FUNCTION Error_Nombre(CODIGOE)
LOCAL CODIGOD
DO CASE
CASE CODIGOE=0
   CODIGOD:='Successful'
CASE CODIGOE=2
   CODIGOD:='File not found'
CASE CODIGOE=3
   CODIGOD:='Path not found'
CASE CODIGOE=4
   CODIGOD:='Too many files open'
CASE CODIGOE=5
   CODIGOD:='Access denied'
CASE CODIGOE=6
   CODIGOD:='Invalid handle'
CASE CODIGOE=8
   CODIGOD:='Insufficient memory'
CASE CODIGOE=15
   CODIGOD:='Invalid drive specified'
CASE CODIGOE=19
   CODIGOD:='Attempted to write to a write-protected disk'
CASE CODIGOE=21
   CODIGOD:='Drive not ready'
CASE CODIGOE=23
   CODIGOD:='Data CRC error'
CASE CODIGOE=29
   CODIGOD:='Write fault'
CASE CODIGOE=30
   CODIGOD:='Read fault'
CASE CODIGOE=32
   CODIGOD:='Sharing violation'
CASE CODIGOE=33
   CODIGOD:='Lock Violation'
OTHERWISE
   CODIGOD:=''
ENDCASE
RETURN(CODIGOD)

