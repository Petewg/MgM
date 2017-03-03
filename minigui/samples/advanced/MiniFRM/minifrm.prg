*****************************************************************************
*                                                                           *
*          MINIFRM - Print FRM files to MINIPRINT or HBPRINTER              *
*                                                                           *
*                                V 0.9                                      *
*                                                                           *
*****************************************************************************

* Seleccione la Interfase de Impresión antes de compilar....
#define _RF_MINIPRINT
*#define _RF_HBPRINTER


***************************************** Características *******************************************
* Funciona en forma similar que con el FRM estándar. 
* Si está la opción TO PRINT, imprime directamente a la impresora. Si no lo está, hace un preview.
* Usa la impresora por defecto.
* Si el ancho es <= 80 usa Courier New 12, simulando el modo normal. 
* Si no usa Courier New  8 simulando condensada.
*
* Diferencias con el FRM estandar
* -------------------------------
* Agregados:
*   - Agrega separadores de miles en los números
*   - Imprime en BOLD los títulos, totales y subtotales
*
* Eliminados:
*   - Está deshabilitada la opción PLAIN
*   - Está deshabilitada la opción TO FILE
*   - No traduce caracteres especiales CHR(xx)
*   - Está deshabilitado el salto de hoja antes del reporte
***************************************************************************************************


#include "minigui.ch"
#include "error.ch"

#ifdef _RF_MINIPRINT
    #include "miniprint.ch"
#endif
#ifdef _RF_HBPRINTER
    #include "winprint.ch"
#endif


********* Parámetros del reporte ************
#define _RF_FIRSTCOL  4  && Offset Primer columna
#define _RF_FIRSTROW  5  && Offset Primer fila
#define _RF_ROWINC    4  && Interlineado 
#define _RF_FONT      "Courier New"  && Font a usar (No usar proporcional!)
#define _RF_SIZECONDENSED 7   && Tamaño de font a usar cuando el ancho es mayor de 80 columnas (132)
#define _RF_SIZENORMAL   11   && Tamaño de font a usar cuando el ancho es menor de 80 columnas
#define _RF_ROWSINLETTER  60  && Cantidad de Filas máximo que soporta el tamaño carta. Si hay mas líneas, se usa Legal

**** Constantes para el Nation Message ********
#define _RF_PAGENO       3     && Página 
#define _RF_SUBTOTAL     4     && Subtotal 
#define _RF_SUBSUBTOTAL  5     && SubSubtotal 
#define _RF_TOTAL        6     && Total 

********** Tamaños de buffer ************* 
#define  SIZE_FILE_BUFF             1990    
#define  SIZE_LENGTHS_BUFF          110
#define  SIZE_OFFSETS_BUFF          110
#define  SIZE_EXPR_BUFF             1440
#define  SIZE_FIELDS_BUFF           300
#define  SIZE_PARAMS_BUFF           24

**************** offsets *******************
#define  LENGTHS_OFFSET             5          
#define  OFFSETS_OFFSET             115        
#define  EXPR_OFFSET                225        
#define  FIELDS_OFFSET              1665       
#define  PARAMS_OFFSET              1965       
#define  FIELD_WIDTH_OFFSET         1
#define  FIELD_TOTALS_OFFSET        6
#define  FIELD_DECIMALS_OFFSET      7
#define  FIELD_CONTENT_EXPR_OFFSET  9
#define  FIELD_HEADER_EXPR_OFFSET   11
#define  PAGE_HDR_OFFSET            1
#define  GRP_EXPR_OFFSET            3
#define  SUB_EXPR_OFFSET            5
#define  GRP_HDR_OFFSET             7
#define  SUB_HDR_OFFSET             9
#define  PAGE_WIDTH_OFFSET          11
#define  LNS_PER_PAGE_OFFSET        13
#define  LEFT_MRGN_OFFSET           15
#define  RIGHT_MGRN_OFFSET          17
#define  COL_COUNT_OFFSET           19
#define  DBL_SPACE_OFFSET           21
#define  SUMMARY_RPT_OFFSET         22
#define  PE_OFFSET                  23
#define  OPTION_OFFSET              24

********* Definiciones para el Array del reporte ************* 
#define RP_HEADER   1       
#define RP_WIDTH    2       
#define RP_LMARGIN  3       
#define RP_RMARGIN  4       
#define RP_LINES    5       
#define RP_SPACING  6       
#define RP_BEJECT   7       
#define RP_AEJECT   8       
#define RP_PLAIN    9       
#define RP_SUMMARY  10      
#define RP_COLUMNS  11      
#define RP_GROUPS   12      
#define RP_HEADING  13      

#define RP_COUNT    13      


******** Columnas ************ 
#define RC_EXP      1       
#define RC_TEXT     2       
#define RC_TYPE     3       
#define RC_HEADER   4       
#define RC_WIDTH    5       
                            
#define RC_DECIMALS 6       
#define RC_TOTAL    7       
#define RC_PICT     8       

#define RC_COUNT    8       

****** Grupos ***********
#define RG_EXP      1  
#define RG_TEXT     2  
#define RG_TYPE     3  
#define RG_HEADER   4  
#define RG_AEJECT   5  

#define RG_COUNT    5  

********** Errores ************
#define  F_OK                       0   && Ok! 
#define  F_EMPTY                   -3   && Archivo vacío
#define  F_ERROR                   -1   && Error desconocido 
#define  F_NOEXIST                  2   && Archivo inexistente

Memvar aReportData
Memvar nMaxLinesAvail
Memvar nPosRow, nPosCol, lUseLetter
Memvar nPageNumber
Memvar lFirstPass
Memvar nLinesLeft
Memvar aGroupTotals
Memvar aReportTotals
Memvar sAux, nFontSize
Memvar cLengthsBuff
Memvar cOffsetsBuff
Memvar cExprBuff

*****************************************************************************
PROCEDURE __ReportForm( cFRMName, lPrinter, cAltFile, lNoConsole, bFor, ;
                       bWhile, nNext, nRecord, lRest, lPlain, cHeading, ;
                       lBEject, lSummary )
******************************************************************************

LOCAL nCol, nGroup
LOCAL xBreakVal, lBroke := .F.
LOCAL err, sAuxST
LOCAL lAnyTotals
LOCAL lAnySubTotals

HB_SYMBOL_UNUSED( cAltFile )
HB_SYMBOL_UNUSED( lNoConsole )
HB_SYMBOL_UNUSED( lPlain )

Private nPosRow, nPosCol, lUseLetter

********* Parametros ************
IF cFRMName == NIL
  err := ErrorNew()
  err:severity := ES_ERROR
  err:genCode := EG_ARG
  err:subSystem := "FRMLBL"
  Eval(ErrorBlock(), err)
ELSE
  IF AT( ".", cFRMName ) == 0
     cFRMName := TRIM( cFRMName ) + ".FRM"
  ENDIF
ENDIF

IF lPrinter == NIL
 lPrinter   := .F.
ENDIF

IF cHeading == NIL
 cHeading := ""
ENDIF

BEGIN SEQUENCE

    ********** Cargo los datos del FRM en el vector aReportData ***********
    aReportData := __FrmLoad( cFRMName )  
    nMaxLinesAvail := aReportData[RP_LINES]

     ********** Determino el tipo de papel a usar **********
     lUseLetter  := (aReportData[ RP_LINES ] <= _RF_ROWSINLETTER)


     ********************** MINIPRINT *******************
     #ifdef _RF_MINIPRINT
     IF lPrinter
        If lUseLetter && Seleccionó Preview? 
           SELECT PRINTER DEFAULT ORIENTATION	PRINTER_ORIENT_PORTRAIT  PAPERSIZE PRINTER_PAPER_LETTER   
        ELSE
           SELECT PRINTER DEFAULT ORIENTATION	PRINTER_ORIENT_PORTRAIT  PAPERSIZE PRINTER_PAPER_LEGAL
        ENDIF
     ELSE
        If lUseLetter
          SELECT PRINTER DEFAULT ORIENTATION	PRINTER_ORIENT_PORTRAIT  PAPERSIZE PRINTER_PAPER_LETTER PREVIEW
        ELSE
          SELECT PRINTER DEFAULT ORIENTATION	PRINTER_ORIENT_PORTRAIT  PAPERSIZE PRINTER_PAPER_LEGAL PREVIEW
        ENDIF
     ENDIF
     #endif

     ********************** HBPRINTER *******************
     #ifdef _RF_HBPRINTER
     INIT PRINTSYS
  
     IF lPrinter && Seleccionó Preview?
       SELECT  DEFAULT 
     ELSE
       SELECT  DEFAULT PREVIEW
     ENDIF

     If lUseLetter
        SET PAGE PAPERSIZE DMPAPER_LETTER 
     ELSE
        SET PAGE PAPERSIZE DMPAPER_LEGAL
     ENDIF

     SET UNITS MM
     #endif

    IF lSummary != NIL            
       aReportData[ RP_SUMMARY ] := lSummary
    ENDIF
    IF lBEject != NIL .AND. lBEject
        aReportData[ RP_BEJECT ]  := .F.
    ENDIF

    aReportData[ RP_HEADING ]    := cHeading

    nPageNumber := 1      && Primer página 
    lFirstPass  := .T.           

    nLinesLeft  := aReportData[ RP_LINES ]

    *********** Inicializo documento **************
    #ifdef _RF_MINIPRINT
       START PRINTDOC 
       START PRINTPAGE
    #ENDIF
    #ifdef _RF_HBPRINTER 
       START DOC
       START PAGE
    #ENDIF

    nPosRow := _RF_FIRSTROW
    nPosCol := _RF_FIRSTCOL

    ******* Imprimo cabezal *********
    CabezalReporte()

    ******* Inicializo totales *********
    aReportTotals := ARRAY( LEN(aReportData[RP_GROUPS]) + 1, LEN(aReportData[RP_COLUMNS]) )
    FOR nCol := 1 TO LEN(aReportData[RP_COLUMNS])
      IF aReportData[RP_COLUMNS,nCol,RC_TOTAL]
        FOR nGroup := 1 TO LEN(aReportTotals)
           aReportTotals[nGroup,nCol] := 0
        NEXT
      ENDIF
    NEXT
    aGroupTotals := ARRAY( LEN(aReportData[RP_GROUPS]) )

    ********** Ejecuto el reporte ! ***********
    DBEval( { || EjecutoReporte() }, bFor, bWhile, nNext, nRecord, lRest )

    ********* Imprimo los totales, si tiene ***********
    FOR nGroup := LEN(aReportData[RP_GROUPS]) TO 1 STEP -1

      ****** El grupo tiene subtotales? ********** 
      lAnySubTotals := .F.
      FOR nCol := 1 TO LEN(aReportData[RP_COLUMNS])
        IF aReportData[RP_COLUMNS,nCol,RC_TOTAL]
           lAnySubTotals := .T.
           EXIT           
        ENDIF
      NEXT

      IF !lAnySubTotals
        LOOP              
      ENDIF
  
      ************ Verifico salto de hoja **********
      IF nLinesLeft < 2
        EjectPage()
        IF aReportData[ RP_PLAIN ]
           nLinesLeft := 1000
        ELSE
           CabezalReporte()
        ENDIF
      ENDIF

      ********** Imprimo Mensaje de Subtotal **************
      PrintIt(IF(nGroup==1,NationMsg(_RF_SUBTOTAL), NationMsg(_RF_SUBSUBTOTAL)) , .t.)

      ***** Armo la linea de subtotales *****
      sAuxSt := ""
      FOR nCol := 1 TO LEN(aReportData[RP_COLUMNS])
        IF aReportData[RP_COLUMNS,nCol,RC_TOTAL]
           sAuxSt := sAuxSt + " " +  TRANSFORM(aReportTotals[nGroup+1,nCol], ConvPic(aReportData[RP_COLUMNS,nCol,RC_PICT]))
        ELSE
           sAuxSt := sAuxSt + " " + SPACE(aReportData[RP_COLUMNS,nCol,RC_WIDTH])
        ENDIF
      NEXT

      **** Imprimo la linea de subtotales ****
      ImprimoUnaLinea(Substr(sAuxSt,2), .t.)
      SaltoLin()

    NEXT

    ******* Genero el Total general ******
    **** Si me quedan menos de 2 lineas, salto de hoja  ****
    IF nLinesLeft < 2
      EjectPage()
      IF aReportData[ RP_PLAIN ]
        nLinesLeft := 1000
      ELSE
        CabezalReporte()
      ENDIF
    ENDIF

    *********** Veo si hay que imprimir totales ***********
    lAnyTotals := .F.
    FOR nCol := 1 TO LEN(aReportData[RP_COLUMNS])
      IF aReportData[RP_COLUMNS,nCol,RC_TOTAL]
        lAnyTotals := .T.
        EXIT
      ENDIF
    NEXT nCol


    IF lAnyTotals

       ********** Mensaje de total *************
       PrintIt(NationMsg(_RF_TOTAL ) , .t.)

       **** Armo la linea de totales ***** 
       sAuxSt := ""
       FOR nCol := 1 TO LEN(aReportData[RP_COLUMNS])
         IF aReportData[RP_COLUMNS,nCol,RC_TOTAL]
           sAuxSt := sAuxSt + " " + TRANSFORM(aReportTotals[1,nCol], ConvPic(aReportData[RP_COLUMNS,nCol,RC_PICT]))
         ELSE
           sAuxSt := sAuxSt + " " + SPACE(aReportData[RP_COLUMNS,nCol,RC_WIDTH])
         ENDIF
       NEXT nCol

       ImprimoUnaLinea(Substr(sAuxSt,2), .t.)
       SaltoLin()

    ENDIF

    ******* Si pidió un eject al final del reporte, lo largo *********
    IF aReportData[ RP_AEJECT ]
       EjectPage()
    ENDIF


RECOVER USING xBreakVal

  lBroke := .T.

END SEQUENCE

******** Libero memoria *********
aReportData   := NIL      
aReportTotals  := NIL
aGroupTotals   := NIL
nPageNumber   := NIL
lFirstPass    := NIL
nLinesLeft    := NIL
nMaxLinesAvail := NIL

****** Cierro el reporte *******
#ifdef _RF_MINIPRINT
  END PRINTPAGE
  END PRINTDOC
#endif
#ifdef _RF_HBPRINTER
  END PAGE
  END DOC
  RELEASE PRINTSYS
#endif

IF lBroke
 BREAK xBreakVal
END

RETURN

*******************************
STATIC PROCEDURE EjecutoReporte
*******************************
*  Ejecutado por DBEVAL() cada vez que un registro está en el scope 
LOCAL aRecordHeader  := {}          
LOCAL aRecordToPrint := {}          
LOCAL nCol                          
LOCAL nGroup                        
LOCAL lGroupChanged  := .F.         
LOCAL lEjectGrp := .F.              
LOCAL nMaxLines                     
LOCAL nLine                         
LOCAL cLine                         
LOCAL lAnySubTotals

******** si la columna tiene totales, los sumo ***********
FOR nCol := 1 TO LEN(aReportData[RP_COLUMNS])
  IF aReportData[RP_COLUMNS,nCol,RC_TOTAL]
     aReportTotals[ 1 ,nCol] += EVAL( aReportData[RP_COLUMNS,nCol,RC_EXP] )
  ENDIF
NEXT

********** veo si cambio alguno de los grupos. Si cambió, totalizo los anteriores *********
IF !lFirstPass    
  FOR nGroup := LEN(aReportData[RP_GROUPS]) TO 1 STEP -1
   lAnySubTotals := .F.
   FOR nCol := 1 TO LEN(aReportData[RP_COLUMNS])
     IF aReportData[RP_COLUMNS,nCol,RC_TOTAL]
        lAnySubTotals := .T.
        EXIT            
     ENDIF
   NEXT

   IF !lAnySubTotals
     LOOP        
   ENDIF

     ******** Veo si cambio el grupo *********
     IF HB_VALTOSTR(EVAL(aReportData[RP_GROUPS,nGroup,RG_EXP]),;
        aReportData[RP_GROUPS,nGroup,RG_TYPE]) != aGroupTotals[nGroup]
        AADD( aRecordHeader, IF(nGroup==1,NationMsg(_RF_SUBTOTAL),;
                                          NationMsg(_RF_SUBSUBTOTAL)) )
        AADD( aRecordHeader, "" )

        IF ( nGroup == 1 )
           lEjectGrp := aReportData[ RP_GROUPS, nGroup, RG_AEJECT ]
        ENDIF

        ********** Recorro las columnas totalizando *************
        FOR nCol := 1 TO LEN(aReportData[RP_COLUMNS])
           IF aReportData[RP_COLUMNS,nCol,RC_TOTAL]
              aRecordHeader[ LEN(aRecordHeader) ] += TRANSFORM(aReportTotals[nGroup+1,nCol], ConvPic(aReportData[RP_COLUMNS,nCol,RC_PICT]))
              aReportTotals[nGroup+1,nCol] := 0
           ELSE
              aRecordHeader[ LEN(aRecordHeader) ] += SPACE(aReportData[RP_COLUMNS,nCol,RC_WIDTH])
           ENDIF
           aRecordHeader[ LEN(aRecordHeader) ] += " "
        NEXT
        aRecordHeader[LEN(aRecordHeader)] := LEFT( aRecordHeader[LEN(aRecordHeader)], LEN(aRecordHeader[LEN(aRecordHeader)]) - 1 )
     ENDIF
  NEXT

ENDIF

lFirstPass = .F.

IF ( LEN( aRecordHeader ) > 0 ) .AND. lEjectGrp
  IF LEN( aRecordHeader ) > nLinesLeft
     EjectPage()

     IF ( aReportData[ RP_PLAIN ] )
        nLinesLeft := 1000
     ELSE
        CabezalReporte()
     ENDIF

  ENDIF

  AEVAL( aRecordHeader, { | HeaderLine | PrintIt(HeaderLine, .t. ) })

  aRecordHeader := {}

  EjectPage()

  IF ( aReportData[ RP_PLAIN ] )
     nLinesLeft := 1000

  ELSE
     CabezalReporte()
  ENDIF

ENDIF

********* Agrego un cabezal en los grupos que cambiaron **************
FOR nGroup := 1 TO LEN(aReportData[RP_GROUPS])
  IF HB_VALTOSTR(EVAL(aReportData[RP_GROUPS,nGroup,RG_EXP]),aReportData[RP_GROUPS,nGroup,RG_TYPE]) == aGroupTotals[nGroup]
  ELSE
     AADD( aRecordHeader, "" )   
     AADD( aRecordHeader, IF(nGroup==1,"** ","* ") +;
           aReportData[RP_GROUPS,nGroup,RG_HEADER] + " " +;
           HB_VALTOSTR(EVAL(aReportData[RP_GROUPS,nGroup,RG_EXP]), ;
           aReportData[RP_GROUPS,nGroup,RG_TYPE]) )
  ENDIF
NEXT

*********** Generé cabezal? ************
IF LEN( aRecordHeader ) > 0
  **** Si entra, lo imprimo ******
  IF LEN( aRecordHeader ) > nLinesLeft
     EjectPage()
     IF aReportData[ RP_PLAIN ]
        nLinesLeft := 1000
     ELSE
        CabezalReporte()
     ENDIF
  ENDIF

  ******** Imprimo cabezal *********** 
  AEVAL( aRecordHeader, { | HeaderLine | PrintIt(HeaderLine, .t. ) } )

  ******* Decremento las lineas disponibles *********
  nLinesLeft -= LEN( aRecordHeader )

  ******* Controlo el salto de hoja ***********
  IF nLinesLeft == 0
     EjectPage()
     IF aReportData[ RP_PLAIN ]
        nLinesLeft := 1000
     ELSE
        CabezalReporte()
     ENDIF
  ENDIF
ENDIF

************** Sumo los totales ********************
FOR nCol := 1 TO LEN(aReportData[RP_COLUMNS])
  IF aReportData[RP_COLUMNS,nCol,RC_TOTAL]
     FOR nGroup := 1 TO LEN( aReportTotals ) - 1
        aReportTotals[nGroup+1,nCol] += EVAL( aReportData[RP_COLUMNS,nCol,RC_EXP] )
     NEXT
  ENDIF
NEXT

************ Reseteo grupos ************
FOR nGroup := 1 TO LEN(aReportData[RP_GROUPS])
  aGroupTotals[nGroup] := HB_VALTOSTR(EVAL(aReportData[RP_GROUPS,nGroup,RG_EXP]),;
                                aReportData[RP_GROUPS,nGroup,RG_TYPE])
NEXT

IF !aReportData[ RP_SUMMARY ]
 **** Calculo cuantas lineas necesita **** 
 nMaxLines := 1
  FOR nCol := 1 TO LEN(aReportData[RP_COLUMNS])
     IF aReportData[RP_COLUMNS,nCol,RC_TYPE] $ "CM"
        nMaxLines := MAX(XMLCOUNT(EVAL(aReportData[RP_COLUMNS,nCol,RC_EXP]),;
                     aReportData[RP_COLUMNS,nCol,RC_WIDTH]), nMaxLines)
     ENDIF
  NEXT

  ********* Defino un array con la cantidad de lineas necesarias para imprimir *****
  ASIZE( aRecordToPrint, nMaxLines )
  AFILL( aRecordToPrint, "" )

  ***** Cargo el registro en el array para imprimir ************
  FOR nCol := 1 TO LEN(aReportData[RP_COLUMNS])
     FOR nLine := 1 TO nMaxLines
        ***** Cargo las variables tipo MEMO o CHARACTER **********
        IF aReportData[RP_COLUMNS,nCol,RC_TYPE] $ "CM"
           cLine := XMEMOLINE(TRIM(EVAL(aReportData[RP_COLUMNS,nCol,RC_EXP])),;
                         aReportData[RP_COLUMNS,nCol,RC_WIDTH], nLine )
           cLine := PADR( cLine, aReportData[RP_COLUMNS,nCol,RC_WIDTH] )
        ELSE
           IF nLine == 1
               ********* Aqui le puse los separadores de miles, que no está por defecto en los frm
               ********* Si se desea quitar, descomentar estas líneas y comentar las siguientes 
*                  cLine := TRANSFORM(EVAL(aReportData[RP_COLUMNS,nCol,RC_EXP]),;
*                           aReportData[RP_COLUMNS,nCol,RC_PICT])
               cLine := TRANSFORM(EVAL(aReportData[RP_COLUMNS,nCol,RC_EXP]),;
                        ConvPic(aReportData[RP_COLUMNS,nCol,RC_PICT]))

              cLine := PADR( cLine, aReportData[RP_COLUMNS,nCol,RC_WIDTH] )
           ELSE
              cLine := SPACE( aReportData[RP_COLUMNS,nCol,RC_WIDTH])
           ENDIF
        ENDIF
        IF nCol > 1
           aRecordToPrint[ nLine ] += " "
        ENDIF
        aRecordToPrint[ nLine ] += cLine
     NEXT
  NEXT

  ********* Entra el registro en la página?? ********
  IF LEN( aRecordToPrint ) > nLinesLeft
     ***** Si no entra en la página actual, verifico si entra en una página completa
     ***** Si no entra: Lo parto y lo imprimo
     IF LEN( aRecordToPrint ) > nMaxLinesAvail
        nLine := 1
        DO WHILE nLine < LEN( aRecordToPrint )
           PrintIt(aRecordToPrint[nLine], .f. )
           nLine++
           nLinesLeft--
           IF nLinesLeft == 0
              EjectPage()
              IF aReportData[ RP_PLAIN ]
                 nLinesLeft := 1000
              ELSE
                 CabezalReporte()
              ENDIF
           ENDIF
        ENDDO
     ELSE
        EjectPage()
        IF aReportData[ RP_PLAIN ]
           nLinesLeft := 1000
        ELSE
           CabezalReporte()
        ENDIF
        AEVAL( aRecordToPrint, ;
           { | RecordLine | ;
             PrintIt(RecordLine, .f. ) ;
           } ;
        )
        nLinesLeft -= LEN( aRecordToPrint )
     ENDIF
  ELSE
     AEVAL( aRecordToPrint, ;
        { | RecordLine | ;
          PrintIt(RecordLine, .f. ) ;
        } ;
     )
     nLinesLeft -= LEN( aRecordToPrint )
  ENDIF

  ***** Verifico salto de hoja ******
  IF nLinesLeft == 0
     EjectPage()
     IF aReportData[ RP_PLAIN ]
        nLinesLeft := 1000
     ELSE
        CabezalReporte()
     ENDIF
  ENDIF

  **** Si seleccionó espaciado distinto de 1, dejo los renglones en blanco *******
  IF aReportData[ RP_SPACING ] > 1
     IF nLinesLeft > aReportData[ RP_SPACING ] - 1
        FOR nLine := 2 TO aReportData[ RP_SPACING ]
           PrintIt("", .f.)
           nLinesLeft--
        NEXT
     ENDIF
  ENDIF

ENDIF  

RETURN


********************************
STATIC PROCEDURE CabezalReporte
********************************
LOCAL nLinesInHeader := 0
LOCAL aPageHeader    := {}
LOCAL nHeadingLength := aReportData[RP_WIDTH] - aReportData[RP_LMARGIN] - 30
LOCAL nCol, nLine, nMaxColLength, cHeader
LOCAL nHeadLine            
LOCAL nRPageSize           
LOCAL aTempPgHeader        

nRPageSize := aReportData[RP_WIDTH] - aReportData[RP_RMARGIN]

****** Creo el cabezal y lo pongo en el array aPageHeader *****

IF aReportData[RP_HEADING] == "" 
   AADD( aPageHeader, NationMsg(_RF_PAGENO) + STR(nPageNumber,6) )
ELSE
   aTempPgHeader := ParseHeader( aReportData[ RP_HEADING ], Occurs( ";", aReportData[ RP_HEADING ] ) + 1 )

   FOR nLine := 1 TO LEN( aTempPgHeader )
       **** Calculo cuantas lineas lleva el cabezal ****
       nLinesInHeader := MAX( XMLCOUNT( LTRIM( aTempPgHeader[ nLine ] ),  nHeadingLength ), 1 )

       ****** Agrego las líneas del cabezal al array ***** 
       FOR nHeadLine := 1 TO nLinesInHeader
            AADD( aPageHeader, SPACE( 15 ) + PADC( TRIM( XMEMOLINE( LTRIM( aTempPgHeader[ nLine ] ),;
                 nHeadingLength, nHeadLine ) ), nHeadingLength ) )
       NEXT nHeadLine

   NEXT nLine
   aPageHeader[ 1 ] := STUFF( aPageHeader[ 1 ], 1, 14, NationMsg(_RF_PAGENO) + STR(nPageNumber,6) )
 
ENDIF
AADD( aPageHeader, DTOC(DATE()) )


********** Agrego el header ************ 
FOR nLine := 1 TO LEN( aReportData[RP_HEADER] )
  ****** calculo la cantidad de lineas necesarias ********** 
  nLinesInHeader := MAX( XMLCOUNT( LTRIM( aReportData[RP_HEADER, nLine ] ), nRPageSize ), 1 )
   
  **** Lo agrego al array *******  
  FOR nHeadLine := 1 TO nLinesInHeader
     cHeader := TRIM( XMEMOLINE( LTRIM( aReportData[ RP_HEADER, nLine ] ), nRPageSize, nHeadLine) )
     AADD( aPageHeader, SPACE( ( nRPageSize - aReportData[ RP_LMARGIN ] - LEN( cHeader ) ) / 2 ) + cHeader )
  NEXT nHeadLine

NEXT nLine

******** Agrego cabezales de las columnas *********
nLinesInHeader := LEN( aPageHeader )

**** Busco el cabezal mas ancho ***** 
nMaxColLength := 0
FOR nCol := 1 TO LEN( aReportData[ RP_COLUMNS ] )
   nMaxColLength := MAX( LEN(aReportData[RP_COLUMNS,nCol,RC_HEADER]), nMaxColLength )
NEXT
FOR nCol := 1 TO LEN( aReportData[ RP_COLUMNS ] )
  ASIZE( aReportData[RP_COLUMNS,nCol,RC_HEADER], nMaxColLength )
NEXT

FOR nLine := 1 TO nMaxColLength
  AADD( aPageHeader, "" )
NEXT

FOR nCol := 1 TO LEN(aReportData[RP_COLUMNS]) 
  FOR nLine := 1 TO nMaxColLength
     IF nCol > 1
        aPageHeader[ nLinesInHeader + nLine ] += " "
     ENDIF
     IF aReportData[RP_COLUMNS,nCol,RC_HEADER,nLine] == NIL
        aPageHeader[ nLinesInHeader + nLine ] += SPACE( aReportData[RP_COLUMNS,nCol,RC_WIDTH] )
     ELSE
        IF aReportData[RP_COLUMNS,nCol,RC_TYPE] == "N"
           aPageHeader[ nLinesInHeader + nLine ] += PADL(aReportData[RP_COLUMNS,nCol,RC_HEADER,nLine],;
                       aReportData[RP_COLUMNS,nCol,RC_WIDTH])
        ELSE
           aPageHeader[ nLinesInHeader + nLine ] += PADR(aReportData[RP_COLUMNS,nCol,RC_HEADER,nLine],;
                       aReportData[RP_COLUMNS,nCol,RC_WIDTH])
        ENDIF
     ENDIF
  NEXT
NEXT

***** Dejo 2 lineas en blanco ******
AADD( aPageHeader, "" )
AADD( aPageHeader, "" )

******** Imprimo el cabezal **********
AEVAL( aPageHeader, { | HeaderLine | PrintIt(HeaderLine, .t. ) } )

*** Incremento el numero de pagina ****
nPageNumber++

nLinesLeft := aReportData[RP_LINES] - LEN( aPageHeader )
nMaxLinesAvail := aReportData[RP_LINES] - LEN( aPageHeader )

RETURN

******************************************
STATIC FUNCTION Occurs( cSearch, cTarget )
******************************************
*  Cuantas veces aparece <cSearch> en <cTarget>

LOCAL nPos, nCount := 0
DO WHILE !EMPTY( cTarget )
   IF (nPos := AT( cSearch, cTarget )) != 0
      nCount++
      cTarget := SUBSTR( cTarget, nPos + 1 )
   ELSE     
      cTarget := ""
   ENDIF
ENDDO
RETURN nCount


******************************************
STATIC PROCEDURE PrintIt( cString, lBold )
******************************************
IF cString == NIL
   cString := ""
ENDIF

ImprimoUnaLinea(cString , lBold)
SaltoLin()

RETURN

**************************
STATIC PROCEDURE EjectPage
**************************
*  Finalizo una página y comienzo la siguiente.....
#ifdef _RF_MINIPRINT
  END PRINTPAGE
  START PRINTPAGE
#ENDIF

#ifdef _RF_HBPRINTER
  END PAGE
  START PAGE 
#ENDIF

nPosRow := _RF_FIRSTROW
RETURN

*****************************************************************
STATIC FUNCTION XMLCOUNT( cString, nLineLength, nTabSize, lWrap )
*****************************************************************
nLineLength := IF( nLineLength == NIL, 79, nLineLength )
nTabSize := IF( nTabSize == NIL, 4, nTabSize )
lWrap := IF( lWrap == NIL, .T., .F. )
IF nTabSize >= nLineLength
   nTabSize := nLineLength - 1
ENDIF
RETURN( MLCOUNT( TRIM(cString), nLineLength, nTabSize, lWrap ) )

*******************************************************************************
STATIC FUNCTION XMEMOLINE( cString, nLineLength, nLineNumber, nTabSize, lWrap )
*******************************************************************************
nLineLength := IF( nLineLength == NIL, 79, nLineLength )
nLineNumber := IF( nLineNumber == NIL, 1, nLineNumber )
nTabSize := IF( nTabSize == NIL, 4, nTabSize )
lWrap := IF( lWrap == NIL, .T., lWrap )

IF nTabSize >= nLineLength
   nTabSize := nLineLength - 1
ENDIF
RETURN( MEMOLINE( cString, nLineLength, nLineNumber, nTabSize, lWrap ) )



******************************
STATIC FUNCTION ConvPic(sPic)
******************************
* Agrego separador de miles, que el FRM estandar no lo hace....
* Ojo, esto puede hacer que de un overflow si no se prevee el espacio en la columna

Local nPto, nEnt, nDec, sResult
Local aPics := {"9","99","999","9999","9,999","99,999","999,999","9999,999","9,999,999","99,999,999","999,999,999","9999,999,999","9,999,999,999","99,999,999,999","999,999,999,999"}

nPto = at(".",sPic)

If (Left(sPic,1) <> "9") .or. (nPto = 0)
   Return sPic
ENDIF

nDec = Substr(sPic, nPto)
nEnt = Left(sPic, nPto - 1)

If Len(nEnt) > 15
   sResult = sPic
ELSE
   sResult = aPics[Len(nEnt)] + nDec
ENDIF
Return sResult


*****************************
Function SaltoLin()
*****************************
nPosRow := nPosRow + _RF_ROWINC
nPosCol := _RF_FIRSTCOL 
Return .t.

*************************************
Function ImprimoUnaLinea(sLin, lBold)
*************************************
Private sAux , nFontSize

#ifdef _RF_MINIPRINT
    If aReportData[RP_WIDTH] <= 80
       nFontSize := _RF_SIZENORMAL
    ELSE
       nFontSize := _RF_SIZECONDENSED
    ENDIF
#ENDIF
 
#ifdef _RF_HBPRINTER
    If aReportData[RP_WIDTH] <= 80
       DEFINE FONT "normal"      name _RF_FONT size _RF_SIZENORMAL
       DEFINE FONT "negrita"      name _RF_FONT size _RF_SIZENORMAL  bold
    ELSE
       DEFINE FONT "normal"      name _RF_FONT size _RF_SIZECONDENSED
       DEFINE FONT "negrita"      name _RF_FONT size _RF_SIZECONDENSED  bold
    ENDIF
#ENDIF 


sAux := HB_OEMTOANSI(sLin)

#ifdef _RF_MINIPRINT
If lBold 
   @ nPosRow, nPosCol + RP_LMARGIN PRINT sAux  font _RF_FONT size nFontSize bold
ELSE
   @ nPosRow, nPosCol + RP_LMARGIN PRINT sAux  font _RF_FONT size nFontSize
ENDIF
#ENDIF 


#ifdef _RF_HBPRINTER
If lBold 
   @ nPosRow, nPosCol + RP_LMARGIN say sAux  font "normal"  to print
ELSE
   @ nPosRow, nPosCol + RP_LMARGIN say sAux  font "negrita" to print
ENDIF
#ENDIF 


nPosCol := nPosCol + Len(sAux) 


Return .t.


******************************
FUNCTION __FrmLoad( cFrmFile )
******************************
* Cargo el archivo FRM en un array

LOCAL cFieldsBuff
LOCAL cParamsBuff
LOCAL nFieldOffset   := 0
LOCAL cFileBuff      := SPACE(SIZE_FILE_BUFF)
LOCAL cGroupExp      := SPACE(200)
LOCAL cSubGroupExp   := SPACE(200)
LOCAL nColCount      := 0        
LOCAL nCount
LOCAL nFrmHandle                 
LOCAL nBytesRead                 
LOCAL nPointer       := 0        
LOCAL nFileError                 
LOCAL cOptionByte                

LOCAL aReport[ RP_COUNT ]        
LOCAL err                        

LOCAL cDefPath         
LOCAL aPaths           
LOCAL nPathIndex := 0  

LOCAL aHeader		  
LOCAL nHeaderIndex	  

cLengthsBuff  := ""
cOffsetsBuff  := ""
cExprBuff     := ""

********** Valores por defecto ***********
aReport[ RP_HEADER ]    := {}
aReport[ RP_WIDTH ]     := 80
aReport[ RP_LMARGIN ]   := 8
aReport[ RP_RMARGIN ]   := 0
aReport[ RP_LINES ]     := 58
aReport[ RP_SPACING ]   := 1
aReport[ RP_BEJECT ]    := .F.
aReport[ RP_AEJECT ]    := .F.
aReport[ RP_PLAIN ]     := .F.
aReport[ RP_SUMMARY ]   := .F.
aReport[ RP_COLUMNS ]   := {}
aReport[ RP_GROUPS ]    := {}
aReport[ RP_HEADING ]   := ""

******** Abro el FRM ********** 
nFrmHandle := FOPEN( cFrmFile )

IF ( !EMPTY( nFileError := FERROR() ) ) .AND. !( "\" $ cFrmFile .OR. ":" $ cFrmFile )

  **** Busco en el path ********
  cDefPath := SET( _SET_DEFAULT ) + ";" + SET( _SET_PATH )
  cDefPath := STRTRAN( cDefPath, ",", ";" )
  aPaths := ListAsArray( cDefPath, ";" )

  FOR nPathIndex := 1 TO LEN( aPaths )
     nFrmHandle := FOPEN( aPaths[ nPathIndex ] + "\" + cFrmFile )
     IF EMPTY( nFileError := FERROR() )
        EXIT
     ENDIF
  NEXT nPathIndex

ENDIF

******* No pude abrirlo? ********
IF nFileError != F_OK
  err := ErrorNew()
  err:severity := ES_ERROR
  err:genCode := EG_OPEN
  err:subSystem := "FRMLBL"
  err:osCode := nFileError
  err:filename := cFrmFile
  Eval(ErrorBlock(), err)
ENDIF

******* Pude abrirlo? ******** 
IF nFileError = F_OK

  FSEEK(nFrmHandle, 0)

  nFileError = FERROR()
  IF nFileError = F_OK

     **** Cargo el FRM al buffer **** 
     nBytesRead = FREAD(nFrmHandle, @cFileBuff, SIZE_FILE_BUFF)
     IF nBytesRead = 0
        nFileError = F_EMPTY      
     ELSE
        nFileError = FERROR()     
     ENDIF

     IF nFileError = F_OK
        *** Verifico que sea un FRM ****
        IF BIN2W(SUBSTR(cFileBuff, 1, 2)) = 2 .AND.;
          BIN2W(SUBSTR(cFileBuff, SIZE_FILE_BUFF - 1, 2)) = 2
           nFileError = F_OK
        ELSE
           nFileError = F_ERROR
        ENDIF

     ENDIF

  ENDIF

  ******* Cierro el archivo ********* 
  IF !FCLOSE(nFrmHandle)
     nFileError = FERROR()
  ENDIF

ENDIF

****** Todo ok *********
IF nFileError = F_OK

   ***** Cargo el FRM en los buffers *******
   cLengthsBuff = SUBSTR(cFileBuff, LENGTHS_OFFSET, SIZE_LENGTHS_BUFF)
   cOffsetsBuff = SUBSTR(cFileBuff, OFFSETS_OFFSET, SIZE_OFFSETS_BUFF)
   cExprBuff    = SUBSTR(cFileBuff, EXPR_OFFSET, SIZE_EXPR_BUFF)
   cFieldsBuff  = SUBSTR(cFileBuff, FIELDS_OFFSET, SIZE_FIELDS_BUFF)
   cParamsBuff  = SUBSTR(cFileBuff, PARAMS_OFFSET, SIZE_PARAMS_BUFF)

   aReport[ RP_WIDTH ]   := BIN2W(SUBSTR(cParamsBuff, PAGE_WIDTH_OFFSET, 2))
   aReport[ RP_LINES ]   := BIN2W(SUBSTR(cParamsBuff, LNS_PER_PAGE_OFFSET, 2))
   aReport[ RP_LMARGIN ] := BIN2W(SUBSTR(cParamsBuff, LEFT_MRGN_OFFSET, 2))
   aReport[ RP_RMARGIN ] := BIN2W(SUBSTR(cParamsBuff, RIGHT_MGRN_OFFSET, 2))

   nColCount  = BIN2W(SUBSTR(cParamsBuff, COL_COUNT_OFFSET, 2))
   * Espaciado
   aReport[ RP_SPACING ] := IF(SUBSTR(cParamsBuff, DBL_SPACE_OFFSET, 1) $ "YyTt", 2, 1)
   * Resumen? 
   aReport[ RP_SUMMARY ] := IF(SUBSTR(cParamsBuff, SUMMARY_RPT_OFFSET, 1) $ "YyTt", .T., .F.)
   cOptionByte = ASC(SUBSTR(cParamsBuff, OPTION_OFFSET, 1))
   * Eject antes?
   IF INT(cOptionByte / 2) = 1
      aReport[ RP_AEJECT ] := .T.  
      cOptionByte -= 2
   ENDIF
   nPointer = BIN2W(SUBSTR(cParamsBuff, PAGE_HDR_OFFSET, 2))
   nHeaderIndex := 4
   aHeader := ParseHeader( GetExpr( nPointer ), nHeaderIndex )
   * Elimino los cabezales vacíos...
   DO WHILE ( nHeaderIndex > 0 )
      IF ! EMPTY( aHeader[ nHeaderIndex ] )
			EXIT
	  ENDIF
	  nHeaderIndex--
   ENDDO

   aReport[ RP_HEADER ] := IIF( EMPTY( nHeaderIndex ) , {}, ASIZE( aHeader, nHeaderIndex ) )

   nPointer = BIN2W(SUBSTR(cParamsBuff, GRP_EXPR_OFFSET, 2))

   IF !EMPTY(cGroupExp := GetExpr( nPointer ))

      ** Agrego un grupo ... 
      AADD( aReport[ RP_GROUPS ], ARRAY( RG_COUNT ))
      aReport[ RP_GROUPS ][1][ RG_TEXT ] := cGroupExp
      aReport[ RP_GROUPS ][1][ RG_EXP ] := &( "{ || " + cGroupExp + "}" )
      IF USED()
         aReport[ RP_GROUPS ][1][ RG_TYPE ] := VALTYPE( EVAL( aReport[ RP_GROUPS ][1][ RG_EXP ] ) )
      ENDIF
      * Cabezal del grupo
      nPointer = BIN2W(SUBSTR(cParamsBuff, GRP_HDR_OFFSET, 2))
      aReport[ RP_GROUPS ][1][ RG_HEADER ] := GetExpr( nPointer )
      * Salto de hoja al finalizar el grupo? 
      aReport[ RP_GROUPS ][1][ RG_AEJECT ] := IF(SUBSTR(cParamsBuff, PE_OFFSET, 1) $ "YyTt", .T., .F.)

   ENDIF

   * Hay Subgrupos? 
   nPointer = BIN2W(SUBSTR(cParamsBuff, SUB_EXPR_OFFSET, 2))

   IF !EMPTY(cSubGroupExp := GetExpr( nPointer ))

      * Agrego el subgrupo
      AADD( aReport[ RP_GROUPS ], ARRAY( RG_COUNT ))
      aReport[ RP_GROUPS ][2][ RG_TEXT ] := cSubGroupExp
      aReport[ RP_GROUPS ][2][ RG_EXP ] := &( "{ || " + cSubGroupExp + "}" )
      IF USED()
         aReport[ RP_GROUPS ][2][ RG_TYPE ] := VALTYPE( EVAL( aReport[ RP_GROUPS ][2][ RG_EXP ] ) )
      ENDIF

      * Cabezal del subgrupo 
      nPointer = BIN2W(SUBSTR(cParamsBuff, SUB_HDR_OFFSET, 2))
      aReport[ RP_GROUPS ][2][ RG_HEADER ] := GetExpr( nPointer )
      * Salto de hoja al finalizar el subgrupo?
      aReport[ RP_GROUPS ][2][ RG_AEJECT ] := .F.

   ENDIF

   ********* Agrego columnas ************
   nFieldOffset := 12  
   FOR nCount := 1 to nColCount
      AADD( aReport[ RP_COLUMNS ], GetColumn( cFieldsBuff, @nFieldOffset ) )
   NEXT nCount

ENDIF

RETURN aReport

**********************************************
FUNCTION ParseHeader( cHeaderString, nFields )
**********************************************
LOCAL cItem
LOCAL nItemCount := 0
LOCAL aPageHeader := {}
LOCAL nHeaderLen := 254
LOCAL nPos

DO WHILE ( ++nItemCount <= nFields )
	cItem := SUBSTR( cHeaderString, 1, nHeaderLen )
	* Busco delimitador....
	nPos := AT( ";", cItem )
	IF ! EMPTY( nPos )
		AADD( aPageHeader, SUBSTR( cItem, 1, nPos - 1 ) )
	ELSE
		IF EMPTY( cItem )
			AADD( aPageHeader, "" )
		ELSE
			AADD( aPageHeader, cItem )
		ENDIF
		nPos := nHeaderLen
	ENDIF
	cHeaderString := SUBSTR( cHeaderString, nPos + 1 )
ENDDO

RETURN( aPageHeader )

***********************************
STATIC FUNCTION GetExpr( nPointer )
***********************************
   LOCAL nExprOffset   := 0
   LOCAL nExprLength   := 0
   LOCAL nOffsetOffset := 0
   LOCAL cString := ""

   IF nPointer != 65535
      nPointer++

      IF nPointer > 1
         nOffsetOffset = (nPointer * 2) - 1
      ENDIF

      nExprOffset = BIN2W(SUBSTR(cOffsetsBuff, nOffsetOffset, 2))
      nExprLength = BIN2W(SUBSTR(cLengthsBuff, nOffsetOffset, 2))

      nExprOffset++
      nExprLength--

      cString = SUBSTR(cExprBuff, nExprOffset, nExprLength)

      IF CHR(0) == SUBSTR(cString, 1, 1) .AND. LEN(SUBSTR(cString,1,1)) = 1
         cString = ""
      ENDIF
   ENDIF

   RETURN (cString)


***************************************************
STATIC FUNCTION GetColumn( cFieldsBuffer, nOffset )
***************************************************
LOCAL nPointer := 0, nNumber := 0, aColumn[ RC_COUNT ], cType

** Ancho de la columna 
aColumn[ RC_WIDTH ] := BIN2W(SUBSTR(cFieldsBuffer, nOffset + FIELD_WIDTH_OFFSET, 2))

** tiene totales?
aColumn[ RC_TOTAL ] := IF(SUBSTR(cFieldsBuffer, nOffset + FIELD_TOTALS_OFFSET, 1) $ "YyTt", .T., .F.)

** Cantidad de decimales 
aColumn[ RC_DECIMALS ] := BIN2W(SUBSTR(cFieldsBuffer, nOffset + FIELD_DECIMALS_OFFSET, 2))

** Expresión con Contenido de la columna
nPointer = BIN2W(SUBSTR(cFieldsBuffer, nOffset + FIELD_CONTENT_EXPR_OFFSET, 2))
aColumn[ RC_TEXT ] := GetExpr( nPointer )
aColumn[ RC_EXP ] := &( "{ || " + GetExpr( nPointer ) + "}" )

** Cabezal de la columna 
nPointer = BIN2W(SUBSTR(cFieldsBuffer, nOffset + FIELD_HEADER_EXPR_OFFSET, 2))

aColumn[ RC_HEADER ] := ListAsArray(GetExpr( nPointer ), ";")

** Picture de la columna 
IF USED()
  cType := VALTYPE( EVAL(aColumn[ RC_EXP ]) )
  aColumn[ RC_TYPE ] := cType
  DO CASE
  CASE cType = "C" .OR. cType = "M"
     aColumn[ RC_PICT ] := REPLICATE("X", aColumn[ RC_WIDTH ])
  CASE cType = "D"
     aColumn[ RC_PICT ] := "@D"
  CASE cType = "N"
     IF aColumn[ RC_DECIMALS ] != 0
        aColumn[ RC_PICT ] := REPLICATE("9", aColumn[ RC_WIDTH ] - aColumn[ RC_DECIMALS ] -1) + "." + REPLICATE("9", aColumn[ RC_DECIMALS ])
     ELSE
        aColumn[ RC_PICT ] := REPLICATE("9", aColumn[ RC_WIDTH ])
     ENDIF
  CASE cType = "L"
     aColumn[ RC_PICT ] := "@L" + REPLICATE("X",aColumn[ RC_WIDTH ]-1)
  ENDCASE
ENDIF

nOffset += 12

RETURN ( aColumn )

*************************************************
STATIC FUNCTION ListAsArray( cList, cDelimiter )
*************************************************
* Convierto un string delimitado (por comas) a un array
LOCAL nPos
LOCAL aList := {}            
LOCAL lDelimLast := .F.

IF cDelimiter == NIL
  cDelimiter := ","
ENDIF

DO WHILE ( LEN(cList) <> 0 )

  nPos := AT(cDelimiter, cList)

  IF ( nPos == 0 )
     nPos := LEN(cList)
  ENDIF

  IF ( SUBSTR( cList, nPos, 1 ) == cDelimiter )
     lDelimLast := .T.
     AADD(aList, SUBSTR(cList, 1, nPos - 1))
  ELSE
     lDelimLast := .F.
     AADD(aList, SUBSTR(cList, 1, nPos)) 
  ENDIF

  cList := SUBSTR(cList, nPos + 1)

ENDDO

IF ( lDelimLast )
  AADD(aList, "")
ENDIF

RETURN aList 
