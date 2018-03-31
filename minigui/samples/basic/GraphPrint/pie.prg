#include "minigui.ch"

function main

   define window m main ;
	clientarea 640, 480 ;
	Title "Print Pie Graph" ;
	backcolor {216,208,200}

   define button x
      row 10
      col 10
      caption "Draw"
      action showpie()
   end button

   define button x1
      row 40
      col 10
      caption "Print"
      action ( showpie(), printpie() )
   end button

   end window
   m.center
   m.activate
return nil


function showpie

   ERASE WINDOW m

   DRAW GRAPH IN WINDOW m;
      AT 80,40;
      TO 460,600;
      TITLE "Product Sales in 2010 (1,000$)";
      TYPE PIE;
      SERIES {1800,1500,1200,800,600,300};
      DEPTH 25;
      SERIENAMES {"Product 1","Product 2","Product 3","Product 4","Product 5","Product 6"};
      COLORS {{255,0,0},{0,0,255},{255,255,0},{0,255,0},{255,128,64},{128,0,128}};
      3DVIEW;
      SHOWXVALUES;
      SHOWLEGENDS RIGHT DATAMASK "99,999"
return nil


function printpie
   Local cPrinter

   cPrinter := GetPrinter()

   If Empty (cPrinter)
      return nil
   EndIf

   SetDefaultPrinter (cPrinter)

   PRINT GRAPH IN WINDOW m;
      AT 80,40;
      TO 460,600;
      TITLE "Product Sales in 2010 (1,000$)";
      TYPE PIE;
      SERIES {1800,1500,1200,800,600,300};
      DEPTH 25;
      SERIENAMES {"Product 1","Product 2","Product 3","Product 4","Product 5","Product 6"};
      COLORS {{255,0,0},{0,0,255},{255,255,0},{0,255,0},{255,128,64},{128,0,128}};
      3DVIEW;
      SHOWXVALUES;
      SHOWLEGENDS RIGHT DATAMASK "99,999"
return nil


#ifndef __XHARBOUR__

#pragma BEGINDUMP

#include "hbapi.h"

HB_FUNC_TRANSLATE( SETDEFAULTPRINTER, WIN_PRINTERSETDEFAULT )

#pragma ENDDUMP

#endif
