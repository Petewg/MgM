/*
 * MiniGUI Menu Demo
*/

#include "minigui.ch"

PROCEDURE Main

   LOCAL n
   LOCAL m_char

   DEFINE WINDOW Win_1 ;
      AT 0, 0 ;
      WIDTH 400 ;
      HEIGHT 400 ;
      TITLE 'Menu Demo 2' ;
      MAIN

   DEFINE MAIN MENU
      POPUP "&Option"

      FOR n := 1 TO 3
         m_char := StrZero( n, 2 )
         MENUITEM 'EXE ' + m_char ACTION MenuProc() NAME &m_char
      NEXT

      END POPUP
   END MENU

   END WINDOW

   ACTIVATE WINDOW Win_1

RETURN


PROCEDURE MenuProc()

   IF This.Name == '01'
      MsgInfo ( 'Action 01' )
   ELSEIF This.Name == '02'
      MsgInfo ( 'Action 02' )
   ELSEIF This.Name == '03'
      MsgInfo ( 'Action 03' )
   ENDIF

RETURN
