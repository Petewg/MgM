/*
 * MINIGUI - Harbour Win32 GUI library Demo
 *
 * Copyright 2002 Roberto Lopez <harbourminigui@gmail.com>
 * http://harbourminigui.googlepages.com/
 *
 * Copyright 2006 Grigory Filatov <gfilatov@inbox.ru>
*/

#include "minigui.ch"

#define WM_PAINT	15

#command DEFINE WINDOW <w> ;
         [ AT <row>,<col> ] ;
         [ WIDTH <wi> ] ;
         [ HEIGHT <h> ] ;
         PICTURE <bitmap> ;
         SPLASH ;
         [ DELAY <delay> ] ;
         [ ON RELEASE <ReleaseProcedure> ] ;
      => ;
	_DefineSplashWindow( <"w">, <row>, <col>, <wi>, <h>, <bitmap>, <delay>, <{ReleaseProcedure}> )

/*
*/
Function Main

	DEFINE WINDOW Form_Main ;
		AT 0,0 ;
		WIDTH 640 HEIGHT 480 ;
		TITLE 'Main Window' ;
		MAIN ;
		NOSHOW 

	END WINDOW

	DEFINE WINDOW Form_Splash ;
		PICTURE 'DEMO' ;
		SPLASH ;
		DELAY 4 ;
		ON RELEASE Form_Main.Show

	END WINDOW

	CENTER WINDOW Form_Main

	ACTIVATE WINDOW ALL

Return Nil

/*
*/
Procedure _DefineSplashWindow( name, row, col, width, height, cbitmap, nTime, Release )
Local aBmpSize := BmpSize( cbitmap )

	DEFAULT row := 0, col := 0, width := aBmpSize[1], height := aBmpSize[2], nTime := 2

	DEFINE WINDOW &name ;
		AT row, col ;
		WIDTH width HEIGHT height ;
		CHILD TOPMOST ;
		NOSIZE NOMAXIMIZE NOMINIMIZE NOSYSMENU NOCAPTION ;
		ON INIT _SplashDelay( name, nTime ) ;
		ON RELEASE Eval( Release )

                @ 0,0 IMAGE Image_1 ;
			PICTURE cbitmap ;
			WIDTH width ;
			HEIGHT height

		DRAW LINE IN WINDOW &name ;
			AT 0, 0 TO 0, Width ;
			PENCOLOR BLACK ;
			PENWIDTH 2

		DRAW LINE IN WINDOW &name ;
			AT Height, 0 TO Height, Width ;
			PENCOLOR BLACK ;
			PENWIDTH 2

		DRAW LINE IN WINDOW &name ;
			AT 0, 0 TO Height, 0 ;
			PENCOLOR BLACK ;
			PENWIDTH 2

		DRAW LINE IN WINDOW &name ;
			AT 0, Width TO Height, Width ;
			PENCOLOR BLACK ;
			PENWIDTH 2

	END WINDOW

	IF EMPTY(row) .AND. EMPTY(col)
		CENTER WINDOW &name
	ENDIF

	SHOW WINDOW &name

Return

/*
*/
Procedure _SplashDelay( name, nTime )
Local iTime := Seconds()

	SendMessage( GetFormHandle(name), WM_PAINT, 0, 0 )

	Do While Seconds() - iTime < nTime
		 DoEvents()
	EndDo

	DoMethod( name, 'Release' )

Return
