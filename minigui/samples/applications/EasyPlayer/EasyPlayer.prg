/*
 * MINIGUI - Harbour Win32 GUI library Demo
 *
 * Copyright 2002-2010 Roberto Lopez <harbourminigui@gmail.com>
 * http://harbourminigui.googlepages.com/
 *
 * Copyright 2003-2013 Grigory Filatov <gfilatov@inbox.ru>
*/

ANNOUNCE RDDSYS

#include "minigui.ch"

#define PROGRAM 'Easy Media Player'
#define VERSION ' version 1.2.3'
#define COPYRIGHT ' 2003-2013 Grigory Filatov'

#define IDI_MAIN	1001

#xcommand ON KEY SPACE [ OF <parent> ] ACTION <action> ;
=> ;
_DefineHotKey ( <"parent"> , 0 , VK_SPACE , <{action}> )

Static cFile := "", nLenght := 0, lPause := .f., lNoSound := .f.

*-----------------------------------------------------------------------------*
PROCEDURE Main()
*-----------------------------------------------------------------------------*
Local v

	SET MULTIPLE OFF

	DEFINE WINDOW Form_1 						;
		AT 0,0 							;
		WIDTH 375 + iif(IsSeven(), GetBorderWidth(), 0)		;
		HEIGHT iif(IsXPThemeActive(), 380, 370) + 		;
			iif(IsSeven(), GetBorderHeight(), 0)		;
		TITLE PROGRAM 						;
		ICON IDI_MAIN						;
		MAIN							;
		ON INIT ( ResizeCtrls(),				;
			DoMethod( "Form_1", "Btn_1", "SetFocus" ) )	;
		ON RELEASE DoMethod( "Form_1", "Play_1", "Release" )	;
		ON MAXIMIZE ResizeCtrls( .t. )				;
		ON SIZE ResizeCtrls( .t. )

		DEFINE MAIN MENU

			POPUP "&File"

				ITEM '&Open...' + Chr(9) + 'Ctrl+O'		ACTION OpenMedia()

				ITEM '&Close'					ACTION ( cFile := "", ;
					Form_1.Btn_2.Enabled := !Empty(cFile), ;
					Form_1.Btn_3.Enabled := !Empty(cFile), ;
					Form_1.Btn_4.Enabled := !Empty(cFile), ;
					Form_1.Play_1.Close, Form_1.Title := PROGRAM )

				SEPARATOR

				ITEM 'E&xit' + Chr(9) + 'Alt+X'			ACTION ReleaseAllWindows()

			END POPUP

			POPUP "&View"

				ITEM 'Full &Screen' + Chr(9) + 'Alt+Enter'	ACTION FullScreen()

				POPUP "&Aspect ratios"
					ITEM '16 : 9' + Chr(9) + 'Ctrl+1' 	ACTION SetAspect( 780, 524 )
					ITEM ' 4 : 3' + Chr(9) + 'Ctrl+2'	ACTION SetAspect( 780, 670 )
				END POPUP

			END POPUP

			POPUP "&Playback"

				ITEM '&Play/Pause' + Chr(9) + 'Space'		ACTION PlayPause()

				POPUP "&Volume"
					ITEM '&Up' + Chr(9) + 'Page Up'		ACTION VolumeUpDown( .T. )
					ITEM '&Down' + Chr(9) + 'Page Down'	ACTION VolumeUpDown( .F. )
					ITEM '&Mute' + Chr(9) + 'Ctrl+M'	ACTION MuteSound()
				END POPUP

			END POPUP

			POPUP "&Help"

				ITEM 'A&bout'					ACTION MsgAbout()

			END POPUP

		END MENU

		@ 0, 2 PLAYER Play_1 ;
			WIDTH Form_1.Width - 12 ;
			HEIGHT 286 FILE cFile ;
			NOMENU NOOPEN ;
			SHOWPOSITION

		@ Form_1.Height - 75, 2 BUTTON Btn_1 ; 
			PICTURE "IDB_OPEN" ; 
			ACTION OpenMedia() ;
			WIDTH 26 ;
			HEIGHT 26 ;
			FLAT

		@ Form_1.Height - 75, 32 BUTTON Btn_2 ; 
			PICTURE "IDB_PLAY" ; 
			ACTION ( lPause := .f., ;
				Form_1.Btn_3.Enabled := .t., ;
				Form_1.Btn_4.Enabled := .t., ;
				Form_1.Btn_2.Enabled := .f., ;
				iif( IsControlDefined( Timer_1, Form_1 ), , ;
				_DefineTimer( "Timer_1", "Form_1", 250, {|| CheckStop()} ) ), ;
				Form_1.Play_1.Play(), ;
	                        v := _GetPlayerVolume( "Play_1", "Form_1" ), ;
				_SetPlayerVolume( "Play_1", "Form_1", v ), ;
				Form_1.Slider_1.Value := v ) ;
			WIDTH 26 ;
			HEIGHT 26 ;
			FLAT

		@ Form_1.Height - 75, 62 BUTTON Btn_3 ; 
			PICTURE "IDB_PAUSE" ; 
			ACTION ( lPause := .t., ;
				Form_1.Btn_2.Enabled := .t., ;
				Form_1.Btn_3.Enabled := .f., ;
				Form_1.Play_1.Pause() ) ;
			WIDTH 26 ;
			HEIGHT 26 ;
			FLAT

		@ Form_1.Height - 75, 92 BUTTON Btn_4 ; 
			PICTURE "IDB_STOP" ; 
			ACTION ( lPause := .t., ;
				Form_1.Btn_3.Enabled := .f., ;
				Form_1.Btn_4.Enabled := .f., ;
				Form_1.Play_1.Position := 0, ;
				Form_1.Btn_2.Enabled := .t. ) ;
			WIDTH 26 ;
			HEIGHT 26 ;
			FLAT

		@ Form_1.Height - 75, 125 CHECKBUTTON Btn_5 ; 
			PICTURE "IDB_SOUND" ; 
			WIDTH 26 ;
			HEIGHT 26 ;
			VALUE lNoSound ;
			ON CHANGE MuteSound()

		@ Form_1.Height - 75, 158 SLIDER Slider_1			;
			RANGE 0, 1000						;
			VALUE 500						;
			WIDTH 206						;
			HEIGHT 26						;
			NOTICKS							;
			ON CHANGE SetVolume( Form_1.Slider_1.Value )		;
			TOOLTIP "Change volume of sound"

		Form_1.Btn_2.Enabled := !Empty(cFile)
		Form_1.Btn_3.Enabled := !Empty(cFile)
		Form_1.Btn_4.Enabled := !Empty(cFile)

		ON KEY ALT+X ACTION Form_1.Release()

		ON KEY ESCAPE ACTION iif( Empty(cFile), , ;
			( Form_1.Btn_3.Enabled := .f., Form_1.Btn_4.Enabled := .f., ;
			Form_1.Play_1.Stop(), Form_1.Btn_2.Enabled := .t., Form_1.Btn_2.SetFocus ) )

		ON KEY ALT+RETURN ACTION FullScreen()

		ON KEY CONTROL+O ACTION OpenMedia()

		ON KEY CONTROL+M ACTION MuteSound()

		ON KEY CONTROL+1 ACTION SetAspect( 780, 524 )

		ON KEY CONTROL+2 ACTION SetAspect( 780, 670 )

		ON KEY SPACE ACTION PlayPause()

		ON KEY PRIOR ACTION VolumeUpDown( .T. )

		ON KEY NEXT ACTION VolumeUpDown( .F. )

	END WINDOW

	CENTER WINDOW Form_1

	ACTIVATE WINDOW Form_1

RETURN

*-----------------------------------------------------------------------------*
STATIC PROCEDURE ResizeCtrls( lCenter )
*-----------------------------------------------------------------------------*
Local nWidth := Form_1.Width, nHeight := Form_1.Height
Local nHeightMin := iif(IsXPThemeActive(), 120, 110), ;
	nCtrlPos := nHeight - iif(IsXPThemeActive(), 85, 75) - iif(IsSeven(), GetBorderHeight() / 2, 0)

	Default lCenter := .f.

	IF lCenter .AND. nWidth < 370
		Form_1.Width := iif(IsXPThemeActive(), 380, 370) + iif(IsSeven(), GetBorderWidth(), 0)
	ENDIF

	IF lCenter .AND. nHeight < nHeightMin
		Form_1.Height := nHeightMin + iif(IsSeven(), GetBorderHeight() / 2, 0)
	ENDIF

	Form_1.Play_1.Width := Form_1.Width - 12 - iif(IsSeven(), GetBorderWidth(), 0)
	Form_1.Play_1.Height := nHeight - iif(IsXPThemeActive(), 94, 84)

	Form_1.Btn_1.Row := nCtrlPos
	Form_1.Btn_2.Row := nCtrlPos
	Form_1.Btn_3.Row := nCtrlPos
	Form_1.Btn_4.Row := nCtrlPos
	Form_1.Btn_5.Row := nCtrlPos
	Form_1.Btn_5.Col := nWidth - 247

	Form_1.Slider_1.Row := nCtrlPos
	Form_1.Slider_1.Col := nWidth - 217

	InvalidateRect( _HMG_MainHandle, 0)

	IF lCenter
		IF cFileExt( cFile ) $ "MP3 WAV"
			Form_1.Height := nHeightMin
		ENDIF
		Form_1.Center()
	ENDIF

RETURN

*-----------------------------------------------------------------------------*
PROCEDURE OpenMedia()
*-----------------------------------------------------------------------------*
Local cOpenFile := Getfile( { {"Media files", "*.avi;*.mpg;*.dat;*.wmv;*.mp3;*.wav"}, ;
	{"All files", "*.*"} }, "Open a File" )

	cFile := cOpenFile

	Form_1.Play_1.Release

	@ 0, 2 PLAYER Play_1 OF Form_1 ;
		WIDTH Form_1.Width - 12 ;
		HEIGHT 286 FILE cFile ;
		NOMENU NOOPEN ;
		SHOWPOSITION

	IF Empty(cFile)

		Form_1.Btn_2.Enabled := !Empty(cFile)
		Form_1.Btn_3.Enabled := !Empty(cFile)
		Form_1.Btn_4.Enabled := !Empty(cFile)
		Form_1.Btn_1.SetFocus

		nLenght := 0
		Form_1.Title := PROGRAM
	ELSE

		Form_1.Btn_2.Enabled := .t.
		Form_1.Btn_3.Enabled := .f.
		Form_1.Btn_4.Enabled := .f.
		Form_1.Btn_2.SetFocus

		nLenght := _GetPlayerLength( "Play_1", "Form_1" )
		Form_1.Title := cFileNoPath(cFile) + ' - ' + PROGRAM

		IF cFileExt( cFile ) $ "MP3 WAV"
			Form_1.Height := iif(IsXPThemeActive(), 120, 110)
		ELSE
			Form_1.Height := iif(IsXPThemeActive(), 380, 370)
		ENDIF

		ResizeCtrls()
	ENDIF

RETURN

*-----------------------------------------------------------------------------*
PROCEDURE VolumeUpDown ( lUp )
*-----------------------------------------------------------------------------*
Local v := Form_1.Slider_1.Value

	SetVolume( v + iif( lUp, 50, -50 ) )

	v := GetProperty( "Form_1", "Play_1", "Volume" )
	Form_1.Slider_1.Value := v

RETURN

*-----------------------------------------------------------------------------*
PROCEDURE SetVolume ( nVolume )
*-----------------------------------------------------------------------------*

	IF !Empty(cFile)

		IF nVolume < 0
			nVolume := 0
		ELSEIF nVolume > 1000
			nVolume := 1000
		ENDIF

		IF !Empty( nVolume ) .AND. lNoSound
			lNoSound := .f.
			SetChkBtnPicture()
		ENDIF

		SET PLAYER Play_1 OF Form_1 VOLUME nVolume

		IF IsWindowDefined( Form_2 )
			SET PLAYER Play_1 OF Form_2 VOLUME nVolume
		ENDIF

	ENDIF

RETURN

*-----------------------------------------------------------------------------*
PROCEDURE MuteSound()
*-----------------------------------------------------------------------------*

	lNoSound := !lNoSound

	SetChkBtnPicture()

	SetVolume( iif( lNoSound, 0, Form_1.Slider_1.Value ) )

RETURN

*-----------------------------------------------------------------------------*
STATIC PROCEDURE SetChkBtnPicture()
*-----------------------------------------------------------------------------*

	Form_1.Btn_5.Release

	IF lNoSound

		@ Form_1.Height - iif(IsXPThemeActive(), 85, 75) - iif(IsSeven(), GetBorderHeight() / 2, 0), ;
			Form_1.Width - 247 CHECKBUTTON Btn_5 OF Form_1 ;
			PICTURE "IDB_NOSOUND" ; 
			WIDTH 26 ;
			HEIGHT 26 ;
			VALUE lNoSound ;
			ON CHANGE MuteSound()

	ELSE

		@ Form_1.Height - iif(IsXPThemeActive(), 85, 75) - iif(IsSeven(), GetBorderHeight() / 2, 0), ;
			Form_1.Width - 247 CHECKBUTTON Btn_5 OF Form_1 ;
			PICTURE "IDB_SOUND" ; 
			WIDTH 26 ;
			HEIGHT 26 ;
			VALUE lNoSound ;
			ON CHANGE MuteSound()

	ENDIF

RETURN

*-----------------------------------------------------------------------------*
STATIC PROCEDURE SetAspect( nX, nY )
*-----------------------------------------------------------------------------*

	IF cFileExt( cFile ) $ "AVI MPG DAT"

		_SetWindowSizePos ( "Form_1" , , , nX , nY )

		Form_1.Center()

	ENDIF

RETURN

*-----------------------------------------------------------------------------*
STATIC PROCEDURE PlayPause()
*-----------------------------------------------------------------------------*

	IF !Empty(cFile)

		IF Form_1.Btn_3.Enabled

			lPause := .t.
			Form_1.Btn_2.Enabled := .t.
			Form_1.Btn_3.Enabled := .f.
			Form_1.Play_1.Pause()

		ELSE

			lPause := .f.
			Form_1.Btn_2.Enabled := .f.
			Form_1.Btn_3.Enabled := .t.
			Form_1.Play_1.Resume()

		ENDIF

	ENDIF

RETURN

*-----------------------------------------------------------------------------*
STATIC PROCEDURE CheckStop()
*-----------------------------------------------------------------------------*
Local p

	IF IsControlDefined( Play_1, Form_1 )

		p := GetProperty( "Form_1", "Play_1", "Position" )

		IF p >= nLenght

			IF IsControlDefined( Timer_1, Form_1 )
				Form_1.Timer_1.Release()
			ENDIF

			lPause := .t.
			Form_1.Btn_3.Enabled := .f.
			Form_1.Btn_4.Enabled := .f.
			Form_1.Btn_2.Enabled := .t.
			Form_1.Btn_2.SetFocus()

		ENDIF
	ENDIF

RETURN

*-----------------------------------------------------------------------------*
STATIC PROCEDURE FullScreen()
*-----------------------------------------------------------------------------*
Local p, nVolume := Form_1.Slider_1.Value

IF !Empty(cFile) .AND. !lPause .AND. cFileExt( cFile ) $ "AVI MPG DAT WMV"

   IF ! IsWindowDefined( Form_2 )

	DEFINE WINDOW Form_2 AT -1, -1 ;
		WIDTH GetDesktopWidth() + 2 ;
		HEIGHT GetDesktopHeight() + 2 ;
		CHILD TOPMOST NOSIZE NOCAPTION ;
		ON INIT ( ShowCursor( .F. ), ;
			DoMethod( "Form_1", "Play_1", "Pause" ), ;
                        p := GetProperty( "Form_1", "Play_1", "Position" ), ;
			_SetPlayerPosition( "Play_1", "Form_2", p ), ;
			DoMethod( "Form_2", "Play_1", "Play" ) ) ;
		ON RELEASE ( ShowCursor( .T. ), ;
			DoMethod( "Form_1", "Play_1", "Resume" ), ;
                        p := GetProperty( "Form_2", "Play_1", "Position" ), ;
			_SetPlayerPosition( "Play_1", "Form_1", p ), ;
			iif( p >= nLenght, CheckStop(), DoMethod( "Form_1", "Play_1", "Play" ) ) )

		@ 0, 0 PLAYER Play_1 ;
			WIDTH Form_2.Width ;
			HEIGHT Form_2.Height ;
			FILE cFile ;
			NOAUTOSIZEWINDOW ;
			NOPLAYBAR

		SET PLAYER Play_1 OF Form_2 VOLUME nVolume

		ON KEY ESCAPE ACTION Form_2.Release

		ON KEY RETURN ACTION Form_2.Release

		ON KEY ALT+RETURN ACTION Form_2.Release

		ON KEY PRIOR ACTION VolumeUpDown( .T. )

		ON KEY NEXT ACTION VolumeUpDown( .F. )

	END WINDOW

	ACTIVATE WINDOW Form_2

   ELSE

	Form_2.Setfocus()

   ENDIF

ENDIF

RETURN

*--------------------------------------------------------*
FUNCTION cFileExt( cPathMask )
*--------------------------------------------------------*
Local cExt := AllTrim( cFileNoPath( cPathMask ) )
Local n    := RAt( ".", cExt )

RETURN Upper( AllTrim( If( n > 0 .and. Len( cExt ) > n, Right( cExt, Len( cExt ) - n ), "" ) ) )

*--------------------------------------------------------*
STATIC FUNCTION MsgAbout()
*--------------------------------------------------------*
RETURN MsgInfo( padc(PROGRAM + VERSION, 40) + CRLF + ;
	"Copyright " + Chr(169) + COPYRIGHT + CRLF + CRLF + ;
	hb_compiler() + CRLF + ;
	version() + CRLF + ;
	Left(MiniGuiVersion(), 38) + CRLF + CRLF + ;
	padc("This program is Freeware!", 38) + CRLF + ;
	padc("Copying is allowed!", 40), "About " + PROGRAM, IDI_MAIN, .f. )
