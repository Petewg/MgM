#include "hmg.ch"

declare window Main

Function main_new_action
LOCAL Title , aLabels , aInitValues , aFormats , aValues

IF Main.Query_Server.Enabled == .T.

	Title 		:= 'New Record'

	aLabels 	:= { 'First:'	, 'Last:'	,'Street:'		,'City:'	,'State:'	,'Zip:' , 'Hire Date'	, 'Married'	, 'Age'	, 'Salary'	}
	aInitValues 	:= { ''		, '' 		, ''			, ''	 	, '' 		,'' 	, DATE()	, .F.		, 0	, 0		}
	aFormats 	:= { 32		, 32 		, 32			, 32 		, 32		, 32 	, NIL		, NIL		, '99'	, '999999'	}

	aValues 	:= InputWindow ( Title , aLabels , aInitValues , aFormats )

	If aValues [1] == Nil

		MsgInfo( 'Canceled', 'New Record' )

	Else

		netio_funcexec( "query_003" , aValues )

		MsgInfo( 'Operation Completed!' )

		Main.Query_String.Value := aValues[2]

		main_query_server_action()

	EndIf

ENDIF

Return Nil
