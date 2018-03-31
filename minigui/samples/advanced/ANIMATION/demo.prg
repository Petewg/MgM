/*
   Name: WinAnim
   Author: Brook Miles
   Description: Making an animation in windows

   Adapted for MiniGUI Extended Edition by Grigory Filatov - 2018
*/

ANNOUNCE RDDSYS

#include <minigui.ch>
#include "i_winuser.ch"

FUNCTION Main

	LOCAL aBitmaps

	DEFINE WINDOW Main;
		WIDTH 320 HEIGHT 240;
		TITLE "A Bitmap Program";
		MAIN;
		ON INIT ( aBitmaps := InitMain() );
		ON RELEASE AEval(aBitmaps, {|hBmp| DeleteObject(hBmp)});
		ON PAINT OnPaintProc(this.Handle)

		ChangeStyle(this.Handle, WS_EX_CLIENTEDGE, , .T.)

	END WINDOW

	Main.Center
	Main.Activate

RETURN Nil


FUNCTION InitMain

	LOCAL hbmBall, hbmMask

	hbmBall := LoadBitmap("BALLBMP")
	hbmMask := LoadBitmap("MASKBMP")

	IF Empty(hbmBall) .OR. Empty(hbmMask)
		MsgStop("Load of resources failed.", "Error")
		QUIT
	ENDIF

	InitBall(hbmBall, hbmMask)

	DEFINE TIMER Timer_1 OF Main INTERVAL 33 ACTION OnTimerProc(thisWindow.Handle)

RETURN {hbmBall, hbmMask}


PROCEDURE OnTimerProc(hwnd)

	LOCAL hdcWindow

	hdcWindow := GetDC(hwnd)

	EraseBall(hdcWindow)
	UpdateBall(hwnd)
	DrawBall(hdcWindow)

	ReleaseDC(hwnd, hdcWindow)

RETURN


PROCEDURE OnPaintProc(hwnd)

	LOCAL hdcWindow, ps

	hdcWindow := BeginPaint(hWnd, @ps)
	DrawBall(hdcWindow)
	EndPaint(hWnd, ps)

RETURN


#pragma BEGINDUMP

#include <windows.h>
#include "hbapi.h"

HBITMAP hbmBall, hbmMask;
BITMAP bm;

int ballX, ballY;
int deltaX, deltaY;

int deltaValue = 4;

void InitBall(HBITMAP hBall, HBITMAP hMask)
{
   hbmBall = hBall;
   hbmMask = hMask;

   GetObject(hbmBall, sizeof(bm), &bm);

   ballX = 0;
   ballY = 0;
   deltaX = deltaValue;
   deltaY = deltaValue;
}

void EraseBall(HDC hdc)
{
   RECT rc;

   rc.left = ballX;
   rc.top = ballY;
   rc.right = ballX + bm.bmWidth;
   rc.bottom = ballY + bm.bmHeight;

   FillRect(hdc, &rc, (HBRUSH)(COLOR_BTNFACE+1));
}

void DrawBall(HDC hdc)
{
   HDC hdcMemory;

   hdcMemory = CreateCompatibleDC(hdc);

   SelectObject(hdcMemory, hbmMask);
   BitBlt(hdc, ballX, ballY, bm.bmWidth, bm.bmHeight, hdcMemory, 0, 0, SRCAND);

   SelectObject(hdcMemory, hbmBall);
   BitBlt(hdc, ballX, ballY, bm.bmWidth, bm.bmHeight, hdcMemory, 0, 0, SRCPAINT);

   DeleteDC(hdcMemory);
}

void UpdateBall(HWND hwnd)
{
   RECT rc;

   GetClientRect(hwnd, &rc);

   ballX += deltaX;
   ballY += deltaY;

   if(ballX < 0)
   {
      ballX = 0;
      deltaX = deltaValue;
   }
   else if(ballX + bm.bmWidth > rc.right)
   {
      ballX = rc.right - bm.bmWidth;
      deltaX = -deltaValue;
   }

   if(ballY < 0)
   {
      ballY = 0;
      deltaY = deltaValue;
   }
   else if(ballY + bm.bmHeight > rc.bottom)
   {
      ballY = rc.bottom - bm.bmHeight;
      deltaY = -deltaValue;
   }
}

HB_FUNC ( INITBALL )
{
   HBITMAP hbmBall = (HBITMAP) hb_parnl( 1 );
   HBITMAP hbmMask = (HBITMAP) hb_parnl( 2 );

   InitBall( hbmBall, hbmMask );
}

HB_FUNC ( ERASEBALL )
{
   HDC hdc = (HDC) hb_parnl( 1 );

   EraseBall( hdc );
}

HB_FUNC ( DRAWBALL )
{
   HDC hdc = (HDC) hb_parnl( 1 );

   DrawBall( hdc );
}

HB_FUNC ( UPDATEBALL )
{
   HWND hwnd = (HWND) hb_parnl( 1 );

   UpdateBall( hwnd );
}

#pragma ENDDUMP
