#include <hmg.ch>

PROCEDURE MAIN()

	SET DATE GERMAN
	SET CENTURY ON

	DEFINE WINDOW frmGUIPrnt ;
		AT 0,0 ;
		WIDTH 400;
		HEIGHT 300 ;
		TITLE 'MiniPrint Tests' ;
		MAIN 

		ON KEY ESCAPE OF frmGUIPrnt ACTION ThisWindow.Release

		DEFINE MAIN MENU 
			DEFINE POPUP 'File'
				MENUITEM 'Step #1' ACTION PrintTest1()
				MENUITEM 'Step #2' ACTION PrintTest2()
				MENUITEM 'Step #3' ACTION PrintTest3()
				MENUITEM 'Step #4' ACTION PrintTest4()
				MENUITEM 'Step #5' ACTION PrintTest5()
				MENUITEM 'Step #6' ACTION PrintTest6()
				MENUITEM 'Step #7' ACTION PrintTest7()
				MENUITEM 'Step #8' ACTION PrintTest8()
				MENUITEM 'Step #9' ACTION PrintTest9()
				MENUITEM 'Step #10' ACTION PrintTest10()
			END POPUP
		END MENU

	END WINDOW

	frmGUIPrnt.Center
	frmGUIPrnt.Activate

RETURN  // Main()

*-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.