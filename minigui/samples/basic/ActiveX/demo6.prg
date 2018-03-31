
/*
 * MINIGUI - Harbour Win32 GUI library Demo
 *
 * Copyright 2002-2008 Roberto Lopez <harbourminigui@gmail.com>
 * http://harbourminigui.googlepages.com/
 *
 * Activex Sample: Inspired by Freewin Activex inplementation by 
 * Oscar Joel Lira Lira http://sourceforge.net/projects/freewin
*/

#include "minigui.ch"

Static aFiles, nLen, nCurrent := 1

FUNCTION Main()

	IF !_HMG_IsXP
		MsgStop( 'This Program Runs In WinXP Only!', 'Demo6' )
		QUIT
	ENDIF

	aFiles := DIRECTORY( "*.JPG" )
	Aeval( DIRECTORY( "*.JPEG" ), {|e| Aadd(aFiles, e)} )
	Aeval( DIRECTORY( "*.PNG" ), {|e| Aadd(aFiles, e)} )
	Aeval( DIRECTORY( "*.BMP" ), {|e| Aadd(aFiles, e)} )
	Aeval( DIRECTORY( "*.TIF" ), {|e| Aadd(aFiles, e)} )
	Aeval( DIRECTORY( "*.GIF" ), {|e| Aadd(aFiles, e)} )
	Aeval( DIRECTORY( "*.PSD" ), {|e| Aadd(aFiles, e)} )
	Aeval( DIRECTORY( "*.ICO" ), {|e| Aadd(aFiles, e)} )
	nLen := LEN( aFiles )

	DEFINE WINDOW Win1 ;
		AT 0,0 ;
		WIDTH 500 ;
		HEIGHT 700 ;
		TITLE 'HMG ActiveX Support Demo' ;
		MAIN ;
		ON MAXIMIZE ( Win1.Test.Width := (Win1.Width) - 100, Win1.Test.Height := (Win1.Height) - 100 ) ;
		ON SIZE ( Win1.Test.Width := (Win1.Width) - 100, Win1.Test.Height := (Win1.Height) - 100 ) ;
		ON RELEASE Win1.Test.Release

		DEFINE MAIN MENU
			POPUP "Test"
				MENUITEM "Open File" ACTION Test()
			END POPUP 			
		END MENU

		DEFINE ACTIVEX Test
			ROW 10
			COL 50
			WIDTH 400  
			HEIGHT 600  
			PROGID "Preview.Preview.1"
		END ACTIVEX

		ON KEY DOWN ACTION Win1.Test.XObject:Zoom(-1)
		ON KEY UP ACTION Win1.Test.XObject:Zoom(1)
		ON KEY LEFT ACTION PreviousImage()
		ON KEY RIGHT ACTION NextImage()

	END WINDOW

	Win1.Test.XObject:Showfile( GetStartUpFolder() + "\" + aFiles[nCurrent][1], 1 )

	Center Window Win1

	Activate Window Win1

RETURN NIL


PROCEDURE PreviousImage

	IF nCurrent > 1
		nCurrent--
	ELSE
		nCurrent := nLen
	ENDIF

	Win1.Test.XObject:Showfile( GetStartUpFolder() + "\" + aFiles[nCurrent][1], 1 )

RETURN


PROCEDURE NextImage

	IF nCurrent < nLen
		nCurrent++
	ELSE
		nCurrent := 1
	ENDIF

	Win1.Test.XObject:Showfile( GetStartUpFolder() + "\" + aFiles[nCurrent][1], 1 )

RETURN


Procedure Test()

	Win1.Test.XObject:Showfile( "c:\minigui\samples\advanced\bmpviewer\bmps\HateComp.bmp", 1 )

Return

