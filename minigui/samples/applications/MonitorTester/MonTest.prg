/*
 * MINIGUI - Harbour Win32 GUI library Demo
 *
 * Copyright 2003-2005 Grigory Filatov <gfilatov@inbox.ru>
*/

ANNOUNCE RDDSYS

#include "minigui.ch"

#define PROGRAM 'Monitor Tester'
#define VERSION ' version 1.0'
#define COPYRIGHT ' 2005 Grigory Filatov'

#define SW_SHOW   5     // &H5

Memvar nScrWidth, nScrHeight

Static nBkClr := 2, cBtnName := "Btn_24", lOnTop := .T., nScreen := 1
Static aColor := {SILVER, WHITE, YELLOW, AQUA, GREEN, OLIVE}

*--------------------------------------------------------*
Function Main()
*--------------------------------------------------------*
Local aColors := {"Silver", "White", "Yellow", "Aqua", "Green", "Olive", "Background"}
PRIVATE nScrWidth := GetDesktopWidth(), nScrHeight := GetDesktopHeight()

	IF FILE('MonTest.chm')
		SET HELPFILE TO 'MonTest.chm'
	ENDIF

	DEFINE WINDOW Form_1 AT nScrHeight - 124, nScrWidth - 290 ;
		WIDTH IF(IsXPThemeActive(), 264, 260) HEIGHT 90 ;
		MAIN ;
		TOPMOST NOSIZE NOCAPTION

		DEFINE SPLITBOX 

			DEFINE TOOLBAR ToolBar_1 BUTTONSIZE 16,16 FLAT

				BUTTON Btn_11 ;
				PICTURE 'Test1' ;
				TOOLTIP 'TV Test' ;
				ACTION DrawTest1()

				BUTTON Btn_12 ;
				PICTURE 'Bars' ;
				TOOLTIP 'Colour Bars' ;
				ACTION DrawColourBars()

				BUTTON Btn_13 ;
				PICTURE 'Grey' ;
				TOOLTIP 'Grey Scale' ;
				ACTION DrawGreyScale()

				BUTTON Btn_14 ;
				PICTURE 'Adjust' ;
				TOOLTIP 'Adjust Brightness' ;
				ACTION DrawAdjustBrightness()

				BUTTON Btn_15 ;
				PICTURE 'High' ;
				TOOLTIP 'High voltage regulation' ;
				ACTION DrawHighVoltage()

				BUTTON Btn_16 ;
				PICTURE 'Read' ;
				TOOLTIP 'Readability' ;
				ACTION DrawReadAbility() SEPARATOR

				BUTTON Btn_17 ;
				PICTURE 'Display' ;
				TOOLTIP 'Display properties' ;
				ACTION ( SetWndStyle( "Form_3", .F. ), ;
					ShellExecute( GetFormHandle("Form_1"), NIL,'rundll32.exe', "shell32.dll,Control_RunDLL desk.cpl,,3", NIL, SW_SHOW ) )

				BUTTON Btn_18 ;
				PICTURE 'Help' ;
				TOOLTIP 'Help' ;
				ACTION ( SetWndStyle( "Form_3", .F. ), DISPLAY HELP MAIN )

				BUTTON Btn_19 ;
				PICTURE 'About' ;
				TOOLTIP 'About' ;
				ACTION MsgAbout() SEPARATOR

				BUTTON Btn_20 ;
				PICTURE 'Close' ;
				TOOLTIP 'Close' ;
				ACTION ReleaseAllWindows()

			END TOOLBAR

			DEFINE TOOLBAR ToolBar_2 BUTTONSIZE 16,16 FLAT BREAK

				BUTTON Btn_21 ;
				PICTURE 'Vert' ;
				TOOLTIP 'Vertical lines' ;
				ACTION VertLines() CHECK GROUP

				BUTTON Btn_22 ;
				PICTURE 'Horiz' ;
				TOOLTIP 'Horizontal lines' ;
				ACTION HorizLines() CHECK GROUP

				BUTTON Btn_23 ;
				PICTURE 'Cross' ;
				TOOLTIP 'Grid' ;
				ACTION DrawGrid() CHECK GROUP SEPARATOR

				BUTTON Btn_24 ;
				PICTURE 'R1' ;
				TOOLTIP '1 pixel' ;
				ACTION Setpixels() CHECK GROUP

				BUTTON Btn_25 ;
				PICTURE 'R2' ;
				TOOLTIP '2 pixels' ;
				ACTION Setpixels() CHECK GROUP

				BUTTON Btn_26 ;
				PICTURE 'R3' ;
				TOOLTIP '3 pixels' ;
				ACTION Setpixels() CHECK GROUP

				BUTTON Btn_27 ;
				PICTURE 'R6' ;
				TOOLTIP '6 pixels' ;
				ACTION Setpixels() CHECK GROUP

				BUTTON Btn_28 ;
				PICTURE 'R20' ;
				TOOLTIP '20 pixels' ;
				ACTION Setpixels() CHECK GROUP

				BUTTON Btn_29 ;
				PICTURE 'R50' ;
				TOOLTIP '50 pixels' ;
				ACTION Setpixels() CHECK GROUP SEPARATOR

				BUTTON Btn_30 ;
				PICTURE 'Hide' ;
				TOOLTIP 'Hide buttons' ;
				ACTION ( lOnTop := .F., SetWndStyle( "Form_1", .F. ), SetWndStyle( "Form_3", .T. ), SetWndStyle( "Form_2", .T. ) )

			END TOOLBAR

			DEFINE TOOLBAR ToolBar_3 BUTTONSIZE 16,16 FLAT BREAK

				BUTTON Btn_31 ;
				PICTURE 'Red' ;
				TOOLTIP 'Red' ;
				ACTION SetDisplayColor(RED)

				BUTTON Btn_32 ;
				PICTURE 'Green' ;
				TOOLTIP 'Green' ;
				ACTION SetDisplayColor(GREEN)

				BUTTON Btn_33 ;
				PICTURE 'Blue' ;
				TOOLTIP 'Blue' ;
				ACTION SetDisplayColor(BLUE)

				BUTTON Btn_34 ;
				PICTURE 'Yellow' ;
				TOOLTIP 'Yellow' ;
				ACTION SetDisplayColor(YELLOW)

				BUTTON Btn_35 ;
				PICTURE 'Aqua' ;
				TOOLTIP 'Aqua' ;
				ACTION SetDisplayColor(AQUA)

				BUTTON Btn_36 ;
				PICTURE 'Pink' ;
				TOOLTIP 'Pink' ;
				ACTION SetDisplayColor(PINK) SEPARATOR

				BUTTON Btn_37 ;
				PICTURE 'Sound' ;
				TOOLTIP 'Default sound' ;
				ACTION PlayDefaultSound() 

			END TOOLBAR

			COMBOBOX Combo_1 ;
				ITEMS aColors ;
				VALUE 7 ;
				WIDTH IF(IsXPThemeActive(), 62, 63) ;
				TOOLTIP 'Background' ;
				ON GOTFOCUS IF(Form_1.Combo_1.ItemCount > 6, Form_1.Combo_1.DeleteItem(7), ) ;
				ON CHANGE SetBackgroundColor(Form_1.Combo_1.Value)

		END SPLITBOX

	END WINDOW

     Form_1.Combo_1.Enabled := .F.

	DEFINE WINDOW Form_2 AT nScrHeight - 44, nScrWidth - 48 ;
		WIDTH 24 HEIGHT 24 ;
		NOSIZE NOCAPTION

		@0,0 BUTTON ImageBtn_1 PICTURE 'Small' WIDTH 24 HEIGHT 24 ;
			ACTION ( lOnTop := .T., SetWndStyle( "Form_1", .T. ), SetWndStyle( "Form_2", .F. ) ) ;
			TOOLTIP 'Show control panel'

	END WINDOW

	DEFINE WINDOW Form_3 AT 0, 0 ;
		WIDTH nScrWidth HEIGHT nScrHeight ;
		TOPMOST NOSIZE NOCAPTION ;
		ON INIT DrawTest1() ;
		ON MOUSECLICK ( SetWndStyle( "Form_3", .T. ), IF( lOnTop, ;
			( SetWndStyle( "Form_2", .T. ), SetWndStyle( "Form_1", .F. ) ), ;
			( SetWndStyle( "Form_2", .F. ), SetWndStyle( "Form_1", .T. ) ) ), lOnTop := !lOnTop ) ;
		BACKCOLOR BLACK

		DEFINE CONTEXT MENU
			ITEM '&Show control panel' 		ACTION ( lOnTop := .T., SetWndStyle( "Form_3", .T. ), ;
									SetWndStyle( "Form_2", .F. ), SetWndStyle( "Form_1", .T. ) )
			SEPARATOR
			ITEM '&TV Test' 			ACTION DrawTest1() IMAGE 'Test1'
			ITEM '&Colour Bars' 			ACTION DrawColourBars() IMAGE 'Bars'
			ITEM '&Grey Scale' 			ACTION DrawGreyScale() IMAGE 'Grey'
			ITEM '&Adjust Brightness' 		ACTION DrawAdjustBrightness() IMAGE 'Adjust'
			ITEM '&High voltage regulation' 	ACTION DrawHighVoltage() IMAGE 'High'
			SEPARATOR
			ITEM 'H&elp' 				ACTION ( SetWndStyle( "Form_3", .F. ), DISPLAY HELP MAIN ) IMAGE 'Help'
			ITEM 'A&bout' 			ACTION ( MsgAbout(), IF( lOnTop, Form_1.Setfocus, Form_2.Setfocus ) ) IMAGE 'About'
			SEPARATOR
			ITEM 'C&lose' 			ACTION ReleaseAllWindows() IMAGE 'Close'
		END MENU

	END WINDOW

    ON KEY ESCAPE of Form_1 ACTION  domethod("Form_1","release") //  Pierpaolo added to facilitate the closure of the program
    ON KEY F1 of Form_1 ACTION _Execute( _HMG_MainHandle, "open", 'MonTest.chm' )

    ACTIVATE WINDOW Form_3, Form_2, Form_1

Return Nil

*--------------------------------------------------------*
Procedure VertLines()
*--------------------------------------------------------*
Local nPixel := GetPixels() + 1, i := 0

	Form_3.BackColor := aColor[nBkClr]

	while i < nScrWidth

		DRAW LINE IN WINDOW Form_3 ;
			AT 0,i TO nScrHeight,i ;
			PENCOLOR BLACK

		i += nPixel
	end

Return

*--------------------------------------------------------*
Procedure HorizLines()
*--------------------------------------------------------*
Local nPixel := GetPixels() + 1, i := 0

	Form_3.BackColor := aColor[nBkClr]

	while i < nScrHeight

		DRAW LINE IN WINDOW Form_3 ;
			AT i,0 TO i,nScrWidth ;
			PENCOLOR BLACK

		i += nPixel
	end

Return

*--------------------------------------------------------*
Procedure DrawGrid()
*--------------------------------------------------------*
Local nPixel := GetPixels() + 1, i := 0

	Form_3.BackColor := aColor[nBkClr]

	while i < nScrWidth

		DRAW LINE IN WINDOW Form_3 ;
			AT 0,i TO nScrHeight,i ;
			PENCOLOR BLACK

		i += nPixel
	end

	i := 0
	while i < nScrHeight

		DRAW LINE IN WINDOW Form_3 ;
			AT i,0 TO i,nScrWidth ;
			PENCOLOR BLACK

		i += nPixel
	end

Return

*--------------------------------------------------------*
Procedure SetPixels()
*--------------------------------------------------------*

	Form_1.Combo_1.Enabled := .T.

	cBtnName := This.Name

	do case
		case Form_1.Btn_22.Value == .T.
			HorizLines()
		case Form_1.Btn_23.Value == .T.
			DrawGrid()
		otherwise
			IF Form_1.Btn_21.Value # .T.
				Form_1.Btn_21.Value := .T.
			ENDIF
			VertLines()
	endcase

Return

*--------------------------------------------------------*
Static Function GetPixels()
*--------------------------------------------------------*
Local nPixel

	Form_1.Combo_1.Enabled := .T.

	do case
		case cBtnName == "Btn_25"
			nPixel := 2
		case cBtnName == "Btn_26"
			nPixel := 3
		case cBtnName == "Btn_27"
			nPixel := 6
		case cBtnName == "Btn_28"
			nPixel := 20
		case cBtnName == "Btn_29"
			nPixel := 50
		otherwise
			IF Form_1.Btn_24.Value # .T.
				Form_1.Btn_24.Value := .T.
			ENDIF
			nPixel := 1
	endcase

	ClearForm_3()

Return nPixel

*--------------------------------------------------------*
Procedure SetBackgroundColor( nColor )
*--------------------------------------------------------*

	if nColor < 1
		nColor := nBkClr
	endif

	ClearForm_3()

	Form_3.BackColor := aColor[nColor]

	nBkClr := nColor

Return

*--------------------------------------------------------*
Procedure SetDisplayColor( aColor )
*--------------------------------------------------------*

	ClearForm_3()

	Form_3.BackColor := aColor

Return

*--------------------------------------------------------*
Procedure PlayDefaultSound()
*--------------------------------------------------------*
Local cKey := "AppEvents\Schemes\Apps\.Default\SystemStart\.Default"
Local cWav := GetRegistryValue(HKEY_CURRENT_USER, cKey, "")

	IF !Empty(cWav)
		IF IsWinNT()
			cWav := StrTran(cWav, "%SystemRoot%", GetWindowsFolder())
		ENDIF

		PLAY WAVE cWav
	ENDIF

Return

*--------------------------------------------------------*
Procedure DrawTest1()
*--------------------------------------------------------*
Local nWidth := nScrWidth / 16, i
Local nHeight := nScrHeight / 12, nSquare := (nScrWidth - nScrHeight) / 2

	ClearForm_3()
	Form_3.BackColor := BLACK

	DRAW ELLIPSE IN WINDOW Form_3 ;
		AT 2,nSquare+2 TO nScrHeight-2,nScrWidth-nSquare+2 ;
		PENCOLOR GREEN ;
		PENWIDTH 2 ;
		FILLCOLOR BLACK

	DRAW ELLIPSE IN WINDOW Form_3 ;
		AT 2,2 TO 2*nHeight+2,2*nWidth+2 ;
		PENCOLOR GREEN ;
		PENWIDTH 2 ;
		FILLCOLOR BLACK

	DRAW ELLIPSE IN WINDOW Form_3 ;
		AT nScrHeight-2*nHeight+2,2 TO nScrHeight-2,2*nWidth+2 ;
		PENCOLOR GREEN ;
		PENWIDTH 2 ;
		FILLCOLOR BLACK

	DRAW ELLIPSE IN WINDOW Form_3 ;
		AT 2,nScrWidth-2*nWidth+2 TO 2*nHeight+2,nScrWidth-2 ;
		PENCOLOR GREEN ;
		PENWIDTH 2 ;
		FILLCOLOR BLACK

	DRAW ELLIPSE IN WINDOW Form_3 ;
		AT nScrHeight-2*nHeight+2,nScrWidth-2*nWidth+2 TO nScrHeight-2,nScrWidth-2 ;
		PENCOLOR GREEN ;
		PENWIDTH 2 ;
		FILLCOLOR BLACK

	for i := 1 to 13
		DRAW LINE IN WINDOW Form_3 ;
			AT nHeight*(i-1)+2,0 TO nHeight*(i-1)+2,nScrWidth ;
			PENCOLOR FUCHSIA ;
			PENWIDTH 2
	next

	DRAW LINE IN WINDOW Form_3 ;
		AT nScrHeight-2,0 TO nScrHeight-2,nScrWidth ;
		PENCOLOR FUCHSIA ;
		PENWIDTH 2

	for i := 1 to 17
		DRAW LINE IN WINDOW Form_3 ;
			AT 0,nWidth*(i-1)+2 TO nScrHeight,nWidth*(i-1)+2 ;
			PENCOLOR FUCHSIA ;
			PENWIDTH 2
	next

	DRAW LINE IN WINDOW Form_3 ;
		AT 0,nScrWidth-2 TO nScrHeight,nScrWidth-2 ;
		PENCOLOR FUCHSIA ;
		PENWIDTH 2

if nScrWidth>750

	DRAW RECTANGLE IN WINDOW Form_3 ;
		AT 4*nHeight+3,if(nScrWidth<1000,4,5)*nWidth+3 TO 5*nHeight+1,if(nScrWidth<1000,12,11)*nWidth-3 ;
		PENCOLOR BLACK ;
		FILLCOLOR BLACK

	DRAW TEXT IN WINDOW Form_3 ;
		AT 4*nHeight+if(nScrWidth<1000,8,24),if(nScrWidth<1000,5,6)*nWidth-16 ;
		VALUE PROGRAM + VERSION ;
		FONT "Arial" SIZE 24 ;
		FONTCOLOR WHITE TRANSPARENT

	DRAW RECTANGLE IN WINDOW Form_3 ;
		AT 7*nHeight+3,if(nScrWidth<1000,4,5)*nWidth+3 TO 8*nHeight+1,if(nScrWidth<1000,12,11)*nWidth-3 ;
		PENCOLOR BLACK ;
		FILLCOLOR BLACK

	DRAW TEXT IN WINDOW Form_3 ;
		AT 7*nHeight+if(nScrWidth<1000,14,32),if(nScrWidth<1000,5,6)*nWidth-16 ;
		VALUE Ltrim(Str(nScrWidth)) + " x " + Ltrim(Str(nScrHeight)) + " pixels and " + Ltrim(Str(GetDisplayColors())) + "b colors" ;
		FONT "Arial" SIZE 18 ;
		FONTCOLOR WHITE TRANSPARENT
endif

Return

*--------------------------------------------------------*
Procedure DrawColourBars()
*--------------------------------------------------------*
Local aBars := { YELLOW, BLUE, GREEN, FUCHSIA, RED, AQUA }, i
Local nWidth := nScrWidth / Len(aBars)

	ClearForm_3()

	for i := 1 to Len(aBars)

		DRAW RECTANGLE IN WINDOW Form_3 ;
			AT 0,nWidth*(i-1) TO nScrHeight,nWidth*i ;
			PENCOLOR aBars[i] ;
			FILLCOLOR aBars[i]
	next

Return

*--------------------------------------------------------*
Procedure DrawGreyScale()
*--------------------------------------------------------*
Local aGrey := { WHITE, {204, 204, 204}, {153, 153, 153}, {102, 102, 102}, {51, 51, 51}, BLACK }, i
Local nWidth := nScrWidth / Len(aGrey)

	ClearForm_3()

	for i := 1 to Len(aGrey)

		DRAW RECTANGLE IN WINDOW Form_3 ;
			AT 0,nWidth*(i-1) TO nScrHeight,nWidth*i ;
			PENCOLOR aGrey[i] ;
			FILLCOLOR aGrey[i]
	next

Return

*--------------------------------------------------------*
Procedure DrawAdjustBrightness()
*--------------------------------------------------------*
Local aGrey := { {156, 156, 156}, {130, 130, 130}, {104, 104, 104}, {78, 78, 78}, {52, 52, 52}, {26, 26, 26}, BLACK }, i
Local nWidth := nScrWidth / 14
Local nHeight := nScrHeight / 14

	ClearForm_3()

	for i := 1 to Len(aGrey)

		DRAW RECTANGLE IN WINDOW Form_3 ;
			AT nHeight*(i-1),nWidth*(i-1) TO nScrHeight - nHeight*(i-1),nScrWidth - nWidth*(i-1) ;
			PENCOLOR aGrey[i] ;
			FILLCOLOR aGrey[i]

		DRAW TEXT IN WINDOW Form_3 ;
			AT nHeight/2 + nHeight*(i-1) - 4,nWidth/2 + nWidth*(i-1) - 12 ;
			VALUE " " + ltrim(str(30+10*i)) + " %" ;
			FONT "MS Sans Serif" SIZE 9 ;
			BACKCOLOR WHITE ;
			FONTCOLOR RED

	next

Return

*--------------------------------------------------------*
Procedure DrawHighVoltage()
*--------------------------------------------------------*
Local aClr := { WHITE, BLACK, WHITE }, i
Local aHeight := {80, nScrHeight - 80, nScrHeight}

if !_IsControlDefined("Timer_1", "Form_3")

	ClearForm_3()

	nScreen := 1
	for i := 1 to Len(aClr)

		DRAW RECTANGLE IN WINDOW Form_3 ;
			AT if(i>1, aHeight[i-1],0),0 TO aHeight[i],nScrWidth ;
			PENCOLOR aClr[i] ;
			FILLCOLOR aClr[i]
	next

	DEFINE TIMER Timer_1 OF Form_3 INTERVAL 500 ACTION OnTimer()
endif

Return

*--------------------------------------------------------*
Procedure OnTimer()
*--------------------------------------------------------*
Local aHeight := {80, nScrHeight - 80, nScrHeight}
Local aClr := IF( Empty(nScreen), ;
	( nScreen := 1, { WHITE, BLACK, WHITE } ), ;
	( nScreen := 0, { BLACK, WHITE, BLACK } ) ), i

	ERASE WINDOW Form_3

	for i := 1 to Len(aClr)

		DRAW RECTANGLE IN WINDOW Form_3 ;
			AT if(i>1, aHeight[i-1],0),0 TO aHeight[i],nScrWidth ;
			PENCOLOR aClr[i] ;
			FILLCOLOR aClr[i]
	next

Return

#define DARKGREEN	{ 0 , 128 , 0 }
*--------------------------------------------------------*
Procedure DrawReadAbility()
*--------------------------------------------------------*
Local cTestName := "ReadAbility"
Local cText := Replicate(cTestName + ' - ' + PROGRAM + ' - ' + Ltrim(COPYRIGHT) + ' - ' + cTestName + CRLF, 10)

if !_IsControlDefined("Edit_1", "Form_3")

	ClearForm_3()
	Form_3.BackColor := GRAY

	@ 60,60 EDITBOX Edit_1 ;
		OF Form_3 ;
		WIDTH 302 ;
		HEIGHT 136 ;
		VALUE cText ;
		FONT "MS Sans Serif" SIZE 9 ;
		BACKCOLOR WHITE ;
		FONTCOLOR BLACK ;
		NOVSCROLL NOHSCROLL ;
		ON GOTFOCUS Form_1.Setfocus

	@ 60,nScrWidth - 368 EDITBOX Edit_2 ;
		OF Form_3 ;
		WIDTH 302 ;
		HEIGHT 136 ;
		VALUE cText ;
		FONT "MS Sans Serif" SIZE 9 ;
		BACKCOLOR BLACK ;
		FONTCOLOR WHITE ;
		NOVSCROLL NOHSCROLL ;
		ON GOTFOCUS Form_1.Setfocus

	@ nScrHeight/2 - 68,60 EDITBOX Edit_3 ;
		OF Form_3 ;
		WIDTH 302 ;
		HEIGHT 136 ;
		VALUE cText ;
		FONT "MS Sans Serif" SIZE 9 ;
		BACKCOLOR BLUE ;
		FONTCOLOR YELLOW ;
		NOVSCROLL NOHSCROLL ;
		ON GOTFOCUS Form_1.Setfocus

	@ nScrHeight/2 - 68,nScrWidth - 368 EDITBOX Edit_4 ;
		OF Form_3 ;
		WIDTH 302 ;
		HEIGHT 136 ;
		VALUE cText ;
		FONT "MS Sans Serif" SIZE 9 ;
		BACKCOLOR YELLOW ;
		FONTCOLOR BLUE ;
		NOVSCROLL NOHSCROLL ;
		ON GOTFOCUS Form_1.Setfocus

	@ nScrHeight - 196,60 EDITBOX Edit_5 ;
		OF Form_3 ;
		WIDTH 302 ;
		HEIGHT 136 ;
		VALUE cText ;
		FONT "MS Sans Serif" SIZE 9 ;
		BACKCOLOR RED ;
		FONTCOLOR DARKGREEN ;
		NOVSCROLL NOHSCROLL ;
		ON GOTFOCUS Form_1.Setfocus

	@ nScrHeight - 196,nScrWidth - 368 EDITBOX Edit_6 ;
		OF Form_3 ;
		WIDTH 302 ;
		HEIGHT 136 ;
		VALUE cText ;
		FONT "MS Sans Serif" SIZE 9 ;
		BACKCOLOR DARKGREEN ;
		FONTCOLOR RED ;
		NOVSCROLL NOHSCROLL ;
		ON GOTFOCUS Form_1.Setfocus
endif

Return

*--------------------------------------------------------*
Procedure ClearForm_3()
*--------------------------------------------------------*
Local i, cEdit

	if IsControlDefined(Timer_1, Form_3)
		Form_3.Timer_1.Release
	endif
	if IsControlDefined(Edit_1, Form_3)
		for i := 1 to 6
			cEdit := "Edit_"+Str(i,1)
			Form_3.&(cEdit).Release
		next
	endif
	ERASE WINDOW Form_3

Return

*--------------------------------------------------------*
Static Procedure MsgAbout()
*--------------------------------------------------------*

	DEFINE WINDOW Form_About ;
		AT 0,0 ;
		WIDTH 224 HEIGHT IF( IsXPThemeActive(), 308, 300 ) ;
		TITLE "About" ;
		MODAL NOSIZE NOSYSMENU ;
		ON INIT Form_About.Btn_2.Setfocus ;
		BACKCOLOR WHITE ;
		FONT 'MS Sans Serif'	;
		SIZE 9

		@ 14,10 FRAME Frame_1 ;
			WIDTH 198 ;
			HEIGHT 218

		@ 26,22 IMAGE Image_1 ;
			PICTURE "LOGO" ;
			WIDTH 59 HEIGHT 64

	       @ 32,94 LABEL Label_1					;
			VALUE PROGRAM					;
			WIDTH 110 HEIGHT 16				;
			BACKCOLOR WHITE					;
			FONT 'MS Sans Serif'				;
			SIZE 10 BOLD

	       @ 60,90 LABEL Label_2					;
			VALUE Upper(Substr(VERSION, 2, 1)) +		;
			Substr(VERSION, 3) + " (May 2005)"		;
			BACKCOLOR WHITE					;
			AUTOSIZE

	       @ 110,22 LABEL Label_3					;
			VALUE "Copyright "+Chr(169)+Left(COPYRIGHT, 5)	;
			WIDTH 180 HEIGHT 28				;
			BACKCOLOR WHITE					;
			CENTERALIGN

	       @ 136,22 LABEL Label_4					;
			VALUE SubStr(COPYRIGHT, 7)			;
			WIDTH 180 HEIGHT 28				;
			BACKCOLOR WHITE					;
			FONT 'MS Sans Serif'				;
			SIZE 12						;
			CENTERALIGN

	       @ 172,24 LABEL Label_5					;
			VALUE "All Rights Reserved"			;
			WIDTH 180 HEIGHT 28				;
			BACKCOLOR WHITE					;
			CENTERALIGN

	       @ 208,24 LABEL Label_7					;
			VALUE "e-mail:"					;
			BACKCOLOR WHITE					;
			AUTOSIZE

		@ 208, 60 HYPERLINK Label_6				;
			VALUE "gfilatov@inbox.ru"			;
			ADDRESS "gfilatov@inbox.ru?cc=&bcc=" +	;
			"&subject=Monitor%20Tester%20Feedback:"	;
			BACKCOLOR WHITE					;
			WIDTH 120 HEIGHT 16				;
			HANDCURSOR

		@ 242, 28 BUTTON Btn_1					;
			CAPTION '&OK'					;
			ACTION Form_About.Release			;
			WIDTH 72					;
			HEIGHT 23

		@ 242, 118 BUTTON Btn_2					; 
			CAPTION '&Help'					;
			ACTION ( SetWndStyle( "Form_3", .F. ), DISPLAY HELP MAIN, Form_About.Release ) ;
			WIDTH 72					;
			HEIGHT 23 DEFAULT

		ON KEY ESCAPE ACTION Form_About.Release

	END WINDOW

	CENTER WINDOW Form_About

	ACTIVATE WINDOW Form_About

Return

#define HWND_TOPMOST    (-1)
#define HWND_NOTOPMOST  (-2)
*--------------------------------------------------------*
Static Procedure SetWndStyle( cForm, lStyle)
*--------------------------------------------------------*
Local nStyle := IF(lStyle, HWND_TOPMOST, HWND_NOTOPMOST)

	SetWindowPos( GetFormHandle( cForm ), nStyle, 0, 0, 0, 0, 3 )

Return


function drawtextout(window,row,col,string,fontcolor,backcolor,fontname,fontsize,bold,italic,underline,strikeout,transparent)
Local i := GetFormIndex( Window )
Local FormHandle := _HMG_aFormHandles[i]
local torow := 0
local tocol := 0

IF formhandle > 0

	if valtype(fontname) == "U"
		fontname := _HMG_DefaultFontName
	endif
	if valtype(fontsize) == "U"
		fontsize := _HMG_DefaultFontSize
	endif
	if valtype(backcolor) == "U"
		backcolor := {255,255,255}
	endif
	if valtype(fontcolor) == "U"
		fontcolor := {0,0,0}
	endif

	torow := row + if(transparent, 0, fontsize + 4)
	tocol := col + (len(string) - 2) * fontsize + if(len(string) > 5, (-1), 2)

	textdraw( formhandle,row,col,string,torow,tocol,fontcolor,backcolor,fontname,fontsize,bold,italic,underline,strikeout,transparent )
	aadd ( _HMG_aFormGraphTasks[i], { || textdraw( formhandle,row,col,string,torow,tocol,fontcolor,backcolor,fontname,fontsize,bold,italic,underline,strikeout,transparent) } )
ENDIF

return nil


#pragma BEGINDUMP

#include <windows.h>
#include "hbapi.h"
#include "hbapiitm.h"

HB_FUNC( GETDISPLAYCOLORS )
{
	DEVMODE  lpDevMode;

	if ( EnumDisplaySettings( NULL, ENUM_CURRENT_SETTINGS, &lpDevMode ) )
	{
		hb_retnl( lpDevMode.dmBitsPerPel );
	}
	else
	{
		hb_retnl( 0 );
	}
}

HB_FUNC ( MENUITEM_SETBITMAPS )
{
	HWND himage1;
	HWND himage2;

	himage1 = (HWND) LoadImage( GetModuleHandle(NULL), hb_parc(3), IMAGE_BITMAP, 13, 13, LR_LOADMAP3DCOLORS | LR_LOADTRANSPARENT );
	if ( himage1 == NULL )
	{
		himage1 = (HWND) LoadImage( 0, hb_parc(3), IMAGE_BITMAP, 0, 0, LR_LOADFROMFILE | LR_LOADMAP3DCOLORS | LR_LOADTRANSPARENT );
	}

	himage2 = (HWND) LoadImage( GetModuleHandle(NULL), hb_parc(4), IMAGE_BITMAP, 13, 13, LR_LOADMAP3DCOLORS | LR_LOADTRANSPARENT );
	if ( himage2 == NULL )
	{
		himage2 = (HWND) LoadImage( 0, hb_parc(4), IMAGE_BITMAP, 0, 0, LR_LOADFROMFILE | LR_LOADMAP3DCOLORS | LR_LOADTRANSPARENT );
	}

	SetMenuItemBitmaps( (HMENU) hb_parnl(1) , hb_parni(2), MF_BYCOMMAND , (HBITMAP) himage1 , (HBITMAP) himage2 ) ;
}

#pragma ENDDUMP
