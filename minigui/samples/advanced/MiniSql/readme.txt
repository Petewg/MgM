
MiniSql (a Simple MySql Access Layer) For Harbour MiniGUI
---------------------------------------------------------

Copyright 2002-2005 Roberto Lopez <roblez@ciudad.com.ar>
http://harbourminigui.googlepages.com/

This software is provided "as-is," without any express or implied warranty.
In no event shall the author be held liable for any damages arising from the
use of this software.


I've decided to create a simple and easy way to access mysql server from
my applications. The result is MiniSql.

MiniSql is a very simple MySql access layer. It relies in mysql.lib (Harbour
contribution library) bundled with MiniGUI.

MiniSql is experimental code, so It could be buggy / unstable and is not 
finished yet.

MiniSql is available for download at http://harbourminigui.googlepages.com/

Available Sql commands:

	SELECT
	UPDATE
	INSERT
	DELETE
	LOCK TABLES
	UNLOCK TABLES

Commands are converted to strings prior to send them to the server, so, you
must put in a non-local variable and substitute using macro operator.

When SELECT command is issued, a CHARACTER array called "SqlResult" is filled 
with query results. ALL COLUMNS WILL BE AVAILABLE AS CHARACTER.

When DELETE, INSERT or UPDATE commands are issued, a variable called 
"SqlAffectedRows" is filled with a numeric value indicating the number of rows
affected by those commands.

Samples:

	* Connect

      	nHandle := SqlConnect( cServer , cUser , cPass )

	if Empty(nHandle)
		MsgStop("Error","")
		Return 
	EndIf

	* Select DataBAse

	if SqlSelectD( nHandle , cDataBAse ) != 0
		MsgStop("Error","")
		Return .F.
	Endif

	cVar1 = "Robert"
	cVar2 = "Paul"

	LOCK TABLES TEST WRITE 

		SELECT * FROM TEST WHERE NAME = "&cVar1" 

		If Len (SqlResult) == 0
			MsgStop ("No Results!","")
			UNLOCK TABLES
			Return
		EndIf

		INSERT INTO TEST SET NAME = "&cVar2" 

	UNLOCK TABLES


Enjoy!

-- 
 Roberto  Lopez <roblez@ciudad.com.ar>
