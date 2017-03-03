/*
 * MINIGUI - Harbour Win32 GUI library Demo
 *
 * (c) 2010 Janusz Pora <januszpora@onet.eu>
*/

#include "minigui.ch"

Function Main

   DEFINE WINDOW Form_1 ;
      AT 0,0 ;
      WIDTH 540 HEIGHT 300 ;
      TITLE 'MiniGUI PagerBox Demo' ;
      ICON 'demo.ico' ;
      MAIN ;
      FONT 'Arial' SIZE 10

      DEFINE MAIN MENU

         POPUP '&File'
            ITEM '&Double Button Size'  ACTION SetBtnSize( .t. )  NAME BTN_SIZE_2
            ITEM '&Single Button Size'  ACTION SetBtnSize( .f. )  NAME BTN_SIZE_1
            SEPARATOR
            ITEM '&Set Border 4'         ACTION SetBorderSize( 4 )
            ITEM '&Set Border 1'         ACTION SetBorderSize( 1 )
            ITEM '&No  Border  '         ACTION SetBorderSize( -1 )
            SEPARATOR
            ITEM '&Toggle PagerBox Positon' ACTION SetPagerBoxPos()
            SEPARATOR
            ITEM '&Exit'       ACTION Form_1.Release
         END POPUP
         POPUP '&Help'
            ITEM '&About'      ACTION MsgInfo ( "MiniGUI PagerBox Demo"+CRLF+"by Janusz Pora" )
         END POPUP
      END MENU


      DEFINE PAGERBOX Pager_1 CAPTION "Demo PagerBox" SCROLLSIZE 5 WIDTH 900 HEIGHT 65 BACKCOLOR GREEN AUTOSCROLL

         DEFINE TOOLBAR ToolBar_a BUTTONSIZE 45,40 FONT 'ARIAL' SIZE 8 FLAT

            BUTTON Button_1b ;
               CAPTION 'More Pager...' ;
               PICTURE 'button7.bmp' ;
               TOOLTIP 'More PagerBox button';
               ACTION Vert_CLick()

            BUTTON Button_2b ;
               CAPTION 'Button 2' ;
               PICTURE 'button8.bmp' ;
               TOOLTIP 'This is button 2';
               ACTION MsgInfo('Click! 2');

            BUTTON Button_3b ;
               CAPTION 'Button 3' ;
               PICTURE 'button6.bmp' ;
               TOOLTIP 'This is button 3';
               ACTION MsgInfo('Click! 3');
               SEPARATOR

            BUTTON Button_1a ;
               CAPTION 'Undo' ;
               PICTURE 'button4.bmp' ;
               TOOLTIP 'Undo button';
               ACTION MsgInfo('Click! 4')

            BUTTON Button_2a ;
               CAPTION 'Save' ;
               PICTURE 'button5.bmp' ;
               TOOLTIP 'Save button';
               ACTION MsgInfo('Click! 5')

            BUTTON Button_3a ;
               CAPTION 'Close' ;
               PICTURE 'button6.bmp' ;
               TOOLTIP 'Close button';
               ACTION MsgInfo('Click! 6') ;

         END TOOLBAR

      END PAGERBOX

   END WINDOW

   Form_1.Btn_Size_1.enabled := .f.

   CENTER WINDOW Form_1

   ACTIVATE WINDOW Form_1

Return Nil

*-----------------------------------------------------------------------------*
Procedure Vert_CLick
*-----------------------------------------------------------------------------*

   if ! IsWIndowDefined ( Form_2 )

      DEFINE WINDOW Form_2 ;
         WIDTH 400 HEIGHT 300 ;
         TITLE 'Vertical PagerBox Test' ;
         CHILD

         DEFINE PAGERBOX Pager_2 CAPTION "PagerBox" SCROLLSIZE 5 WIDTH 60 HEIGHT 400 BACKCOLOR BLUE VERTICAL

            DEFINE TOOLBAR ToolBar_d BUTTONSIZE 45,40 FONT 'Arial' SIZE 8 FLAT WRAP

               BUTTON Button_1c ;
                  CAPTION 'Check 1' ;
                  TOOLTIP 'This is button Check 1';
                  PICTURE 'button4.bmp' ;
                  ACTION _dummy() ;
                  CHECK GROUP

               BUTTON Button_2c ;
                  CAPTION 'Check 2' ;
                  PICTURE 'button5.bmp' ;
                  TOOLTIP 'This is button Check 2';
                  ACTION _dummy();
                  CHECK GROUP

               BUTTON Button_3c ;
                  CAPTION 'Check 3' ;
                  PICTURE 'button6.bmp' ;
                  TOOLTIP 'This is button Check 3';
                  ACTION _dummy() ;
                  CHECK GROUP

               BUTTON Button_4c ;
                  CAPTION 'Help Check' ;
                  PICTURE 'button9.bmp' ;
                  ACTION _dummy() ;
                  CHECK

            END TOOLBAR

         END PAGERBOX

      END WINDOW

      Form_2.Center

      Form_2.Activate

   ENDIF

RETURN


FUNCTION SetBtnSize(lDbl)
  LOCAL nBtnSize := _Pager_GetButtonSize( 'Pager_1', 'Form_1' )

   IF lDbl
      _Pager_SetButtonSize( 'Pager_1', 'Form_1', nBtnSize*2 )
      Form_1.Btn_Size_1.enabled := .t.
      Form_1.Btn_Size_2.enabled := .f.
   ELSE
      _Pager_SetButtonSize( 'Pager_1', 'Form_1', nBtnSize/2 )
      Form_1.Btn_Size_1.enabled := .f.
      Form_1.Btn_Size_2.enabled := .t.
   ENDIF

RETURN NIL


FUNCTION SetBorderSize(nSize)
  LOCAL nBrdSize := _Pager_GetBorder( 'Pager_1', 'Form_1' )

  _Pager_SetBorder( 'Pager_1', 'Form_1', nSize )

RETURN NIL


FUNCTION SetPagerBoxPos()
   LOCAL nPos := _Pager_GetPos( 'Pager_1', 'Form_1' )

   IF nPos == 0
      _Pager_SetPos( 'Pager_1', 'Form_1', 200 )
   ELSE
      _Pager_SetPos( 'Pager_1', 'Form_1', 0 )
   ENDIF

RETURN NIL
