/*
 * MiniGUI Virtual Grid Demo
*/

#include "minigui.ch"

* When using virtual Grids you must avoid to use Item property and AddItem method.
* It can generate unexpected results.

Function Main
Local bColor
Local aData := ARRAY( 10000, 3 )

	AEVAL( aData, { |e| e[1] := str(random(10000)), e[2] := str(random(10000)), e[3] := str(random(10000)) } )

	bColor := { || iif( This.CellRowIndex/2 <> int(This.CellRowIndex/2) , { 222,222,222 } , { 255,255,255 } ) }	

	DEFINE WINDOW Form_1 ;
		AT 0,0 ;
		WIDTH 450 ;
		HEIGHT 400 ;
		TITLE 'Hello World!' ;
		MAIN 

		DEFINE MAIN MENU
			DEFINE POPUP 'File'
				MENUITEM 'Change ItemCount' ACTION Form_1.Grid_1.ItemCount := Min(Len(aData),Val(InputBox('New Value','Change ItemCount')))
			END POPUP
		END MENU

		@ 10,10 GRID Grid_1 ;
		WIDTH 420 ;
		HEIGHT 326 ;
		HEADERS {'Column 1','Column 2','Column 3'} ;
		WIDTHS {132,132,132};
		VIRTUAL ;
		ITEMCOUNT Len(aData) ;
		ON QUERYDATA QueryTest(aData) ;
		COLUMNWHEN 	{ ;
				{ || WhenTest() } , ;
				{ || WhenTest() } , ;
				{ || WhenTest() } ;
				} ;
		COLUMNVALID 	{ ;
				{ || ValidTest(aData) } , ;
				{ || ValidTest(aData) } , ;
				{ || ValidTest(aData) } ;
				} ;
		CELLNAVIGATION ;
		VALUE 1 ;
		EDIT INPLACE {} ;
		DYNAMICBACKCOLOR { bColor , bColor , bColor } 

	END WINDOW

	CENTER WINDOW Form_1

	ACTIVATE WINDOW Form_1

Return Nil


Procedure QueryTest( aArr )

	This.QueryData := aArr[This.QueryRowIndex][This.QueryColIndex]

Return


Function ValidTest( aArr )
Local cString := ''
Local lRet

	cString += 'Cell Edited!'					   + chr(13) + chr(10) 
	cString += 							   + chr(13) + chr(10) 
	cString += 'This.CellRowIndex: ' + alltrim(str(This.CellRowIndex)) + chr(13) + chr(10) 
	cString += 'This.CellColIndex: ' + alltrim(str(This.CellColIndex)) + chr(13) + chr(10) 
	cString += 'This.CellValue:    ' + alltrim( AutoConvert(This.CellValue) ) 

	MsgInfo ( cString )

	IF ( lRet := !( empty ( This.CellValue ) ) )
		aArr [This.CellRowIndex] [This.CellColIndex] := This.CellValue
	ENDIF

Return lRet


Function WhenTest
Local lRet
Local cString := ''

	cString += 'Entering Cell!'					   + chr(13) + chr(10) 
	cString += 							   + chr(13) + chr(10) 
	cString += 'This.CellRowIndex: ' + alltrim(str(This.CellRowIndex)) + chr(13) + chr(10) 
	cString += 'This.CellColIndex: ' + alltrim(str(This.CellColIndex)) + chr(13) + chr(10) 
	cString += 'This.CellValue:    ' + alltrim( AutoConvert(This.CellValue) ) 

	MsgInfo ( cString )

	lRet := ( This.CellColIndex < 3 )

Return lRet


Function AutoConvert( xValue )

Return HB_ValToStr( xValue )
