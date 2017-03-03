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
Local lExit, i

	lExit := .F.

	_HMG_CHILDWAITWINDOW.MESSAGE.VALUE := cMessage

	_HMG_CHILDWAITWINDOW.SHOW

	InkeyGUI(0)

	_HMG_CHILDWAITWINDOW.HIDE

Return Nil

*------------------------------------------------------------------------------*
Function HideWaitWindow()
*------------------------------------------------------------------------------*

	_HMG_CHILDWAITWINDOW.HIDE

Return Nil

*------------------------------------------------------------------------------*
Function WaitWindow ( cMessage , lNoWait )
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
