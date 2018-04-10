/*
 * MiniGUI Menu Demo
 */

#include "minigui.ch"

STATIC nTime1 := 0
STATIC nTime2 := 0

PROCEDURE Main()

   DEFINE WINDOW Win_1 ;
      WIDTH 400 ;
      HEIGHT 400 ;
      TITLE "Modify Menu Test" ;
      MAIN ;
      ON INIT BuildMenu()

      @ 10, 10 BUTTON b_1 CAPTION "Replace menu 2" WIDTH 120 ACTION ReplaceMenu1( "menu_2" )
      @ 40, 10 BUTTON b_2 CAPTION "Replace menu 3" WIDTH 120 ACTION ReplaceMenu2( "menu_3" )

      DEFINE STATUSBAR
         STATUSITEM "" DEFAULT
      END STATUSBAR

   END WINDOW

   ACTIVATE WINDOW Win_1

RETURN


FUNCTION BuildMenu()

   DEFINE MAIN MENU OF Win_1

   DEFINE POPUP '&Test'

      MENUITEM "&First" MESSAGE "First option" ACTION NIL

      MENUITEM "&Second" MESSAGE "Second option" ACTION NIL

      POPUP 'More 2...' NAME menu_2
         ITEM 'SubItem 1' ACTION MsgInfo( 'SubItem1 Clicked' ) NAME menu_2_1
         ITEM 'SubItem 2' ACTION MsgInfo( 'SubItem2 Clicked' ) NAME menu_2_2
      END POPUP

      MENUITEM "&Third" MESSAGE "Third option" ACTION NIL

      POPUP 'More 3...' NAME menu_3
         ITEM 'SubItem 1' ACTION MsgInfo( 'SubItem1 Clicked' ) NAME menu_3_1
         ITEM 'SubItem 2' ACTION MsgInfo( 'SubItem2 Clicked' ) NAME menu_3_2
      END POPUP

      SEPARATOR

      MENUITEM "&Exit"  MESSAGE "Exit" ACTION ThisWindow.Release()

   END POPUP

   END MENU
/*
   ReplaceMenu1( "menu_2" )
   ReplaceMenu2( "menu_3" )
*/
RETURN NIL


PROCEDURE ReplaceMenu1( cMenu )

   LOCAL i
   LOCAL cTxt
   LOCAL Caption
   LOCAL ItemName
   LOCAL bAction

   nTime1  += 1
   cTxt    := hb_ntos( nTime1 ) + " times"

   FOR i := 1 TO 2
      ItemName := cMenu + "_" + hb_ntos( i )
      Caption := "Sub 1" + hb_ntos( i ) + " Replaced " + cTxt
      bAction := hb_macroBlock( "MsgInfo( '" + Caption + "','" + cTxt + "')" )
      _ModifyMenuItem ( ItemName, 'Win_1', Caption, bAction )
   NEXT

RETURN


PROCEDURE ReplaceMenu2( cMenu )

   LOCAL i
   LOCAL cTxt
   LOCAL Caption
   LOCAL ItemName
   LOCAL bAction

   nTime2  += 1
   cTxt    := hb_ntos( nTime2 ) + " times"

   FOR i := 1 TO 2
      ItemName := cMenu + "_" + hb_ntos( i )
      Caption := "Sub 2" + hb_ntos( i ) + " Replaced " + cTxt
      bAction := hb_macroBlock( "MsgInfo( '" + Caption + "','" + cTxt + "')" )
      _ModifyMenuItem ( ItemName, 'Win_1', Caption, bAction )
   NEXT

RETURN
