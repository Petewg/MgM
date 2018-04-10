/*
 * MINIGUI - Harbour Win32 GUI library Demo
 *
 * Copyright 2002-2010 Roberto Lopez <harbourminigui@gmail.com>
 * http://harbourminigui.googlepages.com/
 *
 * Copyright 2006-2010 Grigory Filatov <gfilatov@inbox.ru>
*/
ANNOUNCE RDDSYS

#include "minigui.ch"

#define PROGRAM 'Advanced Shell for UPX v.2.1'
#define COPYRIGHT ' Grigory Filatov, 2006-2010'

#define MsgStop( c )	MsgStop( c, "Error", , .f. )
#define MsgAlert( c )	MsgEXCLAMATION( c, PROGRAM, , .f. )
#define NTRIM( n )	LTrim( Str( n ) )
#define CLR_DBLUE	{  0,   0, 128 }

#define MAKE_UPX

#ifdef MAKE_UPX
	Set Proc To makefile.prg
#endif

Memvar cCfgFile

Procedure Main( cFileIn )
Local cFile := "", nLevel := 7, nMethod := 1, nMemUse := 1, ;
	lExports := .T., lStrip := .T., lResources := .F., ;
	nIcons := 3, cUser := "--backup", lConsole := .T.

	SET MULTIPLE OFF WARNING
	SET CENTERWINDOW RELATIVE PARENT

	PUBLIC cCfgFile := GetStartUpFolder() + "\upxshell.ini"

	IF File(cCfgFile)
		BEGIN INI FILE cCfgFile
			GET cFile SECTION "Config" ENTRY "File" DEFAULT cFile
			GET nLevel SECTION "Config" ENTRY "Level" DEFAULT nLevel
			GET nMethod SECTION "Config" ENTRY "Method" DEFAULT nMethod
			GET nMemUse SECTION "Config" ENTRY "MemUse" DEFAULT nMemUse
			GET lExports SECTION "Config" ENTRY "Exports" DEFAULT lExports
			GET lStrip SECTION "Config" ENTRY "Strip" DEFAULT lStrip
			GET lResources SECTION "Config" ENTRY "Resources" DEFAULT lResources
			GET nIcons SECTION "Config" ENTRY "Icons" DEFAULT nIcons
			GET cUser SECTION "Config" ENTRY "User" //DEFAULT cUser
			GET lConsole SECTION "Config" ENTRY "Console" DEFAULT lConsole
		END INI
	ENDIF

	IF ValType(cFileIn) == "C" .AND. File(cFileIn)
		cFile := cFileIn
	ENDIF

	DEFINE WINDOW Form_1 ;
		AT 0, 0 ;
		WIDTH 509 HEIGHT 295 + IF(IsXPThemeActive(), 8, 0) ;
		TITLE PROGRAM ;
		ICON "IDI_MAIN" ;
		MAIN ;
		NOMAXIMIZE NOSIZE ;
		ON RELEASE SaveConfig() ;
		FONT 'MS Sans Serif'	;
		SIZE 9

		BuildMainMenu()	

		DEFINE SPLITBOX

			DEFINE TOOLBAR ToolBar_1 ;
				BUTTONSIZE 16, 16 ;
				FLAT

			BUTTON TB1_Button_1 ;
				PICTURE 'IDB_OPEN' ;
				TOOLTIP 'Open File (Ctrl+O)' ;
				ACTION OpenFile() SEPARATOR

			BUTTON TB1_Button_2 ;
				PICTURE 'IDB_PACK' ;
				TOOLTIP 'Compress (F9)' ;
				ACTION CompressFile()

			BUTTON TB1_Button_3 ;
				PICTURE 'IDB_UNPACK' ;
				TOOLTIP 'Decompress' ;
				ACTION UnCompressFile() SEPARATOR

			BUTTON TB1_Button_4 ;
				PICTURE 'IDB_INFO' ;
				TOOLTIP 'About (F1)' ;
				ACTION MsgAbout()

	      		END TOOLBAR

		END SPLITBOX

	       @ 40,8 LABEL Label_1			;
			VALUE 'File:'			;
			AUTOSIZE

	       @ 72,8 LABEL Label_2			;
			VALUE 'Compression Level:'	;
			AUTOSIZE

	       @104,8 LABEL Label_3			;
			VALUE 'Compression Method:'	;
			AUTOSIZE

	       @136,8 LABEL Label_4			;
			VALUE 'Memory Usage:'		;
			AUTOSIZE

	       @168,8 LABEL Label_5			;
			VALUE 'User Options:'		;
			AUTOSIZE

		@ 38,40 TEXTBOX Text_1			;
			VALUE cFile			;
			WIDTH 393			;
			HEIGHT 20

		@ 36,440 BUTTONEX Btn_1 ;
			CAPTION 'Open' ; 
			PICTURE 'IDB_OPEN' ;
			ACTION OpenFile() ; 
			WIDTH 57 ; 
	       	     	HEIGHT 24 ;
			TOOLTIP 'Open File (Ctrl+O)' ;
			FLAT

		@ 166,88 TEXTBOX Text_2			;
			VALUE cUser			;
			WIDTH 113			;
			HEIGHT 20

		@ 68,120 COMBOBOX Combo_1		;
			WIDTH 81 HEIGHT 120		;
			ITEMS { '1',			;
				'2',			;
				'3',			;
				'4',			;
 				'5',			;
				'6',			;
				'7',			;
				'8',			;
				'9',			;
				'-best' }		;
			VALUE nLevel

		@100,120 COMBOBOX Combo_2		;
			WIDTH 81 HEIGHT 120		;
			ITEMS { 'default',		;
				'-all-methods',		;
				'-all-filters',		;
				'-brute' }		;
			VALUE nMethod

		@132,120 COMBOBOX Combo_3		;
			WIDTH 81 HEIGHT 120		;
			ITEMS { '10000',		;
				'100000',		;
				'200000',		;
				'400000',		;
				'600000',		;
				'800000',		;
				'999999' }		;
			VALUE nMemUse

		@ 70,224 CHECKBOX Check_1 ; 
			CAPTION 'Compress the Export Section' ; 
			WIDTH 225 ; 
			HEIGHT 16 ; 
			VALUE lExports

		@ 94,224 CHECKBOX Check_2 ; 
			CAPTION 'Strip Relocation Records' ; 
			WIDTH 225 ; 
			HEIGHT 16 ; 
			VALUE lStrip

		@116,224 CHECKBOX Check_3 ; 
			CAPTION "Don't Compress Any Resources" ; 
			WIDTH 225 ; 
			HEIGHT 16 ; 
			VALUE lResources

		@204,8 CHECKBOX Check_4 ; 
			CAPTION 'Show UPX Console' ; 
			WIDTH 177 ; 
			HEIGHT 16 ; 
			VALUE lConsole

		@140,224 FRAME Frame_1 ;
			CAPTION 'Icons Compression' ; 
			WIDTH 273 ; 
			HEIGHT 87

		@153,232 RADIOGROUP Radio_1 ;
			OPTIONS { "Don't compress any icons", ;
				'Compress all but the first icon', ;
				'Compress all which are not in the first icon directory' } ; 
			WIDTH 260 ;
			SPACING 22 ;
			VALUE nIcons

		DEFINE STATUSBAR FONT 'Tahoma' SIZE 9 BOLD
			STATUSITEM "" DEFAULT
		END STATUSBAR

		ON KEY CONTROL+O ACTION OpenFile()
		ON KEY CONTROL+X ACTION ReleaseAllWindows()
		ON KEY F1 ACTION MsgAbout()
		ON KEY F9 ACTION CompressFile()

	END WINDOW

	CENTER WINDOW Form_1

	ACTIVATE WINDOW Form_1

Return

*--------------------------------------------------------*
Procedure BuildMainMenu()
*--------------------------------------------------------*

DEFINE MAIN MENU OF Form_1

	DEFINE POPUP "&File"
		MENUITEM "&Open"+Chr(9)+"Ctrl+O" ACTION OpenFile() IMAGE "IDB_OPEN"
		SEPARATOR 
		MENUITEM "E&xit"+Chr(9)+"Ctrl+X" ACTION ReleaseAllWindows()
	END POPUP

	DEFINE POPUP "&UPX"
		MENUITEM "&Compress"+Chr(9)+"F9" ACTION CompressFile() IMAGE "IDB_PACK"
		MENUITEM "&Decompress" ACTION UnCompressFile() IMAGE "IDB_UNPACK"
	END POPUP

	DEFINE POPUP "&Help"
		MENUITEM "&About"+Chr(9)+"F1" ACTION MsgAbout() IMAGE "IDB_INFO"
	END POPUP

END MENU

Return

*--------------------------------------------------------*
Procedure OpenFile()
*--------------------------------------------------------*
Local cFilter := { ;
	{'All Supported Files', '*.exe; *.dll; *.scr'}, ;
	{'Executable Files', '*.exe'}, ;
	{'Dinamic Link Libraries', '*.dll'}, ;
	{'Screen Savers', '*.scr'}, ;
	{'All Files', '*.*'} }
Local cFile := Form_1.Text_1.Value, cFocused := Form_1.FocusedControl

	cFile := GetFile( cFilter, NIL, IF( Empty(cFile), NIL, cFilePath(cFile) ), .F., .T. )

	IF !Empty(cFile)
		Form_1.Text_1.Value := cFile
		DoMethod( 'Form_1', cFocused, 'SetFocus' )
	ENDIF

Return

*--------------------------------------------------------*
Procedure CompressFile()
*--------------------------------------------------------*
Local cParam := ""
Local cFile := Form_1.Text_1.Value, ;
	nLevel := Form_1.Combo_1.Value, ;
	nMethod := Form_1.Combo_2.Value, ;
	nMemUse := Form_1.Combo_3.Value, ;
	lExports := Form_1.Check_1.Value, ;
	lStrip := Form_1.Check_2.Value, ;
	lResources := Form_1.Check_3.Value, ;
	nIcons := Form_1.Radio_1.Value, ;
	cUser := Form_1.Text_2.Value, ;
	lConsole := Form_1.Check_4.Value

	cParam += "-" + IF(nLevel <= 9, NTRIM(nLevel), Form_1.Combo_1.Item(nLevel)) + " "
	cParam += IF(nMethod == 1, "", "-" + Form_1.Combo_2.Item(nMethod) + " ")
	cParam += IF(nMethod < 4, "--crp-ms=" + Form_1.Combo_3.Item(nMemUse) + " ", "")
	cParam += IF(Empty(cUser), "", cUser + " ")
	IF !lExports
		cParam += "--compress-exports=0 "
	ENDIF
	IF !lStrip
		cParam += "--strip-relocs=0 "
	ENDIF
	IF lResources
		cParam += "--compress-resources=0 "
	ELSE
		cParam += "--compress-icons=" + NTRIM(nIcons - 1) + " "
	ENDIF

	IF Empty( cFile )
		MsgStop( "You should enter the file name." )
	ELSE
		RunUPX( cParam + cFile, IF(lConsole, 1, 0) )
	ENDIF

Return

*--------------------------------------------------------*
Procedure UnCompressFile()
*--------------------------------------------------------*
Local cFile := Form_1.Text_1.Value
Local lConsole := Form_1.Check_4.Value

	IF Empty( cFile )
		MsgStop( "You should enter the file name." )
	ELSE
		RunUPX( "-d " + cFile, IF(lConsole, 1, 0) )
	ENDIF

Return

*--------------------------------------------------------*
Function RunUPX( cParam, nShow )
*--------------------------------------------------------*
Local cUPXPrg := GetStartUpFolder() + "\upx.exe", nRet := 0

	IF !File( cUPXPrg )
#ifdef MAKE_UPX
		Form_1.Statusbar.Item(1) := "Extract upx.exe, please wait..."
		MkFile( cUPXPrg )
		DO EVENTS
#else
		MsgAlert( "You should place the upx.exe at the program folder!" )
		Return nRet
#endif
	ENDIF
	Form_1.Statusbar.Item(1) := IF("-d" $ cParam, "Dec", "C" ) + "ompress, please wait..."

	nRet := ShellExecute( 0, "open", cUPXPrg, cParam, , nShow )

	inkey(IF("-d" $ cParam, .1, 4 ))
	DO EVENTS

	Form_1.Statusbar.Item(1) := "Done."

Return nRet

*--------------------------------------------------------*
Procedure SaveConfig()
*--------------------------------------------------------*
Local cFile := Form_1.Text_1.Value, ;
	nLevel := Form_1.Combo_1.Value, ;
	nMethod := Form_1.Combo_2.Value, ;
	nMemUse := Form_1.Combo_3.Value, ;
	lExports := Form_1.Check_1.Value, ;
	lStrip := Form_1.Check_2.Value, ;
	lResources := Form_1.Check_3.Value, ;
	nIcons := Form_1.Radio_1.Value, ;
	cUser := Form_1.Text_2.Value, ;
	lConsole := Form_1.Check_4.Value

   BEGIN INI FILE cCfgFile
	SET SECTION "Config" ENTRY "File" TO cFile
	SET SECTION "Config" ENTRY "Level" TO nLevel
	SET SECTION "Config" ENTRY "Method" TO nMethod
	SET SECTION "Config" ENTRY "MemUse" TO nMemUse
	SET SECTION "Config" ENTRY "Exports" TO lExports
	SET SECTION "Config" ENTRY "Strip" TO lStrip
	SET SECTION "Config" ENTRY "Resources" TO lResources
	SET SECTION "Config" ENTRY "Icons" TO nIcons
	SET SECTION "Config" ENTRY "User" TO cUser
	SET SECTION "Config" ENTRY "Console" TO lConsole
   END INI

Return

*--------------------------------------------------------*
Static Procedure MsgAbout()
*--------------------------------------------------------*
Local cUPXLink := "http://upx.sourceforge.net/"

	DEFINE WINDOW Form_About ;
		AT 0,0 ;
		WIDTH 311 HEIGHT IF(IsXPThemeActive(), 199, 193) ;
		TITLE "About" ;
		MODAL ;
		NOSYSMENU NOSIZE ;
		FONT 'MS Sans Serif' ;
		SIZE 9

		@ 136,120 BUTTONEX Btn_1 ; 
			CAPTION 'OK' ; 
			ACTION ThisWindow.Release ; 
			WIDTH 75 ; 
			HEIGHT 25 DEFAULT

		@ 16,64 LABEL Label_1			;
			VALUE PROGRAM			;
			AUTOSIZE			;
			FONTCOLOR CLR_DBLUE		;
			FONT 'Times New Roman'		;
			SIZE 12 BOLD

		@ 56,8 LABEL Label_2			;
			VALUE 'Advanced Shell is the shell for UPX version 3.0 or later'	;
			AUTOSIZE

		@ 80,8 LABEL Label_3			;
			VALUE 'Advanced Shell Author:'	;
			AUTOSIZE

		@ 80,144 HYPERLINK Label_4					;
			VALUE SubStr(COPYRIGHT, 2, 15)				;
			ADDRESS "gfilatov@inbox.ru?cc=&bcc=" +		;
				"&subject=UPX%20Shell%20Feedback:" 		;
			AUTOSIZE						;
			TOOLTIP "E-mail me if you have any comments or suggestions" HANDCURSOR

		@ 104,8 LABEL Label_5			;
			VALUE 'UPX Authors:'		;
			AUTOSIZE

		@ 104,88 HYPERLINK Label_6					;
			VALUE 'Markus F.X.J. Oberhumer and Laszlo Molnar'	;
			ADDRESS cUPXLink			 		;
			AUTOSIZE						;
			TOOLTIP cUPXLink HANDCURSOR

			DRAW ICON IN WINDOW Form_About AT 8, 8 ;
				PICTURE "AAA_UPX"

			DRAW LINE IN WINDOW Form_About ;
				AT 128,8 TO 128,297 ;
				PENCOLOR GRAY

			DRAW LINE IN WINDOW Form_About ;
				AT 129,8 TO 129,297 ;
				PENCOLOR WHITE

		ON KEY ESCAPE ACTION ThisWindow.Release

	END WINDOW

	CENTER WINDOW Form_About

	ACTIVATE WINDOW Form_About

Return

*--------------------------------------------------------*
Static function drawline(window,row,col,row1,col1,penrgb,penwidth)
*--------------------------------------------------------*
	Local i := GetFormIndex ( Window )
	Local FormHandle := _HMG_aFormHandles [i]

	if formhandle > 0

		if valtype(penrgb) == "U"
			penrgb := {0,0,0}
		endif
	
		if valtype(penwidth) == "U"
			penwidth := 1
		endif

		linedraw ( formhandle,row,col,row1,col1,penrgb,penwidth )

		aadd ( _HMG_aFormGraphTasks [i] , { || linedraw( formhandle,row,col,row1,col1,penrgb,penwidth ) } )

	endif

Return nil


#pragma BEGINDUMP

#include <windows.h>
#include "hbapi.h"

HB_FUNC( MENUITEM_SETBITMAPS )
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

HB_FUNC( INITIMAGE )
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

HB_FUNC( C_SETPICTURE )
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

#pragma ENDDUMP
