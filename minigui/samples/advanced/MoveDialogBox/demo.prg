/*
 * HMG Demo: Move Dialog Box
 * (c) 2014, by Dr. Claudio Soto <srvet@adinet.com.uy> , http://srvet.blogspot.com
 *
 * Adapted for MiniGUI Extended Edition by Grigory Filatov
 *
 * Revised by Petr Chornyj <myorg63@mail.ru>
*/

#include "minigui.ch"

#xtranslate SET DIALOGBOX [ROW <nRow>] [COL <nCol>] [[<lCenter:CENTER>] [OF <Form>]] ;
	=> ;
            _HMG_DialogBoxProperty( <nRow>, <nCol>, <.lCenter.>, <Form>, .T. )

FUNCTION MAIN

   SET EVENTS FUNCTION TO MYEVENTS

   DEFINE WINDOW Form_1 ;
      AT 100,100 ;
      WIDTH 700 HEIGHT 500 ;
      TITLE 'Move Dialog Box' ;
      MAIN

      @  50,350 BUTTON Button_1 CAPTION "Dlg Move1"  ACTION ( ( SET DIALOGBOX CENTER OF This.Handle ),; 
                                                              MsgInfo ("Hello", "Dlg Move 1"),; 
                                                              SET DIALOGBOX )

      @ 150,100 BUTTON Button_2 CAPTION "Dlg Move2"  ACTION ( ( SET DIALOGBOX CENTER ),; 
                                                              MsgInfo ("Hello", "Dlg Move 2"),; 
                                                              SET DIALOGBOX )

      @ 250,100 BUTTON Button_3 CAPTION "Dlg Move3"  ACTION ( ( SET DIALOGBOX ROW 50 COL 30 ),; 
                                                              MsgInfo ("Hello", "Dlg Move 3"),; 
                                                              SET DIALOGBOX )

      @ 350,100 BUTTON Button_4 CAPTION "Dlg NoMove" ACTION MsgInfo( GetClassName( Form_1.Handle ) )

   END WINDOW

   ACTIVATE WINDOW Form_1

RETURN NIL

///////////////////////////////////////////////////////////////
#define WM_WINDOWPOSCHANGING	70

FUNCTION MyEvents ( hWnd, nMsg, wParam, lParam )

   LOCAL result := 0

	SWITCH nMsg
	CASE WM_WINDOWPOSCHANGING

		_HMG_DialogBoxProcedure()
		EXIT

#ifdef __XHARBOUR__
	DEFAULT
#else
	OTHERWISE
#endif
		result := Events( hWnd, nMsg, wParam, lParam )
	END

RETURN result

///////////////////////////////////////////////////////////////
FUNCTION _HMG_DialogBoxProperty ( nRow, nCol, lCenter, Form, lSet )

   STATIC _HMG_DialogBoxPosSizeInfo

   hb_default( @_HMG_DialogBoxPosSizeInfo, Array(4) )
   hb_default( @lSet, .T. )

   IF lSet
      _HMG_DialogBoxPosSizeInfo [1] := nCol
      _HMG_DialogBoxPosSizeInfo [2] := nRow
      _HMG_DialogBoxPosSizeInfo [3] := lCenter
      _HMG_DialogBoxPosSizeInfo [4] := If( HB_ISSTRING( Form ), GetFormHandle( Form ), Form )
   ELSE
      nCol    := _HMG_DialogBoxPosSizeInfo [1]
      nRow    := _HMG_DialogBoxPosSizeInfo [2]
      lCenter := _HMG_DialogBoxPosSizeInfo [3]
      Form    := _HMG_DialogBoxPosSizeInfo [4]
   ENDIF

RETURN NIL

///////////////////////////////////////////////////////////////
#define SWP_NOOWNERZORDER  0x0200
#define SWP_NOMOVE         0x0002
#define SWP_NOSIZE         0x0001

FUNCTION _HMG_DialogBoxProcedure()

   LOCAL nCol, nRow, Width, Height, lCenter
   LOCAL hWndParent, hWnd := GetActiveWindow()

   IF IsWindowHandle( hWnd ) .AND. GetClassName( hWnd ) == "#32770" // The class name for a dialog box

      _HMG_DialogBoxProperty( @nRow, @nCol, @lCenter, @hWndParent, .F. )

      hb_default( @nCol, GetWindowCol( hWnd ) )
      hb_default( @nRow, GetWindowRow( hWnd ) )
      
      IF ( lCenter := hb_defaultValue( lCenter, .F. ) )

         hb_default( @hWndParent, GetParent( hWnd ) )

         nCol := GetWindowCol( hWndParent ) + Int( ( GetWindowWidth ( hWndParent ) - GetWindowWidth ( hWnd ) ) / 2 )
         nRow := GetWindowRow( hWndParent ) + Int( ( GetWindowHeight( hWndParent ) - GetWindowHeight( hWnd ) ) / 2 )

      ENDIF
      
      SetWindowPos( hWnd, 0, nCol, nRow, 0, 0, SWP_NOOWNERZORDER + SWP_NOSIZE )

   ENDIF

RETURN NIL

///////////////////////////////////////////////////////////////
#pragma BEGINDUMP

#include "mgdefs.h"

HB_FUNC ( GETPARENT )
{
   HB_RETNL( ( LONG_PTR ) GetParent( ( HWND ) HB_PARNL( 1 ) ) );
}

#pragma ENDDUMP
