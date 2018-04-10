/*
 * MINIGUI - Harbour Win32 GUI library Demo
 *
 * Copyright 2002-03 Roberto Lopez <harbourminigui@gmail.com>
 * http://harbourminigui.googlepages.com/
*/

ANNOUNCE RDDSYS

#include "minigui.ch"
#include "i_winuser.ch"

//////////////////////////////////////////////////////////////////////////////
procedure Main()

   SET EVENTS FUNC TO App_OnEvents

   DEFINE WINDOW Form_1 ;
      TITLE 'Demo for Gradient Background' ;
      MAIN ;
      NOMAXIMIZE NOSIZE ;
      ICON 'MAIN'

   END WINDOW

   ON KEY ESCAPE OF Form_1 ACTION ThisWindow.Release()

   ACTIVATE WINDOW Form_1

return

//////////////////////////////////////////////////////////////////////////////
function App_OnEvents( hWnd, nMsg, wParam, lParam )

   local nResult

   switch nMsg
   case WM_ERASEBKGND
      nResult := FillBlue( hWnd )
      exit
   case WM_PAINT
      nResult := App_OnPaint( hWnd )
      exit
   otherwise
      nResult := Events( hWnd, nMsg, wParam, lParam )
   end

return nResult

//////////////////////////////////////////////////////////////////////////////
function App_OnPaint( hWnd )

   local aRect := { 0, 0, 0, 0 }
   local hDC, pPS
   local cRect := ""

   hDC := BeginPaint( hWnd, @pPS )

   DRAW TEXT IN hDC AT 10, 14 ;
      VALUE "Program Setup" ;
      FONT "Verdana" SIZE 24 BOLD ITALIC ;
      FONTCOLOR WHITE TRANSPARENT ;
      ONCE

   DRAW TEXT IN hDC AT Form_1.Height - 54, Form_1.Width - 270 ;
      VALUE "Copyright (c) 2003-2017 by Grigory Filatov" ;
      FONT "Tahoma" SIZE 10 ITALIC ;
      FONTCOLOR WHITE TRANSPARENT ;
      ONCE

   EndPaint( hWnd, pPS )

return 0

//////////////////////////////////////////////////////////////////////////////
function FillBlue( hWnd )

   local hDC := GetDC( hWnd )
   local aRect := { 0, 0, 0, 0 }
   local cx, cy, nSteps, nI, blue := 200
   local brush

   GetClientRect( hWnd, @aRect )

   cx := aRect[2]
   cy := aRect[4]
   nSteps = (cy - cx) / 5
   aRect[4] := 0

   for nI := 0 to nSteps
      aRect[4] += 5

      brush := CreateSolidBrush( 0, 0, blue-- ) ; FillRect( hdc, aRect, brush )
      DeleteObject( brush )

      aRect[2] += 5
   next

   ReleaseDC( hWnd, hDC );

return 1
