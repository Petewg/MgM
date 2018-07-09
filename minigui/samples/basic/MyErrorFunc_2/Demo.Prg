/*
 * MINIGUI - Harbour Win32 GUI library Demo
*/

#include "minigui.ch"

#ifndef __XHARBOUR__
#xcommand TRY              => BEGIN SEQUENCE WITH {|__o| break(__o) }
#xcommand CATCH [<!oErr!>] => RECOVER [USING <oErr>] <-oErr->
#endif

Function Main

	DEFINE WINDOW Form1 ;
		AT 0,0 ;
		WIDTH 400 ;
		HEIGHT 200 ;
		TITLE "DefError Demo" ;
		MAIN NOMAXIMIZE NOSIZE

	@ 10,10 BUTTON Button1 CAPTION "Error with a recovery" ACTION DoError() WIDTH 180 HEIGHT 40

	END WINDOW

	CENTER WINDOW Form1

	ACTIVATE WINDOW Form1

Return Nil


Function DoError

	LOCAL oErrPrev := ErrorBlock()

	TRY

		Unused++

	CATCH oErr

		DefError( oErr )

	END

	ErrorBlock( oErrPrev )

Return Nil


#include "Errsys.prg"
