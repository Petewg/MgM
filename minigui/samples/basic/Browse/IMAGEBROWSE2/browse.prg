/*
 * MINIGUI - Harbour Win32 GUI library Demo
 *
 * Copyright 2002 Roberto Lopez <harbourminigui@gmail.com>
 * http://harbourminigui.googlepages.com/
 *
 * Update 2002 Interativo Networks <xharbour@terra.com.br>
 * 	       Daniel Crocciari
 *	       http://www.ihpz.net
 * 
 *
 * Modified by Roberto Lopez <harbourminigui@gmail.com> 2007.12.02
 *
 * Revised by Grigory Filatov <gfilatov@inbox.ru> 2010.06.10
*/

#include "minigui.ch"

Function Main
	Local bColor := { || iif( recno()/2 == int( recno()/2 ) , { 255,255,255 } , { 240,240,240 } ) }	

	SET MULTIPLE OFF WARNING

	SET CENTURY ON
	SET DATE BRIT
	SET DELETE ON

	SET FONT TO "ARIAL" , 9

	DEFINE WINDOW Form_1 ;
		AT 0,0 ;
		WIDTH 550 ;
		HEIGHT 535 + IF(IsXPThemeActive(), 8, 0) ;
		TITLE 'MiniGUI Browse Demo' ;
		MAIN NOMAXIMIZE ;
		ON INIT OpenTables() ;
		ON RELEASE CloseTables()

		DEFINE MAIN MENU 
			POPUP 'File'
				ITEM 'New'	ACTION IF( Form_1.ButtonNew.Enabled, ButtonNewClick(), NIL )
				ITEM 'Delete'	ACTION IF( Form_1.ButtonDelete.Enabled, ButtonDeleteClick(), NIL )
				SEPARATOR
				ITEM 'Exit'	ACTION Form_1.Release
			END POPUP
			POPUP 'Help'
				ITEM 'About'	ACTION MsgInfo ("MINIGUI - Browse Demo"+CRLF+;
 								"Copyright 2002 Roberto Lopez <harbourminigui@gmail.com>"+CRLF+;
 								"http://harbourminigui.googlepages.com/"+CRLF+CRLF+;
 								"Update 2002 Interativo Networks <xharbour@terra.com.br>"+CRLF+;
 	       							"Daniel Crocciari"+CRLF+;
        							"http://www.ihpz.net", "About" )
			END POPUP
		END MENU

		@ 05,10 BROWSE Browse_1 ;
			WIDTH 515 ;
			HEIGHT 180 ;
			HEADERS { 'Married', 'Code', 'First Name', 'Last Name', 'Birth Date' } ;
			WIDTHS { 55, 55, 145, 145, 90 } ;
			WORKAREA Teste ;
			FIELDS { 'Teste->Married', 'Teste->Code', 'Teste->First', 'Teste->Last', 'Teste->Birth' } ;
			VALUE 1 ;
			ON CHANGE { || BrowseChange() } ;
			ON DBLCLICK { || BrowseEdit() } ;
			DYNAMICBACKCOLOR { NIL, bColor, bColor, bColor, bColor } ;
			NOLINES ;
			JUSTIFY { BROWSE_JTFY_LEFT, BROWSE_JTFY_RIGHT, BROWSE_JTFY_LEFT, BROWSE_JTFY_LEFT, BROWSE_JTFY_CENTER } ;
			IMAGE { "br_no","br_ok" }

		@ 200,010 LABEL LabelCode VALUE "Code" WIDTH 95 HEIGHT 25
		@ 200,105 TEXTBOX TextBoxCode ;
			VALUE "" ;
			WIDTH 100 HEIGHT 25

		@ 230,010 LABEL LabelFirst VALUE "First Name" WIDTH 95 HEIGHT 25
		@ 230,105 TEXTBOX TextBoxFirst ;
			VALUE "" ;
			WIDTH 300 HEIGHT 25

		@ 260,010 LABEL LabelLast VALUE "Last Name" WIDTH 95 HEIGHT 25
		@ 260,105 TEXTBOX TextBoxLast ;
			VALUE "" ;
			WIDTH 300 HEIGHT 25

		@ 290,012 LABEL LabelBirthdate VALUE "Birth Date" WIDTH 95 HEIGHT 25
		@ 290,105 DATEPICKER DatePickerBirth ;
			WIDTH 100 ;
			VALUE Date()

		@ 320,012 LABEL LabelMarried VALUE "Married" WIDTH 95 HEIGHT 25
		@ 320,105 CHECKBOX CheckBoxMarried ;
			CAPTION "Yes Married" ;
	                WIDTH 100 HEIGHT 25 ;
	                VALUE .t.

		@ 350,012 LABEL LabelBio VALUE "Bio" WIDTH 95 HEIGHT 25
		@ 350,105 EDITBOX EditBoxBio ;
	                WIDTH 300 HEIGHT 130 ;
                    	VALUE "" ;
			NOHSCROLL

		@ 325,425 IMAGE ImagePhoto ;
			PICTURE "0.bmp" ;
			WIDTH 100 HEIGHT 125
		@ 455,425 TEXTBOX TextBoxPhoto ;
			VALUE "" ;
			WIDTH 100 HEIGHT 25

		@ 200,425 BUTTON ButtonNew ;
			CAPTION "&New" ;
			ACTION ButtonNewClick() ;
			WIDTH 100 HEIGHT 25
		@ 230,425 BUTTON ButtonSave ;
			CAPTION "&Save" ;
			ACTION ButtonSaveClick() ;
			WIDTH 100 HEIGHT 25
		@ 260,425 BUTTON ButtonCancel ;
			CAPTION "&Cancel" ;
			ACTION ButtonCancelClick() ;
			WIDTH 100 HEIGHT 25
		@ 290,425 BUTTON ButtonDelete ;
			CAPTION "&Delete" ;
			ACTION ButtonDeleteClick() ;
			WIDTH 100 HEIGHT 25

	END WINDOW

	ON KEY ESCAPE OF Form_1 ACTION IF( Form_1.ButtonCancel.Enabled, ButtonCancelClick(), NIL )

	Form_1.TextBoxCode.Enabled := .f.
	Form_1.TextBoxFirst.Enabled := .f.
	Form_1.TextBoxLast.Enabled := .f.
	Form_1.DatePickerBirth.Enabled := .f.
	Form_1.CheckBoxMarried.Enabled := .f.
	Form_1.TextBoxPhoto.Enabled := .f.	
	Form_1.EditBoxBio.Enabled := .f.
	Form_1.ButtonSave.Enabled := .f.
	Form_1.ButtonCancel.Enabled := .f.

        Form_1.Browse_1.SetFocus
        
	CENTER WINDOW Form_1        
	ACTIVATE WINDOW Form_1

Return Nil

Function OpenTables()
	Use Test Alias Teste New
	BrowseChange()  // force first data update
Return Nil

Function CloseTables()
	Use
Return Nil

Function BrowseEdit()
	
	BrowseChange()
	
	Form_1.TextBoxFirst.Enabled := .t.
	Form_1.TextBoxLast.Enabled := .t.
	Form_1.DatePickerBirth.Enabled := .t.
	Form_1.CheckBoxMarried.Enabled := .t.
	Form_1.TextBoxPhoto.Enabled := .t.
	Form_1.EditBoxBio.Enabled := .t.
	Form_1.ButtonNew.Enabled := .f.
	Form_1.ButtonSave.Enabled := .t.
	Form_1.ButtonCancel.Enabled := .t.
	Form_1.ButtonDelete.Enabled := .f.
	
	Form_1.TextBoxFirst.SetFocus

Return Nil

Function ButtonNewClick()

	Form_1.TextBoxCode.Value := "" 
	Form_1.TextBoxFirst.Value :=  "" 
	Form_1.TextBoxLast.Value :=  "" 
	Form_1.DatePickerBirth.Value :=  date() 
	Form_1.TextBoxPhoto.Value :=  "0.bmp" 
	Form_1.CheckBoxMarried.Value :=  .t. 
	Form_1.EditBoxBio.Value :=  "" 
	
	Form_1.ImagePhoto.Picture := "0.bmp"

	Form_1.TextBoxFirst.Enabled := .t.
	Form_1.TextBoxLast.Enabled := .t.
	Form_1.DatePickerBirth.Enabled := .t.
	Form_1.CheckBoxMarried.Enabled := .t.	
	Form_1.TextBoxPhoto.Enabled := .t.
	Form_1.EditBoxBio.Enabled := .t.
	Form_1.ButtonNew.Enabled := .f.
	Form_1.ButtonSave.Enabled := .t.
	Form_1.ButtonCancel.Enabled := .t.
	Form_1.ButtonDelete.Enabled := .f.	
	Form_1.Browse_1.Enabled := .f.

	Form_1.TextBoxFirst.SetFocus

Return Nil

Function ButtonDeleteClick()
	Local vRecno := Form_1.Browse_1.Value
	
	Goto vRecno
	
	If MsgYesNo( "Delete This Record?"+CRLF+CRLF+;
			"Code: "+alltrim(str(Teste->Code))+CRLF+;
			"First Name: "+alltrim(Teste->First)+CRLF+;
			"Last Name: "+alltrim(Teste->Last), "Confirmation" )
		Delete
		Skip -1
		Form_1.Browse_1.Value := Teste->(Recno())
		Form_1.Browse_1.Refresh
		Form_1.Browse_1.SetFocus
	EndIf

Return Nil

Function ButtonSaveClick()

	Local vTextBoxCode := Val( Form_1.TextBoxCode.Value ) 
	Local vTextBoxFirst := Form_1.TextBoxFirst.Value 
	Local vTextBoxLast := Form_1.TextBoxLast.Value 
	Local vDatePickerBirth := Form_1.DatePickerBirth.Value 
	Local vCheckBoxMarried := Form_1.CheckBoxMarried.Value 
	Local vTextBoxPhoto := Form_1.TextBoxPhoto.Value 
	Local vEditBoxBio := Form_1.EditBoxBio.Value 
	
	If vTextBoxCode <= 0
		Goto Bottom
		vTextBoxCode := Teste->Code + 1
		Append Blank
		Replace Teste->Code With vTextBoxCode
	EndIf
	
	Replace Teste->First With vTextBoxFirst
	Replace Teste->Last With vTextBoxLast
	Replace Teste->Birth With vDatePickerBirth
	Replace Teste->Married With vCheckBoxMarried
	Replace Teste->Photo With vTextBoxPhoto
	Replace Teste->Bio With vEditBoxBio
	
	Form_1.TextBoxCode.Value := alltrim(str(Teste->Code))
	Form_1.TextBoxFirst.Enabled := .f.
	Form_1.TextBoxLast.Enabled := .f.
	Form_1.DatePickerBirth.Enabled := .f.
	Form_1.CheckBoxMarried.Enabled := .f.
	Form_1.TextBoxPhoto.Enabled := .f.
	Form_1.EditBoxBio.Enabled := .f.
	Form_1.ButtonNew.Enabled := .t.
	Form_1.ButtonSave.Enabled := .f.
	Form_1.ButtonCancel.Enabled := .f.	
	Form_1.ButtonDelete.Enabled := .t.
	Form_1.Browse_1.Enabled := .t.
	
	Form_1.ImagePhoto.Picture := alltrim(Teste->Photo)
	
	Form_1.Browse_1.Value := Teste->(Recno())
	Form_1.Browse_1.Refresh
	
	Form_1.Browse_1.SetFocus

Return Nil

Function ButtonCancelClick()

	Form_1.TextBoxFirst.Enabled := .f.
	Form_1.TextBoxLast.Enabled := .f.
	Form_1.DatePickerBirth.Enabled := .f.
	Form_1.CheckBoxMarried.Enabled := .f.
	Form_1.TextBoxPhoto.Enabled := .f.
	Form_1.EditBoxBio.Enabled := .f.
	Form_1.ButtonNew.Enabled := .t.
	Form_1.ButtonSave.Enabled := .f.
	Form_1.ButtonCancel.Enabled := .f.
	Form_1.ButtonDelete.Enabled := .t.
	Form_1.Browse_1.Enabled := .t.

	BrowseChange()
	Form_1.Browse_1.SetFocus

Return Nil

Function BrowseChange()
	Local vRecno := Form_1.Browse_1.Value 
	
	Goto vRecno
	
	Form_1.TextBoxCode.Value := alltrim(str(Teste->Code))
	Form_1.TextBoxFirst.Value := alltrim(Teste->First) 
	Form_1.TextBoxLast.Value := alltrim(Teste->Last) 
	Form_1.DatePickerBirth.Value := Teste->Birth 
	Form_1.CheckBoxMarried.Value := Teste->Married 
	Form_1.EditBoxBio.Value := Teste->Bio 
	Form_1.TextBoxPhoto.Value := alltrim(Teste->Photo) 
	
	Form_1.ImagePhoto.Picture := IF( File( alltrim(Teste->Photo) ), alltrim(Teste->Photo), "0.bmp" )

Return Nil
