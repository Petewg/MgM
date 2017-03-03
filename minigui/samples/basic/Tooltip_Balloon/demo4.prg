//================================================================//
// Programa......: ToolTip em várias linhas
// Programador...: Marcos Antonio Gambeta
// Contato.......: dicasdeprogramacao@yahoo.com.br
// Website.......: http://geocities.yahoo.com.br/marcosgambeta/
//================================================================//

#include "minigui.ch"

Function Main

   SET TOOLTIP MAXWIDTH TO 128

   DEFINE WINDOW Form1 ;
      AT 0,0 ;
      WIDTH 400 ;
      HEIGHT 150 ;
      TITLE "ToolTip em várias linhas" ;
      MAIN

      @ 50,150 BUTTON Button1 ;
         CAPTION "OK" ;
         ACTION Form1.Release ;
         TOOLTIP "Clique aqui para fechar esta janela"

   END WINDOW

   //SET TOOLTIP MAXWIDTH TO 128 OF Form1
   SET TOOLTIP VISIBLETIME TO 5000 OF Form1

   CENTER WINDOW Form1

   ACTIVATE WINDOW Form1

Return Nil
