**************************************************************************
*                                                                        *
*  MiniGUI OLE Demo					                 *
*  (c) 2003 Roberto Lopez <harbourminigui@gmail.com>                     *
*									 *
*  Based upon 'TestOle.Prg'                                              *
*									 *
*  Author: Jose F. Gimenez (JFG) - jfgimenez@wanadoo.es                  *
*                                  tecnico.sireinsa@ctv.es               *
*                                                                        *
*  Updated for HMG Extended Edition by MiniGUI Team                      *
*                                                                        *
**************************************************************************

#include "minigui.ch"

PROCEDURE Main()

	DEFINE WINDOW Form_1 ;
		AT 0,0 ;
		WIDTH 334 ;
		HEIGHT 276 ;
		TITLE 'OLE Test' ;
		MAIN

		DEFINE MAIN MENU

			DEFINE POPUP "Tests"
				MENUITEM 'Word Test' ACTION MSWORD()
				MENUITEM 'IE Test' ACTION IEXPLORER()
				MENUITEM 'OutLook Test' ACTION OUTLOOK()
				MENUITEM 'Excel Test' ACTION EXCEL()
				MENUITEM 'Excel Enum' ACTION EXCEL2()
				MENUITEM 'Excel Chart' ACTION EXCEL3()
				SEPARATOR
                                ITEM 'Exit' ACTION Form_1.Release()
			END POPUP

		END MENU

	END WINDOW 

	Form_1.Center()
	Form_1.Activate()

RETURN

//--------------------------------------------------------------------

STATIC PROCEDURE MSWORD()

   LOCAL oWord, oTexto

   oWord:=CreateObject( "Word.Application" )

   oWord:Documents:Add()

   oTexto := oWord:Selection()

   oTexto:Text := "OLE desde MiniGUI!!!"+CRLF
   oTexto:Font:Name := "Arial"
   oTexto:Font:Size := 48
   oTexto:Font:Bold := .T.

   oWord:Visible := .T.
   oWord:WindowState := 1  // Maximizado

RETURN

//--------------------------------------------------------------------

STATIC PROCEDURE IEXPLORER()

   LOCAL oIE

   oIE:=CreateObject( "InternetExplorer.Application" )

   oIE:Visible := .T.

   oIE:Navigate( "http://hmgextended.com/" )

RETURN

//--------------------------------------------------------------------

STATIC PROCEDURE OUTLOOK()

   LOCAL oOL, oLista, oMail, i

   oOL := CreateObject( "Outlook.Application" )

   IF Ole2TxtError() != "S_OK"

      MsgStop("Outlook no está disponible.", "Error")

   ELSE

      oMail := oOL:CreateItem( 0 )  // olMailItem

      FOR i := 1 TO 10
         oMail:Recipients:Add( "Contacto" + LTRIM( STR( i, 2 ) ) + ;
               "<contacto" + LTRIM( STR( i, 2 ) ) + "@servidor.com>" )
      NEXT

      oLista := oOL:CreateItem( 7 )  // olDistributionListItem
      oLista:DLName := "Prueba de lista de distribución"
      oLista:Display( .F. )
      oLista:AddMembers( oMail:Recipients )
      oLista:Save()
      oLista:Close( 0 )

   ENDIF

RETURN

//--------------------------------------------------------------------

STATIC PROCEDURE EXCEL()

   LOCAL oExcel, oHoja

   oExcel := CreateObject( "Excel.Application" )

   oExcel:WorkBooks:Add()

   oHoja := oExcel:ActiveSheet()

   oHoja:Cells:Font:Name := "Arial"
   oHoja:Cells:Font:Size := 12

   oHoja:Cells( 3, 1 ):Value := "Texto:"
   oHoja:Cells( 3, 2 ):Value := "Esto es un texto"
   oHoja:Cells( 4, 1 ):Value := "Número:"
   oHoja:Cells( 4, 2 ):NumberFormat := "#.##0,00"
   oHoja:Cells( 4, 2 ):Value := 1234.50
   oHoja:Cells( 5, 1 ):Value := "Lógico:"
   oHoja:Cells( 5, 2 ):Value := .T.
   oHoja:Cells( 6, 1 ):Value := "Fecha:"
   oHoja:Cells( 6, 2 ):Value := DATE()

   oHoja:Columns( 1 ):Font:Bold := .T.
   oHoja:Columns( 2 ):HorizontalAlignment := -4152  // xlRight

   oHoja:Columns( 1 ):AutoFit()
   oHoja:Columns( 2 ):AutoFit()

   oHoja:Cells( 1, 1 ):Value := "OLE desde MiniGUI!!"
   oHoja:Cells( 1, 1 ):Font:Size := 16
   oHoja:Range( "A1:B1" ):HorizontalAlignment := 7

   oHoja:Cells( 1, 1 ):Select()
   oExcel:Visible := .T.

RETURN

//--------------------------------------------------------------------

/*
 * Harbour Project source code:
 *    demonstration code for FOR EACH used for OLE objects
 *    this code needs HBOLE library
 *
 * Copyright 2007 Enrico Maria Giordano e.m.giordano at emagsoftware.it
 * www - http://harbour-project.org
 *
 */

STATIC PROCEDURE EXCEL2()

   LOCAL oExcel := CREATEOBJECT( "Excel.Application" )
   LOCAL oWorkBook := oExcel:WorkBooks:Add()
   LOCAL oWorkSheet

   FOR EACH oWorkSheet IN oWorkBook:WorkSheets
      MsgInfo( oWorkSheet:Name )
   NEXT
   oExcel:Quit()

RETURN

//--------------------------------------------------------------------

/*
 El ejemplo utiliza la libreria de minigui y Automatizacion OLE pero es muy
 rapido e incluso genera una Grafico de Barras y, lo mas importante, lo graba
 como XLS.

 Espero les sirva (saludos).
 Julio Cesar Manzano Ascanio 
 */

STATIC PROCEDURE EXCEL3()
   Local oExcel, oHoja, oChart
   Local aDbf := {}

   // Creamos el archivo DBF de prueba
   AADD(Adbf,{"ENE","N",7,0})
   AADD(Adbf,{"FEB","N",7,0})
   AADD(Adbf,{"MAR","N",7,0})
   dbcreate("PRU",aDbf)

   // Lo cargamos con datos de prueba
   use PRU
   append blank
   Replace ENE with 34, FEB with 24, MAR with 78
   append blank
   Replace ENE with 8, FEB with 16, MAR with 5
   append blank
   Replace ENE with 28, FEB with 12, MAR with 33
   USE // Cerramos el archivo DBF

   // Abrimos Excel
   oExcel:= CreateObject( "Excel.Application" )

   // Verificamos si hay error
   if Ole2TxtError() != 'S_OK'
	MsgInfo('Excel no esta disponible','Advertencia')
	Return
   endif

   oExcel:Visible := .T. // Hacemos visibles los ca,bios

   oExcel:Workbooks:Open(GetCurrentFolder()+"\PRU.DBF") // Abrimos el BDF

   oExcel:DisplayAlerts := .F. // Deshabilitamos mensajes de Error

   oHoja := oExcel:ActiveSheet() // Activamos la hoja

   oHoja:Range("A1:C4"):Select() // Definimos Rango

   oChart := oExcel:Charts:Add() // Creamos una grafico de barras

   oChart:Hastitle := .T. // Definimos el titulo
   oChart:ChartTitle:Text := "Titulo de Prueba"

   MsgInfo("Se va a grabar como PRU.XLS y tipo XLS")

   // Aca es que grabamos como XLS y tipo XLS. El tipo -4143 es XLS

   oExcel:ActiveWorkbook:SaveAs(GetCurrentFolder()+"\PRU.XLS",-4143)

   // Cerramos todo
   oExcel:Quit()

   MsgInfo("Quedo grabado como: PRU.XLS"+chr(13)+"En: "+GetCurrentFolder())

RETURN
