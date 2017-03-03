/*
 * MINIGUI - Harbour Win32 GUI library Demo
*/

#include "minigui.ch"

MEMVAR cUserName, dDate

STATIC nStatic

PROCEDURE Main()

	LOCAL lValue AS LOGICAL, aArray AS ARRAY, bBlock AS BLOCK
	STATIC nCount AS NUMERIC

	SET CENTURY ON

	PUBLIC cUserName AS STRING
	PRIVATE dDate AS DATE

	ASSIGN nStatic := 0
	ASSIGN nCount := 1
	ASSIGN aArray := { 1, "2", .T. }
	ASSIGN bBlock := {|| .T. }

	DEFINE WINDOW Form_1 ;
		AT 0,0 ;
		WIDTH 350 ;
		HEIGHT 300 ;
		TITLE 'Strongly Typed Variables Test' ;
		MAIN

		DEFINE MAIN MENU

			DEFINE POPUP "Tests"
				MENUITEM 'Assign Valid Value' ACTION MsgInfo( iif( DoTest( aArray ), "Success", "Failure" ), "Result" )
				MENUITEM 'Assign Wrong Value' ACTION DoTest2( aArray )
				SEPARATOR
                                ITEM 'Exit' ACTION Form_1.Release()
			END POPUP

			DEFINE POPUP "Info"
				MENUITEM 'Get String Value'	ACTION MsgInfo( cUserName, "Public Value" )
				MENUITEM 'Get Date Value'	ACTION MsgInfo( dDate, "Private Value" )
				MENUITEM 'Get Numeric Value'	ACTION MsgInfo( nStatic, "Static Value" )
				MENUITEM 'Get Logical Value'	ACTION MsgInfo( lValue, "Local Value" )
				MENUITEM 'Get Array Value'	ACTION MsgDebug( "Array Value:", aArray )
				MENUITEM 'Get Block Value'	ACTION MsgInfo( Eval(bBlock), "Local Value" )
			END POPUP

		END MENU

	END WINDOW 

	Form_1.Center()
	Form_1.Activate()

RETURN


FUNCTION DoTest( aArr )
	LOCAL lOK AS LOGICAL

	nStatic++

	ASSIGN dDate := Date()
	ASSIGN lOK := .T.
	ASSIGN cUserName := "UserName"
	ASSIGN aArr [2] := "Character"

RETURN lOK


FUNCTION DoTest2( aArr )
	LOCAL lOK AS LOGICAL

	ASSIGN dDate := Date() // Valid assignment
	ASSIGN lOK := .F.      // Valid assignment
	ASSIGN aArr := "Wrong" // Wrong assignment

RETURN lOK
