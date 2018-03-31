/*
* MiniGUI Menu Demo
*/

#include "minigui.ch"


#xcommand SHOW CONTEXTMENU OF <parent> ;
      [ AT <nRow>, <nCol> ] ;
      [ <centered: CENTERED> ] ;
      => ;
      _ShowContextMenu( <"parent">, <nRow>, <nCol>, <.centered.> )


Procedure Main

   DEFINE WINDOW Win_1 ;
      AT 0,0 ;
      WIDTH 400 ;
      HEIGHT 400 ;
      TITLE 'Dynamic Context Menu Demo ' ;
      MAIN

      DEFINE MAIN MENU
         POPUP "&File"

            MENUITEM  'Exit'  ACTION ThisWindow.Release()

         END POPUP

         POPUP "&Options"

            MENUITEM  'Dynamic Context Menu at Cursor '  ACTION DynamicContextMenu(1)
            MENUITEM  'Dynamic Context Menu Centered '   ACTION DynamicContextMenu(2)
            MENUITEM  'Dynamic Context Menu at Position '  ACTION DynamicContextMenu(3)

         END POPUP
      END MENU

   END WINDOW

   CENTER WINDOW Win_1

   ACTIVATE WINDOW Win_1

Return


Procedure MenuProc()

   If This.Name == '01'
      MsgInfo ('Action 01')
   ElseIf This.Name == '02'
      MsgInfo ('Action 02')
   ElseIf This.Name == '03'
      MsgInfo ('Action 03')
   EndIf

RETURN


FUNCTION DynamicContextMenu(typ)
   LOCAL N
   LOCAL m_char

   DEFINE CONTEXT MENU OF Win_1

      FOR N = 1 TO 3
         m_char := strzero(n,2)
         MENUITEM  'Context Item ' + m_char ACTION MenuProc() NAME &m_char
      NEXT

   END MENU

   DO CASE
      CASE typ == 1
         SHOW CONTEXTMENU OF Win_1
      CASE typ == 2
         SHOW CONTEXTMENU OF Win_1 CENTERED
      CASE typ == 3
         SHOW CONTEXTMENU OF Win_1 AT GetDesktopHeight()/2, GetDesktopWidth()/2
  ENDCASE

RETURN Nil


FUNCTION _ShowContextMenu(ParentFormName, nRow, nCol, lCentered)
   LOCAL xContextMenuParentHandle := 0
   LOCAL aRow := GetCursorPos()

   DEFAULT nRow := 0, nCol := 0, ParentFormName := ""

   If .Not. _IsWindowDefined (ParentFormName)
      xContextMenuParentHandle := _HMG_xContextMenuParentHandle
   else
      xContextMenuParentHandle := GetFormHandle ( ParentFormName )
   Endif
   if xContextMenuParentHandle == 0
      MsgMiniGuiError("Context Menu is not defined. Program terminated")
   endif
   IF lCentered
      nCol := GetWindowCol(xContextMenuParentHandle) + GetWindowWidth(xContextMenuParentHandle)/2 - 60
      nRow := GetWindowRow(xContextMenuParentHandle) + GetWindowHeight(xContextMenuParentHandle)/2 - GetTitleHeight() - 5
   ELSEIF nRow == 0 .and. nCol == 0
      nCol := aRow[2]
      nRow := aRow[1]
   ENDIF

   TrackPopupMenu ( _HMG_xContextMenuHandle , nCol , nRow , xContextMenuParentHandle )

RETURN Nil
