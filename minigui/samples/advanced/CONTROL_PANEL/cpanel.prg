/*
 * MINIGUI - Harbour Win32 GUI library Demo
 *
 * (c) 2011 Grigory Filatov <gfilatov@inbox.ru>
 *
*/

#include "minigui.ch"


Procedure Main
	Local aCaptions := { "Display Properties", ;
                             "Install/Uninstall", ;
                             "System Properties", ;
                             "Mouse Properties", ;
                             "About program", ;
                             "Exit" }, i, cImage, cLabel, nPos := 22

	DEFINE WINDOW Win_1 ;
		AT 0,0 ;
		WIDTH 198 + iif(ISVISTAORLATER(), 1, 2) * GetBorderWidth() ;
		HEIGHT GetTitleHeight() + 322 + GetBorderHeight() ;
		TITLE "Control Panel" ;
		ICON "MAIN" ;
		MAIN NOMINIMIZE NOMAXIMIZE NOSIZE ;
		BACKCOLOR iif(ISVISTAORLATER(), {233, 236, 216}, Nil) ;
		FONT 'MS Sans Serif' SIZE 9

		For i := 1 To Len(aCaptions)

			cImage := "Image_" + Str(i, 1)
			@ nPos, 24 IMAGE &cImage ;
				PICTURE "IMAGE" + Str(i, 1) ;
				WIDTH 32 ;
				HEIGHT 32 ;
				TRANSPARENT

			cLabel := "Button_" + Str(i, 1)
			@ nPos + 8, 15 LABEL &cLabel VALUE aCaptions[i] ;
				WIDTH 160 ;
				HEIGHT 20 ;
				TRANSPARENT RIGHTALIGN ;
				ACTION DoAction( Val(Right(this.name, 1)) ) ;
				ON MOUSEHOVER createbtnborder("Win_1",this.row-12,this.col-5,this.row+this.height+8,this.col+this.width+14) ;
				ON MOUSELEAVE erasewindow("Win_1")

			nPos += 50

		Next

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
      local cExeFullPath
      local cWinDir := System.WindowsFolder + "\"
      local cSysDir := System.SystemFolder + "\"
      local cParam := cSysDir

	if nMode < 5
		if file(cWinDir + "control.exe")
			cExeFullPath := cWinDir + "control.exe"
		elseif file(cSysDir + "control.exe")
			cExeFullPath := cSysDir + "control.exe"
		endif
	endif

	switch nMode

	case 1
		cParam += "desk.cpl"
		exit

	case 2
		cParam += "appwiz.cpl"
		exit

	case 3
		cParam += "sysdm.cpl"
		exit

	case 4
		cParam += "main.cpl"
		exit

	case 5
		showabout()
		exit

	case 6
		thiswindow.release

	end switch

	if nMode < 5
		EXECUTE FILE ( cExeFullPath ) PARAMETERS ( cParam )
	endif

return nil


function showabout()
      local cAbout := xpadc( "Control Panel v.1.0.1", 400 ) + CRLF + ;
	xpadc( "Copyright " + Chr(169) + " 2011 Grigory Filatov", 400 ) + CRLF + CRLF + ;
	xpadr( "C compiler", 148, "." ) + " : " + hb_compiler() + CRLF + ;
	xpadr( "xBase compiler", 151, "." ) + " : " + version() + CRLF + ;
	xpadr( "GUI library", 150, "." ) + " : " + Left(MiniGuiVersion(), 38) + CRLF + CRLF + ;
	xpadr( "Operating System", 150, "." ) + " : " + OS() + CRLF + ;
	xpadr( "Amount of RAM (MB)", 144, "." ) + " : " + hb_ntos( MemoryStatus(1) + 1 ) + CRLF + ;
	xpadr( "Swap-file size (MB)", 150, "." ) + " : " + hb_ntos( MemoryStatus(3) )

      DEFINE WINDOW Win_2 ;
         AT 0,0 ;
         WIDTH 345 + iif(ISVISTAORLATER(), 1, 2) * GetBorderWidth() ;
         HEIGHT GetTitleHeight() + 269 + GetBorderHeight() ;
         TITLE 'About program' ;
         ICON "MAIN" ;
         PALETTE NOSIZE ;
         BACKCOLOR iif(ISVISTAORLATER(), {233, 236, 216}, Nil) ;
         FONT 'MS Sans Serif' SIZE 9

	@ 0, 0 IMAGE Image_1	;
		PICTURE "LOGO"	;
		WIDTH 345	;
		HEIGHT 73

	@ 80, 6 EditBox readText;
		Width 334       ;
		Height 140      ;
		Value cAbout	;
                NoHScroll

	_ExtDisableControl ( "readText", "Win_2" )

	CreateLine()

	@ Win_2.Height - 50, 265 LABEL Label_1 VALUE "Close" ;
		WIDTH 74 ;
		HEIGHT 14 ;
		TRANSPARENT CENTERALIGN ;
		ACTION thiswindow.release ;
		ON MOUSEHOVER createbtnborder("Win_2",this.row-6,this.col,this.row+this.height+4,this.col+this.width) ;
		ON MOUSELEAVE ( erasewindow("Win_2"), CreateLine() )

	ON KEY ESCAPE ACTION thiswindow.release

	END WINDOW

	Center Window Win_2

	Activate Window Win_2

return nil


function CreateLine()

	DRAW LINE IN WINDOW Win_2 ;
		AT Win_2.Height - 64,6 TO Win_2.Height - 64,340 ;
		PENCOLOR iif(IsWinXPorLater(), {172, 168, 153}, GRAY)

	DRAW LINE IN WINDOW Win_2 ;
		AT Win_2.Height - 63,6 TO Win_2.Height - 63,340 ;
		PENCOLOR WHITE

return nil


function xPadR( cText, nPixels, cChar )

   DEFAULT cChar := Chr(32)

   while GetTextWidth( , cText ) < nPixels
      cText += cChar
   end

return cText


function xPadL( cText, nPixels, cChar )

   DEFAULT cChar := Chr(32)

   while GetTextWidth( , cText ) < nPixels
      cText := cChar + cText
   end

return cText


function xPadC( cText, nPixels, cChar )

   local cRet    := If( ISCHARACTER( cText ), AllTrim( cText ), "" )
   local nLen    := Len( cText )
   local nPixLen
   local nPad

   DEFAULT cChar := Chr(32)

   nPixLen := GetTextWidth( , cText )
   nPad    := GetTextWidth( , cChar )

   if nPixels > nPixLen
      cRet := PadC( cRet, Int( nLen + ( nPixels - nPixLen ) / nPad ), cChar )
   endif

return cRet
