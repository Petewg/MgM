/*
 * MINIGUI - Harbour Win32 GUI library Demo
 *
 * Copyright 2002-06 Roberto Lopez <harbourminigui@gmail.com>
 * http://harbourminigui.googlepages.com/
 *
 * Copyright 2004-07 Grigory Filatov <gfilatov@inbox.ru>
*/

#include "minigui.ch"
#include "shell32.ch"

#define MsgInfo( c ) MsgInfo( c, "Information", , .f. )
#define MsgAlert( c ) MsgExclamation( c, "Attention", , .f. )

Procedure Main( nOper, cFile, cCopy )
	Local aFile:={}, aCopy:={}
	Local cPath := GetStartupFolder() + "\"

	DEFAULT cFile := "compile.bat"
	DEFAULT cCopy := cPath + "Test Directory\compile.bat"
	DEFAULT nOper := FO_COPY

	nOper := IF( Valtype(nOper) == "C", Val(nOper), nOper )

	aadd(aFile, cFile)
	aadd(aFile, "demo.prg")
	aadd(aCopy, cPath + "Test Directory")

	DEFINE WINDOW Form_Main ;
		AT 0,0 ;
		WIDTH 640 HEIGHT 480 ;
		TITLE 'Shell Files Operation sample by Grigory Filatov' ;
		MAIN ;
		NOSIZE NOMAXIMIZE

		define button x
		      row 10
		      col 10
		      caption "Test 1"
                      default .t.
		      action test( aFile, aCopy, nOper, cCopy )
		end button

		define button x2
		      row 40
		      col 10
		      caption "Test 2"
                      default .t.
		      action test2( aFile, aCopy, nOper )
		end button

		define button y
		      row 70
		      col 10
		      caption "Exit"
		      action ThisWindow.Release
		end button

	END WINDOW

	CENTER WINDOW Form_Main

	ACTIVATE WINDOW Form_Main

return

Procedure test( aFile, aCopy, nOper, cCopy )

	IF ( ShellFiles( Application.Handle, aFile, aCopy, nOper, FOF_NOCONFIRMMKDIR ) == 0 )

		MsgInfo("The Test Directory is maked and the files are copied.")

		IF ShFileDelete( , cCopy, .T. )

			MsgInfo( "The file " + aFile[1] + " is deleted from the Test Directory." )

		ELSE

			MsgAlert( "Error of deleting!" )

		ENDIF

	ENDIF

return

Procedure test2( aFile, aCopy, nOper )

	IF ( ShellFiles( Application.Handle, aFile, aCopy, nOper, FOF_NOCONFIRMMKDIR ) == 0 )

		MsgInfo("The Test Directory is maked and the files are copied.")

		IF ShFolderDelete( , aCopy[1], .F. )

			IF lIsDir( aCopy[1] )

				MsgInfo( "The folder " + aCopy[1] + " is NOT erased." )

			ELSE

				MsgInfo( "The folder " + aCopy[1] + " is erased." )

			ENDIF

		ELSE

			MsgAlert( "Error of deleting!" )

		ENDIF

	ENDIF

return

*--------------------------------------------------------*
STATIC FUNCTION lIsDir( cDir )
*--------------------------------------------------------*
LOCAL lExist := .T.

   IF DirChange( cDir ) > 0
	lExist := .F.
   ELSE
	DirChange( GetStartupFolder() )
   ENDIF

RETURN lExist
