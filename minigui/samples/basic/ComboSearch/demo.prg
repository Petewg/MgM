/*
 * MiniGUI ComboBox Demo
*/

#include "minigui.ch"

PROCEDURE Main()

   LOCAL aDigits := {}, i
   LOCAL aWords  := { "one", "two", "three", "twenty", "thirty" }

   for i := 1 to 2500
      aadd( aDigits, "$" + hb_NToS( hb_RandomInt( 2500 ) ) )
   next

   DEFINE WINDOW Form_1 ;
      AT 0,0 ;
      WIDTH 400 ;
      HEIGHT 200 ;
      TITLE 'ComboBox Demo' ;
      MAIN 

      DEFINE MAIN MENU
         DEFINE POPUP 'Test'
            MENUITEM 'Get Value for Combo_1' ACTION MsgInfo( Form_1.Combo_1.Value )
            MENUITEM 'Set Value for Combo_1' ;
                     ACTION ( Form_1.Text_1.Value := 'tw', Form_1.Text_3.Value := 'th' )
            SEPARATOR
            ITEM 'Exit' ACTION ThisWindow.Release
         END POPUP
         DEFINE POPUP 'Test2'
            MENUITEM 'Get Value for Combo_2' ACTION MsgInfo( Form_1.Combo_2.Value )
            MENUITEM 'Set Value for Combo_2' ACTION Form_1.Text_2.Value := hb_NToS( hb_RandomInt( 2500 ) )
         END POPUP
      END MENU


      @ 10,10 COMBOBOX Combo_1 ;
         ITEMS aWords;
         VALUE 1

      @ 40,10 TEXTBOX Text_1 VALUE If( IsVistaOrLater(), '', 'tw' ) ;
         CUEBANNER If( IsVistaOrLater(), 'tw', '' ) ;
         TOOLTIP "Search with using ComboFindStringExact" ;
         ON CHANGE Form_1.Combo_1.Value := ComboFindStringExact( GetControlHandle("Combo_1","Form_1"), Form_1.Text_1.Value )

      @ 70,10 TEXTBOX Text_3 VALUE If( IsVistaOrLater(), '', 'th' ) ;
         CUEBANNER If( IsVistaOrLater(), 'th', '' ) ;
         TOOLTIP "Search with using ComboFindString" ;
         ON CHANGE Form_1.Combo_1.Value := ComboFindString( GetControlHandle("Combo_1","Form_1"), Form_1.Text_3.Value )

      @ 10,160 COMBOBOX Combo_2 ;
         ITEMS aDigits ;
         VALUE 1000

      @ 40,160 TEXTBOX Text_2 VALUE If( IsVistaOrLater(), '', hb_NToS( hb_RandomInt( 2500 ) ) ) ;
         CUEBANNER If( IsVistaOrLater(), hb_NToS( hb_RandomInt( 2500 ) ), '' ) ;
         TOOLTIP "using Custom Search" ;
         ON CHANGE Form_1.Combo_2.Value := ComboSearch( aDigits, Form_1.Text_2.Value )

   END WINDOW

   CENTER WINDOW Form_1

   ACTIVATE WINDOW Form_1

   RETURN


FUNCTION ComboSearch( aArray, cValue )

   RETURN Ascan( aArray, {|e| SubStr(e, 2) = cValue} )
