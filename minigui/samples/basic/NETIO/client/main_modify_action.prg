#include "hmg.ch"

declare window Main

Function main_modify_action
LOCAL I , nRecNo
LOCAL cFirst , cLast , cStreet , cCity , cState , cZip , dHireDate , lMarried , nAge , nSalary
LOCAL Title , aLabels , aInitValues , aFormats , aValues

IF Main.Query_Server.Enabled == .T.

	I := Main.Grid_1.Value

	IF I == 0
		MsgStop('You must select a row!')
		Return Nil
	ENDIF

	nRecNo		:= Val( Main.Grid_1.Cell(I,1) )

	cFirst		:= Main.Grid_1.Cell(I,3)
	cLast		:= Main.Grid_1.Cell(I,2)
	cStreet 	:= Main.Grid_1.Cell(I,4)
	cCity		:= Main.Grid_1.Cell(I,5)
	cState		:= Main.Grid_1.Cell(I,6)
	cZip		:= Main.Grid_1.Cell(I,7) 
	dHireDate	:= CTOD( Main.Grid_1.Cell(I,8) )
	lMarried	:= iif( Main.Grid_1.Cell(I,9)='.T.', .T., .F. )
	nAge		:= Val( Main.Grid_1.Cell(I,10) )
	nSalary		:= Val( Main.Grid_1.Cell(I,11) )

	Title 		:= 'Modify Record'

	aLabels 	:= { 'First:'	, 'Last:'	,'Street:'		,'City:'	,'State:'	,'Zip:' , 'Hire Date'	, 'Married'	, 'Age'	, 'Salary'	}
	aInitValues 	:= { cFirst	, cLast		, cStreet		, cCity 	, cState	, cZip 	, dHireDate	, lMarried	, nAge	, nSalary	}
	aFormats 	:= { 32		, 32 		, 32			, 32 		, 32		, 32 	, NIL		, NIL		, '99'	, '999999'	}

	aValues 	:= InputWindow ( Title , aLabels , aInitValues , aFormats )

	If aValues [1] == Nil

		MsgInfo('Canceled', 'New Record')

	Else

		netio_funcexec( "query_004" , nRecNo , aValues )

		main_query_server_action()

		MsgInfo('Operation Completed!')

	EndIf

ENDIF

Return Nil
