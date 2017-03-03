*--------------------------------------------------------------------------------*
* File:         ANIWND.PRG
* Author:       Morris D'Andrea <m_dandrea@cogeco.ca>
* Description:  Example using the AnimateWindow API call.
*               Tested under windows 2000 and 98. Various effects on a dialog
*               and window including fade, slide, from center, from top left, from top
*               right are in the example.
*               You may want to play with the second parameter in the
*               API call in the example below it is set to 500, you may want to increase
*               for faster systems or decrease it for slower ones ( makes the effect
*               smoother depending on CPU speed ).
*
*               AnimateWindow( hWnd, 500, hb_bitOr(AW_BLEND, AW_HIDE) )
*
*--------------------------------------------------------------------------------*
* Translated for MiniGUI by Grigory Filatov <gfilatov@inbox.ru>

#include "hmg.ch"
/*
#define AW_HOR_POSITIVE   1 // Animates the window from left to right. This flag can be used with roll or slide animation.
#define AW_HOR_NEGATIVE   2 // Animates the window from right to left. This flag can be used with roll or slide animation.
#define AW_VER_POSITIVE   4 // Animates the window from top to bottom. This flag can be used with roll or slide animation.
#define AW_VER_NEGATIVE   8 // Animates the window from bottom to top. This flag can be used with roll or slide animation.
#define AW_CENTER        16 // Makes the window appear to collapse inward if AW_HIDE is used or expand outward if the AW_HIDE is not used.
#define AW_HIDE       65536 // Hides the window. By default, the window is shown.
#define AW_ACTIVATE  131072 // Activates the window.
#define AW_SLIDE     262144 // Uses slide animation. By default, roll animation is used.
#define AW_BLEND     524288 // Uses a fade effect. This flag can be used only if hwnd is a top-level window.
*/
function main()

	// Important if any part of the window is drawn
	// past the top of screen or the bottom of window
	// is beyond the taskbar the window hides first and
	// then the effect is applied dialogs seem to work fine 

	DEFINE WINDOW Form_Main ;
		TITLE 'Window Animation Effects' ;
		MAIN ;
		BACKCOLOR BLUE

		DEFINE STATUSBAR
			STATUSITEM '' DEFAULT
		END STATUSBAR

		DEFINE MAIN MENU
			DEFINE POPUP "&Test Effects"
				MENUITEM "Top Right Down..." ;
					MESSAGE "Show Top Right Down";
					ACTION toprightdown( Application.FormName )
				MENUITEM "Top Left Down..." ;
					MESSAGE "Show Top Left Down";
					ACTION topleftdown( Application.FormName )
				MENUITEM "Fade..." ;
					MESSAGE "Show Fade";
					ACTION Fade( Application.Handle )
				MENUITEM "From Center..." ;
					MESSAGE "Show From Center";
					ACTION fromcenter( Application.FormName )
				MENUITEM "Open Dialog..." ;
					MESSAGE "Open Dialog";
					ACTION opendlg()
				SEPARATOR
				MENUITEM "E&xit" ;
					MESSAGE "Click here to Exit";
				ACTION ( close_wnd( Application.Handle , .t. ), Form_Main.Release() )
			END POPUP
			DEFINE POPUP 'H&elp'
				ITEM 'About'	ACTION MsgInfo ("Free GUI Library For Harbour", "MiniGUI Animation Demo")
			END POPUP
		END MENU

	END WINDOW

	ACTIVATE WINDOW Form_Main

return NIL

/*
*/
function opendlg()

IF !IsWindowDefined( f_Dialog )

   DEFINE DIALOG f_Dialog ;
      OF Form_Main ;
      AT ColChartopix(14),Rowchartopix(7) ;
      WIDTH ColChartopix(45) ;
      HEIGHT Rowchartopix(19);
      CAPTION "Dialog Fade" ;
      ON RELEASE close_wnd(GetFormHandle("f_Dialog"), .f.)

      @ Rowchartopix(2),ColChartopix(7) BUTTON Btn_1 ID 101 ;
          CAPTION 'Top &Right Down' ;
       	  ACTION toprightdown("f_Dialog") ;
 	  WIDTH 120 ;
          HEIGHT 24

      @ Rowchartopix(4),ColChartopix(7) BUTTON Btn_1 ID 102 ;
          CAPTION 'Top &Left Down' ;
       	  ACTION topleftdown("f_Dialog") ;
 	  WIDTH 120 ;
          HEIGHT 24

      @ Rowchartopix(6),ColChartopix(7) BUTTON Btn_1 ID 103 ;
          CAPTION 'From &Center' ;
       	  ACTION fromcenter("f_Dialog") ;
 	  WIDTH 120 ;
          HEIGHT 24

      @ Rowchartopix(8),ColChartopix(7) BUTTON Btn_1 ID 104 ;
          CAPTION '&Fade dialog' ;
       	  ACTION fade(GetFormHandle("f_Dialog")) ;
 	  WIDTH 120 ;
          HEIGHT 24

   END DIALOG 

   BringWindowToTop(GetFormHandle("f_Dialog"))

ELSE
   f_Dialog.Setfocus()
ENDIF

return NIL

/*
*/
function topleftdown(form)
local hwnd := GetFormHandle(form)

HideWindow(hwnd)
ANIMATE WINDOW &form INTERVAL 300 MODE AW_VER_POSITIVE + AW_HOR_POSITIVE + AW_SLIDE
SetFocus(hwnd)

return(NIL)

/*
*/
function toprightdown(form)
local hwnd := GetFormHandle(form)

HideWindow(hwnd)
ANIMATE WINDOW &form INTERVAL 500 MODE AW_VER_POSITIVE + AW_HOR_NEGATIVE + AW_SLIDE
SetFocus(hwnd)

return(NIL)

/*
*/
function fromcenter(form)
local hwnd := GetFormHandle(form)

HideWindow(hwnd)
ANIMATE WINDOW &form INTERVAL 500 MODE AW_CENTER
SetFocus(hwnd)

return(NIL)

/*
*/
function fade(hwnd)

if .not. AnimateWindow( hwnd, 500, AW_BLEND + AW_HIDE )
   HideWindow(hwnd)
endif
msginfo("Window is Faded")
ShowWindow(hwnd)
SetFocus(hwnd)

return(NIL)

/*
*/
function close_wnd(hwnd, lClose)

    if .not. AnimateWindow( hwnd, 500, hb_bitOr(AW_BLEND, AW_HIDE) )
	HideWindow(hwnd)
    endif
    do while IsWindowVisible(hwnd)
	ProcessMessages()
    enddo
    if lClose
	Form_Main.Release()
    endif

return(NIL)

/*
*/					
Static Function RowCharToPix( nValor )
Return nValor*14
/*
*/					
Static Function ColCharToPix( nValor )
Return nValor*8
