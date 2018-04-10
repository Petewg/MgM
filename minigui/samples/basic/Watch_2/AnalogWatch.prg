/*
 * MINIGUI - Harbour Win32 GUI library Demo
 *
 * Author: Christian T. Kurowski <xharbour@wp.pl>
 * Revised by Grigory Filatov <gfilatov@inbox.ru>
 *
*/


#include "minigui.ch"

#define PROGRAM 'Analog Watch'

MEMVAR a, rr

PROCEDURE Main()

PRIVATE a := 640/2
PRIVATE rr := a/2

  DEFINE WINDOW Form_1 ;
    AT 0,0 ;
    WIDTH a+10 ;
    HEIGHT a+36 ;
    TITLE PROGRAM ;
    MAIN ;
    ICON "demo.ico" ;
    NOMAXIMIZE ;
    NOSIZE ;
    ON INIT {|| drawtime(.t.) } ;
    BACKCOLOR WHITE ;
    FONT "MS Sans Serif" SIZE 8

    DEFINE TIMER Timer_1 ;
      INTERVAL 1000 ;
      ACTION { || drawtime() }

    ON KEY ESCAPE ACTION ThisWindow.Release

  END WINDOW

  Form_1.Center
  Form_1.Activate

RETURN


PROCEDURE drawtime(lInit)

LOCAL i, r := 3, step_fi := PI() / 6
LOCAL N := 2 * PI() / step_fi
LOCAL x, x0, y0, x1, y1

  default lInit := .f.

  if lInit
    CLEAN MEMORY
  else
    ERASE WINDOW Form_1
  endif

  FOR i := 0 TO (N - 1)

    x0 := INT(rr * SIN( i * step_fi ) )
    y0 := INT(rr * COS( i * step_fi ) )

    x1 := INT((rr-20) * SIN( i * step_fi ) )
    y1 := INT((rr-20) * COS( i * step_fi ) )

    circle( "Form_1", INT((a/2)-r)+1 + x0, INT((a/2)-r)+1 + y0, 2*r )

    drawline( "Form_1", (a/2+x1), (a/2+y1), (a/2+x0), (a/2+y0) )

  NEXT i

  //

  step_fi := PI() / 30
  N := 2 * PI() / step_fi // N=60 (minutes)
  r := 1

  FOR i := 0 TO (N - 1)

    x0 := INT(rr * SIN( i * step_fi ) )
    y0 := INT(rr * COS( i * step_fi ) )

    x1 := INT( (rr-10) * SIN( i * step_fi ) )
    y1 := INT( (rr-10) * COS( i * step_fi ) )

    circle( "Form_1",INT((a/2)-r)+1 + x0,INT((a/2)-r)+1 + y0,2*r )

    drawline( "Form_1", (a/2+x1), (a/2+y1), (a/2+x0), (a/2+y0) )

  NEXT i

  // seconds

  x0 := INT( (rr-20) * SIN(( VAL(SUBSTR(TIME(), 7, 2))-15) * step_fi ) )
  y0 := INT( (rr-20) * COS(( VAL(SUBSTR(TIME(), 7, 2))-15) * step_fi ) )

  drawline( "Form_1", (a/2), (a/2), (a/2+x0), (a/2+y0) )

  // minutes
  x0 := INT( (rr-30) * SIN(;
      ( (VAL(SUBSTR(TIME(), 7, 2))/60) + (VAL(SUBSTR(TIME(), 4,2)) -15) ) * step_fi) )

  y0 := INT( (rr-30) * COS(;
      ( (VAL(SUBSTR(TIME(), 7, 2))/60) + (VAL(SUBSTR(TIME(), 4,2)) -15) ) * step_fi) )

  drawline( "Form_1", (a/2), (a/2), (a/2+x0), (a/2+y0), , 3 )

  // hours

  step_fi := PI() / 360

  x1 := INT( (rr-60) * SIN(;
      ( VAL(SUBSTR(TIME(), 4, 2)) + ((VAL(SUBSTR(TIME(), 1, 2))-3)*60) ) * step_fi) )
  y1 := INT( (rr-60) * COS(;
      ( VAL(SUBSTR(TIME(), 4, 2)) + ((VAL(SUBSTR(TIME(), 1, 2))-3)*60) ) * step_fi) )

  drawline( "Form_1", (a/2), (a/2), (a/2+x1), (a/2+y1), , 3 )

RETURN


STATIC PROCEDURE Circle( window, nCol, nRow, nWidth , col, linecol )

  drawellipse(window, nCol, nRow, nCol + nWidth , nRow + nWidth, linecol,, col)

RETURN
