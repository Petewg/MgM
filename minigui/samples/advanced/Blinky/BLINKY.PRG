/******************************************************
* blinky.prg
* Demuestra como se puede cambiar la velocidad
* de parpadeo del cursor, haciendo uso de las
* API'S de windows.
* autor: WALTER <walhug@yahoo.com.ar>
******************************************************/

ANNOUNCE RDDSYS

#include "minigui.ch"

#define PROGRAM 'Velocidad del CURSOR'
#define VERSION ' version 0.9'
#define COPYRIGHT  str(year(date())) + ' Walter'

static nOldRate

*****************************************************
PROCEDURE main()

	DEFINE WINDOW Form_1 ;
		AT 0,0 ;
		WIDTH 350 HEIGHT 250 ;
		TITLE 'Velocidad de parpadeo del cursor' ;
		MAIN NOSYSMENU NOSIZE ;
		ON INIT Load_Form()

		DRAW BOX ;
			IN WINDOW Form_1 ;
			AT 10, 10 ;
			TO 215, 210

		@ 025,132 LABEL label_a VALUE "Rápida"     WIDTH 50
		@ 085,132 LABEL label_b VALUE "Lenta"      WIDTH 50
		@ 152,132 LABEL label_c VALUE "Muy Lenta"  WIDTH 70
		@ 180,080 LABEL label_d VALUE "Nula"       WIDTH 50

		@ 080,030 TEXTBOX Text_1 VALUE "" WIDTH 30 NOTABSTOP

		@ 020,080 SLIDER Sld_1  ;
			RANGE 1, 15;
			VALUE 1 ;
			WIDTH 26  ;
			HEIGHT 155 ;
			VERTICAL ;
			ON CHANGE ( SetCaretBlinkTime(if( Form_1.Sld_1.value == 15, -1,Form_1.Sld_1.value * 100)), ;
				Form_1.Text_1.setfocus )

		@ 020,230 BUTTON Btn_1 CAPTION "&Cancelar" ACTION ;
			( SetCaretBlinkTime(nOldRate), Form_1.release )

		@ 050,230 BUTTON Btn_2 CAPTION "&Aplicar"  ACTION ;
			Form_1.release

		@ 080,230 BUTTON Btn_3 CAPTION "&Acerca de..."  ACTION ;
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
   Form_1.Sld_1.value := if( nOldRate < 0, 15, nOldRate / 100 )
RETURN

*****************************************************
STATIC Function MsgAbout()
RETURN( MsgInfo( padc( PROGRAM + VERSION, 38)  + CRLF + ;
	padc("Copyright " + Chr(169) + COPYRIGHT, 38) + CRLF + CRLF + ;
	hb_compiler() + CRLF + ;
	version() + CRLF + ;
	SubStr(MiniGuiVersion(), 1, 38) + CRLF + CRLF, ;
	"Acerca de ..." ) )

#include "H_V_CRS.PRG"
