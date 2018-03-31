/*
 * MINIGUI - Harbour Win32 GUI library Demo
 *
 * Copyright 2002 Roberto Lopez <harbourminigui@gmail.com>
 * http://harbourminigui.googlepages.com/
 *
 * Copyright 2005 Winston Garcia (MoviStar) <wgarcia@eurolicores.com.ve>
 *
*/

#include "minigui.ch"

Function Main

	SET CENTURY ON
	SET DELETED ON
	SET EXCLUSIVE ON
	SET BROWSESYNC ON

	DEFINE WINDOW Form_1 ;
		AT 0,0 ;
		WIDTH 640 HEIGHT 480 ;
		TITLE 'Text-Button Demo (Based Upon a Contribution Of Winston Garcia)' ;
		MAIN NOMAXIMIZE ;
		ON INIT Form_1.TextBtn_01.Setfocus

		ON KEY DOWN ACTION InsertTab()
		ON KEY UP   ACTION InsertShiftTab()

		@13,10 LABEL Lbl_01 Value "BtnTextBox 1 : " ;
			RIGHTALIGN WIDTH  125 TRANSPARENT

		@ 10,140 BTNTEXTBOX TextBtn_01 ;
			NUMERIC ;
			VALUE 123 ;
			FONT 'Verdana' SIZE 12 ;
			TOOLTIP 'BtnTextBox Numeric Con Imagenes' ;
			PICTURE "find.bmp";
			MAXLENGTH 3 ;
			RIGHTALIGN ;
			ACTION FindCode("Form_1","TextBtn_01") ;
			ON ENTER FindCode("Form_1","TextBtn_01")

		@53,10 LABEL Lbl_02 Value "BtnTextBox 2 : " ;
			RIGHTALIGN WIDTH  125 TRANSPARENT

 		@50,140 BTNTEXTBOX TextBtn_02 ;
			WIDTH 90 ;
			NUMERIC ;
			VALUE '' ;
			FONT 'Verdana' SIZE 12 ;
			TOOLTIP 'BtnTextBox Numeric' ;
			MAXLENGTH 6 ;
			ACTION ( MsgInfo("Hola !"), DoMethod("Form_1","TextBtn_03","setfocus") ) ;
			NOKEEPFOCUS

		@93,10 LABEL Lbl_03 Value "BtnTextBox 3 : " ;
			RIGHTALIGN WIDTH  125 TRANSPARENT

 		@90,140 BTNTEXTBOX TextBtn_03 ;
			HEIGHT 22;
			WIDTH 90 ;
			VALUE '' ;
			FONT 'Verdana' SIZE 12 ;
			TOOLTIP 'BtnTextBox' ;
			MAXLENGTH 6 ;
			ACTION ( MsgInfo("Hola !"), DoMethod("Form_1","TextBtn_01","setfocus") ) ;
			NOKEEPFOCUS
       
	END WINDOW
 
	CENTER WINDOW Form_1
	ACTIVATE WINDOW Form_1

Return Nil


Function FindCode(cForm, cTextBtn)
Local cReg := ""

	cReg := GetCode(Getproperty(cForm,cTextBtn,"Value"))
	If !empty(cReg)
		Setproperty(cForm,cTextBtn,"Value",Val(cReg))
		DoMethod(cForm,cTextBtn,"Setfocus")
	EndIf

Return Nil

Function GetCode(nValue)
    Local cReg:= "", nReg := 1

    OpenTables()
	if !empty(nValue)
		nValue := if(nValue < 100, nValue + 100, nValue)
		Seek Alltrim(Str(nValue))
		if !eof()
			nReg := Recno()
		endif
	endif

	DEFINE WINDOW Form_11;
		AT 0,0 ;
		WIDTH 350 HEIGHT 300 ;
		TITLE 'Lista de Articulos' ;
		MODAL NOSIZE;
		ON RELEASE CloseTables()

		@ 5,5 BROWSE Browse_1	;
			WIDTH 330 		;
			HEIGHT 260		;
			HEADERS { 'Producto' , 'Descripcion del Producto' } ;
			WIDTHS { 70 , 240 } ;
			WORKAREA Prod ;
			FIELDS { 'Prod->Item_num' , 'Prod->Item_Desc' } ;
			VALUE nReg ;
			READONLY {.t.,.t.} ;
			Justify {BROWSE_JTFY_LEFT , BROWSE_JTFY_CENTER} ;
			ON DBLCLICK ( cReg:=Prod->Item_num, ThisWindow.Release ) ;
			TOOLTIP "DobleClick o Enter para Seleccionar "

		ON KEY ESCAPE ACTION ThisWindow.Release
	END WINDOW

	CENTER WINDOW Form_11

	ACTIVATE WINDOW Form_11

Return cReg


Procedure OpenTables()
Local i
        Use Prod Alias Prod Shared new
        If !file("Prod.ntx")
           Index on Field->Item_num to Prod
        EndIf
        Set Index to Prod
        Go Top
        If Eof() .and. Bof()
           For I = 1 to 100
             Append Blank
             Replace Item_num  With Alltrim(Str(100+I))
             Replace Item_Desc With "Producto No. "+AllTrim(Str(100+I))
           Next I
        EndIf
        
Return

Procedure CloseTables()
	Use
Return
