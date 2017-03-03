/*
 * Vista Command Link Component Demo
 * (c) 2016 Grigory Filatov
 */

#include "minigui.ch"

Procedure Main

	IF ! IsWinNT() .OR. ! ISVISTAORLATER()
		MsgStop( 'This Program Runs In WinVista Or Later!', 'Stop' )
		Return
	ENDIF

	SET FONT TO _GetSysFont(), 12

	DEFINE WINDOW Form_1 ;
		AT 0,0 ;
		WIDTH 285 ;
		HEIGHT 425 ;
		TITLE 'Command Link Component Demo' ;
		MAIN ;
		ON RELEASE ReleaseCLbuttonRes()

		This.MinButton := .F.
		This.MaxButton := .F.

		DEFINE FRAME Frame_1
			ROW    10
			COL    15
			WIDTH  240
			HEIGHT 152
			CAPTION "Do you wish to Save?"
		END FRAME

		@ 38 , 30 CLBUTTON clb_1 ;
			WIDTH 210 ;
			HEIGHT 52 ;
			CAPTION 'Save' ;
			NOTETEXT "Save document to file" ;
			PICTURE 'save.bmp' ;
			ACTION MsgInfo( 'Selected: ' + This.Caption ) ;
			DEFAULT

		@ 98 , 30 CLBUTTON clb_2 ;
			WIDTH 210 ;
			HEIGHT 52 ;
			CAPTION 'Discard' ;
			NOTETEXT "Leave without saving" ;
			PICTURE 'close.bmp' ;
			ACTION MsgInfo( 'Selected: ' + This.Caption )

		DEFINE FRAME Frame_2
			ROW    175
			COL    15
			WIDTH  240
			HEIGHT 200
			CAPTION "Other Examples"
		END FRAME

		DEFINE CLBUTTON clb_3
			ROW    203
			COL    30
			WIDTH  210
			HEIGHT 72
			CAPTION Space(32) + 'Different Alignment'
			NOTETEXT "Align any way vertically."
			PICTURE 'save.bmp'
			ACTION _dummy()
		END CLBUTTON

		DEFINE CLBUTTON clb_4
			ROW    283
			COL    30
			WIDTH  210
			HEIGHT 80
			CAPTION 'Text Wrap'
			NOTETEXT "Watch the description text wrap by itself when it's too long."
			PICTURE 'close.bmp'
			ACTION _dummy()
		END CLBUTTON

		ON KEY ESCAPE ACTION ThisWindow.Release()

	END WINDOW

	CENTER WINDOW Form_1

	ACTIVATE WINDOW Form_1

Return


Procedure ReleaseCLbuttonRes

	Form_1.clb_1.Release
	Form_1.clb_2.Release
	Form_1.clb_3.Release
	Form_1.clb_4.Release

Return
