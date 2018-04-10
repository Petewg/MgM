/*
 * MiniGUI Menu Demo
*/

#include "minigui.ch"

PROCEDURE Main

   LOCAL aMenu, cAction
   LOCAL nI

   aMenu := { { "Cadastro", "MsgInfo('Cadastro')"  }, ;
              {  "Consulta", "MsgInfo('Consulta')" }, ;
              {  "Sair", "DoMethod('Win_1','Release')" } }

   DEFINE WINDOW Win_1 ;
      AT 0, 0 ;
      WIDTH 400 ;
      HEIGHT 400 ;
      TITLE 'Menu Demo 4' ;
      MAIN

      DEFINE MAIN MENU

      FOR nI := 1 TO Len( aMenu )

         POPUP aMenu[ nI ][ 1 ]
            cAction := aMenu[ nI ][ 2 ]
            ITEM aMenu[ nI ][ 1 ] ACTION {|| &cAction }
         END POPUP

      NEXT

      END MENU

   END WINDOW

   ACTIVATE WINDOW Win_1

RETURN
