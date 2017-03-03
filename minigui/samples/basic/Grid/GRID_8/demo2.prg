/*
 * MiniGUI Virtual Grid Demo
*/

#include "hmg.ch"

Function Main
	Local bColor, fColor
	Local aData

	SET CENTURY ON
	SET DATE GERMAN

	bColor := { || iif ( This.CellRowIndex/2 == int(This.CellRowIndex/2) , { 245,245,245 } , { 255,255,255 } ) }	
	fColor := { || iif ( This.CellRowIndex/2 == int(This.CellRowIndex/2) , { 0,0,150 } , { 0,0,0 } ) }	

	aData := LoadData()

	AEval( aData, { |Value, RowIndex| Value[1] := StrZero( Value[1], 10 ), ;
		Value[2] := Trim( if ( RowIndex/2 == int(RowIndex/2) , Upper(Value[2]) , Lower(Value[2]) ) ), ;
		Value[3] := Trim( if ( RowIndex/2 == int(RowIndex/2) , Lower(Value[3]) , Upper(Value[3]) ) ), ;
		Value[4] := DtoC( Value[4] ), ;
		Value[5] := if ( Value[5] == .T. , 'Yes' , 'No' ), ;
		Value[6] := "<memo>" } )

	CellNavigationColor (_SELECTEDCELL_BACKCOLOR, { 136, 177, 75 } )

	DEFINE WINDOW Form_1 ;
		AT 0,0 ;
		WIDTH 800 ;
		HEIGHT 510 ;
		TITLE 'Hello World!' ;
		MAIN 

		DEFINE MAIN MENU 
			POPUP 'File'
				MENUITEM 'Get Item'		ACTION GetItem()
				MENUITEM 'Export Grid To DBF'	ACTION ExportToDBF("EXPORT", aData)
				MENUITEM 'Export DBF To Excel'	ACTION ExportToXLS("Test")
				SEPARATOR
				MENUITEM 'Exit'			ACTION ThisWindow.Release
			END POPUP
		END MENU

		@ 10,10 GRID Grid_1 ;
			WIDTH 770 ;
			HEIGHT 440 ;
			HEADERS {'Column 1','Column 2','Column 3','Column 4','Column 5','Column 6'} ;
			WIDTHS {100,180,180,100,90,90};
			VIRTUAL ;
			ITEMCOUNT Len(aData) ;
			ON QUERYDATA QueryTest(aData) ;
			CELLNAVIGATION ;
			VALUE { 1 , 1 } ;
			JUSTIFY { BROWSE_JTFY_RIGHT, BROWSE_JTFY_CENTER, BROWSE_JTFY_CENTER, BROWSE_JTFY_CENTER, BROWSE_JTFY_CENTER, BROWSE_JTFY_CENTER } ;
			DYNAMICFORECOLOR { fColor , fColor , fColor , fColor , fColor , fColor } ;
			DYNAMICBACKCOLOR { bColor , bColor , bColor , bColor , bColor , bColor } ;
			LOCKCOLUMNS 1 ;
			FONT 'Courier New' ;
			SIZE 9 

	END WINDOW

	CENTER WINDOW Form_1

	ACTIVATE WINDOW Form_1
   
Return Nil

Procedure QueryTest( aArr )

	This.QueryData := aArr[This.QueryRowIndex][This.QueryColIndex]

Return

Function LoadData
	Local aArr

	USE TEST
	INDEX ON TEST->CODE TO CODE TEMPORARY
	GO TOP

	aArr := Test->( HMG_DbfToArray() )

	USE

Return aArr


PROCEDURE GETITEM()
	Local a := Form_1.Grid_1.Value

	MsgDebug( Form_1.Grid_1.Item( a[1] ) )

RETURN


#ifndef __XHARBOUR__
   #xcommand TRY              => BEGIN SEQUENCE WITH {|__o| break(__o) }
   #xcommand CATCH [<!oErr!>] => RECOVER [USING <oErr>] <-oErr->
#endif

FUNCTION ExportToDBF( cDbf, aData, aStruct )
	LOCAL cAlias, lOK := .T.

	IF ValType( aStruct ) != "A"
		USE TEST
		aStruct := DbStruct()
		USE
	ENDIF

	TRY
		DbCreate( cDbf, aStruct, , .T., cAlias := "TEMP" + hb_ntos( _GetId() ) )
	CATCH
		MsgAlert( "Can not create an export database.", "Warning" )
		lOK := .F.
	END

	IF lOK
		IF ( cAlias )->( HMG_ArrayToDBF( aData ) )
			( cAlias )->( DbCloseArea() )
			MsgInfo( "Export to DBF was done." )
		ENDIF
	ENDIF

RETURN lOK


PROCEDURE ExportToXLS( cDbf )
	LOCAL cAlias := "TEMP"

	USE (cDbf) ALIAS (cAlias)

	IF ( cAlias )->( HMG_DbfToExcel() )
      MSGINFO( "Exported!" )
   ELSE
      MSGINFO( "Can't Export!" )
   ENDIF
   
   
	( cAlias )->( DbCloseArea() )
   

RETURN
