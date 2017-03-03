/*
 * Harbour Win32 Demo
 *
 * Copyright 2012 Grigory Filatov <gfilatov@inbox.ru>
 *
 * Adapting of the menu to run external programs.
 * Copyright 2012 Verchenko Andrey <verchenkoag@gmail.com>
 *
*/

#include "hbgtinfo.ch"
#include "common.ch"
#include "inkey.ch"

FUNCTION Main(cMenu, cWindowMain)
LOCAL nKey, hWindowMain, cColor, nMax := 14 , nRow := 50
LOCAL cExeRun := SUBSTR(EXENAME(), RAT("\",EXENAME())+1 )

DEFAULT cMenu TO ""
DEFAULT cWindowMain TO "0"

hb_gtInfo( HB_GTI_CLOSABLE, .F. )
hb_GTInfo( HB_GTI_WINTITLE, cMenu ) // Define the title of the window from the main menu

SETMODE(nMax,nRow)
CLEAR SCREEN

IF LEN(cMenu) == 0
   ALERT(';There are no parameters to run the task !;; Running the program only from "Main-Demo.exe" !;',{" Quit "})
   QUIT
ENDIF

cColor := "15/"+ALLTRIM(cMenu)
nMax := 33 - VAL(cMenu)*2 ; nRow := 80 - VAL(cMenu)*4

SET CURSOR OFF
SETMODE(nMax,nRow)
SETCOLOR(cColor)
CLEAR SCREEN
? PADC(VERSION(),MAXCOL())
? ; ? "    Exe-file: ", cExeRun
? ; ? "    TaskTest: ", cMenu

IF VALTYPE(cWindowMain) == "C"
   hWindowMain := VAL(cWindowMain)
ENDIF

IF hWindowMain == 0
   ALERT(';The window handle of the main tasks is not defined !;; cParam2 == "0" ;',{" Quit "})
   QUIT
ENDIF

//MINIMIZE( hWindowMain )  //  Remove the main window "Main-Demo.exe" to the taskbar

@  0, 0 TO MAXROW(),MAXCOL() DOUBLE
@ MAXROW()-2,MAXCOL()-12 TO MAXROW(), MAXCOL() DOUBLE
@ MAXROW()-1,MAXCOL()-11 SAY "Y:"
@ MAXROW()-1,MAXCOL()-5 SAY "X:"

@ MAXROW()-3,5 SAY "  ESC-exit  "
@ MAXROW()-4,5 TO MAXROW()-2,16  DOUBLE
COLORWIN(MAXROW()-4,5,MAXROW()-2,16,78)

DO WHILE .T.
   nKey := INKEY(0, INKEY_ALL)
   MUPDATE()
   IF nKey == K_ESC
        EXIT
   ENDIF
   IF MINRECT( MAXROW()-4, 5, MAXROW()-2, 16 )
        EXIT
   ENDIF

ENDDO

MAXIMIZE( hWindowMain )  //  Pick up and switch to the task "Main-Demo.exe"
TONE(400,2)
QUIT

RETURN NIL

*-----------------------------------------------------------------------------*
FUNCTION MINRECT( nTop, nLeft, nBott, nRight)
LOCAL lInside := .F.
IF MROW() >= nTop .AND. MROW() <= nBott
   IF MCOL() >= nLeft .AND. MCOL() <= nRight
      lInside := .T.
   ENDIF
ENDIF

RETURN( lInside )
*-----------------------------------------------------------------------------*
FUNCTION MUPDATE()
@ MAXROW()-1,MAXCOL()-9 SAY MROW() PICT "999"
@ MAXROW()-1,MAXCOL()-3 SAY MCOL() PICT "999"
RETURN NIL
*-----------------------------------------------------------------------------*

#pragma BEGINDUMP

#include <windows.h>
#include <hbapi.h>

HB_FUNC( MINIMIZE )
{
   ShowWindow( (HWND) hb_parnl(1), SW_MINIMIZE );
}

HB_FUNC( MAXIMIZE )
{
   ShowWindow( (HWND) hb_parnl(1), SW_RESTORE );
}

#pragma ENDDUMP
