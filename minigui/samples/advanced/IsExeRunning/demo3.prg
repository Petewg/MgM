/*
 * MINIGUI - Harbour Win32 GUI library Demo
 *
 * Copyright 2002-10 Roberto Lopez <harbourminigui@gmail.com>
 * http://harbourminigui.googlepages.com/
 *
 * Copyright 2013 Simon Norbert <simon.n@t-online.hu>
*/

#include "hmg.ch"

Procedure MAIN
Local cTitle := 'One Instance Sample'
 
OnlyOneInstance( cTitle )
 
DEFINE WINDOW Main ;
   WIDTH 600       ;
   HEIGHT 400      ;
   TITLE cTitle    ;
   MAIN

END WINDOW

Main.Center
Main.Activate

Return


Function OnlyOneInstance( cAppTitle )
Local hWnd := FindWindowEx( ,,, cAppTitle )
 
if hWnd # 0
   iif( IsIconic( hWnd ), Restore( hWnd ), SetForeGroundWindow( hWnd ) )
   ExitProcess( 0 )
endif

Return NIL
