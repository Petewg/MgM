#include "minigui.ch"

Procedure InOtherPrg()

	MsgInfo( Application.Title, "Original Title Of " + Application.FormName )

	Application.Title := 'Title Changed In Other Prg'

Return


EXIT PROCEDURE _OtherProcedure

WaitWindow('OTHER EXIT PROCEDURE')

RETURN


#ifndef __XHARBOUR__

STATIC PROCEDURE TEST

RETURN

#endif
