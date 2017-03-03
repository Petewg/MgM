/*
 * MINIGUI - Harbour Win32 GUI library Demo
 * http://harbourminigui.googlepages.com/
 *
 * INI Demo 2 contributed by Jacek Kubica <kubica@wssk.wroc.pl>
 * Demo demonstrate use of 2 new INI function
 * _GetSectionNames(cIniFile) - return 1-dimmensional array with list of sections in <cIniFile>
 * _GetSection(cSection,cIniFile) - return 2-dimmensional array with list (subarrays {key,value}) 
 *                                  from section <cSection> in <cIniFile> 
*/

#include "minigui.ch"

*-----------------------------
Function Main(cIniFile)
*-----------------------------

	SET CENTURY ON

	DEFINE WINDOW Form_1 ;
		AT 338,157 WIDTH 638 HEIGHT 420+iif(IsThemed(),2*GetBorderHeight(),0) ;
		MAIN ;
		TITLE "INI File demo 2 (C) 2005 Jacek Kubica" ;
		ICON "INIDEMO" ;
		ON INIT {|| IIF(!EMPTY(cIniFile), OPEN_INI(strtran(cIniFile,'"','')), )} ;
		ON MAXIMIZE RESIZEIT() ;
		ON SIZE RESIZEIT()

		@ 40,30 LABEL Label_1 VALUE "INI File" ;
			WIDTH 72 HEIGHT 19 FONT "MS Sans serif" SIZE 9 BOLD

		@ 40,106 TEXTBOX TextBox_1 ;
			WIDTH 460 HEIGHT 19 VALUE "C:\MiniGUI\SAMPLES\BASIC\INI\demo2.ini" ;
			BACKCOLOR {255,255,255}

		@ 39,570 BUTTON Button_1 CAPTION "..." WIDTH 33 HEIGHT 21 ;
     	            ACTION {|| ( (Form_1.TextBox_1.Value := Getfile ( { {'ini files ','*.ini'} }, ;
			'Select ini file'), IIF(FILE(Form_1.TextBox_1.Value), OPEN_INI(Form_1.TextBox_1.Value), ) ))}
		
		@ 110,30 GRID Grid_1 ;
			WIDTH 259 HEIGHT 198 ;
			HEADERS {"Section"} ;
			WIDTHS {250} ;
			ITEMS { {""} } VALUE 0 ;
			FONT "MS Sans serif" SIZE 9 ;
			ON CHANGE {|| Change_section(This.Value, Form_1.TextBox_1.Value)} ;
			BACKCOLOR { 255, 255, 128 }

		@ 110,304 GRID Grid_2 ;
			WIDTH 300 HEIGHT 198 ;
			HEADERS {"Item","Value"} ;
			WIDTHS {70,225} ;
			ITEMS { {"",""} } VALUE 0 ;
			FONT "MS Sans serif" SIZE 9 ;
			BACKCOLOR { 255, 255, 128 }                

		@ 86,31 LABEL Label_2 VALUE "Section(s)" ;
			WIDTH 120 HEIGHT 20 FONT "MS Sans serif" SIZE 9 BOLD

		@ 87,305 LABEL Label_3 VALUE "Key(s) and value(s)" ;
			WIDTH 156 HEIGHT 18 FONT "MS Sans serif" SIZE 9 BOLD

		@ 318,54 BUTTON Button_2 CAPTION "Open INI" ;
			WIDTH 100 HEIGHT 28 FONT "MS Sans serif" SIZE 9 BOLD ;
			ACTION OPEN_INI(Form_1.TextBox_1.Value)

		@ 318,505 BUTTON Button_4 CAPTION "Exit" ;
			WIDTH 100 HEIGHT 28 FONT "MS Sans serif" SIZE 9 BOLD ;
			ACTION ThisWindow.Release

		DEFINE MAIN MENU 
			POPUP '&INI File'
				ITEM 'Open INI File'	ACTION OPEN_INI(Form_1.TextBox_1.Value)
				SEPARATOR
				ITEM 'Exit'		ACTION ThisWindow.Release
			END POPUP
                 	POPUP '&Help'
				ITEM '&About'		ACTION MsgInfo ("HMG INI Demo 2") 
			END POPUP
		END MENU

		DEFINE STATUSBAR FONT "MS Sans serif" SIZE 9 BOLD
			STATUSITEM "" 	 
		END STATUSBAR

	END WINDOW

	CENTER WINDOW Form_1

	ACTIVATE WINDOW Form_1

Return Nil

*----------------------------------------------+
STATIC PROCEDURE RESIZEIT()
*----------------------------------------------+

	Form_1.Grid_2.Width := Form_1.Width-338
	Form_1.Grid_1.Height:= Form_1.Height-222-iif(IsThemed(),2*GetBorderHeight(),0) 
	Form_1.Grid_2.Height:= Form_1.Grid_1.Height

	Form_1.Button_2.Row := Form_1.Height-102-iif(IsThemed(),2*GetBorderHeight(),0) 
	Form_1.Button_4.Row := Form_1.Button_2.Row

Return

*----------------------------------------------+
Function OPEN_INI(cIniFile)
*----------------------------------------------+
Local aRet,aLista,i,p

 if !FILE(cIniFile)
    MsgStop(cIniFile+CRLF+"don`t exist")
    return nil
 endif

 Form_1.Grid_1.DeleteAllItems
 Form_1.Grid_2.DeleteAllItems

 aLista := _GetSectionNames(cIniFile)

 if len(aLista)>0
    for i=1 to len(aLista)
	Form_1.Grid_1.AddItem({aLista[i]})
    next i

    aRet:=_GetSection(aLista[1],cIniFile)

    if len(aRet)>0
      for p=1 to len(aRet)
	Form_1.Grid_2.AddItem({aRet[p,1],aRet[p,2]})
      next p
    endif
 
 endif

 Form_1.Grid_1.Value:=1
 Form_1.Textbox_1.Value :=cIniFILE
 Form_1.StatusBar.Item(1) :=cIniFILE
 Form_1.Grid_1.SetFocus

Return NIL

*-------------------------------------------------+
Function Change_section(nSectionPos,cIniFile)
*-------------------------------------------------+
Local aLista,aRet,p

 aLista := _GetSectionNames(cIniFile)

 If nSectionPos <= 0 .or. nSectionPos > len(aLista)
	Return NIL
 endif

 Form_1.Grid_2.DeleteAllItems

 aRet:=_GetSection(aLista[nSectionPos],cIniFile)

 if len(aRet)>0
    for p=1 to len(aRet)
	Form_1.Grid_2.AddItem({aRet[p,1],aRet[p,2]})
    next p
 endif

Return NIL
