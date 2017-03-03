/*
* MiniGUI PutFile Demo
*   Pete D. 12/05/2016
*      added 7th optional parameter (logic). 
*		PutFile( aFilter, title, cIniFolder, lNoChangeCurDir, cDefFileName, @nFilterIndex, lPromptOverwrite ) 
*		If <lPromptOverwrite> set to .T. (default=.F.) and the filename already exists, user will be asked 
*     to overwrite it or not.
*/

#include <hmg.ch>
#include <Fileio.ch>

PROCEDURE Main()
	
   LOCAL nHandle
	
   IF ( nHandle := FCreate( "test.txt", FC_NORMAL ) ) == -1
      MsgStop( "Cannot create a file" + "Error: " + hb_NtoS( FError() ) )
      QUIT
   ELSE
      FWrite( nHandle, "This is a test textfile" )
      FClose( nHandle )
   ENDIF

	DEFINE WINDOW Win_1 ;
		AT 0,0 ;
		WIDTH 400 ;
		HEIGHT 400 ;
		TITLE 'Saving files...' ;
		MAIN 

		DEFINE MAIN MENU
			POPUP 'File'
				
			ITEM "Save file with overwrite prompt" ;
				  ACTION iif( !Empty( Save() ), hb_MemoWrit("test.txt", "This is a saved textfile"), NIL )
			ITEM "Choose file with overwrite prompt" ;
				  ACTION PutFile( { {'All files','*.*'} }, 'Save File As', hb_CWD(), , , , .T. )
			SEPARATOR
			ITEM "Exit" ;
				  ACTION {|| iif( hb_FileExists("test.txt"), hb_FileDelete("test.txt"), NIL ), ThisWindow.Release }
			END POPUP
		END MENU

	END WINDOW

	CENTER WINDOW Win_1

	ACTIVATE WINDOW Win_1

RETURN


STATIC FUNCTION Save()

RETURN PutFile( { {'text files','*.txt'} }, 'Save File As', hb_CWD(), ,"test.txt" , , .T. )
