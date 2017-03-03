/*
 * MINIGUI - Harbour Win32 GUI library Demo
 *
 * Copyright 2002-05 Roberto Lopez <harbourminigui@gmail.com>
 * http://harbourminigui.googlepages.com/
 *
 * Copyright 2005 Grigory Filatov <gfilatov@inbox.ru>
*/

ANNOUNCE RDDSYS

#include "minigui.ch"

#define PROGRAM 'Circle'
#define PI  3.1415926536

PROCEDURE Main

	DEFINE WINDOW Form_1 ;
		AT 0,0 ;
		WIDTH 400 HEIGHT 400 ;
		TITLE PROGRAM + " - Contributed by Grigory Filatov" ;
		MAIN ;
		ICON "demo.ico" ;
		NOMAXIMIZE ;
		ON INIT OnInit() ;
		ON PAINT drawcircle() ;
		BACKCOLOR WHITE ;
		FONT "MS Sans Serif" SIZE 8

		@ 10,Form_1.Width - 120 BUTTON Button_1 ;
		CAPTION 'Close' ;
		ACTION Form_1.Release

	END WINDOW

	Form_1.Center

	ACTIVATE WINDOW Form_1

Return

PROCEDURE OnInit

	IF !IsWinNT()
		MsgStop( 'This Program Runs In Win2000/XP Only!', 'Stop' )
		ReleaseAllWindows()
	ENDIF

	Form_1.Button_1.Setfocus

	 LayeredWindowStarting(_HMG_MainHandle)

	CLEAN MEMORY

RETURN

PROCEDURE drawcircle
Local i, x0, y0, a := 320, r := 80, rr := 100, step_fi := PI / 8
Local N := 2 * PI / step_fi

	for i := 0 to N - 1

		x0 := rr * sin( i * step_fi )
		y0 := rr * cos( i * step_fi )

		circle( "Form_1", a/2 + x0, a/2 + y0, r )

	next i

RETURN

STATIC PROCEDURE Circle( window, nCol, nRow, nWidth )
	drawellipse(window, nCol, nRow, nCol + nWidth - 1, nRow + nWidth - 1)
RETURN

static function Sin( nAng )

   local nSin, nOld
   local nMod := 3
   local lSgn := .f.

   nSin := nAng

   do while nSin != nOld

      nOld = nSin

      if lSgn
         nSin += (nAng ** nMod) / Fac( nMod )
      else
         nSin -= (nAng ** nMod) / Fac( nMod )
      endif

      nMod += 2

      lSgn = !lSgn

   enddo

return nSin

static function Cos( nAng )

   local nCos, nOld
   local nMod := 2
   local lSgn := .f.

   nCos := 1

   do while nCos != nOld

      nOld = nCos

      if lSgn
         nCos += (nAng ** nMod) / Fac( nMod )
      else
         nCos -= (nAng ** nMod) / Fac( nMod )
      endif

      nMod += 2

      lSgn = !lSgn

   enddo

return nCos

static function Fac( nNum )
  local n, nFac := 1

  for n := 2 to nNum
      nFac *= n
  next

return nFac

#pragma BEGINDUMP

#include <windows.h>
#include "hbapi.h"
#include "hbapiitm.h"

HB_FUNC ( LAYEREDWINDOWSTARTING )
{
	HWND hWnd = ( HWND ) hb_parnl( 1 );
	MSG Msg;
	int x;

	SetWindowLong(hWnd, GWL_EXSTYLE, GetWindowLong(hWnd, GWL_EXSTYLE) | WS_EX_LAYERED);

	for ( x = 0; x < 255; x += 5 )
	{
		SetLayeredWindowAttributes(hWnd, 0, x, 0x02);
  
		if( PeekMessage((LPMSG) &Msg, 0, 0, 0, PM_REMOVE) )
		{
			TranslateMessage(&Msg);
			DispatchMessage(&Msg);
		}
		Sleep(50);
	}

	SetLayeredWindowAttributes(hWnd, 0, 255, 0x02);
}

#pragma ENDDUMP
