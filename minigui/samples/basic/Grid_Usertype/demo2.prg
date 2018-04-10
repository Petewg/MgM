/*
 * MiniGUI USERTYPE Grid Demo 2
 * by Adam Lubszczyk <adam_l@poczta.onet.pl>
*/

#include "minigui.ch"

STATIC aCol1Rows:={1,1,1} //value of 1-st column

PROCEDURE Main

DEFINE WINDOW Form_1 ;
	AT 0,0 ;
	WIDTH 640 ;
	HEIGHT 400 ;
	TITLE "DYNAMIC in GRID INPLACE EDIT" ;
	MAIN

	@ 10,10 GRID Grid_1 ;
		WIDTH 620 ;
		HEIGHT 330 ;
		HEADERS {'Column 1 (COMBOBOX)','Column 2 (DYNAMIC)','Info (No Edit)'} ;
		WIDTHS {160,160,200} ;
		ITEMS {{1,1,'row 1 - variable COMBOBOX'},{1,1,'row 2 - variable COMBOBOX'},{1,1,'row 3 - variable types'}} ;
		EDIT ;
		COLUMNWHEN {{||.T.},{||.T.},{||.F.}} ;
		INPLACE { {'COMBOBOX',{"Number","Words","Logic"}}, {'DYNAMIC',{|r,c|MyDynEdit(r,c)}} } ;
		COLUMNVALID {{||Col1Change()}}

END WINDOW

CENTER WINDOW Form_1

ACTIVATE WINDOW Form_1

RETURN

************************************
// Function used by codeblock from 'DYNAMIC'
// return normal array used in INPLACE EDIT
FUNCTION MyDynEdit(nRow,nCol)
LOCAL aRet
LOCAL nOpt1

nOpt1:=aCol1Rows[nRow] //selected option in column 1

// !!! WARNING !!!
// We can not use: nOpt1:=Form_1.Grid_1.Cell(nRow,1)
// because this also must call MyDynEdit() and make unstop-loop
// so we use public array aCol1Rows with copy of values column 1

IF nRow==1 .OR. nRow == 2
	IF nOpt1 == 1 //Number
		aRet:={'COMBOBOX',{"1","2","3"}}
	ELSEIF nOpt1 == 2 //Words
		aRet:={'COMBOBOX',{"Harbour","Mini","GUI","User"}}
	ELSEIF nOpt1 == 3 //Logic
		aRet:={'COMBOBOX',{"True","False"}}
	ENDIF
ENDIF

IF nRow==3
	IF nOpt1 == 1 //Number
		aRet:={'SPINNER',-10,10 }
	ELSEIF nOpt1 == 2 //Words
		aRet:={'COMBOBOX',{"Harbour","Mini","GUI","User"}}
	ELSEIF nOpt1 == 3 //Logic
		aRet:={'CHECKBOX',"True","False"}
	ENDIF
ENDIF

RETURN aRet
********************************
FUNCTION Col1Change()
LOCAL r:=This.CellRowIndex
LOCAL v:=This.CellValue

//update public array with copy of values column 1
aCol1Rows[r] := v

RETURN .T.
