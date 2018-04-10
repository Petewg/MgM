/*
 * MINIGUI - Harbour Win32 GUI library Demo
 *
 * (c) 2016 Grigory Filatov <gfilatov@inbox.ru>
 *
*/

#include "minigui.ch"


Procedure Main
	Local aCaptions := { "Add a local printer", ;
                             "Add a network, wireless or Bluetooth printer" }
	Local aNotes := { "Use this option only if you don't have a USB printer. (Windows automatically installs USB printers when you plug them in.)", ;
                             "Make sure that your computer is connected to the network, or that your Bluetooth or wireless printer is turned on." }, ;
		i, cImage, cLabel, cLabel2, nPos := 94

	DEFINE WINDOW Win_1 ;
		AT 0,0 ;
		WIDTH 615 + iif(ISVISTAORLATER(), 1, 2) * GetBorderWidth() ;
		HEIGHT GetTitleHeight() + 416 + GetBorderHeight() ;
		TITLE "Add Printer" ;
                ICON "zzz_PrintIcon" ;
		MAIN NOMINIMIZE NOMAXIMIZE NOSIZE ;
		BACKCOLOR iif(ISVISTAORLATER(), {233, 236, 216}, Nil) ;
		FONT "MS Sans Serif" SIZE 9

		DRAW ICON IN WINDOW Win_1 AT 4, 12 ;
			PICTURE "ZZZ_PRINTICON"

		@ 8, 40 LABEL Label_Title VALUE ThisWindow.Title ;
			AUTOSIZE ;
			BOLD ;
			TRANSPARENT

		@ 32, GetBorderWidth() / 2 FRAME Frame_1 Caption "" WIDTH Win_1.Width - 2 * GetBorderWidth() HEIGHT Win_1.Height - 78 - GetTitleHeight()

		@ 50, 36 LABEL Label_Title_2 VALUE "What type of printer do you want to install?" ;
			AUTOSIZE ;
			BOLD ;
			TRANSPARENT

		For i := 1 To Len(aCaptions)

			cImage := "Image_" + Str(i, 1)
			@ nPos, 48 IMAGE &cImage ;
				PICTURE "arrow.bmp" ;
				WIDTH 16 ;
				HEIGHT 16 ;
				TRANSPARENT ;
				ACTION DoAction( Val(Right(this.name, 1)) )

			cLabel := "Button_" + Str(i, 1)
			@ nPos, 70 LABEL &cLabel VALUE aCaptions[i] ;
				WIDTH 500 ;
				HEIGHT 18 ;
				BOLD ;
				TRANSPARENT ;
				ACTION DoAction( Val(Right(this.name, 1)) ) ;
				ON MOUSEHOVER createbtnborder("Win_1",this.row-12,this.col-38,this.row+this.height+42,this.col+this.width+14) ;
				ON MOUSELEAVE ( erasewindow("Win_1"), hmg_drawicon("Win_1","ZZZ_PRINTICON",4,12,,,,.F.) )

			cLabel2 := "Note_" + Str(i, 1)
			@ nPos + 18, 70 LABEL &cLabel2 VALUE aNotes[i] ;
				WIDTH 500 ;
				HEIGHT 46 ;
				TRANSPARENT ;
				ACTION DoAction( Val(Right(this.name, 1)) ) ;
				ON MOUSEHOVER createbtnborder("Win_1",this.row-12-18,this.col-38,this.row-4+this.height,this.col+this.width+14) ;
				ON MOUSELEAVE ( erasewindow("Win_1"), hmg_drawicon("Win_1","ZZZ_PRINTICON",4,12,,,,.F.) )

			nPos += 98

		Next

		SetWindowCursor( GetControlHandle( "Image_1", "Win_1" ), "MINIGUI_FINGER" )

		@ Win_1.Height - 38 - GetTitleHeight(),Win_1.Width - 152 BUTTON Button_3 ;
			CAPTION '&Next' ;
			ACTION _dummy() ;
			WIDTH 64 ;
			HEIGHT 23

		Win_1.Button_3.Enabled := .F.

		@ Win_1.Height - 38 - GetTitleHeight(),Win_1.Width - 82 BUTTON Button_4 ;
			CAPTION '&Cancel' ;
			ACTION thiswindow.release ;
			WIDTH 64 ;
			HEIGHT 23

	END WINDOW

	Center Window Win_1

	Activate Window Win_1

Return


function CreateBtnBorder( cWin,t,l,b,r )

	Rc_Cursor( "MINIGUI_FINGER" )

	DRAW PANEL		;
		IN WINDOW &cWin	;
		AT t,l		;
		TO b,r

return nil


function DoAction( nMode )

	switch nMode

	case 1
		MsgInfo("Click 1")
		exit

	case 2

		MsgInfo("Click 2")

	end switch

return nil
