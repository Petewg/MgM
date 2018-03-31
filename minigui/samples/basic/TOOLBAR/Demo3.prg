/*
 * MINIGUI - Harbour Win32 GUI library Demo
 *
 * Image-based ToolBar Demo
 * (c) 2011 Grigory Filatov <gfilatov@inbox.ru>
*/

#include "minigui.ch"

Static lHover := .F.

Function Main

	DEFINE WINDOW Form_1 ;
		AT 0,0 ;
		WIDTH 640 HEIGHT 480 ;
		TITLE 'MiniGUI Image ToolBar Demo' ;
		ICON 'DEMO.ICO' ;
		MAIN ;
		FONT 'Arial' SIZE 10

		DEFINE STATUSBAR
			STATUSITEM 'HMG Power Ready!' 
		END STATUSBAR

		DEFINE MAIN MENU 
			POPUP '&File'
				ITEM '&Disable ToolBar Button'	ACTION Form_1.Button_1.Enabled := .F. 
				ITEM '&Enable ToolBar Button'	ACTION Form_1.Button_1.Enabled := .T. 
				SEPARATOR
				ITEM 'Get ToolBar Button Caption' ACTION MsgInfo( Form_1.Caption_1.Value) 
				ITEM 'Set ToolBar Button Caption' ACTION SetProperty ( 'Form_1' , 'Caption_1' , 'Value' , 'New Caption' ) 
				SEPARATOR
				ITEM 'E&xit'			ACTION Form_1.Release
			END POPUP
			POPUP '&Help'
				ITEM '&About'		ACTION MsgInfo ("MiniGUI Image ToolBar demo") 
			END POPUP
		END MENU

		DefineImageToolBar()

		ON KEY ALT+M ACTION Modal_Click()
		ON KEY ALT+B ACTION MsgInfo('Click! 2')
		ON KEY ALT+3 ACTION MsgInfo('Click! 3')

	END WINDOW

	CENTER WINDOW Form_1

	ACTIVATE WINDOW Form_1

Return Nil


Function DefineImageToolBar()
	Local aCaptions := { "&More ToolB...", ;
                             "&Button 2", ;
                             "Button &3" }
	Local i, cImage, cLabel, nPos := 0

	For i := 1 To Len(aCaptions)

		cImage := "Button_" + Str(i, 1)
		@ 5, nPos + 10 IMAGE &cImage ;
			PICTURE "button" + Str(i, 1) + ".bmp" ;
			WIDTH 61 ;
			HEIGHT 61 ;
			TRANSPARENT STRETCH ;
			ACTION MsgInfo( 'Click! '+ Right(this.name, 1) ) ;
			ON MOUSEHOVER OnImageHover( Val(Right(this.name, 1)), .t. ) ;
			ON MOUSELEAVE OnImageLeave( Val(Right(this.name, 1)) )

		cLabel := "Caption_" + Str(i, 1)
		@ 79, nPos + 1 LABEL &cLabel VALUE aCaptions[i] ;
			WIDTH 85 ;
			HEIGHT 16 ;
			TRANSPARENT CENTERALIGN ;
			ACTION MsgInfo( 'Click! '+ Right(this.name, 1) ) ;
			ON MOUSEHOVER OnImageHover( Val(Right(this.name, 1)), .f. ) ;
			ON MOUSELEAVE OnImageLeave( Val(Right(this.name, 1)) )

		nPos += 86

	Next

	Form_1.Button_1.Action := { || Modal_Click() }
	Form_1.Caption_1.Action := { || Modal_Click() }

	CreateLines()

Return Nil


Function OnImageHover( nButton, lFlag )
	Local cImage

	if !lHover
		cImage := "Button_" + Str(nButton, 1)
		SetProperty( 'Form_1' , cImage , 'Width' , 67 )
		SetProperty( 'Form_1' , cImage , 'Height' , 67 )
		SetProperty( 'Form_1' , cImage , 'Picture' , "button" + Str(nButton, 1) + ".bmp" )
		lHover := .T.
	endif
	if lFlag
		createbtnborder("Form_1",this.row-3,this.col-9,this.row+this.height+25,this.col+this.width+9)
	else
		createbtnborder("Form_1",this.row-77,this.col,this.row+this.height+2,this.col+this.width)
	endif

Return Nil


Function OnImageLeave( nButton )
	Local cImage

	if lHover
		cImage := "Button_" + Str(nButton, 1)
		SetProperty( 'Form_1' , cImage , 'Width' , 61 )
		SetProperty( 'Form_1' , cImage , 'Height' , 61 )
		SetProperty( 'Form_1' , cImage , 'Picture' , "button" + Str(nButton, 1) + ".bmp" )
		lHover := .F.
	endif

	ERASE WINDOW Form_1
	CreateLines()

Return Nil


Function CreateBtnBorder( cWin,t,l,b,r )

	CursorHand()

	DRAW PANEL		;
		IN WINDOW &cWin	;
		AT t,l		;
		TO b,r

Return Nil


Function CreateLines()

	// Above of image toolbar
	DRAW LINE IN WINDOW Form_1 ;
		AT 0,0 TO 0,Form_1.Width ;
		PENCOLOR iif(IsWinXPorLater(), {172, 168, 153}, {128, 128, 128})

	DRAW LINE IN WINDOW Form_1 ;
		AT 1,0 TO 1,Form_1.Width ;
		PENCOLOR WHITE

	// Below of image toolbar
	DRAW LINE IN WINDOW Form_1 ;
		AT 102,0 TO 102,Form_1.Width ;
		PENCOLOR WHITE

Return Nil


Procedure Modal_Click

	DEFINE WINDOW Form_2 ;
		AT 0,0 ;
		WIDTH 400 HEIGHT 300 ;
		TITLE 'ToolBar Test' ;
		MODAL NOSIZE 

		DefineBottomToolBar()

		ON KEY ALT+U ACTION MsgInfo('UnDo Click!')
		ON KEY ALT+S ACTION MsgInfo('Save Click!')
		ON KEY ALT+C ACTION Form_2.Release

	END WINDOW

	Form_2.Center

	Form_2.Activate

Return


Function DefineBottomToolBar()
	Local aCaptions := { "&Undo", ;
                             "&Save", ;
                             "&Close" }
	Local i, cImage, cLabel, nBottom := Form_2.Height - GetTitleHeight() - 46, nPos := 0

	For i := 1 To Len(aCaptions)

		cImage := "Button_" + Str(i, 1)
		@ nBottom + 5, nPos + 4 IMAGE &cImage ;
			PICTURE "button" + Str(i + 3, 1) + ".bmp" ;
			WIDTH iif(i=1, 22, 20) ;
			HEIGHT iif(i=1, 22, 20) ;
			TRANSPARENT STRETCH ;
			ON MOUSEHOVER OnImageHover2( Val(Right(this.name, 1)), .t. ) ;
			ON MOUSELEAVE OnImageLeave2( Val(Right(this.name, 1)) )

		cLabel := "Caption_" + Str(i, 1)
		@ nBottom + 10, nPos + 36 LABEL &cLabel VALUE aCaptions[i] ;
			WIDTH 62 ;
			HEIGHT 16 ;
			TRANSPARENT ;
			ON MOUSEHOVER OnImageHover2( Val(Right(this.name, 1)), .f. ) ;
			ON MOUSELEAVE OnImageLeave2( Val(Right(this.name, 1)) )

		nPos += 100

	Next

	Form_2.Button_1.Action := { || MsgInfo('UnDo Click!') }
	Form_2.Caption_1.Action := { || MsgInfo('UnDo Click!') }

	Form_2.Button_2.Action := { || MsgInfo('Save Click!') }
	Form_2.Caption_2.Action := { || MsgInfo('Save Click!') }

	Form_2.Button_3.Action := { || DoMethod('Form_2', 'Release') }
	Form_2.Caption_3.Action := { || DoMethod('Form_2', 'Release') }

	CreateBottomLine()

Return Nil


Function OnImageHover2( nButton, lFlag )
	Local cImage

	if !lHover
		cImage := "Button_" + Str(nButton, 1)
		SetProperty( 'Form_2' , cImage , 'Width' , iif(nButton=1, 27, 25) )
		SetProperty( 'Form_2' , cImage , 'Height' , iif(nButton=1, 27, 25) )
		SetProperty( 'Form_2' , cImage , 'Picture' , "button" + Str(nButton + 3, 1) + ".bmp" )
		lHover := .T.
	endif
	if lFlag
		createbtnborder("Form_2",this.row-5,this.col-4,this.row+this.height+iif(nButton=1, 3, 5),this.col+this.width+iif(nButton=1, 67, 69))
	else
		createbtnborder("Form_2",this.row-10,this.col-36,this.row+this.height+9,this.col+this.width)
	endif

Return Nil


Function OnImageLeave2( nButton )
	Local cImage

	if lHover
		cImage := "Button_" + Str(nButton, 1)
		SetProperty( 'Form_2' , cImage , 'Width' , iif(nButton=1, 22, 20) )
		SetProperty( 'Form_2' , cImage , 'Height' , iif(nButton=1, 22, 20) )
		SetProperty( 'Form_2' , cImage , 'Picture' , "button" + Str(nButton + 3, 1) + ".bmp" )
		lHover := .F.
	endif

	ERASE WINDOW Form_2
	CreateBottomLine()

Return Nil


Function CreateBottomLine()
	Local nBottom := Form_2.Height - GetTitleHeight() - 48

	// Above of image toolbar
	DRAW LINE IN WINDOW Form_2 ;
		AT nBottom,0 TO nBottom,Form_2.Width ;
		PENCOLOR iif(IsWinXPorLater(), {172, 168, 153}, {128, 128, 128})

	DRAW LINE IN WINDOW Form_2 ;
		AT nBottom + 1,0 TO nBottom + 1,Form_2.Width ;
		PENCOLOR WHITE

Return Nil
