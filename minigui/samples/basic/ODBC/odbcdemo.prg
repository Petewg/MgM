/*
* MiniGUI ODBC Demo
* Based upon code from:
*	ODBCDEMO - ODBC Access Class Demonstration
*	Felipe G. Coury <fcoury@flexsys-ci.com>
* MiniGUI Version:
*	Roberto Lopez
*
* Updated for HMG Extended Edition by MiniGUI Team
*/

#include "minigui.ch"

#xcommand WITH <oObject> DO => Self := <oObject>
#xcommand ENDWITH           => Self := NIL

Memvar Self

PROCEDURE Main

	DEFINE WINDOW Form_1 ;
		AT 0,0 ;
		WIDTH 400 ;
		HEIGHT 400 ;
		TITLE 'MiniGUI ODBC Demo' ;
		MAIN  

		DEFINE MAIN MENU
			DEFINE POPUP 'File'
				MENUITEM 'Test' ACTION Test()
				SEPARATOR
				MENUITEM 'Exit'	ACTION Form_1.Release
			END POPUP
		END MENU

	END WINDOW

	ACTIVATE WINDOW Form_1

RETURN


Function TEST

   LOCAL cConStr := ;
      "DBQ=" + GetStartupFolder() + "\bd1.mdb;" + ;
      "Driver={Microsoft Access Driver (*.mdb)}"

   LOCAL dsFunctions := TODBC():New( cConStr )

   WITH dsFunctions DO

      ::SetSQL( "SELECT * FROM table1" )
      if ::Open()

         // Put data in fields array
         ::LoadData( ::nRecNo )

         MsgInfo( ::FieldByName( "field1" ):Value )

         ::Skip()

         MsgInfo ( ::FieldByName( "field1" ):Value )

         ::GoTo( 1 )

         MsgInfo ( ::FieldByName( "field1" ):Value )

         ::Prior()

         MsgInfo ( ::FieldByName( "field1" ):Value )

         ::First()

         MsgInfo ( ::FieldByName( "field1" ):Value )

         ::Last()

         MsgInfo ( ::FieldByName( "field1" ):Value )

         ::Close()

      endif

   ENDWITH

   dsFunctions:Destroy()

Return NIL
