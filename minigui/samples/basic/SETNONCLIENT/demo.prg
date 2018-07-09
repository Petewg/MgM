/*
 * Harbour MiniGUI Non Client Demo
*/

#include "minigui.ch"

Function Main
LOCAL aSave := SaveDefaults()
/*
	SET WINDOW BORDER TO 5
	SET SCROLLBAR TO 22
	SET TITLEBAR HEIGHT TO 24
	SET MENU TO 22
	SET TITLEBAR FONT TO "Tahoma", 11 BOLD CHARSET 1
	SET MENU FONT TO "Tahoma", 11 BOLD CHARSET 1
	SET STATUSBAR FONT TO "Tahoma", 11 BOLD CHARSET 1
*/
	SET MESSAGEBOX FONT TO "Tahoma", 11

	DEFINE WINDOW Win1 ;
		AT 0,0 ;
		WIDTH 400 ;
		HEIGHT 400 ;
		TITLE 'Hello World!' ;
		MAIN ;
		ON RELEASE RestoreDefaults(aSave)

		DEFINE MAIN MENU
			DEFINE POPUP 'File'
				ITEM "Exit"	ACTION ThisWindow.Release()
			END POPUP
			POPUP 'Help'
				ITEM 'About'	ACTION MsgInfo("MiniGUI Non Client Demo") 
			END POPUP
		END MENU

		DEFINE STATUSBAR
			STATUSITEM 'HMG Power Ready'
		END STATUSBAR

		DEFINE LISTBOX List1
			ROW	10
			COL	10
			WIDTH	100
			HEIGHT	110
			ITEMS	{ '01','02','03','04','05','06','07','08','09','10' }
		END LISTBOX

		DEFINE BUTTON Button1
			ROW	10
			COL	150
			CAPTION	'Get Non Client Value'
			ACTION	Msgdebug(GetNonClient())
			WIDTH	150
		END BUTTON

		DEFINE BUTTON Button2
			ROW	50
			COL	150
			CAPTION	'Get Non Client Font'
			ACTION	Msgdebug(GetNonClientFont(4))
			WIDTH	150
		END BUTTON

	END WINDOW

	CENTER WINDOW Win1

	ACTIVATE WINDOW Win1 

Return Nil


FUNCTION SaveDefaults()
LOCAL ActiveWindowBorder := GetWindowBorderSize()
LOCAL ScrollBarSize := GetScrollBarSize()
LOCAL ActiveTitleBarWidth := GetTitleBarWidth()
LOCAL ActiveTitleBarHeight := GetTitleBarHeight()
LOCAL MenuSize := GetMenuBarSize()
LOCAL fn := GetDefaultFontName(), fs := GetDefaultFontSize()
LOCAL charset := GetNonClientFont(4)[4]

RETURN {ActiveWindowBorder,ScrollBarSize,ActiveTitleBarWidth,ActiveTitleBarHeight,MenuSize,fn,fs,charset}


PROCEDURE RestoreDefaults(aRestore)
LOCAL bordersize,ScrollSize,CaptionW,CaptionH,MenuSize,Fname,Fsize,charset
LOCAL i

	bordersize := aRestore [1]
	ScrollSize := aRestore [2]
	CaptionW   := aRestore [3]
	CaptionH   := aRestore [4]
	MenuSize   := aRestore [5]
	Fname      := aRestore [6]
	Fsize      := aRestore [7]
	charset    := aRestore [8]

	SETNONCLIENT( 1, bordersize )
	SETNONCLIENT( 2, ScrollSize )
	SETNONCLIENT( 3, CaptionW )
	SETNONCLIENT( 4, CaptionH )
	SETNONCLIENT( 5, MenuSize )
	FOR i:=1 TO 4
		SetNonClientFont( i, Fname, Fsize, .f., charset )
	NEXT

RETURN
