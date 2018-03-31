/*
 * MINIGUI - Harbour Win32 GUI library Demo
 *
 * Author: Christian T. Kurowski <xharbour@wp.pl>
 *
 * MINIGUI - Harbour Win32 GUI library 
 * Copyright 2002-09 Roberto Lopez <harbourminigui@gmail.com>
*/

#include "minigui.ch"

MEMVAR nCorWidth
MEMVAR nCorHeight

PROCEDURE Main()

  LOCAL nWidth  := 800
  LOCAL nHeight := 600

  PUBLIC nCorWidth  := GetDesktopRealWidth() / nWidth
  PUBLIC nCorHeight := GetDesktopRealHeight()/ nHeight

  DEFINE WINDOW oMain ;
    AT ;
      (GetDesktopRealHeight()/2) - (nHeight/2) * nCorHeight, ;
      (GetDesktopRealWidth()/2) - (nWidth/2) * nCorWidth ;
    WIDTH nWidth * nCorWidth ;
    HEIGHT nHeight * nCorHeight ;
    TITLE 'MiniGUI Resolution Adjustment Demo' ;
    MAIN ;
    NOMAXIMIZE ;
    NOSIZE ;
    NOSYSMENU

    ON KEY F2;
      ACTION { || oMain.Row    := ((GetDesktopRealHeight()/2)-(nHeight/2)*nCorHeight),;
                  oMain.Col    := ((GetDesktopRealWidth()/2)-(nWidth/2)*nCorWidth),;
                  oMain.Width  := nWidth*nCorWidth,;
                  oMain.Height := nHeight*nCorHeight }

     DEFINE BUTTONEX ButtonEX_Exit
            ROW    5*nCorHeight
            COL    10*nCorWidth
            WIDTH  90*nCorWidth
            HEIGHT 55*nCorHeight
            CAPTION "Exit"
            ICON NIL
            ACTION {|| ThisWindow.Release }
            FONTSIZE 10*nCorHeight
            VERTICAL .T.
            TOOLTIP "Exit"
     END BUTTONEX

     DEFINE FRAME Frame_1
            ROW    70*nCorHeight
            COL    10*nCorWidth
            WIDTH  780*nCorWidth
            HEIGHT 490*nCorHeight
            FONTSIZE 14*nCorHeight
            OPAQUE .T.
            CAPTION 'MiniGUI Resolution Adjustment Demo'
     END FRAME

     DEFINE LABEL Label_1
            ROW    100*nCorHeight
            COL    20*nCorWidth
            VALUE  'Move window and press F2'
            WIDTH  380*nCorWidth
            HEIGHT 30*nCorHeight
            FONTSIZE 14*nCorHeight
     END LABEL

     DEFINE STATUSBAR FONT "ARIAL" SIZE 9*nCorHeight
            STATUSITEM 'MiniGUI Resolution Adjustment Demo'
            DATE WIDTH  85*nCorWidth
            CLOCK WIDTH 70*nCorWidth
     END STATUSBAR

  END WINDOW

  ACTIVATE WINDOW oMain

RETURN


//*****************************************************************************************
//* borrowed from [MiniGUI]\samples\advanced\FitToDesktop\FitToDesktop.prg
//*****************************************************************************************
 
#pragma BEGINDUMP

#include <mgdefs.h>

HB_FUNC (GETDESKTOPREALTOP) 
{
  RECT rect;
  SystemParametersInfo( SPI_GETWORKAREA, 1, &rect, 0 );

  hb_retni(rect.top);

}
HB_FUNC (GETDESKTOPREALLEFT) 
{
  RECT rect;
  SystemParametersInfo( SPI_GETWORKAREA, 1, &rect, 0 );

  hb_retni(rect.left);

}

HB_FUNC (GETDESKTOPREALWIDTH) 
{
  RECT rect;
  SystemParametersInfo( SPI_GETWORKAREA, 1, &rect, 0 );

  hb_retni(rect.right - rect.left);

}

HB_FUNC (GETDESKTOPREALHEIGHT) 
{
  RECT rect;
  SystemParametersInfo( SPI_GETWORKAREA, 1, &rect, 0 );

  hb_retni(rect.bottom - rect.top);
}

#pragma ENDDUMP
