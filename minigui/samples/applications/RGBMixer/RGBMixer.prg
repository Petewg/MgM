/*
 * MINIGUI - Harbour Win32 GUI library Demo
 *
 * Copyright 2002-09 Roberto Lopez <harbourminigui@gmail.com>
 * http://harbourminigui.googlepages.com/
 *
 * Copyright 2007-09 Grigory Filatov <gfilatov@inbox.ru>
*/

ANNOUNCE RDDSYS

#include "minigui.ch"

#define PROGRAM 'RGBMixer'
#define VERSION ' version 1.0'
#define COPYRIGHT ' Grigory Filatov, 2007'

#define MsgAlert( c )	MsgExclamation( c, "Error" )
#define NTRIM( n )	hb_ntos( n )

#define IDI_MAIN	1001

Static cIniFile, cRGBHexColor := "#7D7D7D", nStepping := 5

*--------------------------------------------------------*
Procedure Main()
*--------------------------------------------------------*
LOCAL r, g, b

	SET MULTIPLE OFF WARNING
	SET DECIMAL TO

	cIniFile := GetStartupFolder() + "\" + PROGRAM + ".ini"

	IF FILE(cIniFile)

		BEGIN INI FILE cIniFile

			GET cRGBHexColor SECTION PROGRAM ENTRY "RGBHexColor" DEFAULT cRGBHexColor
			GET nStepping    SECTION PROGRAM ENTRY "Stepping"    DEFAULT nStepping

		END INI

	ENDIF

	r := HEXATODEC( SubStr(cRGBHexColor, 2, 2) )
	g := HEXATODEC( SubStr(cRGBHexColor, 4, 2) )
	b := HEXATODEC( Right(cRGBHexColor, 2) )

	DEFINE WINDOW Form_1 					;
		AT 0,0 						;
		WIDTH 375					;
		HEIGHT iif(_HMG_IsXP, 290, 282) 		;
		TITLE PROGRAM 					;
		ICON IDI_MAIN					;
		MAIN						;
		NOMAXIMIZE NOSIZE				;
		ON PAINT OnPaint()				;
		ON RELEASE SaveConfig()				;
		FONT 'MS Sans Serif' SIZE 8

		DEFINE MAIN MENU

			POPUP "&File"

				ITEM '&Copy to Clipboard' + Chr(9) + 'Enter'		ACTION CopyToClipboard( cRGBHexColor )
				SEPARATOR
				ITEM 'E&xit' + Chr(9) + 'Alt+X'				ACTION ThisWindow.Release()

			END POPUP

			POPUP "&Options"

				ITEM 'Stepping: &1' + Chr(9) + 'F2'			ACTION ChangeStepping(1) NAME f2
				ITEM 'Stepping: &5' + Chr(9) + 'F3'			ACTION ChangeStepping(5) NAME f3
				ITEM 'Stepping: 51 (&216 colors)' + Chr(9) + 'F4'	ACTION ChangeStepping(51) NAME f4

			END POPUP

			POPUP "&?"

				ITEM 'A&bout'						ACTION MsgAbout()

			END POPUP

		END MENU

		Form_1.f2.Checked := (nStepping == 1)
		Form_1.f3.Checked := (nStepping == 5)
		Form_1.f4.Checked := (nStepping == 51)

		DRAW RECTANGLE IN WINDOW Form_1 AT 4,15 TO 204,215 ;
			FILLCOLOR { r, g, b }

		@ 0,245 LABEL Label_1 VALUE NTRIM( r ) ;
			WIDTH 32 ;
			HEIGHT 12

		@ 0,290 LABEL Label_2 VALUE NTRIM( g ) ;
			WIDTH 32 ;
			HEIGHT 12

		@ 0,335 LABEL Label_3 VALUE NTRIM( b ) ;
			WIDTH 32 ;
			HEIGHT 12

		@ 20, 235 SLIDER Slider_1					;
			RANGE 0, 255 / nStepping				;
			VALUE r / nStepping					;
			WIDTH 32						;
			HEIGHT 170						;
			VERTICAL 						;
			TOP							;
			ON CHANGE ChangeColor( 1, Form_1.Slider_1.Value )	;
			TOOLTIP "Red"

		@ 20, 280 SLIDER Slider_2					;
			RANGE 0, 255 / nStepping				;
			VALUE g / nStepping					;
			WIDTH 32						;
			HEIGHT 170						;
			VERTICAL 						;
			TOP							;
			ON CHANGE ChangeColor( 2, Form_1.Slider_2.Value )	;
			TOOLTIP "Green"

		@ 20, 325 SLIDER Slider_3					;
			RANGE 0, 255 / nStepping				;
			VALUE b / nStepping					;
			WIDTH 32						;
			HEIGHT 170						;
			VERTICAL 						;
			TOP							;
			ON CHANGE ChangeColor( 3, Form_1.Slider_3.Value )	;
			TOOLTIP "Blue"

		@ 197,245 IMAGE Image_1 PICTURE "RED" ;
			WIDTH 20 HEIGHT 8 ;
			ACTION Form_1.Slider_1.Value := IF( Form_1.Slider_1.Value == 255 / nStepping, 0, 255 / nStepping )

		@ 197,290 IMAGE Image_2 PICTURE "GREEN" ;
			WIDTH 20 HEIGHT 8 ;
			ACTION Form_1.Slider_2.Value := IF( Form_1.Slider_2.Value == 255 / nStepping, 0, 255 / nStepping )

		@ 197,335 IMAGE Image_3 PICTURE "BLUE" ;
			WIDTH 20 HEIGHT 8 ;
			ACTION Form_1.Slider_3.Value := IF( Form_1.Slider_3.Value == 255 / nStepping, 0, 255 / nStepping )

		DEFINE STATUSBAR FONT 'MS Sans Serif' SIZE 8 KEYBOARD

		END STATUSBAR

		Form_1.StatusBar.Item(1) := 'COLOR="' + cRGBHexColor + "'"

		ON KEY ALT+X ACTION ThisWindow.Release()
		ON KEY RETURN ACTION CopyToClipboard( cRGBHexColor )
		ON KEY F2 ACTION ChangeStepping(1)
		ON KEY F3 ACTION ChangeStepping(5)
		ON KEY F4 ACTION ChangeStepping(51)

	END WINDOW

	CENTER WINDOW Form_1

	ACTIVATE WINDOW Form_1

Return

*--------------------------------------------------------*
Procedure ChangeColor( n, color )
*--------------------------------------------------------*
LOCAL r, g, b, label := NTRIM( color * nStepping )

	r := SubStr(cRGBHexColor, 2, 2)
	g := SubStr(cRGBHexColor, 4, 2)
	b := Right(cRGBHexColor, 2)

	SetProperty( 'Form_1', 'Label_' + NTRIM( n ), 'Value', label )
	color := DECTOHEXA( color * nStepping )
	color := iif( LEN(color) < 1, '00', iif( LEN(color) < 2, '0' + color, color ) )

	SWITCH n
	CASE 1
		cRGBHexColor := '#' + color + g + b
		EXIT
	CASE 2
		cRGBHexColor := '#' + r + color + b
		EXIT
	CASE 3
		cRGBHexColor := '#' + r + g + color
	END

	Form_1.StatusBar.Item( 1 ) := 'COLOR="' + cRGBHexColor + "'"

	r := HEXATODEC( SubStr(cRGBHexColor, 2, 2) )
	g := HEXATODEC( SubStr(cRGBHexColor, 4, 2) )
	b := HEXATODEC( Right(cRGBHexColor, 2) )

	ERASE WINDOW Form_1

	DRAW RECTANGLE IN WINDOW Form_1 ;
		AT 4,15 TO 204,215 ;
		FILLCOLOR { r, g, b }

Return

*--------------------------------------------------------*
Procedure ChangeStepping( n )
*--------------------------------------------------------*
LOCAL aColor := {}, i

	Aadd( aColor, HEXATODEC( SubStr(cRGBHexColor, 2, 2) ) )
	Aadd( aColor, HEXATODEC( SubStr(cRGBHexColor, 4, 2) ) )
	Aadd( aColor, HEXATODEC( Right(cRGBHexColor, 2) ) )

	nStepping := n
	Form_1.f2.Checked := (nStepping == 1)
	Form_1.f3.Checked := (nStepping == 5)
	Form_1.f4.Checked := (nStepping == 51)

	For i = 1 To 3
		SetProperty( 'Form_1', 'Slider_' + NTRIM( i ), 'RangeMax', 255 / nStepping )
		SetProperty( 'Form_1', 'Slider_' + NTRIM( i ), 'Value', aColor[i] / nStepping )
	Next

Return

*--------------------------------------------------------*
Static Procedure OnPaint()
*--------------------------------------------------------*

	DRAW BOX IN WINDOW Form_1 ;
		AT Form_1.Image_1.Row - 1, Form_1.Image_1.Col - 1 ;
		TO Form_1.Image_1.Row + 8, Form_1.Image_1.Col + 20

	DRAW BOX IN WINDOW Form_1 ;
		AT Form_1.Image_2.Row - 1, Form_1.Image_2.Col - 1 ;
		TO Form_1.Image_2.Row + 8, Form_1.Image_2.Col + 20

	DRAW BOX IN WINDOW Form_1 ;
		AT Form_1.Image_3.Row - 1, Form_1.Image_3.Col - 1 ;
		TO Form_1.Image_3.Row + 8, Form_1.Image_3.Col + 20

Return

*--------------------------------------------------------*
Static Procedure SaveConfig()
*--------------------------------------------------------*

	BEGIN INI FILE cIniFile

		SET SECTION PROGRAM ENTRY "RGBHexColor" TO cRGBHexColor
		SET SECTION PROGRAM ENTRY "Stepping" TO nStepping

	END INI

Return

*--------------------------------------------------------*
Static Function MsgAbout()
*--------------------------------------------------------*
return MsgInfo( padc(PROGRAM + VERSION, 40) + CRLF + ;
	"Copyright " + Chr(169) + COPYRIGHT + CRLF + CRLF + ;
	hb_compiler() + CRLF + ;
	version() + CRLF + ;
	Left(MiniGuiVersion(), 38) + CRLF + CRLF + ;
	padc("This program is Freeware!", 38) + CRLF + ;
	padc("Copying is allowed!", 40), "About " + PROGRAM, IDI_MAIN, .f. )


#ifdef __XHARBOUR__

/*
 * Harbour Project source code:
 * Conversion Functions
 *
 * Copyright 1999 Luiz Rafael Culik <Culik@sl.conex.net>
 * www - https://harbour.github.io
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2, or (at your option)
 * any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this software; see the file COPYING.  If not, write to
 * the Free Software Foundation, Inc., 59 Temple Place, Suite 330,
 * Boston, MA 02111-1307 USA (or visit the web site http://www.gnu.org/).
 *
 * As a special exception, the Harbour Project gives permission for
 * additional uses of the text contained in its release of Harbour.
 *
 * The exception is that, if you link the Harbour libraries with other
 * files to produce an executable, this does not by itself cause the
 * resulting executable to be covered by the GNU General Public License.
 * Your use of that executable is in no way restricted on account of
 * linking the Harbour library code into it.
 *
 * This exception does not however invalidate any other reasons why
 * the executable file might be covered by the GNU General Public License.
 *
 * This exception applies only to the code released by the Harbour
 * Project under the name Harbour.  If you copy code from other
 * Harbour Project or Free Software Foundation releases into a copy of
 * Harbour, as the General Public License permits, the exception does
 * not apply to the code that you add in this way.  To avoid misleading
 * anyone as to the status of such modified files, you must delete
 * this exception notice from them.
 *
 * If you write modifications of your own for Harbour, it is your choice
 * whether to permit this exception to apply to your modifications.
 * If you do not wish that, delete this exception notice.
 *
 */

FUNCTION DecToHexa(nNumber)
   local cNewString:=''
   local nTemp:=0
   WHILE(nNumber > 0)
      nTemp:=(nNumber%16)
      cNewString:=SubStr('0123456789ABCDEF',(nTemp+1),1)+cNewString
      nNumber:=Int((nNumber-nTemp)/16)
   ENDDO
RETURN(cNewString)

FUNCTION HexaToDec(cString)
   local nNumber:=0,nX:=0
   local cNewString:=AllTrim(cString)
   local nLen:=Len(cNewString)
   FOR nX:=1 to nLen
      nNumber+=(At(SubStr(cNewString,nX,1),'0123456789ABCDEF')-1)*(16**(nLen-nX))
   NEXT nX
RETURN nNumber

#endif