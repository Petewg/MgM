/*
 * MINIGUI - Harbour Win32 GUI library Demo
 *
 * Copyright 2002-05 Roberto Lopez <harbourminigui@gmail.com>
 * http://harbourminigui.googlepages.com/
*/

#include 'minigui.ch'

#define ISVISTAORLATER()	( ISVISTA() .Or. ISSEVEN() )

#xcommand ON KEY SPACE [ OF <parent> ] ACTION <action> ;
=> ;
_DefineHotKey ( <"parent"> , 0 , VK_SPACE , <{action}> )

FUNCTION Main()

    DEFINE WINDOW Win_1 ; 
        AT 0,0 ; 
        WIDTH 500 ; 
        HEIGHT 500 ; 
        TITLE 'MonthCalendar Control Demo' ; 
	ICON "DEMO.ICO" ;
        MAIN ; 
        NOSIZE  

	DEFINE MAIN MENU
		DEFINE POPUP 'Test'
			MENUITEM 'Set Row' ACTION Win_1.Control_1.Row := Val(InputBox('Enter Row',''))
			MENUITEM 'Set Col' ACTION Win_1.Control_1.Col := Val(InputBox('Enter Col',''))
			MENUITEM 'Set Width' ACTION Win_1.Control_1.Width := Val(InputBox('Enter Width',''))
			MENUITEM 'Set Height' ACTION Win_1.Control_1.Height := Val(InputBox('Enter Height',''))
			SEPARATOR
			MENUITEM 'Get Row' ACTION MsgInfo ( Win_1.Control_1.Row, 'Row' )
			MENUITEM 'Get Col' ACTION MsgInfo ( Win_1.Control_1.Col, 'Col' )
			MENUITEM 'Get Width' ACTION MsgInfo ( Win_1.Control_1.Width, 'Width' )
			MENUITEM 'Get Height' ACTION MsgInfo ( Win_1.Control_1.Height, 'Height' )

		END POPUP
	END MENU

        DEFINE MONTHCALENDAR CONTROL_1
		ROW	10
		COL	10
		TOOLTIP 'MonthCalendar Control' 
		FONTNAME 'Arial'
		FONTSIZE 8
		IF ! ISVISTAORLATER()
			BACKCOLOR YELLOW
			FONTCOLOR RED
			TITLEBACKCOLOR BLACK
			TITLEFONTCOLOR YELLOW
			TRAILINGFONTCOLOR PURPLE
			BKGNDCOLOR GREEN
		ENDIF
	END MONTHCALENDAR

    IF ! ISVISTAORLATER()

	ON KEY LEFT		ACTION Win_1.Control_1.Value := Win_1.Control_1.Value - 1
	ON KEY RIGHT		ACTION Win_1.Control_1.Value := Win_1.Control_1.Value + 1
	ON KEY UP		ACTION Win_1.Control_1.Value := Win_1.Control_1.Value - 7
	ON KEY DOWN		ACTION Win_1.Control_1.Value := Win_1.Control_1.Value + 7

	ON KEY SPACE		ACTION Win_1.Control_1.Value := Date()

	ON KEY CONTROL+LEFT	ACTION Win_1.Control_1.Value := Win_1.Control_1.Value - 30
	ON KEY CONTROL+RIGHT	ACTION Win_1.Control_1.Value := Win_1.Control_1.Value + 30

    ENDIF

    END WINDOW

    ACTIVATE WINDOW Win_1

RETURN NIL
