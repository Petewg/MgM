/*
 * MiniGUI Menu Demo
*/

#include "hmg.ch"

PROCEDURE Main

   DEFINE WINDOW Win_1 ;
      AT 0, 0 ;
      WIDTH 400 ;
      HEIGHT 400 ;
      TITLE 'Menu Demo 3' ;
      MAIN ;
      ON INIT buildmenu()

      @ 10, 10 LABEL LABEL_1 VALUE "[F2] - ENABLE MENU" AUTOSIZE

      @ 35, 10 LABEL LABEL_2 VALUE "[F3] - ERASE / RESTORE MENU" AUTOSIZE

   END WINDOW

   ON KEY F2 OF Win_1 ACTION EnableMainMenu ( 'Win_1' )
   ON KEY F3 OF Win_1 ACTION iif( IsMainMenuDefined ( 'Win_1' ), clearmenu(), buildmenu() )

   ACTIVATE WINDOW Win_1

RETURN


PROCEDURE buildmenu()

   LOCAL n
   LOCAL m_char
   LOCAL m_executar

   DEFINE MAIN MENU OF Win_1

      POPUP "&File"
         MenuItem 'Open'  Action MsgInfo ( 'File:Open'  )
         MenuItem 'Save'  Action MsgInfo ( 'File:Save'  )
         MenuItem 'Print' Action MsgInfo ( 'File:Print' )
         MenuItem 'Save As...' Action MsgInfo ( 'File:Save As' ) Name SaveAs Disabled
         Separator
         MenuItem 'Exit'  Action Win_1.Release
      END POPUP

      POPUP "&Option"

      FOR n := 1 TO 3
         m_char := StrZero( n, 2 )
         m_executar := "ACT_" + m_char + "()"
         MENUITEM 'EXE ' + m_char ACTION &m_executar NAME &m_char
      NEXT

      END POPUP

   END MENU

RETURN


PROCEDURE clearmenu()

   RELEASE MAIN MENU OF Win_1

RETURN


PROCEDURE act_01()

   DisableMainMenu ( 'Win_1' )

RETURN


PROCEDURE act_02()

   MsgInfo ( 'Action 02' )

RETURN


PROCEDURE act_03()

   MsgInfo ( 'Action 03' )

RETURN


FUNCTION DisableMainMenu( cFormName )

   LOCAL nFormHandle, i, nControlCount

   nFormHandle   := GetFormHandle ( cFormName )
   nControlCount := Len ( _HMG_aControlHandles )

   FOR i := 1 TO nControlCount

      IF _HMG_aControlParentHandles[i ] ==  nFormHandle
         IF ValType ( _HMG_aControlHandles[i ] ) == 'N'
            IF _HMG_aControlType[i ] == 'MENU' .AND. _HMG_aControlEnabled[i ] == .T.
               _DisableMenuItem ( _HMG_aControlNames[i ], cFormName )
            ENDIF
         ENDIF
      ENDIF

   NEXT i

RETURN NIL


FUNCTION EnableMainMenu( cFormName )

   LOCAL nFormHandle, i, nControlCount

   nFormHandle   := GetFormHandle ( cFormName )
   nControlCount := Len ( _HMG_aControlHandles )

   FOR i := 1 TO nControlCount

      IF _HMG_aControlParentHandles[i ] ==  nFormHandle
         IF ValType ( _HMG_aControlHandles[i ] ) == 'N'
            IF _HMG_aControlType[i ] == 'MENU' .AND. _HMG_aControlEnabled[i ] == .T.
               _EnableMenuItem ( _HMG_aControlNames[i ], cFormName )
            ENDIF
         ENDIF
      ENDIF

   NEXT i

RETURN NIL
