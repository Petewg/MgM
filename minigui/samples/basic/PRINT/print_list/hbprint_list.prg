***Creado por Jose Miguel -Valencia (España) <josemisu@yahoo.com.ar>***

#include "minigui.ch"
#include "winprint.ch"

FIELD CODTAR, NOMTAR, IMPORTE

STATIC nVers

PROCEDURE main()
   Local N, aArq
SET LANGUAGE TO GREEK
   ***CODIGO DE PAGINA español***
   REQUEST HB_CODEPAGE_ESWIN
   HB_SETCODEPAGE("ESWIN")

   ***Inicializacion RDD DBFCDX Nativo***
   REQUEST DBFCDX , DBFFPT
   RDDSETDEFAULT( "DBFCDX" )
   SET AUTOPEN OFF //no abrir los indices automaticamente

   ***DATOS DE INICIALIZACION***
   Set Navigation Extended //TAB y ENTER
   SET DATE FORMAT "dd-mm-yyyy"
   SET EPOCH TO YEAR(DATE())-50

   ***crear fichero de datos para este ejemplo***
   IF .NOT. FILE("TARIFAS.DBF")
      aArq:={}
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
   IF .NOT. FILE("TARIFAS.CDX")
      Use TARIFAS Alias TARIFAS new shared
      Index on CODTAR TAG ORDEN1 to TARIFAS.CDX
      TARIFAS->( DBCLOSEAREA() )
   ENDIF
   ***fin crear fichero indice para este ejemplo***

Lis_TarCodigo()

RETURN


Function Lis_TarCodigo()
   Local aIMP

   DEFINE WINDOW W_Imp1 ;
      AT 10,10 ;
      WIDTH 410 HEIGHT 280 ;
      TITLE 'SUIZO hbprint_list v1.2' ;
      MAIN ;
      ON RELEASE CloseTables()

      @ 15,10 LABEL L_CodTar1 VALUE 'Desde codigo' AUTOSIZE TRANSPARENT
      @ 10,100 TEXTBOX T_CodTar1 WIDTH 100 VALUE 'E001' MAXLENGTH 10

      @ 10,250 BUTTON B_Acerca CAPTION 'Aceca de' WIDTH 90 HEIGHT 25 ;
               ACTION Acercade()

      @ 45,10 LABEL L_CodTar2 VALUE 'Hasta codigo' AUTOSIZE TRANSPARENT
      @ 40,100 TEXTBOX T_CodTar2 WIDTH 100 VALUE 'E050' MAXLENGTH 10

      @ 70,10 CHECKBOX C_Cuadro ;
            CAPTION 'Imprimir cuadros en lineas' ;
            WIDTH 200 VALUE .F.


      draw rectangle in window W_Imp1 at 110,010 to 112,390 fillcolor{255,0,0} //Rojo
      aIMP:=Impresoras()
      @125,10 LABEL L_Impresora VALUE 'Impresora' AUTOSIZE TRANSPARENT
      @120,100 COMBOBOX C_Impresora ;
            WIDTH 280 ;
            ITEMS aIMP[1] ;
            VALUE aIMP[3] ;
            TOOLTIP 'Impresora' NOTABSTOP

      @150, 10 CHECKBOX nImp CAPTION 'Seleccionar impresora' ;
               width 150 value .f. ;
               ON CHANGE W_Imp1.C_Impresora.Enabled:=IF(W_Imp1.nImp.Value=.T.,.F.,.T.)

      @180, 10 CHECKBOX nVer CAPTION 'Previsualizar documento' ;
               width 160 value .t.

      @210, 10 BUTTON B_Imprimir CAPTION 'Imprimir' WIDTH 90 HEIGHT 25 ;
               ACTION Lis_TarCodigoi("IMPRESORA")

      @210,110 BUTTON B_Excel CAPTION 'Hoja excel' WIDTH 90 HEIGHT 25 ;
               ACTION Lis_TarCodigoi("EXCEL")

      @210,210 BUTTON B_Calc CAPTION 'Hoja calc' WIDTH 90 HEIGHT 25 ;
               ACTION Lis_TarCodigoi("CALC")

      @210,310 BUTTON B_Salir CAPTION 'Salir'  WIDTH 80 HEIGHT 25 ;
               ACTION W_Imp1.release

      END WINDOW
      CENTER WINDOW W_Imp1
      ACTIVATE WINDOW W_Imp1

Return Nil

Function CloseTables()
   CLOSE DATABASES
   FERASE('TARIFAS.CDX')
   IF FILE("FIN.DBF")
      ERASE FIN.DBF
      ERASE FIN.CDX
   ENDIF
Return NIL


procedure Lis_TarCodigoi(LLAMADA)
   IF FILE("FIN.DBF")
      IF SELEC("FIN")<>0
         FIN->( DBCLOSEAREA() )
      ENDIF
      ERASE FIN.DBF
      ERASE FIN.CDX
   ENDIF

   IF SELEC("TARIFAS")<>0
      SELEC TARIFAS
   ELSE
      Use TARIFAS index TARIFAS Alias TARIFAS new shared
   ENDIF

   SET FILTER TO
   COPY TO FIN FOR ;
      CODTAR>=W_Imp1.T_CodTar1.value .AND. CODTAR<=W_Imp1.T_CodTar2.value
   Use FIN Alias FIN new shared
   INDEX ON CODTAR TO FIN

   GO TOP
   IF LASTREC()=0
      MsgExclamation("No hay datos en las fecha introducidas","Informacion")
      FIN->( DBCLOSEAREA() )
      RETURN
   ENDIF

   DO CASE
   CASE LLAMADA="EXCEL"
      Lis_TarCodigoiExcel()
   CASE LLAMADA="CALC"
      Lis_TarCodigoiCalc()
   OTHERWISE
      Lis_TarCodigoiImp()
   ENDCASE
Return


Function Lis_TarCodigoiImp()
   Local dirimp:=GetCurrentFolder(), PAG, LIN
   INIT PRINTSYS

   IF W_Imp1.nImp.value=.t.
      IF W_Imp1.nVer.value=.t.
         SELECT BY DIALOG PREVIEW
      ELSE
         SELECT BY DIALOG
      ENDIF
   ELSE
      IF W_Imp1.C_Impresora.ItemCount=0 .OR. ;
         W_Imp1.C_Impresora.Value<=0 .OR. ;
         W_Imp1.C_Impresora.Value>W_Imp1.C_Impresora.ItemCount
         MSGSTOP("No hay impresoras instaladas","Error")
         release printsys
         SetCurrentFolder(dirimp)
         RETURN nil
      ENDIF
      IF W_Imp1.nVer.value=.t.
         SELECT PRINTER W_Imp1.C_Impresora.Item(W_Imp1.C_Impresora.Value) PREVIEW
      ELSE
         SELECT PRINTER W_Imp1.C_Impresora.Item(W_Imp1.C_Impresora.Value)
      ENDIF
   ENDIF

   IF HBPRNERROR>0
      release printsys
      SetCurrentFolder(dirimp)
      return nil
   ENDIF

   SET UNITS MM
  define font "ft10" name "times new roman" size 10
  define font "ft12" name "times new roman" size 12 //bold=negrita
  define font "ft14" name "times new roman" size 14
  define font "ft18" name "times new roman" size 18

  define pen "p0" style PS_SOLID width 1 color 0x000000
  define pen "p1" style PS_DOT width 1 color 0xFF0000
  define pen "p2" style PS_NULL

  select font "ft12"
  select pen "p0"

  set page orientation DMORIENT_PORTRAIT papersize DMPAPER_A4 font "ft12"
  start doc name W_Imp1.Title
  start page

GO TOP
PAG:=0
LIN:=0
DO WHILE .NOT. EOF()
   IF LIN>=260 .OR. PAG=0
      IF PAG<>0
         SET TEXT ALIGN CENTER
         @ LIN+5,105 say "SIGUE EN LA HOJA: "+LTRIM(STR(PAG+1)) TO PRINT
         SET TEXT ALIGN LEFT
         end page
         start page
      ENDIF
      PAG++
      select font "ft12"

      @ 20,20 say W_Imp1.Title TO PRINT
      SET TEXT ALIGN RIGHT
      @ 20,190 say "Hoja: "+LTRIM(STR(PAG)) TO PRINT
      SET TEXT ALIGN LEFT
      @ 25,20 say DATE() TO PRINT

      SET TEXT ALIGN CENTER
      @ 25,105 say "Nombre de la empresa" TO PRINT
      @ 35,105 say "Listado de tarifas" FONT "ft18" TO PRINT
      SET TEXT ALIGN LEFT

      @ 40,20 say 'desde: '+W_Imp1.T_CodTar1.value TO PRINT
      @ 45,20 say 'hasta: '+W_Imp1.T_CodTar2.value TO PRINT

      select font "ft10"

      LIN:=55
      IF W_Imp1.C_Cuadro.Value=.T.
         @ LIN, 19,LIN+5, 39 RECTANGLE
         @ LIN, 39,LIN+5,109 RECTANGLE
         @ LIN,109,LIN+5,141 RECTANGLE
      ELSE
         @ LIN+4,20 , LIN+4,140 LINE
      ENDIF
      @ LIN,20 SAY "Codigo" ALIGN TA_LEFT TO PRINT
      @ LIN,40 SAY "Descripcion" ALIGN TA_LEFT TO PRINT
      @ LIN,140 SAY "Importe" ALIGN TA_RIGHT TO PRINT

      LIN+=5
   ENDIF

   IF W_Imp1.C_Cuadro.Value=.T.
      @ LIN, 19,LIN+5, 39 RECTANGLE
      @ LIN, 39,LIN+5,109 RECTANGLE
      @ LIN,109,LIN+5,141 RECTANGLE
   ENDIF
   @ LIN,20 SAY CODTAR ALIGN TA_LEFT TO PRINT
   @ LIN,40 SAY NOMTAR ALIGN TA_LEFT TO PRINT
   @ LIN,140 SAY TRANSFORM( IMPORTE , "@E 9,999,999.99" ) ALIGN TA_RIGHT TO PRINT

   LIN+=5
   SKIP

ENDDO

   SELEC FIN
   FIN->( DBCLOSEAREA() )

   end page
   end doc
   release printsys
   SetCurrentFolder(dirimp)

   IF W_Imp1.nVer.value=.F.
      MsgInfo("Listado terminado")
   ENDIF

Return Nil



Function Lis_TarCodigoiExcel()
   Local LIN:=8, nCol
   LOCAL oExcel, oHoja
   oExcel := TOleAuto():New( "Excel.Application" )
   IF Ole2TxtError() != 'S_OK'
      MsgStop('Excel no esta disponible','error')
      RETURN Nil
   ENDIF
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
      oHoja:Cells( LIN, 3 ):Set( "NumberFormat", "#.##0,00" )
      LIN++
      SKIP
   ENDDO

   oHoja:Cells( 1, 1 ):Value := W_Imp1.Title
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
   *oHoja:SaveAs( W_Imp1.Title )

   oHoja:Cells( 1, 1 ):Select()
   oExcel:Visible := .T.

   IF AT("XHARBOUR",UPPER(VERSION()))=1
      oHoja:end()
      oExcel:end()
   ENDIF

   SELEC FIN
   FIN->( DBCLOSEAREA() )

   MsgInfo("Listado terminado")

Return Nil


Function Lis_TarCodigoiCalc()
   Local LIN:=5
   local oServiceManager,oDesktop,oDocument,oSchedule,oSheet,oCell

   // inicializa
   oServiceManager := TOleAuto():New("com.sun.star.ServiceManager")
   oDesktop := oServiceManager:createInstance("com.sun.star.frame.Desktop")
   IF oDesktop = NIL
      MsgStop('OpenOffice Calc no esta disponible','error')
      RETURN Nil
   ENDIF
   oDocument := oDesktop:loadComponentFromURL("private:factory/scalc","_blank", 0, {})

   // tomar hoja
   oSchedule := oDocument:GetSheets()

   // tomar primera hoja por nombre oSheet := oSchedule:GetByName("Hoja1")
   // o por indice
   oSheet := oSchedule:GetByIndex(0)

   oSheet:getCellByPosition(0,LIN):SetString("Codigo")
   oSheet:getCellByPosition(1,LIN):SetString("Descripcion")
   oSheet:getCellByPosition(2,LIN):SetString("Importe")
   oSheet:getCellRangeByPosition(2,LIN,2,LIN):HoriJustify:=2
   oSheet:getCellRangeByPosition(0,LIN,2,LIN):CharWeight:=150 //NEGRITA

   LIN++

   DO WHILE .NOT. EOF()
      oCell:=oSheet:getCellByPosition(0,LIN) // columna,linea
      oCell:SetString(CODTAR)
      oCell:=oSheet:getCellByPosition(1,LIN) // columna,linea
      oCell:SetString(NOMTAR)
      oCell:=oSheet:getCellByPosition(2,LIN) // columna,linea
      oCell:SetValue(IMPORTE)
      oSheet:getCellRangeByPosition(2,LIN,2,LIN):NumberFormat:=4 //#.##0,00
      LIN++
      SKIP
   ENDDO

   oSheet:getColumns():setPropertyValue("OptimalWidth", .T.)

   oSheet:getCellByPosition(0,0):SetString(W_Imp1.Title)
   oSheet:getCellByPosition(0,1):SetString(DATE())
   oSheet:getCellByPosition(0,2):SetString('Desde:')
   oSheet:getCellByPosition(1,2):SetString(W_Imp1.T_CodTar1.value)
   oSheet:getCellByPosition(0,3):SetString('Hasta:')
   oSheet:getCellByPosition(1,3):SetString(W_Imp1.T_CodTar2.value)
   oSheet:getCellRangeByPosition(0,0,0,0):CharWeight:=150 //NEGRITA

   MsgInfo("Listado terminado")

Return Nil


Function Impresoras()
   Local aIMP1,aIMP2,aIMP3
   INIT PRINTSYS
   nVers := hbprn:getversion()
   GET PRINTERS TO aIMP1
   ASORT(aIMP1,,, { |x, y| UPPER(x) < UPPER(y) })
   GET DEFAULT PRINTER TO aIMP2
   aIMP3:=ASCAN(aIMP1, {|aVal| aVal == aIMP2})
   RELEASE PRINTSYS
RETURN {aIMP1,aIMP2,aIMP3}


Function Acercade()
RETURN MSGINFO("Creado por Jose Miguel -Valencia (España)"+CRLF+"<josemisu@yahoo.com.ar>"+CRLF+CRLF+ ;
   hb_compiler()+CRLF+Version()+CRLF+MiniGuiVersion()+CRLF+"HBPrint library version "+ltrim(str(nVers)),W_Imp1.Title)
