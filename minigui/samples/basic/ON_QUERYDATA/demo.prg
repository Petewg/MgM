/*
 * MiniGUI Virtual Grid Demo
 *
 */

#include "minigui.ch"

MEMVAR lAscend

FUNCTION Main
	LOCAL aData := Array( 1000, 2 )

	AEval( aData, {|e| e[ 1 ] := Str( Random(1000) ), e[ 2 ] := Str( Random(1000) )} )

	PRIVATE lAscend := .T.

	DEFINE WINDOW Form_1 ;
		CLIENTAREA 420, 370 ;
		TITLE 'Column Sort In Virtual Grid' ;
		MAIN 

		DEFINE MAIN MENU
			DEFINE POPUP 'File'
				MENUITEM 'Exit' ACTION ThisWindow.Release
			END POPUP
		END MENU

		@ 10,10 GRID Grid_1 ;
			WIDTH 400 ;
			HEIGHT 330 ;
			HEADERS { '', 'Column 2', 'Column 3' } ;
			WIDTHS { 0, 140, 140 };
			VIRTUAL ;
			ITEMCOUNT Len(aData) ;
			ON QUERYDATA QueryTest(aData) ;
			ON HEADCLICK { , {|| SortThisColumn(aData, '1') }, {|| SortThisColumn(aData, '2') } } ;
			IMAGE { "br_no", "br_ok" }

	END WINDOW

	CENTER WINDOW Form_1

	ACTIVATE WINDOW Form_1

RETURN Nil


PROCEDURE QueryTest( aArray )

	IF This.QueryColIndex == 1

		IF Int( This.QueryRowIndex / 2 ) == This.QueryRowIndex / 2
			This.QueryData := 0
		ELSE
			This.QueryData := 1
		ENDIF

	ELSE

		This.QueryData := aArray[This.QueryRowIndex][This.QueryColIndex - 1]

	ENDIF

RETURN


STATIC FUNCTION SortThisColumn( aArray, cEle )
	LOCAL cBlock := "{|x,y| x[" + cEle + "]" + iif( lAscend, "<", ">" ) + "y[" + cEle + "]}"

#ifndef __XHARBOUR__
	ASort( aArray, , , Eval( hb_macroBlock( cBlock ) ) )
#else
	ASort( aArray, , , &( cBlock ) )
#endif
	Form_1.Grid_1.Refresh

RETURN ( lAscend := !lAscend )
