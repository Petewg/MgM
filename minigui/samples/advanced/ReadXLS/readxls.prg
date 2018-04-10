/*
 * HMG Read XLS Demo
 * Contributed by Ismael Elias <farfa890@gmail.com>
 */

#include "MiniGUI.ch"

STATIC aNamis   := {}
STATIC aWitis   := {}
STATIC aHojita  := {}
STATIC aTypes

FUNCTION Main()

   DEFINE WINDOW winmain ;
      TITLE 'LEER UN EXCEL !!!! ' ;
      MAIN

   @050, 003 GRID Grid_1 ;
      WIDTH winmain.Width - 20 ;
      HEIGHT winmain.Height - 90 ;
      HEADERS { "" } ;
      WIDTHS { 100 } ;
      ITEMS  { { "" } } ;
      VALUE  1 ;
      FONT "Helv" SIZE 10 ;
      PAINTDOUBLEBUFFER

   DEFINE BUTTON cmdxls
      ROW 015
      COL 005
      WIDTH  98
      HEIGHT 24
      CAPTION "&Abrir XLS"
      FONTNAME "Ms Sans Serif"
      FONTSIZE 9
      ACTION FAR_OpenXLS()
      FLAT .T.
   END BUTTON

   DEFINE BUTTON cmdxls2dbf
      ROW 015
      COL 120
      WIDTH  98
      HEIGHT 24
      CAPTION "&Export To DBF"
      FONTNAME "Ms Sans Serif"
      FONTSIZE 9
      ACTION FAR_XLS2DBF()
      FLAT .T.
   END BUTTON

   END WINDOW

   winmain.cmdxls2dbf.Enabled := FALSE

   ACTIVATE WINDOW winmain

RETURN NIL


STATIC FUNCTION FAR_OpenXLS()

   LOCAL ccFile

   ccFile := GetFile( { { "Archivos excel (*.xls)", "*.xls" } }, "Seleccione un archivo excel", GetCurrentFolder(), .F. )

   IF Empty( ccFile )
      RETURN NIL
   ENDIF

   Load_XLS_CLI( ccFile )

RETURN NIL


STATIC FUNCTION Load_XLS_CLI( cArchivo )

   LOCAL nFilas
   LOCAL nColumns
   LOCAL nnColumn
   LOCAL ccValue
   LOCAL i
   LOCAL j

   LOCAL oExcel   AS OBJECT
   LOCAL oWorkBook
   LOCAL oHoja
   LOCAL ccNameIs

   LOCAL nnWiti
   LOCAL aFila, aCellTypes  /*AS ARRAY*/

   SET DECIMALS  TO 0
   SET DATE FORMAT "YYYY-MM-DD"

   oExcel := CreateObject( "Excel.Application" )
   IF Ole2TxtError() != "S_OK"
      MsgStop( 'Excel no está instalado!', 'Error' )
      RETURN NIL
   ENDIF

   oWorkBook := oExcel:WorkBooks:Open( cArchivo )

   oExcel:Sheets( 1 ):Select()
   oHoja := oExcel:ActiveSheet()
   oExcel:Visible       := .F.     // <---- No Mostrar
   oExcel:DisplayAlerts := .F.     // <---- esta elimina mensajes
   //
   // ************** LOOP LECTURA PLANILLA EXCEL *****************
   //
   // ------------ Averiguo Cantida de Filas    ------------------
   //
   nFilas := oHoja:UsedRange:Rows:Count()
   //
   // ------------ Averiguo Cantida de Columnas ------------------
   //
   nnColumn := oHoja:UsedRange:Columns:Count
   //
   aNamis  := {}
   //
   nColumns := Len( GetProperty( "winmain", "Grid_1", "Item", 1 ) )

   DO WHILE nColumns > 0
      winmain.Grid_1.DeleteColumn( nColumns )
      nColumns--
   ENDDO
   //
   // ------------------------------------------------------------
   //
   FOR i = 1 TO nnColumn STEP 1

      ccValue := AnyToString( oHoja:cells( 2, i ):value )
      nnWiti := GetLenColumn( Len( ccValue ) )

      ccNameIs := AnyToString( oHoja:cells( 1, i ):value )
      winmain.Grid_1.AddColumn( i, ccNameIs, nnWiti, LToN( ValType( oHoja:cells( 2, i ):value ) == "N" ) )
      DO EVENTS

      AAdd( aNamis, ccNameIs )
      AAdd( aWitis, nnWiti )

   NEXT i
   //
   winmain.Grid_1.SetFocus
   //
   // ------------------------------------------------------------
   //
   aFila  := {}
   aCellTypes := {}
   //
   FOR i = 2 TO nFilas STEP 1

      FOR j = 1 TO nnColumn STEP 1

         ccValue := oHoja:cells( i, j ):value
         AAdd( aFila, ccValue )
         AAdd( aCellTypes, ValType( oHoja:cells( i, j ):value ) )

      NEXT j

      winmain.Grid_1.addItem( ItemChar( aFila, aCellTypes ) )
      winmain.Grid_1.Value := ( winmain.Grid_1.ItemCount )
      InkeyGUI()

      AAdd( aHojita, aFila )
      IF Valtype( aTypes ) != "A"
         aTypes := aCellTypes
      ENDIF
      aFila  := {}
      aCellTypes := {}

   NEXT i
   //
   winmain.Grid_1.Value := 1
   //
   // ------------------------------------------------------------
   //
   FOR j = 1 TO nnColumn - 1 STEP 1

      ccNameIs := AnyToString( oHoja:cells( 1, j ):value )
      ccValue := AnyToString( oHoja:cells( 2, j ):value )
      IF Len( ccNameIs ) < Len( ccValue )
         DoMethod( 'winmain', 'Grid_1', "ColumnAutoFit", j )
      ELSE
         DoMethod( 'winmain', 'Grid_1', "ColumnAutoFitH", j )
      ENDIF

   NEXT j
   winmain.Grid_1.ColumnWidth( nnColumn ) := GetProperty( 'winmain', 'Grid_1', "ColumnWidth", nnColumn ) - 12
   //
   // ------------------------------------------------------------
   //
   oExcel:DisplayAlerts := .F.   // <---- esta elimina mensajes
   oWorkBook:Close()
   oExcel:Quit()

   oWorkBook := NIL
   oHoja := NIL
   oExcel := NIL

   winmain.title := cArchivo
   winmain.cmdxls2dbf.Enabled := TRUE

RETURN NIL

*----------------------------------------------------------------------*
STATIC FUNCTION ItemChar( aLine, aType )
*----------------------------------------------------------------------*

   LOCAL aRet, x, l

   aRet := Array( Len( aLine ) )
   l := Len( aRet )

   FOR x := 1 TO l
      DO CASE
      CASE aType[ x ] == "N"
         aRet[ x ] := hb_ntos( aLine[ x ] )
      CASE aType[ x ] $ "DT"
         aRet[ x ] := DToC( aLine[ x ] )
      CASE aType[ x ] == "L"
         aRet[ x ] := iif( aLine[ x ], "TRUE", "FALSE" )
      OTHERWISE
         aRet[ x ] := aLine[ x ]
      ENDCASE
   NEXT

RETURN aRet


#ifndef __XHARBOUR__
   #xcommand TRY              => BEGIN SEQUENCE WITH {|__o| break(__o) }
   #xcommand CATCH [<!oErr!>] => RECOVER [USING <oErr>] <-oErr->
#endif

*----------------------------------------------------------------------*
STATIC FUNCTION FAR_XLS2DBF()
*----------------------------------------------------------------------*

   LOCAL i, aStruct := {}, cAlias, lOK := .T.

   FOR i := 1 TO Len( aNamis )
	AAdd( aStruct, { aNamis[i], iif(aTypes[i]=="T", "D", aTypes[i]), iif(aTypes[i]=="T", 8, aWitis[i]/10), 0 } )
   NEXT

   TRY
	DbCreate( "EXPORT", aStruct, , .T., cAlias := "TEMP" + hb_ntos( _GetId() ) )
   CATCH
	MsgAlert( "Can not create an export database.", "Warning" )
	lOK := .F.
   END

   IF lOK
	IF ( cAlias )->( HMG_ArrayToDBF( aHojita ) )
		( cAlias )->( DbCloseArea() )
		MsgInfo( "Export to DBF was done." )
	ENDIF
   ENDIF

RETURN lOK


STATIC FUNCTION AnyToString( csValue )

   LOCAL ccValor
   LOCAL cdate

   DO CASE
   CASE ValType( csValue ) == "N"
      ccValor := hb_ntos( csValue )

   CASE ValType( csValue ) $ "DT"
      IF !Empty( csValue )
         cdate := DToS( csValue )
         ccValor := SubStr( cDate, 1, 4 ) + "-" + SubStr( cDate, 5, 2 ) + "-" + SubStr( cDate, 7, 2 )
      ELSE
         ccValor := ""
      ENDIF

   CASE ValType( csValue ) $ "CM"
      IF Empty( csValue )
         ccValor = ""
      ELSE
         ccValor := "" + csValue + ""
      ENDIF

   CASE ValType( csValue ) == "L"
      ccValor := hb_ntos( lton( csValue ) )

   OTHERWISE
      ccValor := ""       // NOTE: Here we lose csValues we cannot convert

   ENDCASE

RETURN( ccValor )


STATIC FUNCTION GetLenColumn( nnLen )

   LOCAL nnValor

   IF nnLen < 6
      nnValor := 70

   ELSEIF nnLen < 11
      nnValor := 110

   ELSEIF nnLen < 21
      nnValor := 180

   ELSEIF nnLen < 41
      nnValor := 300

   ELSE
      nnValor := 380

   ENDIF

RETURN( nnValor )
