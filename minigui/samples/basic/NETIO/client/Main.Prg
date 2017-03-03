/*
 *	MiniGUI Basic NetIO Client Sample.
 *	Roberto Lopez <mail.box.hmg@gmail.com>
*/

#include <hmg.ch>

Function Main

MEMVAR aRecordSet
MEMVAR cMainTitle

PUBLIC aRecordSet
PUBLIC cMainTitle

        Load Window Main

	IF ValType( cMainTitle ) != "C"
		cMainTitle := Main.Title
	ENDIF

	Main.Query_Server.Enabled	:= .F.
	Main.Disconnect.Enabled		:= .F.
	Main.Query_String.Enabled	:= .F.

        Main.Center

        Main.Activate

Return Nil
