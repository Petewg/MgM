#include "hmg.ch"

declare window Main

Function main_delete_action
LOCAL I , nRecNo

IF Main.Query_Server.Enabled == .T.

	IF .NOT. MSGYESNO('Are You Sure?')
		Return Nil
	ENDIF

	I := Main.Grid_1.Value

	IF I == 0
		MsgStop('You must select a row!')
		Return Nil
	ENDIF

	nRecNo := Val( Main.Grid_1.Cell(I,1) )

	IF netio_funcexec( "query_002" , nRecNo )
		MsgInfo('Record Deleted Successfully!')
		Main.Query_String.Value := ''
		main_query_server_action()
	ELSE
		MsgStop('Error Deleting Record!')
	ENDIF

ENDIF

Return Nil
