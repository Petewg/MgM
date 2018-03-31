#include "minigui.ch"
#include "miniprint.ch"

*------------------------------------------------------------------------------*
Function Main()
*------------------------------------------------------------------------------*

//	AVAILABLE LIBRARY INTERFACE LANGUAGES

//	SET LANGUAGE TO ENGLISH (DEFAULT)
//	SET LANGUAGE TO SPANISH
//	SET LANGUAGE TO PORTUGUESE
//	SET LANGUAGE TO ITALIAN
//	SET LANGUAGE TO GERMAN
//	SET LANGUAGE TO FRENCH

	DEFINE WINDOW Win_1 ;
		AT 0,0 ;
		WIDTH 400 ;
		HEIGHT 400 ;
		TITLE 'MiniPrint Library Test' ;
		MAIN 

		DEFINE MAIN MENU 
			DEFINE POPUP 'File'
				MENUITEM 'Default Printer' ACTION PrintTest1()
				MENUITEM 'User Selected Printer' ACTION PrintTest2()
				MENUITEM 'User Selected Printer And Settings' ACTION PrintTest3()
				MENUITEM 'User Selected Printer And Settings (Preview)' ACTION PrintTest4()
			END POPUP
		END MENU

	END WINDOW

	MAXIMIZE WINDOW Win_1

	ACTIVATE WINDOW Win_1

Return Nil
*------------------------------------------------------------------------------*
Procedure PrintTest1()
*------------------------------------------------------------------------------*

	SELECT PRINTER DEFAULT ;
		ORIENTATION	PRINTER_ORIENT_PORTRAIT ;
		PAPERSIZE	PRINTER_PAPER_LETTER ;
		QUALITY		PRINTER_RES_MEDIUM 

	PrintDoc()

	MsgInfo('Print Finished')

Return
*------------------------------------------------------------------------------*
Procedure PrintTest2()
*------------------------------------------------------------------------------*
Local cPrinter

	cPrinter := GetPrinter()

	If Empty (cPrinter)
		Return
	EndIf

	SELECT PRINTER cPrinter ;
		ORIENTATION	PRINTER_ORIENT_PORTRAIT ;
		PAPERSIZE	PRINTER_PAPER_LETTER ;
		QUALITY		PRINTER_RES_MEDIUM

	PrintDoc()

	MsgInfo('Print Finished')

Return
*------------------------------------------------------------------------------*
Procedure PrintTest3()
*------------------------------------------------------------------------------*
Local lSuccess

	SELECT PRINTER DIALOG TO lSuccess

	If lSuccess == .T.
		PrintDoc()
		MsgInfo('Print Finished')
	EndIf

Return
*------------------------------------------------------------------------------*
Procedure PrintTest4()
*------------------------------------------------------------------------------*
Local lSuccess

	SELECT PRINTER DIALOG TO lSuccess PREVIEW

	If lSuccess == .T.
		PrintDoc()
		MsgInfo('Print Finished')
	EndIf

Return
*------------------------------------------------------------------------------*
Procedure PrintDoc
*------------------------------------------------------------------------------*

	// Measure Units Are Millimeters

	START PRINTDOC

			START PRINTPAGE

				@ 20,20 PRINT "Filled Rectangle Sample:" ;
					FONT "Arial" ;
					SIZE 20 

				@ 30,20 PRINT LINE ;
					TO 30,190 ;
					COLOR {255,255,0} ;
					DOTTED

				@ 40,20 PRINT RECTANGLE ;
					TO 50,190 ;
					PENWIDTH 0.1;
					COLOR {255,255,0}

				@ 60,20 PRINT RECTANGLE ;
					TO 100,190 ;
					COLOR {255,255,0};
					FILLED NOBORDER
					
				@ 110,20 PRINT RECTANGLE ;
					TO 150,190 ;
					PENWIDTH 0.1;
					COLOR {255,255,0};
					ROUNDED
					
				@ 160,20 PRINT RECTANGLE ;
					TO 200,190 ;
					PENWIDTH 0.1;
					COLOR {255,255,0};
					FILLED;
					ROUNDED
										
				@ 170,40 PRINT "Filled Rectangle Sample:" ;
					FONT "Arial" ;
					SIZE 44 COLOR GRAY ANGLE 45

			END PRINTPAGE

			START PRINTPAGE

				@ 20,20 PRINT "Filled Rectangle Sample:" ;
					FONT "Arial" ;
					SIZE 20 

				@ 30,20 PRINT LINE ;
					TO 30,190 ;
					DOTTED

				@ 40,20 PRINT RECTANGLE ;
					TO 50,190 ;
					PENWIDTH 0.1
					
				@ 60,20 PRINT RECTANGLE ;
					TO 100,190 ;
					PENWIDTH 0.1;
					FILLED
					
				@ 110,20 PRINT RECTANGLE ;
					TO 150,190 ;
					PENWIDTH 0.1;
					ROUNDED
					
				@ 160,20 PRINT RECTANGLE ;
					TO 200,190 ;
					PENWIDTH 0.1;
					FILLED;
					ROUNDED
										
			END PRINTPAGE
			
	END PRINTDOC

Return
