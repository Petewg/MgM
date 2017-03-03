#include "hmg.ch"

declare window Main

MEMVAR cMainTitle

Function main_connect_action

LOCAL cNetServer	:= '127.0.0.1'	// Server Address
LOCAL nNetPort		:= 50000	// Server Port
LOCAL cNetPass		:= 'secret'	// Server Password
LOCAL lConnect

	lConnect := netio_connect( cNetServer , nNetPort ,, cNetPass, 9 )
	IF .Not. lConnect
		MSGSTOP("Can't Connect To Server!")
		Return Nil
	ELSE
		Main.Query_Server.Enabled := .T.
		Main.Disconnect.Enabled	  := .T.
		Main.Connect.Enabled	  := .F.
		Main.Query_String.Enabled := .T.
		SETPROPERTY('Main', 'Title', cMainTitle + ' - Connected!')
		Main.Query_String.SetFocus
	ENDIF

Return Nil
