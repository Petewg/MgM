/*
  MINIGUI - Harbour Win32 GUI library Demo/Sample
 
  Copyright 2002-06 Roberto Lopez <harbourminigui@gmail.com>
  http://harbourminigui.googlepages.com/

  SUIZO miniprint_list es Freevare. 

  Desarrollado con Harbour Compiler y
  MINIGUI - Harbour Win32 GUI library (HMG).

  Copyright 2006 Jose Miguel <josemisu@yahoo.com.ar>
*/

#include "minigui.ch"
#include "miniprint.ch"

FIELD CODTAR, NOMTAR, IMPORTE

MEMVAR TituloImp

PROCEDURE main()
   Local N, aArq:={}

   ***CODIGO DE PAGINA español***
   REQUEST HB_CODEPAGE_ESWIN
   HB_SETCODEPAGE("ESWIN")

   ***Inicializacion RDD DBFCDX Nativo***
   REQUEST DBFCDX , DBFFPT
   RDDSETDEFAULT( "DBFCDX" )

   ***DATOS DE INICIALIZACION***
   Set Navigation Extended //TAB y ENTER
   SET DATE FORMAT "dd-mm-yyyy"
   SET EPOCH TO YEAR(DATE())-50

   ***crear fichero de datos para este ejemplo***
   IF .NOT. FILE("TARIFAS.DBF")
      Aadd( aArq , { 'CODTAR'    , 'C' , 10  , 0 } )
      Aadd( aArq , { 'NOMTAR'    , 'C' , 50  , 0 } )
      Aadd( aArq , { 'IMPORTE'   , 'N' , 13  , 2 } )
      DBCreate( "TARIFAS" , aArq  )
      Use TARIFAS Alias TARIFAS new
      FOR N=1 TO 50
         APPEND BLANK
         REPLACE CODTAR WITH "E"+STRZERO(N,3)
         REPLACE NOMTAR WITH "Nombre articulo "+LTRIM(STR(N))
         REPLACE IMPORTE WITH N+1000
      NEXT
      TARIFAS->( DBCLOSEAREA() )
   ENDIF
   ***fin crear fichero de datos para este ejemplo***

   ***crear fichero indice para este ejemplo***
   Use TARIFAS Alias TARIFAS New Shared
   Index On CODTAR TAG ORDEN1 To TARIFAS.CDX
   ***fin crear fichero indice para este ejemplo***

   Lis_TarCodigo()

Return

PROCEDURE Lis_TarCodigo()
   Local aIMP
   Private TituloImp:="Listado de tarifas"

   DEFINE WINDOW W_Imp1 ;
      AT 10,10 ;
      WIDTH 400 HEIGHT 275 ;
      TITLE 'SUIZO miniprint_list v1.0 - Imprimir: '+TituloImp ;
      MAIN      ;
      ON RELEASE CloseTables()

      @ 15,10 LABEL L_CodTar1 ;
              VALUE 'Desde codigo' ;
              WIDTH 90 HEIGHT 25
      @ 10,100 TEXTBOX T_CodTar1 ;
              WIDTH 100 ;
              VALUE 'E001' ;
              TOOLTIP 'Codigo tarifa' ;
              MAXLENGTH 10

      @ 10,250 BUTTON B_Acerca CAPTION 'Aceca de' WIDTH 90 HEIGHT 25 ;
               ACTION Acercade()

      @ 45,10 LABEL L_CodTar2 ;
              VALUE 'Hasta codigo' ;
              WIDTH 90 HEIGHT 25
      @ 40,100 TEXTBOX T_CodTar2 ;
              WIDTH 100 ;
              VALUE 'E050' ;
              TOOLTIP 'Codigo tarifa' ;
              MAXLENGTH 10

      @ 70,10 CHECKBOX C_Cuadro ;
            CAPTION 'Imprimir cuadros en lineas' ;
            WIDTH 200 VALUE .F.

      draw rectangle in window W_Imp1 at 110,010 to 112,390 fillcolor{255,0,0} //Rojo

      aIMP:=Impresoras()

      @125,10 LABEL L_Impresora ;
              VALUE 'Impresora' ;
              WIDTH 90 HEIGHT 25
      @120,100 COMBOBOX C_Impresora ;
            WIDTH 280 ;
            ITEMS aIMP[1] ;
            VALUE aIMP[3] ;
            TOOLTIP 'Impresora' NOTABSTOP

      @150, 10 CHECKBOX nImp CAPTION 'Seleccionar impresora' ;
               width 160 value .f. ;
               ON CHANGE W_Imp1.C_Impresora.Enabled:=IF(W_Imp1.nImp.Value=.T.,.F.,.T.)

      @180, 10 CHECKBOX nVer CAPTION 'Previsualizar documento' ;
               width 160 value .f.

      @210, 10 BUTTON B_Imp CAPTION 'Imprimir' WIDTH 90 HEIGHT 25 ;
               ACTION Lis_TarCodigoi("IMPRESORA")

      @210,110 BUTTON B_Excel CAPTION 'Hoja excel' WIDTH 90 HEIGHT 25 ;
               ACTION Lis_TarCodigoi("EXCEL")

      @210,210 BUTTON B_Can CAPTION 'Cancelar'  WIDTH 90 HEIGHT 25 ;
               ACTION W_Imp1.release

      END WINDOW
      CENTER WINDOW W_Imp1
      ACTIVATE WINDOW W_Imp1

Return


Procedure CloseTables()
   CLOSE DATABASES
   FERASE('TARIFAS.CDX')
   IF FILE("FIN.DBF")
      ERASE FIN.DBF
      ERASE FIN.CDX
   ENDIF
Return


procedure Lis_TarCodigoi(LLAMADA)

   SELEC("Tarifas")

   SET FILTER TO
   COPY TO FIN FOR ;
	CODTAR>=W_Imp1.T_CodTar1.value .AND. CODTAR<=W_Imp1.T_CodTar2.value

   Use FIN Alias FIN New Shared
   INDEX ON CODTAR TO FIN

   GO TOP
   IF LASTREC()=0
      MsgExclamation("No hay datos en las fecha introducidas","Informacion")
      FIN->( DBCLOSEAREA() )
      RETURN
   ENDIF

   IF LLAMADA="EXCEL"
      Lis_TarCodigoiE()
   ELSE
      Lis_TarCodigoiF()
   ENDIF

Return


procedure Lis_TarCodigoiF()
   Local dirimp:=GetCurrentFolder(), nomimp2, PAG, LIN

   IF W_Imp1.nImp.value=.t.
      nomimp2:=GetPrinter()
      IF W_Imp1.nVer.value=.t.
         SELECT PRINTER nomimp2 ORIENTATION PRINTER_ORIENT_PORTRAIT PREVIEW
      ELSE
         SELECT PRINTER nomimp2 ORIENTATION PRINTER_ORIENT_PORTRAIT
      ENDIF
   ELSE
      IF W_Imp1.C_Impresora.ItemCount=0 .OR. ;
         W_Imp1.C_Impresora.Value<=0 .OR. ;
         W_Imp1.C_Impresora.Value>W_Imp1.C_Impresora.ItemCount
         MsgStop("No hay impresoras instaladas","Error")
         release printsys
         SetCurrentFolder(dirimp)
         RETURN
      ENDIF
      IF W_Imp1.nVer.value=.t.
         SELECT PRINTER W_Imp1.C_Impresora.Item(W_Imp1.C_Impresora.Value) ORIENTATION PRINTER_ORIENT_PORTRAIT PREVIEW
      ELSE
         SELECT PRINTER W_Imp1.C_Impresora.Item(W_Imp1.C_Impresora.Value) ORIENTATION PRINTER_ORIENT_PORTRAIT
      ENDIF
   ENDIF

   START PRINTDOC NAME TituloImp
   START PRINTPAGE

GO TOP
PAG:=0
LIN:=0
DO WHILE .NOT. EOF()
   IF LIN>=260 .OR. PAG=0
      IF PAG<>0
         @ LIN+5,105 PRINT "SIGUE EN LA HOJA: "+LTRIM(STR(PAG+1)) CENTER
         END PRINTPAGE
         START PRINTPAGE
      ENDIF
      PAG++

      @ 20,20 PRINT "SUIZO miniprint_list v1.0"
      @ 20,190 PRINT "Hoja: "+LTRIM(STR(PAG)) RIGHT
      @ 25,20 PRINT DATE()

      @ 25,105 PRINT "Nombre de la empresa" CENTER
      @ 35,105 PRINT TituloImp FONT "ft18" CENTER

      @ 40,20 PRINT 'desde: '+W_Imp1.T_CodTar1.value
      @ 45,20 PRINT 'hasta: '+W_Imp1.T_CodTar2.value

      LIN:=55
      IF W_Imp1.C_Cuadro.Value=.T.
         @ LIN, 19 PRINT RECTANGLE TO LIN+5, 39
         @ LIN, 39 PRINT RECTANGLE TO LIN+5,109
         @ LIN,109 PRINT RECTANGLE TO LIN+5,141
      ELSE
         @ LIN+4,20 PRINT LINE TO LIN+4,140
      ENDIF
      @ LIN,20 PRINT "Codigo"
      @ LIN,40 PRINT "Descripcion"
      @ LIN,140 PRINT "Importe" RIGHT

      LIN:=LIN+5
   ENDIF

   IF W_Imp1.C_Cuadro.Value=.T.
      @ LIN, 19 PRINT RECTANGLE TO LIN+5, 39
      @ LIN, 39 PRINT RECTANGLE TO LIN+5,109
      @ LIN,109 PRINT RECTANGLE TO LIN+5,141
   ENDIF
   @ LIN,20 PRINT CODTAR
   @ LIN,40 PRINT NOMTAR
   @ LIN,140 PRINT TRANSFORM( IMPORTE , "@E 9,999,999.99" ) RIGHT

   LIN:=LIN+5
   SKIP

ENDDO

   END PRINTPAGE
   END PRINTDOC

  SetCurrentFolder(dirimp)

  W_Imp1.release

Return


procedure Lis_TarCodigoiE()
   Local LIN:=8, nCol
   LOCAL oExcel, oHoja

   oExcel := TOleAuto():New( "Excel.Application" )
   oExcel:WorkBooks:Add()
***Solo en MS office XP
*   oExcel:Sheets("Hoja1"):Name := "Listado"
*   oExcel:Sheets("Hoja2"):Name := "Resumen"
   oHoja := oExcel:Get( "ActiveSheet" )
   oHoja:Cells:Font:Name := "Arial"
   oHoja:Cells:Font:Size := 10

   oHoja:Cells( LIN, 1 ):Value := "Codigo"
   oHoja:Cells( LIN, 1 ):HorizontalAlignment:= -4152  //Derecha
   oHoja:Cells( LIN, 2 ):Value := "Descripcion"
   oHoja:Cells( LIN, 3 ):Value := "Importe"
***Solo en MS office XP
   oHoja:Cells( LIN, 3 ):Set( "NumberFormat", "#.##0,00 €" )

   oHoja:Range(CHR(64+1)+LTRIM(STR(LIN))+":"+CHR(64+3)+LTRIM(STR(LIN))):Font:Bold := .T.
   oHoja:Range(CHR(64+1)+LTRIM(STR(LIN))+":"+CHR(64+3)+LTRIM(STR(LIN))):Interior:ColorIndex := 36 //sombrear celdas
   oHoja:Range(CHR(64+1)+LTRIM(STR(LIN))+":"+CHR(64+3)+LTRIM(STR(LIN))):Borders(4):LineStyle:= 1  //linea inferior
   oHoja:Range(CHR(64+1)+LTRIM(STR(LIN))+":"+CHR(64+3)+LTRIM(STR(LIN))):HorizontalAlignment := -4108  //Centrar

   LIN++

DO WHILE .NOT. EOF()

   oHoja:Cells( LIN, 1 ):Value := CODTAR
   oHoja:Cells( LIN, 2 ):Value := NOMTAR
   oHoja:Cells( LIN, 3 ):Value := IMPORTE
***Solo en MS office XP
   oHoja:Cells( LIN, 3 ):Set( "NumberFormat", "#.##0,00" )

   LIN++
   SKIP

ENDDO

   oHoja:Cells( 1, 1 ):Value := "SUIZO miniprint_list v1.0"
   oHoja:Cells( 2, 1 ):Value := DATE()
   oHoja:Cells( 4, 1 ):Value := 'desde:'
   oHoja:Cells( 4, 2 ):Value := W_Imp1.T_CodTar1.value
   oHoja:Cells( 5, 1 ):Value := 'hasta:'
   oHoja:Cells( 5, 2 ):Value := W_Imp1.T_CodTar2.value
   oHoja:Range("A1:B6"):HorizontalAlignment:= -4131  //Izquierda

   FOR nCol:=1 TO FCOUNT()
      oHoja:Columns( nCol ):AutoFit()
   NEXT


*Guardar como
*oHoja:SaveAs( TituloImp )

   oHoja:Cells( 1, 1 ):Select()
   oExcel:Visible := .T.

   oHoja:End()
   oExcel:End()

   W_Imp1.release

Return


Function Impresoras()
   Local aIMP1,aIMP2,aIMP3

   aIMP1:=aPrinters()
   ASORT(aIMP1,,, { |x, y| UPPER(x) < UPPER(y) })
   aIMP2:=GetDefaultPrinter()
   aIMP3:=ASCAN(aIMP1, {|aVal| aVal == aIMP2})

RETURN {aIMP1,aIMP2,aIMP3}


Function Acercade()
RETURN MSGINFO("Creado por Jose Miguel -Valencia (España)"+CRLF+"<josemisu@yahoo.com.ar>"+CRLF+CRLF+ ;
   hb_compiler()+CRLF+Version()+CRLF+MiniGuiVersion(),"SUIZO miniprint_list v1.0")
