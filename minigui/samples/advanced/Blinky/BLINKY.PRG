/******************************************************
* blinky.prg
* Demuestra como se puede cambiar la velocidad
* de parpadeo del cursor, haciendo uso de las
* API'S de windows.
* autor: WALTER <walhug@yahoo.com.ar>
*****************************************************
revised 24/04/2015 Pete D.
*/

ANNOUNCE RDDSYS
// #define __CALLDLL__
#include "minigui.ch"

#define PROGRAM 'Velocidad del CURSOR'
#define VERSION ' version 0.9'
#define COPYRIGHT  str(year(date())) + ' Walter'

static nOldRate

*****************************************************
PROCEDURE main()

	DEFINE WINDOW Form_1 ;
		AT 0,0 ;
		WIDTH 350 HEIGHT 280 ;
		TITLE 'Cursor blink rate' ;
		MAIN NOSYSMENU NOSIZE TOPMOST ;
		ON INIT Load_Form()

		DRAW BOX ;
			IN WINDOW Form_1 ;
			AT 10, 10 ;
			TO 230, 200

		@ 025,120 LABEL label_a VALUE "Very fast" AUTOSIZE
		
		@ 060,120 LABEL label_b VALUE "Fast" AUTOSIZE
				
		@ 095,120 LABEL label_c VALUE "Average" AUTOSIZE
		
		@ 130,120 LABEL label_d VALUE "Slow" AUTOSIZE
		
		@ 165,120 LABEL label_e VALUE "Very Slow" AUTOSIZE
		
		@ 200,120 LABEL label_f VALUE "Fixed" AUTOSIZE

		@ 100,030 TEXTBOX Text_1 VALUE "" WIDTH 30 NOTABSTOP

		@ 020,080 SLIDER Sld_1  ;
			RANGE 1, 18;
			VALUE 1 ;
			WIDTH 26  ;
			HEIGHT 200 ;
			VERTICAL ;
			ON CHANGE ( SetCaretBlinkTime(if( Form_1.Sld_1.value == 18, -1, Form_1.Sld_1.value * 100)), ;
				Form_1.Text_1.setfocus )

		@ 020,230 BUTTON Btn_1 CAPTION "&Cancel" ACTION ;
			( SetCaretBlinkTime(nOldRate), Form_1.release )

		@ 050,230 BUTTON Btn_2 CAPTION "&Apply"  ACTION ;
			Form_1.release

		@ 080,230 BUTTON Btn_3 CAPTION "&About..."  ACTION ;
			( MsgAbout(), Form_1.Text_1.setfocus )

	END WINDOW

	Form_1.Text_1.caretpos := 1
	Form_1.Text_1.setfocus

	CENTER WINDOW form_1

	ACTIVATE WINDOW Form_1

RETURN

*****************************************************
STATIC PROCEDURE Load_Form()
	nOldRate := GetCaretBlinkTime()
   Form_1.Sld_1.value := if( nOldRate < 0, 18, nOldRate / 100 )
RETURN

*****************************************************
STATIC Function MsgAbout()

	RETURN(  MsgInfo( padc( PROGRAM + VERSION, 38)  + CRLF + ;
				padc("Copyright " + Chr(169) + COPYRIGHT, 38) + CRLF + CRLF + ;
				hb_compiler() + CRLF + ;
				version() + CRLF + ;
				SubStr(MiniGuiVersion(), 1, 38) + CRLF + CRLF, ;
				"Acerca de ..." ) )


	
// #include "H_V_CRS.PRG"
// DECLARE GetCaretBlinkTime() IN USER32.DLL
// DECLARE SetCaretBlinkTime( wMSeconds ) IN USER32.DLL
STATIC FUNC GetCaretBlinkTime()
   RETURN CallDll32( "GetCaretBlinkTime", "USER32.DLL" )
STATIC FUNC SetCaretBlinkTime( nMillisecs )
   RETURN CallDll32( "SetCaretBlinkTime", "USER32.DLL", nMillisecs )
   

