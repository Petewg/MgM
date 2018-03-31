/*
 * MINIGUI - Harbour Win32 GUI library Demo
 *
 * Copyright 2002-2010 Roberto Lopez <harbourminigui@gmail.com>
 * http://harbourminigui.googlepages.com/
 *
 * Copyright 2006-2014 Grigory Filatov <gfilatov@inbox.ru>
*/

ANNOUNCE RDDSYS

#include "minigui.ch"

#define PROGRAM 'ResizeIt'
#define COPYRIGHT ' 2006-2014 Grigory Filatov'
#define VERSION ' version 1.04'

#define IDI_1 1001
#define MsgInfo( c, t ) MsgInfo( c, t, IDI_1, .f. )
#define NTRIM( n ) LTrim( Str( n ) )

#define GW_HWNDFIRST		0
#define GW_HWNDLAST		1
#define GW_HWNDNEXT		2
#define GW_HWNDPREV		3
#define GW_OWNER		4
#define GW_CHILD		5

Static aList := {}, aSearch := {}, ;
	nTop := 116, nLeft := 397, nSize := 4, ;
	nDefaultWidth := 0, nDefaultHeight := 0, ;
	lCenter := .f., lStart := .f., lOnTop := .f., lAutoRefresh := .f.

Memvar cFileIni
Memvar aResults
Memvar aResult
*--------------------------------------------------------*
Procedure Main
*--------------------------------------------------------*

	SET MULTIPLE OFF

	PUBLIC cFileIni := GetStartUpFolder() + "\" + PROGRAM + '.ini'

	IF FILE( cFileIni )

		BEGIN INI FILE cFileIni

			GET nTop SECTION "Form" ENTRY "Top"
			GET nLeft SECTION "Form" ENTRY "Left"

			GET nSize SECTION "Size" ENTRY "Default"

			GET nDefaultWidth SECTION "CustomSize" ENTRY "Width"
			GET nDefaultHeight SECTION "CustomSize" ENTRY "Height"

			GET lCenter SECTION "Options" ENTRY "Center"
			GET lStart SECTION "Options" ENTRY "Start"
			GET lOnTop SECTION "Options" ENTRY "OnTop"
			GET lAutoRefresh SECTION "Options" ENTRY "AutoRefresh"

			GET aSearch SECTION "Search" ENTRY "Default"

		END INI

	ELSE

		aAdd(aSearch, iif(IsVistaOrLater(), "", "Microsoft ") + "Internet Explorer")
		aAdd(aSearch, "- Netscape")
		aAdd(aSearch, "Mozilla")
		aAdd(aSearch, "- Google Chrome")
		aAdd(aSearch, "- Opera")

		BEGIN INI FILE cFileIni

			SET SECTION "Form" ENTRY "Top" TO nTop
			SET SECTION "Form" ENTRY "Left" TO nLeft

			SET SECTION "Size" ENTRY "Default" TO nSize

			SET SECTION "CustomSize" ENTRY "Width" TO nDefaultWidth
			SET SECTION "CustomSize" ENTRY "Height" TO nDefaultHeight

			SET SECTION "Options" ENTRY "Center" TO lCenter
			SET SECTION "Options" ENTRY "Start" TO lStart
			SET SECTION "Options" ENTRY "OnTop" TO lOnTop
			SET SECTION "Options" ENTRY "AutoRefresh" TO lAutoRefresh

			SET SECTION "Search" ENTRY "Default" TO aSearch

		END INI

	ENDIF

	DEFINE WINDOW Form_1 ;
		AT 0,0 ;
		WIDTH 0 HEIGHT 0 ;
		TITLE PROGRAM ;
		ICON 'MAIN' ;
		MAIN NOSHOW ;
		ON INIT MakeForm() ;
		NOTIFYICON "MAIN" ;
		NOTIFYTOOLTIP PROGRAM ;
		ON NOTIFYCLICK RestoreForm()

		DEFINE NOTIFY MENU
			ITEM 'Re&store'		ACTION RestoreForm() DEFAULT
			SEPARATOR
			ITEM '&Options'		ACTION Options() IMAGE 'OPTIONS'
			ITEM '&Refresh'		ACTION RefreshApps() IMAGE 'REFRESH'
			ITEM '&About'		ACTION ShellAbout( "", PROGRAM + VERSION + ;
				CRLF + "Copyright " + Chr(169) + COPYRIGHT, LoadTrayIcon(GetInstance(), "MAIN", 32, 32) ) IMAGE 'ABOUT'
			SEPARATOR
			ITEM 'E&xit'		ACTION Form_1.Release IMAGE 'EXIT'
		END MENU

	END WINDOW

	ACTIVATE WINDOW Form_1

Return

*--------------------------------------------------------*
Procedure MakeForm()
*--------------------------------------------------------*
Local aApps := { "" }, aImages := { "IE", "NSC", "FOX", "WORLD" }

	DEFINE WINDOW Form_2 ;
		AT nTop, nLeft ;
		WIDTH 350 HEIGHT IF(IsXPThemeActive(), 135, 129) ;
		TITLE PROGRAM + " v" + Right(VERSION, 4) ;
		ICON 'MAIN' ;
		CHILD ;
		NOMAXIMIZE NOSIZE ;
		ON INIT ( RefreshApps(), Form_2.Radio_1.Setfocus ) ;
		ON MINIMIZE Form_2.Hide ;
		ON INTERACTIVECLOSE Form_2.Button_4.OnClick ;
		FONT "MS Sans Serif" SIZE 9 ;
		ON RELEASE SavePosition()

		DEFINE TOOLBAR ToolBar_1 BUTTONSIZE 66,20 FLAT RIGHTTEXT

				BUTTON Button_1 ;
					CAPTION 'Resize' ;
					PICTURE 'Resize' ;
					TOOLTIP 'Resize selected window' ;
					ACTION ResizeForm()

				BUTTON Button_2 ;
					CAPTION 'Refresh' ;
					PICTURE 'Refresh' ;
					TOOLTIP 'Refresh application list (F5)' ;
					ACTION RefreshApps() AUTOSIZE

				BUTTON Button_3 ;
					CAPTION 'Options' ;
					PICTURE 'Options' ;
					TOOLTIP 'Change options' ;
					ACTION Options() AUTOSIZE

				BUTTON Button_4 ;
					CAPTION ' Exit ' ;
					PICTURE 'Exit' ;
					TOOLTIP 'Close this program' ;
					ACTION ReleaseAllWindows() AUTOSIZE

				BUTTON Button_5 ;
					CAPTION 'About' ;
					PICTURE 'About' ;
					TOOLTIP 'About this program' ;
					ACTION MsgInfo( padc(PROGRAM + VERSION, 42) + CRLF + ;
						"Copyright " + Chr(169) + COPYRIGHT + CRLF + CRLF + ;
						hb_compiler() + CRLF + version() + CRLF + ;
						Left(MiniGuiVersion(), 38) + CRLF + CRLF + ;
						padc("This program is Freeware!", 40), "About" )

		END TOOLBAR

		@ 32,5 COMBOBOXEX ComboEx_1 ;
			WIDTH Form_2.Width - 16 ;
			ITEMS aApps ;
			VALUE 1 ;
			IMAGE aImages

		@ 56,5 FRAME Frame_1 ;
			CAPTION 'Sizes' ;
			WIDTH Form_2.Width - 16 ;
			HEIGHT 42

		@ 68,8 RADIOGROUP Radio_1						;
			OPTIONS { '&640x480', '&800x600', '&1024x768', '&Custom ' }	;
			VALUE nSize							;
			WIDTH 71							;
			SPACING 0							;
			TOOLTIP 'Resize to ...'						;
			ON CHANGE ( nSize := Form_2.Radio_1.Value )			;
			HORIZONTAL

		@ 74,Form_2.Width - 52 LABEL Label_1 ;
			AUTOSIZE ;
			VALUE 'Change' ;
			FONTCOLOR BLUE UNDERLINE ;
			TOOLTIP 'Change custom size' ;
			ACTION ChangeSize()

		IF !Empty( nDefaultWidth ) .AND. !Empty( nDefaultHeight )
			Form_2.Radio_1.Caption(4) := NTRIM( nDefaultWidth ) + 'x' + NTRIM( nDefaultHeight )
		ENDIF

		ON KEY F5 ACTION RefreshApps()

		IF lAutoRefresh
			DEFINE TIMER Timer_1 INTERVAL 10000 ACTION RefreshApps()
		ENDIF

	END WINDOW

	SetHandCursor( GetControlHandle( "Label_1", "Form_2" ) )

	Form_2.Button_1.Enabled := ( Len(aList) > 0 )
	Form_2.ComboEx_1.Enabled := ( Len(aList) > 0 )
	Form_2.Radio_1.Enabled := ( Len(aList) > 0 )

	IF lOnTop
		SetWindowPos( GetFormHandle( 'Form_2' ), -1, 0, 0, 0, 0, 3 )
	ENDIF

	ACTIVATE WINDOW Form_2

Return

#define SM_CYMINSPACING         48
*--------------------------------------------------------*
Procedure ResizeForm()
*--------------------------------------------------------*
Local FormHandle, Width, Height
Local n := Form_2.ComboEx_1.Value

	IF n > 0

		FormHandle := aList[ n ][ 2 ]
		Width	:= iif(nSize = 1, 640, iif(nSize = 2, 800, iif(nSize = 3, 1024, nDefaultWidth )))
		Height	:= iif(nSize = 1, 480, iif(nSize = 2, 600, iif(nSize = 3, 768, nDefaultHeight )))

		IF IsIconic( FormHandle )
			_Restore( FormHandle )
		ENDIF

        	MoveWindow( FormHandle, 0, 0, Width, Height, .t. )

		IF lCenter
			C_Center( FormHandle )
		ENDIF

		IF lStart
			Height -= GetSystemMetrics( SM_CYMINSPACING )
			SetWindowHeight( FormHandle, Height )
		ENDIF

		SetForegroundWindow( GetFormHandle( 'Form_2' ) )

	ENDIF

Return

*--------------------------------------------------------*
Procedure SetWindowHeight( hWnd, nHeight )
*--------------------------------------------------------*
Local aRect := { 0, 0, 0, 0 }

	GetWindowRect( hWnd, aRect )

	MoveWindow( hWnd, aRect[1], aRect[2], aRect[3] - aRect[1], nHeight, .t. )

Return

*--------------------------------------------------------*
Procedure ChangeSize()
*--------------------------------------------------------*
Local aLabels, aInitValues, aFormats

	nDefaultWidth	:= iif(EMPTY(nDefaultWidth), GetDesktopWidth(), nDefaultWidth)
	nDefaultHeight	:= iif(EMPTY(nDefaultHeight), GetDesktopHeight(), nDefaultHeight)

	aLabels		:= { '&Width:', '&Height:' }
	aInitValues	:= { nDefaultWidth, nDefaultHeight }
	aFormats	:= { 6, 6 }

	aResults 	:= SizeInputWindow( "Custom size", aLabels, aInitValues, aFormats )

	If aResults[1] # Nil

		nDefaultWidth	:= iif(aResults[1] > 2000, 2000, aResults[1])
		nDefaultHeight	:= iif(aResults[2] > 2000, 2000, aResults[2])

		Form_2.Radio_1.Caption(4) := NTRIM( nDefaultWidth ) + 'x' + NTRIM( nDefaultHeight )

	EndIf

Return

*--------------------------------------------------------*
Procedure RestoreForm()
*--------------------------------------------------------*
Local FormHandle := GetFormHandle( 'Form_2' )

	IF IsWindowVisible( FormHandle )
		SetForegroundWindow( FormHandle )
	ELSE
		Form_2.Restore ; Form_2.Show
	ENDIF

Return

*--------------------------------------------------------*
Procedure SavePosition()
*--------------------------------------------------------*

	BEGIN INI FILE cFileIni

		SET SECTION "Form" ENTRY "Top" TO Form_2.Row
		SET SECTION "Form" ENTRY "Left" TO Form_2.Col

		SET SECTION "Size" ENTRY "Default" TO nSize

		SET SECTION "CustomSize" ENTRY "Width" TO IF(EMPTY(nDefaultWidth), GetDesktopWidth(), nDefaultWidth)
		SET SECTION "CustomSize" ENTRY "Height" TO IF(EMPTY(nDefaultHeight), GetDesktopHeight(), nDefaultHeight)

	END INI

Return

*--------------------------------------------------------*
Procedure Options()
*--------------------------------------------------------*
Local aMessages := {}

	aAdd(aMessages, ;
		"Specify the text that appears in the title bar of your browser" + CRLF + ;
		"window. By default we have added the most common, Internet" + CRLF + ;
		"Explorer and Netscape. You can add/edit/delete the title bar" + CRLF + ;
		"captions below. Remember, they are case sensitive.")

	aAdd(aMessages, "Not sure what the title bar caption is?")

	aAdd(aMessages, ;
		"Open your browser and go to any website. The text that appears" + CRLF + ;
		"after the website title is the caption of the window. Enter that text" + CRLF + ;
		"in the box above. In our example it is   - Microsoft Internet Explorer")

	DEFINE WINDOW Form_3 ;
		AT 0, 0 ;
		WIDTH 360 HEIGHT IF(IsXPThemeActive(), 426, 420) ;
		TITLE 'Options' ;
		ICON 'MAIN' ;
		MODAL NOSIZE ;
		ON RELEASE SetHandCursor( GetControlHandle( "Label_1", "Form_2" ) ) ;
		FONT "MS Sans Serif" SIZE 9

		@ 5,8 FRAME Frame_1 ;
			CAPTION 'Options' ;
			WIDTH Form_2.Width - 100 ;
			HEIGHT 115

		@ 18,24 CHECKBOX Check_1 ; 
			CAPTION 'Center &browser on screen after resize' ; 
			WIDTH 200 ; 
			HEIGHT 23 ; 
			VALUE lCenter ; 
			TOOLTIP 'After resizing, center the browser on your screen' ;
			ON CHANGE lCenter := Form_3.Check_1.Value

		@ 42,24 CHECKBOX Check_2 ; 
			CAPTION '&Include Start Menu height in resize' ; 
			WIDTH 200 ; 
			HEIGHT 23 ; 
			VALUE lStart ; 
			TOOLTIP 'When resizing account for the Windows Taskbar' ;
			ON CHANGE lStart := Form_3.Check_2.Value

		@ 66,24 CHECKBOX Check_3 ; 
			CAPTION 'Au&tomatically refresh for new browsers' ; 
			WIDTH 200 ; 
			HEIGHT 23 ; 
			VALUE lAutoRefresh ; 
			TOOLTIP 'Automatically Refresh for new browsers' ;
			ON CHANGE lAutoRefresh := Form_3.Check_3.Value

		@ 90,24 CHECKBOX Check_4 ; 
			CAPTION '&Stay on top of all other windows' ; 
			WIDTH 200 ; 
			HEIGHT 23 ; 
			VALUE lOnTop ; 
			TOOLTIP 'Try and stay on top of all other windows' ;
			ON CHANGE lOnTop := Form_3.Check_4.Value

		@ 125,8 FRAME Frame_2 ;
			CAPTION 'Application Configuration' ;
			WIDTH Form_2.Width - 10 ;
			HEIGHT 264

		@ 200,16 GRID Grid_1 ;
			WIDTH 232 ;
			HEIGHT 58 ;
			WIDTHS { IF(Len(aSearch) > 3, 211, 227) }	;
			FONT "MS Sans Serif" ;
			SIZE 7 ;
			EDIT ;
			INPLACE {} ;
			NOLINES NOHEADERS

		@ 142,16 LABEL Label_1 ;
			WIDTH 300 ;
			HEIGHT 54 ;
			VALUE aMessages[1]

		@ 264,16 LABEL Label_2 ;
			AUTOSIZE ;
			VALUE aMessages[2]

		@ 280,16 LABEL Label_3 ;
			WIDTH 310 ;
			HEIGHT 40 ;
			VALUE aMessages[3]

		@ 200,Form_2.Width - 84 LABEL Label_4 ;
			AUTOSIZE ;
			VALUE 'Ins = Add/Insert'

		@ 216,Form_2.Width - 84 LABEL Label_5 ;
			AUTOSIZE ;
			VALUE 'F2 = Edit'

		@ 232,Form_2.Width - 84 LABEL Label_6 ;
			AUTOSIZE ;
			VALUE 'Del = Delete'

		@ 328,46 IMAGE Image_1 ;
			PICTURE 'TITLE' ;
			WIDTH 253 ;
			HEIGHT 54

		@ 8, Form_2.Width - 80 BUTTONEX Button_1 ;
			CAPTION '&Save' ;
			ACTION ( SaveOptions(), ThisWindow.Release ) ;
			TOOLTIP 'Save changes' ;
			WIDTH 74 ;
			HEIGHT 24

		@ 40, Form_2.Width - 80 BUTTONEX Button_2 ;
			CAPTION '&Cancel' ;
			ACTION ThisWindow.Release ;
			TOOLTIP 'Cancel changes' ;
			WIDTH 74 ;
			HEIGHT 24

		ON KEY INSERT ACTION AddRow()
		ON KEY F2 ACTION EditRow()
		ON KEY DELETE ACTION DelRow()

	END WINDOW

	SetArrowCursor( GetControlHandle( "Label_1", "Form_3" ) )

	Aeval( aSearch, {|e| Form_3.Grid_1.AddItem( {e} ) } )

	IF lOnTop
		SetWindowPos( GetFormHandle( "Form_3" ), -1, 0, 0, 0, 0, 3 )
	ENDIF

	_MyCenterWindow( "Form_3" )

	IF Form_3.Row < 0
		Form_3.Row := 0
	ENDIF

	IF Form_3.Col < 0
		Form_3.Col := 0
	ENDIF

	ACTIVATE WINDOW Form_3

Return

*--------------------------------------------------------*
Procedure AddRow()
*--------------------------------------------------------*

	IF Form_3.FocusedControl == 'Grid_1'
		Form_3.Grid_1.AddItem( {""} )
		Form_3.Grid_1.Value := Form_3.Grid_1.ItemCount
		IF Form_3.Grid_1.Value > 3 .AND. Form_3.Grid_1.ColumnWidth(1) # 211
			Form_3.Grid_1.ColumnWidth(1) := 211
		ENDIF
		keybd_enter()
	ENDIF

Return

*--------------------------------------------------------*
Procedure EditRow()
*--------------------------------------------------------*

	IF Form_3.FocusedControl == 'Grid_1'
		keybd_enter()
	ENDIF

Return

*--------------------------------------------------------*
Procedure DelRow()
*--------------------------------------------------------*
Local nVal := Form_3.Grid_1.Value

	IF Form_3.FocusedControl == 'Grid_1' .AND. !Empty(nVal)
		Form_3.Grid_1.DeleteItem( nVal )
		Form_3.Grid_1.Value := IF( nVal > 1, nVal - 1, 1 )
		IF Form_3.Grid_1.ItemCount < 4 .AND. Form_3.Grid_1.ColumnWidth(1) # 227
			Form_3.Grid_1.ColumnWidth(1) := 227
		ENDIF
	ENDIF

Return

*--------------------------------------------------------*
Procedure SaveOptions()
*--------------------------------------------------------*
Local i, aItem

	aSearch := {}

	For i := 1 To Form_3.Grid_1.ItemCount
		aItem := Form_3.Grid_1.Item( i )
		IF !Empty( aItem[1] )
			aAdd( aSearch, aItem[1] )
		ENDIF
	Next

	BEGIN INI FILE cFileIni

		SET SECTION "Options" ENTRY "Center" TO lCenter
		SET SECTION "Options" ENTRY "Start" TO lStart
		SET SECTION "Options" ENTRY "OnTop" TO lOnTop
		SET SECTION "Options" ENTRY "AutoRefresh" TO lAutoRefresh

		SET SECTION "Search" ENTRY "Default" TO aSearch

	END INI

	IF IsControlDefined( Timer_1, Form_2 )
		Form_2.Timer_1.Release
	ENDIF

	RefreshApps()

	IF lAutoRefresh
		DEFINE TIMER Timer_1 OF Form_2 INTERVAL 10000 ACTION RefreshApps()
	ENDIF

	SetWindowPos( GetFormHandle( 'Form_2' ), IF( lOnTop, -1, -2 ), 0, 0, 0, 0, 3 )

Return

*--------------------------------------------------------*
Procedure RefreshApps()
*--------------------------------------------------------*
Local aTitles := GetTitles( _HMG_MainHandle )
Local aItems := {}, nItem, cSearch, n

	aList := {}

	IF Len(aTitles) > 0

		For nItem := 1 To Len(aSearch)
			cSearch := aSearch[ nItem ]
			WHILE ( n := aScan( aTitles, {|e| cSearch $ e[1] } ) ) > 0
				aAdd( aList, { aTitles[ n ][ 1 ], aTitles[ n ][ 2 ] } )
				aDel( aTitles, n )
				aSize( aTitles, Len(aTitles) - 1 )
			END
		Next

	ENDIF

	IF IsWindowDefined( Form_2 )

		Form_2.ComboEx_1.DeleteAllItems

		IF Len(aList) > 0
			Aeval( aList, {|e| Aadd( aItems, { e[1], ;
				iif("Internet Explorer" $ e[1], 1, iif("Netscape" $ e[1], 2, ;
				iif("Mozilla" $ e[1], 3, 4))) } ) } )

			Aeval( aItems, {|e| Form_2.ComboEx_1.AddItem( e[1], e[2] ) } )
			Form_2.ComboEx_1.Value := 1
		ENDIF

		Form_2.Button_1.Enabled := ( Len(aList) > 0 )
		Form_2.ComboEx_1.Enabled := ( Len(aList) > 0 )
		Form_2.Radio_1.Enabled := ( Len(aList) > 0 )

	ENDIF

Return

*--------------------------------------------------------*
Function GetTitles( hOwnWnd )
*--------------------------------------------------------*
Local aTasks := {}, cTitle, ;
	hWnd := GetWindow( hOwnWnd, GW_HWNDFIRST )        // Get the first window

	WHILE hWnd != 0                                   // Loop through all the windows

		cTitle := GetWindowText( hWnd )

		IF GetWindow( hWnd, GW_OWNER ) = 0 .AND.;  // If it is an owner window
			IsWindowVisible( hWnd ) .AND.;      // If it is a visible window
			hWnd != hOwnWnd .AND.;              // If it is not this app
			!EMPTY( cTitle ) .AND.;             // If the window has a title
			!( "DOS Session" $ cTitle ) .AND.;  // If it is not DOS session
			!( cTitle == "Program Manager" )    // If it is not the Program Manager

			aAdd( aTasks, { cTitle, hWnd } )
		ENDIF

		hWnd := GetWindow( hWnd, GW_HWNDNEXT )     // Get the next window
	ENDDO

Return ( aTasks )

*--------------------------------------------------------*
Function SizeInputWindow( Title, aLabels, aValues, aFormats )
*--------------------------------------------------------*
Local i, l, ControlRow := 8, LN, CN

	l := Len( aLabels )

	aResult := Array(l)

	DEFINE WINDOW _InputWindow ;
		AT 0,0 ;
		WIDTH 209 ;
		HEIGHT IF(IsXPThemeActive(), 101, 95) ;
		TITLE Title ;
		ICON "MAIN" ;
		MODAL ;
		NOSIZE ;
		ON RELEASE SetHandCursor( GetControlHandle( "Label_1", "Form_2" ) ) ;
		FONT 'MS Sans Serif' ; 
		SIZE 9

		For i := 1 to l

			LN := 'Label_' + NTRIM(i)
			CN := 'Control_' + NTRIM(i)

			@ ControlRow + 4, 15 LABEL &LN VALUE aLabels[i] AUTOSIZE

			do case

			case ValType ( aValues [i] ) == 'N'

				If ValType ( aFormats [i] ) == 'N'
					If  i == l
						@ ControlRow, 65 TEXTBOX &CN ;
						VALUE aValues[i] WIDTH 40 HEIGHT 21 ; 
						MAXLENGTH aFormats[i] ;
						NUMERIC RIGHTALIGN ;
						ON ENTER _InputWindowOk()
					Else
						@ ControlRow, 65 TEXTBOX &CN ;
						VALUE aValues[i] WIDTH 40 HEIGHT 21 ;
						MAXLENGTH aFormats[i] ;
						NUMERIC RIGHTALIGN ;
						ON ENTER _InputWindow.Control_2.Setfocus

						ControlRow := ControlRow + 25
					EndIf
				EndIf

			endcase

		Next i

		@ 09, 122 BUTTONEX Button_1 ;
		OF _InputWindow ;
		CAPTION '&Save' ;
		ACTION _InputWindowOk() ;
		WIDTH 74 ;
		HEIGHT 24

		@ 40, 122 BUTTONEX Button_2 ;
		OF _InputWindow ;
		CAPTION '&Cancel' ;
		ACTION _InputWindowCancel() ;
		WIDTH 74 ;
		HEIGHT 24

	END WINDOW

	IF lOnTop
		SetWindowPos( GetFormHandle( '_InputWindow' ), -1, 0, 0, 0, 0, 3 )
	ENDIF

	SetArrowCursor( GetControlHandle( "Label_1", "_InputWindow" ) )

	_InputWindow.Control_1.SetFocus

	CENTER WINDOW _InputWindow

	ACTIVATE WINDOW _InputWindow

Return ( aResult )

*--------------------------------------------------------*
Function _MyCenterWindow( FormName )
*--------------------------------------------------------*
Local FormHandle := GetFormHandle ( FormName )
Local ParentHandle := GetFormHandle ( 'Form_2' )
Local nPos, nColMain, nRowMain, nWidthMain, nHeightMain, lCentered := .F.

If FormHandle # ParentHandle

   If ( ( nPos := aScan ( _HMG_aFormHandles, ParentHandle ) ) > 0 )

      nColMain	  := GetProperty ( _HMG_aFormNames[ nPos ] , 'Col' )
      nRowMain	  := GetProperty ( _HMG_aFormNames[ nPos ] , 'Row' )
      nWidthMain  := GetProperty ( _HMG_aFormNames[ nPos ] , 'Width' )
      nHeightMain := GetProperty ( _HMG_aFormNames[ nPos ] , 'Height' )

      SetProperty ( FormName, 'Col', nColMain + Int ( ( nWidthMain  - GetProperty ( FormName , 'Width' )  ) / 2 ) )
      SetProperty ( FormName, 'Row', nRowMain + Int ( ( nHeightMain - GetProperty ( FormName , 'Height' ) ) / 2 ) )
      
      lCentered := .T.

   Endif
    
Endif

If !lCentered
   C_Center( FormHandle )
Endif

Return Nil


#pragma BEGINDUMP

#define _WIN32_WINNT   0x0400

#include <windows.h>
#include "hbapi.h"

HB_FUNC( ISICONIC )
{
	hb_retl( IsIconic( ( HWND ) hb_parnl( 1 ) ) );
}

HB_FUNC( KEYBD_ENTER )
{
	keybd_event(
		VK_RETURN,	// virtual-key code
		0,		// hardware scan code
		0,		// flags specifying various function options
		0		// additional data associated with keystroke
	);
}

#if ! defined( __MINGW32__ )

HB_FUNC ( MENUITEM_SETBITMAPS )
{
	HWND himage1;
	HWND himage2;

	himage1 = (HWND) LoadImage( GetModuleHandle(NULL), hb_parc(3), IMAGE_BITMAP, 13, 13, LR_LOADMAP3DCOLORS | LR_LOADTRANSPARENT );
	if ( himage1 == NULL )
	{
		himage1 = (HWND) LoadImage( 0, hb_parc(3), IMAGE_BITMAP, 13, 13, LR_LOADFROMFILE | LR_LOADMAP3DCOLORS | LR_LOADTRANSPARENT );
	}

	himage2 = (HWND) LoadImage( GetModuleHandle(NULL), hb_parc(4), IMAGE_BITMAP, 13, 13, LR_LOADMAP3DCOLORS | LR_LOADTRANSPARENT );
	if ( himage2 == NULL )
	{
		himage2 = (HWND) LoadImage( 0, hb_parc(4), IMAGE_BITMAP, 13, 13, LR_LOADFROMFILE | LR_LOADMAP3DCOLORS | LR_LOADTRANSPARENT );
	}

	SetMenuItemBitmaps( (HMENU) hb_parnl(1) , hb_parni(2), MF_BYCOMMAND , (HBITMAP) himage1 , (HBITMAP) himage2 ) ;
}

HB_FUNC ( INITIMAGE )
{
	HWND  h;
	HBITMAP hBitmap;
	HWND hwnd;

	hwnd = (HWND) hb_parnl (1);

	h = CreateWindowEx(0,"static",NULL,
	WS_CHILD | WS_VISIBLE | SS_BITMAP | SS_NOTIFY,
	hb_parni(3), hb_parni(4), 0, 0,
	hwnd,(HMENU)hb_parni(2) , GetModuleHandle(NULL) , NULL ) ;

	hBitmap = (HBITMAP)LoadImage(0,hb_parc(5),IMAGE_BITMAP,hb_parni(6),hb_parni(7),LR_LOADFROMFILE|LR_CREATEDIBSECTION);
	if (hBitmap==NULL)
	{
		hBitmap = (HBITMAP)LoadImage(GetModuleHandle(NULL),hb_parc(5),IMAGE_BITMAP,hb_parni(6),hb_parni(7),LR_CREATEDIBSECTION);
	}


	SendMessage(h,(UINT)STM_SETIMAGE,(WPARAM)IMAGE_BITMAP,(LPARAM)hBitmap);

	hb_retnl ( (LONG) h );
}

HB_FUNC ( C_SETPICTURE )
{
	HBITMAP hBitmap;

	hBitmap = (HBITMAP)LoadImage(0,hb_parc(2),IMAGE_BITMAP,hb_parni(3),hb_parni(4),LR_LOADFROMFILE|LR_CREATEDIBSECTION);
	if (hBitmap==NULL)
	{
		hBitmap = (HBITMAP)LoadImage(GetModuleHandle(NULL),hb_parc(2),IMAGE_BITMAP,hb_parni(3),hb_parni(4),LR_CREATEDIBSECTION);
	}

	SendMessage((HWND) hb_parnl (1),(UINT)STM_SETIMAGE,(WPARAM)IMAGE_BITMAP,(LPARAM)hBitmap);

       hb_retnl ( (LONG) hBitmap );
}
#endif

#pragma ENDDUMP
