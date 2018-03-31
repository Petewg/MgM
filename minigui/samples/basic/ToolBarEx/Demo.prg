/*
 * MINIGUI - Harbour Win32 GUI library Demo
 *
 * Copyright 2002 Roberto Lopez <harbourminigui@gmail.com>
 * http://harbourminigui.googlepages.com/
*/

#define KON_LIN   chr(13)+chr(10)

#include "minigui.ch"


Function Main

	DEFINE WINDOW Form_1 ;
		AT 0,0 ;
		WIDTH 640 HEIGHT 480 ;
		TITLE 'MiniGUI ToolBar Demo (Based Upon a Contribution Of Janusz Pora)' ;
		ICON 'DEMO.ICO' ;
		MAIN ;
		FONT 'Arial' SIZE 10 

		DEFINE STATUSBAR
			STATUSITEM '[x] Harbour Power Ready!' 
		END STATUSBAR


		DEFINE MAIN MENU 
			POPUP '&File'
				ITEM 'Get ToolBar_3 Button_1'	    ACTION MsgInfo ( if ( Form_1.Button_1c.Value , '.T.' , '.F.' ) , 'Button_1c' )
				ITEM 'Get ToolBar_3 Button_2'	    ACTION MsgInfo ( if ( Form_1.Button_2c.Value , '.T.' , '.F.' ) , 'Button_2c' )
				ITEM 'Get ToolBar_3 Button_3'	    ACTION MsgInfo ( if ( Form_1.Button_3c.Value , '.T.' , '.F.' ) , 'Button_3c' )
				ITEM 'Get ToolBar_3 Button_4'	    ACTION MsgInfo ( if ( Form_1.Button_4c.Value , '.T.' , '.F.' ) , 'Button_4c' )
    			SEPARATOR	
				ITEM 'Set ToolBar_3 Button_1'	    ACTION Form_1.Button_1c.Value := .T. 
				ITEM 'Set ToolBar_3 Button_2'	    ACTION Form_1.Button_2c.Value := .T. 
				ITEM 'Set ToolBar_3 Button_3'	    ACTION Form_1.Button_3c.Value := .T. 
				ITEM 'Set ToolBar_3 Button_4'	    ACTION Form_1.Button_4c.Value := .T. 
		    	SEPARATOR	
				ITEM '&Exit'		ACTION Form_1.Release
			END POPUP
			POPUP '&Help'
				ITEM '&About'		ACTION MsgInfo ("MiniGUI ToolBarEx demo") 
			END POPUP
		END MENU

		DEFINE SPLITBOX 

			DEFINE TOOLBAREX ToolBar_a BUTTONSIZE 42,40 SIZE 7  CAPTION 'Dropdown Button'  FLAT

				BUTTON Button_1a ;
					CAPTION '&Open' ;
					PICTURE 'Btn01.bmp' ;
					TOOLTIP 'Open New File' ;
					ACTION MsgInfo('Click! 1')


				BUTTON Button_2a ;
					CAPTION '&Save' ;
					PICTURE 'Btn04.bmp' ;
					TOOLTIP 'Save file' ;
					WHOLEDROPDOWN 

				BUTTON Button_3a ;
					CAPTION '&Close' ;
					PICTURE 'Btn03.bmp' ;
					TOOLTIP 'Close file without save' ;
					ACTION MsgInfo('Click! 3') DROPDOWN

			END TOOLBAR

			DEFINE TOOLBAREX ToolBar_b BUTTONSIZE 50,40 FONT 'ARIAL' SIZE 7 FLAT CAPTION 'Bootom Text'

				BUTTON Button_1b ;
					CAPTION '&Printer' ;
					PICTURE 'Btn11.bmp' ;
					ACTION MsgInfo('Click! 1') 

				BUTTON Button_2b ;
					CAPTION 'Pre&view' ;
					PICTURE 'Btn12.bmp' ;
					ACTION MsgInfo('Click! 2') ; 
					SEPARATOR

				BUTTON Button_3b ;
					CAPTION '&Copy' ;
					PICTURE 'Btn21.bmp' ;
					ACTION MsgInfo('Click! 3')

				BUTTON Button_4b ;
					CAPTION '&Cut' ;
					PICTURE 'Btn22.bmp' ;
					ACTION MsgInfo('Click! 4')

				BUTTON Button_5b ;
					CAPTION '&Paste' ;
					PICTURE 'Btn23.bmp' ;
					ACTION MsgInfo('Click! 5')

			END TOOLBAR

			DEFINE TOOLBAREX ToolBar_c BUTTONSIZE 25,25 FONT 'ARIAL' SIZE 7  FLAT CAPTION 'Group Button'

				BUTTON Button_1c ;
					TOOLTIP '&New' ;
					PICTURE 'Btn01.bmp' ;
					ACTION _dummy();
					CHECK GROUP

				BUTTON Button_2c ;
					TOOLTIP '&Open' ;
					PICTURE 'Btn02.bmp' ;
					ACTION _dummy(); 
					CHECK GROUP

				BUTTON Button_3c ;
					TOOLTIP '&Close' ;
					PICTURE 'Btn03.bmp' ;
					ACTION _dummy() ;
					SEPARATOR;
					CHECK GROUP

				BUTTON Button_4c ;
					PICTURE 'Btn04.bmp' ;
					TOOLTIP '&Save' ;
					ACTION _dummy() ;
					CHECK 

			END TOOLBAR

			DEFINE TOOLBAREX ToolBar_d BUTTONSIZE 25,25  CAPTION 'Mixed Buttons' FLAT RIGHTTEXT MIXEDBUTTONS

				BUTTON Button_1d ;
					CAPTION '&Undo' ;
					PICTURE 'Btn31.bmp' ;
					TOOLTIP 'Undo last change' ;
					ACTION MsgInfo('Click! 1')

				BUTTON Button_2d ;
					PICTURE 'Btn33.bmp' ;
					TOOLTIP 'Save file' ;
					ACTION MsgInfo('Click! 2')

				BUTTON Button_3d ;
					CAPTION '&Redo' ;
					PICTURE 'Btn32.bmp' ;
					TOOLTIP 'Redo last change' ;
					ACTION MsgInfo('Click! 3') 

			END TOOLBAR

			DEFINE TOOLBAREX ToolBar_e BUTTONSIZE 25,25 SIZE 7  CAPTION 'Two Rows Button' ROWS 2 BREAK

				BUTTON Button_1e ;
					TOOLTIP '&New' ;
					PICTURE 'Btn01.bmp' ;
					ACTION _dummy();

				BUTTON Button_2e ;
					TOOLTIP '&Open' ;
					PICTURE 'Btn02.bmp' ;
					ACTION _dummy(); 

				BUTTON Button_3e ;
					TOOLTIP '&Close' ;
					PICTURE 'Btn03.bmp' ;
					ACTION _dummy() ;

				BUTTON Button_4e ;
					PICTURE 'Btn04.bmp' ;
					TOOLTIP '&Save' ;
					ACTION _dummy() 

				BUTTON Button_5e ;
					PICTURE 'Btn21.bmp' ;
					TOOLTIP '&Copy' ;
					ACTION _dummy() 

				BUTTON Button_6e ;
					PICTURE 'Btn22.bmp' ;
					TOOLTIP '&Cut' ;
					ACTION _dummy() 

				BUTTON Button_7e ;
					PICTURE 'Btn23.bmp' ;
					TOOLTIP '&Paste' ;
					ACTION _dummy() 

			END TOOLBAR

			DEFINE TOOLBAREX ToolBar_f BUTTONSIZE 50,50 CAPTION 'Centered Bitmap' 

				BUTTON Button_1f ;
					TOOLTIP '&Open' ;
					PICTURE 'Btn02.bmp' ;
					ACTION _dummy();

				BUTTON Button_2f ;
					TOOLTIP '&Save' ;
					PICTURE 'Btn04.bmp' ;
					ACTION _dummy(); 

			END TOOLBAR

			DEFINE TOOLBAREX ToolBar_g BUTTONSIZE 50,50 CAPTION 'Adjust Bitmap' 

				BUTTON Button_1g ;
					TOOLTIP '&Open' ;
					PICTURE 'Btn02.bmp' ;
					ACTION _dummy();
					ADJUST

				BUTTON Button_2g ;
					TOOLTIP '&Save' ;
					PICTURE 'Btn04.bmp' ;
					ACTION _dummy(); 
					ADJUST

			END TOOLBAR

			DEFINE TOOLBAREX ToolBar_m BUTTONSIZE 35,40 FONT 'ARIAL' SIZE 7 FLAT CAPTION 'Hiden Buttons 1 with Chevron' TOOLBARSIZE 70 BREAK

				BUTTON Button_1m ;
					CAPTION '&New' ;
					PICTURE 'Btn01.bmp' ;
					ACTION MsgInfo('Click! 1') 

				BUTTON Button_2m ;
					CAPTION '&Open' ;
					PICTURE 'Btn02.bmp' ;
					TOOLTIP 'Open file';
					ACTION MsgInfo('Click! 2')

				BUTTON Button_3m ;
					CAPTION '&Close' ;
					PICTURE 'Btn03.bmp' ;
					ACTION MsgInfo('Click! 3')

				BUTTON Button_4m ;
					CAPTION '&Save' ;
					PICTURE 'Btn04.bmp' ;
					ACTION MsgInfo('Click! 4') ; 
					SEPARATOR 

				BUTTON Button_5m ;
					CAPTION '&Printer' ;
					PICTURE 'Btn11.bmp' ;
					ACTION MsgInfo('Click! 5') 
	
				BUTTON Button_6m ;
					CAPTION 'Pre&view' ;
					PICTURE 'Btn12.bmp' ;
					ACTION MsgInfo('Click! 6') 

			END TOOLBAR

			DEFINE TOOLBAREX ToolBar_n BUTTONSIZE 35,40 FONT 'ARIAL' SIZE 7 FLAT CAPTION 'Hiden Buttons 2 with Chevron' TOOLBARSIZE 70 

				BUTTON Button_1n ;
					CAPTION '&New' ;
					PICTURE 'Btn01.bmp' ;
					ACTION MsgInfo('Click! 1') 

				BUTTON Button_2n ;
					CAPTION '&Open' ;
					PICTURE 'Btn02.bmp' ;
					TOOLTIP 'Open file';
					ACTION MsgInfo('Click! 2')

				BUTTON Button_3n ;
					CAPTION '&Close' ;
					PICTURE 'Btn03.bmp' ;
					ACTION MsgInfo('Click! 3')

				BUTTON Button_4n ;
					CAPTION '&Save' ;
					PICTURE 'Btn04.bmp' ;
					ACTION MsgInfo('Click! 4') ; 
					SEPARATOR 

	    			BUTTON Button_5n ;
					CAPTION '&Printer' ;
					PICTURE 'Btn11.bmp' ;
					ACTION MsgInfo('Click! 5') 
	
				BUTTON Button_6n ;
					CAPTION 'Pre&view' ;
					PICTURE 'Btn12.bmp' ;
					ACTION MsgInfo('Click! 6') 

			END TOOLBAR

			DEFINE TOOLBAR ToolBar_o BUTTONSIZE 35,30 FONT 'ARIAL' SIZE 7 FLAT CAPTION 'Bottom Text Standard'

				BUTTON Button_1o ;
					CAPTION '&Printer' ;
					PICTURE 'Btn11.bmp' ;
					ACTION MsgInfo('Click! 1')

				BUTTON Button_2o ;
					CAPTION 'Pre&view' ;
					PICTURE 'Btn12.bmp' ;
					ACTION MsgInfo('Click! 2') ; 
					SEPARATOR

				BUTTON Button_3o ;
					CAPTION '&Copy' ;
					PICTURE 'Btn21.bmp' ;
					ACTION MsgInfo('Click! 3')

				BUTTON Button_4o ;
					CAPTION '&Cut' ;
					PICTURE 'Btn22.bmp' ;
					ACTION MsgInfo('Click! 4')

				BUTTON Button_5o ;
					CAPTION '&Paste' ;
					PICTURE 'Btn23.bmp' ;
					ACTION MsgInfo('Click! 5')

			END TOOLBAR

		END SPLITBOX

		DEFINE DROPDOWN MENU BUTTON Button_2a 
			ITEM '&Exit'	ACTION Form_1.Release
			ITEM '&About'	ACTION MsgInfo ("MiniGUI ToolBarEx demo") 
		END MENU

		DEFINE DROPDOWN MENU BUTTON Button_3a 
			ITEM '&Disable ToolBar 1 Button 1'	ACTION Form_1.Button_1a.Enabled := .F.
			ITEM '&Enable ToolBar 1 Button 1'	ACTION Form_1.Button_1a.Enabled := .T.
		END MENU

	END WINDOW

	CENTER WINDOW Form_1

	ACTIVATE WINDOW Form_1

Return Nil

#pragma BEGINDUMP

#include <windows.h>
#include "hbapi.h"
#include "hbapiitm.h"

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

#pragma ENDDUMP