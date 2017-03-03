*------------------------------------------------------------------------------*
Function InitWaitWindow()
*------------------------------------------------------------------------------*

	DEFINE WINDOW _HMG_CHILDWAITWINDOW ;
		AT	0,0	;
		WIDTH	500	;
		HEIGHT	40	;
		TITLE	''	;	
		CHILD		;
		NOSHOW		;
		NOSYSMENU	;
		NOCAPTION

		DEFINE LABEL Message
			ROW		5
			COL		10
			WIDTH		480
			HEIGHT		25
			VALUE		''
			CENTERALIGN	.T.
		END LABEL			

	END WINDOW

	_HMG_CHILDWAITWINDOW.CENTER

Return Nil

*------------------------------------------------------------------------------*
Function ShowWaitWindow( cMessage )
*------------------------------------------------------------------------------*

	_HMG_CHILDWAITWINDOW.MESSAGE.VALUE := cMessage

	_HMG_CHILDWAITWINDOW.SHOW

Return Nil

*------------------------------------------------------------------------------*
Function ShowWaitWindowModal( cMessage )
*------------------------------------------------------------------------------*
Local lExit
Local i

	lExit := .F.

	_HMG_CHILDWAITWINDOW.MESSAGE.VALUE := cMessage

	_HMG_CHILDWAITWINDOW.SHOW

	For i := 1 To 255
		GetAsyncKeyState(i)
	Next i

	Do While .Not. lExit
		For i := 1 To 255
			If GetAsyncKeyState(i) <> 0
				lExit := .T.
				Exit				
			EndIf
		Next i
	EndDo

	_HMG_CHILDWAITWINDOW.HIDE

Return Nil

*------------------------------------------------------------------------------*
Function HideWaitWindow()
*------------------------------------------------------------------------------*

	_HMG_CHILDWAITWINDOW.HIDE

Return Nil

*------------------------------------------------------------------------------*
Function WaitWindow2 ( cMessage , lNoWait )
*------------------------------------------------------------------------------*

	if pcount() > 0

		If ValType ( lNoWait ) == 'L'

			If	lNoWait == .T.

				ShowWaitWindow( cMessage )

			Else

				ShowWaitWindowModal( cMessage )

			EndIf

		Else

			ShowWaitWindowModal( cMessage )

		EndIf

	Else

		HideWaitWindow()

	EndIf

Return Nil

*------------------------------------------------------------------------------*
* Low Level C Routines
*------------------------------------------------------------------------------*

#pragma BEGINDUMP

#include <windows.h>
#include "hbapi.h"

HB_FUNC ( GETASYNCKEYSTATE )
{
	hb_retni(GetAsyncKeyState(hb_parni(1)));
}

#pragma ENDDUMP
