/*
 * HMG ReadXLS Demo
 * Contributed by Isma Elias <farfa890@gmail.Com>
 */

#include "MiniGUI.ch"

#define NTrim( n ) LTRIM( STR( n, IF( n == INT( n ), 0, 2 ) ) )

Static aNamis   := {}
Static aFila    := {}
Static aWitis   := {}
Static aHojita  := {}

Function Main()
    Local nWcrt
    Local nHcrt

    SET FONT TO "Ms Sans Serif", 9

    DEFINE WINDOW winmain ;
        TITLE 'LEER UN EXCEL !!!! ' ;
        MAIN

        nWcrt    := winmain.Width-20
        nHcrt    := winmain.Height-90

        @050,003 GRID Grid_1 ;
                 WIDTH nWcrt ;
                 HEIGHT nHcrt ;
                 HEADERS { "" } ;
                 WIDTHS { 100 } ;
                 ITEMS  { { "" } } ;
                 VALUE  1

        DEFINE BUTTON cmdxls
            ROW 015
            COL 005
            WIDTH  98
            HEIGHT 24
            CAPTION "&Abrir XLS"
            ACTION FAR_OpenXLS()
            FLAT .T.
        END BUTTON

    END WINDOW

    ACTIVATE WINDOW winmain

Return Nil


Static Function FAR_OpenXLS()

     LOCAL ccFile

     if EMPTY(ccFile) .or. ccFile==NIL .or. LEN(ccFile)==0
        ccFile := getfile({{"Archivos excel  (*.xls)","*.xls"}},"Seleccione un archivo excel",GetCurrentFolder(),.f.)
     endif

     if EMPTY(ccFile) .or. ccFile==NIL .or. LEN(ccFile)==0
        return nil
     endif

     Load_XLS_CLI( ccFile )


Return Nil


Static Function Load_XLS_CLI( cArchivo )

     LOCAL nFilas   := 0
     LOCAL nColumns := 0
     LOCAL nnColumn := 0
     LOCAL nuColumn
     LOCAL ccValue
     LOCAL i        := 0
     LOCAL j        := 0

     LOCAL oExcel   as Object
     LOCAL oWorkBook
     LOCAL oHoja
     LOCAL ccNameIs := ""

     LOCAL NoSale  := TRUE
     LOCAL nnWiti  := 0
     LOCAL aTypes  AS ARRAY

     SET DECIMALS  TO 0

     oExcel := TOleAuto():New( "Excel.Application" )
	  msgdebug( oExcel )
     IF  oExcel == NIL
          MsgStop('Excel no está instalado!','Error')
          RETURN Nil
     Endif

     oWorkBook := oExcel:WorkBooks:Open( cArchivo )

     oExcel:Sheets(1):Select()
     oHoja := oExcel:ActiveSheet()
     oExcel:Visible       := .F.     // <---- No Mostrar
     oExcel:DisplayAlerts := .F.     // <---- esta elimina mensajes
     //
     ************** LOOP LECTURA PLANILLA EXCEL ******************
     //
     //------------ Averiguo Cantida de Filas    ------------------
     //
     nFilas    := oHoja:UsedRange:Rows:Count()
     //
     //------------ Averiguo Cantida de Columnas ------------------
     //
     nnColumn := 0
     //
     aNamis  := {}
     //
     i := 0
     nuColumn := 0

     nColumns := Len( getProperty( "winmain", "Grid_1", "Item", 1 ) )

     DO WHILE nColumns != 0
         winmain.Grid_1.DeleteColumn( nColumns )
         nColumns--
     ENDDO

     Do While NoSale

        i++

        ccValue := AnyToString( oHoja:cells(2,i):value )
        nnWiti := GetLenColumn( LEN( ccValue )  )

	ccNameIs := AnyToString( oHoja:cells(01, i):value )
        IF EMPTY( ccNameIs ) .or. LEN( ccNameIs ) == 0 .or. ccNameIs = ' '

           nuColumn := i - 1
           NoSale := FALSE

        ELSE

           winmain.Grid_1.AddColumn( i, ccNameIs, nnWiti, iif(Valtype( oHoja:cells(2,i):value ) == "N", 1, 0) )
           DoEvents()

           AADD(aNamis, ccNameIs )
           AADD(aWitis, 120)
           nnColumn := i
        ENDIF

     EndDo
     //
     IF  nuColumn <> nnColumn
         MsgInfo("nuColumn " + str(nuColumn) +  " nnColumn " + str(nnColumn))
     ENDIF
     //
     //------------------------------------------------------------
     //
     aFila  := {}
     aTypes := {}
     //
     FOR i=2 TO nFilas Step 1

          FOR j=1 TO nnColumn Step 1

             ccValue := AnyToString( oHoja:cells(i,j):value )
             AADD(aFila, ccValue )
             AADD(aTypes, "C")

          NEXT j

          winmain.Grid_1.addItem( ItemChar(aFila, aTypes) )

          AADD(aHojita, aFila )
          aFila  := {}
          aTypes := {}
          DoEvents()

     Next i

     oExcel:DisplayAlerts := .F. // <---- esta elimina mensajes
     oWorkBook:Close()
     oExcel:Quit()

     oWorkBook := NIL
     oHoja := NIL
     oExcel := NIL

     winmain.title := cArchivo

RETURN Nil

*----------------------------------------------------------------------*
FUNCTION ItemChar(aLine, aType)
*----------------------------------------------------------------------*

    LOCAL aRet:={}, x:=0, l:=0

    aRet:=array( len(aLine) )
    l:=len(aRet)

    FOR x:=1 TO l
        do case
        case aType[x]=="N"
             aRet[x]:=NTrim(aLine[x])
        case aType[x]=="D"
             aRet[x]:=dtoc(aLine[x])
        case aType[x]=="L"
             aRet[x]:=iif(aLine[x], "TRUE", "FALSE")
        otherwise
             aRet[x]:=aLine[x]
        endcase
    NEXT

RETURN aRet


STATIC FUNCTION AnyToString(csValue)

   LOCAL ccValor
   LOCAL cdate

   DO CASE
   CASE Valtype(csValue) == "N"
        ccValor := hb_ntos(csValue)

   CASE Valtype(csValue) == "D"
        IF !Empty(csValue)
           cdate := dtos(csValue)
           ccValor := substr(cDate,1,4) + "-" + substr(cDate,5,2) + "-" + substr(cDate,7,2)
        ELSE
           ccValor := ""
        ENDIF
   CASE Valtype(csValue) == "T"
        IF !Empty(csValue)
           cdate := dtos(csValue)
           ccValor := substr(cDate,1,4) + "-" + substr(cDate,5,2) + "-" + substr(cDate,7,2)
        ELSE
           ccValor := ""
        ENDIF

   CASE Valtype(csValue) $ "CM"
        IF Empty( csValue)
           ccValor=""
        ELSE
           ccValor := "" + csValue+ ""
        ENDIF

   CASE Valtype(csValue) == "L"
        ccValor := AllTrim(Str(iif(csValue == .F., 0, 1)))

   OTHERWISE
        ccValor := ""       // NOTE: Here we lose csValues we cannot convert

   ENDCASE

RETURN( ccValor )


STATIC FUNCTION GetLenColumn( nnLen )

    LOCAL nnValor := 120

    IF nnLen < 6
       nnValor := 70
    ELSEIF nnLen < 10
       nnValor := 110
    ELSEIF nnLen < 20
       nnValor := 140
    ELSEIF nnLen < 40
       nnValor := 240
    ELSE
       nnValor := 380
    ENDIF

RETURN( nnValor )
