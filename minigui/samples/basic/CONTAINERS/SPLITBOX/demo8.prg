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
      WIDTH 640 HEIGHT 480 ;
      TITLE 'MiniGUI SplitBox Demo' ;
      MAIN ;
      ON PAINT SPLITBOX_RESIZE()

      DEFINE STATUSBAR
         STATUSITEM 'HMG Power Ready - Resize SplitBox And Enjoy !' 
      END STATUSBAR

      DEFINE MAIN MENU 
         POPUP '&Help'
            ITEM 'About'      ACTION MsgInfo ("MiniGUI SplitBox Demo","A COOL Feature ;)") 
         END POPUP
      END MENU

      DEFINE SPLITBOX 

         DEFINE TOOLBAR ToolBar_1 BUTTONSIZE 95,30 FLAT RIGHTTEXT CAPTION 'ToolBar 1'

		BUTTON Button_1 ;
			CAPTION '&Undo' ;
			PICTURE 'button4.bmp' ;
			ACTION MsgInfo('UnDo Click!') 

		BUTTON Button_2 ;
			CAPTION '&Save' ;
			PICTURE 'button5.bmp' ;
			ACTION MsgInfo('Save Click!') 
	
		BUTTON Button_3 ;
			CAPTION '&Close' ;
			PICTURE 'button6.bmp' ;
			ACTION MsgInfo('Close Click!') 

		BUTTON Button_10 ;
			CAPTION '&Login' ;
			PICTURE 'button14.bmp' ;
			ACTION MsgInfo('Login Click!') 

         END TOOLBAR

         DEFINE WINDOW SplitChild_1 ; 
            WIDTH 200 ;
            HEIGHT 200 ;
            VIRTUAL WIDTH 800 ;
            VIRTUAL HEIGHT 800 ;
            SPLITCHILD NOCAPTION

            DEFINE LABEL Label_1
               ROW   55
               COL   30
               VALUE 'Label !!!' 
               WIDTH 100 
               HEIGHT 27 
            END LABEL

            DEFINE CHECKBOX Check_1
               ROW   80
               COL   30
               CAPTION 'Check 1' 
               VALUE .T. 
               TOOLTIP 'CheckBox' 
            END CHECKBOX
         
            DEFINE SLIDER Slider_1
               ROW 115
               COL 30
               RANGEMIN 1
               RANGEMAX 10 
               VALUE 5 
               TOOLTIP 'Slider' 
            END SLIDER
            
            DEFINE FRAME Frame_1
               ROW   45
               COL   170
               WIDTH 85
               HEIGHT 110
            END FRAME

            DEFINE RADIOGROUP Radio_1
               ROW   50
               COL   180
               OPTIONS { 'One' , 'Two' , 'Three', 'Four' } 
               VALUE 1 
               WIDTH 70 
               TOOLTIP 'RadioGroup' 
            END RADIOGROUP

         END WINDOW 

      END SPLITBOX

   END WINDOW

   CENTER WINDOW Form_1

   ACTIVATE WINDOW Form_1

Return Nil

*---------------------------------------------*
PROCEDURE SPLITBOX_RESIZE
*---------------------------------------------*
LOCAL Height    := GetFormClientHeight ("Form_1") - GetStatusbarHeight ("Form_1")
LOCAL DifHeight := Height - REBAR_GETHEIGHT (GetSplitBoxHandle("Form_1"))
LOCAL aRect     := REBAR_GETBANDINFO (GetSplitBoxHandle("Form_1"), 1)   // SplitChild_1
LOCAL NewHeight := aRect [2] + DifHeight

   REBAR_SETMINCHILDSIZE (GetSplitBoxHandle("Form_1"), 1, NewHeight)   // SplitChild_1

RETURN

*---------------------------------------------*
FUNCTION GetFormClientHeight (cForm)
*---------------------------------------------*
LOCAL aRect := { 0, 0, 0, 0 }
LOCAL nValue := 0

   if _IsWindowDefined (cForm)
      GetClientRect (GetFormHandle(cForm), aRect)
      nValue := aRect[4]
   Endif

RETURN (nValue)

*---------------------------------------------*
FUNCTION GetStatusbarHeight (cForm)
*---------------------------------------------*
RETURN GetControlHeight (cForm, "STATUSBAR")

*---------------------------------------------*
FUNCTION GetControlHeight (cForm, cControl)
*---------------------------------------------*
LOCAL aRect := { 0, 0, 0, 0 }
LOCAL nValue := 0

   if _IsControlDefined (cControl, cForm)
      if GetProperty (cForm, cControl, "Visible")
         GetClientRect (GetControlHandle (cControl, cForm), aRect)
         nValue := aRect[4]
      Endif
   Endif

RETURN (nValue)

*---------------------------------------------*
FUNCTION GetSplitBoxHandle (cParentForm)
*---------------------------------------------*
LOCAL i := GetFormIndex (cParentForm)

   if i > 0 .AND. _HMG_aFormReBarHandle [i] <> 0
      Return _HMG_aFormReBarHandle [i]
   EndIf

RETURN 0


#pragma BEGINDUMP

#include <mgdefs.h>
#include <windows.h>
#include <commctrl.h>

#include "hbapi.h"

//*********************************************
//    by Dr. Claudio Soto (July 2014)
//*********************************************

HB_FUNC( REBAR_GETHEIGHT )
{
   HWND hWnd    = ( HWND ) HB_PARNL( 1 );
   UINT nHeight = SendMessage( hWnd, RB_GETBARHEIGHT, 0, 0 );

   hb_retni( ( INT ) nHeight );
}

HB_FUNC( REBAR_GETBANDCOUNT )
{
   HWND hWnd       = ( HWND ) HB_PARNL( 1 );
   UINT nBandCount = SendMessage( hWnd, RB_GETBANDCOUNT, 0, 0 );

   hb_retni( ( INT ) nBandCount );
}

HB_FUNC( REBAR_GETBARRECT )
{
   HWND hWnd  = ( HWND ) HB_PARNL( 1 );
   UINT nBand = ( UINT ) hb_parni( 2 );
   RECT Rect;

   SendMessage( hWnd, RB_GETRECT, ( WPARAM ) nBand, ( LPARAM ) &Rect );

   hb_reta( 6 );
   hb_storvnl( ( LONG ) Rect.left, -1, 1 );
   hb_storvnl( ( LONG ) Rect.top, -1, 2 );
   hb_storvnl( ( LONG ) Rect.right, -1, 3 );
   hb_storvnl( ( LONG ) Rect.bottom, -1, 4 );
   hb_storvnl( ( LONG ) ( Rect.right - Rect.left ), -1, 5 );   // nWidth
   hb_storvnl( ( LONG ) ( Rect.bottom - Rect.top ), -1, 6 );   // nHeight
}

HB_FUNC( REBAR_GETBANDBORDERS )
{
   HWND hWnd  = ( HWND ) HB_PARNL( 1 );
   UINT nBand = ( UINT ) hb_parni( 2 );
   RECT Rect;

   SendMessage( hWnd, RB_GETBANDBORDERS, ( WPARAM ) nBand, ( LPARAM ) &Rect );

   hb_reta( 4 );
   hb_storvnl( ( LONG ) Rect.left, -1, 1 );
   hb_storvnl( ( LONG ) Rect.top, -1, 2 );
   hb_storvnl( ( LONG ) Rect.right, -1, 3 );
   hb_storvnl( ( LONG ) Rect.bottom, -1, 4 );
}

HB_FUNC( REBAR_SETMINCHILDSIZE )
{
   HWND hWnd  = ( HWND ) HB_PARNL( 1 );
   UINT nBand = ( UINT ) hb_parni( 2 );
   UINT yMin  = ( UINT ) hb_parni( 3 );

   REBARBANDINFO rbbi;

   rbbi.cbSize     = sizeof( REBARBANDINFO );
   rbbi.fMask      = RBBIM_CHILDSIZE;
   rbbi.cxMinChild = 0;
   rbbi.cyMinChild = yMin;
   rbbi.cx         = 0;

   SendMessage( hWnd, RB_SETBANDINFO, ( WPARAM ) nBand, ( LPARAM ) &rbbi );
}

HB_FUNC( REBAR_GETBANDINFO )
{
   HWND hWnd  = ( HWND ) HB_PARNL( 1 );
   UINT uBand = ( UINT ) hb_parni( 2 );
   REBARBANDINFO rbbi;

   rbbi.cbSize = sizeof( REBARBANDINFO );
   rbbi.fMask  = RBBIM_CHILDSIZE | RBBIM_SIZE;

   SendMessage( hWnd, RB_GETBANDINFO, ( WPARAM ) uBand, ( LPARAM ) &rbbi );

   hb_reta( 7 );
   hb_storvnl( ( LONG ) rbbi.cxMinChild, -1, 1 );
   hb_storvnl( ( LONG ) rbbi.cyMinChild, -1, 2 );
   hb_storvnl( ( LONG ) rbbi.cx, -1, 3 );
   hb_storvnl( ( LONG ) rbbi.cyChild, -1, 4 );
   hb_storvnl( ( LONG ) rbbi.cyMaxChild, -1, 5 );
   hb_storvnl( ( LONG ) rbbi.cyIntegral, -1, 6 );
   hb_storvnl( ( LONG ) rbbi.cxIdeal, -1, 7 );
}

#pragma ENDDUMP
