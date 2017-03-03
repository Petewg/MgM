/*
 * MINIGUI - Harbour Win32 GUI library Demo
 *
 * Copyright 2002-05 Roberto Lopez <harbourminigui@gmail.com>
 * http://harbourminigui.googlepages.com/
 * 
 * New function added HMG 1.0 Experimental Build 6
 * Jacek Kubica <kubica@wssk.wroc.pl>
 *
 * SET LOGERROR ON/OFF Enable (default) or disable logging errors to errorlog file
 * IsErrorLogActive() - return logical value regarding to LOGERROR status
 *
 * SET ERRORLOG TO <cFile> - set new errorlog file (default {APPDIR>}\ErrorLog.htm)
 * SET ERRORLOG TO         - reset errorlog file to default value  
 */

#include "minigui.ch"

Function Main()

	SET DATE ITALIAN
	SET CENTURY ON

	DEFINE WINDOW Form_1 ;
		AT 0,0 ;
		WIDTH 300 HEIGHT 150 ;
		TITLE 'Harbour MiniGUI ErrorLog Demo' ;
		MAIN 
	
        	DEFINE MAIN MENU 
			POPUP '&ErrorLog Function'
				ITEM 'Get ErrorLog File Name '	 ACTION  MsgBox(_GetErrorlogFile())
				ITEM 'Set ErrorLog File Name'	 ACTION  SetLogFile(Putfile ( { {'*.htm Files','*.htm'} , {'*.html Files','*.html'} } , 'Select errorlog file' , GetStartUpFolder(), .t., "MyErrorLog"))
                                ITEM 'Reset ErrorLog File Name'	 ACTION  SetLogFile()
		    	SEPARATOR	
				ITEM 'Enable ErrorLogging '	 ACTION  LogEnable(.t.)
				ITEM 'Disable ErrorLogging'	 ACTION  LogEnable(.f.)
                        SEPARATOR
                                ITEM 'ErrorLogging Status '   ACTION MsgBox("Errorlogging is now "+IIF(IsErrorLogActive(), "active", "disabled"))
			END POPUP
                       	POPUP '&Fake Error'
				ITEM 'Do some error'		ACTION SomeError()
                                SEPARATOR
                                ITEM 'Set bad errorlog filename '  ACTION SetBadFile()
			END POPUP

			POPUP '&Help'
				ITEM '&About'		ACTION MsgBox( MiniguiVersion() , "ErrorLog functions DEMO" )
			END POPUP
		END MENU


	END WINDOW
	Form_1.Center
	Form_1.Activate

Return Nil

*-------------------------------
Function LogEnable(lValue)
*-------------------------------
If lValue==.t.
	SET LOGERROR ON
else
	SET LOGERROR OFF
endif
Return NIL

*-------------------------------
Function SetLogFile(cFile)
*-------------------------------
If !EMPTY(cFile)
	SET ERRORLOG TO cFile
else
	SET ERRORLOG TO 
endif
Return NIL

*-------------------------------
Function SetBadFile()
*-------------------------------
	SET ERRORLOG TO "Z:\File.htm"  // Wrong disk
Return NIL

*-------------------------------
Procedure SomeError()
*-------------------------------
Local Var1 As Numeric
Local Var2 As String

	ASSIGN Var2 := Var1 + 1  // Assignment error

Return
