#include "MiniGui.ch"
#include "TSBrowse.ch"


//--------------------------------------------------------------------------------------------------------------------//

Function TestStop()

   Local oBrw
   FIELD State,Last

   DbSelectArea( "Employee" )
   Index on State+Last To StName


   DEFINE FONT Font_12  FONTNAME "Tahoma" SIZE 9

   DEFINE WINDOW Form_12 At 40,60 ;
         WIDTH 800 HEIGHT 540 ;
         TITLE  "Stop browsing";
         ICON "Demo.ico";
         CHILD

    DEFINE SPLITBOX
      DEFINE TOOLBAREX Bar_1 BUTTONSIZE 35, 20

         BUTTON Btn_1 CAPTION "Stop" CHECK ;
            ACTION { ||oBrw:lDontChange := ! oBrw:lDontChange, oBrw:SetFocus()} ;
            TOOLTIP "Disable/Enable Browser's cursor..."


         BUTTON Btn_3 CAPTION  "Exit" AUTOSIZE  ;
            ACTION Form_12.Release ;
            TOOLTIP "Exit"
      END TOOLBAR

   END SPLITBOX

   DEFINE STATUSBAR
      STATUSITEM '' DEFAULT
   END STATUSBAR

   @ 50, 20 TBROWSE oBrw ALIAS "Employee"  WIDTH 760 HEIGHT 430  ;
           AUTOCOLS SELECTOR .F. EDITABLE FONT 'Font_12' ;
           MESSAGE   "Press Stop button to enable/disable the Browser's cursor"

   END WINDOW

   ACTIVATE WINDOW Form_12

   RELEASE FONT Font_12

Return Nil


Function TestUserMenu()

   Local oBrw
   FIELD State,Last

   DbSelectArea( "Employee" )
   Index on State+Last To StName


   DEFINE FONT Font_12  FONTNAME "Tahoma" SIZE 9

   DEFINE WINDOW Form_12 At 40,60 ;
         WIDTH 800 HEIGHT 540 ;
         TITLE  "Header User Menu";
         ICON "Demo.ico";
         CHILD

      DEFINE STATUSBAR
         STATUSITEM '' DEFAULT
      END STATUSBAR

      DEFINE TBROWSE oBrw AT 20,20 ALIAS "Employee"  WIDTH 760 HEIGHT 460  ;
           AUTOCOLS SELECTOR .F. EDITABLE FONT 'Font_12' ;
           MESSAGE   "Press RButton at Header in 2 or 3 Column to activate User Menu "

         oBrw:UserPopup( {|nCol| DefMenuItem(nCol,oBrw) },{2,3} )
      END TBROWSE

    END WINDOW

    ACTIVATE WINDOW Form_12

    RELEASE FONT Font_12

Return Nil


FUNCTION DefMenuItem(nCol,oBrw)
   if oBrw:lPopupActiv
      if nCol != oBrw:nPopupActiv
         if oBrw:nPopupActiv == 2
            _RemoveMenuItem ( "M_TEST1" , oBrw:cParentWnd  )
            _RemoveMenuItem ( "M_TEST2" , oBrw:cParentWnd  )
            _RemoveMenuItem ( "M_TEST3" , oBrw:cParentWnd  )
         else
            _RemoveMenuItem ( "M_TEST4" , oBrw:cParentWnd  )
            _RemoveMenuItem ( "M_TEST5" , oBrw:cParentWnd  )
         endif
      endif
   endif
   If nCol == 2
      MENUITEM 'TEST 1'  ACTION {|| MsgInfo("Menu 1 Selected") } NAME M_TEST1
      MENUITEM 'TEST 2'  ACTION {|| MsgInfo("Menu 2 Selected") } NAME M_TEST2
      MENUITEM 'TEST 3'  ACTION {|| MsgInfo("Menu 3 Selected") } NAME M_TEST3
   else
      MENUITEM 'TEST 4'  ACTION {|| MsgInfo("Menu 4 Selected") } NAME M_TEST4
      MENUITEM 'TEST 5'  ACTION {|| MsgInfo("Menu 5 Selected") } NAME M_TEST5
   endif

Return Nil
