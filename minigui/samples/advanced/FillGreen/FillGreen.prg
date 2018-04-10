/*
 * FillGreen.prg
 *
 * Author: P.Chornyj <myorg63@mail.ru>
*/

ANNOUNCE RDDSYS

#include "minigui.ch"

PROCEDURE Main()

   LOCAL cForm := "Form_1"
   LOCAL nClr1 := RGB ( 0, 200, 0 )
   LOCAL nClr2 := RGB ( 0,   0, 0 )

   DEFINE WINDOW Form_1 ;
      TITLE 'Demo for Gradient Background';
      ICON 'setup.ico' ;
      MAIN ; 
      NOMAXIMIZE NOSIZE ;
      ON PAINT ( FillGreen( This.Handle, nClr1, nClr2 ) )

      DRAW TEXT IN cForm AT 10, 14 ;
         VALUE "Program Setup" ;
         FONT "Verdana" SIZE 24 BOLD ITALIC ;
         FONTCOLOR WHITE TRANSPARENT

      DRAW TEXT IN cForm AT Form_1.Height - 54, Form_1.Width - 250 ;
         VALUE "Copyright (c) 2007-2017 by P.Chornyj" ;
         FONT "Tahoma" SIZE 10 ITALIC ;
         FONTCOLOR WHITE TRANSPARENT

      ON KEY ESCAPE ACTION ThisWindow.Release

   END WINDOW

   ACTIVATE WINDOW Form_1

   RETURN

/*
*/
FUNCTION FillGreen( hWnd, clrFrom, clrTo )

   LOCAL hdc, pps

   hdc := BeginPaint( hWnd, @pps )

   FillGradient( hDC, 0, 0, Form_1.Height, Form_1.Width, .T., clrFrom, clrTo )

   EndPaint( hWnd, pps )

   RETURN NIL
