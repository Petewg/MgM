/*
 *
 *	MiniSql Basic MySql Access Sample.
 *	Roberto Lopez <harbourminigui@gmail.com>
 *
 *	To test this sample: 
 *
 *	- You must link MySql libraries (Compile demo /m).
 *      - 'libmysql.dll' must be in the same folder as the program.
 *	- 'root' at 'localhost' with no password is assumed.
 *	- 'NAMEBOOK' database and 'NAMES' existence is assumed
 *	  (you may create them using 'demo_1.prg' sample 
 *	  at \minigui\samples\basic\mysql)
 *	
*/

#include "MiniGui.ch"
#include "sql.ch"

#define MsgInfo( c ) MsgInfo( c, , , .f. )
#define MsgStop( c ) MsgInfo( c, "Error", , .f. )

Static SqlResult, SqlAffectedRows

MemVar SqlTrace, cCode
*------------------------------------------------------------------------------*
Procedure Main
*------------------------------------------------------------------------------*

	SET SQLTRACE OFF

	DEFINE WINDOW Win_1 ;
		AT 0,0 ;
		WIDTH 400 ;
		HEIGHT 400 ;
		TITLE 'MiniSql Basic Sample' ;
		MAIN 

		DEFINE MAIN MENU

			DEFINE POPUP 'Query'
				MENUITEM 'Open Query Window'	ACTION ShowQuery()
				SEPARATOR	                                       			                                    
				ITEM "Exit"			ACTION ThisWindow.Release()
			END POPUP

		END MENU

	END WINDOW

	Win_1.Center

	ACTIVATE WINDOW Win_1

Return

*------------------------------------------------------------------------------*
Procedure ShowQuery()
*------------------------------------------------------------------------------*
Local nHandle
Local i

	* Connect

      	nHandle := SqlConnect( 'localhost' , 'root' , '' )

	if Empty( nHandle )
		MsgStop( "Can't Connect" )
		Return 
	EndIf

	* Select DataBase

	if SqlSelectD( nHandle , 'NAMEBOOK' ) != 0
		MsgStop( "Can't Select Database" )
		Return
	Endif


	SELECT * FROM NAMES WHERE NAME LIKE "k%"

	If Len( SqlResult ) == 0
		MsgStop ( "No Results!" )
		Return
	EndIf

	Define Window ShowQuery ;
		At 0,0 ;
		Width 640 ;
		Height 480 ;
		Title 'Show Query Name Like "k%"' ;
		Modal ;
		NoSize

		Define Main Menu
			Define Popup 'Operations'
				MenuItem 'Edit Row' Action EditRow( nHandle )
				MenuItem 'Delete Row' Action DeleteRow( nHandle )
				Separator
				MenuItem 'Refresh' Action UpdateGrid( nHandle )
			End Popup
		End Menu

		Define Grid Grid_1
			Row 0
			Col 0
			Width 630
			Height 430
			Headers {'Code','Name'}
			Widths {250,250}
		End Grid

	End Window		

	For i := 1 To Len ( SqlResult )
		ShowQuery.Grid_1.AddItem ( { SqlResult [i] [1] , SqlResult [i] [2] } )
	Next i

	ShowQuery.Center

	ShowQuery.Activate

Return

*------------------------------------------------------------------------------*
Procedure EditRow( nHandle )
*------------------------------------------------------------------------------*
Private cCode := ShowQuery.Grid_1.Cell (1,1)

	LOCK TABLES NAMES WRITE

	UPDATE NAMES SET Name = "KELLY ROSA" WHERE CODE = "&cCode"

	If SqlAffectedRows == 1
		MsgInfo ( "Update is successful!" )
		UpdateGrid( nHandle )
	EndIf

	UNLOCK TABLES

Return

*------------------------------------------------------------------------------*
Procedure DeleteRow( nHandle )
*------------------------------------------------------------------------------*
Private cCode := ShowQuery.Grid_1.Cell (1,1)

	LOCK TABLES NAMES WRITE

	DELETE FROM NAMES WHERE CODE = "&cCode"

	If SqlAffectedRows == 1
		MsgInfo ( "Removal is successful!" )
		UpdateGrid( nHandle )
	EndIf

	UNLOCK TABLES

Return

*------------------------------------------------------------------------------*
Procedure UpdateGrid( nHandle )
*------------------------------------------------------------------------------*
Local i

	SELECT * FROM NAMES WHERE NAME LIKE "k%"

	ShowQuery.Grid_1.DeleteAllItems()

	For i := 1 To Len ( SqlResult )
		ShowQuery.Grid_1.AddItem ( { SqlResult [i] [1] , SqlResult [i] [2] } )
	Next i

Return

*------------------------------------------------------------------------------*
* Adding MiniSql Code To The Program (It should be a library, I know :)
*------------------------------------------------------------------------------*
#include "minisql.prg"

