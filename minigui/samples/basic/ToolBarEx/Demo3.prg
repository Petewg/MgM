/*
 * MINIGUI - Harbour Win32 GUI library Demo
 *
 * Copyright 2002 Roberto Lopez <harbourminigui@gmail.com>
 * http://harbourminigui.googlepages.com/
*/


#include "minigui.ch"

Function Main

	DEFINE WINDOW Form_1 ;
		AT 0,0 ;
		WIDTH 600 HEIGHT 380 ;
		TITLE 'MiniGUI ToolBarEx Demo (Based Upon a Contribution Of Janusz Pora)' ;
		ICON 'DEMO.ICO' ;
		MAIN ;
		FONT 'Arial' SIZE 10 

		DEFINE STATUSBAR
			STATUSITEM '[x] Harbour MiniGUI Power Ready!' DEFAULT
		END STATUSBAR

		DEFINE MAIN MENU 
			POPUP 'ToolBar&1'
				ITEM 'Enable ToolBar_1 Button_1'	    ACTION Form_1.Button_1.Enabled := .T.
				ITEM 'Enable ToolBar_1 Button_2'	    ACTION Form_1.Button_2.Enabled := .T.
				ITEM 'Enable ToolBar_1 Button_3'	    ACTION Form_1.Button_3.Enabled := .T.
				ITEM 'Enable ToolBar_1 Button_4'	    ACTION Form_1.Button_4.Enabled := .T.
				ITEM 'Enable ToolBar_1 Button_5'	    ACTION Form_1.Button_5.Enabled := .T.
				ITEM 'Enable ToolBar_1 Button_6'	    ACTION Form_1.Button_6.Enabled := .T.
    			SEPARATOR	
				ITEM 'Disable ToolBar_1 Button_1'	    ACTION Form_1.Button_1.Enabled := .F.
				ITEM 'Disable ToolBar_1 Button_2'	    ACTION Form_1.Button_2.Enabled := .F.
				ITEM 'Disable ToolBar_1 Button_3'	    ACTION Form_1.Button_3.Enabled := .F.
				ITEM 'Disable ToolBar_1 Button_4'	    ACTION Form_1.Button_4.Enabled := .F.
				ITEM 'Disable ToolBar_1 Button_5'	    ACTION Form_1.Button_5.Enabled := .F.
				ITEM 'Disable ToolBar_1 Button_6'	    ACTION Form_1.Button_6.Enabled := .F.
		    	SEPARATOR	
				ITEM '&Exit'			ACTION Form_1.Release
			END POPUP
			POPUP 'ToolBar&2'
				ITEM 'Enable ToolBar_2 Button_1'	    ACTION Form_1.Button_1a.Enabled := .T.
				ITEM 'Enable ToolBar_2 Button_2'	    ACTION Form_1.Button_2a.Enabled := .T.
				ITEM 'Enable ToolBar_2 Button_3'	    ACTION Form_1.Button_3a.Enabled := .T.
				ITEM 'Enable ToolBar_2 Button_4'	    ACTION Form_1.Button_4a.Enabled := .T.
				ITEM 'Enable ToolBar_2 Button_5'	    ACTION Form_1.Button_5a.Enabled := .T.
				ITEM 'Enable ToolBar_2 Button_6'	    ACTION Form_1.Button_6a.Enabled := .T.
    			SEPARATOR	
				ITEM 'Disable ToolBar_2 Button_1'	    ACTION Form_1.Button_1a.Enabled := .F.
				ITEM 'Disable ToolBar_2 Button_2'	    ACTION Form_1.Button_2a.Enabled := .F.
				ITEM 'Disable ToolBar_2 Button_3'	    ACTION Form_1.Button_3a.Enabled := .F.
				ITEM 'Disable ToolBar_2 Button_4'	    ACTION Form_1.Button_4a.Enabled := .F.
				ITEM 'Disable ToolBar_2 Button_5'	    ACTION Form_1.Button_5a.Enabled := .F.
				ITEM 'Disable ToolBar_2 Button_6'	    ACTION Form_1.Button_6a.Enabled := .F.
			END POPUP

			POPUP '&Help'
				ITEM '&About'		ACTION MsgInfo ("MiniGUI ToolBarEx demo") 
			END POPUP
		END MENU

		DEFINE SPLITBOX 

			DEFINE TOOLBAREX ToolBar_1 BUTTONSIZE 35,40 FONT 'ARIAL' SIZE 7 FLAT CAPTION 'Hiden Buttons 1 with Chevron' TOOLBARSIZE 70 BREAK

				BUTTON Button_1 ;
					CAPTION '&New' ;
					PICTURE 'Btn01.bmp' ;
					ACTION MsgInfo('Click! 1'); 

				BUTTON Button_2 ;
					CAPTION '&Open' ;
					PICTURE 'Btn02.bmp' ;
					TOOLTIP 'Open file';
					ACTION MsgInfo('Click! 2')

				BUTTON Button_3 ;
					CAPTION '&Close' ;
					PICTURE 'Btn03.bmp' ;
					ACTION MsgInfo('Click! 3')

				BUTTON Button_4 ;
					CAPTION '&Save' ;
					PICTURE 'Btn04.bmp' ;
					ACTION MsgInfo('Click! 4'); 
					SEPARATOR 

				BUTTON Button_5 ;
					CAPTION '&Printer' ;
					PICTURE 'Btn11.bmp' ;
					ACTION MsgInfo('Click! 5'); 
	
				BUTTON Button_6 ;
					CAPTION 'Pre&view' ;
					PICTURE 'Btn12.bmp' ;
					ACTION MsgInfo('Click! 6'); 

			END TOOLBAR

			DEFINE TOOLBAREX ToolBar_2 BUTTONSIZE 35,40 FONT 'ARIAL' SIZE 7 FLAT CAPTION 'Hiden Buttons 2 with Chevron' TOOLBARSIZE 70 

				BUTTON Button_1a ;
					CAPTION '&New' ;
					PICTURE 'Btn01.bmp' ;
					ACTION MsgInfo('Click! 1'); 

				BUTTON Button_2a ;
					CAPTION '&Open' ;
					PICTURE 'Btn02.bmp' ;
					TOOLTIP 'Open file';
					ACTION MsgInfo('Click! 2')

				BUTTON Button_3a ;
					CAPTION '&Close' ;
					PICTURE 'Btn03.bmp' ;
					ACTION MsgInfo('Click! 3')

				BUTTON Button_4a ;
					CAPTION '&Save' ;
					PICTURE 'Btn04.bmp' ;
					ACTION MsgInfo('Click! 4'); 
					SEPARATOR 

				BUTTON Button_5a ;
					CAPTION '&Printer' ;
					PICTURE 'Btn11.bmp' ;
					ACTION MsgInfo('Click! 5'); 
	
				BUTTON Button_6a ;
					CAPTION 'Pre&view' ;
					PICTURE 'Btn12.bmp' ;
					ACTION MsgInfo('Click! 6'); 

			END TOOLBAR

		END SPLITBOX

        @ 100 , 50 LABEL Label_1 ; 
            VALUE " Info: " ; 
            HEIGHT 32 AUTOSIZE ;
            FONTCOLOR RED ;   
            FONT "Arial" SIZE 20 BOLD BORDER

        @ 105 , 150 LABEL Label_2 ; 
            VALUE " Disabled Button with Chevron " ; 
            HEIGHT 35 AUTOSIZE ;
            FONTCOLOR BLUE ;   
            FONT "Arial" SIZE 16

        Form_1.Button_3.Enabled  := .F.
        Form_1.Button_5.Enabled  := .F.
        Form_1.Button_4a.Enabled  := .F.
        Form_1.Button_5a.Enabled  := .F.
	
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
