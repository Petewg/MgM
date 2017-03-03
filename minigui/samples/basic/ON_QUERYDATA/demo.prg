/*
* MiniGUI Virtual Grid Demo
*/

#include "minigui.ch"

Memvar lAscend

Function Main
Local aData := array( 1000, 2 )

	AEVAL(aData, {|e,i| e[1] := str(random(1000)), e[2] := str(random(1000))})

	Private lAscend := .t.

	DEFINE WINDOW Form_1 ;
		AT 0,0 ;
		WIDTH 450 ;
		HEIGHT 400 ;
		TITLE 'Sort Virtual Grid Demo' ;
		MAIN 

		DEFINE MAIN MENU
			DEFINE POPUP 'File'
				MENUITEM 'Exit' ACTION ThisWindow.Release
			END POPUP
		END MENU

		@ 10,10 GRID Grid_1 ;
		WIDTH 400 ;
		HEIGHT 330 ;
		HEADERS {'','Column 2','Column 3'} ;
		WIDTHS {0,140,140};
		VIRTUAL ;
		ITEMCOUNT Len(aData) ;
		ON QUERYDATA QueryTest(aData) ;
		ON HEADCLICK { , {|| SortThisColumn(aData,'1') }, {|| SortThisColumn(aData,'2') } } ;
		IMAGE { "br_no", "br_ok" }

	END WINDOW

	CENTER WINDOW Form_1

	ACTIVATE WINDOW Form_1

Return Nil

Procedure QueryTest(aArray)

	If This.QueryColIndex == 1
		If Int ( This.QueryRowIndex / 2 ) == This.QueryRowIndex / 2
			This.QueryData := 0
		Else
			This.QueryData := 1
		EndIf
	Else
		This.QueryData := aArray[This.QueryRowIndex][This.QueryColIndex-1]
	EndIf

Return

Static Function SortThisColumn(aArray, cEle)
Local bBlock := "{|x,y| x[" + cEle + "]" + if(lAscend, "<", ">") + "y[" + cEle + "]}"

	aSort( aArray, , , &bBlock )

	Form_1.Grid_1.ItemCount := Len(aArray)

Return ( lAscend := !lAscend )
