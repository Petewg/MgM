/*
 * MiniGUI Focused Control Color Frame Demo
 * 2007 MiniGUI Team
*/

#include "minigui.ch"

memvar c_txt_back, c_txt_color
memvar c_lbl_back, c_lbl_color

Function Main

local cas_n, cas_var, cas_lbl, m_col

private c_txt_back  := {255, 255,   0}
private c_txt_color := {255, 255, 255}

private c_lbl_back  := {0, 255, 255}
private c_lbl_color := {0, 255, 255}

SET NAVIGATION EXTENDED

DEFINE WINDOW Form_cas ;
   AT 0,0 WIDTH 400 HEIGHT 400 ;
   TITLE 'Press UP or DOWN or ENTER  -   by CAS' MAIN ;
   BACKCOLOR {0,255,255}

   ON KEY DOWN ACTION InsertTab()
   ON KEY UP   ACTION InsertShiftTab()
   ON KEY ESCAPE ACTION Form_cas.Release

   for cas_n=1 to 10
      cas_var = 'TEXT_' + alltrim(str(cas_n))
      cas_lbl = 'LBL_'  + alltrim(str(cas_n))

      @ cas_n*30 , 30 LABEL &cas_lbl value cas_lbl ;
                      width 95 height 25 backcolor c_lbl_color

      m_col := form_cas.&cas_lbl..col + form_cas.&cas_lbl..width + 20

      @ cas_n*30 , m_col TEXTBOX &cas_var value cas_var width 200 ;
			ON LOSTFOCUS cas_func(1) ;
			ON GOTFOCUS cas_func() ;
			BACKCOLOR c_txt_color ;
			FONTCOLOR {0,0,0}
   next

END WINDOW

Form_cas.Center
Form_cas.Activate

Return Nil

*............................................................................*

static function cas_func(...)

local var_text  := this.name
local var_label := 'LBL_' + substr(var_text, 6)

if pcount() # 0
   form_cas.&var_label..fontbold := .f.
   form_cas.&var_label..fontsize := 9

   form_cas.&var_label..backcolor := c_lbl_color
   form_cas.&var_text..backcolor  := c_txt_color

   RedrawControlFrame ( var_text, 'form_cas' )

else

   form_cas.&var_label..fontbold := .t.
   form_cas.&var_label..fontsize := 12

   form_cas.&var_label..backcolor := c_lbl_back
   form_cas.&var_text..backcolor  := c_txt_back

   * caretpos = 0, it was put for not selecting the whole text
   form_cas.&var_text..caretpos  := 0

   DrawColorFrame ( GetControlHandle( var_text, 'form_cas' ), {255,0,0} )

endif

return nil

*------------------------------------------------------------------------------*
procedure RedrawControlFrame ( ControlName, ParentForm )
*------------------------------------------------------------------------------*
Local ix := GetControlIndex ( ControlName, ParentForm )
Local h := _HMG_aControlParentHandles [ix]

	RedrawWindowControlRect( h , _HMG_aControlRow[ix] , _HMG_aControlCol[ix] , _HMG_aControlRow[ix] + _HMG_aControlHeight[ix] , _HMG_aControlCol[ix] + _HMG_aControlWidth [ix] )

Return


#pragma BEGINDUMP

#define _WIN32_WINNT   0x0400

#include <windows.h>
#include "hbapi.h"

#ifdef __XHARBOUR__
#define HB_PARNI( n, x ) hb_parni( n, x )
#else
#define HB_PARNI( n, x ) hb_parvni( n, x )
#endif

HB_FUNC( DRAWCOLORFRAME )
{
   HWND hWnd = ( HWND ) hb_parnl( 1 );

   HDC hdc = GetWindowDC( hWnd );
   RECT rect;
   HBRUSH hbr = CreateSolidBrush( RGB ( HB_PARNI(2, 1),
					HB_PARNI(2, 2),
					HB_PARNI(2, 3) ) );

   GetWindowRect( hWnd, &rect );
   rect.right -= rect.left;
   rect.bottom -= rect.top;
   rect.left = 0;
   rect.top = 0;

   FrameRect( hdc, &rect, hbr );
   InflateRect( &rect, -1, -1 );
   FrameRect( hdc, &rect, hbr );

   DeleteObject( hbr );
   ReleaseDC( hWnd, hdc );
}

#pragma ENDDUMP
