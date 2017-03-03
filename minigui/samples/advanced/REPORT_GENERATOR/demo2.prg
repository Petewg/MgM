#include "minigui.ch"
#include "i_rptgen.ch"

Set Procedure To h_rptgen

Procedure Main

	Public _HMG_RPTDATA := Array( 165 )

	Set Century On
	Set Date Ansi

	DEFINE WINDOW Win_1 ;
		ROW 0 ;
		COL 0 ;
		WIDTH 400 ;
		HEIGHT 400 ;
		TITLE 'Hello World!' ;
		MAIN  

		DEFINE MAIN MENU
			POPUP 'File'
				ITEM 'Test'	ACTION Test()
			END POPUP
		END MENU


	END WINDOW

	Win_1.Center

	Win_1.Activate

Return

Procedure Test

	Use Test

	LOAD REPORT Test

	EXECUTE REPORT Test PREVIEW SELECTPRINTER

	Use

Return
