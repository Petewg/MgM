/*
 * MINIGUI - Harbour Win32 GUI library Demo
 *
 * Copyright 2002-09 Roberto Lopez <harbourminigui@gmail.com>
 *
 * Based upon a sample Minigui\Samples\Advanced\AnimatedGif
 * Author: P.Chornyj <myorg63@mail.ru>
 *
 * Harbour TGif class
 * Copyright 2009 Grigory Filatov <gfilatov@inbox.ru>
*/

#include "minigui.ch"

#define IDR_DEMO	1001 

*--------------------------------------------------------*
Function Main()
*--------------------------------------------------------*
Local oGif, cFile := hb_dirTemp() + "\" + "hmgdemo.gif"
Local aPictInfo

   SET MULTIPLE OFF WARNING

   IF RCDataToFile( IDR_DEMO, cFile ) > 0

	aPictInfo := GetGIFSize( cFile )

	DEFINE WINDOW Form_Main ;
		AT 0,0 ;
		WIDTH 0 HEIGHT 0 ;
		TITLE 'Gif89 Demo' ;
		MAIN NOMAXIMIZE NOSIZE ;
		BACKCOLOR SILVER ;
		ON RELEASE FErase( cFile )

		DEFINE MAIN MENU

			DEFINE POPUP "&File" 

				MENUITEM '&Play' ACTION IIF( !oGif:IsRunning(), oGif:Play(), )
				MENUITEM '&Stop' ACTION IIF( oGif:IsRunning(), oGif:Stop(), )
				MENUITEM '&Restart' ACTION ( oGif:cFilename := 'ani-search.gif', ;
					oGif:nDelay := 12, oGif:nWidth := GetGIFSize( oGif:cFilename )[1], ;
					oGif:nHeight := GetGIFSize( oGif:cFilename )[2], oGif:Update(), ;
					EraseWindow( "Form_Main" ), FormReSize( oGif ), oGif:Restart() )
				SEPARATOR
				MENUITEM "E&xit" ACTION ThisWindow.Release()

			END POPUP

			DEFINE POPUP "&?" 

				MENUITEM "GIF &Info" ACTION IIF( oGif:nTotalFrames > 1, ;
					( oGif:Stop(), MsgInfo( ;
					"Picture name" + Chr(9) + ": " + cFileNoPath( oGif:cFileName ) + CRLF + ;
					"Image Width"  + Chr(9) + ": " + hb_ntos( oGif:nWidth ) + CRLF + ;
					"Image Height" + Chr(9) + ": " + hb_ntos( oGif:nHeight ) + CRLF + ;
					"Total Frames" + Chr(9) + ": " + hb_ntos( oGif:nTotalFrames ) + CRLF + ;
					"Current Frame" + Chr(9) + ": " + hb_ntos( oGif:nCurrentFrame ), ;
					"GIF Info" ), oGif:Play() ), )

			END POPUP

		END MENU

		@ 25, 10 ANIGIF Gif_1 OBJ oGif PARENT Form_Main PICTURE cFile ;
			WIDTH aPictInfo [1] HEIGHT aPictInfo [2]

	END WINDOW

	FormReSize( oGif )

	CENTER WINDOW Form_Main

	ACTIVATE WINDOW Form_Main

   ENDIF

Return Nil

*--------------------------------------------------------*
Function FormReSize( oGif )
*--------------------------------------------------------*
	Form_Main.Width := Max( 180, oGif:nWidth + 2 * GetBorderWidth() + 40 )
	Form_Main.Height := GetTitleHeight() + oGif:nHeight + 2 * GetBorderHeight() + 60
	oGif:nLeft := ( Form_Main.Width - oGif:nWidth - GetBorderWidth() ) / 2 + 1
	oGif:Update()

	DRAW PANEL IN WINDOW Form_Main ;
		AT oGif:nTop - 2, oGif:nLeft - 2 ;
		TO oGif:nBottom + 2, oGif:nRight + 2

Return Nil

*--------------------------------------------------------*
Function GetGIFSize( cGIFfile )
*--------------------------------------------------------*
Return hb_GetImageSize( cGIFfile )
